---
-- StoreItemPatcher
--
-- tbd
--
-- Copyright (c) Peppie84, 2023
--
StoreItemPatcher = {
    MOD_NAME = g_currentModName or "unknown"
}

---TODO
---@param modName string
---@param storeManager table (StoreManager)
---@param patchMeta table array<string, array<any>>
function StoreItemPatcher:patchItems(modName, storeManager, patchMeta)
    for storeItemIndex = 1, #storeManager.items do
        local storeItem = storeManager.items[storeItemIndex]
        if storeItem.categoryName == patchMeta.CATEGORY and storeItem.species == patchMeta.SPECIES then
            local xmlFile = loadXMLFile("storeItemXML", storeItem.xmlFilename)
            local baseXMLName = getXMLRootName(xmlFile)
            local baseXMLKey = baseXMLName .. ".base"
            delete(xmlFile)

            xmlFile = XMLFile.load("storeManagerLoadItemXml", storeItem.xmlFilename, storeItem.xmlSchema)
            if xmlFile == nil then
                return
            end

            if xmlFile:hasProperty(baseXMLKey .. ".filename") then
                local i3dMd5HashFilename = getMD5(xmlFile:getValue(baseXMLKey .. ".filename"))

                if patchMeta.PATCHLIST_PRICES[i3dMd5HashFilename] ~= nil then
                    StoreItemPatcher:patchPrice(storeManager, storeItemIndex, patchMeta, i3dMd5HashFilename)
                    g_brUtils:logInfo('Info: StoreItemPatcher patched: \'%s\'', tostring(storeItem.name))
                end
            end

            xmlFile:delete()
        end
    end
end

---Patch the store item by its storeItemIndex with a new price from patchMeta.PATCHLIST_PRICES
---@param storeManager table (StoreManager)
---@param storeItemIndex number
---@param patchMeta table
---@param pricePatchIndexIdentifier string
function StoreItemPatcher:patchPrice(storeManager, storeItemIndex, patchMeta, pricePatchIndexIdentifier)
    storeManager.items[storeItemIndex].price = patchMeta.PATCHLIST_PRICES[pricePatchIndexIdentifier]
end
