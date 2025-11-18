--[[
	SurvivalUI.lua
	Creates and manages the survival game UI
	Shows: Health, Hunger, Sanity, Temperature, Night counter, Time remaining
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for game config
local GameConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameConfig"))

local SurvivalUI = {}

-- Create main UI
function SurvivalUI:CreateUI()
	-- Main screen GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SurvivalUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Stats container (top-left)
	local statsFrame = Instance.new("Frame")
	statsFrame.Name = "StatsFrame"
	statsFrame.Size = UDim2.new(0, 250, 0, 200)
	statsFrame.Position = UDim2.new(0, 10, 0, 10)
	statsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	statsFrame.BackgroundTransparency = 0.5
	statsFrame.BorderSizePixel = 2
	statsFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
	statsFrame.Parent = screenGui

	local statsCorner = Instance.new("UICorner")
	statsCorner.CornerRadius = UDim.new(0, 10)
	statsCorner.Parent = statsFrame

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0, 30)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "SURVIVAL STATS"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.Parent = statsFrame

	-- Create stat bars
	self:CreateStatBar(statsFrame, "Health", 1, GameConfig.UI_COLORS.Health)
	self:CreateStatBar(statsFrame, "Hunger", 2, GameConfig.UI_COLORS.Hunger)
	self:CreateStatBar(statsFrame, "Sanity", 3, GameConfig.UI_COLORS.Sanity)
	self:CreateStatBar(statsFrame, "Temperature", 4, GameConfig.UI_COLORS.Temperature)

	-- Night counter (top-center)
	local nightFrame = Instance.new("Frame")
	nightFrame.Name = "NightFrame"
	nightFrame.Size = UDim2.new(0, 300, 0, 80)
	nightFrame.Position = UDim2.new(0.5, -150, 0, 10)
	nightFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	nightFrame.BackgroundTransparency = 0.5
	nightFrame.BorderSizePixel = 2
	nightFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
	nightFrame.Parent = screenGui

	local nightCorner = Instance.new("UICorner")
	nightCorner.CornerRadius = UDim.new(0, 10)
	nightCorner.Parent = nightFrame

	local nightLabel = Instance.new("TextLabel")
	nightLabel.Name = "NightLabel"
	nightLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nightLabel.BackgroundTransparency = 1
	nightLabel.Text = "NIGHT 0"
	nightLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	nightLabel.Font = Enum.Font.GothamBold
	nightLabel.TextSize = 24
	nightLabel.Parent = nightFrame

	local timeLabel = Instance.new("TextLabel")
	timeLabel.Name = "TimeLabel"
	timeLabel.Size = UDim2.new(1, 0, 0.5, 0)
	timeLabel.Position = UDim2.new(0, 0, 0.5, 0)
	timeLabel.BackgroundTransparency = 1
	timeLabel.Text = "Day - 5:00 remaining"
	timeLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
	timeLabel.Font = Enum.Font.Gotham
	timeLabel.TextSize = 18
	timeLabel.Parent = nightFrame

	-- Dusk warning (center)
	local duskWarning = Instance.new("Frame")
	duskWarning.Name = "DuskWarning"
	duskWarning.Size = UDim2.new(0, 400, 0, 100)
	duskWarning.Position = UDim2.new(0.5, -200, 0.5, -50)
	duskWarning.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
	duskWarning.BackgroundTransparency = 0.3
	duskWarning.BorderSizePixel = 3
	duskWarning.BorderColor3 = Color3.fromRGB(255, 0, 0)
	duskWarning.Visible = false
	duskWarning.Parent = screenGui

	local duskCorner = Instance.new("UICorner")
	duskCorner.CornerRadius = UDim.new(0, 15)
	duskCorner.Parent = duskWarning

	local duskText = Instance.new("TextLabel")
	duskText.Size = UDim2.new(1, 0, 1, 0)
	duskText.BackgroundTransparency = 1
	duskText.Text = "⚠️ NIGHT IS COMING! ⚠️\nReturn to campfire!"
	duskText.TextColor3 = Color3.fromRGB(255, 255, 255)
	duskText.Font = Enum.Font.GothamBold
	duskText.TextSize = 20
	duskText.Parent = duskWarning

	-- Controls hint (bottom-left)
	local controlsFrame = Instance.new("Frame")
	controlsFrame.Name = "ControlsFrame"
	controlsFrame.Size = UDim2.new(0, 200, 0, 120)
	controlsFrame.Position = UDim2.new(0, 10, 1, -130)
	controlsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	controlsFrame.BackgroundTransparency = 0.7
	controlsFrame.BorderSizePixel = 0
	controlsFrame.Parent = screenGui

	local controlsCorner = Instance.new("UICorner")
	controlsCorner.CornerRadius = UDim.new(0, 8)
	controlsCorner.Parent = controlsFrame

	local controlsText = Instance.new("TextLabel")
	controlsText.Size = UDim2.new(1, -10, 1, -10)
	controlsText.Position = UDim2.new(0, 5, 0, 5)
	controlsText.BackgroundTransparency = 1
	controlsText.Text = [[CONTROLS:
WASD - Move
Space - Jump
E - Interact
B - Build Menu
Tab - Inventory]]
	controlsText.TextColor3 = Color3.fromRGB(200, 200, 200)
	controlsText.Font = Enum.Font.Gotham
	controlsText.TextSize = 12
	controlsText.TextXAlignment = Enum.TextXAlignment.Left
	controlsText.TextYAlignment = Enum.TextYAlignment.Top
	controlsText.Parent = controlsFrame

	self.ScreenGui = screenGui
	self.NightLabel = nightLabel
	self.TimeLabel = timeLabel
	self.DuskWarning = duskWarning
	self.StatBars = {}
end

function SurvivalUI:CreateStatBar(parent, statName, position, color)
	local yOffset = 30 + (position * 40)

	-- Container
	local container = Instance.new("Frame")
	container.Name = statName .. "Container"
	container.Size = UDim2.new(1, -20, 0, 35)
	container.Position = UDim2.new(0, 10, 0, yOffset)
	container.BackgroundTransparency = 1
	container.Parent = parent

	-- Label
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, 0, 0, 15)
	label.BackgroundTransparency = 1
	label.Text = statName
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	-- Bar background
	local barBg = Instance.new("Frame")
	barBg.Name = "BarBackground"
	barBg.Size = UDim2.new(1, 0, 0, 18)
	barBg.Position = UDim2.new(0, 0, 0, 17)
	barBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	barBg.BorderSizePixel = 1
	barBg.BorderColor3 = Color3.fromRGB(100, 100, 100)
	barBg.Parent = container

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 4)
	barCorner.Parent = barBg

	-- Bar fill
	local barFill = Instance.new("Frame")
	barFill.Name = "BarFill"
	barFill.Size = UDim2.new(1, 0, 1, 0)
	barFill.BackgroundColor3 = color
	barFill.BorderSizePixel = 0
	barFill.Parent = barBg

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 4)
	fillCorner.Parent = barFill

	-- Value text
	local valueText = Instance.new("TextLabel")
	valueText.Name = "ValueText"
	valueText.Size = UDim2.new(1, 0, 1, 0)
	valueText.BackgroundTransparency = 1
	valueText.Text = "100/100"
	valueText.TextColor3 = Color3.fromRGB(255, 255, 255)
	valueText.Font = Enum.Font.GothamBold
	valueText.TextSize = 11
	valueText.ZIndex = 2
	valueText.Parent = barBg

	self.StatBars[statName] = {
		Fill = barFill,
		ValueText = valueText
	}
