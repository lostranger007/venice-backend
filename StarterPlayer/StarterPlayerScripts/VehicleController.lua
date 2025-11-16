--[[
    VehicleController.lua
    Controls hovercraft movement when player sits in seat
    Location: StarterPlayer > StarterPlayerScripts > VehicleController (LocalScript)
]]

print("[VehicleController] Starting...")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local VehicleController = {}
VehicleController.Active = false
VehicleController.CurrentSeat = nil
VehicleController.HovercraftParts = {}
VehicleController.Thrusters = {}
VehicleController.HoverPads = {}

-- Input state
local input = {
    W = false,
    A = false,
    S = false,
    D = false,
    Space = false,
    LeftShift = false,
    Q = false,
    E = false
}

-- Settings
local BASE_SPEED = 50  -- Base movement speed even without thrusters
local THRUST_MULTIPLIER = 5  -- Multiplier for thruster power
local HOVER_MULTIPLIER = 1.5
local TURN_SPEED = 2
local MAX_SPEED = 150
local HOVER_HEIGHT = 10

-- Find all connected parts
function VehicleController:FindHovercraftParts(seat)
    local parts = {}
    local thrusters = {}
    local hoverPads = {}

    -- Get all parts in workspace
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and
           part:GetAttribute("IsHovercraftPart") and
           part:GetAttribute("Owner") == player.UserId then

            table.insert(parts, part)

            -- Check for thrusters
            if part:GetAttribute("ThrustPower") then
                table.insert(thrusters, part)
            end

            -- Check for hover pads
            if part:GetAttribute("HoverForce") or part.Name == "HoverPad" then
                table.insert(hoverPads, part)
            end
        end
    end

    return parts, thrusters, hoverPads
end

-- Calculate center of mass
function VehicleController:GetCenterOfMass()
    if #VehicleController.HovercraftParts == 0 then
        return Vector3.new(0, 0, 0)
    end

    local totalMass = 0
    local weightedPosition = Vector3.new(0, 0, 0)

    for _, part in ipairs(VehicleController.HovercraftParts) do
        local mass = part:GetMass()
        totalMass = totalMass + mass
        weightedPosition = weightedPosition + (part.Position * mass)
    end

    return weightedPosition / totalMass
end

