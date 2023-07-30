--
-- SwarmControlActivatable
--
-- Todo: add description
--
-- Copyright (c) Peppie84, 2023
--

SwarmControlActivatable = {}
local SwarmControlActivatable_mt = Class(SwarmControlActivatable)

---TODO
function SwarmControlActivatable.new(beecare)
    local self = {}

    setmetatable(self, SwarmControlActivatable_mt)

    self.beecare = beecare
    self.activateText = g_i18n:getText("realbees_beecare_do_schwarm_control")

    return self
end

---TODO
function SwarmControlActivatable:getIsActivatable()
    if self.beecare:getCanInteract() and self.beecare:getSwarmControleNeeded() then
        return true
    end

    return false
end

---TODO
function SwarmControlActivatable:run()
    if g_server ~= nil then
        self.beecare:doSwarmControl()
    else
        ---TODO for Multiplayer!
        ---g_client:getServerConnection():sendEvent(CUSTOM_EVENT.new(self.bale))
    end
end
