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

-- Wait for character to load properly
repeat task.wait() until player.Character
local character = player.Character
local humanoid = character:WaitForChild("Humanoid")

print("[JetController] Character and humanoid loaded:", character.Name, humanoid.Name)

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
local TURN_SPEED = 1.5  -- How fast jet turns left/right
local PITCH_SPEED = 1.0  -- How fast jet pitches up/down
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

    print("[JetController] Taking control of jet...")

    -- Find all parts
    JetController.JetParts, JetController.Engines, JetController.Wings, JetController.Weapons,
        JetController.TotalThrust, JetController.MaxSpeed, JetController.Maneuverability =
        JetController:FindJetParts(cockpit)

    print("[JetController] Found", #JetController.JetParts, "parts,",
          #JetController.Engines, "engines,", #JetController.Wings, "wings,",
          #JetController.Weapons, "weapons")
    print("[JetController] Total thrust:", JetController.TotalThrust, "Max speed:", JetController.MaxSpeed)

    -- CRITICAL: Unanchor cockpit FIRST (VehicleSeat needs special handling)
    cockpit.Anchored = false

    -- Disable VehicleSeat's built-in physics (it fights against our custom physics!)
    if cockpit:IsA("VehicleSeat") then
        cockpit.MaxSpeed = 0
        cockpit.Torque = 0
        cockpit.TurnSpeed = 0
        print("[JetController] Disabled VehicleSeat built-in physics")
    end

    print("[JetController] COCKPIT unanchored:", cockpit.Name, "Anchored:", cockpit.Anchored)

    -- Unanchor all other parts and disable collision so they can move freely
    for _, part in ipairs(JetController.JetParts) do
        part.Anchored = false
        part.CanCollide = false  -- Disable collision to prevent parts from fighting each other
        print("[JetController] Unanchored:", part.Name, "IsAnchored:", part.Anchored, "CanCollide:", part.CanCollide)
    end
    print("[JetController] Finished unanchoring all jet parts")

    -- Check for welds
    local weldCount = 0
    for _, part in ipairs(JetController.JetParts) do
        for _, child in ipairs(part:GetChildren()) do
            if child:IsA("WeldConstraint") then
                weldCount = weldCount + 1
            end
        end
    end
    print("[JetController] Found", weldCount, "WeldConstraints connecting parts")

    -- Create Attachment for constraints
    local attachment = Instance.new("Attachment")
    attachment.Name = "JetAttachment"
    attachment.Parent = cockpit

    -- Create LinearVelocity for movement (modern replacement for BodyVelocity)
    local linearVel = Instance.new("LinearVelocity")
    linearVel.Name = "JetLinearVelocity"
    linearVel.Attachment0 = attachment
    linearVel.MaxForce = math.huge
    linearVel.VectorVelocity = Vector3.new(0, 0, 0)
    linearVel.RelativeTo = Enum.ActuatorRelativeTo.World
    linearVel.Parent = cockpit

    -- Create AlignOrientation for rotation (modern replacement for BodyGyro)
    local alignOrientation = Instance.new("AlignOrientation")
    alignOrientation.Name = "JetAlignOrientation"
    alignOrientation.Attachment0 = attachment
    alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignOrientation.MaxTorque = math.huge
    alignOrientation.Responsiveness = 50
    alignOrientation.CFrame = cockpit.CFrame
    alignOrientation.Parent = cockpit

    -- VERIFY: Double-check cockpit is unanchored after creating physics
    if cockpit.Anchored then
        warn("[JetController] WARNING: Cockpit re-anchored itself! Forcing unanchor...")
        cockpit.Anchored = false
    end

    print("[JetController] Physics created - Ready to fly!")
    print("[JetController] LinearVelocity MaxForce:", linearVel.MaxForce)
    print("[JetController] AlignOrientation MaxTorque:", alignOrientation.MaxTorque)
    print("[JetController] Cockpit Anchored:", cockpit.Anchored)
    print("[JetController] Assembly Root:", cockpit:GetRootPart().Name)

    -- FINAL CHECK: Verify in the next frame
    task.wait(0.1)
    print("[JetController] FINAL CHECK - Cockpit still unanchored?", not cockpit.Anchored)

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

    -- Deactivate engine effects
    for _, engine in ipairs(JetController.Engines) do
        local fire = engine:FindFirstChild("EngineEffect")
        local smoke = engine:FindFirstChild("EngineSmoke")
        if fire then fire.Enabled = false end
        if smoke then smoke.Enabled = false end
    end

    -- Remove physics
    if JetController.CurrentCockpit then
        local linearVel = JetController.CurrentCockpit:FindFirstChild("JetLinearVelocity")
        local alignOrientation = JetController.CurrentCockpit:FindFirstChild("JetAlignOrientation")
        local attachment = JetController.CurrentCockpit:FindFirstChild("JetAttachment")
        if linearVel then linearVel:Destroy() end
        if alignOrientation then alignOrientation:Destroy() end
        if attachment then attachment:Destroy() end
    end

    -- Re-anchor all parts and re-enable collision
    for _, part in ipairs(JetController.JetParts) do
        if part and part.Parent then
            part.Anchored = true
            part.CanCollide = true
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
local debugCounter = 0
function JetController:Update(deltaTime)
    if not JetController.Active or not JetController.CurrentCockpit then
        return
    end

    local cockpit = JetController.CurrentCockpit
    local linearVel = cockpit:FindFirstChild("JetLinearVelocity")
    local alignOrientation = cockpit:FindFirstChild("JetAlignOrientation")

    if not linearVel or not alignOrientation then
        warn("[JetController] Physics objects missing!")
        return
    end

    -- CRITICAL: If cockpit becomes anchored, force unanchor every frame
    if cockpit.Anchored then
        warn("[JetController] BUG: Cockpit became anchored during flight! Re-unanchoring...")
        cockpit.Anchored = false
    end

    -- Debug every 60 frames (about 1 second)
    debugCounter = debugCounter + 1
    if debugCounter >= 60 then
        debugCounter = 0
        print("[JetController] Update - Throttle:", JetController.Throttle)
        print("  INTENDED Velocity:", linearVel.VectorVelocity.Magnitude)
        print("  ACTUAL Velocity:", cockpit.AssemblyLinearVelocity.Magnitude)
        print("  Anchored:", cockpit.Anchored, "CanCollide:", cockpit.CanCollide)
        print("  Position:", cockpit.Position)
        print("  LinearVel enabled:", linearVel.Enabled, "Parent:", linearVel.Parent ~= nil)
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

    -- Add hover force - always push upward to counteract gravity
    local hoverForce = 30  -- Base hover force

    -- Add lift from wings when moving
    local liftForce = 0
    for _, wing in ipairs(JetController.Wings) do
        liftForce = liftForce + (wing:GetAttribute("LiftPower") or 0)
    end

    -- Total upward velocity = hover + lift (lift increases with throttle)
    local upwardVelocity = hoverForce + (liftForce * 0.2 * JetController.Throttle)

    linearVel.VectorVelocity = forwardVelocity + Vector3.new(0, upwardVelocity, 0)

    -- WASD FLIGHT CONTROLS (no mouse)
    local currentCFrame = cockpit.CFrame

    -- A/D for turning left/right (yaw)
    local turnAmount = 0
    if input.A then
        turnAmount = TURN_SPEED
    elseif input.D then
        turnAmount = -TURN_SPEED
    end

    -- Apply turn
    if turnAmount ~= 0 then
        currentCFrame = currentCFrame * CFrame.Angles(0, math.rad(turnAmount), 0)
    end

    -- Set target orientation
    alignOrientation.CFrame = currentCFrame
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
humanoid.Seated:Connect(function(isSeated, seat)
    print("[JetController] Seated event:", isSeated, seat)
    if isSeated and seat and seat:GetAttribute("IsCockpit") then
        print("[JetController] Detected cockpit, starting control")
        JetController:StartControl(seat)
    else
        if JetController.Active then
            print("[JetController] Exited seat, stopping control")
            JetController:StopControl()
        end
    end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")

    humanoid.Seated:Connect(function(isSeated, seat)
        if isSeated and seat and seat:GetAttribute("IsCockpit") then
            JetController:StartControl(seat)
        else
            if JetController.Active then
                JetController:StopControl()
            end
        end
    end)
end)

-- Update loop
RunService.RenderStepped:Connect(function(deltaTime)
    JetController:Update(deltaTime)
end)

print("[JetController] Initialized")
print("[JetController] Controls:")
print("  - W/S: Throttle up/down")
print("  - A/D: Turn left/right")
print("  - Space: Afterburner")
print("  - Click: Fire weapons")

-- Export
_G.JetController = JetController

return JetController
