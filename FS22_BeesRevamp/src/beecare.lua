---
-- BeeCare
--
-- Main class for each hive for the bee care. Handles the current state,
---the number of bees, the varroa treatment and the swarm pressure.
--
-- Copyright (c) Peppie84, 2023
-- https://github.com/Peppie84/FS22_BeesRevamp
--
BeeCare = {
    MOD_NAME = g_currentModName or "unknown",
    OXUSIM_FEATURE_DISABLE = true,
    DEFAULT_BEE_VALUE_MAX = 20000,
    DEFAULT_BEE_VALUE = 14000,
    DEFAULT_BEE_VALUE_MIN = 8000,
    STATES = {
        YOUNG_HIVE = 1,
        ECONOMIC_HIVE = 2,
        DEAD = 3
    }
}

---comment
function BeeCare.prerequisitesPresent(specializations)
    g_brUtils:logDebug('BeeCare.prerequisitesPresent')
    return SpecializationUtil.hasSpecialization(PlaceableBeehiveExtended, specializations)
end

---InitSpecialization
function BeeCare.initSpecialization()
    g_brUtils:logDebug('BeeCare.initSpecialization')
end

---registerFunctions
---@param placeableType table
function BeeCare.registerFunctions(placeableType)
    g_brUtils:logDebug('BeeCare.registerFunctions')
    SpecializationUtil.registerFunction(placeableType, "getBeePopulation", BeeCare.getBeePopulation)
    SpecializationUtil.registerFunction(placeableType, "updateInfoTables", BeeCare.updateInfoTables)
    SpecializationUtil.registerFunction(placeableType, "getCanInteract", BeeCare.getCanInteract)
    SpecializationUtil.registerFunction(placeableType, "doSwarmControl", BeeCare.doSwarmControl)
    SpecializationUtil.registerFunction(placeableType, "getSwarmControleNeeded", BeeCare.getSwarmControleNeeded)
end

---registerEventListeners
---@param placeableType table
function BeeCare.registerEventListeners(placeableType)
    g_brUtils:logDebug('BeeCare.registerEventListeners')
    SpecializationUtil.registerEventListener(placeableType, "onLoad", BeeCare)
    SpecializationUtil.registerEventListener(placeableType, "onDelete", BeeCare)
    SpecializationUtil.registerEventListener(placeableType, "onFinalizePlacement", BeeCare)
    SpecializationUtil.registerEventListener(placeableType, "onInfoTriggerEnter", BeeCare)
    SpecializationUtil.registerEventListener(placeableType, "onInfoTriggerLeave", BeeCare)
end

function BeeCare.registerOverwrittenFunctions(placeableType)
    SpecializationUtil.registerOverwrittenFunction(placeableType, "updateInfo", BeeCare.updateInfo)
    SpecializationUtil.registerOverwrittenFunction(placeableType, "updateBeehiveState", BeeCare.updateBeehiveState)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Load and Save

---Defines path on the savegame placables.xml
---@param schema any
---@param basePath any
function BeeCare.registerSavegameXMLPaths(schema, basePath)
    g_brUtils:logDebug('BeeCare.registerSavegameXMLPaths')

    schema:setXMLSpecializationType('BeeCare')
    schema:register(XMLValueType.INT, basePath .. '#bees', 'Number of bees')
    schema:register(XMLValueType.STRING, basePath .. '#lastOxucare', 'Last oxuvar treatment')
    schema:register(XMLValueType.STRING, basePath .. '#placedDay', 'Placed on this day')
    schema:register(XMLValueType.BOOL, basePath .. '#swarmed', 'Is hive swarmed')
    schema:register(XMLValueType.BOOL, basePath .. '#swarmPressure', 'Has hive swarm pressure')
    schema:register(XMLValueType.INT, basePath .. '#state', 'Current state of the hive')
    schema:setXMLSpecializationType()
end

function BeeCare:loadFromXMLFile(xmlFile, key)
    g_brUtils:logDebug('BeeCare.loadFromXMLFile')
    local spec = self.spec_beecare

    spec.bees = xmlFile:getInt(key .. '#bees', spec.bees)
    spec.lastOxucare = xmlFile:getValue(key .. '#lastOxucare', spec.lastOxucare)
    spec.placedDay = xmlFile:getValue(key .. '#placedDay', spec.placedDay)
    spec.swarmed = xmlFile:getBool(key .. '#swarmed', spec.swarmed)
    spec.swarmPressure = xmlFile:getBool(key .. '#swarmPressure', spec.swarmPressure)
    spec.state = xmlFile:getInt(key .. '#state', spec.state)
    spec:updateInfoTables()
end

