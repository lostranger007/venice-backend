--[[
    JetPartsCatalog.lua
    Catalog of all jet parts available in the shop
    Location: ReplicatedStorage > Modules > ShopCatalog (ModuleScript)
]]

local ShopCatalog = {}

-- Categories of parts
ShopCatalog.Categories = {
    "Cockpits",
    "Wings",
    "Engines",
    "Weapons",
    "Body Parts"
}

-- All available jet parts
ShopCatalog.Items = {
    -- COCKPITS
    {
        Name = "Basic Cockpit",
        Price = 0,
        Category = "Cockpits",
        Description = "Standard fighter cockpit",
        BlockType = "Cockpit",
        Size = Vector3.new(4, 2, 6),
        Color = Color3.fromRGB(100, 100, 100),
        IsCockpit = true,
        Health = 100
    },
    {
        Name = "Advanced Cockpit",
        Price = 5000,
        Category = "Cockpits",
        Description = "Reinforced cockpit with better durability",
        BlockType = "Cockpit",
        Size = Vector3.new(4, 2, 6),
        Color = Color3.fromRGB(50, 50, 70),
        IsCockpit = true,
        Health = 200
    },
    {
        Name = "Stealth Cockpit",
        Price = 15000,
        Category = "Cockpits",
        Description = "Lightweight stealth cockpit",
        BlockType = "Cockpit",
        Size = Vector3.new(4, 2, 5),
        Color = Color3.fromRGB(30, 30, 30),
        IsCockpit = true,
        Health = 150,
        Transparency = 0.3
    },

    -- WINGS
    {
        Name = "Standard Wing",
        Price = 0,
        Category = "Wings",
        Description = "Basic wing for stability",
        BlockType = "Wing",
        Size = Vector3.new(12, 0.5, 4),
        Color = Color3.fromRGB(200, 200, 200),
        Maneuverability = 1.0,
        LiftPower = 50
    },
    {
        Name = "Delta Wing",
        Price = 3000,
        Category = "Wings",
        Description = "High-speed delta wing",
        BlockType = "Wing",
        Size = Vector3.new(10, 0.5, 6),
        Color = Color3.fromRGB(180, 180, 180),
        Maneuverability = 1.3,
        LiftPower = 70
    },
    {
        Name = "Swept Wing",
        Price = 8000,
        Category = "Wings",
        Description = "Agile swept wing design",
        BlockType = "Wing",
        Size = Vector3.new(14, 0.5, 3),
        Color = Color3.fromRGB(160, 160, 160),
        Maneuverability = 1.8,
        LiftPower = 60
    },

    -- ENGINES
    {
        Name = "Basic Engine",
        Price = 0,
        Category = "Engines",
        Description = "Standard jet engine",
        BlockType = "Engine",
        Size = Vector3.new(3, 3, 4),
        Color = Color3.fromRGB(150, 75, 0),
        ThrustPower = 500,
        MaxSpeed = 100
    },
    {
        Name = "Turbo Engine",
        Price = 4000,
        Category = "Engines",
        Description = "High-thrust turbine engine",
        BlockType = "Engine",
        Size = Vector3.new(3, 3, 5),
        Color = Color3.fromRGB(200, 100, 0),
        ThrustPower = 1000,
        MaxSpeed = 150
    },
    {
        Name = "Afterburner Engine",
        Price = 12000,
        Category = "Engines",
        Description = "Extreme speed afterburner",
        BlockType = "Engine",
        Size = Vector3.new(4, 4, 6),
        Color = Color3.fromRGB(255, 50, 0),
        ThrustPower = 2000,
        MaxSpeed = 250
    },

    -- WEAPONS
    {
        Name = "Machine Gun",
        Price = 2000,
        Category = "Weapons",
        Description = "Rapid-fire machine gun",
        BlockType = "Weapon",
        Size = Vector3.new(1, 1, 4),
        Color = Color3.fromRGB(50, 50, 50),
        WeaponType = "Gun",
        Damage = 10,
        FireRate = 0.1,
        Range = 500
    },
    {
        Name = "Missile Launcher",
        Price = 8000,
        Category = "Weapons",
        Description = "Homing missile launcher",
        BlockType = "Weapon",
        Size = Vector3.new(2, 1, 3),
        Color = Color3.fromRGB(100, 50, 50),
        WeaponType = "Missile",
        Damage = 50,
        FireRate = 2.0,
        Range = 1000,
        MissileSpeed = 200
    },
    {
        Name = "Cannon",
        Price = 5000,
        Category = "Weapons",
        Description = "Heavy cannon - slow but powerful",
        BlockType = "Weapon",
        Size = Vector3.new(2, 2, 5),
        Color = Color3.fromRGB(80, 80, 80),
        WeaponType = "Cannon",
        Damage = 35,
        FireRate = 0.5,
        Range = 600
    },

    -- BODY PARTS
    {
        Name = "Fuselage Block",
        Price = 0,
        Category = "Body Parts",
        Description = "Basic body block",
        BlockType = "Body",
        Size = Vector3.new(4, 3, 6),
        Color = Color3.fromRGB(180, 180, 180)
    },
    {
        Name = "Tail Fin",
        Price = 500,
        Category = "Body Parts",
        Description = "Vertical stabilizer",
        BlockType = "TailFin",
        Size = Vector3.new(0.5, 4, 3),
        Color = Color3.fromRGB(200, 200, 200),
        Stability = 1.5
    },
    {
        Name = "Nose Cone",
        Price = 800,
        Category = "Body Parts",
        Description = "Aerodynamic nose cone",
        BlockType = "Nose",
        Size = Vector3.new(3, 2, 4),
        Color = Color3.fromRGB(220, 220, 220),
        SpeedBonus = 10
    },
    {
        Name = "Armor Plate",
        Price = 3000,
        Category = "Body Parts",
        Description = "Heavy armor plating",
        BlockType = "Armor",
        Size = Vector3.new(4, 3, 4),
        Color = Color3.fromRGB(100, 100, 120),
        ArmorBonus = 50
    }
}

-- Get all items in a specific category
function ShopCatalog:GetItemsByCategory(category)
    local items = {}
    for _, item in ipairs(ShopCatalog.Items) do
        if item.Category == category then
            table.insert(items, item)
        end
    end
    return items
end

-- Get a specific item by name
function ShopCatalog:GetItem(itemName)
    for _, item in ipairs(ShopCatalog.Items) do
        if item.Name == itemName then
            return item
        end
    end
    return nil
end

return ShopCatalog
