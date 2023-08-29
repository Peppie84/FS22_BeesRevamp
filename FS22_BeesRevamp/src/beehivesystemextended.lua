---
-- BeehiveSystemExtended
--
-- The BeehiveSystemExtended class derives from the original BeehiveSystem class
-- and adds some special cases to it.
--
-- Copyright (c) Peppie84, 2023
--
BeehiveSystemExtended = {
    MOD_NAME = g_currentModName or "unknown",
    MAX_HONEY_PER_MONTH_INDEXED_BY_PERIOD = { 0.75, 1.50, 2.25, 3.20, 2.80, 2.00, 1.50, 0.75, -0.5, -0.5, -0.5, -0.5 },
    DEBUG = true,
    LAST_FRUIT_INDEX = FruitType.UNKNOWN
}

local BeehiveSystemExtended_mt = Class(BeehiveSystemExtended, BeehiveSystem)

---TODO
---@param mission table current loaded mission table
---@param customMt any custom metatable class
---@return table (BeehiveSystemExtended) returns BeehiveSystemExtended instance
function BeehiveSystemExtended.new(mission, beehivePatchMeta, customMt)
    local self = BeehiveSystemExtended:superClass().new(mission, customMt or BeehiveSystemExtended_mt)

    self.beehiveInfluenceFactorAtHiveCount = 0
    self.fieldUpdateCache = FruitType.UNKNOWN
    self.beehivePatchMeta = beehivePatchMeta

    self:addFieldInfoExtension()

    return self
end

---TODO
---@param mission table
function BeehiveSystemExtended:onMissionStart(mission)
    -- kann gelöscht werden, wenn nichts rein kommt ...
end

---TODO
function BeehiveSystemExtended:updateState()
    g_brUtils:logDebug('BeehiveSystemExtended.updateState')

    local environment = self.mission.environment
    self.isFxActive = true
    self.isProductionActive = true

    local isRaining = environment.weather:getIsRaining()
    local isTemperaturToFly = environment.weather:getCurrentTemperature() > 10
    local isSunOn = environment.isSunOn
    local isWinterSeason = environment.currentSeason == Environment.SEASON.WINTER

    if isRaining or not isTemperaturToFly or not isSunOn or isWinterSeason then
        self.isFxActive = false
    end

    g_brUtils:logDebug('- CurrentFxActive: %s', self.isFxActive)
    g_brUtils:logDebug('- CurrentIsProductionActive: %s', self.isProductionActive)
end

---TODO
---@param period number
---@return number
function BeehiveSystemExtended:getGrothFactor(period)
    ---TODO Rename to groth factor
    return self.MAX_HONEY_PER_MONTH_INDEXED_BY_PERIOD[period]
end

---TODO
function BeehiveSystemExtended:delete()
    g_brUtils:logDebug('BeehiveSystemExtended.delete')
    BeehiveSystemExtended:superClass().delete(self)
end

---TODO
---@param farmId number
function BeehiveSystemExtended:updateBeehivesOutput(farmId)
    g_brUtils:logDebug('BeehiveSystemExtended.updateBeehivesOutput')
    if self.mission:getIsServer() then
        for i = 1, #self.beehivesSortedRadius do
            local beehive = self.beehivesSortedRadius[i]
            local beehiveOwner = beehive:getOwnerFarmId()

            if farmId == nil or farmId == beehiveOwner then
                local palletSpawner = BeehiveSystemExtended:superClass().getFarmBeehivePalletSpawner(self, beehiveOwner)

                if palletSpawner ~= nil then
                    local honeyAmount = beehive:getHoneyAmountToSpawn()
                    g_brUtils:logDebug('- honeyAmount: %s', tostring(honeyAmount))

                    palletSpawner:addFillLevel(honeyAmount)
                end
            end
        end
    end
end

