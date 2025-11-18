-- BuildingSystem.lua
-- Base building system with grid snapping, block placement, and deletion

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Load block catalog
local BlockCatalog = require(ReplicatedStorage.Modules.BlockCatalog)

-- Building system state
local BuildingSystem = {
	IsBuilding = false,
	CurrentBlock = nil,
	PreviewPart = nil,
	DeleteMode = false,
	CurrentRotation = 0, -- Rotation in 90-degree increments (0, 90, 180, 270)
	GridSize = BlockCatalog.GridSize,
	MaxPlacementDistance = 100,
	PlacedParts = {} -- Track all placed parts
}

-- Helper function to snap position to grid
function BuildingSystem:SnapToGrid(position)
	local g = self.GridSize
	return Vector3.new(
		math.floor(position.X / g + 0.5) * g,
		math.floor(position.Y / g + 0.5) * g,
		math.floor(position.Z / g + 0.5) * g
	)
end

-- Create a block part based on block data
function BuildingSystem:CreateBlockPart(blockData, isPreview)
	local part

	-- Create different shapes based on block type
	if blockData.Shape == "Block" then
		part = Instance.new("Part")
		part.Shape = Enum.PartType.Block
	elseif blockData.Shape == "Wedge" then
		part = Instance.new("WedgePart")
	elseif blockData.Shape == "CornerWedge" then
		part = Instance.new("CornerWedgePart")
	elseif blockData.Shape == "Cylinder" then
		part = Instance.new("Part")
		part.Shape = Enum.PartType.Cylinder
	elseif blockData.Shape == "Ball" then
		part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
	elseif blockData.Shape == "Doorway" then
		-- Create doorway using negative parts (model)
		part = self:CreateDoorwayModel(blockData, isPreview)
		return part
	elseif blockData.Shape == "Window" or blockData.Shape == "LargeWindow" then
		-- Create window using negative parts (model)
		part = self:CreateWindowModel(blockData, isPreview)
		return part
	elseif blockData.Shape == "Stairs" then
		-- Create stairs using multiple parts (model)
		part = self:CreateStairsModel(blockData, isPreview)
		return part
	else
		part = Instance.new("Part")
	end

	part.Size = blockData.Size
	part.Color = blockData.Color
	part.Material = blockData.Material
	part.Name = blockData.Name
	part.Anchored = true
	part.CanCollide = not isPreview

	if isPreview then
		part.Transparency = 0.5
		part.CanCollide = false
	end

	-- Add attributes for tracking
	part:SetAttribute("IsBasePart", true)
	part:SetAttribute("BlockType", blockData.Name)
	part:SetAttribute("Owner", player.UserId)

	return part
end

-- Create doorway model (wall with door cutout)
function BuildingSystem:CreateDoorwayModel(blockData, isPreview)
	local model = Instance.new("Model")
	model.Name = blockData.Name

	-- Main wall
	local wall = Instance.new("Part")
	wall.Size = blockData.Size
	wall.Color = blockData.Color
	wall.Material = blockData.Material
	wall.Anchored = true
	wall.CanCollide = not isPreview
	wall.Name = "Wall"

	-- Top section above door
	local topSection = Instance.new("Part")
	topSection.Size = Vector3.new(blockData.Size.X, 1, blockData.Size.Z)
	topSection.Color = blockData.Color
	topSection.Material = blockData.Material
	topSection.Anchored = true
	topSection.CanCollide = not isPreview
	topSection.Name = "TopSection"
	topSection.Parent = model

	-- Left section
	local leftSection = Instance.new("Part")
	leftSection.Size = Vector3.new(0.5, 3, blockData.Size.Z)
	leftSection.Color = blockData.Color
	leftSection.Material = blockData.Material
	leftSection.Anchored = true
	leftSection.CanCollide = not isPreview
	leftSection.Name = "LeftSection"
	leftSection.Parent = model

	-- Right section
	local rightSection = Instance.new("Part")
	rightSection.Size = Vector3.new(0.5, 3, blockData.Size.Z)
	rightSection.Color = blockData.Color
	rightSection.Material = blockData.Material
	rightSection.Anchored = true
	rightSection.CanCollide = not isPreview
	rightSection.Name = "RightSection"
	rightSection.Parent = model

	if isPreview then
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = 0.5
				part.CanCollide = false
			end
		end
	end

	-- Set PrimaryPart
	model.PrimaryPart = topSection

	-- Add attributes
	model:SetAttribute("IsBasePart", true)
	model:SetAttribute("BlockType", blockData.Name)
	model:SetAttribute("Owner", player.UserId)

	return model
