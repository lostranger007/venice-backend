--[[
    ShopSystem.lua
    Main shop server logic for jet parts
    Location: ServerScriptService > ShopSystem (Script - NOT LocalScript!)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Load modules
local ShopCatalog = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ShopCatalog"))
local DataManager = require(ServerScriptService:WaitForChild("DataManager"))

-- Initialize DataManager first
DataManager:Init()

-- Create a jet part
local function createBlock(itemData, player)
    local block

    -- Create VehicleSeat for cockpits
    if itemData.IsCockpit then
        block = Instance.new("VehicleSeat")
        block.Name = "Cockpit"
        block.Size = itemData.Size
        block.Color = itemData.Color
        block.TopSurface = Enum.SurfaceType.Smooth
        block.BottomSurface = Enum.SurfaceType.Smooth
        block.Anchored = true
        block.CanCollide = true
    else
        -- Regular part for everything else
        block = Instance.new("Part")
        block.Name = itemData.Name
        block.Size = itemData.Size
        block.Color = itemData.Color
        block.Material = Enum.Material.SmoothPlastic
        block.TopSurface = Enum.SurfaceType.Smooth
        block.BottomSurface = Enum.SurfaceType.Smooth
        block.Anchored = true
        block.CanCollide = true
    end

    if itemData.Transparency then
        block.Transparency = itemData.Transparency
    end

    -- Mark as jet part
    block:SetAttribute("IsJetPart", true)
    block:SetAttribute("Owner", player.UserId)
    block:SetAttribute("PartType", itemData.BlockType)

    -- Add cockpit attributes
    if itemData.IsCockpit then
        block:SetAttribute("IsCockpit", true)
        block:SetAttribute("Health", itemData.Health or 100)
    end

    -- Add engine attributes and effects
    if itemData.Category == "Engines" then
        block:SetAttribute("ThrustPower", itemData.ThrustPower)
        block:SetAttribute("MaxSpeed", itemData.MaxSpeed)

        -- Add engine fire effect
        local fire = Instance.new("Fire")
        fire.Name = "EngineEffect"
        fire.Size = 8
        fire.Heat = 15
        fire.Color = Color3.fromRGB(255, 150, 0)
        fire.SecondaryColor = Color3.fromRGB(100, 150, 255)
        fire.Enabled = false
        fire.Parent = block

        -- Add smoke effect
        local smoke = Instance.new("Smoke")
        smoke.Name = "EngineSmoke"
        smoke.Size = 3
        smoke.RiseVelocity = -5
        smoke.Color = Color3.fromRGB(100, 100, 100)
        smoke.Opacity = 0.3
        smoke.Enabled = false
        smoke.Parent = block
    end

    -- Add wing attributes
    if itemData.Category == "Wings" then
        block:SetAttribute("Maneuverability", itemData.Maneuverability or 1.0)
        block:SetAttribute("LiftPower", itemData.LiftPower or 50)
    end

    -- Add weapon attributes
    if itemData.Category == "Weapons" then
        block:SetAttribute("WeaponType", itemData.WeaponType)
        block:SetAttribute("Damage", itemData.Damage)
        block:SetAttribute("FireRate", itemData.FireRate)
        block:SetAttribute("Range", itemData.Range)
        if itemData.MissileSpeed then
            block:SetAttribute("MissileSpeed", itemData.MissileSpeed)
        end

        -- Add muzzle attachment for weapons
        local attachment = Instance.new("Attachment")
        attachment.Name = "MuzzlePoint"
        attachment.Position = Vector3.new(0, 0, -itemData.Size.Z/2)
        attachment.Parent = block
    end

    -- Add body part attributes
    if itemData.Stability then
        block:SetAttribute("Stability", itemData.Stability)
    end
    if itemData.SpeedBonus then
        block:SetAttribute("SpeedBonus", itemData.SpeedBonus)
    end
    if itemData.ArmorBonus then
        block:SetAttribute("ArmorBonus", itemData.ArmorBonus)
    end

    return block
end

-- Handle purchase
local function onPurchase(player, itemName)
    local item = ShopCatalog:GetItem(itemName)
    if not item then
        return {success = false, message = "Item not found!"}
    end

    if item.Price > 0 and DataManager:OwnsItem(player, itemName) then
        return {success = false, message = "You already own this!"}
    end

    local playerCoins = DataManager:GetCoins(player)
    if playerCoins < item.Price then
        return {success = false, message = "Not enough coins!"}
    end

    if DataManager:RemoveCoins(player, item.Price) then
        DataManager:AddItem(player, itemName)
        return {success = true, message = "Purchased " .. itemName .. "!"}
    end

    return {success = false, message = "Purchase failed!"}
end

-- Handle spawn
local function onSpawn(player, itemName, cframe)
    if not DataManager:OwnsItem(player, itemName) then
        return {success = false, message = "You don't own this item!"}
    end

    local item = ShopCatalog:GetItem(itemName)
    if not item then
        return {success = false, message = "Item not found!"}
    end

    local block = createBlock(item, player)

    if cframe then
        block.CFrame = cframe
    else
        -- Default: spawn in front of player
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local root = character.HumanoidRootPart
            block.Position = root.Position + root.CFrame.LookVector * 10 + Vector3.new(0, 5, 0)
        else
            block.Position = Vector3.new(0, 50, 0)
        end
    end

    block.Parent = workspace

    return {success = true, message = "Spawned " .. itemName .. "!", block = block}
end

-- Create RemoteFunctions
local purchaseFunc = Instance.new("RemoteFunction")
purchaseFunc.Name = "PurchaseItem"
purchaseFunc.OnServerInvoke = onPurchase
purchaseFunc.Parent = ReplicatedStorage

local spawnFunc = Instance.new("RemoteFunction")
spawnFunc.Name = "SpawnItem"
spawnFunc.OnServerInvoke = onSpawn
spawnFunc.Parent = ReplicatedStorage

local getDataFunc = Instance.new("RemoteFunction")
getDataFunc.Name = "GetPlayerData"
getDataFunc.OnServerInvoke = function(player)
    return DataManager:GetData(player)
end
getDataFunc.Parent = ReplicatedStorage

print("[ShopSystem] Initialized")
