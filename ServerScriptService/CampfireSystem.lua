--[[
	CampfireSystem.lua
	Manages the campfire - the central survival mechanic
	Players must keep it fueled to survive nights
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local CampfireSystem = {}
CampfireSystem.Campfires = {}

-- Campfire class
local Campfire = {}
Campfire.__index = Campfire

function Campfire.new(position)
	local self = setmetatable({}, Campfire)

	self.Fuel = GameConfig.CAMPFIRE_MAX_FUEL
	self.IsLit = true
	self.Position = position
	self.Model = nil

	self:CreateModel()

	return self
end

function Campfire:CreateModel()
	-- Create campfire model
	local model = Instance.new("Model")
	model.Name = "Campfire"

	-- Fire pit (stone base)
	local firePit = Instance.new("Part")
	firePit.Name = "FirePit"
	firePit.Size = Vector3.new(6, 1, 6)
	firePit.Position = self.Position
	firePit.Anchored = true
	firePit.Material = Enum.Material.Slate
	firePit.Color = Color3.fromRGB(70, 70, 70)
	firePit.Shape = Enum.PartType.Cylinder
	firePit.Orientation = Vector3.new(0, 0, 90)
	firePit.Parent = model

	-- Logs
	for i = 1, 4 do
		local log = Instance.new("Part")
		log.Name = "Log" .. i
		log.Size = Vector3.new(1, 1, 4)
		log.Position = self.Position + Vector3.new(0, 1, 0)
		log.Anchored = true
		log.Material = Enum.Material.Wood
		log.Color = Color3.fromRGB(100, 70, 40)
		log.Orientation = Vector3.new(0, i * 45, 0)
		log.Parent = model
	end

	-- Fire effect
	local fireLight = Instance.new("Part")
	fireLight.Name = "FireLight"
	fireLight.Size = Vector3.new(1, 1, 1)
	fireLight.Position = self.Position + Vector3.new(0, 2, 0)
	fireLight.Anchored = true
	fireLight.Transparency = 1
	fireLight.CanCollide = false
	fireLight.Parent = model

	-- Point light for illumination
	local light = Instance.new("PointLight")
	light.Brightness = 2
	light.Color = Color3.fromRGB(255, 150, 50)
	light.Range = 40
	light.Shadows = true
	light.Parent = fireLight

	-- Fire particle effect
	local fire = Instance.new("Fire")
	fire.Size = 8
	fire.Heat = 15
	fire.Color = Color3.fromRGB(255, 120, 0)
	fire.SecondaryColor = Color3.fromRGB(255, 200, 0)
	fire.Parent = fireLight

	-- Smoke particle effect
	local smoke = Instance.new("Smoke")
	smoke.Size = 3
	smoke.RiseVelocity = 5
	smoke.Color = Color3.fromRGB(100, 100, 100)
	smoke.Opacity = 0.5
	smoke.Parent = fireLight

	-- Interaction part
	local interactPart = Instance.new("Part")
	interactPart.Name = "Interact"
	interactPart.Size = Vector3.new(8, 4, 8)
	interactPart.Position = self.Position + Vector3.new(0, 2, 0)
	interactPart.Anchored = true
	interactPart.Transparency = 0.8
	interactPart.CanCollide = false
	interactPart.BrickColor = BrickColor.new("Bright orange")
	interactPart.Material = Enum.Material.Neon
	interactPart.Parent = model

	-- ProximityPrompt for adding fuel
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Add Wood (E)"
	prompt.ObjectText = "Campfire"
	prompt.MaxActivationDistance = 8
	prompt.HoldDuration = 1
	prompt.Parent = interactPart

	-- Store reference to self for closure
	local campfire = self

	prompt.Triggered:Connect(function(player)
		-- Will get ResourceSystem from Initialize
		if CampfireSystem.ResourceSystem then
			campfire:AddFuel(player, GameConfig.WOOD_FUEL_AMOUNT, CampfireSystem.ResourceSystem)
		end
	end)

	-- Add fuel counter billboard
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "FuelDisplay"
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = interactPart

	local fuelText = Instance.new("TextLabel")
	fuelText.Name = "FuelText"
	fuelText.Size = UDim2.new(1, 0, 1, 0)
	fuelText.BackgroundTransparency = 0.3
	fuelText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	fuelText.TextColor3 = Color3.fromRGB(255, 200, 0)
	fuelText.Font = Enum.Font.GothamBold
	fuelText.TextSize = 20
	fuelText.Text = "Fuel: " .. math.floor(self.Fuel) .. "/" .. GameConfig.CAMPFIRE_MAX_FUEL
	fuelText.Parent = billboard

	model.Parent = workspace
	self.Model = model
	self.FireEffect = fire
	self.SmokeEffect = smoke
	self.LightEffect = light
	self.FuelDisplay = fuelText
end

function Campfire:AddFuel(player, amount, resourceSystem)
	-- Check if player has wood in inventory
	if resourceSystem then
		local inventory = resourceSystem:GetPlayerInventory(player)
		if not inventory or not inventory:HasItem("Wood", 1) then
			warn("[Campfire] " .. player.Name .. " doesn't have wood!")
			return false
		end

		-- Consume wood from inventory
		if not inventory:RemoveItem("Wood", 1) then
			return false
		end
	end

	local oldFuel = self.Fuel
	self.Fuel = math.min(GameConfig.CAMPFIRE_MAX_FUEL, self.Fuel + amount)

	if self.Fuel > oldFuel then
		print("[Campfire] " .. player.Name .. " added " .. (self.Fuel - oldFuel) .. " fuel to the campfire.")

		-- Restart fire if it was out
		if not self.IsLit then
			self:Light()
		end

		self:UpdateDisplay()

		return true
	end

	return false
end

function Campfire:DrainFuel(amount)
	self.Fuel = math.max(0, self.Fuel - amount)

	if self.Fuel <= 0 and self.IsLit then
		self:Extinguish()
	end

	self:UpdateDisplay()
end

function Campfire:Light()
	self.IsLit = true
	if self.FireEffect then
		self.FireEffect.Enabled = true
	end
	if self.SmokeEffect then
		self.SmokeEffect.Enabled = true
	end
	if self.LightEffect then
		self.LightEffect.Enabled = true
	end
	print("[Campfire] Campfire has been lit!")
end

function Campfire:Extinguish()
	self.IsLit = false
	if self.FireEffect then
		self.FireEffect.Enabled = false
	end
	if self.SmokeEffect then
		self.SmokeEffect.Enabled = false
	end
	if self.LightEffect then
		self.LightEffect.Enabled = false
	end
	print("[Campfire] WARNING: Campfire has gone out! Add fuel!")
end

function Campfire:UpdateDisplay()
	if self.FuelDisplay then
		self.FuelDisplay.Text = "Fuel: " .. math.floor(self.Fuel) .. "/" .. GameConfig.CAMPFIRE_MAX_FUEL

		-- Change color based on fuel level
		local fuelPercent = self.Fuel / GameConfig.CAMPFIRE_MAX_FUEL
		if fuelPercent > 0.5 then
			self.FuelDisplay.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green
		elseif fuelPercent > 0.25 then
			self.FuelDisplay.TextColor3 = Color3.fromRGB(255, 200, 0) -- Yellow
		else
			self.FuelDisplay.TextColor3 = Color3.fromRGB(255, 50, 50) -- Red
		end
	end
end

function Campfire:HealNearbyPlayers()
	if not self.IsLit then return end

	for _, player in pairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			local rootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoid and rootPart then
				local distance = (rootPart.Position - self.Position).Magnitude

				if distance <= GameConfig.CAMPFIRE_HEAL_RADIUS then
					-- Heal player
					humanoid.Health = math.min(
						humanoid.MaxHealth,
						humanoid.Health + GameConfig.CAMPFIRE_HEAL_RATE * 0.1 -- Scaled for update rate
					)
				end
			end
		end
	end
end

function Campfire:Destroy()
	if self.Model then
		self.Model:Destroy()
	end
end

-- System functions
function CampfireSystem:Initialize(resourceSystem)
	print("[CampfireSystem] Initializing campfire system...")

	-- Store resource system reference
	CampfireSystem.ResourceSystem = resourceSystem

	-- Create main campfire at spawn
	local spawnLocation = workspace:FindFirstChild("SpawnLocation")
	local campfirePosition = spawnLocation and spawnLocation.Position + Vector3.new(0, 5, 15) or Vector3.new(0, 5, 15)

	local mainCampfire = Campfire.new(campfirePosition)
	table.insert(self.Campfires, mainCampfire)

	-- Listen for day/night events
	local gameEvents = ReplicatedStorage:WaitForChild("GameEvents")
	local nightStarted = gameEvents:WaitForChild("NightStarted")
	local dayStarted = gameEvents:WaitForChild("DayStarted")

	self.IsNightTime = false

	nightStarted.OnServerEvent:Connect(function()
		self.IsNightTime = true
		print("[CampfireSystem] Night started - campfires will now drain fuel.")
	end)

	dayStarted.OnServerEvent:Connect(function()
		self.IsNightTime = false
		print("[CampfireSystem] Day started - campfire fuel drain stopped.")
	end)

	-- Update loop
	RunService.Heartbeat:Connect(function(deltaTime)
		for _, campfire in ipairs(self.Campfires) do
			-- Drain fuel during night
			if self.IsNightTime and campfire.IsLit then
				campfire:DrainFuel(GameConfig.CAMPFIRE_FUEL_DRAIN_PER_SECOND * deltaTime)
			end

			-- Heal nearby players
			campfire:HealNearbyPlayers()
		end
	end)

	print("[CampfireSystem] System initialized with " .. #self.Campfires .. " campfire(s).")
end

function CampfireSystem:CreateCampfire(position)
	local campfire = Campfire.new(position)
	table.insert(self.Campfires, campfire)
	return campfire
end

function CampfireSystem:GetNearestCampfire(position)
	local nearest = nil
	local nearestDistance = math.huge

	for _, campfire in ipairs(self.Campfires) do
		local distance = (campfire.Position - position).Magnitude
		if distance < nearestDistance then
			nearest = campfire
			nearestDistance = distance
		end
	end

	return nearest, nearestDistance
end

return CampfireSystem
