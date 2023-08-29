---
-- BeeCare
--
-- tbd
--
-- Copyright (c) Peppie84, 2023
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
    SpecializationUtil.registerFunction(placeableType, "getBeehiveStatus", BeeCare.getBeehiveStatus)
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

-- ---Definiert Pfade in der modDesc-Placeable-xml
-- ---@param schema any
-- ---@param basePath any
-- function BeeCare.registerXMLPaths(schema, basePath)
--     g_brUtils:logDebug('BeeCare.registerXMLPaths')
-- 	-- schema:setXMLSpecializationType("BeeCare")
-- 	-- --schema:register(XMLValueType.STRING, basePath .. ".beecare#saveId", "TODO")
-- 	-- schema:register(XMLValueType.BOOL, basePath .. ".beecare#swarmed", "TODO", false)
-- 	-- schema:register(XMLValueType.INT, basePath .. ".beecare#bees", "TODO", 14000)
--     -- schema:register(XMLValueType.STRING, basePath .. ".beecare#lastOxusim", "TODO")
-- 	-- schema:setXMLSpecializationType()
-- end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- MULTIPLAYER!

-- function BeeCare:onReadUpdateStream(streamId, connection)
-- 	local spec = self.spec_husbandry
-- 	spec.globalProductionFactor = streamReadUInt8(streamId) / 100
-- end

-- function BeeCare:onWriteUpdateStream(streamId, connection)
-- 	local spec = self.spec_husbandry

-- 	streamWriteUInt8(streamId, MathUtil.round(spec.globalProductionFactor * 100))
-- end


-- function BeeCare:onReadStream(streamId, connection)
-- 	local spec = self.spec_husbandry

-- 	if spec.unloadingStation ~= nil then
-- 		local unloadingStationId = NetworkUtil.readNodeObjectId(streamId)

-- 		spec.unloadingStation:readStream(streamId, connection)
-- 		g_client:finishRegisterObject(spec.unloadingStation, unloadingStationId)
-- 	end

-- 	if spec.loadingStation ~= nil then
-- 		local loadingStationId = NetworkUtil.readNodeObjectId(streamId)

-- 		spec.loadingStation:readStream(streamId, connection)
-- 		g_client:finishRegisterObject(spec.loadingStation, loadingStationId)
-- 	end

-- 	if spec.storage ~= nil then
-- 		local storageId = NetworkUtil.readNodeObjectId(streamId)

-- 		spec.storage:readStream(streamId, connection)
-- 		g_client:finishRegisterObject(spec.storage, storageId)
-- 	end

-- 	spec.globalProductionFactor = streamReadUInt8(streamId) / 255
-- end

-- function BeeCare:onWriteStream(streamId, connection)
-- 	local spec = self.spec_husbandry

-- 	if spec.unloadingStation ~= nil then
-- 		NetworkUtil.writeNodeObjectId(streamId, NetworkUtil.getObjectId(spec.unloadingStation))
-- 		spec.unloadingStation:writeStream(streamId, connection)
-- 		g_server:registerObjectInStream(connection, spec.unloadingStation)
-- 	end

-- 	if spec.loadingStation ~= nil then
-- 		NetworkUtil.writeNodeObjectId(streamId, NetworkUtil.getObjectId(spec.loadingStation))
-- 		spec.loadingStation:writeStream(streamId, connection)
-- 		g_server:registerObjectInStream(connection, spec.loadingStation)
-- 	end

-- 	if spec.storage ~= nil then
-- 		NetworkUtil.writeNodeObjectId(streamId, NetworkUtil.getObjectId(spec.storage))
-- 		spec.storage:writeStream(streamId, connection)
-- 		g_server:registerObjectInStream(connection, spec.storage)
-- 	end

-- 	streamWriteUInt8(streamId, MathUtil.round(spec.globalProductionFactor * 255))
-- end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Load and Save

---Definiert Pfade in der savegame-Placeable-xml
---@param schema any
---@param basePath any
function BeeCare.registerSavegameXMLPaths(schema, basePath)
    g_brUtils:logDebug('BeeCare.registerSavegameXMLPaths')
    -- basePath = placeables.placeable(?).FS22_BeesRevamp.beecare

    schema:setXMLSpecializationType('BeeCare')
    schema:register(XMLValueType.INT, basePath .. '#bees', 'TODO')
    schema:register(XMLValueType.STRING, basePath .. '#lastOxucare', 'TODO')
    schema:register(XMLValueType.STRING, basePath .. '#placedDay', 'TODO')
    schema:register(XMLValueType.BOOL, basePath .. '#schwarmed', 'TODO')
    schema:register(XMLValueType.BOOL, basePath .. '#schwarmPressure', 'TODO')
    schema:register(XMLValueType.INT, basePath .. '#state', 'TODO')
    schema:setXMLSpecializationType()
end

function BeeCare:loadFromXMLFile(xmlFile, key)
    g_brUtils:logDebug('BeeCare.loadFromXMLFile')
    local spec = self.spec_beecare

    spec.bees = xmlFile:getInt(key .. '#bees', spec.bees)
    spec.lastOxucare = xmlFile:getValue(key .. '#lastOxucare', spec.lastOxucare)
    spec.placedDay = xmlFile:getValue(key .. '#placedDay', spec.placedDay)
    spec.schwarmed = xmlFile:getBool(key .. '#schwarmed', spec.schwarmed)
    spec.schwarmPressure = xmlFile:getBool(key .. '#schwarmPressure', spec.schwarmPressure)
    spec.state = xmlFile:getInt(key .. '#state', spec.state)
    spec:updateInfoTables()
