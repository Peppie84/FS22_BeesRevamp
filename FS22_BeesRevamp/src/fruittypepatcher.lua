---
-- FruitType Patcher
--
-- TODO
--
-- Copyright (c) Peppie84, 2023
--
FruitTypePatcher = {
}

---TODO
---@param modName any
---@param fruitTypeManager any
---@param patchMeta any
function FruitTypePatcher:patchTypes(modName, fruitTypeManager, patchMeta)
    for patchFruitTypeName, patchFruitTypeDesc in pairs(patchMeta.PATCHLIST_YIELD_BONUS) do
        local fruitType = fruitTypeManager:getFruitTypeByName(patchFruitTypeName)
        if fruitType ~= nil then
            fruitType.beeYieldBonusPercentage = patchFruitTypeDesc.yieldBonus
            g_brUtils:logInfo('FruitType %s set beeYieldBonusPercentage to %s!', tostring(patchFruitTypeName), tostring(patchFruitTypeDesc.yieldBonus))
        end
    end
end
