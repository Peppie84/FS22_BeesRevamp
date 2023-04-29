Test = {}

---FSDensityMapUtil.cutFruitArea
---@param self table
---@param overwrittenFunc function
---@param fruitIndex any
---@param startWorldX any
---@param startWorldZ any
---@param widthWorldX any
---@param widthWorldZ any
---@param heightWorldX any
---@param heightWorldZ any
---@param destroySpray any
---@param useMinForageState any
---@param excludedSprayType any
---@param setsWeeds any
---@param limitToField any
---@return unknown
function Test.cutFruitArea(self, overwrittenFunc, fruitIndex, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, destroySpray, useMinForageState, excludedSprayType, setsWeeds, limitToField)

    local messageFormat = "Test.cutFruitArea x, z = %s, %s - getBeehiveInfluenceFactorAt: %s"
    local message = string.format(messageFormat, tostring(startWorldX), tostring(startWorldZ), tostring(g_currentMission.beehiveSystem:getBeehiveInfluenceFactorAt(startWorldZ, startWorldX)))
    g_brUtils:logDebug(message)

    return overwrittenFunc(self, fruitIndex, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, destroySpray, useMinForageState, excludedSprayType, setsWeeds, limitToField)
end

---FSBaseMission:getHarvestScaleMultiplier
---@param self table
---@param overwrittenFunc function
---@param fruitTypeIndex any
---@param sprayFactor any
---@param plowFactor any
---@param limeFactor any
---@param weedFactor any
---@param stubbleFactor any
---@param rollerFactor any
---@param beeYieldBonusPercentage any
function Test.getHarvestScaleMultiplier(self, overwrittenFunc, fruitTypeIndex, sprayFactor, plowFactor, limeFactor, weedFactor, stubbleFactor, rollerFactor, beeYieldBonusPercentage)
    g_brUtils:logDebug('Test.getHarvestScaleMultiplier')
    return overwrittenFunc(self, fruitTypeIndex, sprayFactor, plowFactor, limeFactor, weedFactor, stubbleFactor, rollerFactor, beeYieldBonusPercentage)
end
