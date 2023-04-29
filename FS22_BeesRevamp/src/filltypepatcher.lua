---
-- FillTypePatcher
--
--
-- Copyright (c) Peppie84, 2023
--
FillTypePatcher = {
    REAL_PRICE_PERLITER = 13.15 -- €
}

---TODO
---@param modName string
---@param fillTypeManager table (FillTypeManager)
function FillTypePatcher:patchTypes(modName, fillTypeManager)
    local fillType = fillTypeManager:getFillTypeByName('HONEY')
    if fillType ~= nil then
        fillType.pricePerLiter = FillTypePatcher.REAL_PRICE_PERLITER
        g_brUtils:logInfo('FillType Honey patched!')
    end
end
