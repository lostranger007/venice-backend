--[[
	GameConfig.lua
	Central configuration for 99 Nights in the Forest game
	Contains all game constants and settings
]]

local GameConfig = {}

-- GAME PROGRESSION
GameConfig.TOTAL_NIGHTS_REQUIRED = 99
GameConfig.NIGHTS_REDUCED_PER_CHILD = 20 -- Each rescued child reduces nights needed

-- DAY/NIGHT CYCLE
GameConfig.DAY_LENGTH_SECONDS = 300 -- 5 minutes of daytime
GameConfig.NIGHT_LENGTH_SECONDS = 240 -- 4 minutes of nighttime
GameConfig.DUSK_WARNING_SECONDS = 30 -- Warning before night starts

-- Time of day values (0-24)
GameConfig.SUNRISE_TIME = 6
GameConfig.SUNSET_TIME = 18
GameConfig.MIDNIGHT_TIME = 0

-- CAMPFIRE SYSTEM
GameConfig.CAMPFIRE_MAX_FUEL = 100
GameConfig.CAMPFIRE_FUEL_DRAIN_PER_SECOND = 0.5 -- Drains during night
GameConfig.CAMPFIRE_HEAL_RATE = 2 -- HP healed per second near campfire
GameConfig.CAMPFIRE_HEAL_RADIUS = 15 -- Distance from campfire for healing
GameConfig.WOOD_FUEL_AMOUNT = 20 -- Fuel gained per wood added

-- PLAYER STATS
GameConfig.PLAYER_MAX_HEALTH = 100
GameConfig.PLAYER_MAX_HUNGER = 100
GameConfig.PLAYER_MAX_SANITY = 100
GameConfig.PLAYER_MAX_TEMPERATURE = 100

-- Stat drain rates
GameConfig.HUNGER_DRAIN_PER_SECOND = 0.1
GameConfig.SANITY_DRAIN_NIGHT = 0.3 -- Per second during night
GameConfig.SANITY_DRAIN_NEAR_ENEMY = 0.5 -- Additional drain near enemies
GameConfig.TEMPERATURE_DRAIN_SNOW_BIOME = 0.4 -- Per second in snow biome

-- Stat effects
GameConfig.HUNGER_DAMAGE_THRESHOLD = 20 -- Start taking damage below this hunger
GameConfig.HUNGER_DAMAGE_PER_SECOND = 1
GameConfig.LOW_SANITY_THRESHOLD = 30 -- Visual effects trigger below this
GameConfig.FREEZING_THRESHOLD = 20 -- Start taking damage below this temp
GameConfig.FREEZING_DAMAGE_PER_SECOND = 2

-- RESOURCES
GameConfig.WOOD_PER_TREE = 10
GameConfig.STONE_PER_ROCK = 5
GameConfig.BERRIES_HUNGER_RESTORE = 10
GameConfig.COOKED_MEAT_HUNGER_RESTORE = 30
GameConfig.RAW_MEAT_HUNGER_RESTORE = 15

-- ENEMIES
GameConfig.THE_DEER = {
	Health = 200,
	Damage = 25,
	Speed = 20,
	DetectionRange = 60,
	AttackRange = 5,
	SpawnChance = 0.8, -- 80% chance to spawn each night
	JumpscareRange = 10
}

GameConfig.CULTIST = {
	Health = 80,
	Damage = 15,
	Speed = 16,
	DetectionRange = 50,
	AttackRange = 8,
	SpawnChance = 0.6
}

GameConfig.WOLF = {
	Health = 60,
	Damage = 20,
	Speed = 22,
	DetectionRange = 40,
	AttackRange = 5,
	PackSize = 3 -- Wolves spawn in packs
}

GameConfig.BEAR = {
	Health = 300,
	Damage = 40,
	Speed = 14,
	DetectionRange = 30,
	AttackRange = 6,
	SpawnChance = 0.2 -- Rare spawn
}

-- WEAPONS
GameConfig.WEAPONS = {
	Axe = {
		Damage = 15,
		Range = 5,
		Cooldown = 1.0
	},
	Spear = {
		Damage = 25,
		Range = 7,
		Cooldown = 1.5
	},
	Bow = {
		Damage = 30,
		Range = 100,
		Cooldown = 2.0,
		AmmoType = "Arrow"
	},
	Pistol = {
		Damage = 40,
		Range = 150,
		Cooldown = 0.8,
		AmmoType = "Bullet"
	},
	Rifle = {
		Damage = 60,
		Range = 200,
		Cooldown = 1.2,
		AmmoType = "Bullet"
	}
}

-- BIOMES
GameConfig.BIOMES = {
	Forest = {
		TemperatureDrain = 0,
		DangerLevel = 1
	},
	Volcanic = {
		TemperatureDrain = -0.3, -- Actually increases temp (negative drain)
		DangerLevel = 3,
		DamagePerSecond = 5 -- Lava damage
	},
	Snow = {
		TemperatureDrain = 0.4,
		DangerLevel = 2
	}
}

-- MISSING CHILDREN
GameConfig.CHILDREN_LOCATIONS = 4 -- 4 children to rescue
GameConfig.CHILD_DETECTION_RANGE = 20
GameConfig.CHILD_RESCUE_RADIUS = 5

-- DIFFICULTY SCALING
GameConfig.DIFFICULTY_MULTIPLIER_PER_PLAYER = 1.3
GameConfig.MAX_PLAYERS = 5

-- UI COLORS
GameConfig.UI_COLORS = {
	Health = Color3.fromRGB(255, 50, 50),
	Hunger = Color3.fromRGB(255, 165, 0),
	Sanity = Color3.fromRGB(100, 100, 255),
	Temperature = Color3.fromRGB(0, 200, 255),
	Fuel = Color3.fromRGB(255, 200, 0)
}

-- SPAWN SETTINGS
GameConfig.ENEMY_SPAWN_DISTANCE_MIN = 50 -- Min distance from campfire
GameConfig.ENEMY_SPAWN_DISTANCE_MAX = 100 -- Max distance from campfire
GameConfig.MAX_ENEMIES_AT_ONCE = 10

-- LIGHTING SETTINGS
GameConfig.DAY_BRIGHTNESS = 2
GameConfig.NIGHT_BRIGHTNESS = 0.1
GameConfig.DAY_AMBIENT = Color3.fromRGB(150, 150, 150)
GameConfig.NIGHT_AMBIENT = Color3.fromRGB(10, 10, 20)

return GameConfig
