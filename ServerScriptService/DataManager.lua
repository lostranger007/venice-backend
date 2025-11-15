--[[
    DataManager.lua
    Manages player data, currency, and inventory
    Place in: ServerScriptService
]]

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DataManager = {}
local playerData = {}

-- DataStore for saving player progress
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")

-- Default data for new players
local DEFAULT_DATA = {
    Coins = 100,  -- Starting coins
    OwnedItems = {"Wooden Block"},  -- Items player owns
    TotalTreasureCollected = 0,
    GamesPlayed = 0
}

-- Get player data
function DataManager:GetData(player)
    return playerData[player.UserId]
end

-- Get player coins
function DataManager:GetCoins(player)
    local data = self:GetData(player)
    return data and data.Coins or 0
end

-- Add coins to player
function DataManager:AddCoins(player, amount)
    local data = self:GetData(player)
    if data then
        data.Coins = data.Coins + amount
        self:UpdateClient(player)
        return true
    end
    return false
end

-- Remove coins from player (for purchases)
function DataManager:RemoveCoins(player, amount)
    local data = self:GetData(player)
    if data and data.Coins >= amount then
        data.Coins = data.Coins - amount
        self:UpdateClient(player)
        return true
    end
    return false
end

-- Check if player owns an item
function DataManager:OwnsItem(player, itemName)
    local data = self:GetData(player)
    if data then
        for _, ownedItem in ipairs(data.OwnedItems) do
            if ownedItem == itemName then
                return true
            end
        end
    end
    return false
end

-- Add item to player's inventory
function DataManager:AddItem(player, itemName)
    local data = self:GetData(player)
    if data and not self:OwnsItem(player, itemName) then
        table.insert(data.OwnedItems, itemName)
        return true
    end
    return false
end

-- Load player data from DataStore
function DataManager:LoadData(player)
    local success, data = pcall(function()
        return PlayerDataStore:GetAsync(player.UserId)
    end)

    if success and data then
        playerData[player.UserId] = data
        print("Loaded data for " .. player.Name)
    else
        -- New player or error loading, use default data
        playerData[player.UserId] = {
            Coins = DEFAULT_DATA.Coins,
            OwnedItems = {table.unpack(DEFAULT_DATA.OwnedItems)},  -- Copy array
            TotalTreasureCollected = DEFAULT_DATA.TotalTreasureCollected,
            GamesPlayed = DEFAULT_DATA.GamesPlayed
        }
        print("Created new data for " .. player.Name)
    end

    -- Send initial data to client
    self:UpdateClient(player)
end

-- Save player data to DataStore
function DataManager:SaveData(player)
    local data = playerData[player.UserId]
    if data then
        local success, err = pcall(function()
            PlayerDataStore:SetAsync(player.UserId, data)
        end)

        if success then
            print("Saved data for " .. player.Name)
        else
            warn("Failed to save data for " .. player.Name .. ": " .. tostring(err))
        end
    end
end

-- Update client with current data
function DataManager:UpdateClient(player)
    local data = self:GetData(player)
    if data then
        -- Send to client via RemoteEvent
        local updateEvent = ReplicatedStorage:WaitForChild("UpdatePlayerData", 5)
        if updateEvent then
            updateEvent:FireClient(player, data)
        end
    end
end

-- Handle player joining
local function onPlayerAdded(player)
    DataManager:LoadData(player)
end

-- Handle player leaving
local function onPlayerRemoving(player)
    DataManager:SaveData(player)
    playerData[player.UserId] = nil
end

-- Initialize
function DataManager:Init()
    -- Create RemoteEvents for communication
    local updateEvent = Instance.new("RemoteEvent")
    updateEvent.Name = "UpdatePlayerData"
    updateEvent.Parent = ReplicatedStorage

    -- Connect player events
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)

    -- Load data for existing players (if script reloaded)
    for _, player in ipairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end

    -- Save all data periodically (every 5 minutes)
    spawn(function()
        while true do
            wait(300)  -- 5 minutes
            for _, player in ipairs(Players:GetPlayers()) do
                DataManager:SaveData(player)
            end
            print("Auto-saved all player data")
        end
    end)

    print("DataManager initialized")
end

return DataManager
