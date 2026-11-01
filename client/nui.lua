--[[
    Plenix FiveM Fireworks - Client NUI
    Launch menu and its NUI callbacks
]]

local menuOpen = false

-----------------------------------------------------------
-- MENU DATA
-----------------------------------------------------------
-- Rough show length (ms) for the card, from the countdown and each shot's waits
local function EstimateDurationMs(firework)
    local perShot = firework.timeBetweenShoots or 300
    for _, particle in ipairs(firework.particles or {}) do
        perShot = perShot + (particle.timeToNextShoot or 0)
    end
    return (firework.timeToStart or 0) + (firework.shoots or 1) * perShot
end

local function BuildMenuFireworks()
    local list = {}
    for key, firework in pairs(Config.Fireworks) do
        table.insert(list, {
            key = key,
            name = firework.name or ('Firework ' .. key),
            category = firework.category,
            image = firework.item and ('../items/images/' .. firework.item .. '.png') or nil,
            shoots = firework.shoots,
            duration = EstimateDurationMs(firework),
        })
    end
    table.sort(list, function(a, b) return a.key < b.key end)
    return list
end

local function GetMenuLocale()
    local t = Config.Translate
    return {
        title = t['MENU_TITLE'],
        all = t['MENU_ALL'],
        select = t['MENU_SELECT'],
        shots = t['MENU_SHOTS'],
        active = t['MENU_ACTIVE'],
        launch = t['MENU_LAUNCH'],
        stopLast = t['MENU_STOP_LAST'],
        stopAll = t['MENU_STOP_ALL'],
    }
end

-----------------------------------------------------------
-- OPEN / CLOSE
-----------------------------------------------------------
RegisterNetEvent('plenix-fireworks:openMenu', function()
    if menuOpen then return end
    menuOpen = true

    SendNUIMessage({
        action = 'openMenu',
        fireworks = BuildMenuFireworks(),
        categories = Config.Menu.Categories,
        locale = GetMenuLocale(),
        active = Fireworks.CountMenuFireworks(),
        debug = Config.General.Debug,
    })
    SetNuiFocus(true, true)
end)

local function CloseMenu()
    menuOpen = false
    SetNuiFocus(false, false)
end

-----------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------
RegisterNUICallback('closeMenu', function(data, cb)
    CloseMenu()
    cb('ok')
end)

-- The menu closes on launch so the player can watch the box being placed
RegisterNUICallback('launch', function(data, cb)
    local key = tonumber(data.key)
    if not key or not Fireworks.IsValidFireworkType(key) then
        cb({ success = false })
        return
    end

    CloseMenu()
    TriggerServerEvent('plenix-fireworks:requestLaunch', key)
    cb({ success = true })
end)

RegisterNUICallback('stopLast', function(data, cb)
    TriggerServerEvent('plenix-fireworks:requestStopLast')
    cb('ok')
end)

RegisterNUICallback('stopAll', function(data, cb)
    TriggerServerEvent('plenix-fireworks:requestStopAll')
    cb('ok')
end)

-----------------------------------------------------------
-- CONTROLS WHILE THE MENU IS OPEN
-----------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        if menuOpen then
            DisableControlAction(0, 1, true)   -- Look Left/Right
            DisableControlAction(0, 2, true)   -- Look Up/Down
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(0, 18, true)  -- Enter
            DisableControlAction(0, 322, true) -- ESC
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
            Citizen.Wait(0)
        else
            Citizen.Wait(250)
        end
    end
end)

-- Release focus if the resource stops with the menu open
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() and menuOpen then
        SetNuiFocus(false, false)
    end
end)
