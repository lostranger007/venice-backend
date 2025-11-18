--[[
	WorkspaceSetup.lua
	Sets up the forest environment for 99 Nights in the Forest
	Creates terrain, trees, rocks, and resource nodes
]]

local workspace = game:GetService("Workspace")

print("[WorkspaceSetup] Creating forest environment...")

-- Create ground (large grass area)
local ground = Instance.new("Part")
ground.Name = "Ground"
ground.Size = Vector3.new(500, 2, 500)
ground.Position = Vector3.new(0, -1, 0)
ground.Anchored = true
ground.Color = Color3.fromRGB(90, 130, 60)
ground.Material = Enum.Material.Grass
ground.TopSurface = Enum.SurfaceType.Smooth
ground.BottomSurface = Enum.SurfaceType.Smooth
ground.Locked = true
ground.Parent = workspace

-- Create spawn location
local spawnLocation = Instance.new("SpawnLocation")
spawnLocation.Name = "SpawnLocation"
spawnLocation.Size = Vector3.new(8, 1, 8)
spawnLocation.Position = Vector3.new(0, 1, 0)
spawnLocation.Anchored = true
spawnLocation.CanCollide = true
spawnLocation.Transparency = 0.5
spawnLocation.BrickColor = BrickColor.new("Bright green")
spawnLocation.TopSurface = Enum.SurfaceType.Smooth
spawnLocation.BottomSurface = Enum.SurfaceType.Smooth
spawnLocation.Locked = true
spawnLocation.Parent = workspace

-- Helper function to create a tree
local function createTree(position)
	local tree = Instance.new("Model")
	tree.Name = "Tree"

	-- Trunk
	local trunk = Instance.new("Part")
	trunk.Name = "Trunk"
	trunk.Size = Vector3.new(3, 15, 3)
	trunk.Position = position + Vector3.new(0, 7.5, 0)
	trunk.Anchored = true
	trunk.Color = Color3.fromRGB(100, 70, 40)
	trunk.Material = Enum.Material.Wood
	trunk.Parent = tree

	-- Leaves (multiple parts for fuller look)
	for i = 1, 3 do
		local leaves = Instance.new("Part")
		leaves.Name = "Leaves" .. i
		leaves.Size = Vector3.new(12, 8, 12)
		leaves.Position = position + Vector3.new(0, 15 + (i * 3), 0)
		leaves.Anchored = true
		leaves.Color = Color3.fromRGB(50, 120, 50)
		leaves.Material = Enum.Material.Grass
		leaves.Shape = Enum.PartType.Ball
		leaves.Parent = tree
	end

	-- Add ProximityPrompt for chopping
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Chop Tree"
	prompt.ObjectText = "Tree"
	prompt.MaxActivationDistance = 10
	prompt.HoldDuration = 2
	prompt.Parent = trunk

	-- Tag for resource system
	trunk:SetAttribute("ResourceType", "Wood")
	trunk:SetAttribute("ResourceAmount", 10)

	tree.Parent = workspace
	return tree
end

-- Helper function to create a rock
local function createRock(position)
	local rock = Instance.new("Part")
	rock.Name = "Rock"
	rock.Size = Vector3.new(
		math.random(4, 7),
		math.random(3, 5),
		math.random(4, 7)
	)
	rock.Position = position
	rock.Anchored = true
	rock.Color = Color3.fromRGB(120, 120, 120)
	rock.Material = Enum.Material.Slate
	rock.Parent = workspace

	-- Add ProximityPrompt for mining
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Mine Rock"
	prompt.ObjectText = "Rock"
	prompt.MaxActivationDistance = 8
	prompt.HoldDuration = 2
	prompt.Parent = rock

	-- Tag for resource system
	rock:SetAttribute("ResourceType", "Stone")
	rock:SetAttribute("ResourceAmount", 5)

	return rock
end

