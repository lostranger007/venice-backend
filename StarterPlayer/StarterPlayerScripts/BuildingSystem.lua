--[[
    BuildingSystem.lua
    Handles block placement, rotation, and welding
    Location: StarterPlayer > StarterPlayerScripts > BuildingSystem (LocalScript)
]]

print("[BuildingSystem] Starting...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local spawnFunc = ReplicatedStorage:WaitForChild("SpawnItem")

local BuildingSystem = {}
BuildingSystem.Enabled = false
BuildingSystem.CurrentBlock = nil
BuildingSystem.PreviewBlock = nil
BuildingSystem.Rotation = 0
BuildingSystem.GridSize = 1
BuildingSystem.MaxPlaceDistance = 50
BuildingSystem.DeleteModeEnabled = false  -- Toggle for delete mode

-- Create build plate
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

-- Create preview
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

    local selection = Instance.new("SelectionBox")
    selection.Adornee = preview
    selection.LineThickness = 0.05
    selection.Color3 = Color3.fromRGB(100, 255, 100)
    selection.Parent = preview

    preview.Parent = workspace
    BuildingSystem.PreviewBlock = preview
end

-- Snap to grid
function BuildingSystem:SnapToGrid(position)
    local g = BuildingSystem.GridSize
    return Vector3.new(
        math.floor(position.X / g + 0.5) * g,
        math.floor(position.Y / g + 0.5) * g,
        math.floor(position.Z / g + 0.5) * g
    )
end

-- Check valid placement
function BuildingSystem:IsValidPlacement(position)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local distance = (position - player.Character.HumanoidRootPart.Position).Magnitude
        if distance > BuildingSystem.MaxPlaceDistance then
            return false
        end
    end
    return true
end

-- Update preview
function BuildingSystem:UpdatePreview()
    if not BuildingSystem.Enabled or not BuildingSystem.PreviewBlock then
        return
    end

    local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {BuildingSystem.PreviewBlock, player.Character}

    local rayResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 500, raycastParams)

    if rayResult then
        local hitPos = rayResult.Position
        local normal = rayResult.Normal
        local offset = normal * (BuildingSystem.PreviewBlock.Size.Y / 2)
        local targetPos = BuildingSystem:SnapToGrid(hitPos + offset)

        local rotation = CFrame.Angles(0, math.rad(BuildingSystem.Rotation), 0)
        BuildingSystem.PreviewBlock.CFrame = CFrame.new(targetPos) * rotation

        local isValid = BuildingSystem:IsValidPlacement(targetPos)
        local selection = BuildingSystem.PreviewBlock:FindFirstChildOfClass("SelectionBox")
        if selection then
            selection.Color3 = isValid and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        end
        BuildingSystem.PreviewBlock.Color = isValid and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    else
        BuildingSystem.PreviewBlock.Position = Vector3.new(0, -1000, 0)
    end
end

-- Place block
function BuildingSystem:PlaceBlock()
    if not BuildingSystem.Enabled or not BuildingSystem.PreviewBlock or not BuildingSystem.CurrentBlock then
        return false
    end

    local position = BuildingSystem.PreviewBlock.Position
    if not BuildingSystem:IsValidPlacement(position) then
        print("[BuildingSystem] Invalid placement")
        return false
    end

    local targetCFrame = BuildingSystem.PreviewBlock.CFrame
    local result = spawnFunc:InvokeServer(BuildingSystem.CurrentBlock.Name, targetCFrame)

    if result.success then
        print("[BuildingSystem] Block placed:", BuildingSystem.CurrentBlock.Name)

        -- Weld nearby blocks (wait for block to exist in workspace)
        task.wait(0.2)
        BuildingSystem:WeldNearbyParts(targetCFrame.Position)

        return true
    else
        warn("[BuildingSystem] Failed to place:", result.message)
        return false
    end
end

-- Weld nearby parts together (called after placing a block)
function BuildingSystem:WeldNearbyParts(placedPosition)
    print("[BuildingSystem] Looking for parts to weld near", placedPosition)

    -- Find the block we just placed
    local placedBlock = nil
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and
           part:GetAttribute("IsJetPart") and
           part:GetAttribute("Owner") == player.UserId then
            local distance = (part.Position - placedPosition).Magnitude
            if distance < 1 then  -- Very close = the block we just placed
                placedBlock = part
                break
            end
        end
    end

    if not placedBlock then
        warn("[BuildingSystem] Couldn't find placed block to weld!")
        return
    end

    print("[BuildingSystem] Found placed block:", placedBlock.Name)

    -- Now weld it to all nearby jet parts
    local weldCount = 0
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and
           part ~= placedBlock and
           part:GetAttribute("IsJetPart") and
           part:GetAttribute("Owner") == player.UserId then

            local distance = (part.Position - placedBlock.Position).Magnitude
            if distance < 15 then  -- Increased from 10 to 15 studs
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = placedBlock
                weld.Part1 = part
                weld.Parent = placedBlock
                weldCount = weldCount + 1
                print("[BuildingSystem] Welded", placedBlock.Name, "to", part.Name, "distance:", math.floor(distance))
            end
        end
    end

    print("[BuildingSystem] Created", weldCount, "welds")
end

-- Delete block
function BuildingSystem:DeleteBlock()
    local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character, BuildingSystem.PreviewBlock}

    local rayResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 500, raycastParams)

    if rayResult and rayResult.Instance then
        local hitPart = rayResult.Instance
        if hitPart:GetAttribute("IsJetPart") and
           hitPart:GetAttribute("Owner") == player.UserId then
            hitPart:Destroy()
            print("[BuildingSystem] Deleted block")
            return true
        end
    end

    return false
end

-- Start building
function BuildingSystem:StartBuilding(itemData)
    BuildingSystem.Enabled = true
    BuildingSystem.CurrentBlock = itemData
    BuildingSystem:CreatePreview(itemData)
    print("[BuildingSystem] Started building with:", itemData.Name)
end

-- Stop building
function BuildingSystem:StopBuilding()
    BuildingSystem.Enabled = false
    BuildingSystem.CurrentBlock = nil
    BuildingSystem.Rotation = 0

    if BuildingSystem.PreviewBlock then
        BuildingSystem.PreviewBlock:Destroy()
        BuildingSystem.PreviewBlock = nil
    end

    print("[BuildingSystem] Stopped building")
end

-- Input handling
mouse.Button1Down:Connect(function()
    if BuildingSystem.DeleteModeEnabled then
        -- Delete mode - clicking deletes blocks
        BuildingSystem:DeleteBlock()
    elseif BuildingSystem.Enabled then
        -- Build mode - clicking places blocks
        BuildingSystem:PlaceBlock()
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.R then
        if BuildingSystem.Enabled then
            BuildingSystem.Rotation = (BuildingSystem.Rotation + 90) % 360
            print("[BuildingSystem] Rotated to:", BuildingSystem.Rotation)
        end
    elseif input.KeyCode == Enum.KeyCode.X then
        BuildingSystem:DeleteBlock()
    elseif input.KeyCode == Enum.KeyCode.Escape then
        if BuildingSystem.Enabled then
            BuildingSystem:StopBuilding()
        end
    end
end)

-- Update loop
RunService.RenderStepped:Connect(function()
    if BuildingSystem.Enabled then
        BuildingSystem:UpdatePreview()
    end
end)

print("[BuildingSystem] Initialized")
print("[BuildingSystem] Controls: Click=Place, R=Rotate, X=Delete, ESC=Cancel")

-- Export globally
_G.BuildingSystem = BuildingSystem

return BuildingSystem
