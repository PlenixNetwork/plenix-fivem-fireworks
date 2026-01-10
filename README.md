# 🎆 Plenix FiveM Fireworks

A fireworks system for FiveM servers with multiple firework types, particle effects, and framework support.

## ✨ Features

- 5 firework types with unique particle effects
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
| `/fire_1` | Starburst Display |
| `/fire_2` | Christmas Special |
| `/fire_3` | Spiral Burst |
| `/fire_4` | Trail Burst |
| `/fountain_1` | Fountain |

> Commands require permission. Items can be used by anyone.

## 📄 License

MIT License - see [LICENSE](LICENSE)

---

**Made with ❤️ by Plenix Network**
