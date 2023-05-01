---
-- Placeable Beehive extended
--
-- tbd
--
-- Copyright (c) Peppie84, 2023
--
PlaceableBeehiveExtended = {
    MOD_NAME = g_currentModName or "unknown",
    PATCHLIST_HIVE_COUNT_ON_RUNTIME = {
        ["d7294ff6f5e42e624c40a2df4eeec060"] = 1,     -- Stock lvl 1
        ["215ebd1eab110e0bf84b958df9cf6695"] = 1,     -- Stock lvl 2
        ["5f1492c2fa8a3535890ab4edf04e5912"] = 1,     -- Stock lvl 3
        ["aa843f40070ca949ed4e4461d15d89ef"] = 10,    -- Stock lvl 4
        ["9375e364a873f2614c7f30c716781051"] = 33,    -- Stock lvl 5
    }
}

---TODO
function PlaceableBeehiveExtended.prerequisitesPresent(specializations)
    g_brUtils:logDebug('PlaceableBeehiveExtended.prerequisitesPresent')
    return SpecializationUtil.hasSpecialization(PlaceableBeehive, specializations)
end

---InitSpecialization
function PlaceableBeehiveExtended.initSpecialization()
    g_brUtils:logDebug('PlaceableBeehiveExtended.initSpecialization')
end

---TODO
---@param placeableType any
function PlaceableBeehiveExtended.registerFunctions(placeableType)
	SpecializationUtil.registerFunction(placeableType, "getBeehiveHiveCount", PlaceableBeehiveExtended.getBeehiveHiveCount)
    SpecializationUtil.registerFunction(placeableType, "updateActionRadius", PlaceableBeehiveExtended.updateActionRadius)
end

---registerEventListeners
---@param placeableType table
function PlaceableBeehiveExtended.registerEventListeners(placeableType)
    g_brUtils:logDebug('PlaceableBeehiveExtended.registerEventListeners')
    SpecializationUtil.registerEventListener(placeableType, "onLoad", PlaceableBeehiveExtended)
    SpecializationUtil.registerEventListener(placeableType, "onDelete", PlaceableBeehiveExtended)
end

function PlaceableBeehiveExtended.registerOverwrittenFunctions(placeableType)
	SpecializationUtil.registerOverwrittenFunction(placeableType, "getHoneyAmountToSpawn", PlaceableBeehiveExtended.getHoneyAmountToSpawn)
    --SpecializationUtil.registerOverwrittenFunction(placeableType, "getBeehiveInfluenceFactor", PlaceableBeehiveExtended.getBeehiveInfluenceFactor)
    SpecializationUtil.registerOverwrittenFunction(placeableType, "updateInfo", PlaceableBeehiveExtended.updateInfo)
end


function PlaceableBeehiveExtended.registerXMLPaths(schema, basePath)
	schema:setXMLSpecializationType("Beehive")
	schema:register(XMLValueType.FLOAT, basePath .. ".beehive#hiveCount", "The number of hives on this beehive")
	schema:setXMLSpecializationType()
end

--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
-- Load and Save

---Definiert Pfade in der savegame-Placeable-xml
---@param schema any
---@param basePath any
function PlaceableBeehiveExtended.registerSavegameXMLPaths(schema, basePath)
    g_brUtils:logDebug('PlaceableBeehiveExtended.registerSavegameXMLPaths')
    -- basePath = placeables.placeable(?).FS22_BeesRevamp.placeablebeehiveextended

	schema:setXMLSpecializationType("PlaceableBeehiveExtended")
	schema:register(XMLValueType.INT, basePath .. ".nectar", "TODO")
	schema:setXMLSpecializationType()
end

function PlaceableBeehiveExtended:loadFromXMLFile(xmlFile, key)
    g_brUtils:logDebug('PlaceableBeehiveExtended.loadFromXMLFile')
    -- key = placeables.placeable(?).FS22_BeesRevamp.placeablebeehiveextended
	local spec = self.spec_beehiveextended

	spec.nectar = xmlFile:getInt(key .. ".nectar", spec.nectar)
end

function PlaceableBeehiveExtended:saveToXMLFile(xmlFile, key, usedModNames)
    g_brUtils:logDebug('PlaceableBeehiveExtended.saveToXMLFile')
	local spec = self.spec_beehiveextended

	xmlFile:setInt(key .. ".nectar", spec.nectar)
end

--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------


