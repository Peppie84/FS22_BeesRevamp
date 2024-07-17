---
-- Placeable Beehive extended
--
-- Some additional functionalities for all bee hives.
-- - collecting nectar instead of honey
-- - produces honey over night
-- - bees consume also honey
-- - converts nectar into honey
-- - updates action radius to 500m
--
-- Copyright (c) Peppie84, 2023
-- https://github.com/Peppie84/FS22_BeesRevamp
--
PlaceableBeehiveExtended = {
    MOD_NAME = g_currentModName or 'unknown',
    PATCHLIST_HIVE_COUNT_ON_RUNTIME = {
        ['d7294ff6f5e42e624c40a2df4eeec060'] = 1,  -- Stock lvl 1
        ['215ebd1eab110e0bf84b958df9cf6695'] = 1,  -- Stock lvl 2
        ['5f1492c2fa8a3535890ab4edf04e5912'] = 1,  -- Stock lvl 3
        ['aa843f40070ca949ed4e4461d15d89ef'] = 10, -- Stock lvl 4
        ['9375e364a873f2614c7f30c716781051'] = 33, -- Stock lvl 5
        ["c4011d0e68dc43435cd5ba4c042365ce"] = 4,  -- https://farming-simulator.com/mod.php?mod_id=242870&title=fs2022
    },
    NECTAR_PER_BEE_IN_MILLILITER = 0.05,           -- 50ul (mikroliter)
    BEE_FLIGHTS_PER_HOUR = 2.0,
    BEE_HONEY_CONSUMATION_PER_MONTH = 0.000433,
    FLYING_BEES_PERCENTAGE = 0.66,
    HOUSE_BEES_PERCENTAGE = 0.34,
    RATIO_HONEY_KG_TO_LITER = 1.4,
    RATIO_HONEY_LITER_TO_NECTAR = 3.0
}

---PlaceableBeehiveExtended.prerequisitesPresent
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
    SpecializationUtil.registerFunction(
        placeableType,
        'getBeehiveHiveCount',
        PlaceableBeehiveExtended.getBeehiveHiveCount
    )
    SpecializationUtil.registerFunction(
        placeableType,
        'updateActionRadius',
        PlaceableBeehiveExtended.updateActionRadius
    )
    SpecializationUtil.registerFunction(
        placeableType,
        'updateNectar',
        PlaceableBeehiveExtended.updateNectar
    )
    SpecializationUtil.registerFunction(placeableType, "updateInfoTables2", PlaceableBeehiveExtended.updateNectarInfoTable)
end

---registerEventListeners
---@param placeableType table
function PlaceableBeehiveExtended.registerEventListeners(placeableType)
    g_brUtils:logDebug('PlaceableBeehiveExtended.registerEventListeners')
    SpecializationUtil.registerEventListener(placeableType, 'onLoad', PlaceableBeehiveExtended)
    SpecializationUtil.registerEventListener(placeableType, 'onDelete', PlaceableBeehiveExtended)
end

function PlaceableBeehiveExtended.registerOverwrittenFunctions(placeableType)
    SpecializationUtil.registerOverwrittenFunction(placeableType, 'getHoneyAmountToSpawn',
        PlaceableBeehiveExtended.getHoneyAmountToSpawn)
    --SpecializationUtil.registerOverwrittenFunction(placeableType, 'getBeehiveInfluenceFactor', PlaceableBeehiveExtended.getBeehiveInfluenceFactor)
    SpecializationUtil.registerOverwrittenFunction(placeableType, 'updateInfo', PlaceableBeehiveExtended.updateInfo)
end

function PlaceableBeehiveExtended.registerXMLPaths(schema, basePath)
    schema:setXMLSpecializationType('Beehive')
    schema:register(XMLValueType.FLOAT, basePath .. '.beehive#hiveCount', 'The number of hives on this bee hive')
    schema:setXMLSpecializationType()
end

--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
-- Load and Save

---Defines path on the savegame placables.xml
---@param schema any
---@param basePath any
function PlaceableBeehiveExtended.registerSavegameXMLPaths(schema, basePath)
    g_brUtils:logDebug('PlaceableBeehiveExtended.registerSavegameXMLPaths')
    -- basePath = placeables.placeable(?).FS22_BeesRevamp.placeablebeehiveextended

    schema:setXMLSpecializationType('PlaceableBeehiveExtended')
    schema:register(XMLValueType.FLOAT, basePath .. '.nectar', 'Current amount of nectar')
    schema:setXMLSpecializationType()
end

