--[[
    Plenix FiveM Fireworks - Server Main
    Core server-side functionality
]]

-- Server-side framework objects
local ESX = nil
local QBCore = nil

-----------------------------------------------------------
-- DEBUG HELPER
-----------------------------------------------------------
local function DebugPrint(message, color)
    if Config.General.Debug then
        color = color or '^3'
        print(color .. '[Fireworks] ' .. message .. '^0')
    end
end

-----------------------------------------------------------
-- FRAMEWORK INITIALIZATION (Server-side)
-----------------------------------------------------------
Citizen.CreateThread(function()
    if Config.General.Framework == 'esx' then
        if GetResourceState('es_extended') == 'started' then
            ESX = exports['es_extended']:getSharedObject()
            DebugPrint('ESX Framework loaded', '^2')
        else
            print('^1[Fireworks] WARNING: es_extended not found^0')
        end
    elseif Config.General.Framework == 'qb' then
        if GetResourceState('qb-core') == 'started' then
            QBCore = exports['qb-core']:GetCoreObject()
            DebugPrint('QBCore Framework loaded', '^2')
        else
            print('^1[Fireworks] WARNING: qb-core not found^0')
        end
    end
end)

-----------------------------------------------------------
-- HELPER FUNCTIONS
-----------------------------------------------------------
local function HasItem(source, itemName)
    DebugPrint('Checking if player ' .. source .. ' has item: ' .. itemName)
    
    if Config.General.Inventory == 'ox' then
        local success, result = pcall(function()
            return exports.ox_inventory:Search(source, 'count', itemName)
        end)
        if success then
            DebugPrint('ox_inventory Search result: ' .. tostring(result))
            return result and result > 0
        else
            DebugPrint('ox_inventory Search error: ' .. tostring(result), '^1')
            return false
        end
    elseif Config.General.Inventory == 'qb' then
        if not QBCore then return false end
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        local item = Player.Functions.GetItemByName(itemName)
        return item ~= nil and item.amount > 0
    elseif Config.General.Inventory == 'esx' then
        if not ESX then return false end
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end
        local item = xPlayer.getInventoryItem(itemName)
        return item and item.count > 0
    end
    return false
end

local function RemoveItem(source, itemName, amount)
    DebugPrint('Removing ' .. amount .. 'x ' .. itemName .. ' from player ' .. source)
    
    if Config.General.Inventory == 'ox' then
        local success, err = pcall(function()
            exports.ox_inventory:RemoveItem(source, itemName, amount)
        end)
        if not success then
            DebugPrint('RemoveItem error: ' .. tostring(err), '^1')
        end
    elseif Config.General.Inventory == 'qb' then
        if not QBCore then return end
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            Player.Functions.RemoveItem(itemName, amount)
        end
    elseif Config.General.Inventory == 'esx' then
        if not ESX then return end
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.removeInventoryItem(itemName, amount)
        end
    end
end

local function UseFirework(source, fireworkKey)
    DebugPrint('UseFirework called - Player: ' .. source .. ', Key: ' .. tostring(fireworkKey), '^2')
    
    local firework = Config.Fireworks[fireworkKey]
    if not firework then 
        DebugPrint('Invalid firework key: ' .. tostring(fireworkKey), '^1')
        return 
    end
    
    -- Check for lighter requirement
    if Config.Items.RequireLighter then
        DebugPrint('Checking lighter requirement...')
        if not HasItem(source, Config.Items.LighterItem) then
            DebugPrint('Player missing lighter', '^1')
            TriggerClientEvent('plenix-fireworks:notification', source, 'NEED_LIGHTER', 5000, 'error')
            return
        end
        DebugPrint('Player has lighter', '^2')
    end
    
    -- Remove item if configured
    if firework.itemRemovable and firework.item then
        RemoveItem(source, firework.item, 1)
    end
    
    -- Trigger firework on client
    DebugPrint('Triggering client firework event', '^2')
    TriggerClientEvent('plenix-fireworks:startFirework', source, fireworkKey)
end

-----------------------------------------------------------
-- PERMISSION CHECKING
-----------------------------------------------------------
local function HasCommandPermission(source)
    -- Check admin bypass first
    if Config.Permissions.AdminBypass then
        if IsPlayerAceAllowed(source, Config.Permissions.AdminPermission) then
            DebugPrint('Admin bypass granted for player ' .. source, '^2')
            return true
        end
    end
    
    local mode = Config.Permissions.Mode
    
    if mode == 'none' then
        return false
    end
    
    if mode == 'ace' then
        return IsPlayerAceAllowed(source, Config.Permissions.AcePermission)
    end
    
    if mode == 'job' then
        local jobName = nil
        local jobGrade = 0
        
        if Config.General.Framework == 'esx' and ESX then
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer then
                jobName = xPlayer.job.name
                jobGrade = xPlayer.job.grade
            end
        elseif Config.General.Framework == 'qb' and QBCore then
            local Player = QBCore.Functions.GetPlayer(source)
            if Player then
                jobName = Player.PlayerData.job.name
                jobGrade = Player.PlayerData.job.grade.level
            end
        end
        
        if not jobName then
            return false
        end
        
        local requiredGrade = Config.Permissions.AllowedJobs[jobName]
        if requiredGrade ~= nil and jobGrade >= requiredGrade then
            return true
        end
        
        return false
    end
    
    return false
