--[[
    Plenix FiveM Fireworks - Configuration File
    Configure all aspects of the Fireworks System
]]

Config = {}

-----------------------------------------------------------
-- GENERAL SETTINGS
-----------------------------------------------------------
Config.General = {
    Debug = false,                          -- Enable debug mode for console logs
    Framework = 'esx',                      -- Framework: 'esx', 'qb', 'standalone'
    Inventory = 'ox',                       -- Inventory: 'ox', 'qb', 'esx' (ox_inventory recommended)
    Enable3DText = true,                    -- Show 3D countdown text on firework box
    DisableMultipleFireworks = false,       -- If true, player can only have one active firework at a time
}

-----------------------------------------------------------
-- FRAMEWORK INITIALIZATION
-----------------------------------------------------------
if Config.General.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.General.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
end

-----------------------------------------------------------
-- ITEM REQUIREMENTS
-----------------------------------------------------------
Config.Items = {
    RequireLighter = true,                  -- Require lighter item to use fireworks
    LighterItem = 'lighter',                -- Item name for lighter
}

-----------------------------------------------------------
-- COMMAND PERMISSIONS
-- Configure who can use firework commands
-----------------------------------------------------------
Config.Permissions = {
    -- Permission mode: 'ace', 'job', 'none'
    -- 'ace'  = Use ACE permissions (add to server.cfg)
    -- 'job'  = Use job-based permissions (ESX/QBCore)
    -- 'none' = Commands disabled, only items work
    Mode = 'ace',
    
    -- Admin Bypass (always allow admins to use commands)
    AdminBypass = true,                     -- If true, admins can always use commands
    AdminPermission = 'command',            -- ACE permission that admins have (default: 'command')
    
    -- ACE Permission Settings (when Mode = 'ace')
    AcePermission = 'fireworks.use',        -- Permission required to use commands
    
    -- Job-based Settings (when Mode = 'job')
    -- Format: ['job_name'] = minimum_grade
    -- Use 0 for any grade
    AllowedJobs = {
        ['police'] = 0,                     -- Any police grade
        ['ambulance'] = 2,                  -- Ambulance grade 2+
    },
}

-----------------------------------------------------------
-- ANIMATION SETTINGS
-----------------------------------------------------------
Config.Animation = {
    Dictionary = 'anim@mp_fireworks',       -- Animation dictionary
    Name = 'place_firework_3_box',          -- Animation name
}

-----------------------------------------------------------
-- NOTIFICATIONS
-- Customize notification system based on your framework
-----------------------------------------------------------
Config.Notification = function(message, time, type)
    if Config.General.Framework == 'esx' then
        -- ESX Notification
        TriggerEvent('esx:showNotification', message)
    elseif Config.General.Framework == 'qb' then
        -- QBCore Notification
        TriggerEvent('QBCore:Notify', message, type, time)
    else
        -- Standalone / Default
        SetNotificationTextEntry('STRING')
        AddTextComponentString(message)
        DrawNotification(false, true)
    end
end

-----------------------------------------------------------
-- TRANSLATIONS
-----------------------------------------------------------
Config.Translate = {
    ['CANNOT_START'] = "You can't set off several fireworks at once, wait until the current one goes off",
    ['NEED_LIGHTER'] = "You need to have a lighter!",
    ['YOU_PLACE_FIREWORK'] = "You placed the firework!",
    ['NO_PERMISSION'] = "You don't have permission to use this command!",
    ['FIREWORK_STOPPED'] = "Firework stopped!",
    ['FIREWORKS_STOPPED'] = "All fireworks stopped!",
    ['NO_FIREWORK_TO_STOP'] = "No active firework to stop!",
}

