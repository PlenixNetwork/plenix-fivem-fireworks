# 🎆 Plenix FiveM Fireworks

A fireworks system for FiveM servers with multiple firework types, particle effects, and framework support.

## ✨ Features

- 8 firework types with unique particle effects
- ESX, QBCore, and Standalone support
- ox_inventory, qb-inventory, qs-inventory integration
- Command and item usage support
- ACE or job-based permissions
- Optional lighter requirement
- 3D countdown display

## 📋 Requirements

- **Framework**: ESX Legacy, QBCore, or Standalone
- **Inventory**: ox_inventory (recommended), qb-inventory, or ESX default

## 🚀 Installation

1. Place in your `resources` folder
2. Add items to your inventory system (see `items/` folder)
3. Configure `shared/config.lua`
4. Add to `server.cfg`:

```cfg
ensure plenix-fivem-fireworks
```

## ⚙️ Configuration

Edit `shared/config.lua`:

```lua
Config.General = {
    Debug = false,
    Framework = 'esx',      -- 'esx', 'qb', 'standalone'
    Inventory = 'ox',       -- 'ox', 'qb', 'qs', 'esx'
}

Config.Items = {
    RequireLighter = true,
    LighterItem = 'lighter',
}

Config.Permissions = {
    Mode = 'ace',                    -- 'ace', 'job', 'none'
    AcePermission = 'fireworks.use',
    AllowedJobs = {
        ['police'] = 0,
        ['ambulance'] = 2,
    },
}
```

## 🎮 Commands

| Command | Description |
|---------|-------------|
| `/firework_1` | Starburst Display |
| `/firework_2` | Christmas Special |
| `/firework_3` | Spiral Burst |
| `/firework_4` | Trail Burst |
| `/fountain_1` | Fountain |
| `/firework_battery` | Battery Colorful Burst (rapid colorful explosions) |
| `/firework_battery2` | Battery Fast Burst (rapid explosions) |
| `/firework_start` | Start Rocket (single big explosion) |
| `/firework_finale` | Finale Salute (3 massive explosions) |
| `/stopfirework` | Stop last placed firework |
| `/stopfireworks` | Stop all placed fireworks |

> Commands require permission. Items can be used by anyone.

## 📄 License

This project is licensed under the **MIT License**.