end

-- Create window model (wall with window cutout)
function BuildingSystem:CreateWindowModel(blockData, isPreview)
	local model = Instance.new("Model")
	model.Name = blockData.Name

	local windowHeight = blockData.Shape == "LargeWindow" and 2.5 or 1.5
	local windowWidth = blockData.Shape == "LargeWindow" and 3 or 2

	-- Top section
	local topSection = Instance.new("Part")
	topSection.Size = Vector3.new(blockData.Size.X, (blockData.Size.Y - windowHeight) / 2, blockData.Size.Z)
	topSection.Color = blockData.Color
	topSection.Material = blockData.Material
	topSection.Anchored = true
	topSection.CanCollide = not isPreview
	topSection.Name = "TopSection"
	topSection.Parent = model

	-- Bottom section
	local bottomSection = Instance.new("Part")
	bottomSection.Size = Vector3.new(blockData.Size.X, (blockData.Size.Y - windowHeight) / 2, blockData.Size.Z)
	bottomSection.Color = blockData.Color
	bottomSection.Material = blockData.Material
	bottomSection.Anchored = true
	bottomSection.CanCollide = not isPreview
	bottomSection.Name = "BottomSection"
	bottomSection.Parent = model

	-- Left section
	local leftSection = Instance.new("Part")
	leftSection.Size = Vector3.new((blockData.Size.X - windowWidth) / 2, windowHeight, blockData.Size.Z)
	leftSection.Color = blockData.Color
	leftSection.Material = blockData.Material
	leftSection.Anchored = true
	leftSection.CanCollide = not isPreview
	leftSection.Name = "LeftSection"
	leftSection.Parent = model

	-- Right section
	local rightSection = Instance.new("Part")
	rightSection.Size = Vector3.new((blockData.Size.X - windowWidth) / 2, windowHeight, blockData.Size.Z)
	rightSection.Color = blockData.Color
	rightSection.Material = blockData.Material
	rightSection.Anchored = true
	rightSection.CanCollide = not isPreview
	rightSection.Name = "RightSection"
	rightSection.Parent = model

	if isPreview then
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = 0.5
				part.CanCollide = false
			end
		end
	end

	model.PrimaryPart = topSection

	model:SetAttribute("IsBasePart", true)
	model:SetAttribute("BlockType", blockData.Name)
	model:SetAttribute("Owner", player.UserId)

	return model
end

-- Create stairs model (multiple steps)
function BuildingSystem:CreateStairsModel(blockData, isPreview)
	local model = Instance.new("Model")
	model.Name = blockData.Name

	local numSteps = 4
	local stepHeight = blockData.Size.Y / numSteps
	local stepDepth = blockData.Size.Z / numSteps

	for i = 1, numSteps do
		local step = Instance.new("Part")
		step.Size = Vector3.new(blockData.Size.X, stepHeight, stepDepth * i)
		step.Color = blockData.Color
		step.Material = blockData.Material
		step.Anchored = true
		step.CanCollide = not isPreview
		step.Name = "Step" .. i
		step.Parent = model

		if isPreview then
			step.Transparency = 0.5
			step.CanCollide = false
		end

		if i == 1 then
			model.PrimaryPart = step
		end
	end

	model:SetAttribute("IsBasePart", true)
	model:SetAttribute("BlockType", blockData.Name)
	model:SetAttribute("Owner", player.UserId)

	return model
