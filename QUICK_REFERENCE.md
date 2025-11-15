# Quick Reference Guide

## File Structure

```
venice-backend/
├── README.md                                    # Project overview
├── INSTALLATION_GUIDE.md                        # Setup instructions
├── QUICK_REFERENCE.md                          # This file
│
├── ServerScriptService/
│   ├── ShopSystem.lua                          # Main shop server logic
│   └── DataManager.lua                         # Player data & currency
│
├── ReplicatedStorage/
│   └── Modules/
│       └── ShopCatalog.lua                     # All shop items
│
├── StarterGui/
│   └── ShopGui/
│       └── ShopGui.lua                         # GUI creation
│
└── StarterPlayer/
    └── StarterPlayerScripts/
        └── ShopController.lua                  # Client-side logic
```

## Key Functions Reference

### ShopCatalog (ReplicatedStorage/Modules/ShopCatalog.lua)

```lua
ShopCatalog:GetItemsByCategory(category)  -- Get all items in a category
ShopCatalog:GetItem(itemName)             -- Get specific item data
ShopCatalog:CanAfford(itemName, coins)    -- Check if player can buy
```

### DataManager (ServerScriptService/DataManager.lua)

```lua
DataManager:GetData(player)               -- Get all player data
DataManager:GetCoins(player)              -- Get player's coin balance
DataManager:AddCoins(player, amount)      -- Add coins to player
DataManager:RemoveCoins(player, amount)   -- Remove coins (returns bool)
DataManager:OwnsItem(player, itemName)    -- Check if player owns item
DataManager:AddItem(player, itemName)     -- Add item to inventory
```

### ShopController (StarterPlayer/StarterPlayerScripts/ShopController.lua)

```lua
ShopController:PurchaseItem(itemName)     -- Buy an item
ShopController:SpawnItem(itemName)        -- Spawn owned item
ShopController:ShowNotification(msg, color) -- Show message to player
ShopController:OpenBuildMenu()            -- Open inventory
```

## RemoteEvents & RemoteFunctions

Located in **ReplicatedStorage**:

| Name | Type | Purpose |
|------|------|---------|
| `PurchaseItem` | RemoteFunction | Client → Server: Buy item |
| `SpawnItem` | RemoteFunction | Client → Server: Spawn item |
| `CollectTreasure` | RemoteEvent | Client → Server: Add coins |
| `GetPlayerData` | RemoteFunction | Client → Server: Get initial data |
| `UpdatePlayerData` | RemoteEvent | Server → Client: Sync player data |
| `RequestPurchase` | BindableEvent | GUI → Controller: Purchase request |

## Item Properties

Each item in ShopCatalog has:

```lua
{
    Name = "Item Name",              -- Display name
    Price = 100,                     -- Cost in coins
    Category = "Blocks",             -- Category for filtering
    Description = "Description",     -- Shown in shop
    BlockType = "WoodBlock",         -- Unique identifier
    Color = Color3.fromRGB(r,g,b),   -- Block color
    Size = Vector3.new(x,y,z),       -- Block dimensions

    -- Optional properties:
    Transparency = 0.5,              -- For glass blocks
    ThrustPower = 500,               -- For thrusters
    HoverForce = 800                 -- For hover pads
}
```

## Categories

1. **Blocks** - Basic building blocks
2. **Thrusters** - Propulsion and hover systems
3. **Wings** - Stability and aerodynamics
4. **Decorations** - Paint, seats, flags
5. **Special** - Advanced items (rocket boosters, shields, etc.)

## Default Player Data

```lua
{
    Coins = 100,
    OwnedItems = {"Wooden Block"},
    TotalTreasureCollected = 0,
    GamesPlayed = 0
}
```

## GUI Colors

```lua
COLORS = {
    Background = Color3.fromRGB(30, 30, 35),
    Header = Color3.fromRGB(45, 45, 55),
    Button = Color3.fromRGB(60, 60, 70),
    ButtonHover = Color3.fromRGB(80, 80, 90),
    ButtonBuy = Color3.fromRGB(50, 150, 50),
    ButtonBuyHover = Color3.fromRGB(70, 180, 70),
    Text = Color3.fromRGB(255, 255, 255),
    Gold = Color3.fromRGB(255, 215, 0),
    CategorySelected = Color3.fromRGB(100, 100, 255)
}
```

## Adding a New Item

1. Open `ReplicatedStorage/Modules/ShopCatalog.lua`
2. Add to the `Items` table:

```lua
{
    Name = "Cool Block",
    Price = 500,
    Category = "Blocks",
    Description = "A really cool block!",
    BlockType = "CoolBlock",
    Color = Color3.fromRGB(255, 0, 255),
    Size = Vector3.new(4, 4, 4)
}
```

3. Save and test!

## Adding a New Category

1. Open `ReplicatedStorage/Modules/ShopCatalog.lua`
2. Add to `Categories` array:

```lua
ShopCatalog.Categories = {
    "Blocks",
    "Thrusters",
    "Wings",
    "Decorations",
    "Special",
    "YourNewCategory"  -- Add here
}
```

3. Add items with `Category = "YourNewCategory"`

## Awarding Coins (for treasure collection)

In your treasure/coin pickup script:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local collectTreasureEvent = ReplicatedStorage:WaitForChild("CollectTreasure")

-- When player touches treasure
local function onTouched(hit)
    local player = game.Players:GetPlayerFromCharacter(hit.Parent)
    if player then
        local coinAmount = 10  -- How many coins to award
        collectTreasureEvent:FireServer(coinAmount)
    end
end
```

## DataStore Information

- **DataStore Name**: `PlayerData_v1`
- **Key**: Player's UserId
- **Auto-save**: Every 5 minutes
- **Save on leave**: Yes

## Keyboard Shortcuts

- **S** - Toggle Shop
- **B** - Open Build/Inventory Menu

## Common Customizations

### Change Shop Window Size
`StarterGui/ShopGui/ShopGui.lua` line 36-38

### Change Item Card Size
`StarterGui/ShopGui/ShopGui.lua` line 149 (UIGridLayout)

### Modify Starting Coins
`ServerScriptService/DataManager.lua` line 14

### Change Auto-save Interval
`ServerScriptService/DataManager.lua` line 140 (default: 300 seconds)

### Add More Default Items
`ServerScriptService/DataManager.lua` line 15

## Testing Without DataStore

If you're getting DataStore errors in Studio:
1. File → Game Settings → Security
2. Enable "Enable Studio Access to API Services"
3. Click Save

## Performance Tips

- The shop uses UIGridLayout for automatic item positioning
- Items are only created when category is selected (not all at once)
- Player data is cached locally to reduce server calls
- Data is only saved when changed, not continuously

---

**This is a complete, working shop system!** You can extend it with:
- Multiplayer building
- Welding system for blocks
- Vehicle controls
- Treasure spawning system
- Leaderboards
- Achievement system
