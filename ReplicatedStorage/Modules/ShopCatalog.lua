--[[
    ShopCatalog.lua
    Defines all purchasable items for the hovercraft game
    Place in: ReplicatedStorage > Modules
]]

local ShopCatalog = {}

-- Item categories
ShopCatalog.Categories = {
    "Blocks",
    "Thrusters",
    "Wings",
    "Decorations",
    "Special"
}

-- All shop items
-- Each item has: Name, Price, Category, Description, BlockType (for spawning)
ShopCatalog.Items = {
    -- BLOCKS
    {
        Name = "Wooden Block",
        Price = 0,
        Category = "Blocks",
        Description = "Basic wooden block. Free!",
        BlockType = "WoodBlock",
        Color = Color3.fromRGB(153, 102, 51),
        Size = Vector3.new(4, 4, 4)
    },
    {
        Name = "Stone Block",
        Price = 50,
        Category = "Blocks",
        Description = "Stronger and heavier than wood",
        BlockType = "StoneBlock",
        Color = Color3.fromRGB(128, 128, 128),
        Size = Vector3.new(4, 4, 4)
    },
    {
        Name = "Metal Block",
        Price = 150,
        Category = "Blocks",
        Description = "Very durable metal block",
        BlockType = "MetalBlock",
        Color = Color3.fromRGB(192, 192, 192),
        Size = Vector3.new(4, 4, 4)
    },
    {
        Name = "Light Block",
        Price = 100,
        Category = "Blocks",
        Description = "Lightweight floating block",
        BlockType = "LightBlock",
        Color = Color3.fromRGB(173, 216, 230),
        Size = Vector3.new(4, 4, 4)
    },
    {
        Name = "Glass Block",
        Price = 200,
        Category = "Blocks",
        Description = "Transparent block for windows",
        BlockType = "GlassBlock",
        Color = Color3.fromRGB(200, 240, 255),
        Size = Vector3.new(4, 4, 4),
        Transparency = 0.5
    },

    -- THRUSTERS
    {
        Name = "Small Thruster",
        Price = 100,
        Category = "Thrusters",
        Description = "Basic propulsion",
        BlockType = "SmallThruster",
        Color = Color3.fromRGB(255, 100, 100),
        Size = Vector3.new(2, 2, 3),
        ThrustPower = 500
    },
    {
        Name = "Medium Thruster",
        Price = 300,
        Category = "Thrusters",
        Description = "More powerful thrust",
        BlockType = "MediumThruster",
        Color = Color3.fromRGB(255, 50, 50),
        Size = Vector3.new(3, 3, 4),
        ThrustPower = 1500
    },
    {
        Name = "Large Thruster",
        Price = 600,
        Category = "Thrusters",
        Description = "Maximum power!",
        BlockType = "LargeThruster",
        Color = Color3.fromRGB(255, 0, 0),
        Size = Vector3.new(4, 4, 5),
        ThrustPower = 3000
    },
    {
        Name = "Hover Pad",
        Price = 250,
        Category = "Thrusters",
        Description = "Keeps your craft floating",
        BlockType = "HoverPad",
        Color = Color3.fromRGB(100, 100, 255),
        Size = Vector3.new(4, 1, 4),
        HoverForce = 800
    },

    -- WINGS
    {
        Name = "Small Wing",
        Price = 150,
        Category = "Wings",
        Description = "Improves stability",
        BlockType = "SmallWing",
        Color = Color3.fromRGB(255, 255, 255),
        Size = Vector3.new(6, 0.5, 2)
    },
    {
        Name = "Large Wing",
        Price = 350,
        Category = "Wings",
        Description = "Better aerodynamics",
        BlockType = "LargeWing",
        Color = Color3.fromRGB(240, 240, 240),
        Size = Vector3.new(10, 0.5, 3)
    },

    -- DECORATIONS
    {
        Name = "Red Paint",
        Price = 50,
        Category = "Decorations",
        Description = "Paint blocks red",
        BlockType = "PaintRed",
        Color = Color3.fromRGB(255, 0, 0),
        Size = Vector3.new(2, 2, 2)
    },
    {
        Name = "Blue Paint",
        Price = 50,
        Category = "Decorations",
        Description = "Paint blocks blue",
        BlockType = "PaintBlue",
        Color = Color3.fromRGB(0, 0, 255),
        Size = Vector3.new(2, 2, 2)
    },
    {
        Name = "Flag",
        Price = 100,
        Category = "Decorations",
        Description = "Show your colors!",
        BlockType = "Flag",
        Color = Color3.fromRGB(255, 255, 0),
        Size = Vector3.new(0.2, 4, 2)
    },
    {
        Name = "Pilot Seat",
        Price = 200,
        Category = "Decorations",
        Description = "Control your hovercraft",
        BlockType = "Seat",
        Color = Color3.fromRGB(80, 50, 30),
        Size = Vector3.new(4, 2, 4)
    },

    -- SPECIAL
    {
        Name = "Rocket Booster",
        Price = 1000,
        Category = "Special",
        Description = "EXTREME SPEED!",
        BlockType = "RocketBooster",
        Color = Color3.fromRGB(255, 165, 0),
        Size = Vector3.new(3, 3, 6),
        ThrustPower = 5000
    },
    {
        Name = "Shield Generator",
        Price = 1500,
        Category = "Special",
        Description = "Protects your craft",
        BlockType = "Shield",
        Color = Color3.fromRGB(0, 255, 255),
        Size = Vector3.new(3, 3, 3)
    },
    {
        Name = "Treasure Detector",
        Price = 800,
        Category = "Special",
        Description = "Find treasure easier",
        BlockType = "Detector",
        Color = Color3.fromRGB(255, 215, 0),
        Size = Vector3.new(2, 3, 2)
    }
}

-- Get items by category
function ShopCatalog:GetItemsByCategory(category)
    local items = {}
    for _, item in ipairs(self.Items) do
        if item.Category == category then
            table.insert(items, item)
        end
    end
    return items
end

-- Get item by name
function ShopCatalog:GetItem(itemName)
    for _, item in ipairs(self.Items) do
        if item.Name == itemName then
            return item
        end
    end
    return nil
end

-- Check if player can afford item
function ShopCatalog:CanAfford(itemName, playerCoins)
    local item = self:GetItem(itemName)
    if item then
        return playerCoins >= item.Price
    end
    return false
end

return ShopCatalog
