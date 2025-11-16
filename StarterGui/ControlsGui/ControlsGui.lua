--[[
    ControlsGui.lua
    Shows vehicle controls on screen
    Location: StarterGui > ControlsGui (folder) > ControlsGui (LocalScript)
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ControlsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Controls frame (hidden by default)
local controlsFrame = Instance.new("Frame")
controlsFrame.Name = "ControlsFrame"
controlsFrame.Size = UDim2.new(0, 250, 0, 200)
controlsFrame.Position = UDim2.new(1, -260, 1, -210)
controlsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
controlsFrame.BackgroundTransparency = 0.3
controlsFrame.BorderSizePixel = 0
controlsFrame.Visible = false
controlsFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = controlsFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🚁 HOVERCRAFT CONTROLS"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = controlsFrame

-- Controls text
local controlsText = Instance.new("TextLabel")
controlsText.Size = UDim2.new(1, -20, 1, -40)
controlsText.Position = UDim2.new(0, 10, 0, 35)
controlsText.BackgroundTransparency = 1
controlsText.Text = [[
W/S - Forward/Backward
A/D - Left/Right
Space - Up
Shift - Down
Q/E - Turn Left/Right

Click to exit
]]
controlsText.TextColor3 = Color3.fromRGB(255, 255, 255)
controlsText.TextSize = 14
controlsText.Font = Enum.Font.Gotham
controlsText.TextXAlignment = Enum.TextXAlignment.Left
controlsText.TextYAlignment = Enum.TextYAlignment.Top
controlsText.Parent = controlsFrame

-- Show/hide based on vehicle control
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

humanoid.Seated:Connect(function(isSeated, seat)
    if isSeated and seat and seat:GetAttribute("IsHovercraftPart") then
        controlsFrame.Visible = true
    else
        controlsFrame.Visible = false
    end
end)

print("[ControlsGui] Initialized")
