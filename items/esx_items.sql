--[[
    Plenix FiveM Fireworks - ESX Items (SQL)
    
    Run this SQL query in your database to add the items
    This is for ESX servers using the default items table
]]

-- SQL Query for ESX items table
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
    ('firework_1', 'Starburst Firework', 500, 0, 1),
    ('firework_2', 'Christmas Firework', 500, 0, 1),
    ('firework_3', 'Spiral Firework', 500, 0, 1),
    ('firework_4', 'Trail Burst Firework', 500, 0, 1),
    ('fountain_1', 'Fountain Firework', 500, 0, 1),
    ('lighter', 'Lighter', 50, 0, 1);

-- If you already have a lighter item, remove the last line