end

-----------------------------------------------------------
-- COMMAND PERMISSION REQUEST
-----------------------------------------------------------
RegisterNetEvent('plenix-fireworks:requestCommand', function(fireworkKey)
    local source = source
    
    if not HasCommandPermission(source) then
        return TriggerClientEvent('plenix-fireworks:notification', source, 'NO_PERMISSION', 5000, 'error')
    end
    
    local firework = Config.Fireworks[fireworkKey]
    if not firework then
        return
    end
    
    if Config.Items.RequireLighter then
        if not HasItem(source, Config.Items.LighterItem) then
            return TriggerClientEvent('plenix-fireworks:notification', source, 'NEED_LIGHTER', 5000, 'error')
        end
    end
    
    -- Pass true to indicate this is from a command
    TriggerClientEvent('plenix-fireworks:startFirework', source, fireworkKey, true)
end)

-----------------------------------------------------------
-- STOP FIREWORK COMMANDS
-----------------------------------------------------------
RegisterNetEvent('plenix-fireworks:requestStopLast', function()
    local source = source
    
    if not HasCommandPermission(source) then
        return TriggerClientEvent('plenix-fireworks:notification', source, 'NO_PERMISSION', 5000, 'error')
    end
    
    TriggerClientEvent('plenix-fireworks:stopLast', source)
end)

RegisterNetEvent('plenix-fireworks:requestStopAll', function()
    local source = source
    
    if not HasCommandPermission(source) then
        return TriggerClientEvent('plenix-fireworks:notification', source, 'NO_PERMISSION', 5000, 'error')
    end
    
    TriggerClientEvent('plenix-fireworks:stopAll', source)
end)

-----------------------------------------------------------
-- USABLE ITEM REGISTRATION
-----------------------------------------------------------
Citizen.CreateThread(function()
    -- Wait for resources to fully load
    Wait(3000)
    
    DebugPrint('Registering usable items...')
    DebugPrint('Inventory system: ' .. Config.General.Inventory)
    
    if Config.General.Inventory == 'ox' then
        -- Check if ox_inventory is available
        local oxState = GetResourceState('ox_inventory')
        DebugPrint('ox_inventory state: ' .. oxState)
        
        if oxState ~= 'started' then
            print('^1[Fireworks] ERROR: ox_inventory is not started!^0')
            return
        end
        
        -- Build list of firework items for quick lookup
        local fireworkItems = {}
        for key, firework in pairs(Config.Fireworks) do
            if firework.item then
                fireworkItems[firework.item] = key
                DebugPrint('Tracking ox_inventory item: ' .. firework.item .. ' (key: ' .. key .. ')', '^2')
            end
        end
        
        -- Listen for ox_inventory item usage event
        AddEventHandler('ox_inventory:usedItem', function(playerId, itemName, slotId, metadata)
            local fireworkKey = fireworkItems[itemName]
            if fireworkKey then
                DebugPrint('ox_inventory item used! Player: ' .. playerId .. ', Item: ' .. itemName, '^2')
                UseFirework(playerId, fireworkKey)
            end
        end)
        
        DebugPrint('ox_inventory integration complete (using usedItem event)', '^2')
        
    elseif Config.General.Inventory == 'qb' then
        if GetResourceState('qb-core') ~= 'started' then
            print('^1[Fireworks] ERROR: qb-core is not started!^0')
            return
        end
        
        if not QBCore then
            Wait(1000)
            QBCore = exports['qb-core']:GetCoreObject()
        end
        
        for key, firework in pairs(Config.Fireworks) do
            if firework.item then
                QBCore.Functions.CreateUseableItem(firework.item, function(source)
                    UseFirework(source, key)
                end)
                DebugPrint('Registered QBCore item: ' .. firework.item, '^2')
            end
        end
        
        DebugPrint('QBCore integration complete', '^2')
        
    elseif Config.General.Inventory == 'esx' then
        if GetResourceState('es_extended') ~= 'started' then
            print('^1[Fireworks] ERROR: es_extended is not started!^0')
            return
        end
        
        if not ESX then
            Wait(1000)
            ESX = exports['es_extended']:getSharedObject()
        end
        
        for key, firework in pairs(Config.Fireworks) do
            if firework.item then
                ESX.RegisterUsableItem(firework.item, function(source)
                    UseFirework(source, key)
                end)
                DebugPrint('Registered ESX item: ' .. firework.item, '^2')
            end
        end
        
        DebugPrint('ESX integration complete', '^2')
    else
        print('^1[Fireworks] ERROR: Unknown inventory: ' .. tostring(Config.General.Inventory) .. '^0')
    end
end)

-----------------------------------------------------------
-- DEBUG COMMAND
-----------------------------------------------------------
RegisterCommand('fireworks_debug', function(source)
    print('=== FIREWORKS DEBUG ===')
    print('Framework:', Config.General.Framework)
    print('Inventory:', Config.General.Inventory)
    print('RequireLighter:', Config.Items.RequireLighter)
    print('LighterItem:', Config.Items.LighterItem)
    print('ox_inventory state:', GetResourceState('ox_inventory'))
    print('Fireworks configured:')
    for key, fw in pairs(Config.Fireworks) do
        print('  [' .. key .. '] item=' .. tostring(fw.item))
    end
    print('=======================')
end, true)
