--[[
    BuildingSystem.lua
    Handles block placement, rotation, and welding
    Place in: StarterPlayer > StarterPlayerScripts (as a LocalScript)
]]

print("=== BuildingSystem Starting ===")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local BuildingSystem = {}

-- Building settings
BuildingSystem.Enabled = false
BuildingSystem.CurrentBlock = nil
BuildingSystem.PreviewBlock = nil
BuildingSystem.Rotation = 0  -- Current rotation in degrees (0, 90, 180, 270)
BuildingSystem.GridSize = 1  -- Snap to grid
BuildingSystem.MaxPlaceDistance = 50  -- How far you can place blocks
BuildingSystem.BuildPlate = nil  -- Reference to build area

-- Colors
local PREVIEW_COLOR_VALID = Color3.fromRGB(100, 255, 100)
local PREVIEW_COLOR_INVALID = Color3.fromRGB(255, 100, 100)

-- Create build plate (the area where players can build)
function BuildingSystem:CreateBuildPlate()
    local buildPlate = Instance.new("Part")
    buildPlate.Name = "BuildPlate"
    buildPlate.Size = Vector3.new(100, 1, 100)
    buildPlate.Position = Vector3.new(0, 0, 0)
    buildPlate.Anchored = true
    buildPlate.BrickColor = BrickColor.new("Dark green")
    buildPlate.Material = Enum.Material.Grass
    buildPlate.TopSurface = Enum.SurfaceType.Smooth
    buildPlate.BottomSurface = Enum.SurfaceType.Smooth
    buildPlate.Parent = workspace

    BuildingSystem.BuildPlate = buildPlate
    print("Build plate created")
end

-- Create a preview block (ghost block that follows mouse)
function BuildingSystem:CreatePreview(itemData)
    if BuildingSystem.PreviewBlock then
        BuildingSystem.PreviewBlock:Destroy()
    end

    local preview = Instance.new("Part")
    preview.Name = "PreviewBlock"
    preview.Size = itemData.Size
    preview.Color = itemData.Color
    preview.Material = Enum.Material.Neon
    preview.Transparency = 0.5
    preview.CanCollide = false
    preview.Anchored = true
    preview.TopSurface = Enum.SurfaceType.Smooth
    preview.BottomSurface = Enum.SurfaceType.Smooth

    -- Add outline
    local selection = Instance.new("SelectionBox")
    selection.Adornee = preview
    selection.LineThickness = 0.05
    selection.Color3 = PREVIEW_COLOR_VALID
    selection.Parent = preview

    preview.Parent = workspace
    BuildingSystem.PreviewBlock = preview

    return preview
end

-- Round position to grid
function BuildingSystem:SnapToGrid(position)
    local gridSize = BuildingSystem.GridSize
    return Vector3.new(
        math.floor(position.X / gridSize + 0.5) * gridSize,
        math.floor(position.Y / gridSize + 0.5) * gridSize,
        math.floor(position.Z / gridSize + 0.5) * gridSize
    )
end

-- Check if position is valid for placement
function BuildingSystem:IsValidPlacement(position, size)
    -- Check if too far from player
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local distance = (position - player.Character.HumanoidRootPart.Position).Magnitude
        if distance > BuildingSystem.MaxPlaceDistance then
            return false
        end
    end

    -- Check if overlapping with other parts
    local region = Region3.new(
        position - size/2,
        position + size/2
    ):ExpandToGrid(4)

    local parts = workspace:FindPartsInRegion3(region, nil, 100)

    for _, part in ipairs(parts) do
        -- Ignore preview block and build plate
        if part ~= BuildingSystem.PreviewBlock and
           part ~= BuildingSystem.BuildPlate and
           part.Name ~= "Terrain" then
            -- Check if it's another player's block
            if not part:GetAttribute("IsHovercraftPart") then
                return false
            end
        end
    end

    return true
end

-- Update preview block position and rotation
function BuildingSystem:UpdatePreview()
    if not BuildingSystem.Enabled or not BuildingSystem.PreviewBlock then
        return
    end

    -- Raycast from mouse to find placement position
    local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {BuildingSystem.PreviewBlock, player.Character}

    local rayResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 500, raycastParams)

    if rayResult then
        local hitPosition = rayResult.Position
        local normal = rayResult.Normal

        -- Place block on top of surface
        local blockSize = BuildingSystem.PreviewBlock.Size
        local offset = normal * (blockSize.Y / 2)
        local targetPosition = hitPosition + offset

        -- Snap to grid
        targetPosition = BuildingSystem:SnapToGrid(targetPosition)

        -- Apply rotation
        local rotation = CFrame.Angles(0, math.rad(BuildingSystem.Rotation), 0)
        BuildingSystem.PreviewBlock.CFrame = CFrame.new(targetPosition) * rotation

        -- Check if valid placement
        local isValid = BuildingSystem:IsValidPlacement(targetPosition, blockSize)

        -- Update color
        local selectionBox = BuildingSystem.PreviewBlock:FindFirstChildOfClass("SelectionBox")
        if selectionBox then
            selectionBox.Color3 = isValid and PREVIEW_COLOR_VALID or PREVIEW_COLOR_INVALID
        end

        BuildingSystem.PreviewBlock.Color = isValid and PREVIEW_COLOR_VALID or PREVIEW_COLOR_INVALID
    else
        -- No surface found, hide preview far away
        BuildingSystem.PreviewBlock.Position = Vector3.new(0, -1000, 0)
    end
