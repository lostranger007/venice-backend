# Troubleshooting Guide - GUI Not Showing Up

## Quick Checks

### 1. Check the Output Window
In Roblox Studio:
- Go to **View** → **Output** (or press F9)
- Look for any **red error messages**
- Take a screenshot and share what errors you see

### 2. Verify Script Types

**CRITICAL**: Make sure you created the correct script types!

| Location | Script Name | Must Be Type |
|----------|-------------|--------------|
| ServerScriptService | ShopSystem | **Script** (NOT LocalScript) |
| ServerScriptService | DataManager | **ModuleScript** |
| ReplicatedStorage/Modules | ShopCatalog | **ModuleScript** |
| StarterGui/ShopGui | ShopGui | **LocalScript** |
| StarterPlayer/StarterPlayerScripts | ShopController | **LocalScript** |

### 3. Check Script Locations

In Explorer, verify this exact structure:

```
Workspace
ReplicatedStorage
  └─ Modules (Folder)
      └─ ShopCatalog (ModuleScript)
ServerScriptService
  ├─ ShopSystem (Script)
  └─ DataManager (ModuleScript)
StarterGui
  └─ ShopGui (Folder)
      └─ ShopGui (LocalScript)
StarterPlayer
  └─ StarterPlayerScripts
      └─ ShopController (LocalScript)
```

## Common Issues & Fixes

### Issue 1: "Script Timeout" Error
**Cause**: DataStore not enabled in Studio

**Fix**:
1. Home → Game Settings
2. Security tab
3. Enable "Enable Studio Access to API Services"
4. Click Save
5. Restart the test

### Issue 2: "Infinite yield" Warning
**Cause**: Scripts can't find required modules

**Fix**:
- Make sure `Modules` folder exists in ReplicatedStorage
- Make sure `ShopCatalog` is inside the Modules folder
- Check spelling is exact (case-sensitive!)

### Issue 3: GUI Literally Not Visible
**Cause**: Script created GUI but it's hidden or positioned off-screen

**Fix**: Use the test script below

### Issue 4: LocalScripts Not Running
**Cause**: Scripts are regular Scripts instead of LocalScripts

**Fix**:
1. Delete the scripts in StarterGui and StarterPlayerScripts
2. Right-click → Insert Object → **LocalScript** (not Script!)
3. Paste the code again

## Test Script (Use This First!)

Create a **LocalScript** in **StarterGui** called "TestGui":

```lua
print("=== GUI TEST STARTED ===")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("Player:", player.Name)
print("PlayerGui:", playerGui)

-- Create a simple test button
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TestGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 100)
button.Position = UDim2.new(0.5, -100, 0.5, -50)
button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
button.Text = "TEST BUTTON - I WORK!"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 20
button.Font = Enum.Font.GothamBold
button.Parent = screenGui

button.MouseButton1Click:Connect(function()
    print("Button clicked!")
    button.Text = "CLICKED!"
end)

print("=== GUI TEST COMPLETE - You should see a red button! ===")
```

**If you see the red button**: Your GUI system works! The issue is with the shop scripts.

**If you DON'T see the red button**: LocalScripts aren't running. Check:
- Is it actually a LocalScript?
- Is it in StarterGui?
- Check Output for errors

## Step-by-Step Verification

### Step 1: Test Server Scripts
1. Start the game in Studio
2. Open Output (F9)
3. Look for these messages:
   ```
   DataManager initialized
   ShopSystem initialized
   ```

**If you DON'T see these**:
- ShopSystem is not running
- Check it's a **Script** (not ModuleScript or LocalScript)
- Check it's in **ServerScriptService**
- Look for error messages in Output

### Step 2: Test Client Scripts
In Output, look for:
```
ShopGui initialized
ShopController initialized
Welcome! Press S for Shop, B for Build
```

**If you DON'T see these**:
- LocalScripts aren't running
- Check they're **LocalScripts** (not regular Scripts)
- Check locations match the structure above

### Step 3: Manual GUI Test
Run this in a LocalScript in StarterGui:

```lua
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Wait a bit for everything to load
wait(2)

-- Check if our GUI exists
local shopGui = player.PlayerGui:FindFirstChild("ShopGui")
print("ShopGui exists:", shopGui ~= nil)

if shopGui then
    print("ShopGui found!")
    local shopFrame = shopGui:FindFirstChild("ShopFrame")
    print("ShopFrame exists:", shopFrame ~= nil)

    local openButton = shopGui:FindFirstChild("OpenShopButton")
    print("OpenShopButton exists:", openButton ~= nil)

    if openButton then
        print("Button Position:", openButton.Position)
        print("Button Size:", openButton.Size)
        print("Button Visible:", openButton.Visible)
    end
else
    print("ShopGui NOT found!")
end
```

## Still Not Working?

If none of the above helps, I'll create a simplified single-script version that's easier to debug. Please share:

1. Screenshot of your Explorer window showing all the scripts
2. Any error messages from Output window
3. Result of the Test Script above

## Quick Fix: All-In-One Version

If you're still stuck, I can create a single-file version that's easier to set up. Let me know!
