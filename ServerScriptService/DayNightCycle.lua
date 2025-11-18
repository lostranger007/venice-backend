--[[
	DayNightCycle.lua
	Manages the day/night cycle, lighting, and time progression
	Server-side script that controls game time
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local DayNightCycle = {}

-- State
DayNightCycle.CurrentNight = 0
DayNightCycle.IsNightTime = false
DayNightCycle.TimeElapsed = 0
DayNightCycle.PhaseTimeRemaining = GameConfig.DAY_LENGTH_SECONDS
DayNightCycle.IsInDuskWarning = false

-- Events for other scripts to listen to
local RemoteEvents = Instance.new("Folder")
RemoteEvents.Name = "GameEvents"
RemoteEvents.Parent = ReplicatedStorage

local NightStartedEvent = Instance.new("RemoteEvent")
NightStartedEvent.Name = "NightStarted"
NightStartedEvent.Parent = RemoteEvents

local DayStartedEvent = Instance.new("RemoteEvent")
DayStartedEvent.Name = "DayStarted"
DayStartedEvent.Parent = RemoteEvents

local DuskWarningEvent = Instance.new("RemoteEvent")
DuskWarningEvent.Name = "DuskWarning"
DuskWarningEvent.Parent = RemoteEvents

local TimeUpdateEvent = Instance.new("RemoteEvent")
TimeUpdateEvent.Name = "TimeUpdate"
TimeUpdateEvent.Parent = RemoteEvents

-- Initialize lighting
local function setupLighting()
	Lighting.Brightness = GameConfig.DAY_BRIGHTNESS
	Lighting.Ambient = GameConfig.DAY_AMBIENT
	Lighting.OutdoorAmbient = GameConfig.DAY_AMBIENT
	Lighting.ClockTime = GameConfig.SUNRISE_TIME
	Lighting.GeographicLatitude = 45

	-- Add atmosphere for better visuals
	if not Lighting:FindFirstChild("Atmosphere") then
		local atmosphere = Instance.new("Atmosphere")
		atmosphere.Density = 0.3
		atmosphere.Offset = 0.25
		atmosphere.Color = Color3.fromRGB(199, 199, 199)
		atmosphere.Decay = Color3.fromRGB(106, 112, 125)
		atmosphere.Glare = 0.2
		atmosphere.Haze = 1.5
		atmosphere.Parent = Lighting
	end

	-- Add bloom for night glow effects
	if not Lighting:FindFirstChild("Bloom") then
		local bloom = Instance.new("BloomEffect")
		bloom.Intensity = 0.3
		bloom.Size = 24
		bloom.Threshold = 0.8
		bloom.Parent = Lighting
	end

	-- Add color correction for night mood
	if not Lighting:FindFirstChild("ColorCorrection") then
		local colorCorrection = Instance.new("ColorCorrection")
		colorCorrection.Name = "ColorCorrection"
		colorCorrection.Brightness = 0
		colorCorrection.Contrast = 0
		colorCorrection.Saturation = 0
		colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
		colorCorrection.Parent = Lighting
	end
end

-- Transition to night
local function startNight()
	DayNightCycle.CurrentNight += 1
	DayNightCycle.IsNightTime = true
	DayNightCycle.PhaseTimeRemaining = GameConfig.NIGHT_LENGTH_SECONDS
	DayNightCycle.IsInDuskWarning = false

	print("[DayNightCycle] Night " .. DayNightCycle.CurrentNight .. " has begun!")

	-- Update lighting
	local colorCorrection = Lighting:FindFirstChild("ColorCorrection")

	-- Smooth transition to night
	local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local lightingGoals = {
		Brightness = GameConfig.NIGHT_BRIGHTNESS,
		ClockTime = GameConfig.MIDNIGHT_TIME,
		Ambient = GameConfig.NIGHT_AMBIENT,
		OutdoorAmbient = GameConfig.NIGHT_AMBIENT
	}

	local lightingTween = game:GetService("TweenService"):Create(Lighting, tweenInfo, lightingGoals)
	lightingTween:Play()

	if colorCorrection then
		local ccGoals = {
			Brightness = -0.2,
			Contrast = 0.1,
			Saturation = -0.3,
			TintColor = Color3.fromRGB(100, 120, 180)
		}
		local ccTween = game:GetService("TweenService"):Create(colorCorrection, tweenInfo, ccGoals)
		ccTween:Play()
	end

	-- Fire event to all clients
	NightStartedEvent:FireAllClients(DayNightCycle.CurrentNight)
end

-- Transition to day
local function startDay()
	DayNightCycle.IsNightTime = false
	DayNightCycle.PhaseTimeRemaining = GameConfig.DAY_LENGTH_SECONDS

	print("[DayNightCycle] Day " .. DayNightCycle.CurrentNight .. " has begun! Time to gather resources.")

	-- Update lighting
	local colorCorrection = Lighting:FindFirstChild("ColorCorrection")

	-- Smooth transition to day
	local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local lightingGoals = {
		Brightness = GameConfig.DAY_BRIGHTNESS,
		ClockTime = GameConfig.SUNRISE_TIME,
		Ambient = GameConfig.DAY_AMBIENT,
		OutdoorAmbient = GameConfig.DAY_AMBIENT
	}

	local lightingTween = game:GetService("TweenService"):Create(Lighting, tweenInfo, lightingGoals)
	lightingTween:Play()

	if colorCorrection then
		local ccGoals = {
			Brightness = 0,
			Contrast = 0,
			Saturation = 0,
			TintColor = Color3.fromRGB(255, 255, 255)
		}
		local ccTween = game:GetService("TweenService"):Create(colorCorrection, tweenInfo, ccGoals)
		ccTween:Play()
	end

	-- Fire event to all clients
	DayStartedEvent:FireAllClients(DayNightCycle.CurrentNight)
end

-- Dusk warning
local function triggerDuskWarning()
	if not DayNightCycle.IsInDuskWarning then
		DayNightCycle.IsInDuskWarning = true
		print("[DayNightCycle] DUSK WARNING! Night is coming in " .. GameConfig.DUSK_WARNING_SECONDS .. " seconds!")
		DuskWarningEvent:FireAllClients()
	end
end

-- Initialize the cycle
function DayNightCycle:Initialize()
	print("[DayNightCycle] Initializing day/night cycle system...")

	setupLighting()

	-- Start with day
	DayNightCycle.CurrentNight = 0
	DayNightCycle.IsNightTime = false
	DayNightCycle.PhaseTimeRemaining = GameConfig.DAY_LENGTH_SECONDS

	-- Update loop
	RunService.Heartbeat:Connect(function(deltaTime)
		DayNightCycle.TimeElapsed += deltaTime
		DayNightCycle.PhaseTimeRemaining -= deltaTime

		-- Check for dusk warning
		if not DayNightCycle.IsNightTime and
		   DayNightCycle.PhaseTimeRemaining <= GameConfig.DUSK_WARNING_SECONDS and
		   DayNightCycle.PhaseTimeRemaining > 0 then
			triggerDuskWarning()
		end

		-- Phase transition
		if DayNightCycle.PhaseTimeRemaining <= 0 then
			if DayNightCycle.IsNightTime then
				startDay()
			else
				startNight()
			end
		end

		-- Send periodic updates to clients (every 1 second)
		if math.floor(DayNightCycle.TimeElapsed) % 1 == 0 then
			TimeUpdateEvent:FireAllClients({
				CurrentNight = DayNightCycle.CurrentNight,
				IsNightTime = DayNightCycle.IsNightTime,
				TimeRemaining = math.max(0, math.floor(DayNightCycle.PhaseTimeRemaining))
			})
		end
	end)

	print("[DayNightCycle] System initialized! Starting Day 0.")
end

-- Get current state
function DayNightCycle:GetState()
	return {
		CurrentNight = DayNightCycle.CurrentNight,
		IsNightTime = DayNightCycle.IsNightTime,
		TimeRemaining = math.max(0, math.floor(DayNightCycle.PhaseTimeRemaining))
	}
end

-- Force advance to next phase (for testing)
function DayNightCycle:ForceNextPhase()
	if DayNightCycle.IsNightTime then
		startDay()
	else
		startNight()
	end
end

return DayNightCycle
