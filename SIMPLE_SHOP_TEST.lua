--[[
    SIMPLE_SHOP_TEST.lua

    This is a simplified, single-file version for testing if your GUI works.

    INSTALLATION:
    1. In Roblox Studio, go to StarterGui
    2. Right-click StarterGui → Insert Object → LocalScript
    3. Name it "SimpleShopTest"
    4. Copy and paste this ENTIRE file into that LocalScript
    5. Press Play

    You should see a big green "TEST SHOP" button. If you do, the GUI system works!
    If not, check the Output window (View → Output or press F9) for errors.
]]

print("=== SIMPLE SHOP TEST STARTING ===")

-- Get services
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Wait for PlayerGui
print("Waiting for PlayerGui...")
local playerGui = player:WaitForChild("PlayerGui", 10)

if not playerGui then
    warn("ERROR: PlayerGui not found!")
    warn("This means LocalScripts aren't running properly.")
    return
end

print("SUCCESS: PlayerGui found!")

-- Create a ScreenGui
print("Creating ScreenGui...")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleShopTest"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

print("ScreenGui created and parented to PlayerGui")

-- Create a simple test button
print("Creating test button...")
local testButton = Instance.new("TextButton")
testButton.Name = "TestShopButton"
testButton.Size = UDim2.new(0, 200, 0, 100)
testButton.Position = UDim2.new(0.5, -100, 0.5, -50)
testButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
testButton.BorderSizePixel = 3
testButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
testButton.Text = "TEST SHOP\n(Click Me!)"
testButton.TextColor3 = Color3.fromRGB(255, 255, 255)
testButton.TextSize = 24
testButton.Font = Enum.Font.GothamBold
testButton.TextWrapped = true
testButton.Parent = screenGui

print("Test button created!")

-- Add UICorner for rounded edges
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = testButton

-- Make it interactive
local clickCount = 0
testButton.MouseButton1Click:Connect(function()
    clickCount = clickCount + 1
    testButton.Text = "Clicked " .. clickCount .. " times!\n✓ GUI WORKS!"
    testButton.BackgroundColor3 = Color3.fromRGB(
        math.random(100, 255),
        math.random(100, 255),
        math.random(100, 255)
    )
    print("Button clicked!", clickCount, "times")
end)

-- Hover effects
testButton.MouseEnter:Connect(function()
    testButton.BackgroundColor3 = Color3.fromRGB(70, 220, 70)
    testButton.Size = UDim2.new(0, 220, 0, 110)
    print("Mouse entered button")
end)

testButton.MouseLeave:Connect(function()
    if clickCount == 0 then
        testButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    end
    testButton.Size = UDim2.new(0, 200, 0, 100)
    print("Mouse left button")
end)

-- Create info label
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 400, 0, 100)
infoLabel.Position = UDim2.new(0.5, -200, 0, 20)
infoLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
infoLabel.BackgroundTransparency = 0.3
infoLabel.BorderSizePixel = 0
infoLabel.Text = "✓ GUI System Working!\n\nIf you can see this, your GUI setup is correct.\nNow you can install the full shop system."
infoLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
infoLabel.TextSize = 16
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextWrapped = true
infoLabel.Parent = screenGui

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoLabel

-- Success message
print("=== SIMPLE SHOP TEST COMPLETE ===")
print("")
print("✓✓✓ SUCCESS! ✓✓✓")
print("")
print("If you can see a green button in the middle of your screen,")
print("your GUI system is working correctly!")
print("")
print("Next steps:")
print("1. Delete this SimpleShopTest script")
print("2. Follow the INSTALLATION_GUIDE.md to install the full shop")
print("")
print("If you DON'T see the button:")
print("1. Make sure this is a LocalScript (not a Script)")
print("2. Make sure it's in StarterGui")
print("3. Check this Output window for error messages")
print("")
print("=================================")