---TODO
---@param wx number
---@param wz number
---@return number
function BeehiveSystemExtended:getBeehiveInfluenceFactorAt(wx, wz)
    local beehiveCount = self:getBeehiveInfluenceHiveCountAt(wx, wz)
    local farmLand = g_farmlandManager:getFarmlandAtWorldPosition(wx, wz)

    local totalFieldArea = farmLand.totalFieldArea or farmLand.areaInHa
    if totalFieldArea == nil or self.LAST_FRUIT_INDEX == FruitType.UNKNOWN then
        return 0
    end

    local fruitType = g_fruitTypeManager:getFruitTypeByIndex(self.LAST_FRUIT_INDEX)
    if fruitType == nil then
        return 0
    end

    local fruitYieldBonus = self:getYieldBonusByFruitName(fruitType.name)

    if fruitYieldBonus.yieldBonus == 0 then
        return 0
    end

    g_brUtils:logDebug('- LAST_FRUIT_INDEX: %s', tostring(self.LAST_FRUIT_INDEX))
    g_brUtils:logDebug('- totalFieldArea: %s', tostring(totalFieldArea))
    g_brUtils:logDebug('- beeYieldBonusPercentage: %s', tostring(fruitType.beeYieldBonusPercentage))
    g_brUtils:logDebug('- result: %s',
        tostring(math.min(beehiveCount / (totalFieldArea * fruitYieldBonus.hivesPerHa), 1)))

    return math.min(beehiveCount / (totalFieldArea * fruitYieldBonus.hivesPerHa), 1)
end

---TODO
---@param wx number
---@param wz number
---@return number
function BeehiveSystemExtended:getBeehiveInfluenceHiveCountAt(wx, wz)
    local beehiveInfluenceCounter = 0

    for i = 1, #self.beehivesSortedRadius do
        local beehive = self.beehivesSortedRadius[i]
        if beehive:getBeehiveInfluenceFactor(wx, wz) > 0 and beehive:getBeePopulation() > 0 then
            beehiveInfluenceCounter = beehiveInfluenceCounter + beehive:getBeehiveHiveCount()
        end
    end

    return beehiveInfluenceCounter
end

-------------------------------------------------------------------------------

function BeehiveSystemExtended:addFieldInfoExtension()
    if g_modIsLoaded["FS22_precisionFarming"] then
        local precisionFarmingMod = FS22_precisionFarming.g_precisionFarming
        if precisionFarmingMod ~= nil then
            precisionFarmingMod.fieldInfoDisplayExtension:addFieldInfo(
                "Influenced by Bees",
                self,
                self.updateFieldInfoDisplay2,
                4,
                nil
            )
            precisionFarmingMod.fieldInfoDisplayExtension:addFieldInfo(
                "Bee Bonus",
                self,
                self.updateFieldInfoDisplay,
                4,
                nil
            )
        end

        PlayerHUDUpdater.fieldAddFruit = Utils.appendedFunction(
            PlayerHUDUpdater.fieldAddFruit,
            function(updater, data, box)
                self.fieldUpdateCache = data.fruitTypeMax or FruitType.UNKNOWN
            end
        )
    else -- OR simply add Crop Rotation Info to standard HUDs
        PlayerHUDUpdater.fieldAddFruit = Utils.appendedFunction(
            PlayerHUDUpdater.fieldAddFruit,
            BeehiveSystemExtended.fieldAddFruit
        )
    end
end