end

-- Position doorway parts correctly
function BuildingSystem:PositionDoorwayParts(model, position, rotation)
	local parts = model:GetChildren()
	local cframe = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation), 0)

	for _, part in ipairs(parts) do
		if part:IsA("BasePart") then
			if part.Name == "TopSection" then
				part.CFrame = cframe * CFrame.new(0, 1.5, 0)
			elseif part.Name == "LeftSection" then
				part.CFrame = cframe * CFrame.new(-1.75, -0.5, 0)
			elseif part.Name == "RightSection" then
				part.CFrame = cframe * CFrame.new(1.75, -0.5, 0)
			end
		end
	end
end

-- Position window parts correctly
function BuildingSystem:PositionWindowParts(model, position, rotation, blockData)
	local parts = model:GetChildren()
	local cframe = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation), 0)

	local windowHeight = blockData.Shape == "LargeWindow" and 2.5 or 1.5
	local windowWidth = blockData.Shape == "LargeWindow" and 3 or 2

	for _, part in ipairs(parts) do
		if part:IsA("BasePart") then
			if part.Name == "TopSection" then
				local yOffset = blockData.Size.Y / 2 - part.Size.Y / 2
				part.CFrame = cframe * CFrame.new(0, yOffset, 0)
			elseif part.Name == "BottomSection" then
				local yOffset = -(blockData.Size.Y / 2 - part.Size.Y / 2)
				part.CFrame = cframe * CFrame.new(0, yOffset, 0)
			elseif part.Name == "LeftSection" then
				local xOffset = -(blockData.Size.X / 2 - part.Size.X / 2)
				part.CFrame = cframe * CFrame.new(xOffset, 0, 0)
			elseif part.Name == "RightSection" then
				local xOffset = blockData.Size.X / 2 - part.Size.X / 2
				part.CFrame = cframe * CFrame.new(xOffset, 0, 0)
			end
		end
	end
end

-- Position stairs parts correctly
function BuildingSystem:PositionStairsParts(model, position, rotation, blockData)
	local parts = model:GetChildren()
	local cframe = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation), 0)

	local numSteps = 4
	local stepHeight = blockData.Size.Y / numSteps
	local stepDepth = blockData.Size.Z / numSteps

	for i, part in ipairs(parts) do
		if part:IsA("BasePart") and part.Name:match("Step") then
			local stepNum = tonumber(part.Name:match("%d+"))
			if stepNum then
				local yOffset = -blockData.Size.Y / 2 + stepHeight * stepNum - stepHeight / 2
				local zOffset = -blockData.Size.Z / 2 + (stepDepth * stepNum) / 2
				part.CFrame = cframe * CFrame.new(0, yOffset, zOffset)
			end
		end
	end
end

-- Create preview block
function BuildingSystem:CreatePreview()
	if self.PreviewPart then
		self.PreviewPart:Destroy()
	end

	if not self.CurrentBlock then return end

	self.PreviewPart = self:CreateBlockPart(self.CurrentBlock, true)
	self.PreviewPart.Parent = workspace

	-- Add selection box for visual feedback
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.LineThickness = 0.05
	selectionBox.Color3 = Color3.fromRGB(0, 255, 0)
	selectionBox.SurfaceTransparency = 0.8

	if self.PreviewPart:IsA("Model") then
		selectionBox.Adornee = self.PreviewPart.PrimaryPart
	else
		selectionBox.Adornee = self.PreviewPart
	end

	selectionBox.Parent = self.PreviewPart
end

