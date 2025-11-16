--[[
    DataManager.lua
    Manages player data and currency
    Location: ServerScriptService > DataManager (ModuleScript)
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local DataManager = {}
local playerData = {}
local PlayerDataStore = DataStoreService:GetDataStore("HovercraftPlayerData_v1")

local DEFAULT_DATA = {
    Coins = 100,
    OwnedItems = {"Wooden Block"}
}

function DataManager:GetData(player)
    return playerData[player.UserId]
end

function DataManager:GetCoins(player)
    local data = self:GetData(player)
    return data and data.Coins or 0
end

function DataManager:AddCoins(player, amount)
    local data = self:GetData(player)
    if data then
        data.Coins = data.Coins + amount
        self:UpdateClient(player)
        return true
    end
    return false
end

function DataManager:RemoveCoins(player, amount)
    local data = self:GetData(player)
    if data and data.Coins >= amount then
        data.Coins = data.Coins - amount
        self:UpdateClient(player)
        return true
    end
    return false
end

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

function DataManager:AddItem(player, itemName)
    local data = self:GetData(player)
    if data and not self:OwnsItem(player, itemName) then
        table.insert(data.OwnedItems, itemName)
        self:UpdateClient(player)
        return true
    end
    return false
end

function DataManager:LoadData(player)
    local success, data = pcall(function()
        return PlayerDataStore:GetAsync(player.UserId)
    end)

    if success and data then
        playerData[player.UserId] = data
    else
        playerData[player.UserId] = {
            Coins = DEFAULT_DATA.Coins,
            OwnedItems = {table.unpack(DEFAULT_DATA.OwnedItems)}
        }
    end

    print("[DataManager] Loaded data for", player.Name)
    self:UpdateClient(player)
end

function DataManager:SaveData(player)
    local data = playerData[player.UserId]
    if data then
        local success, err = pcall(function()
            PlayerDataStore:SetAsync(player.UserId, data)
        end)
        if success then
            print("[DataManager] Saved data for", player.Name)
        else
            warn("[DataManager] Failed to save data for", player.Name, ":", err)
        end
    end
end

function DataManager:UpdateClient(player)
    local data = self:GetData(player)
    if data then
        local event = game.ReplicatedStorage:FindFirstChild("UpdatePlayerData")
        if event then
            event:FireClient(player, data)
        end
    end
end

function DataManager:Init()
    local updateEvent = Instance.new("RemoteEvent")
    updateEvent.Name = "UpdatePlayerData"
    updateEvent.Parent = game.ReplicatedStorage

    Players.PlayerAdded:Connect(function(player)
        DataManager:LoadData(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        DataManager:SaveData(player)
        playerData[player.UserId] = nil
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        DataManager:LoadData(player)
    end

    print("[DataManager] Initialized")
end

return DataManager
