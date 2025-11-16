--[[
    JetController.lua
    Mouse-based fighter jet flight controller
    Location: StarterPlayer > StarterPlayerScripts > VehicleController (LocalScript)
]]

print("[JetController] Starting...")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local JetController = {}
JetController.Active = false
JetController.CurrentCockpit = nil
JetController.JetParts = {}
JetController.Engines = {}
JetController.Wings = {}
JetController.Weapons = {}
JetController.Throttle = 0  -- 0 to 1
JetController.MaxSpeed = 100
JetController.TotalThrust = 0
JetController.Maneuverability = 1.0

-- Input state
local input = {
    W = false,  -- Throttle up
    S = false,  -- Throttle down
    A = false,  -- Roll left
    D = false,  -- Roll right
    Space = false,  -- Afterburner
    MouseHeld = false  -- Fire weapons
}

-- Settings
local THROTTLE_SPEED = 0.5  -- How fast throttle changes
local ROLL_SPEED = 3  -- Roll speed in degrees
local MOUSE_SENSITIVITY = 0.3  -- How responsive mouse control is
local AFTERBURNER_MULTIPLIER = 2.0

-- Find all connected jet parts
function JetController:FindJetParts(cockpit)
    local parts = {}
    local engines = {}
    local wings = {}
    local weapons = {}
    local totalThrust = 0
    local maxSpeed = 100
    local maneuverability = 1.0

    -- Get all parts in workspace
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and
           part:GetAttribute("IsJetPart") and
           part:GetAttribute("Owner") == player.UserId then

            table.insert(parts, part)

            -- Check for engines
            if part:GetAttribute("ThrustPower") then
                table.insert(engines, part)
                totalThrust = totalThrust + part:GetAttribute("ThrustPower")
                local engineMaxSpeed = part:GetAttribute("MaxSpeed")
                if engineMaxSpeed and engineMaxSpeed > maxSpeed then
                    maxSpeed = engineMaxSpeed
                end
            end

            -- Check for wings
            if part:GetAttribute("Maneuverability") then
                table.insert(wings, part)
                maneuverability = maneuverability * part:GetAttribute("Maneuverability")
            end

            -- Check for weapons
            if part:GetAttribute("WeaponType") then
                table.insert(weapons, part)
            end
        end
    end

    return parts, engines, wings, weapons, totalThrust, maxSpeed, maneuverability
end