-- Check if placement position is valid (no overlap)
function BuildingSystem:IsValidPlacement(position)
	if not self.CurrentBlock then return false end

	-- Check distance from player
	local character = player.Character
	if not character or not character.PrimaryPart then return false end

	local distance = (position - character.PrimaryPart.Position).Magnitude
	if distance > self.MaxPlacementDistance then
		return false
	end

	-- Check for overlapping parts
	local size = self.CurrentBlock.Size
	local region = Region3.new(position - size/2, position + size/2)
	region = region:ExpandToGrid(4)

	local partsInRegion = workspace:FindPartsInRegion3(region, nil, 100)

	for _, part in ipairs(partsInRegion) do
		-- Ignore terrain, preview, and non-building parts
		if part ~= self.PreviewPart and
		   part:GetAttribute("IsBasePart") and
		   not part:IsDescendantOf(self.PreviewPart) then

			-- Allow placement if parts are far enough apart (allow adjacent placement)
			local partPosition = part.Position
			local distance = (position - partPosition).Magnitude
			local minDistance = (size.Magnitude + part.Size.Magnitude) / 4

			if distance < minDistance then
				return false
			end
		end
	end

	return true
end

-- Update preview position and visuals
function BuildingSystem:UpdatePreview()
	if not self.IsBuilding or not self.PreviewPart or not self.CurrentBlock then return end

	-- Raycast from camera through mouse
	local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {self.PreviewPart, player.Character}

	local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)

	if raycastResult then
		-- Snap to grid
		local position = self:SnapToGrid(raycastResult.Position)

		-- Offset position based on block size to place on surface
		local offset = Vector3.new(0, self.CurrentBlock.Size.Y / 2, 0)
		position = position + offset

		-- Update preview position with rotation
		if self.PreviewPart:IsA("Model") then
			if self.CurrentBlock.Shape == "Doorway" then
				self:PositionDoorwayParts(self.PreviewPart, position, self.CurrentRotation)
			elseif self.CurrentBlock.Shape == "Window" or self.CurrentBlock.Shape == "LargeWindow" then
				self:PositionWindowParts(self.PreviewPart, position, self.CurrentRotation, self.CurrentBlock)
			elseif self.CurrentBlock.Shape == "Stairs" then
				self:PositionStairsParts(self.PreviewPart, position, self.CurrentRotation, self.CurrentBlock)
			else
				self.PreviewPart:SetPrimaryPartCFrame(CFrame.new(position) * CFrame.Angles(0, math.rad(self.CurrentRotation), 0))
			end
		else
			self.PreviewPart.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(self.CurrentRotation), 0)
		end

		-- Update color based on validity
		local selectionBox = self.PreviewPart:FindFirstChildOfClass("SelectionBox")
		if selectionBox then
			if self:IsValidPlacement(position) then
				selectionBox.Color3 = Color3.fromRGB(0, 255, 0) -- Green = valid
			else
				selectionBox.Color3 = Color3.fromRGB(255, 0, 0) -- Red = invalid
			end
		end
	end
end

-- Place block at current preview position
function BuildingSystem:PlaceBlock()
	if not self.PreviewPart or not self.CurrentBlock then return end

	local position
	if self.PreviewPart:IsA("Model") then
		position = self.PreviewPart.PrimaryPart.Position
	else
		position = self.PreviewPart.Position
	end

	if not self:IsValidPlacement(position) then
		warn("Invalid placement position")
		return
	end

	-- Create actual block
	local newBlock = self:CreateBlockPart(self.CurrentBlock, false)
	newBlock.Parent = workspace

	-- Position with rotation
	if newBlock:IsA("Model") then
		if self.CurrentBlock.Shape == "Doorway" then
			self:PositionDoorwayParts(newBlock, position, self.CurrentRotation)
		elseif self.CurrentBlock.Shape == "Window" or self.CurrentBlock.Shape == "LargeWindow" then
			self:PositionWindowParts(newBlock, position, self.CurrentRotation, self.CurrentBlock)
		elseif self.CurrentBlock.Shape == "Stairs" then
			self:PositionStairsParts(newBlock, position, self.CurrentRotation, self.CurrentBlock)
		else
			newBlock:SetPrimaryPartCFrame(CFrame.new(position) * CFrame.Angles(0, math.rad(self.CurrentRotation), 0))
		end
	else
		newBlock.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(self.CurrentRotation), 0)
	end

	-- Track placed part
	table.insert(self.PlacedParts, newBlock)

	print("Placed block:", self.CurrentBlock.Name, "at", position)