-- Start controlling vehicle
function VehicleController:StartControl(seat)
    VehicleController.Active = true
    VehicleController.CurrentSeat = seat

    -- Disable jumping so Space key doesn't make player jump out
    if humanoid then
        humanoid.JumpPower = 0
        humanoid.JumpHeight = 0
    end

    -- Find all parts
    VehicleController.HovercraftParts, VehicleController.Thrusters, VehicleController.HoverPads =
        VehicleController:FindHovercraftParts(seat)

    print("[VehicleController] Found", #VehicleController.HovercraftParts, "parts,",
          #VehicleController.Thrusters, "thrusters,", #VehicleController.HoverPads, "hover pads")

    -- Unanchor all parts so they can move
    for _, part in ipairs(VehicleController.HovercraftParts) do
        part.Anchored = false
    end
    print("[VehicleController] Unanchored all hovercraft parts")

    -- Create BodyVelocity and BodyGyro on seat
    if not seat:FindFirstChild("BodyVelocity") then
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.Name = "BodyVelocity"
        bodyVel.MaxForce = Vector3.new(100000, 100000, 100000)  -- High force to move the vehicle
        bodyVel.Velocity = Vector3.new(0, 0, 0)
        bodyVel.P = 1250  -- Power for reaching target velocity
        bodyVel.Parent = seat
    end

    if not seat:FindFirstChild("BodyGyro") then
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "BodyGyro"
        bodyGyro.MaxTorque = Vector3.new(50000, 50000, 50000)  -- High torque for rotation
        bodyGyro.P = 10000  -- Power
        bodyGyro.D = 1000  -- Dampening
        bodyGyro.Parent = seat
    end

    -- Activate thruster effects
    for _, thruster in ipairs(VehicleController.Thrusters) do
        local fire = thruster:FindFirstChild("ThrustEffect")
        if fire then
            fire.Enabled = true
        end
    end
end

-- Stop controlling vehicle
function VehicleController:StopControl()
    VehicleController.Active = false

    -- Re-enable jumping
    if humanoid then
        humanoid.JumpPower = 50
        humanoid.JumpHeight = 7.2
    end

    -- Deactivate thruster effects
    for _, thruster in ipairs(VehicleController.Thrusters) do
        local fire = thruster:FindFirstChild("ThrustEffect")
        if fire then
            fire.Enabled = false
        end
    end

    -- Re-anchor all parts so they don't fall
    for _, part in ipairs(VehicleController.HovercraftParts) do
        if part and part.Parent then
            part.Anchored = true
        end
    end
    print("[VehicleController] Re-anchored all hovercraft parts")

    -- Remove forces
    if VehicleController.CurrentSeat then
        local bodyVel = VehicleController.CurrentSeat:FindFirstChild("BodyVelocity")
        local bodyGyro = VehicleController.CurrentSeat:FindFirstChild("BodyGyro")
        if bodyVel then bodyVel:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
    end

    VehicleController.CurrentSeat = nil
    VehicleController.HovercraftParts = {}
    VehicleController.Thrusters = {}
    VehicleController.HoverPads = {}

    print("[VehicleController] Stopped control")
end

-- Update vehicle physics
function VehicleController:Update()
    if not VehicleController.Active or not VehicleController.CurrentSeat then
        return
    end

    local seat = VehicleController.CurrentSeat
    local bodyVel = seat:FindFirstChild("BodyVelocity")
    local bodyGyro = seat:FindFirstChild("BodyGyro")

    if not bodyVel or not bodyGyro then
        return
    end

    -- Calculate thrust
    local thrustDirection = Vector3.new(0, 0, 0)

    if input.W then
        thrustDirection = thrustDirection + seat.CFrame.LookVector
    end
    if input.S then
        thrustDirection = thrustDirection - seat.CFrame.LookVector
    end
    if input.A then
        thrustDirection = thrustDirection - seat.CFrame.RightVector
    end
    if input.D then
        thrustDirection = thrustDirection + seat.CFrame.RightVector
    end
    if input.Space then
        thrustDirection = thrustDirection + Vector3.new(0, 1, 0)
    end
    if input.LeftShift then
        thrustDirection = thrustDirection - Vector3.new(0, 1, 0)
    end

    -- Calculate total thrust power (with base speed)
    local totalThrust = BASE_SPEED  -- Start with base speed
    for _, thruster in ipairs(VehicleController.Thrusters) do
        totalThrust = totalThrust + (thruster:GetAttribute("ThrustPower") or 0) * THRUST_MULTIPLIER
    end

    -- Apply thrust
    local targetVelocity = Vector3.new(0, 0, 0)
    if thrustDirection.Magnitude > 0 then
        targetVelocity = thrustDirection.Unit * totalThrust
    end

    -- Apply hover force - always push upward slightly
    local hoverVelocity = 20  -- Default upward velocity

    bodyVel.Velocity = targetVelocity + Vector3.new(0, hoverVelocity, 0)

    -- Limit speed
    if bodyVel.Velocity.Magnitude > MAX_SPEED then
        bodyVel.Velocity = bodyVel.Velocity.Unit * MAX_SPEED
    end

    -- Apply rotation
    if input.Q then
        bodyGyro.CFrame = bodyGyro.CFrame * CFrame.Angles(0, math.rad(TURN_SPEED), 0)
    end
    if input.E then
        bodyGyro.CFrame = bodyGyro.CFrame * CFrame.Angles(0, -math.rad(TURN_SPEED), 0)
    end

    -- Keep gyro updated with seat orientation
    if not input.Q and not input.E then
        bodyGyro.CFrame = seat.CFrame
    end
end

-- Input handling
UserInputService.InputBegan:Connect(function(inputObj, gameProcessed)
    if gameProcessed then return end

    if inputObj.KeyCode == Enum.KeyCode.W then
        input.W = true
    elseif inputObj.KeyCode == Enum.KeyCode.A then
        input.A = true
    elseif inputObj.KeyCode == Enum.KeyCode.S then
        input.S = true
    elseif inputObj.KeyCode == Enum.KeyCode.D then
        input.D = true
    elseif inputObj.KeyCode == Enum.KeyCode.Space then
        input.Space = true
    elseif inputObj.KeyCode == Enum.KeyCode.LeftShift then
        input.LeftShift = true
    elseif inputObj.KeyCode == Enum.KeyCode.Q then
        input.Q = true
    elseif inputObj.KeyCode == Enum.KeyCode.E then
        input.E = true
    end
end)

UserInputService.InputEnded:Connect(function(inputObj)
    if inputObj.KeyCode == Enum.KeyCode.W then
        input.W = false
    elseif inputObj.KeyCode == Enum.KeyCode.A then
        input.A = false
    elseif inputObj.KeyCode == Enum.KeyCode.S then
        input.S = false
    elseif inputObj.KeyCode == Enum.KeyCode.D then
        input.D = false
    elseif inputObj.KeyCode == Enum.KeyCode.Space then
        input.Space = false
    elseif inputObj.KeyCode == Enum.KeyCode.LeftShift then
        input.LeftShift = false
    elseif inputObj.KeyCode == Enum.KeyCode.Q then
        input.Q = false
    elseif inputObj.KeyCode == Enum.KeyCode.E then
        input.E = false
    end
end)

-- Detect seat sitting
humanoid.Seated:Connect(function(isSeated, seat)
    if isSeated and seat and seat:GetAttribute("IsHovercraftPart") then
        VehicleController:StartControl(seat)
    else
        VehicleController:StopControl()
    end
end)

-- Update loop
RunService.Heartbeat:Connect(function()
    VehicleController:Update()
end)

print("[VehicleController] Initialized")
print("[VehicleController] Controls: WASD=Move, Space/Shift=Up/Down, Q/E=Turn")

-- Export
_G.VehicleController = VehicleController

return VehicleController