-- Helper function to create berry bush
local function createBerryBush(position)
	local bush = Instance.new("Part")
	bush.Name = "BerryBush"
	bush.Size = Vector3.new(4, 3, 4)
	bush.Position = position
	bush.Anchored = true
	bush.Color = Color3.fromRGB(70, 140, 70)
	bush.Material = Enum.Material.Grass
	bush.Shape = Enum.PartType.Ball
	bush.Parent = workspace

	-- Berries (small red spheres)
	for i = 1, 5 do
		local berry = Instance.new("Part")
		berry.Name = "Berry"
		berry.Size = Vector3.new(0.5, 0.5, 0.5)
		berry.Position = position + Vector3.new(
			math.random(-2, 2),
			math.random(-1, 1),
			math.random(-2, 2)
		)
		berry.Anchored = true
		berry.Color = Color3.fromRGB(200, 30, 30)
		berry.Material = Enum.Material.SmoothPlastic
		berry.Shape = Enum.PartType.Ball
		berry.Parent = bush
	end

	-- Add ProximityPrompt for gathering
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Gather Berries"
	prompt.ObjectText = "Berry Bush"
	prompt.MaxActivationDistance = 8
	prompt.HoldDuration = 1
	prompt.Parent = bush

	-- Tag for resource system
	bush:SetAttribute("ResourceType", "Berries")
	bush:SetAttribute("ResourceAmount", 5)

	return bush
end

-- Generate forest around spawn (avoiding campfire area)
print("[WorkspaceSetup] Generating trees...")
local treeCount = 0
for x = -200, 200, 20 do
	for z = -200, 200, 20 do
		-- Skip area near spawn (for campfire)
		if math.abs(x) > 30 or math.abs(z) > 30 then
			-- Random placement with some variation
			if math.random() > 0.3 then -- 70% chance for tree
				local randomOffset = Vector3.new(
					math.random(-8, 8),
					0,
					math.random(-8, 8)
				)
				createTree(Vector3.new(x, 0, z) + randomOffset)
				treeCount = treeCount + 1
			end
		end
	end
end
print("[WorkspaceSetup] Created " .. treeCount .. " trees")

-- Generate rocks
print("[WorkspaceSetup] Generating rocks...")
local rockCount = 0
for i = 1, 30 do
	local randomPos = Vector3.new(
		math.random(-200, 200),
		2,
		math.random(-200, 200)
	)
	-- Skip area near spawn
	if math.abs(randomPos.X) > 30 or math.abs(randomPos.Z) > 30 then
		createRock(randomPos)
		rockCount = rockCount + 1
	end
end
print("[WorkspaceSetup] Created " .. rockCount .. " rocks")

-- Generate berry bushes
print("[WorkspaceSetup] Generating berry bushes...")
local bushCount = 0
for i = 1, 20 do
	local randomPos = Vector3.new(
		math.random(-150, 150),
		1.5,
		math.random(-150, 150)
	)
	-- Skip area near spawn
	if math.abs(randomPos.X) > 30 or math.abs(randomPos.Z) > 30 then
		createBerryBush(randomPos)
		bushCount = bushCount + 1
	end
end
print("[WorkspaceSetup] Created " .. bushCount .. " berry bushes")

-- Add fog for atmosphere
local atmosphere = workspace:FindFirstChildOfClass("Atmosphere")
if not atmosphere then
	atmosphere = Instance.new("Atmosphere")
	atmosphere.Parent = workspace
end
atmosphere.Density = 0.4
atmosphere.Offset = 0.5
atmosphere.Color = Color3.fromRGB(199, 199, 199)
atmosphere.Decay = Color3.fromRGB(106, 112, 125)
atmosphere.Glare = 0.3
atmosphere.Haze = 2

-- Add welcome message
local message = Instance.new("Message")
message.Text = "Welcome to 99 Nights in the Forest! Survive 99 nights..."
message.Parent = workspace
task.wait(5)
message:Destroy()

print("[WorkspaceSetup] Forest environment created successfully!")
print("[WorkspaceSetup] Spawn location at (0, 1, 0)")
print("[WorkspaceSetup] Campfire will be placed nearby")