end

-- Delete block under mouse
function BuildingSystem:DeleteBlock()
	-- Raycast from camera through mouse
	local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {player.Character}

	local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)

	if raycastResult and raycastResult.Instance then
		local part = raycastResult.Instance

		-- Check if it's a building part owned by player
		local owner = part:GetAttribute("Owner")
		local isBasePart = part:GetAttribute("IsBasePart")

		-- Check parent model if part itself isn't marked
		if not isBasePart and part.Parent:IsA("Model") then
			owner = part.Parent:GetAttribute("Owner")
			isBasePart = part.Parent:GetAttribute("IsBasePart")
			if isBasePart then
				part = part.Parent
			end
		end

		if isBasePart and owner == player.UserId then
			-- Remove from tracked parts
			for i, trackedPart in ipairs(self.PlacedParts) do
				if trackedPart == part then
					table.remove(self.PlacedParts, i)
					break
				end
			end

			part:Destroy()
			print("Deleted block")
		else
			warn("Cannot delete: not owned by you or not a building part")
		end
	end
end

-- Rotate preview block
function BuildingSystem:RotatePreview()
	self.CurrentRotation = (self.CurrentRotation + 90) % 360
	print("Rotation:", self.CurrentRotation)
end

-- Start building with selected block
function BuildingSystem:StartBuilding(blockData)
	self.IsBuilding = true
	self.CurrentBlock = blockData
	self.CurrentRotation = 0
	self:CreatePreview()
	print("Started building with:", blockData.Name)
end

-- Stop building
function BuildingSystem:StopBuilding()
	self.IsBuilding = false
	self.CurrentBlock = nil
	self.CurrentRotation = 0

	if self.PreviewPart then
		self.PreviewPart:Destroy()
		self.PreviewPart = nil
	end

	print("Stopped building")
end

-- Toggle delete mode
function BuildingSystem:ToggleDeleteMode()
	self.DeleteMode = not self.DeleteMode
	print("Delete mode:", self.DeleteMode)

	-- Fire event to update UI
	local toggleEvent = ReplicatedStorage:FindFirstChild("ToggleDeleteMode")
	if toggleEvent then
		toggleEvent:Fire(self.DeleteMode)
	end
end

-- Handle user input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	-- R key - Rotate
	if input.KeyCode == Enum.KeyCode.R and BuildingSystem.IsBuilding then
		BuildingSystem:RotatePreview()
	end

	-- X key - Toggle delete mode
	if input.KeyCode == Enum.KeyCode.X then
		BuildingSystem:ToggleDeleteMode()
	end

	-- Escape key - Stop building
	if input.KeyCode == Enum.KeyCode.Escape and BuildingSystem.IsBuilding then
		BuildingSystem:StopBuilding()
	end
end)

-- Handle mouse click
mouse.Button1Down:Connect(function()
	if BuildingSystem.DeleteMode then
		-- Delete mode
		BuildingSystem:DeleteBlock()
	elseif BuildingSystem.IsBuilding then
		-- Place mode
		BuildingSystem:PlaceBlock()
	end
end)

-- Update preview every frame
RunService.RenderStepped:Connect(function()
	if BuildingSystem.IsBuilding then
		BuildingSystem:UpdatePreview()
	end
end)

-- Expose to global for UI to access
_G.BuildingSystem = BuildingSystem

print("BuildingSystem loaded")

return BuildingSystem
