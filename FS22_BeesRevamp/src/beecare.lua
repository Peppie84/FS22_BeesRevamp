---
-- BeeCare
--
-- tbd
--
-- Copyright (c) Peppie84, 2023
--
BeeCare = {
    MOD_NAME = g_currentModName or "unknown",
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
end

---registerEventListeners
---@param placeableType table
function BeeCare.registerEventListeners(placeableType)
    g_brUtils:logDebug('BeeCare.registerEventListeners')
    SpecializationUtil.registerEventListener(placeableType, "onLoad", BeeCare)
    SpecializationUtil.registerEventListener(placeableType, "onDelete", BeeCare)
    SpecializationUtil.registerEventListener(placeableType, "onFinalizePlacement", BeeCare)
	-- SpecializationUtil.registerEventListener(placeableType, "onReadStream", BeeCare)
	-- SpecializationUtil.registerEventListener(placeableType, "onWriteStream", BeeCare)
	-- SpecializationUtil.registerEventListener(placeableType, "onReadUpdateStream", BeeCare)
	-- SpecializationUtil.registerEventListener(placeableType, "onWriteUpdateStream", BeeCare)
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

	schema:setXMLSpecializationType("BeeCare")
	schema:register(XMLValueType.INT, basePath .. "#bees", "TODO")
    schema:register(XMLValueType.STRING, basePath .. "#lastOxucare", "TODO")
    schema:register(XMLValueType.STRING, basePath .. "#placedDay", "TODO")
    schema:register(XMLValueType.BOOL, basePath .. "#schwarmed", "TODO")
    schema:register(XMLValueType.BOOL, basePath .. "#schwarmPressure", "TODO")
    schema:register(XMLValueType.INT, basePath .. "#state", "TODO")
	schema:setXMLSpecializationType()
end

function BeeCare:loadFromXMLFile(xmlFile, key)
    g_brUtils:logDebug('BeeCare.loadFromXMLFile')
	local spec = self.spec_beecare

	spec.bees = xmlFile:getInt(key .. "#bees", spec.bees)
    spec.lastOxucare = xmlFile:getValue(key .. "#lastOxucare", spec.lastOxucare)
    spec.placedDay = xmlFile:getValue(key .. "#placedDay", spec.placedDay)
    spec.schwarmed = xmlFile:getBool(key .. "#schwarmed", spec.schwarmed)
    spec.schwarmPressure = xmlFile:getBool(key .. "#schwarmPressure", spec.schwarmPressure)
    spec.state = xmlFile:getInt(key .. "#state", spec.state)
    spec:updateInfoTables()
end

function BeeCare:saveToXMLFile(xmlFile, key, usedModNames)
    g_brUtils:logDebug('BeeCare.saveToXMLFile')
	local spec = self.spec_beecare

	xmlFile:setInt(key .. "#bees", spec.bees)
    xmlFile:setValue(key .. "#lastOxucare", spec.lastOxucare)
    xmlFile:setValue(key .. "#placedDay", spec.placedDay)
    xmlFile:setBool(key .. "#schwarmed", spec.schwarmed)
    xmlFile:setBool(key .. "#schwarmPressure", spec.schwarmPressure)
    xmlFile:setInt(key .. "#state", spec.state)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

---comment
function BeeCare:updateInfoTables()
    g_brUtils:logDebug('BeeCare.updateInfoTables')

    local spec = self.spec_beecare
    spec.infoTablePopulation = {
        title = 'Bee population',
        text = g_i18n:formatNumber(self:getBeePopulation()) .. ' Bees'
    }
    if spec.schwarmPressure then
        spec.infoTableSwarm = {
            title = 'Schwarmlustig',
            text = tostring(spec.schwarmPressure)
        }
    end
    spec.infoTableOxuSim = {
        title = g_i18n:getText("realbees_oxusim", BeeCare.MOD_NAME),
        text = 'Nein'
    }

    local statusHive = ''
    if spec.state == BeeCare.STATES.ECONOMIC_HIVE then
        statusHive = 'Wirtschaftsvolk'
    elseif spec.state == BeeCare.STATES.YOUNG_HIVE then
        statusHive = 'Jungvolk'
    elseif spec.state == BeeCare.STATES.DEAD then
        statusHive = 'Dead'
    end

    if spec.schwarmed then
        statusHive = statusHive .. ' (abgeschwärmt)'
    end

    g_brUtils:logDebug(' State, %s', tostring(statusHive))

    spec.infoTableState = {
        title = 'Status',
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
    spec.placedDay = BrUtils:getCurrentDayYearString()
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

    local oxuCareOnNov = 'Y'..currentYear..'M9D0'
    local oxuCareOnDec = 'Y'..currentYear..'M10D0'

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
	local spec = self.spec_beecare

    g_messageCenter:unsubscribe(MessageType.PERIOD_CHANGED, self)
    g_messageCenter:unsubscribe(MessageType.YEAR_CHANGED, self)
end

---TODO
function BeeCare:getBeehiveStatus()
    g_brUtils:logDebug('BeeCare.getBeehiveStatus')
    local spec = self.spec_beecare
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
---@param superFunc function
---@param infoTable table
function BeeCare:updateInfo(superFunc, infoTable)
    local spec = self.spec_beecare

    if spec.infoTableState ~= nil then
        table.insert(infoTable, spec.infoTableState)
    end

    table.insert(infoTable, spec.infoTablePopulation)

    if spec.infoTableSwarm then
        table.insert(infoTable, spec.infoTableSwarm)
    end

    table.insert(infoTable, spec.infoTableOxuSim)

	superFunc(self, infoTable)
end
