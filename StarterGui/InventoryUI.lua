--[[
	InventoryUI.lua
	Displays player inventory and allows item usage
	Shows wood, stone, berries, meat, ammo, etc.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local InventoryUI = {}

function InventoryUI:CreateUI()
	-- Main screen GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "InventoryUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Inventory frame (initially hidden, toggle with Tab)
	local inventoryFrame = Instance.new("Frame")
	inventoryFrame.Name = "InventoryFrame"
	inventoryFrame.Size = UDim2.new(0, 500, 0, 400)
	inventoryFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
	inventoryFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	inventoryFrame.BackgroundTransparency = 0.2
	inventoryFrame.BorderSizePixel = 3
	inventoryFrame.BorderColor3 = Color3.fromRGB(150, 150, 150)
	inventoryFrame.Visible = false
	inventoryFrame.Parent = screenGui

	local invCorner = Instance.new("UICorner")
	invCorner.CornerRadius = UDim.new(0, 12)
	invCorner.Parent = inventoryFrame

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0, 40)
	titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	titleLabel.BackgroundTransparency = 0.3
	titleLabel.BorderSizePixel = 0
	titleLabel.Text = "INVENTORY [Tab to close]"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 20
	titleLabel.Parent = inventoryFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 12)
	titleCorner.Parent = titleLabel

	-- Items container (scrolling frame)
	local itemsContainer = Instance.new("ScrollingFrame")
	itemsContainer.Name = "ItemsContainer"
	itemsContainer.Size = UDim2.new(1, -20, 1, -60)
	itemsContainer.Position = UDim2.new(0, 10, 0, 50)
	itemsContainer.BackgroundTransparency = 1
	itemsContainer.BorderSizePixel = 0
	itemsContainer.ScrollBarThickness = 8
	itemsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	itemsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	itemsContainer.Parent = inventoryFrame

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 8)
	layout.Parent = itemsContainer

	-- Quick inventory display (always visible at top-right)
	local quickInv = Instance.new("Frame")
	quickInv.Name = "QuickInventory"
	quickInv.Size = UDim2.new(0, 180, 0, 150)
	quickInv.Position = UDim2.new(1, -190, 0, 10)
	quickInv.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	quickInv.BackgroundTransparency = 0.6
	quickInv.BorderSizePixel = 0
	quickInv.Parent = screenGui

	local quickCorner = Instance.new("UICorner")
	quickCorner.CornerRadius = UDim.new(0, 8)
	quickCorner.Parent = quickInv

	local quickTitle = Instance.new("TextLabel")
	quickTitle.Size = UDim2.new(1, 0, 0, 25)
	quickTitle.BackgroundTransparency = 1
	quickTitle.Text = "RESOURCES"
	quickTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	quickTitle.Font = Enum.Font.GothamBold
	quickTitle.TextSize = 14
	quickTitle.Parent = quickInv

	local quickLayout = Instance.new("UIListLayout")
	quickLayout.SortOrder = Enum.SortOrder.LayoutOrder
	quickLayout.Padding = UDim.new(0, 3)
	quickLayout.Parent = quickInv

	-- Add padding
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 5)
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = quickInv

	self.ScreenGui = screenGui
	self.InventoryFrame = inventoryFrame
	self.ItemsContainer = itemsContainer
	self.QuickInventory = quickInv
	self.ItemElements = {}
	self.QuickElements = {}
end

