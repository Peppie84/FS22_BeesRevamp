Test = {}

function Test.cutFruitArea(fruitIndex, overwrittenFunc, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX,
                           heightWorldZ, destroySpray, useMinForageState, excludedSprayType, setsWeeds, limitToField)
    g_brUtils:logDebug('Test:cutFruitArea')

    local numPixels, totalNumPixels, sprayFactor, plowFactor, limeFactor, weedFactor, stubbleFactor, rollerFactor, beeFactor, growthState, maxArea, terrainDetailPixelsSum =
        overwrittenFunc(fruitIndex, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ,
            destroySpray, useMinForageState, excludedSprayType, setsWeeds, limitToField)

    if Test.popBeeMultiplier then
        Test.lastBeeYieldBonusPercentage = beeFactor
    end

    return numPixels, totalNumPixels, sprayFactor, plowFactor, limeFactor, weedFactor, stubbleFactor, rollerFactor,
        beeFactor, growthState, maxArea, terrainDetailPixelsSum
end

---FSBaseMission:getHarvestScaleMultiplier
function Test:getHarvestScaleMultiplier(overwrittenFunc, fruitTypeIndex, sprayFactor, plowFactor, limeFactor, weedFactor,
                                        stubbleFactor, rollerFactor, beeYieldBonusPercentage)
    ---
    g_brUtils:logDebug('Test:getHarvestScaleMultiplier')
    g_currentMission.beehiveSystem.LAST_FRUIT_INDEX = fruitTypeIndex or FruitType.UNKNOWN

    return overwrittenFunc(self, fruitTypeIndex, sprayFactor, plowFactor, limeFactor, weedFactor, stubbleFactor,
        rollerFactor, beeYieldBonusPercentage)
end

---Cutter:processCutterArea
function Test:processCutterArea(overwrittenFunc, workArea, dt)
    local spec = self.spec_cutter
    g_brUtils:logDebug('Test:processCutterArea')

    Test.popBeeMultiplier = true
    local lastRealArea, lastArea = overwrittenFunc(self, workArea, dt)
    Test.popBeeMultiplier = false

    if Test.lastBeeYieldBonusPercentage ~= nil then
        g_brUtils:logDebug('lastBeeYieldBonusPercentage: %s', tostring(Test.lastBeeYieldBonusPercentage))
        spec.workAreaParameters.lastRealArea = lastRealArea * (1 + Test.lastBeeYieldBonusPercentage)
        lastRealArea = spec.workAreaParameters.lastRealArea
    end

    return lastRealArea, lastArea
end
