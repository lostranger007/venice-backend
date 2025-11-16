--[[
    BuildingToolsGui.lua
    GUI for building tools (toggle build mode, delete mode)
    Location: StarterGui > BuildingToolsGui (folder) > BuildingToolsGui (LocalScript)
]]

print("[BuildingToolsGui] Starting...")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BuildingToolsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Container for tool buttons
local toolsFrame = Instance.new("Frame")
toolsFrame.Name = "ToolsFrame"
toolsFrame.Size = UDim2.new(0, 150, 0, 120)
toolsFrame.Position = UDim2.new(1, -160, 0, 10)
toolsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
toolsFrame.BackgroundTransparency = 0.3
toolsFrame.BorderSizePixel = 0
toolsFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = toolsFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "BUILDING TOOLS"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = toolsFrame

-- Cancel Build Mode Button
local cancelBuildButton = Instance.new("TextButton")
cancelBuildButton.Name = "CancelBuildButton"
cancelBuildButton.Size = UDim2.new(1, -20, 0, 35)
cancelBuildButton.Position = UDim2.new(0, 10, 0, 30)
cancelBuildButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
cancelBuildButton.Text = "❌ EXIT BUILD MODE"
cancelBuildButton.TextColor3 = Color3.fromRGB(255, 255, 255)
cancelBuildButton.TextSize = 13
cancelBuildButton.Font = Enum.Font.GothamBold
cancelBuildButton.BorderSizePixel = 0
cancelBuildButton.Visible = false  -- Hidden by default
cancelBuildButton.Parent = toolsFrame

local cancelCorner = Instance.new("UICorner")
cancelCorner.CornerRadius = UDim.new(0, 6)
cancelCorner.Parent = cancelBuildButton

-- Delete Mode Toggle Button
local deleteButton = Instance.new("TextButton")
deleteButton.Name = "DeleteButton"
deleteButton.Size = UDim2.new(1, -20, 0, 35)
deleteButton.Position = UDim2.new(0, 10, 0, 75)
deleteButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
deleteButton.Text = "🗑️ DELETE MODE: OFF"
deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteButton.TextSize = 12
deleteButton.Font = Enum.Font.GothamBold
deleteButton.BorderSizePixel = 0
deleteButton.Parent = toolsFrame

local deleteCorner = Instance.new("UICorner")
deleteCorner.CornerRadius = UDim.new(0, 6)
deleteCorner.Parent = deleteButton

-- State
local deleteMode = false

-- Cancel Build Mode
cancelBuildButton.MouseButton1Click:Connect(function()
    if _G.BuildingSystem then
        _G.BuildingSystem:StopBuilding()
        cancelBuildButton.Visible = false
    end
end)

-- Toggle Delete Mode
deleteButton.MouseButton1Click:Connect(function()
    if _G.BuildingSystem then
        deleteMode = not deleteMode
        _G.BuildingSystem.DeleteModeEnabled = deleteMode

        if deleteMode then
            deleteButton.Text = "🗑️ DELETE MODE: ON"
            deleteButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        else
            deleteButton.Text = "🗑️ DELETE MODE: OFF"
            deleteButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        end

        print("[BuildingToolsGui] Delete mode:", deleteMode)
    end
end)

-- Monitor building system state
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.BuildingSystem then
            -- Show/hide cancel button based on building state
            cancelBuildButton.Visible = _G.BuildingSystem.Enabled
        end
    end
end)

print("[BuildingToolsGui] Initialized")