function BeeCare:saveToXMLFile(xmlFile, key, usedModNames)
    g_brUtils:logDebug('BeeCare.saveToXMLFile')
    local spec = self.spec_beecare

    xmlFile:setInt(key .. '#bees', spec.bees)
    xmlFile:setValue(key .. '#lastOxucare', spec.lastOxucare)
    xmlFile:setValue(key .. '#placedDay', spec.placedDay)
    xmlFile:setBool(key .. '#swarmed', spec.swarmed)
    xmlFile:setBool(key .. '#swarmPressure', spec.swarmPressure)
    xmlFile:setInt(key .. '#state', spec.state)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

---comment
function BeeCare:updateInfoTables()
    g_brUtils:logDebug('BeeCare.updateInfoTables')

    local spec = self.spec_beecare

    spec.infoTablePopulation = {
        title = g_brUtils:getModText('realbees_beecare_info_title_bee_population'),
        text = string.format(
            g_brUtils:getModText('realbees_beecare_info_bee_population_format'),
            tostring(g_i18n:formatNumber(self:getBeePopulation(), 0))
        )
    }

    if spec.swarmPressure then
        local swarmTextLabel = spec.swarmPressure and
            'realbees_beecare_common_state_on' or
            'realbees_beecare_common_state_off'

        spec.infoTableSwarm = {
            title = g_brUtils:getModText('realbees_beecare_info_title_swarm_pressure'),
            text = g_brUtils:getModText(swarmTextLabel)
        }
    end

    spec.infoTableOxuSim = {
        title = g_brUtils:getModText('realbees_beecare_info_title_oxusim'),
        text = g_brUtils:getModText('realbees_beecare_common_state_off')
    }

    local statusHive = ''
    if spec.state == BeeCare.STATES.ECONOMIC_HIVE then
        statusHive = g_brUtils:getModText('realbees_beecare_state_economic_hive')
    elseif spec.state == BeeCare.STATES.YOUNG_HIVE then
        statusHive = g_brUtils:getModText('realbees_beecare_state_young_hive')
    elseif spec.state == BeeCare.STATES.DEAD then
        statusHive = g_brUtils:getModText('realbees_beecare_state_dead_hive')
    end

    if spec.swarmed then
        statusHive = string.format('%s (%s)',
            statusHive,
            g_brUtils:getModText('realbees_beecare_state_additional_swarmed')
        )
    end

    spec.infoTableState = {
        title = g_brUtils:getModText('realbees_beecare_info_title_state'),
        text = statusHive
    }
end

---Will be called on placing a hive
function BeeCare:onFinalizePlacement()
    g_brUtils:logDebug('BeeCare.onFinalizePlacement')

    local spec = self.spec_beecare

    -- skip onFinalizePlacement if we're just in loading
    if spec.placedDay ~= '' then
        return
    end

    spec.bees = math.random(BeeCare.DEFAULT_BEE_VALUE_MIN, BeeCare.DEFAULT_BEE_VALUE)
    spec.placedDay = g_brUtils:getCurrentDayYearString()
    spec.state = BeeCare.STATES.YOUNG_HIVE
    spec:updateInfoTables()
end

---Initialize beecare for this bee hive
---@param savegame table
function BeeCare:onLoad(savegame)
    g_brUtils:logDebug('BeeCare.onLoad')

    self.spec_beecare = self[('spec_%s.beecare'):format(BeeCare.MOD_NAME)]
    self.spec_beehiveextended = self[('spec_%s.beehiveextended'):format(PlaceableBeehiveExtended.MOD_NAME)]

    local spec = self.spec_beecare

    spec.activatable = SwarmControlActivatable.new(self)

    spec.environment = g_currentMission.environment
    spec.bees = BeeCare.DEFAULT_BEE_VALUE
    spec.lastOxucare = ''
    spec.placedDay = ''
    spec.state = BeeCare.STATES.YOUNG_HIVE
    spec.swarmed = false
    spec.swarmPressure = false

    spec.infoTablePopulation = nil
    spec.infoTableSwarm = nil
    spec.infoTableOxuSim = nil
    spec.infoTableState = nil
    spec:updateInfoTables()

    spec.dirtyFlag = self:getNextDirtyFlag()

    g_messageCenter:subscribe(MessageType.PERIOD_CHANGED, BeeCare.onPeriodChanged, self)
    g_messageCenter:subscribe(MessageType.YEAR_CHANGED, BeeCare.onYearChanged, self)
end

