--[[
    ShopGui.lua
    Creates the shop GUI interface
    Place in: StarterGui > ShopGui (as a LocalScript)
]]

print("=== ShopGui Starting ===")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
print("Player found:", player.Name)

local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
    warn("PlayerGui not found!")
    return
end
print("PlayerGui found")

-- Wait for modules with error handling
print("Waiting for ReplicatedStorage.Modules.ShopCatalog...")
local modulesFolder = ReplicatedStorage:WaitForChild("Modules", 10)
if not modulesFolder then
    warn("Modules folder not found in ReplicatedStorage!")
    warn("Make sure you created a Folder named 'Modules' in ReplicatedStorage")
    return
end

local catalogModule = modulesFolder:WaitForChild("ShopCatalog", 10)
if not catalogModule then
    warn("ShopCatalog module not found in Modules folder!")
    warn("Make sure you created a ModuleScript named 'ShopCatalog' in the Modules folder")
    return
end

local ShopCatalog
local success, err = pcall(function()
    ShopCatalog = require(catalogModule)
end)

if not success then
    warn("Failed to load ShopCatalog:", err)
    return
end

print("ShopCatalog loaded successfully!")

local ShopGui = {}
ShopGui.IsOpen = false
ShopGui.CurrentCategory = "Blocks"

-- Colors
local COLORS = {
    Background = Color3.fromRGB(30, 30, 35),
    Header = Color3.fromRGB(45, 45, 55),
    Button = Color3.fromRGB(60, 60, 70),
    ButtonHover = Color3.fromRGB(80, 80, 90),
    ButtonBuy = Color3.fromRGB(50, 150, 50),
    ButtonBuyHover = Color3.fromRGB(70, 180, 70),
    Text = Color3.fromRGB(255, 255, 255),
    Gold = Color3.fromRGB(255, 215, 0),
    CategorySelected = Color3.fromRGB(100, 100, 255)
}

-- Create main GUI
function ShopGui:CreateMainGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShopGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    -- Main shop frame (hidden by default)
    local shopFrame = Instance.new("Frame")
    shopFrame.Name = "ShopFrame"
    shopFrame.Size = UDim2.new(0, 800, 0, 500)
    shopFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
    shopFrame.BackgroundColor3 = COLORS.Background
    shopFrame.BorderSizePixel = 0
    shopFrame.Visible = false
    shopFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = shopFrame

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = COLORS.Header
    header.BorderSizePixel = 0
    header.Parent = shopFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "HOVERCRAFT SHOP"
    title.TextColor3 = COLORS.Text
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- Coin display
    local coinFrame = Instance.new("Frame")
    coinFrame.Name = "CoinFrame"
    coinFrame.Size = UDim2.new(0, 150, 0, 35)
    coinFrame.Position = UDim2.new(1, -160, 0.5, -17)
    coinFrame.BackgroundColor3 = COLORS.Button
    coinFrame.BorderSizePixel = 0
    coinFrame.Parent = header

    local coinCorner = Instance.new("UICorner")
    coinCorner.CornerRadius = UDim.new(0, 8)
    coinCorner.Parent = coinFrame

    local coinLabel = Instance.new("TextLabel")
    coinLabel.Name = "CoinLabel"
    coinLabel.Size = UDim2.new(1, -10, 1, 0)
    coinLabel.Position = UDim2.new(0, 5, 0, 0)
    coinLabel.BackgroundTransparency = 1
    coinLabel.Text = "💰 0"
    coinLabel.TextColor3 = COLORS.Gold
    coinLabel.TextSize = 20
    coinLabel.Font = Enum.Font.GothamBold
    coinLabel.Parent = coinFrame

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -45, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = COLORS.Text
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton

    -- Category buttons container
    local categoryFrame = Instance.new("Frame")
    categoryFrame.Name = "CategoryFrame"
    categoryFrame.Size = UDim2.new(0, 150, 1, -60)
    categoryFrame.Position = UDim2.new(0, 10, 0, 55)
    categoryFrame.BackgroundColor3 = COLORS.Header
    categoryFrame.BorderSizePixel = 0
    categoryFrame.Parent = shopFrame

    local catCorner = Instance.new("UICorner")
    catCorner.CornerRadius = UDim.new(0, 8)
    catCorner.Parent = categoryFrame

    local categoryList = Instance.new("UIListLayout")
    categoryList.Padding = UDim.new(0, 5)
    categoryList.Parent = categoryFrame

    -- Items container
    local itemsFrame = Instance.new("ScrollingFrame")
    itemsFrame.Name = "ItemsFrame"
    itemsFrame.Size = UDim2.new(1, -175, 1, -60)
    itemsFrame.Position = UDim2.new(0, 165, 0, 55)
    itemsFrame.BackgroundColor3 = COLORS.Header
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

    local gridPadding = Instance.new("UIPadding")
    gridPadding.PaddingTop = UDim.new(0, 10)
    gridPadding.PaddingLeft = UDim.new(0, 10)
    gridPadding.Parent = itemsFrame

    return screenGui
