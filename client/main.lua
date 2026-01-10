--[[
    Plenix FiveM Fireworks - Client Main
    Core client-side functionality
]]

local hasActiveFirework = nil

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
local function RequestParticleAsset(dict)
    if HasNamedPtfxAssetLoaded(dict) then return end
    
    RequestNamedPtfxAsset(dict)
    local timeout = 0
    while not HasNamedPtfxAssetLoaded(dict) and timeout < 1000 do
        timeout = timeout + 1
        Wait(10)
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
-- COMMAND REGISTRATION
-----------------------------------------------------------
Citizen.CreateThread(function()
    for key, firework in pairs(Config.Fireworks) do
        if firework.command then
            RegisterCommand(firework.command, function()
                TriggerServerEvent('plenix-fireworks:requestCommand', key)
            end, false)
            Fireworks.Debug('Registered command:', firework.command)
        end
    end
end)

-----------------------------------------------------------
-- START FIREWORK EVENT
-----------------------------------------------------------
RegisterNetEvent('plenix-fireworks:startFirework', function(fireworkType)
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

    Fireworks.Debug('Starting firework:', fireworkType)

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

    -- Create firework box prop
    hasActiveFirework = CreateObject(propHash, playerOffset.x, playerOffset.y, playerOffset.z, true, false, false)
    
    if not hasActiveFirework or hasActiveFirework == 0 then
        Fireworks.Debug('Failed to create firework prop')
        ClearPedTasks(playerPed)
        return
    end

    PlaceObjectOnGroundProperly(hasActiveFirework)
    FreezeEntityPosition(hasActiveFirework, true)

    -- Clear animation
    ClearPedTasks(playerPed)

    -- Show notification
    Config.Notification(Config.Translate['YOU_PLACE_FIREWORK'], 4500, 'success')

    local boxCoords = GetEntityCoords(hasActiveFirework)

    -- Countdown display
    while countdown > 0 do
        countdown = countdown - 50
        if Config.General.Enable3DText then
            DrawText3D(boxCoords, tostring(math.ceil(countdown / 1000)))
        end
        Wait(50)
    end

    -- Load all particle effects
    for _, particle in pairs(fireworkData.particles) do
        RequestParticleAsset(particle.name)
    end

    Fireworks.Debug('Starting firework shots, total:', remainingShoots)

    -- Fire the firework
    while remainingShoots > 0 do
        remainingShoots = remainingShoots - 1
        
        for _, particle in pairs(fireworkData.particles) do
            UseParticleFxAsset(particle.name)
            
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
            
            Wait(particle.timeToNextShoot)
        end
        
        Wait(fireworkData.timeBetweenShoots or 300)
    end

    Fireworks.Debug('Firework finished, cleaning up')

    -- Cleanup
    NetworkFadeOutEntity(hasActiveFirework, true, false)
    Wait(2000)
    
    if DoesEntityExist(hasActiveFirework) then
        DeleteEntity(hasActiveFirework)
    end
    
    hasActiveFirework = nil
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
