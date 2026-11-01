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
    Inventory = 'ox',                       -- Inventory: 'ox', 'qb', 'esx', 'qs' (ox_inventory recommended)
    Enable3DText = true,                    -- Show 3D countdown text on firework box
    DisableMultipleFireworks = false,       -- If true, player can only have one active firework at a time
}

-----------------------------------------------------------
-- FRAMEWORK INITIALIZATION
-----------------------------------------------------------
-- pcall so a missing/not-yet-started framework doesn't abort loading the rest of this config
if Config.General.Framework == 'esx' and GetResourceState('es_extended') ~= 'missing' then
    local ok, obj = pcall(function() return exports['es_extended']:getSharedObject() end)
    if ok then ESX = obj end
elseif Config.General.Framework == 'qb' and GetResourceState('qb-core') ~= 'missing' then
    local ok, obj = pcall(function() return exports['qb-core']:GetCoreObject() end)
    if ok then QBCore = obj end
end

-----------------------------------------------------------
-- ITEM REQUIREMENTS
-----------------------------------------------------------
Config.Items = {
    RequireLighter = true,                  -- Require lighter item to use fireworks
    LighterItem = 'lighter',                -- Item name for lighter
}

-----------------------------------------------------------
-- LAUNCH MENU
-- One command opens the menu to launch any firework without its item
-----------------------------------------------------------
Config.Menu = {
    Command = 'fireworks',                  -- Chat command that opens the menu
    Keybind = '',                           -- Optional default key (e.g. 'F7'), players can rebind it in Settings > Key Bindings
    Categories = {                          -- Menu tabs, in this order; each firework's `category` picks one
        { key = 'classic', label = 'Classic', icon = 'fa-star' },
        { key = 'battery', label = 'Batteries', icon = 'fa-bolt' },
        { key = 'fountain', label = 'Fountains', icon = 'fa-fire' },
        { key = 'halloween', label = 'Halloween', icon = 'fa-ghost' },
        { key = 'christmas', label = 'Christmas', icon = 'fa-tree' },
    },
}

-----------------------------------------------------------
-- MENU PERMISSIONS
-- Configure who can open the launch menu (items can be used by anyone)
-----------------------------------------------------------
Config.Permissions = {
    -- Permission mode: 'ace', 'job', 'none'
    -- 'ace'  = Use ACE permissions (add to server.cfg)
    -- 'job'  = Use job-based permissions (ESX/QBCore)
    -- 'none' = Menu disabled, only items work
    Mode = 'ace',

    -- Admin Bypass (always allow admins to open the menu)
    AdminBypass = true,                     -- If true, admins can always open the menu
    AdminPermission = 'command',            -- ACE permission that admins have (default: 'command')

    -- ACE Permission Settings (when Mode = 'ace')
    AcePermission = 'fireworks.use',        -- Permission required to open the menu
    
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
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, true)
    end
end

-----------------------------------------------------------
-- TRANSLATIONS
-----------------------------------------------------------
Config.Translate = {
    ['CANNOT_START'] = "You can't set off several fireworks at once, wait until the current one goes off",
    ['NEED_LIGHTER'] = "You need to have a lighter!",
    ['YOU_PLACE_FIREWORK'] = "You placed the firework!",
    ['NO_PERMISSION'] = "You don't have permission to use the fireworks menu!",
    ['FIREWORK_STOPPED'] = "Firework stopped!",
    ['FIREWORKS_STOPPED'] = "%d firework(s) stopped!",
    ['NO_FIREWORK_TO_STOP'] = "No active firework to stop!",

    -- Launch menu
    ['MENU_TITLE'] = "Fireworks",
    ['MENU_ALL'] = "All",
    ['MENU_SELECT'] = "Select a firework",
    ['MENU_SHOTS'] = "shots",
    ['MENU_ACTIVE'] = "Active fireworks: %d",
    ['MENU_LAUNCH'] = "Launch",
    ['MENU_STOP_LAST'] = "Stop last",
    ['MENU_STOP_ALL'] = "Stop all",
    ['MENU_KEYBIND'] = "Open the fireworks menu",
}

