# 🎆 Plenix FiveM Fireworks

A fireworks system for FiveM servers with multiple firework types, particle effects, and framework support.

## ✨ Features

- 15 firework types with unique particle effects
- Halloween and Christmas fireworks in seasonal colors
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
| `/firework_halloween` | Halloween Night (orange, purple and green bursts) |
| `/firework_halloween_battery` | Haunted Battery (rapid Halloween explosions with ghostly smoke) |
| `/fountain_halloween` | Cauldron Fountain (Halloween colored fountain) |
| `/firework_christmas` | Christmas Night (red, green, white and gold bursts with a star rocket) |
| `/firework_christmas_battery` | Christmas Battery (rapid Christmas explosions) |
| `/fountain_christmas` | Christmas Tree Fountain (Christmas colored fountain) |
| `/stopfirework` | Stop last placed firework |
| `/stopfireworks` | Stop all placed fireworks |

> Commands require permission. Items can be used by anyone.

## 🎃 Seasonal fireworks

The Halloween and Christmas fireworks tint GTA's own firework effects with the colors in `Config.Palettes` (RGB from `0.0` to `1.0`). Add a `colors` palette to a particle in `Config.Fireworks` to tint it, and a `chance` to fire it on only some shots. Tints work best on the `scr_indep_fireworks` starburst, trailburst, fountain and shotburst, and on the build 3407+ `scr_hr_lny_races` launch effects; effects that already have their own colors, like the `*_rgw` and `*_rwb` bursts, mix with the tint unpredictably.

A few accents come from GTA Online DLCs and only show on servers whose `sv_enforceGameBuild` includes them; below that they are skipped and the rest of the show plays:

| Accent | Firework | Game build |
|--------|----------|------------|
| Orange and green rider bursts | Halloween Night | 2699+ |
| Ghostly smoke | Haunted Battery, Cauldron Fountain | 2944+ |
| Gold star rocket | Christmas Night | 3407+ |

The tint travels with the networked particle, so every player should see the same colors. Test once with two players on your server, and make sure your anticheat doesn't block particle events (`ptFxEvent`).

---

## 📄 License

This project is licensed under the **MIT License**.
