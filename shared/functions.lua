--[[
    Plenix FiveM Fireworks - Shared Functions
    Utility functions available on both client and server
]]

Fireworks = Fireworks or {}

-----------------------------------------------------------
-- DEBUG LOGGING
-----------------------------------------------------------
function Fireworks.Debug(...)
    if Config.General.Debug then
        local args = {...}
        local message = '[Fireworks Debug] '
        for i, v in ipairs(args) do
            message = message .. tostring(v) .. ' '
        end
        print(message)
    end
end

-----------------------------------------------------------
-- GET FIREWORK TYPE CONFIGURATION
-----------------------------------------------------------
function Fireworks.GetFireworkType(fireworkType)
    if Config.Fireworks[fireworkType] then
        return Config.Fireworks[fireworkType]
    end
    return nil
end

-----------------------------------------------------------
-- CHECK IF FIREWORK TYPE IS VALID
-----------------------------------------------------------
function Fireworks.IsValidFireworkType(fireworkType)
    return Config.Fireworks[fireworkType] ~= nil
end

-----------------------------------------------------------
-- GET ALL FIREWORK TYPES
-----------------------------------------------------------
function Fireworks.GetAllFireworkTypes()
    local types = {}
    for key, data in pairs(Config.Fireworks) do
        table.insert(types, {
            key = key,
            name = data.name or ('Firework ' .. key),
            item = data.item,
            command = data.command,
            shoots = data.shoots
        })
    end
    return types
end

-----------------------------------------------------------
-- GET FRAMEWORK OBJECT
-----------------------------------------------------------
function Fireworks.GetFramework()
    if Config.General.Framework == 'esx' then
        return ESX
    elseif Config.General.Framework == 'qb' then
        return QBCore
    end
    return nil
end