end

function BeeCare:saveToXMLFile(xmlFile, key, usedModNames)
    g_brUtils:logDebug('BeeCare.saveToXMLFile')
    local spec = self.spec_beecare

    xmlFile:setInt(key .. '#bees', spec.bees)
    xmlFile:setValue(key .. '#lastOxucare', spec.lastOxucare)
    xmlFile:setValue(key .. '#placedDay', spec.placedDay)
    xmlFile:setBool(key .. '#schwarmed', spec.schwarmed)
    xmlFile:setBool(key .. '#schwarmPressure', spec.schwarmPressure)
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

    if spec.schwarmPressure then
        local schwarmTextLabel = spec.schwarmPressure and
            'realbees_beecare_common_state_on' or
            'realbees_beecare_common_state_off'

        spec.infoTableSwarm = {
            title = g_brUtils:getModText('realbees_beecare_info_title_schwarm_pressure'),
            text = g_brUtils:getModText(schwarmTextLabel)
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

    if spec.schwarmed then
        statusHive = string.format('%s (%s)',
            statusHive,
            g_brUtils:getModText('realbees_beecare_state_additional_schwarmed')
        )
    end

    g_brUtils:logDebug(' State, %s', statusHive)

    spec.infoTableState = {
        title = g_brUtils:getModText('realbees_beecare_info_title_state'),
        text = statusHive
    }
end

---comment
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

---TODO
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
    spec.schwarmed = false
    spec.schwarmPressure = false

    spec.infoTablePopulation = nil
    spec.infoTableSwarm = nil
    spec.infoTableOxuSim = nil
    spec.infoTableState = nil
    spec:updateInfoTables()

    spec.dirtyFlag = self:getNextDirtyFlag()

    g_messageCenter:subscribe(MessageType.PERIOD_CHANGED, BeeCare.onPeriodChanged, self)
    g_messageCenter:subscribe(MessageType.YEAR_CHANGED, BeeCare.onYearChanged, self)
end

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

    spec.schwarmed = false
    spec.schwarmPressure = false

    spec:updateInfoTables()
end

---TODO
function BeeCare:onPeriodChanged()
    g_brUtils:logDebug('BeeCare.onPeriodChanged')
    local spec = self.spec_beecare

    if spec.schwarmPressure then
        spec.schwarmed = true
        spec.schwarmPressure = false
        spec.bees = spec.bees * 0.5
    end

    local currentPeriod = spec.environment.currentPeriod
    if currentPeriod >= 1 and currentPeriod <= 6 and not spec.schwarmed and spec.state == BeeCare.STATES.ECONOMIC_HIVE then
        local random = math.random()
        if random <= 0.75 then
            spec.schwarmPressure = true
        end
        spec:updateInfoTables()
    end
end

---TODO
---@return number
function BeeCare:getBeePopulation()
    local specBeeHiveExtended = self.spec_beehiveextended
    local spec = self.spec_beecare

    local grothFactor = g_currentMission.beehiveSystem:getGrothFactor(spec.environment.currentPeriod);
    local beePopulation = spec.bees * math.abs(grothFactor)

    return (specBeeHiveExtended:getBeehiveHiveCount() * beePopulation) - 1 -- minus the queen :P
end

---TODO
function BeeCare:onDelete()
    g_brUtils:logDebug('BeeCare.onDelete')

    g_messageCenter:unsubscribe(MessageType.PERIOD_CHANGED, self)
    g_messageCenter:unsubscribe(MessageType.YEAR_CHANGED, self)
end

---TODO
function BeeCare:getBeehiveStatus()
    g_brUtils:logDebug('BeeCare.getBeehiveStatus')
    local spec = self.spec_beecare
end

---TODO
function BeeCare:onInfoTriggerEnter()
    g_brUtils:logDebug('BeeCare.onInfoTriggerEnter')
    local spec = self.spec_beecare
    g_currentMission.activatableObjectsSystem:addActivatable(spec.activatable)
end

---TODO
function BeeCare:onInfoTriggerLeave()
    g_brUtils:logDebug('BeeCare.onInfoTriggerLeave')
    local spec = self.spec_beecare
    g_currentMission.activatableObjectsSystem:removeActivatable(spec.activatable)
end

---TODO
---@return boolean
function BeeCare:getCanInteract()
    return g_currentMission.accessHandler:canPlayerAccess(self)
end

---TODO
function BeeCare:doSwarmControl()
    local spec = self.spec_beecare
    spec.schwarmPressure = false
    spec.infoTableSwarm = nil
    spec:updateInfoTables()
end

---TODO
---@return boolean
function BeeCare:getSwarmControleNeeded()
    return self.spec_beecare.schwarmPressure
end

---TODO
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

---TODO
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

    table.insert(infoTable, spec.infoTableOxuSim)

    overwrittenFunc(self, infoTable)
end