---TODO
---@param savegame table
function PlaceableBeehiveExtended:onLoad(savegame)
    g_brUtils:logDebug('PlaceableBeehiveExtended.onLoad')

    self.spec_beehiveextended = self[("spec_%s."):format(PlaceableBeehiveExtended.MOD_NAME) .. 'beehiveextended']

    local xmlFile = self.xmlFile
    local spec = self.spec_beehiveextended

    local hiveCount = xmlFile:getFloat("placeable.beehive#hiveCount", -1)
    if hiveCount == -1 then
        hiveCount = 1 -- default
        -- Patch to runtime
        local i3dMd5HashFilename = getMD5(xmlFile:getValue("placeable.base.filename", "no-i3d-filename"))
        if PlaceableBeehiveExtended.PATCHLIST_HIVE_COUNT_ON_RUNTIME[i3dMd5HashFilename] ~= nil then
            hiveCount = PlaceableBeehiveExtended.PATCHLIST_HIVE_COUNT_ON_RUNTIME[i3dMd5HashFilename]
        end
    end

    spec.nectar = 0
    spec.hiveCount = tostring(hiveCount)

    spec:updateActionRadius(500);

    spec.infoTableNectar = {
        title = "Nektar",
        text = g_i18n:formatNumber(spec.nectar, 0) .. "l"
    }
    spec.infoTableHives = {
        title = "Hives",
        text = spec.hiveCount
    }

    g_messageCenter:subscribe(MessageType.WEATHER_CHANGED, PlaceableBeehiveExtended.onWeatherChanged, self)
    g_messageCenter:subscribe(MessageType.HOUR_CHANGED, PlaceableBeehiveExtended.onHourChanged, self)
end

function PlaceableBeehiveExtended:updateActionRadius(radius)
    local specBeehive = self.spec_beehive

    specBeehive.actionRadius = radius
    specBeehive.actionRadiusSquared = (specBeehive.actionRadius * 0.5) ^ 2
    specBeehive.infoTableRange.text = g_i18n:formatNumber(specBeehive.actionRadius, 0) .. "m"
end

---TODO
function PlaceableBeehiveExtended:onHourChanged()
    g_brUtils:logDebug('PlaceableBeehiveExtended.onHourChanged')
	local spec = self.spec_beehiveextended
end

---TODO
function PlaceableBeehiveExtended:onWeatherChanged()
    g_brUtils:logDebug('PlaceableBeehiveExtended.onWeatherChanged')
    g_currentMission.beehiveSystem:updateBeehivesState();
end

---TODO
function PlaceableBeehiveExtended:onDelete()
    g_brUtils:logDebug('PlaceableBeehiveExtended.onDelete')
	local spec = self.spec_beehiveextended

    g_messageCenter:unsubscribe(MessageType.WEATHER_CHANGED, self)
end

---TODO
---@param superFunc function
---@return number
function PlaceableBeehiveExtended:getHoneyAmountToSpawn(superFunc)
    g_brUtils:logDebug('PlaceableBeehiveExtended.getHoneyAmountToSpawn')
    local specBeeHive = self.spec_beehive
    local specBeeCare = self.spec_beecare
    local spec = self.spec_beehiveextended

	if specBeeHive.isProductionActive and specBeeCare.status == BeeCare.STATES.ECONOMIC_HIVE then
        local deltaTimeInHoursOfLastSpawn =  (specBeeHive.environment.dayTime - specBeeHive.lastDayTimeHoneySpawned) / 1000
		local minHoursOfLastSpawn = math.min(math.abs(deltaTimeInHoursOfLastSpawn / 3600), 1)
        local grothFactor = g_currentMission.beehiveSystem:getGrothFactor(specBeeHive.environment.currentPeriod);
        g_brUtils:logDebug('- Current grothFactor: %s', tostring(grothFactor))
        local honeyPerHourSpec = specBeeHive.honeyPerHour * grothFactor;

		specBeeHive.lastDayTimeHoneySpawned = specBeeHive.environment.dayTime

		return honeyPerHourSpec * minHoursOfLastSpawn * specBeeHive.environment.timeAdjustment
	end

	return 0
end

---TODO
function PlaceableBeehiveExtended:getBeehiveHiveCount()
    local spec = self.spec_beehiveextended
    return math.max(spec.hiveCount, 1)
end

---TODO
---@param superFunc function
---@param wx number
---@param wz number
---@return number
function PlaceableBeehiveExtended:getBeehiveInfluenceFactor(superFunc, wx, wz)
	local spec = self.spec_beehive
	local distanceToPointSquared = MathUtil.getPointPointDistanceSquared(spec.wx, spec.wz, wx, wz)
    --print("PlaceableBeehiveExtended:getBeehiveInfluenceFactor distanceToPointSquared: " .. tostring(distanceToPointSquared) )

	if distanceToPointSquared <= spec.actionRadiusSquared then
        --print("PlaceableBeehiveExtended:getBeehiveInfluenceFactor distanceToPointSquared * 0.85: " .. tostring(distanceToPointSquared * 0.85) )
        --print("PlaceableBeehiveExtended:getBeehiveInfluenceFactor ohne 1-: " .. tostring(distanceToPointSquared * 0.85 / spec.actionRadiusSquared) )
		return 1 - distanceToPointSquared * 0.85 / spec.actionRadiusSquared
	end

	return 0
end

---TODO
---@param superFunc function
---@param infoTable table
function PlaceableBeehiveExtended:updateInfo(superFunc, infoTable)
    local spec = self.spec_beehiveextended

	table.insert(infoTable, spec.infoTableNectar)
    table.insert(infoTable, spec.infoTableHives)

	superFunc(self, infoTable)
end
