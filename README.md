# Build a Hovercraft for Treasure

A Roblox game inspired by "Build a Boat for Treasure" where players build hovercrafts to collect treasure!

## 🚨 GUI Not Showing Up? Start Here!

If the shop GUI doesn't appear when you test:

1. **Quick Test**: Use `SIMPLE_SHOP_TEST.lua` first
   - Create a LocalScript in StarterGui
   - Copy the contents of `SIMPLE_SHOP_TEST.lua` into it
   - Press Play - you should see a green button
   - If you do, your GUI works! Continue with full installation.

2. **Verify Setup**: Use `SETUP_VERIFICATION.lua`
   - Create a LocalScript in StarterPlayer > StarterPlayerScripts
   - Copy the contents of `SETUP_VERIFICATION.lua` into it
   - Check Output window (F9) for detailed diagnostics

3. **Read Troubleshooting**: See `TROUBLESHOOTING.md` for detailed help

**Most Common Issue**: Making sure scripts are the correct type:
- `ShopGui.lua` must be a **LocalScript** (not Script)
- `ShopController.lua` must be a **LocalScript** (not Script)
- `ShopSystem.lua` must be a **Script** (not LocalScript)

## Features

- **Shop System**: Buy parts to build your hovercraft
- **Currency System**: Earn coins by collecting treasure
- **GUI Shop**: Easy-to-use interface for purchasing items
- **Hovercraft Parts**: Various blocks, thrusters, and decorations

## Installation

1. Open Roblox Studio
2. Create a new place or open your existing game
3. Import the scripts into the corresponding folders:
   - `ServerScriptService/` → ServerScriptService in Roblox Studio
   - `ReplicatedStorage/` → ReplicatedStorage in Roblox Studio
   - `StarterGui/` → StarterGui in Roblox Studio
   - `StarterPlayer/` → StarterPlayer in Roblox Studio

## Structure

```
ServerScriptService/
├── ShopSystem.lua          # Main shop server logic
└── DataManager.lua         # Player data and currency management

ReplicatedStorage/
└── Modules/
    └── ShopCatalog.lua     # Item catalog and configurations

StarterGui/
└── ShopGui/
    └── ShopGui.lua         # GUI creation script

StarterPlayer/
└── StarterPlayerScripts/
    └── ShopController.lua  # Client-side shop controller
```

## How to Use

1. Players start with 100 coins
2. Open the shop by pressing the "SHOP" button on screen
3. Browse and purchase hovercraft parts
4. Build your hovercraft and collect treasure to earn more coins!

## Customization

- Edit `ShopCatalog.lua` to add/remove items
- Modify starting coins in `DataManager.lua`
- Customize GUI colors and layout in `ShopGui.lua`
