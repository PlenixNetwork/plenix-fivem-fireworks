fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'plenix-fivem-fireworks'
author 'Plenix Network'
description 'Advanced Fireworks System for FiveM with multiple firework types, particle effects, and framework support'
version '2.0.0'

-- Shared Scripts (loaded on both client and server)
shared_scripts {
    'shared/config.lua',
    'shared/functions.lua'
}

-- Client Scripts
client_scripts {
    'client/main.lua'
}

-- Server Scripts
server_scripts {
    'server/main.lua'
}