-- Start controlling jet
function JetController:StartControl(cockpit)
    JetController.Active = true
    JetController.CurrentCockpit = cockpit
    JetController.Throttle = 0

    -- Lock mouse to center and hide cursor
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

    print("[JetController] Taking control of jet...")

    -- Find all parts
    JetController.JetParts, JetController.Engines, JetController.Wings, JetController.Weapons,
        JetController.TotalThrust, JetController.MaxSpeed, JetController.Maneuverability =
        JetController:FindJetParts(cockpit)

    print("[JetController] Found", #JetController.JetParts, "parts,",
          #JetController.Engines, "engines,", #JetController.Wings, "wings,",
          #JetController.Weapons, "weapons")
    print("[JetController] Total thrust:", JetController.TotalThrust, "Max speed:", JetController.MaxSpeed)

    -- Unanchor all parts so they can move
    for _, part in ipairs(JetController.JetParts) do
        part.Anchored = false
    end
    print("[JetController] Unanchored all jet parts")

    -- Create BodyVelocity for movement
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.Name = "JetBodyVelocity"
    bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVel.Velocity = Vector3.new(0, 0, 0)
    bodyVel.P = 1250
    bodyVel.Parent = cockpit

    -- Create BodyGyro for rotation (mouse aiming)
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "JetBodyGyro"
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000
    bodyGyro.D = 1000
    bodyGyro.CFrame = cockpit.CFrame
    bodyGyro.Parent = cockpit

    print("[JetController] Physics created - Ready to fly!")

    -- Activate engine effects
    for _, engine in ipairs(JetController.Engines) do
        local fire = engine:FindFirstChild("EngineEffect")
        local smoke = engine:FindFirstChild("EngineSmoke")
        if fire then fire.Enabled = true end
        if smoke then smoke.Enabled = true end
    end

    -- Set camera to follow jet
    camera.CameraSubject = cockpit
end

-- Stop controlling jet
function JetController:StopControl()
    JetController.Active = false

    -- Unlock mouse
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default

    -- Deactivate engine effects
    for _, engine in ipairs(JetController.Engines) do
        local fire = engine:FindFirstChild("EngineEffect")
        local smoke = engine:FindFirstChild("EngineSmoke")
        if fire then fire.Enabled = false end
        if smoke then smoke.Enabled = false end
    end

    -- Remove physics
    if JetController.CurrentCockpit then
        local bodyVel = JetController.CurrentCockpit:FindFirstChild("JetBodyVelocity")
        local bodyGyro = JetController.CurrentCockpit:FindFirstChild("JetBodyGyro")
        if bodyVel then bodyVel:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
    end

    -- Re-anchor all parts
    for _, part in ipairs(JetController.JetParts) do
        if part and part.Parent then
            part.Anchored = true
        end
    end
    print("[JetController] Re-anchored all jet parts")

    -- Reset camera
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = player.Character:FindFirstChild("Humanoid")
    end

    JetController.CurrentCockpit = nil
    JetController.JetParts = {}
    JetController.Engines = {}
    JetController.Wings = {}
    JetController.Weapons = {}

    print("[JetController] Stopped control")
end

-- Update jet physics (mouse-based flight)
function JetController:Update(deltaTime)
    if not JetController.Active or not JetController.CurrentCockpit then
        return
    end

    local cockpit = JetController.CurrentCockpit
    local bodyVel = cockpit:FindFirstChild("JetBodyVelocity")
    local bodyGyro = cockpit:FindFirstChild("JetBodyGyro")

    if not bodyVel or not bodyGyro then
        warn("[JetController] Physics objects missing!")
        return
    end

    -- Update throttle
    if input.W then
        JetController.Throttle = math.min(1, JetController.Throttle + THROTTLE_SPEED * deltaTime)
    end
    if input.S then
        JetController.Throttle = math.max(0, JetController.Throttle - THROTTLE_SPEED * deltaTime)
    end

    -- Calculate speed
    local baseSpeed = JetController.MaxSpeed * JetController.Throttle
    local speed = baseSpeed

    -- Apply afterburner
    if input.Space then
        speed = speed * AFTERBURNER_MULTIPLIER
    end

    -- Calculate velocity based on where cockpit is facing
    local forwardVelocity = cockpit.CFrame.LookVector * speed

    -- Add slight upward force for lift (based on wings)
    local liftForce = 0
    for _, wing in ipairs(JetController.Wings) do
        liftForce = liftForce + (wing:GetAttribute("LiftPower") or 0)
    end
    local upwardVelocity = Vector3.new(0, liftForce * 0.1 * JetController.Throttle, 0)

    bodyVel.Velocity = forwardVelocity + upwardVelocity

    -- MOUSE AIMING: Point jet where mouse is looking
    local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
    local targetPosition = mouseRay.Origin + mouseRay.Direction * 100

    -- Calculate target orientation
    local targetCFrame = CFrame.lookAt(cockpit.Position, targetPosition)

    -- Apply roll with A/D
    local rollAngle = 0
    if input.A then
        rollAngle = math.rad(-ROLL_SPEED)
    elseif input.D then
        rollAngle = math.rad(ROLL_SPEED)
    end

    if rollAngle ~= 0 then
        targetCFrame = targetCFrame * CFrame.Angles(0, 0, rollAngle)
    end

    -- Smoothly rotate to target (faster with better maneuverability)
    local lerpSpeed = MOUSE_SENSITIVITY * JetController.Maneuverability
    bodyGyro.CFrame = bodyGyro.CFrame:Lerp(targetCFrame, lerpSpeed)
end

-- Fire weapons
function JetController:FireWeapons()
    if not JetController.Active then return end

    for _, weapon in ipairs(JetController.Weapons) do
        local weaponType = weapon:GetAttribute("WeaponType")
        local muzzle = weapon:FindFirstChild("MuzzlePoint")

        if muzzle and weaponType then
            -- Fire weapon (will implement weapon system next)
            print("[JetController] Firing", weaponType, "from", weapon.Name)
            -- TODO: Implement actual shooting
        end
    end
end

-- Input handling
UserInputService.InputBegan:Connect(function(inputObj, gameProcessed)
    if gameProcessed then return end

    if inputObj.KeyCode == Enum.KeyCode.W then
        input.W = true
    elseif inputObj.KeyCode == Enum.KeyCode.S then
        input.S = true
    elseif inputObj.KeyCode == Enum.KeyCode.A then
        input.A = true
    elseif inputObj.KeyCode == Enum.KeyCode.D then
        input.D = true
    elseif inputObj.KeyCode == Enum.KeyCode.Space then
        input.Space = true
    elseif inputObj.UserInputType == Enum.UserInputType.MouseButton1 then
        input.MouseHeld = true
        if JetController.Active then
            JetController:FireWeapons()
        end
    end
end)

UserInputService.InputEnded:Connect(function(inputObj)
    if inputObj.KeyCode == Enum.KeyCode.W then
        input.W = false
    elseif inputObj.KeyCode == Enum.KeyCode.S then
        input.S = false
    elseif inputObj.KeyCode == Enum.KeyCode.A then
        input.A = false
    elseif inputObj.KeyCode == Enum.KeyCode.D then
        input.D = false
    elseif inputObj.KeyCode == Enum.KeyCode.Space then
        input.Space = false
    elseif inputObj.UserInputType == Enum.UserInputType.MouseButton1 then
        input.MouseHeld = false
    end
end)

-- Detect cockpit sitting
player.Character:WaitForChild("Humanoid").Seated:Connect(function(isSeated, seat)
    if isSeated and seat and seat:GetAttribute("IsCockpit") then
        JetController:StartControl(seat)
    else
        if JetController.Active then
            JetController:StopControl()
        end
    end
end)

-- Update loop
RunService.RenderStepped:Connect(function(deltaTime)
    JetController:Update(deltaTime)
end)

print("[JetController] Initialized")
print("[JetController] Controls:")
print("  - Mouse: Aim jet")
print("  - W/S: Throttle up/down")
print("  - A/D: Roll left/right")
print("  - Space: Afterburner")
print("  - Click: Fire weapons")

-- Export
_G.JetController = JetController

return JetController
