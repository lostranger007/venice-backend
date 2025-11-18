# Base Building System Guide

## Overview
A complete base building system for Roblox with grid snapping, multiple block types, and intuitive controls.

## Features
- ✅ **24 Different Block Types** across 7 categories
- ✅ **Grid Snapping** (4-stud large grid for structural building)
- ✅ **Smart Collision Detection** (prevents overlapping)
- ✅ **Block Rotation** (90-degree increments)
- ✅ **Delete Mode** (remove placed blocks)
- ✅ **Free Building** (unlimited blocks, no currency system)
- ✅ **Real-time Preview** (green = valid, red = invalid placement)

## Controls

### Building Controls
- **B Key** or **BUILD Button** - Open/close block selection menu
- **Left Click** - Place block at preview location
- **R Key** - Rotate preview block 90 degrees
- **X Key** - Toggle delete mode on/off
- **ESC Key** - Exit building mode

### Delete Mode
- **X Key** - Toggle delete mode
- **Left Click** (in delete mode) - Delete clicked block

## Block Categories

### 1. Foundations (3 types)
- **Foundation** - Large 4x4x1 concrete base
- **Floor** - Thin 4x4x0.5 wooden floor
- **Large Floor** - 8x8x0.5 large platform

### 2. Walls (3 types)
- **Wall** - Standard 4x4x0.5 brick wall
- **Tall Wall** - 8 studs high wall
- **Corner Wall** - L-shaped corner piece

### 3. Openings (3 types)
- **Doorway** - Wall with door cutout
- **Window Wall** - Wall with small window
- **Large Window** - Wall with large window opening

### 4. Roofs (3 types)
- **Roof** - Angled slate roof piece
- **Roof Corner** - Corner roof piece
- **Flat Roof** - Flat concrete roof

### 5. Stairs (3 types)
- **Ramp** - Angled ramp (2 studs high)
- **Stairs** - Multi-step staircase
- **Small Ramp** - Small 1-stud ramp

### 6. Decorative (8 types)
- **Small Cube** - 1x1x1 cube
- **Medium Cube** - 2x2x2 cube
- **Large Cube** - 4x4x4 cube
- **Pillar** - Tall 1x8x1 marble pillar
- **Platform** - 2x0.5x2 small platform
- **Sphere** - 2x2x2 decorative sphere
- **Beam** - 8x0.5x0.5 horizontal beam

## How to Use

### Basic Building
1. Press **B** to open the build menu
2. Click on any block type to select it
3. Move your mouse to position the preview
4. Press **R** to rotate if needed
5. Click to place the block

### Deleting Blocks
1. Press **X** to enable delete mode
2. Click on any block you own to delete it
3. Press **X** again to exit delete mode

### Tips
- Blocks snap to a 4-stud grid automatically
- Green preview = valid placement location
- Red preview = invalid (overlapping or too far)
- Maximum placement distance: 100 studs
- You can only delete blocks you placed

## File Structure

```
venice-backend/
├── ReplicatedStorage/
│   └── Modules/
│       └── BlockCatalog.lua          (Block definitions)
│
├── ServerScriptService/
│   └── WorkspaceSetup.lua            (Build plate setup)
│
├── StarterPlayer/StarterPlayerScripts/
│   └── BuildingSystem.lua            (Core building logic)
│
└── StarterGui/
    └── BuildingGui/
        └── BuildingGui.lua           (User interface)
```

## Technical Details

### Grid System
- **Grid Size**: 4 studs (large grid for structural building)
- **Snapping**: Automatic grid snapping on all axes
- **Precision**: Positions rounded to nearest grid point

### Collision Detection
- **System**: Region3-based overlap checking
- **Minimum Distance**: Calculated based on block sizes
- **Adjacent Placement**: Blocks can be placed next to each other

### Ownership System
- All placed blocks are tagged with owner's UserId
- Players can only delete their own blocks
- Attributes: `IsBasePart`, `BlockType`, `Owner`

## Adding New Blocks

To add a new block type, edit `BlockCatalog.lua`:

```lua
{
    Name = "My New Block",
    Category = "Custom",
    Description = "A custom block",
    Size = Vector3.new(4, 4, 4),
    Color = Color3.fromRGB(255, 100, 100),
    Material = Enum.Material.Plastic,
    Price = 0,
    Shape = "Block" -- or "Wedge", "Cylinder", etc.
}
```

### Available Shapes
- `Block` - Standard rectangular block
- `Wedge` - Angled wedge (for ramps/roofs)
- `CornerWedge` - Corner wedge piece
- `Cylinder` - Cylindrical shape
- `Ball` - Sphere shape
- `Doorway` - Multi-part doorway model
- `Window` / `LargeWindow` - Window models
- `Stairs` - Multi-step staircase model

## Troubleshooting

### Block won't place (red preview)
- Check if you're too far away (max 100 studs)
- Check if overlapping with existing block
- Try moving to a different position

### Preview not showing
- Make sure you selected a block from the menu
- Check if BuildingSystem loaded (check console)
- Try pressing B to reopen menu

### Can't delete a block
- Make sure delete mode is ON (press X)
- You can only delete blocks you placed
- Check that you're clicking directly on the block

## Performance Tips
- Limit total placed blocks for better performance
- Use larger blocks instead of many small blocks
- Consider adding a block limit system if needed

## Future Enhancements
Potential features to add:
- Save/load builds (DataStore integration)
- Building templates/blueprints
- Color customization
- Building permissions/teams
- Block limits per player
- Build zones/plots
- Material variants
- Custom block shapes

## Credits
Built for Roblox Base Building Game
Version 1.0