end

-- Create category button
function ShopGui:CreateCategoryButton(category, parent)
    local button = Instance.new("TextButton")
    button.Name = category .. "Button"
    button.Size = UDim2.new(1, -10, 0, 40)
    button.BackgroundColor3 = COLORS.Button
    button.Text = category
    button.TextColor3 = COLORS.Text
    button.TextSize = 16
    button.Font = Enum.Font.Gotham
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    -- Hover effect
    button.MouseEnter:Connect(function()
        if ShopGui.CurrentCategory ~= category then
            button.BackgroundColor3 = COLORS.ButtonHover
        end
    end)

    button.MouseLeave:Connect(function()
        if ShopGui.CurrentCategory ~= category then
            button.BackgroundColor3 = COLORS.Button
        end
    end)

    -- Click event
    button.MouseButton1Click:Connect(function()
        ShopGui:SetCategory(category)
    end)

    return button
end

-- Create item card
function ShopGui:CreateItemCard(item, parent)
    local card = Instance.new("Frame")
    card.Name = item.Name
    card.BackgroundColor3 = COLORS.Button
    card.BorderSizePixel = 0
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    -- Item name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -10, 0, 25)
    nameLabel.Position = UDim2.new(0, 5, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = item.Name
    nameLabel.TextColor3 = COLORS.Text
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextWrapped = true
    nameLabel.Parent = card

    -- Color preview
    local colorPreview = Instance.new("Frame")
    colorPreview.Size = UDim2.new(0, 80, 0, 80)
    colorPreview.Position = UDim2.new(0.5, -40, 0, 35)
    colorPreview.BackgroundColor3 = item.Color
    colorPreview.BorderSizePixel = 2
    colorPreview.BorderColor3 = COLORS.Text
    colorPreview.Parent = card

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 6)
    previewCorner.Parent = colorPreview

    -- Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -10, 0, 30)
    descLabel.Position = UDim2.new(0, 5, 0, 120)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = item.Description
    descLabel.TextColor3 = COLORS.Text
    descLabel.TextSize = 11
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextWrapped = true
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = card

    -- Price and Buy button
    local buyButton = Instance.new("TextButton")
    buyButton.Name = "BuyButton"
    buyButton.Size = UDim2.new(1, -20, 0, 35)
    buyButton.Position = UDim2.new(0, 10, 1, -40)
    buyButton.BackgroundColor3 = COLORS.ButtonBuy
    buyButton.Text = item.Price == 0 and "FREE" or "💰 " .. item.Price
    buyButton.TextColor3 = COLORS.Text
    buyButton.TextSize = 16
    buyButton.Font = Enum.Font.GothamBold
    buyButton.Parent = card

    local buyCorner = Instance.new("UICorner")
    buyCorner.CornerRadius = UDim.new(0, 6)
    buyCorner.Parent = buyButton

    -- Button hover
    buyButton.MouseEnter:Connect(function()
        buyButton.BackgroundColor3 = COLORS.ButtonBuyHover
    end)

    buyButton.MouseLeave:Connect(function()
        buyButton.BackgroundColor3 = COLORS.ButtonBuy
    end)

    return card, buyButton
end

-- Set active category
function ShopGui:SetCategory(category)
    ShopGui.CurrentCategory = category

    -- Update category button colors
    local categoryFrame = playerGui.ShopGui.ShopFrame.CategoryFrame
    for _, button in ipairs(categoryFrame:GetChildren()) do
        if button:IsA("TextButton") then
            if button.Text == category then
                button.BackgroundColor3 = COLORS.CategorySelected
            else
                button.BackgroundColor3 = COLORS.Button
            end
        end
    end

    -- Refresh items
    ShopGui:RefreshItems()