---On Year changed, check oxucare was made else the hive
---will die due to high varroa mite infection otherwise
---transformn to an economic hive
function BeeCare:onYearChanged()
    g_brUtils:logDebug('BeeCare.onYearChanged')

    local spec = self.spec_beecare
    local specBeeHiveExtended = self.spec_beehiveextended
    local currentYear = spec.environment.currentYear - 1

    local oxuCareOnNov = 'Y' .. currentYear .. 'M9D0'
    local oxuCareOnDec = 'Y' .. currentYear .. 'M10D0'

    if BeeCare.OXUSIM_FEATURE_DISABLE == true then
        spec.lastOxucare = oxuCareOnDec
    end

    if spec.lastOxucare == nil or
        spec.lastOxucare == '' or
        not (spec.lastOxucare == oxuCareOnNov or
            spec.lastOxucare == oxuCareOnDec) then
        -- dead!!
        spec.bees = 0
        specBeeHiveExtended:updateActionRadius(0)
        spec.state = BeeCare.STATES.DEAD
        g_brUtils:logDebug('Dead!')
    else
        -- will transform to a full hive
        spec.bees = math.random(BeeCare.DEFAULT_BEE_VALUE, BeeCare.DEFAULT_BEE_VALUE_MAX)
        spec.state = BeeCare.STATES.ECONOMIC_HIVE
        g_brUtils:logDebug('ECONOMIC_HIVE!')
    end

    spec.swarmed = false
    spec.swarmPressure = false

    spec:updateInfoTables()
end

---On period change, check if last month was swarmpressur
---to let them swarm! Otherwise roll the swarmPressure with
---a 75% chance, only between MAR-JUL
function BeeCare:onPeriodChanged()
    g_brUtils:logDebug('BeeCare.onPeriodChanged')
    local spec = self.spec_beecare

    if spec.swarmPressure then
        spec.swarmed = true
        spec.swarmPressure = false
        spec.bees = spec.bees * 0.5
    end

    local currentPeriod = spec.environment.currentPeriod
    if currentPeriod >= 1 and currentPeriod <= 6 and not spec.swarmed and spec.state == BeeCare.STATES.ECONOMIC_HIVE then
        local random = math.random()
        if random <= 0.75 then
            spec.swarmPressure = true
        end
        spec:updateInfoTables()
    end
end

---Get the current bee population
---@return number
function BeeCare:getBeePopulation()
    local specBeeHiveExtended = self.spec_beehiveextended
    local spec = self.spec_beecare

    local grothFactor = g_currentMission.beehiveSystem:getGrothFactor(spec.environment.currentPeriod);
    local beePopulation = spec.bees * math.abs(grothFactor)

    return (specBeeHiveExtended:getBeehiveHiveCount() * beePopulation) - 1 -- minus the queen :P
end

---Clean up by onDelete
function BeeCare:onDelete()
    g_brUtils:logDebug('BeeCare.onDelete')

    g_messageCenter:unsubscribe(MessageType.PERIOD_CHANGED, self)
    g_messageCenter:unsubscribe(MessageType.YEAR_CHANGED, self)
end

---On nearby hive enter
function BeeCare:onInfoTriggerEnter()
    g_brUtils:logDebug('BeeCare.onInfoTriggerEnter')
    local spec = self.spec_beecare
    g_currentMission.activatableObjectsSystem:addActivatable(spec.activatable)
end

---On nearby hive leaves
function BeeCare:onInfoTriggerLeave()
    g_brUtils:logDebug('BeeCare.onInfoTriggerLeave')
    local spec = self.spec_beecare
    g_currentMission.activatableObjectsSystem:removeActivatable(spec.activatable)
end

---Can the current player interact with that hive
---@return boolean
function BeeCare:getCanInteract()
    return g_currentMission.accessHandler:canPlayerAccess(self)
end

---Action do swarm control and remove the swarm pressure.
function BeeCare:doSwarmControl()
    local spec = self.spec_beecare
    spec.swarmPressure = false
    spec.infoTableSwarm = nil
    spec:updateInfoTables()
end

---Returns if a current swarm control is needed
---@return boolean
function BeeCare:getSwarmControleNeeded()
    return self.spec_beecare.swarmPressure
end

---Overwrite the original updateBeehiveState and control the
---the flying bees with other conditions
---@param overwrittenFunc function
function BeeCare:updateBeehiveState(overwrittenFunc)
    g_brUtils:logDebug('BeeCare.updateBeehiveState')
    local spec = self.spec_beecare
    local specBeeHive = self.spec_beehive

    overwrittenFunc(self)

    local beePopulation = spec:getBeePopulation()
    spec:updateInfoTables()

    if beePopulation <= 0 then
        specBeeHive.isFxActive = false
        specBeeHive.isProductionActive = false
        g_effectManager:stopEffects(specBeeHive.effects)
        g_soundManager:stopSample(specBeeHive.samples.idle)
    end
end

---Updates the infoTable of this hive
---@param overwrittenFunc function
---@param infoTable table
function BeeCare:updateInfo(overwrittenFunc, infoTable)
    local spec = self.spec_beecare

    if spec.infoTableState ~= nil then
        table.insert(infoTable, spec.infoTableState)
    end

    table.insert(infoTable, spec.infoTablePopulation)

    if spec.infoTableSwarm then
        table.insert(infoTable, spec.infoTableSwarm)
    end

    if BeeCare.OXUSIM_FEATURE_DISABLE == false then
        table.insert(infoTable, spec.infoTableOxuSim)
    end

    overwrittenFunc(self, infoTable)
end