function InventoryUI:CreateItemSlot(itemName, amount, parent, isQuick)
	local slot = Instance.new("Frame")
	slot.Name = itemName .. "Slot"
	slot.Size = isQuick and UDim2.new(1, 0, 0, 20) or UDim2.new(1, 0, 0, 60)
	slot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	slot.BackgroundTransparency = isQuick and 1 or 0.3
	slot.BorderSizePixel = 0
	slot.Parent = parent

	if not isQuick then
		local slotCorner = Instance.new("UICorner")
		slotCorner.CornerRadius = UDim.new(0, 6)
		slotCorner.Parent = slot
	end

	-- Item name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "ItemName"
	nameLabel.Size = isQuick and UDim2.new(0.7, 0, 1, 0) or UDim2.new(0.6, -10, 0, 25)
	nameLabel.Position = isQuick and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 10, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = itemName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = isQuick and 12 or 16
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = slot

	-- Amount
	local amountLabel = Instance.new("TextLabel")
	amountLabel.Name = "Amount"
	amountLabel.Size = isQuick and UDim2.new(0.3, 0, 1, 0) or UDim2.new(0.4, -10, 0, 25)
	amountLabel.Position = isQuick and UDim2.new(0.7, 0, 0, 0) or UDim2.new(0.6, 0, 0, 10)
	amountLabel.BackgroundTransparency = 1
	amountLabel.Text = "x" .. amount
	amountLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
	amountLabel.Font = Enum.Font.GothamBold
	amountLabel.TextSize = isQuick and 12 or 16
	amountLabel.TextXAlignment = Enum.TextXAlignment.Right
	amountLabel.Parent = slot

	if not isQuick then
		-- Use button (for consumables)
		if itemName == "Berries" or itemName == "CookedMeat" or itemName == "RawMeat" then
			local useButton = Instance.new("TextButton")
			useButton.Name = "UseButton"
			useButton.Size = UDim2.new(0, 80, 0, 25)
			useButton.Position = UDim2.new(0, 10, 0, 30)
			useButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
			useButton.BorderSizePixel = 0
			useButton.Text = "EAT"
			useButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			useButton.Font = Enum.Font.GothamBold
			useButton.TextSize = 14
			useButton.Parent = slot

			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 4)
			btnCorner.Parent = useButton

			useButton.MouseButton1Click:Connect(function()
				self:UseItem(itemName)
			end)
		end
	end

	return slot
end

function InventoryUI:UseItem(itemName)
	-- Send request to server to use item
	local inventoryEvents = ReplicatedStorage:WaitForChild("InventoryEvents")
	local useItemEvent = inventoryEvents:WaitForChild("UseItem")

	useItemEvent:FireServer(itemName, 1)

	print("[InventoryUI] Used " .. itemName)
end

function InventoryUI:UpdateInventory()
	local inventoryFolder = player:FindFirstChild("Inventory")
	if not inventoryFolder then return end

	-- Clear old elements
	for _, element in pairs(self.ItemElements) do
		element:Destroy()
	end
	self.ItemElements = {}

	for _, element in pairs(self.QuickElements) do
		element:Destroy()
	end
	self.QuickElements = {}

	-- Create new elements
	for _, itemValue in pairs(inventoryFolder:GetChildren()) do
		if itemValue:IsA("IntValue") then
			local itemName = itemValue.Name
			local amount = itemValue.Value

			-- Full inventory slot
			local slot = self:CreateItemSlot(itemName, amount, self.ItemsContainer, false)
			table.insert(self.ItemElements, slot)

			-- Quick inventory (only show important resources)
			if itemName == "Wood" or itemName == "Stone" or itemName == "Berries" then
				local quickSlot = self:CreateItemSlot(itemName, amount, self.QuickInventory, true)
				quickSlot.LayoutOrder = itemName == "Wood" and 2 or (itemName == "Stone" and 3 or 4)
				table.insert(self.QuickElements, quickSlot)
			end
		end
	end
end

function InventoryUI:ToggleInventory()
	self.InventoryFrame.Visible = not self.InventoryFrame.Visible

	if self.InventoryFrame.Visible then
		self:UpdateInventory()
	end
end

function InventoryUI:Initialize()
	print("[InventoryUI] Initializing inventory UI...")

	self:CreateUI()

	-- Wait for inventory folder
	local inventoryFolder = player:WaitForChild("Inventory", 10)

	if not inventoryFolder then
		warn("[InventoryUI] Could not find Inventory folder!")
		return
	end

	-- Listen for inventory changes
	inventoryFolder.ChildAdded:Connect(function()
		self:UpdateInventory()
	end)

	for _, child in pairs(inventoryFolder:GetChildren()) do
		if child:IsA("IntValue") then
			child.Changed:Connect(function()
				self:UpdateInventory()
			end)
		end
	end

	-- Initial update
	self:UpdateInventory()

	-- Tab to toggle inventory
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == Enum.KeyCode.Tab then
			self:ToggleInventory()
		end
	end)

	print("[InventoryUI] Inventory UI initialized!")
end

-- Auto-initialize
InventoryUI:Initialize()

return InventoryUI
