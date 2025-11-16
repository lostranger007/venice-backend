--[[
    ShopSystem.lua
    Main shop system - handles purchases and item spawning
    Place in: ServerScriptService
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Require modules
local ShopCatalog = require(ReplicatedStorage.Modules.ShopCatalog)
local DataManager = require(ServerScriptService.DataManager)

local ShopSystem = {}

-- Initialize DataManager
DataManager:Init()

-- Create a block instance based on item data
local function createBlock(itemData, player)
    local block = Instance.new("Part")
    block.Name = itemData.BlockType
    block.Size = itemData.Size
    block.Color = itemData.Color
    block.Material = Enum.Material.SmoothPlastic
    block.TopSurface = Enum.SurfaceType.Smooth
    block.BottomSurface = Enum.SurfaceType.Smooth

    if itemData.Transparency then
        block.Transparency = itemData.Transparency
    end

    -- Add special properties based on block type
    if itemData.Category == "Thrusters" then
        -- Add BodyVelocity or similar for thrust
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Name = "ThrustForce"
        bodyVelocity.Parent = block

        -- Store thrust power as attribute
        block:SetAttribute("ThrustPower", itemData.ThrustPower or 0)
        block:SetAttribute("HoverForce", itemData.HoverForce or 0)

        -- Add fire effect for thrusters
        local fire = Instance.new("Fire")
        fire.Size = 5
        fire.Heat = 10
        fire.Color = Color3.fromRGB(255, 100, 0)
        fire.Enabled = false
        fire.Name = "ThrustEffect"
        fire.Parent = block
    end

    if itemData.BlockType == "Seat" then
        -- Convert to VehicleSeat
        block:Destroy()
        block = Instance.new("VehicleSeat")
        block.Name = "PilotSeat"
        block.Size = itemData.Size
        block.Color = itemData.Color
        block.TopSurface = Enum.SurfaceType.Smooth
    end

    -- Make block weldable
    block:SetAttribute("IsHovercraftPart", true)
    block:SetAttribute("Owner", player.UserId)

    return block
end

-- Handle purchase request
local function onPurchaseRequest(player, itemName)
    local item = ShopCatalog:GetItem(itemName)

    if not item then
        return {success = false, message = "Item not found!"}
    end

    -- Check if already owned (except free items)
    if item.Price > 0 and DataManager:OwnsItem(player, itemName) then
        return {success = false, message = "You already own this item!"}
    end

    -- Check if player has enough coins
    local playerCoins = DataManager:GetCoins(player)
    if playerCoins < item.Price then
        return {success = false, message = "Not enough coins! Need " .. item.Price .. " coins."}
    end

    -- Process purchase
    if DataManager:RemoveCoins(player, item.Price) then
        DataManager:AddItem(player, itemName)
        return {
            success = true,
            message = "Purchased " .. itemName .. "!",
            newBalance = DataManager:GetCoins(player)
        }
    else
        return {success = false, message = "Purchase failed!"}
    end
end

-- Handle item spawn request
local function onSpawnRequest(player, itemName, cframe)
    -- Check if player owns the item
    if not DataManager:OwnsItem(player, itemName) then
        return {success = false, message = "You don't own this item!"}
    end

    local item = ShopCatalog:GetItem(itemName)
    if not item then
        return {success = false, message = "Item not found!"}
    end

    -- Create the block
    local block = createBlock(item, player)

    -- Position block
    if cframe then
        -- Use provided CFrame (from building system)
        block.CFrame = cframe
    else
        -- Default: position in front of player
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            local spawnPosition = rootPart.Position + rootPart.CFrame.LookVector * 10
            block.Position = spawnPosition + Vector3.new(0, 5, 0)
        else
            block.Position = Vector3.new(0, 50, 0)
        end
    end

    block.Parent = workspace

    return {
        success = true,
        message = "Spawned " .. itemName .. "!",
        blockInstance = block
    }
end

-- Handle treasure collection
local function onTreasureCollected(player, treasureValue)
    DataManager:AddCoins(player, treasureValue)
    local data = DataManager:GetData(player)
    if data then
        data.TotalTreasureCollected = data.TotalTreasureCollected + treasureValue
    end

    return {
        success = true,
        newBalance = DataManager:GetCoins(player)
    }
end

-- Initialize RemoteEvents and RemoteFunctions
function ShopSystem:Init()
    -- Purchase RemoteFunction
    local purchaseFunction = Instance.new("RemoteFunction")
    purchaseFunction.Name = "PurchaseItem"
    purchaseFunction.OnServerInvoke = onPurchaseRequest
    purchaseFunction.Parent = ReplicatedStorage

    -- Spawn item RemoteFunction
    local spawnFunction = Instance.new("RemoteFunction")
    spawnFunction.Name = "SpawnItem"
    spawnFunction.OnServerInvoke = onSpawnRequest
    spawnFunction.Parent = ReplicatedStorage

    -- Treasure collection RemoteEvent
    local treasureEvent = Instance.new("RemoteEvent")
    treasureEvent.Name = "CollectTreasure"
    treasureEvent.OnServerEvent:Connect(function(player, treasureValue)
        onTreasureCollected(player, treasureValue)
    end)
    treasureEvent.Parent = ReplicatedStorage

    -- Get player data RemoteFunction (for initial load)
    local getDataFunction = Instance.new("RemoteFunction")
    getDataFunction.Name = "GetPlayerData"
    getDataFunction.OnServerInvoke = function(player)
        return DataManager:GetData(player)
    end
    getDataFunction.Parent = ReplicatedStorage

    print("ShopSystem initialized")
end

-- Start the shop system
ShopSystem:Init()

return ShopSystem
