--[[
    CollectibleManager.lua
    Manages collectible coins/treasure in the course
    Location: ServerScriptService > CollectibleManager (Script)
]]

print("[CollectibleManager] Starting...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService:WaitForChild("DataManager"))

local CollectibleManager = {}
CollectibleManager.Coins = {}

-- Create a collectible coin
function CollectibleManager:CreateCoin(position, value)
    local coin = Instance.new("Part")
    coin.Name = "Coin"
    coin.Size = Vector3.new(4, 4, 0.5)
    coin.Position = position
    coin.Anchored = true
    coin.CanCollide = false
    coin.BrickColor = BrickColor.new("Bright yellow")
    coin.Material = Enum.Material.Neon
    coin.Shape = Enum.PartType.Cylinder
    coin.Orientation = Vector3.new(0, 0, 90)

    -- Value attribute
    coin:SetAttribute("CoinValue", value or 100)
    coin:SetAttribute("IsCollectible", true)

    -- Make it glow
    local light = Instance.new("PointLight")
    light.Brightness = 2
    light.Color = Color3.fromRGB(255, 255, 0)
    light.Range = 20
    light.Parent = coin

    -- Sparkle effect
    local sparkle = Instance.new("Sparkles")
    sparkle.SparkleColor = Color3.fromRGB(255, 255, 0)
    sparkle.Parent = coin

    -- Touch detection
    local debounce = {}
    coin.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = game.Players:GetPlayerFromCharacter(character)

        if player and not debounce[player.UserId] then
            debounce[player.UserId] = true

            local value = coin:GetAttribute("CoinValue") or 100
            DataManager:AddCoins(player, value)

            print("[CollectibleManager]", player.Name, "collected coin worth", value)

            -- Visual feedback
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://5153328183"  -- Coin collect sound
            sound.Volume = 0.5
            sound.Parent = coin
            sound:Play()

            -- Fade out
            coin.Transparency = 1
            for _, child in ipairs(coin:GetChildren()) do
                if child:IsA("Light") or child:IsA("Sparkles") then
                    child.Enabled = false
                end
            end

            -- Respawn after 10 seconds
            task.delay(10, function()
                coin.Transparency = 0
                for _, child in ipairs(coin:GetChildren()) do
                    if child:IsA("Light") or child:IsA("Sparkles") then
                        child.Enabled = true
                    end
                end
                debounce[player.UserId] = nil
            end)
        end
    end)

    coin.Parent = workspace
    table.insert(CollectibleManager.Coins, coin)

    return coin
end

-- Create finish line
function CollectibleManager:CreateFinishLine(position, size)
    local finish = Instance.new("Part")
    finish.Name = "FinishLine"
    finish.Size = size or Vector3.new(50, 20, 2)
    finish.Position = position
    finish.Anchored = true
    finish.CanCollide = false
    finish.BrickColor = BrickColor.new("Lime green")
    finish.Material = Enum.Material.Neon
    finish.Transparency = 0.5

    -- Checkered pattern
    for i = 0, 4 do
        for j = 0, 1 do
            local square = Instance.new("Part")
            square.Size = Vector3.new(10, 10, 0.1)
            square.Position = finish.Position + Vector3.new(-20 + i*10, -5 + j*10, 0)
            square.Anchored = true
            square.CanCollide = false
            square.BrickColor = (i + j) % 2 == 0 and BrickColor.new("Black") or BrickColor.new("White")
            square.Parent = finish
        end
    end

    -- Completion detection
    local debounce = {}
    finish.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = game.Players:GetPlayerFromCharacter(character)

        if player and not debounce[player.UserId] then
            debounce[player.UserId] = true

            local reward = 5000  -- Big reward for finishing
            DataManager:AddCoins(player, reward)

            print("[CollectibleManager]", player.Name, "crossed finish line! Reward:", reward)

            -- Victory sound
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://5153328183"
            sound.Volume = 1
            sound.Parent = finish
            sound:Play()

            task.delay(5, function()
                debounce[player.UserId] = nil
            end)
        end
    end)

    finish.Parent = workspace
    return finish
end

print("[CollectibleManager] Initialized")

return CollectibleManager