---PlaceableBeehiveExtended:loadFromXMLFile
---@param xmlFile any
---@param key any
function PlaceableBeehiveExtended:loadFromXMLFile(xmlFile, key)
    g_brUtils:logDebug('PlaceableBeehiveExtended.loadFromXMLFile')
    -- key = placeables.placeable(?).FS22_BeesRevamp.placeablebeehiveextended
    local spec = self.spec_beehiveextended

    spec.nectar = xmlFile:getFloat(key .. '.nectar', spec.nectar)

    spec:updateInfoTables2()
end

---PlaceableBeehiveExtended:saveToXMLFile
---@param xmlFile any
---@param key any
---@param usedModNames any
function PlaceableBeehiveExtended:saveToXMLFile(xmlFile, key, usedModNames)
    g_brUtils:logDebug('PlaceableBeehiveExtended.saveToXMLFile')
    local spec = self.spec_beehiveextended

    xmlFile:setFloat(key .. '.nectar', spec.nectar)
end

--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------


---PlaceableBeehiveExtended:onLoad
---@param savegame table
function PlaceableBeehiveExtended:onLoad(savegame)
    g_brUtils:logDebug('PlaceableBeehiveExtended.onLoad')

    self.spec_beehiveextended = self[('spec_%s.'):format(PlaceableBeehiveExtended.MOD_NAME) .. 'beehiveextended']

    local xmlFile = self.xmlFile
    local spec = self.spec_beehiveextended

    local hiveCount = xmlFile:getFloat('placeable.beehive#hiveCount', -1)
    if hiveCount == -1 then
        hiveCount = 1 -- default
        -- Patch to runtime
        local i3dMd5HashFilename = getMD5(xmlFile:getValue('placeable.base.filename', 'no-i3d-filename'))
        if PlaceableBeehiveExtended.PATCHLIST_HIVE_COUNT_ON_RUNTIME[i3dMd5HashFilename] ~= nil then
            hiveCount = PlaceableBeehiveExtended.PATCHLIST_HIVE_COUNT_ON_RUNTIME[i3dMd5HashFilename]
        end
    end

    spec.environment = g_currentMission.environment
    spec.nectar = 0
    spec.hiveCount = tostring(hiveCount)

    spec:updateActionRadius(500);

    spec.infoTableNectar = {
        title = g_brUtils:getModText('beesrevamp_placeablebeehiveextended_info_title_nectar'),
        text = string.format(
            g_brUtils:getModText('beesrevamp_placeablebeehiveextended_info_nectar_format'),
            g_i18n:formatNumber(spec.nectar)
        )
    }
    spec.infoTableHives = {
        title = g_brUtils:getModText('beesrevamp_placeablebeehiveextended_info_title_hives'),
        text = spec.hiveCount
    }

    g_messageCenter:subscribe(MessageType.WEATHER_CHANGED, PlaceableBeehiveExtended.onWeatherChanged, self)
    g_messageCenter:subscribe(MessageType.HOUR_CHANGED, PlaceableBeehiveExtended.onHourChanged, self)
end

function PlaceableBeehiveExtended:updateActionRadius(radius)
    local specBeehive = self.spec_beehive

    specBeehive.actionRadius = radius
    specBeehive.actionRadiusSquared = (specBeehive.actionRadius * 0.5) ^ 2
    specBeehive.infoTableRange.text = g_i18n:formatNumber(specBeehive.actionRadius, 0) .. 'm'
end

---TODO
function PlaceableBeehiveExtended:onHourChanged()
    g_brUtils:logDebug('PlaceableBeehiveExtended.onHourChanged')
    local specBeeHive = self.spec_beehive
    local specBeeCare = self.spec_beecare
    local spec = self.spec_beehiveextended

    ---
    --- Produce Nectar!
    if specBeeHive.isFxActive and specBeeCare.state == BeeCare.STATES.ECONOMIC_HIVE then
        local flyingBees = specBeeCare:getBeePopulation() * PlaceableBeehiveExtended.FLYING_BEES_PERCENTAGE
        local nectarInMlPerHour = flyingBees * PlaceableBeehiveExtended.NECTAR_PER_BEE_IN_MILLILITER *
            PlaceableBeehiveExtended.BEE_FLIGHTS_PER_HOUR
        local nectarInLiterPerHour = nectarInMlPerHour / 1000

        g_brUtils:logDebug('Produce.Nectar: ' .. nectarInLiterPerHour)

        spec:updateNectar(nectarInLiterPerHour)
    end

    ---
    --- Consume Nectar/Honey!
    local bees = specBeeCare:getBeePopulation()
    local honeyForBeesPerMonth = (bees * PlaceableBeehiveExtended.BEE_HONEY_CONSUMATION_PER_MONTH) /
        PlaceableBeehiveExtended.RATIO_HONEY_LITER_TO_NECTAR
    local honeyForBeesPerHour = honeyForBeesPerMonth / 24

    g_brUtils:logDebug('Consume.Nectar: ' .. honeyForBeesPerHour)

    spec:updateNectar(-honeyForBeesPerHour)
