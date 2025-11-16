--[[
    CourseBuilder.lua
    Creates obstacle course automatically
    Location: ServerScriptService > CourseBuilder (Script)
]]

print("[CourseBuilder] Starting...")

local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local CollectibleManager = require(ServerScriptService:WaitForChild("CollectibleManager"))

local CourseBuilder = {}

-- Create start platform
function CourseBuilder:CreateStartPlatform()
    local start = Instance.new("Part")
    start.Name = "StartPlatform"
    start.Size = Vector3.new(60, 2, 60)
    start.Position = Vector3.new(0, 20, 0)
    start.Anchored = true
    start.BrickColor = BrickColor.new("Bright blue")
    start.Material = Enum.Material.SmoothPlastic
    start.Parent = workspace

    -- Start sign
    local sign = Instance.new("Part")
    sign.Size = Vector3.new(40, 15, 2)
    sign.Position = start.Position + Vector3.new(0, 10, -25)
    sign.Anchored = true
    sign.BrickColor = BrickColor.new("Bright green")
    sign.Material = Enum.Material.Neon
    sign.Parent = workspace

    local label = Instance.new("SurfaceGui")
    label.Face = Enum.NormalId.Front
    label.Parent = sign

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "START"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 100
    text.Font = Enum.Font.GothamBold
    text.Parent = label

    print("[CourseBuilder] Created start platform")
    return start
end

-- Create spinning obstacle
function CourseBuilder:CreateSpinningWall(position)
    local base = Instance.new("Part")
    base.Size = Vector3.new(2, 2, 2)
    base.Position = position
    base.Anchored = true
    base.Transparency = 1
    base.CanCollide = false
    base.Parent = workspace

    -- Four spinning arms
    for i = 1, 4 do
        local arm = Instance.new("Part")
        arm.Size = Vector3.new(30, 3, 3)
        arm.Position = position
        arm.Anchored = false
        arm.BrickColor = BrickColor.new("Really red")
        arm.Material = Enum.Material.SmoothPlastic
        arm.Parent = workspace

        -- Weld to base
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = base
        weld.Part1 = arm
        weld.Parent = arm

        -- Position arm
        arm.CFrame = base.CFrame * CFrame.Angles(0, math.rad(90 * (i-1)), 0)
    end

    -- Spin it
    RunService.Heartbeat:Connect(function()
        base.CFrame = base.CFrame * CFrame.Angles(0, math.rad(1), 0)
    end)

    return base
end

-- Create moving platform
function CourseBuilder:CreateMovingPlatform(startPos, endPos, speed)
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(20, 2, 20)
    platform.Position = startPos
    platform.Anchored = true
    platform.BrickColor = BrickColor.new("Dark stone grey")
    platform.Material = Enum.Material.Slate
    platform.Parent = workspace

    -- Movement
    local moving = true
    local direction = 1

    task.spawn(function()
        while moving do
            local currentPos = platform.Position
            local targetPos = direction == 1 and endPos or startPos

            platform.Position = currentPos:Lerp(targetPos, speed or 0.01)

            if (platform.Position - targetPos).Magnitude < 1 then
                direction = direction * -1
                task.wait(1)
            end

            task.wait()
        end
    end)

    return platform
end

-- Create ring to fly through
function CourseBuilder:CreateRing(position, rotation)
    local ring = Instance.new("Part")
    ring.Name = "Ring"
    ring.Size = Vector3.new(25, 25, 2)
    ring.Position = position
    ring.Anchored = true
    ring.CanCollide = false
    ring.BrickColor = BrickColor.new("Bright blue")
    ring.Material = Enum.Material.Neon
    ring.Transparency = 0.5
    ring.Shape = Enum.PartType.Cylinder
    ring.Orientation = rotation or Vector3.new(0, 0, 90)
    ring.Parent = workspace

    -- Make it glow
    local light = Instance.new("PointLight")
    light.Brightness = 3
    light.Color = Color3.fromRGB(0, 150, 255)
    light.Range = 30
    light.Parent = ring

    -- Center hole
    local hole = Instance.new("Part")
    hole.Size = Vector3.new(15, 15, 3)
    hole.Position = position
    hole.Anchored = true
    hole.CanCollide = false
    hole.Transparency = 1
    hole.Shape = Enum.PartType.Cylinder
    hole.Orientation = rotation or Vector3.new(0, 0, 90)
    hole.Parent = ring

    return ring
