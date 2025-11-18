-- BlockCatalog.lua
-- Defines all available building blocks for the base building system

local BlockCatalog = {}

-- Grid size for snapping (4 studs for large structural pieces)
BlockCatalog.GridSize = 4

-- Block definitions
BlockCatalog.Blocks = {

	-- FOUNDATIONS & FLOORS
	{
		Name = "Foundation",
		Category = "Foundations",
		Description = "Large foundation block for building bases",
		Size = Vector3.new(4, 1, 4),
		Color = Color3.fromRGB(80, 80, 80),
		Material = Enum.Material.Concrete,
		Price = 0, -- Free building
		Shape = "Block"
	},
	{
		Name = "Floor",
		Category = "Floors",
		Description = "Thin floor platform",
		Size = Vector3.new(4, 0.5, 4),
		Color = Color3.fromRGB(139, 90, 43),
		Material = Enum.Material.Wood,
		Price = 0,
		Shape = "Block"
	},
	{
		Name = "Large Floor",
		Category = "Floors",
		Description = "Large floor platform (8x8)",
		Size = Vector3.new(8, 0.5, 8),
		Color = Color3.fromRGB(139, 90, 43),
		Material = Enum.Material.Wood,
		Price = 0,
		Shape = "Block"
	},

	-- WALLS
	{
		Name = "Wall",
		Category = "Walls",
		Description = "Standard wall segment",
		Size = Vector3.new(4, 4, 0.5),
		Color = Color3.fromRGB(163, 162, 165),
		Material = Enum.Material.Brick,
		Price = 0,
		Shape = "Block"
	},
	{
		Name = "Tall Wall",
		Category = "Walls",
		Description = "Tall wall segment (8 studs high)",
		Size = Vector3.new(4, 8, 0.5),
		Color = Color3.fromRGB(163, 162, 165),
		Material = Enum.Material.Brick,
		Price = 0,
		Shape = "Block"
	},
	{
		Name = "Corner Wall",
		Category = "Walls",
		Description = "L-shaped corner wall",
		Size = Vector3.new(4, 4, 0.5),
		Color = Color3.fromRGB(163, 162, 165),
		Material = Enum.Material.Brick,
		Price = 0,
		Shape = "Block",
		IsCorner = true
	},

	-- DOORWAYS & WINDOWS
	{
		Name = "Doorway",
		Category = "Openings",
		Description = "Wall with doorway cutout",
		Size = Vector3.new(4, 4, 0.5),
		Color = Color3.fromRGB(163, 162, 165),
		Material = Enum.Material.Brick,
		Price = 0,
		Shape = "Doorway"
	},
	{
		Name = "Window Wall",
		Category = "Openings",
		Description = "Wall with window cutout",
		Size = Vector3.new(4, 4, 0.5),
		Color = Color3.fromRGB(163, 162, 165),
		Material = Enum.Material.Brick,
		Price = 0,
		Shape = "Window"
	},
	{
		Name = "Large Window",
		Category = "Openings",
		Description = "Wall with large window opening",
		Size = Vector3.new(4, 4, 0.5),
		Color = Color3.fromRGB(163, 162, 165),
		Material = Enum.Material.Brick,
		Price = 0,
		Shape = "LargeWindow"
	},

	-- ROOFS
	{
		Name = "Roof",
		Category = "Roofs",
		Description = "Angled roof piece",
		Size = Vector3.new(4, 0.5, 4),
		Color = Color3.fromRGB(105, 64, 40),
		Material = Enum.Material.Slate,
		Price = 0,
		Shape = "Wedge"
	},
	{
		Name = "Roof Corner",
		Category = "Roofs",
		Description = "Corner roof piece",
		Size = Vector3.new(4, 2, 4),
		Color = Color3.fromRGB(105, 64, 40),
		Material = Enum.Material.Slate,
		Price = 0,
		Shape = "CornerWedge"
	},
	{
		Name = "Flat Roof",
		Category = "Roofs",
		Description = "Flat roof segment",
		Size = Vector3.new(4, 0.5, 4),
		Color = Color3.fromRGB(70, 70, 70),
		Material = Enum.Material.Concrete,
		Price = 0,
		Shape = "Block"
	},

	-- RAMPS & STAIRS
	{
		Name = "Ramp",
		Category = "Stairs",
		Description = "Angled ramp for walking up",
		Size = Vector3.new(4, 2, 4),
		Color = Color3.fromRGB(163, 162, 165),
		Material = Enum.Material.Concrete,
		Price = 0,
		Shape = "Wedge"
	},
	{
		Name = "Stairs",
		Category = "Stairs",
		Description = "Staircase segment",
		Size = Vector3.new(4, 4, 4),
		Color = Color3.fromRGB(139, 90, 43),
		Material = Enum.Material.Wood,
		Price = 0,
		Shape = "Stairs"
	},
	{
		Name = "Small Ramp",
		Category = "Stairs",
		Description = "Small ramp (2 studs high)",
		Size = Vector3.new(4, 1, 4),
		Color = Color3.fromRGB(163, 162, 165),
		Material = Enum.Material.Concrete,
		Price = 0,
		Shape = "Wedge"
	},

	-- DECORATIVE BLOCKS
	{
		Name = "Small Cube",
		Category = "Decorative",
		Description = "Small decorative cube (1x1x1)",
		Size = Vector3.new(1, 1, 1),
		Color = Color3.fromRGB(170, 170, 170),
		Material = Enum.Material.SmoothPlastic,
		Price = 0,
		Shape = "Block"
	},
	{
		Name = "Medium Cube",
		Category = "Decorative",
		Description = "Medium cube (2x2x2)",
		Size = Vector3.new(2, 2, 2),
		Color = Color3.fromRGB(170, 170, 170),
		Material = Enum.Material.SmoothPlastic,
		Price = 0,
		Shape = "Block"
	},
	{
		Name = "Large Cube",
		Category = "Decorative",
		Description = "Large cube (4x4x4)",
		Size = Vector3.new(4, 4, 4),
		Color = Color3.fromRGB(170, 170, 170),
		Material = Enum.Material.SmoothPlastic,
		Price = 0,
		Shape = "Block"
	},
	{
		Name = "Pillar",
		Category = "Decorative",
		Description = "Tall decorative pillar",
		Size = Vector3.new(1, 8, 1),
		Color = Color3.fromRGB(230, 230, 230),
		Material = Enum.Material.Marble,
		Price = 0,
		Shape = "Cylinder"
	},
	{
		Name = "Platform",
		Category = "Decorative",
		Description = "Small platform (2x0.5x2)",
		Size = Vector3.new(2, 0.5, 2),
		Color = Color3.fromRGB(139, 90, 43),
		Material = Enum.Material.Wood,
		Price = 0,
		Shape = "Block"
	},
	{
		Name = "Sphere",
		Category = "Decorative",
		Description = "Decorative sphere (2x2x2)",
		Size = Vector3.new(2, 2, 2),
		Color = Color3.fromRGB(170, 170, 170),
		Material = Enum.Material.SmoothPlastic,
		Price = 0,
		Shape = "Ball"
	},
	{
		Name = "Beam",
		Category = "Decorative",
		Description = "Long horizontal beam",
		Size = Vector3.new(8, 0.5, 0.5),
		Color = Color3.fromRGB(139, 90, 43),
		Material = Enum.Material.Wood,
		Price = 0,
		Shape = "Block"
	}
}

-- Get all blocks in a specific category
function BlockCatalog:GetBlocksByCategory(category)
	local blocks = {}
	for _, block in ipairs(self.Blocks) do
		if block.Category == category then
			table.insert(blocks, block)
		end
	end
	return blocks
end

-- Get all unique categories
function BlockCatalog:GetCategories()
	local categories = {}
	local seen = {}
	for _, block in ipairs(self.Blocks) do
		if not seen[block.Category] then
			table.insert(categories, block.Category)
			seen[block.Category] = true
		end
	end
	return categories
end

-- Get block by name
function BlockCatalog:GetBlockByName(name)
	for _, block in ipairs(self.Blocks) do
		if block.Name == name then
			return block
		end
	end
	return nil
end

return BlockCatalog