end

-- Refresh item list
function ShopGui:RefreshItems()
    local itemsFrame = playerGui.ShopGui.ShopFrame.ItemsFrame

    -- Clear existing items
    for _, child in ipairs(itemsFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    -- Get items for current category
    local items = ShopCatalog:GetItemsByCategory(ShopGui.CurrentCategory)

    -- Create item cards
    for _, item in ipairs(items) do
        local card, buyButton = ShopGui:CreateItemCard(item, itemsFrame)

        -- Handle purchase
        buyButton.MouseButton1Click:Connect(function()
            -- This will be handled by ShopController
            local event = ReplicatedStorage:FindFirstChild("RequestPurchase")
            if event then
                event:Fire(item.Name)
            end
        end)
    end

    -- Update canvas size
    local gridLayout = itemsFrame:FindFirstChildOfClass("UIGridLayout")
    if gridLayout then
        itemsFrame.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y + 20)
    end
end

-- Update coin display
function ShopGui:UpdateCoins(amount)
    local coinLabel = playerGui.ShopGui.ShopFrame.Header.CoinFrame.CoinLabel
    if coinLabel then
        coinLabel.Text = "💰 " .. tostring(amount)
    end
end

-- Toggle shop visibility
function ShopGui:Toggle()
    local shopFrame = playerGui.ShopGui.ShopFrame
    ShopGui.IsOpen = not ShopGui.IsOpen
    shopFrame.Visible = ShopGui.IsOpen

    if ShopGui.IsOpen then
        ShopGui:RefreshItems()
    end
end

-- Create shop button (to open shop)
function ShopGui:CreateShopButton()
    local screenGui = playerGui:WaitForChild("ShopGui")

    local shopButton = Instance.new("TextButton")
    shopButton.Name = "OpenShopButton"
    shopButton.Size = UDim2.new(0, 120, 0, 50)
    shopButton.Position = UDim2.new(0, 10, 1, -60)
    shopButton.BackgroundColor3 = COLORS.ButtonBuy
    shopButton.Text = "🛒 SHOP"
    shopButton.TextColor3 = COLORS.Text
    shopButton.TextSize = 20
    shopButton.Font = Enum.Font.GothamBold
    shopButton.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = shopButton

    shopButton.MouseButton1Click:Connect(function()
        ShopGui:Toggle()
    end)

    -- Hover effect
    shopButton.MouseEnter:Connect(function()
        shopButton.BackgroundColor3 = COLORS.ButtonBuyHover
    end)

    shopButton.MouseLeave:Connect(function()
        shopButton.BackgroundColor3 = COLORS.ButtonBuy
    end)
end

-- Initialize
function ShopGui:Init()
    print("Initializing ShopGui...")

    -- Create main GUI
    print("Creating main GUI...")
    local screenGui = ShopGui:CreateMainGui()
    print("ScreenGui created:", screenGui.Name)

    local categoryFrame = screenGui.ShopFrame.CategoryFrame
    print("CategoryFrame found")

    -- Create category buttons
    print("Creating category buttons...")
    for _, category in ipairs(ShopCatalog.Categories) do
        ShopGui:CreateCategoryButton(category, categoryFrame)
        print("  - Created button for:", category)
    end

    -- Set initial category
    print("Setting initial category...")
    ShopGui:SetCategory("Blocks")

    -- Create shop open button
    print("Creating shop open button...")
    ShopGui:CreateShopButton()
    print("Shop button created!")

    -- Close button functionality
    local closeButton = screenGui.ShopFrame.Header.CloseButton
    closeButton.MouseButton1Click:Connect(function()
        print("Close button clicked")
        ShopGui:Toggle()
    end)

    print("=== ShopGui initialized successfully! ===")
    print("You should see a green 'SHOP' button in the bottom-left corner!")
end

-- Auto-initialize when script runs
local initSuccess, initErr = pcall(function()
    ShopGui:Init()
end)

if not initSuccess then
    warn("Failed to initialize ShopGui:", initErr)
    warn("Check the error above and verify your setup!")
end

return ShopGui
