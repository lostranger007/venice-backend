-- BuildingGui.lua
-- User interface for the building system

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Load block catalog
local BlockCatalog = require(ReplicatedStorage.Modules.BlockCatalog)

-- Wait for BuildingSystem to load
local BuildingSystem
repeat
	BuildingSystem = _G.BuildingSystem
	if not BuildingSystem then
		wait(0.1)
	end
until BuildingSystem

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BuildingGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main container frame (block selection menu)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 500)
mainFrame.Position = UDim2.new(0, 10, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Add corner rounding
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Title label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "BUILDING BLOCKS"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleLabel

-- Scrolling frame for blocks
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "BlocksList"
scrollFrame.Size = UDim2.new(1, -20, 1, -100)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = mainFrame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 6)
scrollCorner.Parent = scrollFrame

-- List layout for blocks
local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollFrame

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(1, -20, 0, 35)
closeButton.Position = UDim2.new(0, 10, 1, -45)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "CLOSE MENU (ESC)"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- Control panel (top-right)
local controlPanel = Instance.new("Frame")
controlPanel.Name = "ControlPanel"
controlPanel.Size = UDim2.new(0, 200, 0, 100)
controlPanel.Position = UDim2.new(1, -210, 0, 10)
controlPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
controlPanel.BorderSizePixel = 2
controlPanel.BorderColor3 = Color3.fromRGB(255, 255, 255)
controlPanel.Visible = false
controlPanel.Parent = screenGui

local controlCorner = Instance.new("UICorner")
controlCorner.CornerRadius = UDim.new(0, 8)
controlCorner.Parent = controlPanel

-- Delete mode button
local deleteModeButton = Instance.new("TextButton")
deleteModeButton.Name = "DeleteModeButton"
deleteModeButton.Size = UDim2.new(1, -20, 0, 35)
deleteModeButton.Position = UDim2.new(0, 10, 0, 10)
deleteModeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
deleteModeButton.BorderSizePixel = 0
deleteModeButton.Text = "DELETE MODE: OFF"
deleteModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteModeButton.TextSize = 14
deleteModeButton.Font = Enum.Font.GothamBold
deleteModeButton.Parent = controlPanel

local deleteCorner = Instance.new("UICorner")
deleteCorner.CornerRadius = UDim.new(0, 6)
deleteCorner.Parent = deleteModeButton

-- Exit building button
local exitButton = Instance.new("TextButton")
exitButton.Name = "ExitButton"
exitButton.Size = UDim2.new(1, -20, 0, 35)
exitButton.Position = UDim2.new(0, 10, 0, 55)
exitButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
exitButton.BorderSizePixel = 0
exitButton.Text = "EXIT BUILD MODE"
exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
exitButton.TextSize = 14
exitButton.Font = Enum.Font.GothamBold
exitButton.Parent = controlPanel

local exitCorner = Instance.new("UICorner")
exitCorner.CornerRadius = UDim.new(0, 6)
exitCorner.Parent = exitButton

-- Build button (bottom-right corner to open menu)
local buildButton = Instance.new("TextButton")
buildButton.Name = "BuildButton"
buildButton.Size = UDim2.new(0, 150, 0, 50)
buildButton.Position = UDim2.new(1, -160, 1, -60)
buildButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
buildButton.BorderSizePixel = 0
buildButton.Text = "BUILD (B)"
buildButton.TextColor3 = Color3.fromRGB(255, 255, 255)
buildButton.TextSize = 18
buildButton.Font = Enum.Font.GothamBold
buildButton.Parent = screenGui

local buildCorner = Instance.new("UICorner")
buildCorner.CornerRadius = UDim.new(0, 8)
buildCorner.Parent = buildButton

-- Function to create category header
local function createCategoryHeader(categoryName, layoutOrder)
	local header = Instance.new("TextLabel")
	header.Name = "Category_" .. categoryName
	header.Size = UDim2.new(1, -10, 0, 30)
	header.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	header.BorderSizePixel = 0
	header.Text = "▼ " .. categoryName:upper()
	header.TextColor3 = Color3.fromRGB(255, 200, 0)
	header.TextSize = 14
	header.Font = Enum.Font.GothamBold
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.LayoutOrder = layoutOrder
	header.Parent = scrollFrame

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.Parent = header

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 4)
	headerCorner.Parent = header

	return header
end

-- Function to create block button
local function createBlockButton(blockData, layoutOrder)
	local button = Instance.new("TextButton")
	button.Name = blockData.Name
	button.Size = UDim2.new(1, -10, 0, 60)
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.BorderSizePixel = 0
	button.Text = ""
	button.LayoutOrder = layoutOrder
	button.Parent = scrollFrame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = button

	-- Color indicator
	local colorBox = Instance.new("Frame")
	colorBox.Size = UDim2.new(0, 50, 0, 50)
	colorBox.Position = UDim2.new(0, 5, 0, 5)
	colorBox.BackgroundColor3 = blockData.Color
	colorBox.BorderSizePixel = 1
	colorBox.BorderColor3 = Color3.fromRGB(255, 255, 255)
	colorBox.Parent = button

	local colorCorner = Instance.new("UICorner")
	colorCorner.CornerRadius = UDim.new(0, 4)
	colorCorner.Parent = colorBox

	-- Block name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -65, 0, 25)
	nameLabel.Position = UDim2.new(0, 60, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = blockData.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 14
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = button

	-- Block description
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -65, 0, 25)
	descLabel.Position = UDim2.new(0, 60, 0, 30)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = blockData.Description
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextSize = 11
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextWrapped = true
	descLabel.Parent = button

	-- Button click handler
	button.MouseButton1Click:Connect(function()
		BuildingSystem:StartBuilding(blockData)
		mainFrame.Visible = false
		controlPanel.Visible = true
		print("Selected block:", blockData.Name)
	end)

	-- Hover effect
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	end)

	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end)

	return button
end

-- Populate blocks list
local function populateBlocksList()
	-- Clear existing
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	local layoutOrder = 0

	-- Get categories
	local categories = BlockCatalog:GetCategories()

	-- Create sections for each category
	for _, category in ipairs(categories) do
		-- Category header
		createCategoryHeader(category, layoutOrder)
		layoutOrder = layoutOrder + 1

		-- Get blocks in category
		local blocks = BlockCatalog:GetBlocksByCategory(category)

		-- Create button for each block
		for _, block in ipairs(blocks) do
			createBlockButton(block, layoutOrder)
			layoutOrder = layoutOrder + 1
		end
	end

	-- Update canvas size
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

-- Populate on load
populateBlocksList()

-- Update canvas size when layout changes
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

-- Build button click handler
buildButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- Close button click handler
closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

-- Delete mode button click handler
deleteModeButton.MouseButton1Click:Connect(function()
	BuildingSystem:ToggleDeleteMode()
end)

-- Exit building button click handler
exitButton.MouseButton1Click:Connect(function()
	BuildingSystem:StopBuilding()
	controlPanel.Visible = false
end)

-- Listen for delete mode changes
local toggleEvent = Instance.new("BindableEvent")
toggleEvent.Name = "ToggleDeleteMode"
toggleEvent.Parent = ReplicatedStorage

toggleEvent.Event:Connect(function(isDeleteMode)
	if isDeleteMode then
		deleteModeButton.Text = "DELETE MODE: ON"
		deleteModeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	else
		deleteModeButton.Text = "DELETE MODE: OFF"
		deleteModeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	end
end)

-- Keyboard shortcut for opening build menu
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	-- B key to toggle build menu
	if input.KeyCode == Enum.KeyCode.B then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

print("BuildingGui loaded")