-----------------------------------------------------------
-- COLOR PALETTES
-- Tints for a particle's `colors` list: RGB from 0.0 to 1.0 (not 0-255)
-- Tint the scr_indep_fireworks effects (starburst, trailburst, fountain, shotburst) and the
-- scr_hr_lny_races launch effects (game build 3407+); effects with their own colors
-- (*_rgw, *_rwb, proj_indep_firework bursts) mix with the tint unpredictably
-----------------------------------------------------------
Config.Palettes = {
    Halloween = {
        { 1.0, 0.4, 0.0 },                  -- Pumpkin orange
        { 0.55, 0.0, 1.0 },                 -- Witch purple
        { 0.35, 1.0, 0.0 },                 -- Toxic green
    },
    Christmas = {
        { 1.0, 0.0, 0.0 },                  -- Red
        { 0.0, 0.85, 0.15 },                -- Green
        { 1.0, 1.0, 1.0 },                  -- White
        { 1.0, 0.75, 0.15 },                -- Gold
    },
    Gold = {
        { 1.0, 0.75, 0.15 },
    },
}

-----------------------------------------------------------
-- FIREWORK TYPES
-- Define different types of fireworks with their effects
--
-- Particle options:
--   name / effect     Particle dictionary and effect (non-looped effects only)
--   scale             Effect size (other players see at most 10.0)
--   plusHeight        Height above the box where the effect starts
--   randomizeXY       Random offset of up to 10 m around the box
--   timeToNextShoot   Wait after this particle (ms)
--   colors            Optional: palette to tint with, one color picked per shot
--   chance            Optional: 0.0-1.0 chance to fire on each shot (default always)
--
-- Particles whose dictionary is not in the server's game build are skipped
-----------------------------------------------------------
Config.Fireworks = {
    [1] = {
        name = 'Starburst Display',
        item = 'firework_1',                -- Item name or nil
        itemRemovable = true,               -- Remove item after use
        category = 'classic',               -- Menu tab (Config.Menu.Categories)
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
        category = 'christmas',
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
        category = 'classic',
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
        category = 'classic',
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
        category = 'fountain',
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
        category = 'battery',
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
        category = 'battery',
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
        category = 'classic',
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
        category = 'classic',
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

    -----------------------------------------------------------
    -- HALLOWEEN
    -- Orange, purple and green bursts; the accents at the box need game build
    -- 2699+ (rider bursts) and 2944+ (ghost smoke) and are skipped below that
    -----------------------------------------------------------
    [10] = {
        name = 'Halloween Night',
        item = 'firework_halloween',
        itemRemovable = true,
        category = 'halloween',
        shoots = 40,
        prop = 'ind_prop_firework_03',
        timeToStart = 3000,
        timeBetweenShoots = 900,
        particles = {
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_trailburst', scale = 2.5, plusHeight = 10.0, randomizeXY = true, timeToNextShoot = 150, colors = Config.Palettes.Halloween },
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_starburst', scale = 2.0, plusHeight = 50.0, randomizeXY = true, timeToNextShoot = 300, colors = Config.Palettes.Halloween },
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_starburst', scale = 1.5, plusHeight = 55.0, randomizeXY = true, timeToNextShoot = 150, colors = Config.Palettes.Halloween },
            { name = 'scr_sum2_hal', effect = 'scr_sum2_hal_rider_death_orange', scale = 2.0, plusHeight = 0.5, randomizeXY = false, timeToNextShoot = 0, chance = 0.3 },
            { name = 'scr_sum2_hal', effect = 'scr_sum2_hal_rider_death_green', scale = 2.0, plusHeight = 0.5, randomizeXY = false, timeToNextShoot = 0, chance = 0.3 },
        },
    },

    [11] = {
        name = 'Haunted Battery',
        item = 'firework_halloween_battery',
        itemRemovable = true,
        category = 'halloween',
        shoots = 50,
        prop = 'ind_prop_firework_03',
        timeToStart = 3000,
        timeBetweenShoots = 400,
        particles = {
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_trailburst', scale = 3.0, plusHeight = 10.0, randomizeXY = true, timeToNextShoot = 100, colors = Config.Palettes.Halloween },
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_starburst', scale = 3.0, plusHeight = 60.0, randomizeXY = true, timeToNextShoot = 50, colors = Config.Palettes.Halloween },
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_starburst', scale = 2.5, plusHeight = 60.0, randomizeXY = true, timeToNextShoot = 50, colors = Config.Palettes.Halloween },
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_trailburst', scale = 2.0, plusHeight = 60.0, randomizeXY = true, timeToNextShoot = 10, colors = Config.Palettes.Halloween },
            { name = 'scr_srr_hal', effect = 'scr_srr_hal_appear_smoke_deer', scale = 2.5, plusHeight = 0.5, randomizeXY = false, timeToNextShoot = 0, chance = 0.15 },
        },
    },

    [12] = {
        name = 'Cauldron Fountain',
        item = 'fountain_halloween',
        itemRemovable = true,
        category = 'halloween',
        shoots = 100,
        prop = 'ind_prop_firework_04',
        timeToStart = 3000,
        timeBetweenShoots = 700,
        particles = {
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_fountain', scale = 2.0, plusHeight = 0.25, randomizeXY = false, timeToNextShoot = 500, colors = Config.Palettes.Halloween },
            { name = 'scr_srr_hal', effect = 'scr_srr_hal_appear_smoke_mtlion', scale = 2.0, plusHeight = 0.5, randomizeXY = false, timeToNextShoot = 0, chance = 0.1 },
        },
    },

    -----------------------------------------------------------
    -- CHRISTMAS
    -- Red, green, white and gold; the gold star rocket needs game build 3407+
    -- and is skipped below that
    -----------------------------------------------------------
    [13] = {
        name = 'Christmas Night',
        item = 'firework_christmas',
        itemRemovable = true,
        category = 'christmas',
        shoots = 40,
        prop = 'ind_prop_firework_03',
        timeToStart = 3000,
        timeBetweenShoots = 900,
        particles = {
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_trailburst', scale = 2.5, plusHeight = 10.0, randomizeXY = true, timeToNextShoot = 150, colors = Config.Palettes.Christmas },
            { name = 'proj_xmas_firework', effect = 'scr_firework_xmas_burst_rgw', scale = 1.5, plusHeight = 50.0, randomizeXY = true, timeToNextShoot = 200 },
            { name = 'proj_xmas_firework', effect = 'scr_firework_xmas_ring_burst_rgw', scale = 1.5, plusHeight = 50.0, randomizeXY = true, timeToNextShoot = 200 },
            { name = 'proj_xmas_firework', effect = 'scr_firework_xmas_spiral_burst_rgw', scale = 1.5, plusHeight = 50.0, randomizeXY = true, timeToNextShoot = 200, chance = 0.5 },
            { name = 'scr_hr_lny_races', effect = 'scr_hr_lny_firework_launch_shape_star', scale = 1.0, plusHeight = 0.0, randomizeXY = false, timeToNextShoot = 0, colors = Config.Palettes.Gold, chance = 0.2 },
        },
    },

    [14] = {
        name = 'Christmas Battery',
        item = 'firework_christmas_battery',
        itemRemovable = true,
        category = 'christmas',
        shoots = 50,
        prop = 'ind_prop_firework_03',
        timeToStart = 3000,
        timeBetweenShoots = 400,
        particles = {
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_trailburst', scale = 3.0, plusHeight = 10.0, randomizeXY = true, timeToNextShoot = 100, colors = Config.Palettes.Christmas },
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_starburst', scale = 3.0, plusHeight = 60.0, randomizeXY = true, timeToNextShoot = 50, colors = Config.Palettes.Christmas },
            { name = 'proj_xmas_firework', effect = 'scr_firework_xmas_repeat_burst_rgw', scale = 1.5, plusHeight = 60.0, randomizeXY = true, timeToNextShoot = 50 },
            { name = 'proj_xmas_firework', effect = 'scr_firework_xmas_burst_rgw', scale = 1.5, plusHeight = 60.0, randomizeXY = true, timeToNextShoot = 10 },
        },
    },

    [15] = {
        name = 'Christmas Tree Fountain',
        item = 'fountain_christmas',
        itemRemovable = true,
        category = 'christmas',
        shoots = 100,
        prop = 'ind_prop_firework_04',
        timeToStart = 3000,
        timeBetweenShoots = 700,
        particles = {
            { name = 'scr_indep_fireworks', effect = 'scr_indep_firework_fountain', scale = 2.0, plusHeight = 0.25, randomizeXY = false, timeToNextShoot = 500, colors = Config.Palettes.Christmas },
        },
    },
}