end

function SurvivalUI:UpdateStatBar(statName, currentValue, maxValue)
	local statBar = self.StatBars[statName]
	if not statBar then return end

	local percentage = math.clamp(currentValue / maxValue, 0, 1)

	-- Update bar size
	statBar.Fill.Size = UDim2.new(percentage, 0, 1, 0)

	-- Update text
	statBar.ValueText.Text = math.floor(currentValue) .. "/" .. maxValue

	-- Flash red if low
	if percentage < 0.25 then
		-- Pulsing effect for low stats
		local pulseValue = (math.sin(tick() * 4) + 1) / 2 -- 0 to 1
		statBar.Fill.BackgroundTransparency = 0.3 * pulseValue
	else
		statBar.Fill.BackgroundTransparency = 0
	end
end

function SurvivalUI:UpdateNightCounter(nightNumber, isNight, timeRemaining)
	-- Update night label
	if nightNumber == 0 then
		self.NightLabel.Text = "STARTING SOON"
		self.NightLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	else
		self.NightLabel.Text = "NIGHT " .. nightNumber .. " / " .. GameConfig.TOTAL_NIGHTS_REQUIRED
		self.NightLabel.TextColor3 = isNight and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
	end

	-- Update time label
	local minutes = math.floor(timeRemaining / 60)
	local seconds = timeRemaining % 60
	local phase = isNight and "NIGHT" or "DAY"

	self.TimeLabel.Text = phase .. " - " .. minutes .. ":" .. string.format("%02d", seconds) .. " remaining"
	self.TimeLabel.TextColor3 = isNight and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 100)
