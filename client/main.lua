--[[
    Plenix FiveM Fireworks - Client Main
    Core client-side functionality
]]

local hasActiveFirework = nil
local activeFireworks = {}           -- Track all active fireworks { [id] = { prop = entity, cancelled = false } }
local fireworkIdCounter = 0          -- Counter for unique firework IDs
local lastMenuFireworkId = nil       -- Last firework placed from the menu

-----------------------------------------------------------
-- MENU FIREWORK COUNT
-----------------------------------------------------------
function Fireworks.CountMenuFireworks()
    local count = 0
    for _, firework in pairs(activeFireworks) do
        if firework.fromMenu and not firework.cancelled then
            count = count + 1
        end
    end
    return count
end

-- Keeps the menu's "Active fireworks" line current (ignored while the menu is closed)
local function RefreshMenuActive()
    SendNUIMessage({ action = 'updateActive', count = Fireworks.CountMenuFireworks() })
end

-----------------------------------------------------------
-- 3D TEXT DRAWING
-----------------------------------------------------------
local function DrawText3D(coords, text)
    local camCoords = GetFinalRenderedCamCoord()
    local distance = #(coords - camCoords)
    local scale = (0.8 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    
    SetTextScale(0.0 * scale, 0.55 * scale)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextDropShadow()
    SetTextColour(240, 240, 240, 185)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

-----------------------------------------------------------
-- ANIMATION LOADING
-----------------------------------------------------------
local function RequestAnimationDictionary(dict)
    if HasAnimDictLoaded(dict) then return end
    
    RequestAnimDict(dict)
    local timeout = 0
    while not HasAnimDictLoaded(dict) and timeout < 1000 do
        timeout = timeout + 1
        Wait(10)
    end
end

-----------------------------------------------------------
-- PARTICLE LOADING
-----------------------------------------------------------
local function RequestParticleAssets(particles)
    for _, particle in ipairs(particles) do
        RequestNamedPtfxAsset(particle.name)
    end
end

-- Waits until every asset has loaded or Fireworks.ParticleLoadTimeout has passed since they were
-- requested; the shot loop skips the effects of an asset that isn't loaded (yet), so a DLC
-- dictionary missing from the game build can't stall the show
local function WaitForParticleAssets(particles, requestedAt)
    local deadline = requestedAt + Fireworks.ParticleLoadTimeout
    local checked = {}

    for _, particle in ipairs(particles) do
        local dict = particle.name
        if not checked[dict] then
            checked[dict] = true
            while not HasNamedPtfxAssetLoaded(dict) and GetGameTimer() < deadline do
                Wait(10)
            end
            if not HasNamedPtfxAssetLoaded(dict) then
                Fireworks.Debug('Particle asset not loaded, its effects are skipped until it is:', dict)
            end
        end
    end
end

-----------------------------------------------------------
-- PROP MODEL LOADING
-----------------------------------------------------------
local function RequestPropModel(model)
    local hash = type(model) == 'string' and GetHashKey(model) or model
    
    if HasModelLoaded(hash) then return hash end
    
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 1000 do
        timeout = timeout + 1
        Wait(10)
    end
    
    return hash
end

-----------------------------------------------------------
-- MENU COMMAND & KEYBIND
-- The server checks the permission before the menu opens
-----------------------------------------------------------
if Config.Menu.Command and Config.Menu.Command ~= '' then
    RegisterCommand(Config.Menu.Command, function()
        TriggerServerEvent('plenix-fireworks:requestMenu')
    end, false)
    Fireworks.Debug('Registered command:', Config.Menu.Command)

    -- Listed in Settings > Key Bindings > FiveM, unbound unless Config.Menu.Keybind sets a default
    RegisterKeyMapping(Config.Menu.Command, Config.Translate['MENU_KEYBIND'], 'keyboard', Config.Menu.Keybind or '')
end

-----------------------------------------------------------
-- START FIREWORK EVENT
-----------------------------------------------------------
RegisterNetEvent('plenix-fireworks:startFirework', function(fireworkType, fromMenu)
    -- Check if player already has an active firework
    if Config.General.DisableMultipleFireworks and hasActiveFirework then
        Config.Notification(Config.Translate['CANNOT_START'], 4500, 'error')
        return
    end

    -- Validate firework type
    local fireworkData = Fireworks.GetFireworkType(fireworkType)
    if not fireworkData then
        Fireworks.Debug('Invalid firework type:', fireworkType)
        return
    end

    -- Generate unique ID for this firework
    fireworkIdCounter = fireworkIdCounter + 1
    local fireworkId = fireworkIdCounter
    
    Fireworks.Debug('Starting firework:', fireworkType, '(ID:', fireworkId, ')')

    -- Stream the particle assets in while the box is placed and the countdown runs
    local assetsRequestedAt = GetGameTimer()
    RequestParticleAssets(fireworkData.particles)

    local playerPed = PlayerPedId()
    local playerOffset = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.6, 0.0)
    local remainingShoots = fireworkData.shoots
    local countdown = fireworkData.timeToStart

    -- Load and play placing animation
    RequestAnimationDictionary(Config.Animation.Dictionary)
    TaskPlayAnim(
        playerPed, 
        Config.Animation.Dictionary, 
        Config.Animation.Name, 
        8.0, -8.0, -1, 0, 0, false, false, false
    )
    
    Wait(1500)

    -- Load prop model
    local propHash = RequestPropModel(fireworkData.prop)

    -- Create firework box prop (networked so others see it; falls back to a local prop
    -- on servers with entity lockdown, where client-created networked entities are blocked)
    hasActiveFirework = CreateObject(propHash, playerOffset.x, playerOffset.y, playerOffset.z, true, false, false)
    if not hasActiveFirework or hasActiveFirework == 0 or not DoesEntityExist(hasActiveFirework) then
        Fireworks.Debug('Networked prop blocked, using local prop')
        hasActiveFirework = CreateObject(propHash, playerOffset.x, playerOffset.y, playerOffset.z, false, false, false)
    end
    SetModelAsNoLongerNeeded(propHash)
    
    if not hasActiveFirework or hasActiveFirework == 0 then
        Fireworks.Debug('Failed to create firework prop')
        ClearPedTasks(playerPed)
        TriggerServerEvent('plenix-fireworks:finished')
        return
    end

    PlaceObjectOnGroundProperly(hasActiveFirework)
    FreezeEntityPosition(hasActiveFirework, true)
    
    -- Track this firework
    activeFireworks[fireworkId] = {
        prop = hasActiveFirework,
        cancelled = false,
        fromMenu = fromMenu or false
    }
    
    -- If from the menu, track as last menu firework
    if fromMenu then
        lastMenuFireworkId = fireworkId
        RefreshMenuActive()
    end

    -- Clear animation
    ClearPedTasks(playerPed)

    -- Show notification
    Config.Notification(Config.Translate['YOU_PLACE_FIREWORK'], 4500, 'success')

    local boxCoords = GetEntityCoords(hasActiveFirework)
    local currentFirework = activeFireworks[fireworkId]

    -- Countdown display
    while countdown > 0 do
        -- Check if cancelled
        if currentFirework.cancelled then
            Fireworks.Debug('Firework cancelled during countdown (ID:', fireworkId, ')')
            goto cleanup
        end
        
        -- Draw every frame, otherwise the 3D text flickers
        if Config.General.Enable3DText then
            DrawText3D(boxCoords, tostring(math.ceil(countdown / 1000)))
        end
        Wait(0)
        countdown = countdown - GetFrameTime() * 1000
    end

    -- Wait for any particle asset still loading (usually all done during the countdown)
    WaitForParticleAssets(fireworkData.particles, assetsRequestedAt)

    Fireworks.Debug('Starting firework shots, total:', remainingShoots)

    -- Fire the firework
    while remainingShoots > 0 do
        -- Check if cancelled
        if currentFirework.cancelled then
            Fireworks.Debug('Firework cancelled during firing (ID:', fireworkId, ')')
            goto cleanup
        end
        
        remainingShoots = remainingShoots - 1
        
        for _, particle in ipairs(fireworkData.particles) do
            if HasNamedPtfxAssetLoaded(particle.name) and (not particle.chance or math.random() < particle.chance) then
                UseParticleFxAssetNextCall(particle.name)

                -- Tint only when configured, so effects with built-in colors keep them
                if particle.colors then
                    local color = particle.colors[math.random(#particle.colors)]
                    SetParticleFxNonLoopedColour(color[1] + 0.0, color[2] + 0.0, color[3] + 0.0)
                end

                local offsetX = particle.randomizeXY and math.random(-10, 10) or 0.0
                local offsetY = particle.randomizeXY and math.random(-10, 10) or 0.0

                StartNetworkedParticleFxNonLoopedAtCoord(
                    particle.effect,
                    boxCoords.x + offsetX,
                    boxCoords.y + offsetY,
                    boxCoords.z + particle.plusHeight,
                    0.0, 0.0, 0.0,
                    particle.scale,
                    false, false, false
                )
            end

            Wait(particle.timeToNextShoot)
            
            -- Check if cancelled during particle loop
            if currentFirework.cancelled then
                Fireworks.Debug('Firework cancelled during particles (ID:', fireworkId, ')')
                goto cleanup
            end
        end
        
        Wait(fireworkData.timeBetweenShoots or 300)
    end

    Fireworks.Debug('Firework finished, cleaning up')

    -- Cleanup label
    ::cleanup::
    
    -- Cleanup
    local propEntity = activeFireworks[fireworkId] and activeFireworks[fireworkId].prop
    if propEntity and DoesEntityExist(propEntity) then
        NetworkFadeOutEntity(propEntity, true, false)
        Wait(500)
        if DoesEntityExist(propEntity) then
            DeleteEntity(propEntity)
        end
    end
    
    -- Remove from tracking
    activeFireworks[fireworkId] = nil
    RefreshMenuActive()
    
    -- Clear last menu firework if this was it
    if lastMenuFireworkId == fireworkId then
        lastMenuFireworkId = nil
    end
    
    hasActiveFirework = nil
    TriggerServerEvent('plenix-fireworks:finished')
end)

-----------------------------------------------------------
-- NOTIFICATION EVENT
-----------------------------------------------------------
RegisterNetEvent('plenix-fireworks:notification', function(messageKey, time, notifType)
    local message = Config.Translate[messageKey]
    if message then
        Config.Notification(message, time, notifType)
    else
        Fireworks.Debug('Missing translation key:', messageKey)
    end
end)

-----------------------------------------------------------
-- STOP FIREWORK EVENTS
-----------------------------------------------------------
RegisterNetEvent('plenix-fireworks:stopLast', function()
    if lastMenuFireworkId and activeFireworks[lastMenuFireworkId] and not activeFireworks[lastMenuFireworkId].cancelled then
        Fireworks.Debug('Stopping last menu firework (ID:', lastMenuFireworkId, ')')
        activeFireworks[lastMenuFireworkId].cancelled = true
        RefreshMenuActive()
        Config.Notification(Config.Translate['FIREWORK_STOPPED'] or 'Firework stopped', 3000, 'info')
    else
        Config.Notification(Config.Translate['NO_FIREWORK_TO_STOP'] or 'No active firework to stop', 3000, 'error')
    end
end)

RegisterNetEvent('plenix-fireworks:stopAll', function()
    local count = 0
    for id, firework in pairs(activeFireworks) do
        if firework.fromMenu and not firework.cancelled then
            firework.cancelled = true
            count = count + 1
        end
    end
    
    if count > 0 then
        RefreshMenuActive()
        Fireworks.Debug('Stopping all menu fireworks, count:', count)
        Config.Notification(string.format(Config.Translate['FIREWORKS_STOPPED'] or '%d firework(s) stopped', count), 3000, 'info')
    else
        Config.Notification(Config.Translate['NO_FIREWORK_TO_STOP'] or 'No active fireworks to stop', 3000, 'error')
    end
end)
