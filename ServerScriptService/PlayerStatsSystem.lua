--[[
	PlayerStatsSystem.lua
	Manages player survival stats: Health, Hunger, Sanity, Temperature
	Server-side system that tracks and updates all player stats
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local PlayerStatsSystem = {}
PlayerStatsSystem.PlayerData = {} -- Stores data for each player

-- Player stats class
local PlayerStats = {}
PlayerStats.__index = PlayerStats

function PlayerStats.new(player)
	local self = setmetatable({}, PlayerStats)

	self.Player = player
	self.Health = GameConfig.PLAYER_MAX_HEALTH
	self.Hunger = GameConfig.PLAYER_MAX_HUNGER
	self.Sanity = GameConfig.PLAYER_MAX_SANITY
	self.Temperature = GameConfig.PLAYER_MAX_TEMPERATURE

	self.CurrentBiome = "Forest"
	self.IsNearCampfire = false
	self.IsNearEnemy = false

	-- Create stats folder in player
	self:CreateStatsFolder()

	return self
end

function PlayerStats:CreateStatsFolder()
	local statsFolder = Instance.new("Folder")
	statsFolder.Name = "SurvivalStats"
	statsFolder.Parent = self.Player

	-- Create value objects for stats (so they replicate to client)
	local health = Instance.new("NumberValue")
	health.Name = "Health"
	health.Value = self.Health
	health.Parent = statsFolder

	local hunger = Instance.new("NumberValue")
	hunger.Name = "Hunger"
	hunger.Value = self.Hunger
	hunger.Parent = statsFolder

	local sanity = Instance.new("NumberValue")
	sanity.Name = "Sanity"
	sanity.Value = self.Sanity
	sanity.Parent = statsFolder

	local temperature = Instance.new("NumberValue")
	temperature.Name = "Temperature"
	temperature.Value = self.Temperature
	temperature.Parent = statsFolder

	local biome = Instance.new("StringValue")
	biome.Name = "CurrentBiome"
	biome.Value = self.CurrentBiome
	biome.Parent = statsFolder

	self.StatsFolder = statsFolder
end

function PlayerStats:UpdateStatValue(statName, newValue)
	local statValue = self.StatsFolder:FindFirstChild(statName)
	if statValue then
		statValue.Value = newValue
	end
end

function PlayerStats:ModifyHunger(amount)
	self.Hunger = math.clamp(self.Hunger + amount, 0, GameConfig.PLAYER_MAX_HUNGER)
	self:UpdateStatValue("Hunger", self.Hunger)

	if amount > 0 then
		print("[Stats] " .. self.Player.Name .. " gained " .. amount .. " hunger (now " .. math.floor(self.Hunger) .. ")")
	end
end

function PlayerStats:ModifySanity(amount)
	self.Sanity = math.clamp(self.Sanity + amount, 0, GameConfig.PLAYER_MAX_SANITY)
	self:UpdateStatValue("Sanity", self.Sanity)

	if self.Sanity < GameConfig.LOW_SANITY_THRESHOLD then
		-- Trigger low sanity effects (will implement visual effects later)
	end
end

function PlayerStats:ModifyTemperature(amount)
	self.Temperature = math.clamp(self.Temperature + amount, 0, GameConfig.PLAYER_MAX_TEMPERATURE)
	self:UpdateStatValue("Temperature", self.Temperature)

	if self.Temperature < GameConfig.FREEZING_THRESHOLD then
		-- Player is freezing
	end
end

function PlayerStats:SetBiome(biomeName)
	self.CurrentBiome = biomeName
	self:UpdateStatValue("CurrentBiome", biomeName)
end

function PlayerStats:Update(deltaTime, isNightTime)
	-- Hunger drain (constant)
	self:ModifyHunger(-GameConfig.HUNGER_DRAIN_PER_SECOND * deltaTime)

	-- Sanity drain (during night)
	if isNightTime then
		local sanityDrain = GameConfig.SANITY_DRAIN_NIGHT * deltaTime

		-- Extra drain if near enemies
		if self.IsNearEnemy then
			sanityDrain += GameConfig.SANITY_DRAIN_NEAR_ENEMY * deltaTime
		end

		self:ModifySanity(-sanityDrain)
	else
		-- Slowly recover sanity during day
		self:ModifySanity(0.2 * deltaTime)
	end

	-- Temperature management based on biome
	local biomeConfig = GameConfig.BIOMES[self.CurrentBiome]
	if biomeConfig then
		local tempChange = -biomeConfig.TemperatureDrain * deltaTime

		-- Warm up near campfire
		if self.IsNearCampfire then
			tempChange += 0.5 * deltaTime
		end

		self:ModifyTemperature(tempChange)
	end

	-- Apply damage from low stats
	local character = self.Player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			-- Hunger damage
			if self.Hunger < GameConfig.HUNGER_DAMAGE_THRESHOLD then
				humanoid:TakeDamage(GameConfig.HUNGER_DAMAGE_PER_SECOND * deltaTime)
			end

			-- Freezing damage
			if self.Temperature < GameConfig.FREEZING_THRESHOLD then
				humanoid:TakeDamage(GameConfig.FREEZING_DAMAGE_PER_SECOND * deltaTime)
			end

			-- Update health stat
			self.Health = humanoid.Health
			self:UpdateStatValue("Health", self.Health)
		end
	end
end

function PlayerStats:CheckNearCampfire(campfireSystem)
	local character = self.Player.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local nearestCampfire, distance = campfireSystem:GetNearestCampfire(rootPart.Position)

	self.IsNearCampfire = (distance and distance <= GameConfig.CAMPFIRE_HEAL_RADIUS) or false
end

function PlayerStats:Destroy()
	if self.StatsFolder then
		self.StatsFolder:Destroy()
	end
end

-- System functions
function PlayerStatsSystem:Initialize(campfireSystem)
	print("[PlayerStatsSystem] Initializing player stats system...")

	self.CampfireSystem = campfireSystem

	-- Listen for day/night events
	local gameEvents = ReplicatedStorage:WaitForChild("GameEvents")
	local nightStarted = gameEvents:WaitForChild("NightStarted")
	local dayStarted = gameEvents:WaitForChild("DayStarted")

	self.IsNightTime = false

	nightStarted.OnServerEvent:Connect(function()
		self.IsNightTime = true
	end)

	dayStarted.OnServerEvent:Connect(function()
		self.IsNightTime = false
	end)

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

	-- Update loop
	RunService.Heartbeat:Connect(function(deltaTime)
		for userId, playerStats in pairs(self.PlayerData) do
			-- Check if near campfire
			if self.CampfireSystem then
				playerStats:CheckNearCampfire(self.CampfireSystem)
			end

			-- Update stats
			playerStats:Update(deltaTime, self.IsNightTime)
		end
	end)

	-- Create remote events for stat manipulation
	local statEvents = Instance.new("Folder")
	statEvents.Name = "StatEvents"
	statEvents.Parent = ReplicatedStorage

	local eatFoodEvent = Instance.new("RemoteEvent")
	eatFoodEvent.Name = "EatFood"
	eatFoodEvent.Parent = statEvents

	eatFoodEvent.OnServerEvent:Connect(function(player, foodType)
		self:OnPlayerEatFood(player, foodType)
	end)

	print("[PlayerStatsSystem] System initialized!")
end

function PlayerStatsSystem:OnPlayerAdded(player)
	-- Wait for character
	player.CharacterAdded:Connect(function(character)
		-- Create stats for player
		local playerStats = PlayerStats.new(player)
		self.PlayerData[player.UserId] = playerStats

		print("[PlayerStatsSystem] Created stats for " .. player.Name)

		-- Setup character-specific things
		local humanoid = character:WaitForChild("Humanoid")

		-- Listen for death
		humanoid.Died:Connect(function()
			print("[PlayerStatsSystem] " .. player.Name .. " has died!")
			-- Will implement respawn logic later
		end)
	end)

	-- Load character if already exists
	if player.Character then
		local playerStats = PlayerStats.new(player)
		self.PlayerData[player.UserId] = playerStats
	end
end

function PlayerStatsSystem:OnPlayerRemoving(player)
	local playerStats = self.PlayerData[player.UserId]
	if playerStats then
		playerStats:Destroy()
		self.PlayerData[player.UserId] = nil
	end
end

function PlayerStatsSystem:OnPlayerEatFood(player, foodType)
	local playerStats = self.PlayerData[player.UserId]
	if not playerStats then return end

	-- Restore hunger based on food type
	if foodType == "Berries" then
		playerStats:ModifyHunger(GameConfig.BERRIES_HUNGER_RESTORE)
	elseif foodType == "CookedMeat" then
		playerStats:ModifyHunger(GameConfig.COOKED_MEAT_HUNGER_RESTORE)
	elseif foodType == "RawMeat" then
		playerStats:ModifyHunger(GameConfig.RAW_MEAT_HUNGER_RESTORE)
	end
end

function PlayerStatsSystem:GetPlayerStats(player)
	return self.PlayerData[player.UserId]
end

function PlayerStatsSystem:SetPlayerBiome(player, biomeName)
	local playerStats = self.PlayerData[player.UserId]
	if playerStats then
		playerStats:SetBiome(biomeName)
	end
end

return PlayerStatsSystem
