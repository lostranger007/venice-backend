--[[
	GameController.lua
	Main game controller - initializes all game systems
	This is the entry point for the server-side game logic
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

print("===========================================")
print("  99 NIGHTS IN THE FOREST - GAME START")
print("===========================================")

-- Wait for all modules to load
local GameConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameConfig"))
local DayNightCycle = require(ServerScriptService:WaitForChild("DayNightCycle"))
local CampfireSystem = require(ServerScriptService:WaitForChild("CampfireSystem"))
local PlayerStatsSystem = require(ServerScriptService:WaitForChild("PlayerStatsSystem"))
local ResourceSystem = require(ServerScriptService:WaitForChild("ResourceSystem"))

local GameController = {}

function GameController:Initialize()
	print("[GameController] Initializing game systems...")

	-- Initialize resource system first (needed by other systems)
	ResourceSystem:Initialize()
	task.wait(0.5)

	-- Initialize day/night cycle
	DayNightCycle:Initialize()
	task.wait(0.5)

	-- Initialize campfire system (needs resource system)
	CampfireSystem:Initialize(ResourceSystem)
	task.wait(0.5)

	-- Initialize player stats system (needs campfire system)
	PlayerStatsSystem:Initialize(CampfireSystem)
	task.wait(0.5)

	print("[GameController] All systems initialized successfully!")
	print("[GameController] Game is ready to play!")
	print("===========================================")
end

-- Start the game
GameController:Initialize()

return GameController
