# Installation Guide for Build a Hovercraft for Treasure

This guide will help you set up the shop system in your Roblox game.

## Step 1: Prepare Your Roblox Studio

1. Open Roblox Studio
2. Create a new Baseplate or open your existing game
3. Make sure you can see the Explorer panel (View > Explorer)

## Step 2: Create the Folder Structure

In Roblox Studio Explorer, you should have these services:
- **ServerScriptService** (for server-side scripts)
- **ReplicatedStorage** (for shared modules)
- **StarterGui** (for UI)
- **StarterPlayer** (for player scripts)

## Step 3: Add Server Scripts

### In ServerScriptService:

1. Right-click **ServerScriptService** → Insert Object → **Script**
2. Name it `ShopSystem`
3. Copy the contents from `ServerScriptService/ShopSystem.lua` and paste into this script

4. Right-click **ServerScriptService** → Insert Object → **ModuleScript**
5. Name it `DataManager`
6. Copy the contents from `ServerScriptService/DataManager.lua` and paste into this module

## Step 4: Add Shared Modules

### In ReplicatedStorage:

1. Right-click **ReplicatedStorage** → Insert Object → **Folder**
2. Name it `Modules`

3. Right-click the **Modules** folder → Insert Object → **ModuleScript**
4. Name it `ShopCatalog`
5. Copy the contents from `ReplicatedStorage/Modules/ShopCatalog.lua` and paste into this module

## Step 5: Add GUI

### In StarterGui:

1. Right-click **StarterGui** → Insert Object → **Folder**
2. Name it `ShopGui`

3. Right-click the **ShopGui** folder → Insert Object → **LocalScript**
4. Name it `ShopGui`
5. Copy the contents from `StarterGui/ShopGui/ShopGui.lua` and paste into this script

## Step 6: Add Player Scripts

### In StarterPlayer:

1. Expand **StarterPlayer** in the Explorer
2. Right-click **StarterPlayerScripts** → Insert Object → **LocalScript**
3. Name it `ShopController`
4. Copy the contents from `StarterPlayer/StarterPlayerScripts/ShopController.lua` and paste into this script

## Step 7: Test Your Game

1. Click the **Play** button in Roblox Studio
2. You should see:
   - A **🛒 SHOP** button in the bottom-left corner
   - A **📦 BUILD** button next to it
   - A notification saying "Welcome! Press S for Shop, B for Build"

## Keyboard Controls

- **S** - Toggle Shop
- **B** - Open Build Menu (spawn owned items)

## Customization Tips

### Change Starting Coins
In `ServerScriptService/DataManager.lua`, find line 14:
```lua
Coins = 100,  -- Change this number
```

### Add New Items
In `ReplicatedStorage/Modules/ShopCatalog.lua`, add new entries to the `Items` table following the existing format.

### Change Colors
In `StarterGui/ShopGui/ShopGui.lua`, modify the `COLORS` table at the top (around line 18).

### Modify GUI Layout
In `StarterGui/ShopGui/ShopGui.lua`:
- Line 36-38: Change shop window size
- Line 167: Change category button size
- Line 266: Change shop button position

## Testing the Shop System

1. **Opening the Shop**: Click the "SHOP" button or press S
2. **Browsing Items**: Click category buttons on the left (Blocks, Thrusters, Wings, etc.)
3. **Buying Items**: Click the buy button on any item card
4. **Spawning Items**: Press B or click "BUILD" to open your inventory, then click any owned item to spawn it

## Common Issues

### "Script timeout" error
- This happens if DataStore is not enabled
- Go to Game Settings → Security → Enable Studio Access to API Services

### Items not spawning
- Make sure you're in Play mode, not Edit mode
- Check the Output window for error messages

### GUI not showing
- Make sure the LocalScripts are in the correct locations
- Check that ReplicatedStorage has the required modules

## Next Steps

Now that the shop system is working, you can:

1. **Create a spawn zone** for players
2. **Add treasure items** around the map
3. **Create a finish line** or goal area
4. **Add physics** to make blocks actually hover
5. **Implement welding** so blocks stick together when building
6. **Add team/multiplayer** support

## Need Help?

If you encounter issues:
1. Check the Output window (View → Output) for error messages
2. Make sure all scripts are in the correct locations
3. Verify that all ModuleScripts are named correctly
4. Ensure your game has API Services enabled

---

**Happy Building!** 🚁
