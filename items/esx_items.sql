--[[
    Plenix FiveM Fireworks - ESX Items (SQL)
    
    Run this SQL query in your database to add the items
    This is for ESX servers using the default items table

    Safe to run again after an update: items you already have (including
    lighter) are skipped and keep their labels and weights
]]

-- SQL Query for ESX items table
INSERT IGNORE INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
    ('firework_1', 'Starburst Firework', 500, 0, 1),
    ('firework_2', 'Christmas Firework', 500, 0, 1),
    ('firework_3', 'Spiral Firework', 500, 0, 1),
    ('firework_4', 'Trail Burst Firework', 500, 0, 1),
    ('fountain_1', 'Fountain Firework', 500, 0, 1),
    ('firework_battery', 'Battery Colorful Burst', 800, 0, 1),
    ('firework_battery2', 'Battery Fast Burst', 800, 0, 1),
    ('firework_start', 'Start Rocket', 300, 0, 1),
    ('firework_finale', 'Finale Salute', 1000, 0, 1),
    ('firework_halloween', 'Halloween Rocket', 500, 0, 1),
    ('firework_halloween_battery', 'Haunted Battery', 800, 0, 1),
    ('fountain_halloween', 'Cauldron Fountain', 500, 0, 1),
    ('firework_christmas', 'Christmas Rocket', 500, 0, 1),
    ('firework_christmas_battery', 'Christmas Battery', 800, 0, 1),
    ('fountain_christmas', 'Christmas Tree Fountain', 500, 0, 1),
    ('lighter', 'Lighter', 50, 0, 1);
