-- WorkspaceSetup.lua
-- Sets up the build plate and workspace environment

local workspace = game:GetService("Workspace")

-- Clear workspace (optional - remove if you want to keep existing objects)
-- for _, obj in ipairs(workspace:GetChildren()) do
-- 	if not obj:IsA("Terrain") and not obj:IsA("Camera") then
-- 		obj:Destroy()
-- 	end
-- end

-- Create build plate
local buildPlate = Instance.new("Part")
buildPlate.Name = "BuildPlate"
buildPlate.Size = Vector3.new(200, 1, 200)
buildPlate.Position = Vector3.new(0, 0, 0)
buildPlate.Anchored = true
buildPlate.Color = Color3.fromRGB(100, 200, 100)
buildPlate.Material = Enum.Material.Grass
buildPlate.TopSurface = Enum.SurfaceType.Smooth
buildPlate.BottomSurface = Enum.SurfaceType.Smooth
buildPlate.Locked = true
buildPlate.Parent = workspace

-- Add grid texture to build plate for visual reference
local texture = Instance.new("Texture")
texture.Texture = "rbxasset://textures/GridTexture.png"
texture.StudsPerTileU = 4
texture.StudsPerTileV = 4
texture.Transparency = 0.7
texture.Face = Enum.NormalId.Top
texture.Parent = buildPlate

-- Create spawn location
local spawnLocation = Instance.new("SpawnLocation")
spawnLocation.Size = Vector3.new(6, 1, 6)
spawnLocation.Position = Vector3.new(0, 1, 0)
spawnLocation.Anchored = true
spawnLocation.CanCollide = true
spawnLocation.Transparency = 0.5
spawnLocation.BrickColor = BrickColor.new("Bright green")
spawnLocation.TopSurface = Enum.SurfaceType.Smooth
spawnLocation.BottomSurface = Enum.SurfaceType.Smooth
spawnLocation.Locked = true
spawnLocation.Parent = workspace

-- Add welcome message
local message = Instance.new("Message")
message.Text = "Welcome to Base Building! Press B to open the build menu."
message.Parent = workspace
wait(5)
message:Destroy()

-- Configure lighting for better visibility
local lighting = game:GetService("Lighting")
lighting.Brightness = 2
lighting.Ambient = Color3.fromRGB(150, 150, 150)
lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
lighting.TimeOfDay = "14:00:00"

print("Workspace setup complete!")
print("Build plate created at (0, 0, 0)")
print("Press B to open the build menu")
