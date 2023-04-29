---
-- BeeCare
--
-- tbd
--
-- Copyright (c) Peppie84, 2023
--
BeeCare = {
    MOD_NAME = g_currentModName or "unknown",
    DEFAULT_BEE_VALUE = 14000
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
end

---registerEventListeners
---@param placeableType table
function BeeCare.registerEventListeners(placeableType)
    g_brUtils:logDebug('BeeCare.registerEventListeners')
    SpecializationUtil.registerEventListener(placeableType, "onLoad", BeeCare)
    SpecializationUtil.registerEventListener(placeableType, "onDelete", BeeCare)
    -- SpecializationUtil.registerEventListener(placeableType, "onFinalizePlacement", BeeCare)
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
    schema:register(XMLValueType.BOOL, basePath .. "#schwarmed", "TODO")
    schema:register(XMLValueType.BOOL, basePath .. "#schwarmee", "TODO")
	schema:setXMLSpecializationType()
end

function BeeCare:loadFromXMLFile(xmlFile, key)
    g_brUtils:logDebug('BeeCare.loadFromXMLFile')
	local spec = self.spec_beecare

	spec.bees = xmlFile:getInt(key .. "#bees", spec.bees)
    spec.lastOxucare = xmlFile:getValue(key .. "#lastOxucare", spec.lastOxucare)
    spec.schwarmed = xmlFile:getBool(key .. "#schwarmed", spec.schwarmed)
    spec.schwarmee = xmlFile:getBool(key .. "#schwarmee", spec.schwarmee)
end

function BeeCare:saveToXMLFile(xmlFile, key, usedModNames)
    g_brUtils:logDebug('BeeCare.saveToXMLFile')
	local spec = self.spec_beecare

	xmlFile:setInt(key .. "#bees", spec.bees)
    xmlFile:setValue(key .. "#lastOxucare", spec.lastOxucare)
    xmlFile:setBool(key .. "#schwarmed", spec.schwarmed)
    xmlFile:setBool(key .. "#schwarmee", spec.schwarmee)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


---TODO
---@param savegame table
function BeeCare:onLoad(savegame)
    g_brUtils:logDebug('BeeCare.onLoad')

    self.spec_beecare = self[("spec_%s.beecare"):format(BeeCare.MOD_NAME)]
    self.spec_beehiveextended = self[("spec_%s.beehiveextended"):format(PlaceableBeehiveExtended.MOD_NAME)]

    local spec = self.spec_beecare

    spec.environment = g_currentMission.environment
    spec.bees = BeeCare.DEFAULT_BEE_VALUE
    spec.lastOxucare = ''
    spec.schwarmed = false
    spec.schwarmee = false

    spec.infoTablePopulation = {
        title = "Bee population",
        text = g_i18n:formatNumber(self:getBeePopulation()) .. " Bees"
    }
    spec.infoTableSwarm = {
        title = "Schwarmlustig",
        text = tostring(spec.schwarmee)
    }
    spec.infoTableOxuSim = {
        title = g_i18n:getText("realbees_oxusim", BeeCare.MOD_NAME),
        text = "Nein"
    }

    spec.dirtyFlag = self:getNextDirtyFlag()

    g_messageCenter:subscribe(MessageType.YEAR_CHANGED, BeeCare.onYearChanged, self)
end

---TODO
function BeeCare:onYearChanged()
    g_brUtils:logDebug('BeeCare.onYearChanged')
    local spec = self.spec_beecare
    local specBeeHiveExtended = self.spec_beehiveextended

    local currentYear = spec.environment.currentYear - 1

    local oxuCareOnNov = currentYear .. '-9'
    local oxuCareOnDec = currentYear .. '-10'

    if spec.lastOxucare == nil or
        spec.lastOxucare == '' or
        not (spec.lastOxucare == oxuCareOnNov or
        spec.lastOxucare == oxuCareOnDec) then
        -- died!
        spec.bees = 0
        specBeeHiveExtended:updateActionRadius(0)
    end
end

---TODO
---@return number
function BeeCare:getBeePopulation()
    local specBeeHiveExtended = self.spec_beehiveextended
    local spec = self.spec_beecare

    local grothFactor = g_currentMission.beehiveSystem:getGrothFactor(spec.environment.currentPeriod);

    return (specBeeHiveExtended:getBeehiveHiveCount() * (spec.bees * grothFactor))
end

---TODO
function BeeCare:onDelete()
    g_brUtils:logDebug('BeeCare.onDelete')
	local spec = self.spec_beecare

    g_messageCenter:unsubscribe(MessageType.YEAR_CHANGED, self)
end

---TODO
function BeeCare:getBeehiveStatus()
    g_brUtils:logDebug('BeeCare.getBeehiveStatus')
    local spec = self.spec_beecare
end

---TODO
---@param superFunc function
function BeeCare:updateBeehiveState(superFunc)
    g_brUtils:logDebug('BeeCare.updateBeehiveState')
    local spec = self.spec_beecare
    local specBeeHive = self.spec_beehive

    superFunc(self)

    local beePopulation = spec:getBeePopulation()
    spec.infoTablePopulation.text = g_i18n:formatNumber(beePopulation) .. " Bees"

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
	table.insert(infoTable, spec.infoTablePopulation)
    table.insert(infoTable, spec.infoTableSwarm)
    table.insert(infoTable, spec.infoTableOxuSim)

	superFunc(self, infoTable)
end
