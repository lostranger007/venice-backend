--[[
    ShopGui.lua
    Creates the shop GUI
    Location: StarterGui > ShopGui (folder) > ShopGui (LocalScript)
]]

print("[ShopGui] Starting...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for catalog
local ShopCatalog = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ShopCatalog"))

local ShopGui = {}
ShopGui.IsOpen = false
ShopGui.CurrentCategory = "Blocks"

-- Create main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JetFighterShopGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Shop frame
local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopFrame"
shopFrame.Size = UDim2.new(0, 800, 0, 500)
shopFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
shopFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
shopFrame.BorderSizePixel = 0
shopFrame.Visible = false
shopFrame.Parent = screenGui

local shopCorner = Instance.new("UICorner")
shopCorner.CornerRadius = UDim.new(0, 10)
shopCorner.Parent = shopFrame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
header.BorderSizePixel = 0
header.Parent = shopFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "JET FIGHTER SHOP"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Coin display
local coinLabel = Instance.new("TextLabel")
coinLabel.Name = "CoinLabel"
coinLabel.Size = UDim2.new(0, 150, 0, 35)
coinLabel.Position = UDim2.new(1, -160, 0.5, -17)
coinLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
coinLabel.Text = "💰 0"
coinLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinLabel.TextSize = 20
coinLabel.Font = Enum.Font.GothamBold
coinLabel.BorderSizePixel = 0
coinLabel.Parent = header

local coinCorner = Instance.new("UICorner")
coinCorner.CornerRadius = UDim.new(0, 8)
coinCorner.Parent = coinLabel

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -45, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Category frame
local categoryFrame = Instance.new("Frame")
categoryFrame.Size = UDim2.new(0, 150, 1, -60)
categoryFrame.Position = UDim2.new(0, 10, 0, 55)
categoryFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
categoryFrame.BorderSizePixel = 0
categoryFrame.Parent = shopFrame

local catCorner = Instance.new("UICorner")
catCorner.CornerRadius = UDim.new(0, 8)
catCorner.Parent = categoryFrame

local catLayout = Instance.new("UIListLayout")
catLayout.Padding = UDim.new(0, 5)
catLayout.Parent = categoryFrame

-- Items frame
local itemsFrame = Instance.new("ScrollingFrame")
itemsFrame.Name = "ItemsFrame"
itemsFrame.Size = UDim2.new(1, -175, 1, -60)
itemsFrame.Position = UDim2.new(0, 165, 0, 55)
itemsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
itemsFrame.BorderSizePixel = 0
itemsFrame.ScrollBarThickness = 6
itemsFrame.Parent = shopFrame

local itemsCorner = Instance.new("UICorner")
itemsCorner.CornerRadius = UDim.new(0, 8)
itemsCorner.Parent = itemsFrame

local itemsGrid = Instance.new("UIGridLayout")
itemsGrid.CellSize = UDim2.new(0, 180, 0, 200)
itemsGrid.CellPadding = UDim2.new(0, 10, 0, 10)
itemsGrid.SortOrder = Enum.SortOrder.Name
itemsGrid.Parent = itemsFrame

local itemsPadding = Instance.new("UIPadding")
itemsPadding.PaddingTop = UDim.new(0, 10)
itemsPadding.PaddingLeft = UDim.new(0, 10)
itemsPadding.Parent = itemsFrame

-- Shop open button
local shopButton = Instance.new("TextButton")
shopButton.Size = UDim2.new(0, 120, 0, 50)
shopButton.Position = UDim2.new(0, 10, 1, -60)
shopButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
shopButton.Text = "🛒 SHOP"
shopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shopButton.TextSize = 20
shopButton.Font = Enum.Font.GothamBold
shopButton.BorderSizePixel = 0
shopButton.Parent = screenGui

local shopBtnCorner = Instance.new("UICorner")
shopBtnCorner.CornerRadius = UDim.new(0, 10)
shopBtnCorner.Parent = shopButton

-- Functions
function ShopGui:RefreshItems()
    for _, child in ipairs(itemsFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local items = ShopCatalog:GetItemsByCategory(ShopGui.CurrentCategory)

    for _, item in ipairs(items) do
        local card = Instance.new("Frame")
        card.Name = item.Name
        card.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        card.BorderSizePixel = 0
        card.Parent = itemsFrame

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 8)
        cardCorner.Parent = card

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -10, 0, 25)
        nameLabel.Position = UDim2.new(0, 5, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = item.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextWrapped = true
        nameLabel.Parent = card

        local colorBox = Instance.new("Frame")
        colorBox.Size = UDim2.new(0, 80, 0, 80)
        colorBox.Position = UDim2.new(0.5, -40, 0, 35)
        colorBox.BackgroundColor3 = item.Color
        colorBox.BorderSizePixel = 2
        colorBox.BorderColor3 = Color3.fromRGB(255, 255, 255)
        colorBox.Parent = card

        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, 6)
        colorCorner.Parent = colorBox

        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -10, 0, 30)
        descLabel.Position = UDim2.new(0, 5, 0, 120)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = item.Description
        descLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        descLabel.TextSize = 11
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextWrapped = true
        descLabel.TextYAlignment = Enum.TextYAlignment.Top
        descLabel.Parent = card

        local buyButton = Instance.new("TextButton")
        buyButton.Name = "BuyButton"
        buyButton.Size = UDim2.new(1, -20, 0, 35)
        buyButton.Position = UDim2.new(0, 10, 1, -40)
        buyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        buyButton.Text = item.Price == 0 and "FREE" or "💰 " .. item.Price
        buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        buyButton.TextSize = 16
        buyButton.Font = Enum.Font.GothamBold
        buyButton.BorderSizePixel = 0
        buyButton.Parent = card

        local buyCorner = Instance.new("UICorner")
        buyCorner.CornerRadius = UDim.new(0, 6)
        buyCorner.Parent = buyButton

        buyButton.MouseButton1Click:Connect(function()
            local event = ReplicatedStorage:FindFirstChild("RequestPurchase")
            if event then
                event:Fire(item.Name)
            end
        end)
    end

    itemsFrame.CanvasSize = UDim2.new(0, 0, 0, itemsGrid.AbsoluteContentSize.Y + 20)
end

function ShopGui:SetCategory(category)
    ShopGui.CurrentCategory = category

    for _, button in ipairs(categoryFrame:GetChildren()) do
        if button:IsA("TextButton") then
            if button.Text == category then
                button.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
            else
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            end
        end
    end

    ShopGui:RefreshItems()
end

-- Create category buttons
for _, category in ipairs(ShopCatalog.Categories) do
    local button = Instance.new("TextButton")
    button.Name = category .. "Button"
    button.Size = UDim2.new(1, -10, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    button.Text = category
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.Gotham
    button.BorderSizePixel = 0
    button.Parent = categoryFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        ShopGui:SetCategory(category)
    end)
end

-- Toggle shop
shopButton.MouseButton1Click:Connect(function()
    ShopGui.IsOpen = not ShopGui.IsOpen
    shopFrame.Visible = ShopGui.IsOpen
    if ShopGui.IsOpen then
        ShopGui:RefreshItems()
    end
end)

closeButton.MouseButton1Click:Connect(function()
    ShopGui.IsOpen = false
    shopFrame.Visible = false
end)

-- Initial setup
ShopGui:SetCategory("Cockpits")  -- Start with Cockpits category

print("[ShopGui] Initialized")

-- Export
_G.ShopGui = ShopGui
return ShopGui
