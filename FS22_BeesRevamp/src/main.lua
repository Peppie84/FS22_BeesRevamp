--
-- Main
--
-- Main class for initialize the bees revamp mod.
--
-- Copyright (c) Peppie84, 2023
-- https://github.com/Peppie84/FS22_BeesRevamp
--
---@type string directory of the mod.
local modDirectory = g_currentModDirectory or ''
---@type string name of the mod.
local modName = g_currentModName or 'unknown'

---@type table current manual attach instance
local modEnvironment

source(modDirectory .. 'src/brutils.lua')
source(modDirectory .. 'src/activatables/swarmcontrolactivatable.lua')
source(modDirectory .. 'src/beehivesystemextended.lua')
source(modDirectory .. 'src/storeitempatcher.lua')
source(modDirectory .. 'src/specializationpatcher.lua')
source(modDirectory .. 'src/fruittypepatcher.lua')
source(modDirectory .. 'src/filltypepatcher.lua')

source(modDirectory .. 'src/harvest.lua')

---Mission00 is loading
---@param mission table (Mission00)
local function load(mission)
    -- Patch beehive store items
    local beehivePatchMeta = {
        CATEGORY = 'BEEHIVES',
        SPECIES = 'placeable',
        PATCHLIST_PRICES = {
            ['d7294ff6f5e42e624c40a2df4eeec060'] = 200,   -- Stock lvl 1
            ['215ebd1eab110e0bf84b958df9cf6695'] = 400,   -- Stock lvl 2
            ['5f1492c2fa8a3535890ab4edf04e5912'] = 500,   -- Stock lvl 3
            ['aa843f40070ca949ed4e4461d15d89ef'] = 4000,  -- Stock lvl 4
            ['9375e364a873f2614c7f30c716781051'] = 16000,  -- Stock lvl 5
            ['3a4a10c57e06959d5c51a920ec432a80'] = 450,   -- https://farming-simulator.com/mod.php?mod_id=258373&title=fs2022
            ['98cdfe4ea9e2f01dac978f2892daef26'] = 200,   -- https://farming-simulator.com/mod.php?mod_id=242870&title=fs2022
            ['c4011d0e68dc43435cd5ba4c042365ce'] = 1150,  -- https://farming-simulator.com/mod.php?mod_id=242870&title=fs2022
            ['5f8c5339e645b43380da721a356ca8b7'] = 450,   -- https://farming-simulator.com/mod.php?mod_id=242870&title=fs2022
        },
        PATCHLIST_HIVE_COUNT = {
            ['d7294ff6f5e42e624c40a2df4eeec060'] = 1,  -- Stock lvl 1
            ['215ebd1eab110e0bf84b958df9cf6695'] = 1,  -- Stock lvl 2
            ['5f1492c2fa8a3535890ab4edf04e5912'] = 1,  -- Stock lvl 3
            ['aa843f40070ca949ed4e4461d15d89ef'] = 10, -- Stock lvl 4
            ['9375e364a873f2614c7f30c716781051'] = 33, -- Stock lvl 5
            ['c4011d0e68dc43435cd5ba4c042365ce'] = 4,  -- https://farming-simulator.com/mod.php?mod_id=242870&title=fs2022
        },
        PATCHLIST_YIELD_BONUS = {
            ['CANOLA']    = {
                ['yieldBonus'] = 0.3,
                ['hivesPerHa'] = 3
            },
            ['SUNFLOWER'] = {
                ['yieldBonus'] = 0.8,
                ['hivesPerHa'] = 4
            },
            ['POTATO']    = {
                ['yieldBonus'] = 0,
                ['hivesPerHa'] = 0
            },
            ['ALFALFA']   = {
                ['yieldBonus'] = 0.15,
                ['hivesPerHa'] = 10
            },
            ['CLOVER']    = {
                ['yieldBonus'] = 0.10,
                ['hivesPerHa'] = 8
            },
            ['CLOVERGRASS']    = {
                ['yieldBonus'] = 0.10,
                ['hivesPerHa'] = 8
            },
            ['BUCKWHEAT'] = {
                ['yieldBonus'] = 0.25,
                ['hivesPerHa'] = 4.5
            },
            ['PHACELIA']  = {
                ['yieldBonus'] = 0.25,
                ['hivesPerHa'] = 4
            },
            ['SILPHIE']   = {
                ['yieldBonus'] = 0.50,
                ['hivesPerHa'] = 4
            },
            ['MUSTARD']   = {
                ['yieldBonus'] = 0.50,
                ['hivesPerHa'] = 4
            },
        }
    }

    -- create a new beehivesystem mod class
    modEnvironment = BeehiveSystemExtended.new(mission, beehivePatchMeta, nil)
    -- overwrite the current beehivesystem with our new one
    mission.beehiveSystem = modEnvironment

    --First version, do not patch the filltype pricePerLiter
    FillTypePatcher:patchBasePrice(g_fillTypeManager)
    StoreItemPatcher:patchItems(modName, g_storeManager, beehivePatchMeta)
    SpecializationPatcher.patchPlacablesWithNewSpec(modName, g_placeableTypeManager)
    FruitTypePatcher:patchFruitsBeeYieldBonus(g_fruitTypeManager, beehivePatchMeta.PATCHLIST_YIELD_BONUS)
end

---Mission00 is unloading
local function unload()
    if modEnvironment ~= nil then
        modEnvironment = nil
    end
end

---loadBeesRevampHelpLine
---@param self table
---@param overwrittenFunc function
---@param ... any
---@return boolean
local function loadBeesRevampHelpLine(self, overwrittenFunc, ...)
    local ret = overwrittenFunc(self, ...)
    if ret then
        self:loadFromXML(Utils.getFilename('gui/helpLine.xml', modDirectory))
        return true
    end
    return false
end


--- Initialize the mod
local function init()
    Mission00.load = Utils.prependedFunction(Mission00.load, load)
    Mission00.delete = Utils.appendedFunction(FSBaseMission.delete, unload)

    HelpLineManager.loadMapData = Utils.overwrittenFunction(HelpLineManager.loadMapData, loadBeesRevampHelpLine)
    FSDensityMapUtil.cutFruitArea = Utils.overwrittenFunction(FSDensityMapUtil.cutFruitArea, Harvest.cutFruitArea)
    SpecializationPatcher.installSpecializations(modName, g_placeableSpecializationManager, modDirectory, g_placeableTypeManager)
end

init()
