# 🎆 Plenix FiveM Fireworks

A fireworks system for FiveM servers with multiple firework types, particle effects, and framework support.

## ✨ Features

- 15 firework types with unique particle effects
- Halloween and Christmas fireworks in seasonal colors
- ESX, QBCore, and Standalone support
- ox_inventory, qb-inventory, qs-inventory integration
- Launch menu (`/fireworks`) and usable items
- ACE or job-based permissions for the menu
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

Config.Menu = {
    Command = 'fireworks',           -- Opens the launch menu
    Keybind = '',                    -- Optional default key, e.g. 'F7'
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

## 🎮 Launch menu

`/fireworks` opens the launch menu: pick a tab (Classic, Batteries, Fountains, Halloween, Christmas), select a firework and press **Launch** (or double-click it, or press Enter). **Stop last** and **Stop all** stop the fireworks you launched from the menu. Each firework's `category` in `Config.Fireworks` picks its tab, and `Config.Menu.Categories` sets the tabs' order, labels and icons. Players can bind the menu to a key in Settings → Key Bindings → FiveM.

| Firework | Item |
|----------|------|
| Starburst Display | `firework_1` |
| Christmas Special | `firework_2` |
| Spiral Burst | `firework_3` |
| Trail Burst | `firework_4` |
| Fountain | `fountain_1` |
| Battery Colorful Burst (rapid colorful explosions) | `firework_battery` |
| Battery Fast Burst (rapid explosions) | `firework_battery2` |
| Start Rocket (single big explosion) | `firework_start` |
| Finale Salute (3 massive explosions) | `firework_finale` |
| Halloween Night (orange, purple and green bursts) | `firework_halloween` |
| Haunted Battery (rapid Halloween explosions with ghostly smoke) | `firework_halloween_battery` |
| Cauldron Fountain (Halloween colored fountain) | `fountain_halloween` |
| Christmas Night (red, green, white and gold bursts with a star rocket) | `firework_christmas` |
| Christmas Battery (rapid Christmas explosions) | `firework_christmas_battery` |
| Christmas Tree Fountain (Christmas colored fountain) | `fountain_christmas` |

> The menu requires permission and launches without using an item. Items can be used by anyone, so you can sell them in shops.

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
