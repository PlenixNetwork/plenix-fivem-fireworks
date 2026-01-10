--[[
    Plenix FiveM Fireworks - ox_inventory Items
    
    IMPORTANT: Copy these items to your ox_inventory/data/items.lua file
    
    The items MUST be added to ox_inventory for the script to work!
    
    NOTE: The "consume = 0" setting is required - the script handles item removal!
]]

--[[
    ADD THE FOLLOWING TO YOUR ox_inventory/data/items.lua FILE:
    (Copy everything between the dashed lines)
    
    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    --- FIREWORKS (PLENIX-FIVEM-FIREWORKS) ---
    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    ["firework_1"] = {
        label = "Starburst Firework",
        weight = 500,
        stack = true,
        close = true,
        consume = 0, -- Script handles removal
        description = "A beautiful starburst firework display",
    },

    ["firework_2"] = {
        label = "Christmas Firework",
        weight = 500,
        stack = true,
        close = true,
        consume = 0,
        description = "Festive Christmas themed firework",
    },

    ["firework_3"] = {
        label = "Spiral Firework",
        weight = 500,
        stack = true,
        close = true,
        consume = 0,
        description = "Mesmerizing spiral burst firework",
    },

    ["firework_4"] = {
        label = "Trail Burst Firework",
        weight = 500,
        stack = true,
        close = true,
        consume = 0,
        description = "Stunning trail burst effect",
    },

    ["fountain_1"] = {
        label = "Fountain Firework",
        weight = 500,
        stack = true,
        close = true,
        consume = 0,
        description = "Ground fountain firework",
    },

    ["firework_battery"] = {
        label = "Battery Colorful Burst",
        weight = 800,
        stack = true,
        close = true,
        consume = 0,
        description = "Multiple colorful rapid explosions in the sky",
    },

    ["firework_battery2"] = {
        label = "Battery Fast Burst",
        weight = 800,
        stack = true,
        close = true,
        consume = 0,
        description = "Multiple rapid explosions in the sky",
    },

    ["firework_start"] = {
        label = "Start Rocket",
        weight = 300,
        stack = true,
        close = true,
        consume = 0,
        description = "Single big explosion to announce the start",
    },

    ["firework_finale"] = {
        label = "Finale Salute",
        weight = 1000,
        stack = true,
        close = true,
        consume = 0,
        description = "3 massive explosions to end the show",
    },

    -- Only add lighter if you don't already have one
    ["lighter"] = {
        label = "Lighter",
        weight = 50,
        stack = true,
        close = false,
        description = "A simple lighter to ignite fireworks",
    },
]]