---TODO
---@param fieldInfo any
---@param startWorldX any
---@param startWorldZ any
---@param widthWorldX any
---@param widthWorldZ any
---@param heightWorldX any
---@param heightWorldZ any
---@param isColorBlindMode any
function BeehiveSystemExtended:updateFieldInfoDisplay(fieldInfo, startWorldX, startWorldZ, widthWorldX, widthWorldZ,
                                                      heightWorldX, heightWorldZ, isColorBlindMode)
    if g_farmlandManager:getOwnerIdAtWorldPosition(startWorldX, startWorldZ) ~= self.mission.player.farmId then
        return nil
    end

    local player = g_currentMission.player

    local beeHiveYieldBonusAtPlayerPosition = g_currentMission.beehiveSystem:getBeehiveInfluenceFactorAt(
        player.baseInformation.lastPositionX,
        player.baseInformation.lastPositionZ
    )
    local beeHiveInfluencedHiveCount = g_currentMission.beehiveSystem:getBeehiveInfluenceHiveCountAt(
        startWorldX,
        startWorldZ
    )
    local farmLand = g_farmlandManager:getFarmlandAtWorldPosition(
        player.baseInformation.lastPositionX,
        player.baseInformation.lastPositionZ
    )

    local totalFieldArea = farmLand.totalFieldArea
    if totalFieldArea == nil then
        totalFieldArea = 0
    end

    local fruitTypeIndex = self.fieldUpdateCache
    if fruitTypeIndex == nil or fruitTypeIndex == FruitType.UNKNOWN then
        return
    end

    local fruitType = g_fruitTypeManager:getFruitTypeByIndex(fruitTypeIndex)
    local fruitYieldBonus = self:getYieldBonusByFruitName(fruitType.name)

    fieldInfo.beeFactor = beeHiveYieldBonusAtPlayerPosition
    fieldInfo.totalFieldArea = totalFieldArea
    fieldInfo.fruitTypeIndex = self.fieldUpdateCache
    fieldInfo.beeYieldBonus = fruitYieldBonus
    fieldInfo.fruitName = fruitType.name:upper()

    local factor = 0

    if fruitYieldBonus.yieldBonus ~= 0 then
        factor = beeHiveInfluencedHiveCount / (totalFieldArea * fruitYieldBonus.hivesPerHa)
        factor = math.min(factor * fruitYieldBonus.yieldBonus, fruitYieldBonus.yieldBonus)
    end

    local value = string.format(
        "+ %s %%",
        g_i18n:formatNumber(factor * 100, 2)
    )
    local color = { 1.0, 1.0, 1.0, 1 }

    -- value, color, additionalValue
    return value, color, nil
end

---Returns the PATCHLIST_YIELD_BONUS table entry for the given fruitName. A 0-value table is returned when no entry is found.
---@param fruitName string Fruit name
---@return table {yieldBonus, hivesPerHa}
function BeehiveSystemExtended:getYieldBonusByFruitName(fruitName)
    local defaultYieldBonus = { ["yieldBonus"] = 0, ["hivesPerHa"] = 0 }

    local fruitYieldBonus = self.beehivePatchMeta.PATCHLIST_YIELD_BONUS[fruitName:upper()]
    if fruitYieldBonus == nil then
        return defaultYieldBonus
    end

    return fruitYieldBonus
end

---TODO
---@param fieldInfo any
---@param startWorldX any
---@param startWorldZ any
---@param widthWorldX any
---@param widthWorldZ any
---@param heightWorldX any
---@param heightWorldZ any
---@param isColorBlindMode any
function BeehiveSystemExtended:updateFieldInfoDisplay2(fieldInfo, startWorldX, startWorldZ, widthWorldX, widthWorldZ,
                                                       heightWorldX, heightWorldZ, isColorBlindMode)
    if g_farmlandManager:getOwnerIdAtWorldPosition(startWorldX, startWorldZ) ~= self.mission.player.farmId then
        return nil
    end

    local beeHiveInfluencedHiveCount = g_currentMission.beehiveSystem:getBeehiveInfluenceHiveCountAt(
        startWorldX,
        startWorldZ
    )
    fieldInfo.beeHiveInfluencedHiveCount = beeHiveInfluencedHiveCount

    local value = string.format(
        "%s Hives",
        g_i18n:formatNumber(beeHiveInfluencedHiveCount, 0)
    )

    return value, { 1.0, 1.0, 1.0, 1 }, nil, nil