end

-- Create wall with gap
function CourseBuilder:CreateWallGap(position, gapPosition)
    local width = 60
    local height = 30
    local gapSize = 15

    -- Left wall
    local leftWall = Instance.new("Part")
    leftWall.Size = Vector3.new((width - gapSize) / 2, height, 3)
    leftWall.Position = position + Vector3.new(-gapSize/2 - (width - gapSize)/4, 0, 0)
    leftWall.Anchored = true
    leftWall.BrickColor = BrickColor.new("Medium stone grey")
    leftWall.Material = Enum.Material.Brick
    leftWall.Parent = workspace

    -- Right wall
    local rightWall = Instance.new("Part")
    rightWall.Size = Vector3.new((width - gapSize) / 2, height, 3)
    rightWall.Position = position + Vector3.new(gapSize/2 + (width - gapSize)/4, 0, 0)
    rightWall.Anchored = true
    rightWall.BrickColor = BrickColor.new("Medium stone grey")
    rightWall.Material = Enum.Material.Brick
    rightWall.Parent = workspace

    return {leftWall, rightWall}
end

-- Build the complete course
function CourseBuilder:BuildCourse()
    print("[CourseBuilder] Building obstacle course...")

    -- Start platform
    self:CreateStartPlatform()

    local courseLength = 500
    local currentZ = 50

    -- Section 1: Easy rings with coins
    for i = 1, 5 do
        local pos = Vector3.new(math.random(-10, 10), 30, currentZ)
        self:CreateRing(pos, Vector3.new(0, 0, 90))
        CollectibleManager:CreateCoin(pos, 100)
        currentZ = currentZ + 40
    end

    -- Section 2: Spinning obstacles
    for i = 1, 3 do
        local pos = Vector3.new(0, 30, currentZ)
        self:CreateSpinningWall(pos)
        CollectibleManager:CreateCoin(pos + Vector3.new(20, 0, 0), 200)
        currentZ = currentZ + 50
    end

    -- Section 3: Wall gaps
    for i = 1, 4 do
        local pos = Vector3.new(math.random(-5, 5), 30, currentZ)
        self:CreateWallGap(pos)
        CollectibleManager:CreateCoin(pos + Vector3.new(0, 0, 5), 150)
        currentZ = currentZ + 45
    end

    -- Section 4: Moving platforms
    for i = 1, 3 do
        local startPos = Vector3.new(-20, 25, currentZ)
        local endPos = Vector3.new(20, 25, currentZ)
        self:CreateMovingPlatform(startPos, endPos, 0.02)
        CollectibleManager:CreateCoin(Vector3.new(0, 30, currentZ), 250)
        currentZ = currentZ + 50
    end

    -- Section 5: Challenging rings
    for i = 1, 3 do
        local pos = Vector3.new(math.random(-15, 15), 35, currentZ)
        local rotation = Vector3.new(0, math.random(0, 45), 90)
        self:CreateRing(pos, rotation)
        CollectibleManager:CreateCoin(pos, 300)
        currentZ = currentZ + 35
    end

    -- Finish line
    local finishPos = Vector3.new(0, 30, currentZ + 30)
    CollectibleManager:CreateFinishLine(finishPos, Vector3.new(60, 30, 2))

    print("[CourseBuilder] Course complete! Length:", currentZ, "studs")
end

-- Auto-build on start
CourseBuilder:BuildCourse()

print("[CourseBuilder] Initialized")

return CourseBuilder