end

function SurvivalUI:ShowDuskWarning()
	self.DuskWarning.Visible = true

	-- Flash effect
	task.spawn(function()
		for i = 1, 6 do
			self.DuskWarning.Visible = true
			task.wait(0.5)
			self.DuskWarning.Visible = false
			task.wait(0.5)
		end
		self.DuskWarning.Visible = false
	end)
end

function SurvivalUI:Initialize()
	print("[SurvivalUI] Initializing survival UI...")

	self:CreateUI()

	-- Wait for survival stats folder
	local character = player.Character or player.CharacterAdded:Wait()
	local statsFolder = player:WaitForChild("SurvivalStats", 10)

	if not statsFolder then
		warn("[SurvivalUI] Could not find SurvivalStats folder!")
		return
	end

	-- Listen for stat changes
	local function updateStats()
		local health = statsFolder:FindFirstChild("Health")
		local hunger = statsFolder:FindFirstChild("Hunger")
		local sanity = statsFolder:FindFirstChild("Sanity")
		local temperature = statsFolder:FindFirstChild("Temperature")

		if health then
			self:UpdateStatBar("Health", health.Value, GameConfig.PLAYER_MAX_HEALTH)
		end
		if hunger then
			self:UpdateStatBar("Hunger", hunger.Value, GameConfig.PLAYER_MAX_HUNGER)
		end
		if sanity then
			self:UpdateStatBar("Sanity", sanity.Value, GameConfig.PLAYER_MAX_SANITY)
		end
		if temperature then
			self:UpdateStatBar("Temperature", temperature.Value, GameConfig.PLAYER_MAX_TEMPERATURE)
		end
	end

	-- Update on value changes
	for _, stat in pairs(statsFolder:GetChildren()) do
		if stat:IsA("NumberValue") then
			stat.Changed:Connect(updateStats)
		end
	end

	-- Initial update
	updateStats()

	-- Listen for game events
	local gameEvents = ReplicatedStorage:WaitForChild("GameEvents")

	gameEvents:WaitForChild("TimeUpdate").OnClientEvent:Connect(function(data)
		self:UpdateNightCounter(data.CurrentNight, data.IsNightTime, data.TimeRemaining)
	end)

	gameEvents:WaitForChild("DuskWarning").OnClientEvent:Connect(function()
		self:ShowDuskWarning()
	end)

	gameEvents:WaitForChild("NightStarted").OnClientEvent:Connect(function(nightNumber)
		print("[SurvivalUI] Night " .. nightNumber .. " has started!")
		-- Play sound effect here
	end)

	gameEvents:WaitForChild("DayStarted").OnClientEvent:Connect(function(nightNumber)
		print("[SurvivalUI] Day " .. nightNumber .. " has started!")
		-- Play sound effect here
	end)

	-- Update loop for visual effects
	RunService.RenderStepped:Connect(function()
		updateStats() -- Keep bars updated with pulsing effects
	end)

	print("[SurvivalUI] UI initialized!")
end

-- Auto-initialize
SurvivalUI:Initialize()

return SurvivalUI
