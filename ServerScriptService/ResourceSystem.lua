--[[
	ResourceSystem.lua
	Manages resource gathering from trees, rocks, berry bushes, etc.
	Handles player inventory and resource collection
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local GameConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameConfig"))

local ResourceSystem = {}
ResourceSystem.PlayerInventories = {}

-- Inventory class
local Inventory = {}
Inventory.__index = Inventory

function Inventory.new(player)
	local self = setmetatable({}, Inventory)

	self.Player = player
	self.Items = {
		Wood = 0,
		Stone = 0,
		Berries = 0,
		RawMeat = 0,
		CookedMeat = 0,
		Arrows = 0,
		Bullets = 0
	}

	self:CreateInventoryFolder()

	return self
end

function Inventory:CreateInventoryFolder()
	local inventoryFolder = Instance.new("Folder")
	inventoryFolder.Name = "Inventory"
	inventoryFolder.Parent = self.Player

	-- Create value objects for each item type
	for itemName, amount in pairs(self.Items) do
		local itemValue = Instance.new("IntValue")
		itemValue.Name = itemName
		itemValue.Value = amount
		itemValue.Parent = inventoryFolder
	end

	self.InventoryFolder = inventoryFolder
end

function Inventory:AddItem(itemName, amount)
	if not self.Items[itemName] then
		warn("[Inventory] Invalid item type: " .. itemName)
		return false
	end

	self.Items[itemName] = self.Items[itemName] + amount

	-- Update value object
	local itemValue = self.InventoryFolder:FindFirstChild(itemName)
	if itemValue then
		itemValue.Value = self.Items[itemName]
	end

	print("[Inventory] " .. self.Player.Name .. " gained " .. amount .. " " .. itemName .. " (Total: " .. self.Items[itemName] .. ")")

	return true
end

function Inventory:RemoveItem(itemName, amount)
	if not self.Items[itemName] then
		warn("[Inventory] Invalid item type: " .. itemName)
		return false
	end

	if self.Items[itemName] < amount then
		return false -- Not enough items
	end

	self.Items[itemName] = self.Items[itemName] - amount

	-- Update value object
	local itemValue = self.InventoryFolder:FindFirstChild(itemName)
	if itemValue then
		itemValue.Value = self.Items[itemName]
	end

	print("[Inventory] " .. self.Player.Name .. " used " .. amount .. " " .. itemName .. " (Remaining: " .. self.Items[itemName] .. ")")

	return true
end

function Inventory:GetItemCount(itemName)
	return self.Items[itemName] or 0
end

function Inventory:HasItem(itemName, amount)
	return self:GetItemCount(itemName) >= amount
end

function Inventory:Destroy()
	if self.InventoryFolder then
		self.InventoryFolder:Destroy()
	end
end

-- Resource gathering functions
local function gatherResource(player, resourceObject)
	local inventory = ResourceSystem.PlayerInventories[player.UserId]
	if not inventory then return end

	local resourceType = resourceObject:GetAttribute("ResourceType")
	local resourceAmount = resourceObject:GetAttribute("ResourceAmount")

	if not resourceType or not resourceAmount then
		warn("[ResourceSystem] Resource object missing attributes!")
		return
	end

	-- Add to inventory
	inventory:AddItem(resourceType, resourceAmount)

	-- Visual feedback
	local particle = Instance.new("ParticleEmitter")
	particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particle.Rate = 100
	particle.Lifetime = NumberRange.new(0.5, 1)
	particle.Speed = NumberRange.new(5, 10)
	particle.Parent = resourceObject
	particle.Enabled = true

	task.wait(0.3)
	particle.Enabled = false

	task.wait(1)
	particle:Destroy()

	-- Remove or respawn resource
	if resourceObject.Parent:IsA("Model") then
		-- It's a tree, destroy the whole model
		resourceObject.Parent:Destroy()

		-- Respawn after delay (optional)
		task.spawn(function()
			task.wait(120) -- 2 minutes respawn
			-- Could respawn tree here
		end)
	else
		-- It's a rock or bush, just remove it
		resourceObject:Destroy()

		-- Respawn after delay
		task.spawn(function()
			task.wait(60) -- 1 minute respawn for rocks/bushes
			-- Could respawn resource here
		end)
	end
end

-- System functions
function ResourceSystem:Initialize()
	print("[ResourceSystem] Initializing resource gathering system...")

	-- Setup for existing players
	for _, player in pairs(Players:GetPlayers()) do
		self:OnPlayerAdded(player)
	end

	-- Setup for new players
	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerAdded(player)
	end)

	-- Cleanup when players leave
	Players.PlayerRemoving:Connect(function(player)
		self:OnPlayerRemoving(player)
	end)

	-- Listen for ProximityPrompt triggers on all resources
	ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
		local parent = prompt.Parent

		-- Check if it's a resource
		if parent:GetAttribute("ResourceType") then
			gatherResource(player, parent)
		end

		-- Check if it's campfire (add fuel)
		if parent.Name == "Interact" and parent.Parent and parent.Parent.Name == "Campfire" then
			-- Get player's wood
			local inventory = self.PlayerInventories[player.UserId]
			if inventory and inventory:HasItem("Wood", 1) then
				-- Wood will be consumed by campfire system
				-- (the campfire system handles this via its own prompt)
			end
		end
	end)

	-- Create remote events for inventory operations
	local inventoryEvents = Instance.new("Folder")
	inventoryEvents.Name = "InventoryEvents"
	inventoryEvents.Parent = ReplicatedStorage

	local useItemEvent = Instance.new("RemoteEvent")
	useItemEvent.Name = "UseItem"
	useItemEvent.Parent = inventoryEvents

	useItemEvent.OnServerEvent:Connect(function(player, itemName, amount)
		self:OnPlayerUseItem(player, itemName, amount or 1)
	end)

	print("[ResourceSystem] System initialized!")
