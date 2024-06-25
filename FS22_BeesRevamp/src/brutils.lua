--
-- BrUtils
--
-- BeesRevamp utils table. Just some helper functions.
--
-- Copyright (c) Peppie84, 2023
-- https://github.com/Peppie84/FS22_BeesRevamp
--
BrUtils = {
    DEBUG_MODE = false,
    MOD_NAME = g_currentModName or "unknown",
    SERVERITY = {
        INFO = 1,
        ERROR = 2,
        WARNING = 3,
        DEBUG = 4
    }
}

---Log a message. It will consider the debug flag for debug messages
---@param severity number
---@param messageFormat string
---@param ... any
function BrUtils:log(severity, messageFormat, ...)
    if not self.DEBUG_MODE and severity == self.SERVERITY.DEBUG then
        return
    end

    local severityName = self:getSeverityString(severity)

    log(string.format('BeesRevamp %s: ' .. messageFormat, severityName, ...))
end

---Translates the serverity value (number) into a readable value.
---@param serverity number
---@return string
function BrUtils:getSeverityString(serverity)
    for serverityIndex, serverityValue in pairs(self.SERVERITY) do
        if serverity == serverityValue then
            return tostring(serverityIndex)
        end
    end

    return "{Severity not found}"
end

---Log a debug message
---@param messageFormat string
---@param ... any
function BrUtils:logDebug(messageFormat, ...)
    self:log(BrUtils.SERVERITY.DEBUG, messageFormat, ...)
end

---Log a info message
---@param messageFormat string
---@param ... any
function BrUtils:logInfo(messageFormat, ...)
    self:log(BrUtils.SERVERITY.INFO, messageFormat, ...)
end

---Log a error message
---@param messageFormat string
---@param ... any
function BrUtils:logError(messageFormat, ...)
    self:log(BrUtils.SERVERITY.ERROR, messageFormat, ...)
end

---Log a warning message
---@param messageFormat string
---@param ... any
function BrUtils:logWarning(messageFormat, ...)
    self:log(BrUtils.SERVERITY.WARNING, messageFormat, ...)
end

---TODO
---@return string
function BrUtils:getCurrentDayYearString()
    return 'Y' .. g_currentMission.environment.currentYear .. 'M' .. g_currentMission.environment.currentPeriod .. 'D0'
end

---TODO
---@param text string
---@return string
function BrUtils:getModText(text)
    return g_i18n:getText(text, self.MOD_NAME)
end

g_brUtils = BrUtils;