-----------------------------------------------------------
-- FIREWORK TYPES
-- Define different types of fireworks with their effects
-----------------------------------------------------------
Config.Fireworks = {
    [1] = {
        name = 'Starburst Display',
        item = 'firework_1',                -- Item name or nil
        itemRemovable = true,               -- Remove item after use
        command = 'firework_1',             -- Command name or nil
        shoots = 50,                        -- Number of shots
        prop = 'ind_prop_firework_03',      -- Prop model
        timeToStart = 3000,                 -- Time before first shot (ms)
        timeBetweenShoots = 1250,           -- Time between shots (ms)
        particles = {
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_starburst', scale = 2.0, plusHeight = 50.0, randomizeXY = true, timeToNextShoot = 120 },
            { name = 'proj_indep_firework', effect = 'scr_indep_firework_grd_burst', scale = 2.0, plusHeight = 50.0, randomizeXY = true, timeToNextShoot = 300 },
            { name = 'proj_indep_firework', effect = 'scr_indep_firework_air_burst', scale = 2.0, plusHeight = 50.0, randomizeXY = true, timeToNextShoot = 600 },
        },
    },

    [2] = {
        name = 'Christmas Special',
        item = 'firework_2',
        itemRemovable = true,
        command = 'firework_2',
        shoots = 80,
        prop = 'ind_prop_firework_03',
        timeToStart = 3000,
        timeBetweenShoots = 250,
        particles = {
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_trailburst', scale = 2.0, plusHeight = 10.0, randomizeXY = true, timeToNextShoot = 125 },
            { name = 'proj_indep_firework_v2', effect = 'scr_firework_indep_burst_rwb', scale = 1.0, plusHeight = 50.0, randomizeXY = true, timeToNextShoot = 125 },
            { name = 'proj_xmas_firework', effect = 'scr_firework_xmas_ring_burst_rgw', scale = 1.0, plusHeight = 50.0, randomizeXY = true, timeToNextShoot = 125 },
        },
    },

    [3] = {
        name = 'Spiral Burst',
        item = 'firework_3',
        itemRemovable = true,
        command = 'firework_3',
        shoots = 80,
        prop = 'ind_prop_firework_03',
        timeToStart = 3000,
        timeBetweenShoots = 250,
        particles = {
            { name = 'proj_indep_firework', effect = 'scr_indep_firework_air_burst', scale = 1.0, plusHeight = 50.0, randomizeXY = true, timeToNextShoot = 125 },
            { name = 'proj_indep_firework_v2', effect = 'scr_firework_indep_spiral_burst_rwb', scale = 1.0, plusHeight = 50.0, randomizeXY = true, timeToNextShoot = 125 },
            { name = 'proj_indep_firework_v2', effect = 'scr_firework_indep_repeat_burst_rwb', scale = 1.0, plusHeight = 50.0, randomizeXY = true, timeToNextShoot = 125 },
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_starburst', scale = 1.0, plusHeight = 50.0, randomizeXY = true, timeToNextShoot = 125 },
        },
    },

    [4] = {
        name = 'Trail Burst',
        item = 'firework_4',
        itemRemovable = true,
        command = 'firework_4',
        shoots = 50,
        prop = 'ind_prop_firework_03',
        timeToStart = 3000,
        timeBetweenShoots = 550,
        particles = {
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_trailburst', scale = 4.0, plusHeight = 50.0, randomizeXY = true, timeToNextShoot = 10 },
        },
    },

    [5] = {
        name = 'Fountain',
        item = 'fountain_1',
        itemRemovable = true,
        command = 'fountain_1',
        shoots = 100,
        prop = 'ind_prop_firework_04',
        timeToStart = 3000,
        timeBetweenShoots = 700,
        particles = {
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_fountain', scale = 2.0, plusHeight = 0.25, randomizeXY = false, timeToNextShoot = 500 },
        },
    },

    [6] = {
        name = 'Battery Colorful Burst',
        item = 'firework_battery',
        itemRemovable = true,
        command = 'firework_battery',
        shoots = 50,
        prop = 'ind_prop_firework_03',
        timeToStart = 3000,
        timeBetweenShoots = 400,
        particles = {
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_trailburst', scale = 3.0, plusHeight = 10.0, randomizeXY = true, timeToNextShoot = 100 },
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_starburst', scale = 3.0, plusHeight = 60.0, randomizeXY = true, timeToNextShoot = 50 },
            { name = 'proj_indep_firework', effect = 'scr_indep_firework_air_burst', scale = 3.0, plusHeight = 60.0, randomizeXY = true, timeToNextShoot = 50 },
            { name = 'proj_indep_firework_v2', effect = 'scr_firework_indep_burst_rwb', scale = 2.5, plusHeight = 60.0, randomizeXY = true, timeToNextShoot = 50 },
            { name = 'proj_indep_firework', effect = 'scr_indep_firework_grd_burst', scale = 2.0, plusHeight = 60.0, randomizeXY = true, timeToNextShoot = 10 },
        },
    },

    [7] = {
        name = 'Battery Fast Burst',
        item = 'firework_battery2',
        itemRemovable = true,
        command = 'firework_battery2',
        shoots = 80,
        prop = 'ind_prop_firework_03',
        timeToStart = 3000,
        timeBetweenShoots = 300,
        particles = {
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_trailburst', scale = 2.0, plusHeight = 1.0, randomizeXY = false, timeToNextShoot = 10 },
        },
    },

    [8] = {
        name = 'Start Rocket',
        item = 'firework_start',
        itemRemovable = true,
        command = 'firework_start',
        shoots = 1,
        prop = 'ind_prop_firework_03',
        timeToStart = 3000,
        timeBetweenShoots = 0,
        particles = {
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_trailburst', scale = 4.0, plusHeight = 50.0, randomizeXY = true, timeToNextShoot = 10 },
        },
    },

    [9] = {
        name = 'Finale Salute',
        item = 'firework_finale',
        itemRemovable = true,
        command = 'firework_finale',
        shoots = 3,
        prop = 'ind_prop_firework_03',
        timeToStart = 3000,
        timeBetweenShoots = 2500,
        particles = {
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_trailburst', scale = 4.0, plusHeight = 10.0, randomizeXY = false, timeToNextShoot = 100 },
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_starburst', scale = 4.0, plusHeight = 60.0, randomizeXY = false, timeToNextShoot = 50 },
            { name = 'proj_indep_firework', effect = 'scr_indep_firework_air_burst', scale = 4.0, plusHeight = 60.0, randomizeXY = false, timeToNextShoot = 50 },
            { name = 'proj_indep_firework_v2', effect = 'scr_firework_indep_burst_rwb', scale = 3.5, plusHeight = 60.0, randomizeXY = false, timeToNextShoot = 50 },
            { name = 'proj_indep_firework', effect = 'scr_indep_firework_grd_burst', scale = 3.0, plusHeight = 60.0, randomizeXY = false, timeToNextShoot = 10 },
        },
    },
}
