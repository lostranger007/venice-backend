--[[
    ShopController.lua
    Client-side shop controller
    Location: StarterPlayer > StarterPlayerScripts > ShopController (LocalScript)
]]

print("[ShopController] Starting...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for modules
local ShopCatalog = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ShopCatalog"))

-- Wait for RemoteFunctions
local purchaseFunc = ReplicatedStorage:WaitForChild("PurchaseItem")
local spawnFunc = ReplicatedStorage:WaitForChild("SpawnItem")
local getDataFunc = ReplicatedStorage:WaitForChild("GetPlayerData")
local updateEvent = ReplicatedStorage:WaitForChild("UpdatePlayerData")

local ShopController = {}
ShopController.PlayerData = {Coins = 0, OwnedItems = {}}

-- Create request purchase event
local requestPurchaseEvent = Instance.new("BindableEvent")
requestPurchaseEvent.Name = "RequestPurchase"
requestPurchaseEvent.Parent = ReplicatedStorage

-- Show notification
function ShopController:ShowNotification(message, color)
    local screenGui = playerGui:FindFirstChild("HovercraftShopGui")
    if not screenGui then return end

    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 60)
    notification.Position = UDim2.new(0.5, -150, 0, 20)
    notification.BackgroundColor3 = color or Color3.fromRGB(50, 50, 50)
    notification.BorderSizePixel = 0
    notification.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = notification

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, 0)
    text.Position = UDim2.new(0, 10, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 16
    text.Font = Enum.Font.GothamBold
    text.TextWrapped = true
    text.Parent = notification

    task.delay(3, function()
        notification:Destroy()
    end)
end

-- Update UI
function ShopController:UpdateUI()
    local screenGui = playerGui:FindFirstChild("HovercraftShopGui")
    if screenGui and screenGui:FindFirstChild("ShopFrame") then
        local coinLabel = screenGui.ShopFrame.Header:FindFirstChild("CoinLabel")
        if coinLabel then
            coinLabel.Text = "💰 " .. tostring(ShopController.PlayerData.Coins)
        end
    end
end

-- Purchase item
function ShopController:PurchaseItem(itemName)
    local result = purchaseFunc:InvokeServer(itemName)

    if result.success then
        ShopController:ShowNotification(result.message, Color3.fromRGB(0, 255, 0))
    else
        ShopController:ShowNotification(result.message, Color3.fromRGB(255, 0, 0))
    end
end

-- Create BUILD button
function ShopController:CreateBuildButton()
    local screenGui = playerGui:WaitForChild("HovercraftShopGui")

    local buildButton = Instance.new("TextButton")
    buildButton.Name = "BuildButton"
    buildButton.Size = UDim2.new(0, 120, 0, 50)
    buildButton.Position = UDim2.new(0, 140, 1, -60)
    buildButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    buildButton.Text = "📦 BUILD"
    buildButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    buildButton.TextSize = 20
    buildButton.Font = Enum.Font.GothamBold
    buildButton.BorderSizePixel = 0
    buildButton.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = buildButton

    buildButton.MouseButton1Click:Connect(function()
        ShopController:OpenBuildMenu()
    end)
end

-- Open build menu
function ShopController:OpenBuildMenu()
    local screenGui = playerGui:FindFirstChild("HovercraftShopGui")
    if not screenGui then return end

    if screenGui:FindFirstChild("BuildMenu") then
        screenGui.BuildMenu:Destroy()
        return
    end

    local buildMenu = Instance.new("Frame")
    buildMenu.Name = "BuildMenu"
    buildMenu.Size = UDim2.new(0, 400, 0, 500)
    buildMenu.Position = UDim2.new(0.5, -200, 0.5, -250)
    buildMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    buildMenu.BorderSizePixel = 0
    buildMenu.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = buildMenu

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    header.Text = "SELECT BLOCK TO PLACE"
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextSize = 18
    header.Font = Enum.Font.GothamBold
    header.BorderSizePixel = 0
    header.Parent = buildMenu

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 2.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        buildMenu:Destroy()
    end)

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -50)
    scrollFrame.Position = UDim2.new(0, 10, 0, 45)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.BorderSizePixel = 0
    scrollFrame.Parent = buildMenu

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame

    for _, itemName in ipairs(ShopController.PlayerData.OwnedItems) do
        local item = ShopCatalog:GetItem(itemName)
        if item then
            local itemButton = Instance.new("TextButton")
            itemButton.Size = UDim2.new(1, -10, 0, 50)
            itemButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            itemButton.Text = item.Name
            itemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            itemButton.TextSize = 16
            itemButton.Font = Enum.Font.Gotham
            itemButton.BorderSizePixel = 0
            itemButton.Parent = scrollFrame

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = itemButton

            local colorBox = Instance.new("Frame")
            colorBox.Size = UDim2.new(0, 40, 0, 40)
            colorBox.Position = UDim2.new(0, 5, 0.5, -20)
            colorBox.BackgroundColor3 = item.Color
            colorBox.BorderSizePixel = 1
            colorBox.BorderColor3 = Color3.fromRGB(255, 255, 255)
            colorBox.Parent = itemButton

            local colorCorner = Instance.new("UICorner")
            colorCorner.CornerRadius = UDim.new(0, 4)
            colorCorner.Parent = colorBox

            itemButton.MouseButton1Click:Connect(function()
                if _G.BuildingSystem then
                    _G.BuildingSystem:StartBuilding(item)
                    ShopController:ShowNotification("Building " .. item.Name .. "! Click to place, R to rotate, X to delete, ESC to cancel", Color3.fromRGB(100, 200, 255))
                    buildMenu:Destroy()
                else
                    warn("[ShopController] BuildingSystem not found!")
                end
            end)
        end
    end

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

-- Initialize
function ShopController:Init()
    -- Get initial data
    local data = getDataFunc:InvokeServer()
    if data then
        ShopController.PlayerData = data
        ShopController:UpdateUI()
    end

    -- Listen for updates
    updateEvent.OnClientEvent:Connect(function(newData)
        ShopController.PlayerData = newData
        ShopController:UpdateUI()
    end)

    -- Listen for purchase requests
    requestPurchaseEvent.Event:Connect(function(itemName)
        ShopController:PurchaseItem(itemName)
    end)

    -- Create BUILD button
    task.wait(1)
    ShopController:CreateBuildButton()

    ShopController:ShowNotification("Welcome! Use SHOP and BUILD buttons!", Color3.fromRGB(100, 100, 255))
    print("[ShopController] Initialized")
end

ShopController:Init()

return ShopController