end

---TODO
---@param fieldInfo any
---@return number
---@return number
---@return unknown
---@return unknown
function BeehiveSystemExtended:yieldChangeFunc(fieldInfo)
    if fieldInfo.fruitTypeIndex == nil or fieldInfo.beeHiveInfluencedHiveCount == nil then
        return 0, 1, nil, nil
    end

    --fieldInfo.beeHiveInfluencedHiveCount  = beeHiveInfluencedHiveCount
    --fieldInfo.beeFactor                   = max
    --fieldInfo.totalFieldArea              = ha
    --fieldInfo.beeYieldBonus               = patchObj.hivesPerHa

    local beeFactor = (fieldInfo.beeFactor * fieldInfo.beeYieldBonus) or 0
    local factor = (fieldInfo.beeHiveInfluencedHiveCount / (fieldInfo.totalFieldArea * fieldInfo.beeYieldBonus.hivesPerHa)) *
        fieldInfo.beeYieldBonus
    local maxFactor = math.min(factor, beeFactor)

    --- factor, proportion, _yieldPotential, _yieldPotentialToHa
    return 0, 1, nil, nil
end

---comment
---@param data table
---@param box table InfoBox
function BeehiveSystemExtended:fieldAddFruit(data, box)
    g_brUtils:logDebug('BeehiveSystemExtended.fieldAddFruit')

    local fruitTypeIndex = data.fruitTypeMax
    if fruitTypeIndex == nil then
        return
    end
    local fruitType = g_fruitTypeManager:getFruitTypeByIndex(fruitTypeIndex)
    local player = g_currentMission.player

    local beeHiveYieldBonusAtPlayerPosition = g_currentMission.beehiveSystem:getBeehiveInfluenceFactorAt(
        player.baseInformation.lastPositionX,
        player.baseInformation.lastPositionZ
    ) * fruitType.beeYieldBonusPercentage;

    local beeHiveInfluencedHiveCount = g_currentMission.beehiveSystem:getBeehiveInfluenceHiveCountAt(
        player.baseInformation.lastPositionX,
        player.baseInformation.lastPositionZ
    )
    local farmLand = g_farmlandManager:getFarmlandAtWorldPosition(
        player.baseInformation.lastPositionX,
        player.baseInformation.lastPositionZ
    )

    local totalFieldArea = farmLand.totalFieldArea
    if totalFieldArea == nil then
        totalFieldArea = 0
    end

    box:addLine("Influenced by Bees", string.format("%s Hives", g_i18n:formatNumber(beeHiveInfluencedHiveCount, 0)))
    box:addLine("Bee Bonus", string.format("+ %s %%", g_i18n:formatNumber(beeHiveYieldBonusAtPlayerPosition * 100, 2)))
    box:addLine("Field area", g_i18n:formatNumber(totalFieldArea, 0))
end

---TODO
---@param posX number
---@param posZ number
---@param rotY number
function BeehiveSystemExtended:updateFieldInfo(posX, posZ, rotY)
    if self.requestedFieldData then
        return
    end

    -- multiple calls per second!
end

-- function BeehiveSystemExtended:addPalletSpawnerFillLevel(superFunc,fillLevel)
-- 	if self.isServer then
--         superFunc(self,fillLevel)
--         local spec = self.spec_beehivePalletSpawner

--         print("- FillLevel: " .. spec.pendingLiters)
-- 	end
-- end

-- PlaceableBeehivePalletSpawner.addFillLevel = Utils.overwrittenFunction(PlaceableBeehivePalletSpawner.addFillLevel, BeehiveSystemExtended.addPalletSpawnerFillLevel)
-- PlaceableBeehive.getHoneyAmountToSpawn = Utils.overwrittenFunction(PlaceableBeehive.getHoneyAmountToSpawn, BeehiveSystemExtended.getHoneyAmountToSpawn)
