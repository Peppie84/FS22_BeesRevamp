Harvest = {
    popBeeMultiplier = false,
    lastBeeYieldBonusPercentage = 0,
}

---CutFruitArea
function Harvest.cutFruitArea(fruitIndex, overwrittenFunc, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX,
                           heightWorldZ, destroySpray, useMinForageState, excludedSprayType, setsWeeds, limitToField)
    g_brUtils:logDebug('Harvest:cutFruitArea')

    local numPixels, totalNumPixels, sprayFactor, plowFactor, limeFactor, weedFactor, stubbleFactor, rollerFactor, beeFactor, growthState, maxArea, terrainDetailPixelsSum =
        overwrittenFunc(fruitIndex, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ,
            destroySpray, useMinForageState, excludedSprayType, setsWeeds, limitToField)

    if Harvest.popBeeMultiplier then
        Harvest.lastBeeYieldBonusPercentage = beeFactor
    end

    return numPixels, totalNumPixels, sprayFactor, plowFactor, limeFactor, weedFactor, stubbleFactor, rollerFactor,
        beeFactor, growthState, maxArea, terrainDetailPixelsSum
end

---FSBaseMission:getHarvestScaleMultiplier
function Harvest:getHarvestScaleMultiplier(overwrittenFunc, fruitTypeIndex, sprayFactor, plowFactor, limeFactor, weedFactor,
                                        stubbleFactor, rollerFactor, beeYieldBonusPercentage)
    ---
    g_brUtils:logDebug('Harvest:getHarvestScaleMultiplier')
    g_currentMission.beehiveSystem.LAST_FRUIT_INDEX = fruitTypeIndex or FruitType.UNKNOWN

    return overwrittenFunc(self, fruitTypeIndex, sprayFactor, plowFactor, limeFactor, weedFactor, stubbleFactor,
        rollerFactor, beeYieldBonusPercentage)
end

---Cutter:processCutterArea
function Harvest:processCutterArea(overwrittenFunc, workArea, dt)
    local spec = self.spec_cutter
    g_brUtils:logDebug('Harvest:processCutterArea')

    Harvest.popBeeMultiplier = true
    local lastRealArea, lastArea = overwrittenFunc(self, workArea, dt)
    Harvest.popBeeMultiplier = false

    if Harvest.lastBeeYieldBonusPercentage ~= nil then
        g_brUtils:logDebug('lastBeeYieldBonusPercentage: %s', tostring(Harvest.lastBeeYieldBonusPercentage))
        spec.workAreaParameters.lastRealArea = lastRealArea * (1 + Harvest.lastBeeYieldBonusPercentage)
        lastRealArea = spec.workAreaParameters.lastRealArea
    end

    return lastRealArea, lastArea
end
