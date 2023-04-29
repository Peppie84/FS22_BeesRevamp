--
-- Main
--
-- Main class for initialize the real bees mod.
--
-- Copyright (c) Peppie84, 2023
--
---@type string directory of the mod.
local modDirectory = g_currentModDirectory or ''
---@type string name of the mod.
local modName = g_currentModName or 'unknown'

---@type table current manual attach instance
local modEnvironment

source(modDirectory .. 'src/brutils.lua')
source(modDirectory .. 'src/beehivesystemextended.lua')
source(modDirectory .. 'src/storeitempatcher.lua')
source(modDirectory .. 'src/specializationpatcher.lua')
source(modDirectory .. 'src/fruittypepatcher.lua')
source(modDirectory .. 'src/filltypepatcher.lua')

source(modDirectory .. 'src/test.lua')

---Mission00 is loading
---@param mission table (Mission00)
local function load(mission)
    -- Patch beehive store items
    local beehivePatchMeta = {
        CATEGORY = 'BEEHIVES',
        SPECIES = 'placeable',
        PATCHLIST_PRICES = {
            ["d7294ff6f5e42e624c40a2df4eeec060"] = 200,     -- Stock lvl 1
            ["215ebd1eab110e0bf84b958df9cf6695"] = 400,     -- Stock lvl 2
            ["5f1492c2fa8a3535890ab4edf04e5912"] = 450,     -- Stock lvl 3
            ["aa843f40070ca949ed4e4461d15d89ef"] = 2500,    -- Stock lvl 4
            ["9375e364a873f2614c7f30c716781051"] = 8500,    -- Stock lvl 5
            ["3a4a10c57e06959d5c51a920ec432a80"] = 450,     -- https://farming-simulator.com/mod.php?mod_id=258373&title=fs2022
            ["98cdfe4ea9e2f01dac978f2892daef26"] = 200,     -- https://farming-simulator.com/mod.php?mod_id=242870&title=fs2022
            ["c4011d0e68dc43435cd5ba4c042365ce"] = 1150,    -- https://farming-simulator.com/mod.php?mod_id=242870&title=fs2022
            ["5f8c5339e645b43380da721a356ca8b7"] = 450,     -- https://farming-simulator.com/mod.php?mod_id=242870&title=fs2022
            ["778abd40c811b423ed2e0d91af9ef3b7"] = 14500,   -- https://farming-simulator.com/mod.php?mod_id=225503&title=fs2022
        },
        PATCHLIST_HIVE_COUNT = {
            ["d7294ff6f5e42e624c40a2df4eeec060"] = 1,     -- Stock lvl 1
            ["215ebd1eab110e0bf84b958df9cf6695"] = 1,     -- Stock lvl 2
            ["5f1492c2fa8a3535890ab4edf04e5912"] = 1,     -- Stock lvl 3
            ["aa843f40070ca949ed4e4461d15d89ef"] = 10,    -- Stock lvl 4
            ["9375e364a873f2614c7f30c716781051"] = 33,    -- Stock lvl 5
        },
        PATCHLIST_YIELD_BONUS = {
            ["CANOLA"] = {
                ["yieldBonus"] = 0.3,
                ["hivesPerHa"] = 3
            },
            ["SUNFLOWER"]  = {
                ["yieldBonus"] = 0.8,
                ["hivesPerHa"] = 4
            },
            ["POTATO"]      = {
                ["yieldBonus"] = 0.05,
                ["hivesPerHa"] = 3
            },
            ["ALFALFA"] = {
                ["yieldBonus"] = 0.15,
                ["hivesPerHa"] = 10
            },
            ["CLOVER"] = {
                ["yieldBonus"] = 0.10,
                ["hivesPerHa"] = 8
            },
            ["BUCKWHEAT"] = {
                ["yieldBonus"] = 0.25,
                ["hivesPerHa"] = 4.5
            },
            ["PHACELIA"] = {
                ["yieldBonus"] = 0.25,
                ["hivesPerHa"] = 4
            },
            ["STRAWBERRY"] = {
                ["yieldBonus"] = 0.50,
                ["hivesPerHa"] = 1.5
            },
            ["SILPHIE"] = {
                ["yieldBonus"] = 0.50,
                ["hivesPerHa"] = 4
            },
        }
    }

    -- create a new beehivesystem mod class
    modEnvironment = BeehiveSystemExtended.new(mission, beehivePatchMeta, nil)
    -- overwrite the current beehivesystem with our new one
    mission.beehiveSystem = modEnvironment

    FillTypePatcher:patchTypes(modName, g_fillTypeManager)
    StoreItemPatcher:patchItems(modName, g_storeManager, beehivePatchMeta)
    SpecializationPatcher.patchPlacablesWithNewSpec(modName, g_placeableTypeManager)
    FruitTypePatcher:patchTypes(modName, g_fruitTypeManager, beehivePatchMeta)