end

function ResourceSystem:OnPlayerAdded(player)
	-- Wait for character
	player.CharacterAdded:Connect(function(character)
		-- Create inventory for player
		local inventory = Inventory.new(player)
		self.PlayerInventories[player.UserId] = inventory

		print("[ResourceSystem] Created inventory for " .. player.Name)

		-- Give starting items
		inventory:AddItem("Wood", 10) -- Start with some wood
		inventory:AddItem("Berries", 3)
	end)

	-- Load character if already exists
	if player.Character then
		local inventory = Inventory.new(player)
		self.PlayerInventories[player.UserId] = inventory

		-- Give starting items
		inventory:AddItem("Wood", 10)
		inventory:AddItem("Berries", 3)
	end
end

function ResourceSystem:OnPlayerRemoving(player)
	local inventory = self.PlayerInventories[player.UserId]
	if inventory then
		inventory:Destroy()
		self.PlayerInventories[player.UserId] = nil
	end
end

function ResourceSystem:OnPlayerUseItem(player, itemName, amount)
	local inventory = self.PlayerInventories[player.UserId]
	if not inventory then return end

	-- Handle different item types
	if itemName == "Berries" or itemName == "CookedMeat" or itemName == "RawMeat" then
		-- Eating food
		if inventory:RemoveItem(itemName, amount) then
			-- Trigger stat restoration
			local statEvents = ReplicatedStorage:FindFirstChild("StatEvents")
			if statEvents then
				local eatFoodEvent = statEvents:FindFirstChild("EatFood")
				if eatFoodEvent then
					eatFoodEvent:Fire(player, itemName)
				end
			end
		end
	elseif itemName == "Wood" then
		-- Could be used for building or campfire
		-- Handle based on context
	end
end

function ResourceSystem:GetPlayerInventory(player)
	return self.PlayerInventories[player.UserId]
end

return ResourceSystem
