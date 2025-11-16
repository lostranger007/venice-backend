--[[
    ShopController.lua
    Client-side controller for the shop system
    Place in: StarterPlayer > StarterPlayerScripts (as a LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for required elements
local ShopCatalog = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ShopCatalog"))

local ShopController = {}
ShopController.PlayerData = {
    Coins = 0,
    OwnedItems = {},
    TotalTreasureCollected = 0,
    GamesPlayed = 0
}

-- Get RemoteEvents/Functions
local purchaseItemFunc = ReplicatedStorage:WaitForChild("PurchaseItem")
local spawnItemFunc = ReplicatedStorage:WaitForChild("SpawnItem")
local updateDataEvent = ReplicatedStorage:WaitForChild("UpdatePlayerData")
local getDataFunc = ReplicatedStorage:WaitForChild("GetPlayerData")

-- Create local event for purchase requests
local requestPurchaseEvent = Instance.new("BindableEvent")
requestPurchaseEvent.Name = "RequestPurchase"
requestPurchaseEvent.Parent = ReplicatedStorage

-- Update local player data
function ShopController:UpdateData(newData)
    if newData then
        ShopController.PlayerData = newData
        ShopController:UpdateUI()
    end
end

-- Update UI elements
function ShopController:UpdateUI()
    -- Update coin display in shop
    local shopGui = playerGui:FindFirstChild("HovercraftShopGui")
    if shopGui and shopGui:FindFirstChild("ShopFrame") then
        local coinLabel = shopGui.ShopFrame.Header.CoinFrame.CoinLabel
        if coinLabel then
            coinLabel.Text = "💰 " .. tostring(ShopController.PlayerData.Coins)
        end

        -- Update buy buttons based on owned items
        ShopController:UpdateBuyButtons()
    end
end

-- Update buy buttons to show owned/not enough coins
function ShopController:UpdateBuyButtons()
    local shopGui = playerGui:FindFirstChild("HovercraftShopGui")
    if not shopGui or not shopGui:FindFirstChild("ShopFrame") then return end

    local itemsFrame = shopGui.ShopFrame.ItemsFrame

    for _, itemCard in ipairs(itemsFrame:GetChildren()) do
        if itemCard:IsA("Frame") and itemCard:FindFirstChild("BuyButton") then
            local buyButton = itemCard.BuyButton
            local itemName = itemCard.Name

            local item = ShopCatalog:GetItem(itemName)
            if not item then continue end

            -- Check if owned
            local isOwned = false
            for _, ownedItem in ipairs(ShopController.PlayerData.OwnedItems) do
                if ownedItem == itemName then
                    isOwned = true
                    break
                end
            end

            if isOwned then
                buyButton.Text = "OWNED ✓"
                buyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            elseif item.Price > ShopController.PlayerData.Coins then
                buyButton.Text = "💰 " .. item.Price .. " (Not Enough)"
                buyButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
            else
                buyButton.Text = item.Price == 0 and "FREE" or "💰 " .. item.Price
                buyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            end
        end
    end
end

-- Handle purchase request
function ShopController:PurchaseItem(itemName)
    local item = ShopCatalog:GetItem(itemName)
    if not item then
        ShopController:ShowNotification("Item not found!", Color3.fromRGB(255, 0, 0))
        return
    end

    -- Check if already owned
    for _, ownedItem in ipairs(ShopController.PlayerData.OwnedItems) do
        if ownedItem == itemName and item.Price > 0 then
            ShopController:ShowNotification("You already own this!", Color3.fromRGB(255, 150, 0))
            return
        end
    end

    -- Check if enough coins
    if ShopController.PlayerData.Coins < item.Price then
        ShopController:ShowNotification("Not enough coins!", Color3.fromRGB(255, 0, 0))
        return
    end

    -- Request purchase from server
    local success, result = pcall(function()
        return purchaseItemFunc:InvokeServer(itemName)
    end)

    if success and result.success then
        ShopController:ShowNotification(result.message, Color3.fromRGB(0, 255, 0))
        -- Data will be updated via UpdatePlayerData event
    else
        local message = (result and result.message) or "Purchase failed!"
        ShopController:ShowNotification(message, Color3.fromRGB(255, 0, 0))
    end
end

-- Spawn an owned item
function ShopController:SpawnItem(itemName)
    local success, result = pcall(function()
        return spawnItemFunc:InvokeServer(itemName)
    end)

    if success and result.success then
        ShopController:ShowNotification(result.message, Color3.fromRGB(0, 255, 0))
    else
        local message = (result and result.message) or "Spawn failed!"
        ShopController:ShowNotification(message, Color3.fromRGB(255, 0, 0))
    end
end

-- Show notification to player
function ShopController:ShowNotification(message, color)
    local screenGui = playerGui:FindFirstChild("HovercraftShopGui")
    if not screenGui then return end

    -- Create notification
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 60)
    notification.Position = UDim2.new(0.5, -150, 0, -70)
    notification.BackgroundColor3 = color or Color3.fromRGB(50, 50, 50)
    notification.BorderSizePixel = 0
    notification.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = notification

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = message
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 16
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextWrapped = true
    textLabel.Parent = notification

    -- Animate in
    notification:TweenPosition(
        UDim2.new(0.5, -150, 0, 20),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Back,
        0.5,
        true
    )

    -- Destroy after delay
    task.delay(3, function()
        notification:TweenPosition(
            UDim2.new(0.5, -150, 0, -70),
            Enum.EasingDirection.In,
            Enum.EasingStyle.Back,
            0.3,
            true,
            function()
                notification:Destroy()
            end
        )
    end)
end

-- Create inventory/build UI
function ShopController:CreateInventoryUI()
    local screenGui = playerGui:FindFirstChild("HovercraftShopGui")
    if not screenGui then return end

    local inventoryButton = Instance.new("TextButton")
    inventoryButton.Name = "InventoryButton"
    inventoryButton.Size = UDim2.new(0, 120, 0, 50)
    inventoryButton.Position = UDim2.new(0, 140, 1, -60)
    inventoryButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    inventoryButton.Text = "📦 BUILD"
    inventoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    inventoryButton.TextSize = 20
    inventoryButton.Font = Enum.Font.GothamBold
    inventoryButton.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = inventoryButton

    -- Click to open build menu
    inventoryButton.MouseButton1Click:Connect(function()
        ShopController:OpenBuildMenu()
    end)
end

-- Open build menu (spawn owned items)
function ShopController:OpenBuildMenu()
    local screenGui = playerGui:FindFirstChild("HovercraftShopGui")
    if not screenGui then return end

    -- Check if already open
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

    -- Header
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    header.Text = "BUILD MODE - Click to Spawn"
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextSize = 18
    header.Font = Enum.Font.GothamBold
    header.Parent = buildMenu

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 2.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header

    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 6)
    closeBtnCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        buildMenu:Destroy()
    end)

    -- Scrolling frame for items
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -50)
    scrollFrame.Position = UDim2.new(0, 10, 0, 45)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.Parent = buildMenu

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame

    -- Add owned items
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
            itemButton.Parent = scrollFrame

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = itemButton

            -- Color indicator
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

            -- Spawn item on click
            itemButton.MouseButton1Click:Connect(function()
                ShopController:SpawnItem(itemName)
            end)
        end
    end

    -- Update canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