end

---PlaceableBeehiveExtended:onWeatherChanged
function PlaceableBeehiveExtended:onWeatherChanged()
    g_brUtils:logDebug('PlaceableBeehiveExtended.onWeatherChanged')
    g_currentMission.beehiveSystem:updateBeehivesState();
end

---PlaceableBeehiveExtended:onDelete
function PlaceableBeehiveExtended:onDelete()
    g_brUtils:logDebug('PlaceableBeehiveExtended.onDelete')
    local spec = self.spec_beehiveextended

    g_messageCenter:unsubscribe(MessageType.WEATHER_CHANGED, self)
end

---PlaceableBeehiveExtended:getHoneyAmountToSpawn
---@param superFunc function
---@return number
function PlaceableBeehiveExtended:getHoneyAmountToSpawn(superFunc)
    g_brUtils:logDebug('PlaceableBeehiveExtended.getHoneyAmountToSpawn')
    local specBeeHive = self.spec_beehive
    local specBeeCare = self.spec_beecare
    local spec = self.spec_beehiveextended

    ---
    --- Nectar into Honey!
    if specBeeHive.isProductionActive and specBeeCare.state == BeeCare.STATES.ECONOMIC_HIVE then
        if spec.nectar > 0 then
            local houseBees = specBeeCare:getBeePopulation() * PlaceableBeehiveExtended.HOUSE_BEES_PERCENTAGE
            if spec.environment.isSunOn == false then
                --- double the house bees by night
                houseBees = specBeeCare:getBeePopulation()
            end

            local nectarInMlPerHour = houseBees * PlaceableBeehiveExtended.NECTAR_PER_BEE_IN_MILLILITER
            local nectarInLiterPerHour = nectarInMlPerHour / 1000

            if nectarInLiterPerHour > spec.nectar then
                nectarInLiterPerHour = spec.nectar
            end

            spec:updateNectar(-nectarInLiterPerHour)

            return nectarInLiterPerHour / PlaceableBeehiveExtended.RATIO_HONEY_LITER_TO_NECTAR
        end
    end

    return 0
end

---PlaceableBeehiveExtended:getBeehiveHiveCount
function PlaceableBeehiveExtended:getBeehiveHiveCount()
    local spec = self.spec_beehiveextended
    return math.max(spec.hiveCount, 1)
end

---PlaceableBeehiveExtended:getBeehiveInfluenceFactor
---@param superFunc function
---@param wx number
---@param wz number
---@return number
function PlaceableBeehiveExtended:getBeehiveInfluenceFactor(superFunc, wx, wz)
    local spec = self.spec_beehive
    local distanceToPointSquared = MathUtil.getPointPointDistanceSquared(spec.wx, spec.wz, wx, wz)

    if distanceToPointSquared <= spec.actionRadiusSquared then
        return 1 - distanceToPointSquared * 0.85 / spec.actionRadiusSquared
    end

    return 0
end

---PlaceableBeehiveExtended:updateNectar
---@param nectar number
function PlaceableBeehiveExtended:updateNectar(nectar)
    local spec = self.spec_beehiveextended

    if nectar < 0 and spec.nectar <= 0 then
        return
    end

    spec.nectar = spec.nectar + nectar
    spec:updateInfoTables2()
end

function PlaceableBeehiveExtended:updateNectarInfoTable()
    g_brUtils:logDebug('BeeCare.updateNectarInfoTable')

    local spec = self.spec_beehiveextended

    spec.infoTableNectar.text = string.format(
        g_brUtils:getModText('beesrevamp_placeablebeehiveextended_info_nectar_format'),
        g_i18n:formatNumber(spec.nectar)
    )
end

---PlaceableBeehiveExtended:updateInfo
---@param superFunc function
---@param infoTable table
function PlaceableBeehiveExtended:updateInfo(superFunc, infoTable)
    local spec = self.spec_beehiveextended

    table.insert(infoTable, spec.infoTableNectar)
    table.insert(infoTable, spec.infoTableHives)

    superFunc(self, infoTable)
end
