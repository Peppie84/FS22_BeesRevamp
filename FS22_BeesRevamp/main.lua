---
-- Main
--
-- Main class for initialize the real bees mod.
--
-- Copyright (c) Peppie84, 2023
--

local modDirectory = g_currentModDirectory

source(modDirectory .. "beehivesystem.lua")

-- isActive
function isActive()
    return g_modIsLoaded["FS22_RealBees"]
end

-- init
function init()
    FSBaseMission.initTerrain = Utils.appendedFunction(FSBaseMission.initTerrain, initTerrain)

    -- change old beehive placeable system
    --g_placeableSpecializationManager.specializations["beehive"] = nil;
    --g_placeableSpecializationManager:addSpecialization("beehive", "PlaceableRealBees", modDirectory .. "PlaceableRealBees.lua");

    addConsoleCommand("mydebug1", "Debugme", "__debug1", BeehiveSystemMod)
    addConsoleCommand("mydebug2", "Debugme", "__debug2", BeehiveSystemMod)
end

-- initTerrain
function initTerrain(mission, terrainId, filename)
    print("Main RealBees initTerrain")
    if not isActive() then
        return
    end

    BeehiveSystem.updateState = Utils.overwrittenFunction(BeehiveSystem.updateState, BeehiveSystemMod.updateState)
end

init()
