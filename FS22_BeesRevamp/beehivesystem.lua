---
-- Beehive system Mod
--
-- Main class to handle real bees simulation.
--
-- Copyright (c) Peppie84, 2023
--

BeehiveSystemMod = {
    MOD_NAME = g_currentModName or "FS22_RealBees",
    MOD_DIRECTORY = g_currentModDirectory,
    DEBUG_MODE = false
}

-- Honey Leistung:
--  0.75   1.25   1.5    2.0    1.5    1.25   0.75   0.5    -0.5   -0.5    -0.5    -0.5
-- Mär=1, Apr=2, Mai=3, Jun=4, Jul=5, Aug=6, Sep=7, Okt=8, Nov=9, Dez=10, Jan=11, Feb=12

-- function BeehiveSystemMod:__updateState()

--     print("__updateState")
--     g_currentMission.beehiveSystem.isFxActive = BeehiveSystemMod.DEBUG_MODE;

--     print(string.format("BeehiveSystemMod__updateState - %s", g_currentMission.beehiveSystem.isFxActive))
--     print(string.format("BeehiveSystemMod__updateState - %s", g_currentMission.beehiveSystem.isProductionActive))
-- end

function  BeehiveSystemMod:__debug1()
    for name, spec in pairs(g_placeableSpecializationManager:getSpecializations()) do
        print(string.format("Name: %s", name))
        print(string.format("spec: %s", spec))
    end
end

function  BeehiveSystemMod:__debug2()
end

function BeehiveSystemMod:updateState()
	local environment = g_currentMission.environment

    print("CurrentPeriod: " .. environment.currentPeriod);
end