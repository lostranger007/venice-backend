--[[
    SETUP_VERIFICATION.lua

    This script checks if your shop system is set up correctly.

    INSTALLATION:
    1. Create a LocalScript in StarterPlayer > StarterPlayerScripts
    2. Name it "SetupVerification"
    3. Copy this entire file into it
    4. Press Play
    5. Check the Output window (View → Output or F9)

    This will tell you exactly what's missing or wrong with your setup!
]]

print("╔═══════════════════════════════════════════════╗")
print("║   SHOP SYSTEM SETUP VERIFICATION             ║")
print("╚═══════════════════════════════════════════════╝")
print("")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local errors = 0
local warnings = 0

-- Helper functions
local function checkExists(parent, name, expectedType)
    local child = parent:FindFirstChild(name)
    if not child then
        warn("✗ MISSING:", name, "in", parent:GetFullName())
        warn("  Expected Type:", expectedType)
        errors = errors + 1
        return false
    else
        if child.ClassName ~= expectedType then
            warn("✗ WRONG TYPE:", name, "is", child.ClassName, "but should be", expectedType)
            errors = errors + 1
            return false
        else
            print("✓", name, "(" .. expectedType .. ")", "found in", parent.Name)
            return true
        end
    end
end

local function checkService(service, name)
    print("")
    print("─────────────────────────────────")
    print("Checking", name .. "...")
    print("─────────────────────────────────")
end

-- Check ReplicatedStorage
checkService(ReplicatedStorage, "ReplicatedStorage")
local modulesFolder = ReplicatedStorage:FindFirstChild("Modules")
if checkExists(ReplicatedStorage, "Modules", "Folder") then
    checkExists(modulesFolder, "ShopCatalog", "ModuleScript")

    -- Try to require the module
    local catalog = modulesFolder:FindFirstChild("ShopCatalog")
    if catalog then
        local success, result = pcall(function()
            return require(catalog)
        end)

        if success then
            print("✓ ShopCatalog module loads successfully!")
            if result.Items and #result.Items > 0 then
                print("✓ ShopCatalog has", #result.Items, "items")
            else
                warn("✗ ShopCatalog has no items!")
                errors = errors + 1
            end
        else
            warn("✗ ShopCatalog has errors:", result)
            errors = errors + 1
        end
    end
end

-- Check RemoteEvents/Functions
print("")
print("Checking RemoteEvents/Functions...")
local remotes = {
    {"PurchaseItem", "RemoteFunction"},
    {"SpawnItem", "RemoteFunction"},
    {"CollectTreasure", "RemoteEvent"},
    {"GetPlayerData", "RemoteFunction"},
    {"UpdatePlayerData", "RemoteEvent"}
}

for _, remote in ipairs(remotes) do
    local name, expectedType = remote[1], remote[2]
    local found = ReplicatedStorage:FindFirstChild(name)

    if found and found.ClassName == expectedType then
        print("✓", name, "(" .. expectedType .. ")")
    elseif found then
        warn("✗", name, "exists but is", found.ClassName, "instead of", expectedType)
        errors = errors + 1
    else
        warn("✗ MISSING:", name, "(this is created by server scripts)")
        warnings = warnings + 1
    end
end

-- Check StarterGui
checkService(StarterGui, "StarterGui")
local shopGuiFolder = StarterGui:FindFirstChild("ShopGui")
if checkExists(StarterGui, "ShopGui", "Folder") then
    checkExists(shopGuiFolder, "ShopGui", "LocalScript")
end

-- Check StarterPlayerScripts
checkService(StarterPlayer.StarterPlayerScripts, "StarterPlayerScripts")
checkExists(StarterPlayer.StarterPlayerScripts, "ShopController", "LocalScript")

-- Check PlayerGui (client-side check)
print("")
print("─────────────────────────────────")
print("Checking Client GUI...")
print("─────────────────────────────────")

local playerGui = player:WaitForChild("PlayerGui", 5)
if playerGui then
    local shopGui = playerGui:FindFirstChild("ShopGui")
    if shopGui then
        print("✓ ShopGui exists in PlayerGui")

        -- Check for GUI elements
        local elements = {
            "ShopFrame",
            "OpenShopButton"
        }

        for _, elementName in ipairs(elements) do
            if shopGui:FindFirstChild(elementName) then
                print("✓", elementName, "exists")
            else
                warn("✗", elementName, "not found")
                errors = errors + 1
            end
        end
    else
        warn("✗ ShopGui not found in PlayerGui")
        warn("  This means the ShopGui LocalScript didn't run or failed")
        errors = errors + 1
    end
else
    warn("✗ PlayerGui not accessible")
    errors = errors + 1
end

-- NOTE: Can't check ServerScriptService from client
print("")
print("─────────────────────────────────")
print("Note: Server Scripts")
print("─────────────────────────────────")
print("⚠ Cannot verify server scripts from client")
print("  Make sure you have these in ServerScriptService:")
print("  • ShopSystem (Script)")
print("  • DataManager (ModuleScript)")

-- Summary
print("")
print("╔═══════════════════════════════════════════════╗")
print("║              VERIFICATION SUMMARY             ║")
print("╚═══════════════════════════════════════════════╝")
print("")

if errors == 0 and warnings == 0 then
    print("✓✓✓ PERFECT! Everything is set up correctly! ✓✓✓")
    print("")
    print("Your shop system should be working!")
    print("Look for the green SHOP button in the bottom-left corner.")
    print("")
elseif errors == 0 then
    print("⚠ Setup is mostly correct, but has", warnings, "warnings")
    print("Warnings are usually OK - they might be created at runtime")
    print("")
else
    print("✗ Found", errors, "errors and", warnings, "warnings")
    print("")
    print("Please fix the errors marked with ✗ above")
    print("Check the INSTALLATION_GUIDE.md for help")
    print("")
end

print("════════════════════════════════════════════════")

-- Keep this script around for re-checking
print("")
print("To run this check again, just restart the game in Studio")
print("You can delete this script once everything works!")
