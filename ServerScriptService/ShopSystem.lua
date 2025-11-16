--[[
    ShopSystem.lua
    Main shop server logic
    Location: ServerScriptService > ShopSystem (Script - NOT LocalScript!)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Load modules
local ShopCatalog = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ShopCatalog"))
local DataManager = require(ServerScriptService:WaitForChild("DataManager"))

-- Initialize DataManager first
DataManager:Init()

-- Create a block
local function createBlock(itemData, player)
    local block = Instance.new("Part")
    block.Name = itemData.BlockType
    block.Size = itemData.Size
    block.Color = itemData.Color
    block.Material = Enum.Material.SmoothPlastic
    block.TopSurface = Enum.SurfaceType.Smooth
    block.BottomSurface = Enum.SurfaceType.Smooth
    block.Anchored = false
    block.CanCollide = true

    if itemData.Transparency then
        block.Transparency = itemData.Transparency
    end

    -- Mark as hovercraft part
    block:SetAttribute("IsHovercraftPart", true)
    block:SetAttribute("Owner", player.UserId)

    -- Add thruster effects if needed
    if itemData.Category == "Thrusters" and itemData.ThrustPower then
        block:SetAttribute("ThrustPower", itemData.ThrustPower)
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