end

-- Rotate preview block
function BuildingSystem:Rotate(degrees)
    BuildingSystem.Rotation = (BuildingSystem.Rotation + degrees) % 360
    print("Rotated to:", BuildingSystem.Rotation, "degrees")
end

-- Place the current block
function BuildingSystem:PlaceBlock()
    if not BuildingSystem.Enabled or not BuildingSystem.PreviewBlock or not BuildingSystem.CurrentBlock then
        return false
    end

    local position = BuildingSystem.PreviewBlock.Position
    local size = BuildingSystem.PreviewBlock.Size

    -- Check if valid
    if not BuildingSystem:IsValidPlacement(position, size) then
        print("Invalid placement!")
        return false
    end

    -- Request server to spawn the block at the preview position
    local spawnFunc = ReplicatedStorage:FindFirstChild("SpawnItem")
    if spawnFunc then
        local targetCFrame = BuildingSystem.PreviewBlock.CFrame

        local success, result = pcall(function()
            return spawnFunc:InvokeServer(BuildingSystem.CurrentBlock.Name, targetCFrame)
        end)

        if success and result.success then
            -- Wait a frame for the block to be created
            task.wait(0.1)

            -- Find the newly created block and weld it
            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and
                   part:GetAttribute("IsHovercraftPart") and
                   part:GetAttribute("Owner") == player.UserId and
                   (part.Position - position).Magnitude < 5 then
                    -- Weld to nearby blocks
                    BuildingSystem:WeldToNearbyBlocks(part)
                    break
                end
            end

            print("Block placed:", BuildingSystem.CurrentBlock.Name)
            return true
        else
            warn("Failed to place block:", result and result.message or "Unknown error")
        end
    end

    return false
end

-- Weld block to nearby blocks
function BuildingSystem:WeldToNearbyBlocks(block)
    if not block or not block.Parent then return end

    local searchRadius = 10
    local nearbyParts = {}

    -- Find nearby parts
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and
           part ~= block and
           part:GetAttribute("IsHovercraftPart") and
           part:GetAttribute("Owner") == player.UserId then

            local distance = (part.Position - block.Position).Magnitude
            if distance < searchRadius then
                table.insert(nearbyParts, part)
            end
        end
    end

    -- Weld to nearby parts
    for _, nearbyPart in ipairs(nearbyParts) do
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = block
        weld.Part1 = nearbyPart
        weld.Parent = block

        print("Welded", block.Name, "to", nearbyPart.Name)
    end
end

-- Delete block under mouse
function BuildingSystem:DeleteBlock()
    local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character, BuildingSystem.PreviewBlock}

    local rayResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 500, raycastParams)

    if rayResult and rayResult.Instance then
        local hitPart = rayResult.Instance

        -- Check if it's a hovercraft part owned by the player
        if hitPart:GetAttribute("IsHovercraftPart") and
           hitPart:GetAttribute("Owner") == player.UserId then
            hitPart:Destroy()
            print("Deleted block:", hitPart.Name)
            return true
        end
    end

    return false
end

-- Start building mode with a specific block
function BuildingSystem:StartBuilding(itemData)
    BuildingSystem.Enabled = true
    BuildingSystem.CurrentBlock = itemData
    BuildingSystem:CreatePreview(itemData)

    print("Building mode started with:", itemData.Name)
end

-- Stop building mode
function BuildingSystem:StopBuilding()
    BuildingSystem.Enabled = false
    BuildingSystem.CurrentBlock = nil
    BuildingSystem.Rotation = 0

    if BuildingSystem.PreviewBlock then
        BuildingSystem.PreviewBlock:Destroy()
        BuildingSystem.PreviewBlock = nil
    end

    print("Building mode stopped")
end

-- Handle input
function BuildingSystem:SetupInput()
    -- Mouse click to place
    mouse.Button1Down:Connect(function()
        if BuildingSystem.Enabled then
            BuildingSystem:PlaceBlock()
        end
    end)

    -- Keyboard controls
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        -- R to rotate clockwise
        if input.KeyCode == Enum.KeyCode.R then
            if BuildingSystem.Enabled then
                BuildingSystem:Rotate(90)
            end
        end

        -- E to rotate counter-clockwise
        if input.KeyCode == Enum.KeyCode.E then
            if BuildingSystem.Enabled then
                BuildingSystem:Rotate(-90)
            end
        end

        -- X to delete block
        if input.KeyCode == Enum.KeyCode.X then
            BuildingSystem:DeleteBlock()
        end

        -- Escape to cancel building
        if input.KeyCode == Enum.KeyCode.Escape then
            if BuildingSystem.Enabled then
                BuildingSystem:StopBuilding()
            end
        end
    end)
end

-- Update loop
RunService.RenderStepped:Connect(function()
    if BuildingSystem.Enabled then
        BuildingSystem:UpdatePreview()
    end
end)

-- Initialize
BuildingSystem:CreateBuildPlate()
BuildingSystem:SetupInput()

print("=== BuildingSystem Initialized ===")
print("Controls:")
print("  - Click to place block")
print("  - R to rotate clockwise")
print("  - E to rotate counter-clockwise")
print("  - X to delete block under mouse")
print("  - ESC to cancel building")

-- Export for use by other scripts
_G.BuildingSystem = BuildingSystem

return BuildingSystem
