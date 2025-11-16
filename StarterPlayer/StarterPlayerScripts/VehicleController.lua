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

    -- DISABLE ALL PART PHYSICS - This is critical!
    for _, part in ipairs(JetController.JetParts) do
        part.Anchored = false
        part.CanCollide = false
        part.Massless = true  -- Remove mass to simplify physics
        -- Destroy any existing body movers
        for _, child in ipairs(part:GetChildren()) do
            if child:IsA("BodyMover") or child:IsA("Constraint") then
                child:Destroy()
            end
        end
        print("[JetController] Prepared part:", part.Name)
    end

    -- Disable VehicleSeat's built-in physics
    if cockpit:IsA("VehicleSeat") then
        cockpit.MaxSpeed = 0
        cockpit.Torque = 0
        cockpit.TurnSpeed = 0
        cockpit.Disabled = true  -- Disable VehicleSeat completely
    end

    -- SIMPLE PHYSICS: Just use BodyVelocity on the cockpit
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.Name = "JetBodyVelocity"
    bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVel.Velocity = Vector3.new(0, 50, 0)  -- Start with upward velocity
    bodyVel.Parent = cockpit

    print("[JetController] Created BodyVelocity - testing upward movement...")
    print("[JetController] Cockpit Anchored:", cockpit.Anchored)
    print("[JetController] Cockpit CanCollide:", cockpit.CanCollide)
    print("[JetController] Cockpit Massless:", cockpit.Massless)

    -- Wait and check if position changes
    local startPos = cockpit.Position
    task.wait(1)
    local endPos = cockpit.Position
    local moved = (endPos - startPos).Magnitude
    print("[JetController] After 1 second - Moved distance:", moved, "studs")
    if moved < 1 then
        warn("[JetController] NOT MOVING! Position unchanged!")
    else
        print("[JetController] SUCCESS! Jet is moving!")
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
        local bodyVel = JetController.CurrentCockpit:FindFirstChild("JetBodyVelocity")
        if bodyVel then bodyVel:Destroy() end
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

-- Update jet physics - SIMPLE VERSION
local debugCounter = 0
function JetController:Update(deltaTime)
    if not JetController.Active or not JetController.CurrentCockpit then
        return
    end

    local cockpit = JetController.CurrentCockpit
    local bodyVel = cockpit:FindFirstChild("JetBodyVelocity")

    if not bodyVel then
        warn("[JetController] BodyVelocity missing!")
        return
    end

    -- Force unanchor every frame
    if cockpit.Anchored then
        warn("[JetController] Cockpit anchored! Re-unanchoring...")
        cockpit.Anchored = false
    end

    -- Update throttle with W/S
    if input.W then
        JetController.Throttle = math.min(1, JetController.Throttle + THROTTLE_SPEED * deltaTime)
    end
    if input.S then
        JetController.Throttle = math.max(0, JetController.Throttle - THROTTLE_SPEED * deltaTime)
    end

    -- SUPER SIMPLE: Just go up and forward
    local forwardSpeed = 100 * JetController.Throttle  -- Forward speed
    local upSpeed = 50  -- Always hover upward

    -- Forward direction (where cockpit faces)
    local forward = cockpit.CFrame.LookVector * forwardSpeed

    -- Apply velocity
    bodyVel.Velocity = forward + Vector3.new(0, upSpeed, 0)

    -- Simple turning with A/D
    if input.A then
        cockpit.CFrame = cockpit.CFrame * CFrame.Angles(0, math.rad(TURN_SPEED), 0)
    elseif input.D then
        cockpit.CFrame = cockpit.CFrame * CFrame.Angles(0, math.rad(-TURN_SPEED), 0)
    end

    -- Debug every second
    debugCounter = debugCounter + 1
    if debugCounter >= 60 then
        debugCounter = 0
        print("[JetController] Throttle:", JetController.Throttle)
        print("  Velocity:", bodyVel.Velocity.Magnitude, "studs/sec")
        print("  Position:", cockpit.Position)
        print("  Anchored:", cockpit.Anchored)
    end
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