-- Handle keyboard shortcuts
function ShopController:SetupInput()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        -- Press B to open build menu
        if input.KeyCode == Enum.KeyCode.B then
            ShopController:OpenBuildMenu()
        end

        -- Press S to toggle shop
        if input.KeyCode == Enum.KeyCode.S then
            local shopGui = playerGui:FindFirstChild("HovercraftShopGui")
            if shopGui and shopGui:FindFirstChild("ShopFrame") then
                local shopFrame = shopGui.ShopFrame
                shopFrame.Visible = not shopFrame.Visible
            end
        end
    end)
end

-- Initialize
function ShopController:Init()
    -- Get initial data
    local success, data = pcall(function()
        return getDataFunc:InvokeServer()
    end)

    if success and data then
        ShopController:UpdateData(data)
    end

    -- Listen for data updates
    updateDataEvent.OnClientEvent:Connect(function(newData)
        ShopController:UpdateData(newData)
    end)

    -- Listen for purchase requests from GUI
    requestPurchaseEvent.Event:Connect(function(itemName)
        ShopController:PurchaseItem(itemName)
    end)

    -- Create additional UI
    task.wait(1)  -- Wait for ShopGui to initialize
    ShopController:CreateInventoryUI()
    ShopController:SetupInput()

    print("ShopController initialized")
    ShopController:ShowNotification("Welcome! Press S for Shop, B for Build", Color3.fromRGB(100, 100, 255))
end

-- Auto-initialize
ShopController:Init()

return ShopController