end

---Mission00 is unloading
local function unload()
    if modEnvironment ~= nil then
        modEnvironment = nil
    end
end

---Called when player clicks start.
---@param mission table (Mission00)
local function startMission(mission)
    modEnvironment:onMissionStart(mission)
end

--- Initialize the mod
local function init()

    g_brUtils.DEBUG_MODE = true

    Mission00.load = Utils.prependedFunction(Mission00.load, load)
    Mission00.delete = Utils.appendedFunction(FSBaseMission.delete, unload)
    Mission00.onStartMission = Utils.appendedFunction(Mission00.onStartMission, startMission)

    FSDensityMapUtil.cutFruitArea = Utils.overwrittenFunction(FSDensityMapUtil.cutFruitArea, Test.cutFruitArea)
    FSBaseMission.setHarvestScaleRatio = Utils.overwrittenFunction(FSBaseMission.setHarvestScaleRatio, Test.getHarvestScaleMultiplier)

    SpecializationPatcher.installSpecializations(modName, g_placeableSpecializationManager, modDirectory, g_placeableTypeManager)
end


init()


-- local function initSpecialization(typeManager)
--     -- if typeManager.typeName == "placeable" then
--     --     RealBees.installSpecializations(g_placeableTypeManager, g_specializationManager, modDirectory, modName)
--     -- end
-- end

-- -- isActive
-- function isActive()
--     return g_modIsLoaded["FS22_RealBees"]
-- end

-- -- init
-- function init()
--     FSBaseMission.initTerrain = Utils.appendedFunction(FSBaseMission.initTerrain, initTerrain)
--     Mission00.load = Utils.prependedFunction(Mission00.load, load)

--     -- -- change old beehive placeable system

--     -- addConsoleCommand("mydebug1", "Debugme", "__debug1", BeehiveSystemMod)
--     -- addConsoleCommand("mydebug2", "Debugme", "__debug2", BeehiveSystemMod)
-- end

-- -- initTerrain
-- function initTerrain(mission, terrainId, filename)
--     log("Main RealBees initTerrain")
--     if not isActive() then return end

--     --BeehiveSystem.updateState = Utils.overwrittenFunction(BeehiveSystem.updateState, BeehiveSystemMod.updateState)
--     --PlaceableBeehive.getHoneyAmountToSpawn = Utils.overwrittenFunction(PlaceableBeehive.getHoneyAmountToSpawn, BeehiveSystemMod.getHoneyAmountToSpawn)
-- end

-- -- load
-- function load()
--     log("Main RealBees load")
--     if not isActive() then return end

--     BeehiveSystem.onHourChanged = Utils.overwrittenFunction(BeehiveSystem.onHourChanged, BeehiveSystemMod.onHourChanged)

--     SpecializationManager.addSpecialization = Utils.overwrittenFunction(SpecializationManager.addSpecialization, BeehiveSystemMod.AddSpecialization)
--     SpecializationManager.initDataStructures = Utils.appendedFunction(SpecializationManager.initDataStructures, BeehiveSystemMod.initDataStructures)

--     --BeehiveSystem.updateState = Utils.overwrittenFunction(BeehiveSystem.updateState, BeehiveSystemMod.updateState)
--     --PlaceableBeehive.getHoneyAmountToSpawn = Utils.overwrittenFunction(PlaceableBeehive.getHoneyAmountToSpawn, BeehiveSystemMod.getHoneyAmountToSpawn)
-- end

-- -- function PostInitSpecializations(specializationManager, superFunc, ...)
-- --     print("Main RealBees postInitSpecializations " .. self.typeName)
-- --     self.specializations["beehive"] = nil;
-- --     specializationManager:addSpecialization("beehive", "PlaceableRealBees", modDirectory .. "NotPlaceableRealBees.lua");
-- --     superFunc(specializationManager, ...)
-- -- end

-- init()
