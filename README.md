# Base Building Game

A complete Roblox base building system with grid snapping, 24+ block types, and intuitive controls!

## 🎮 Quick Start

1. **Install in Roblox Studio**
2. **Press Play** to test
3. **Press B** to open the build menu
4. **Click a block** to start building
5. **Click** to place blocks
6. **Press R** to rotate
7. **Press X** to delete blocks

## ✨ Features

- 🏗️ **24 Different Block Types** - Foundations, walls, roofs, stairs, decorative pieces
- 📐 **Grid Snapping** - Automatic 4-stud grid for perfect alignment
- 🎨 **Real-time Preview** - Green/red indicators for valid placement
- 🔄 **Block Rotation** - Rotate blocks with R key
- 🗑️ **Delete Mode** - Remove blocks with X key
- 🎯 **Collision Detection** - Smart overlap prevention
- 🆓 **Free Building** - Unlimited blocks, no currency needed

## 🎯 Controls

| Key/Action | Function |
|------------|----------|
| **B** | Open/close block menu |
| **Left Click** | Place block or delete (in delete mode) |
| **R** | Rotate block 90 degrees |
| **X** | Toggle delete mode |
| **ESC** | Exit building mode |

## 📦 Block Categories

### Foundations & Floors (3 types)
- Foundation, Floor, Large Floor

### Walls (3 types)
- Standard Wall, Tall Wall, Corner Wall

### Openings (3 types)
- Doorway, Window Wall, Large Window

### Roofs (3 types)
- Angled Roof, Roof Corner, Flat Roof

### Stairs & Ramps (3 types)
- Ramp, Stairs, Small Ramp

### Decorative (9 types)
- Cubes, Spheres, Pillars, Platforms, Beams

## 📁 Installation

### Method 1: Copy Files Directly

1. Open your Roblox Studio place
2. Copy the scripts into these locations:

```
📁 ServerScriptService
   └── WorkspaceSetup.lua           (Script)

📁 ReplicatedStorage
   └── 📁 Modules
       └── BlockCatalog.lua         (ModuleScript)

📁 StarterPlayer
   └── 📁 StarterPlayerScripts
       └── BuildingSystem.lua       (LocalScript)

📁 StarterGui
   └── 📁 BuildingGui
       └── BuildingGui.lua          (LocalScript)
```

### Method 2: Quick Setup

1. Create the folder structure above
2. Copy each `.lua` file to its corresponding location
3. Make sure to use the correct script types (see above)
4. Press **Play** and test!

## 🏗️ Project Structure

```
venice-backend/
├── ServerScriptService/
│   └── WorkspaceSetup.lua              # Creates build plate and environment
│
├── ReplicatedStorage/
│   └── Modules/
│       └── BlockCatalog.lua            # All block definitions (24 blocks)
│
├── StarterPlayer/StarterPlayerScripts/
│   └── BuildingSystem.lua              # Core building logic (600+ lines)
│
├── StarterGui/
│   └── BuildingGui/
│       └── BuildingGui.lua             # User interface and menus
│
└── Documentation/
    ├── README.md                       # This file
    ├── BUILDING_SYSTEM_GUIDE.md        # Complete user guide
    └── TROUBLESHOOTING.md              # Common issues and fixes
```

## 🎓 How to Use

### Building Your First Structure

1. **Open Menu**: Press **B** to open the block menu
2. **Select Block**: Click on any block type (e.g., "Foundation")
3. **Position**: Move your mouse to see the preview
   - **Green outline** = Valid placement
   - **Red outline** = Invalid (overlapping or too far)
4. **Rotate**: Press **R** to rotate the block
5. **Place**: Click to place the block
6. **Repeat**: Select more blocks and keep building!

### Deleting Blocks

1. **Enable Delete Mode**: Press **X**
2. **Click Block**: Click on any block you placed to delete it
3. **Exit Delete Mode**: Press **X** again

## 🔧 Customization

### Adding New Blocks

Edit `/ReplicatedStorage/Modules/BlockCatalog.lua`:

```lua
{
    Name = "Custom Block",
    Category = "Custom",
    Description = "Your custom block",
    Size = Vector3.new(4, 4, 4),
    Color = Color3.fromRGB(255, 100, 100),
    Material = Enum.Material.Plastic,
    Price = 0,
    Shape = "Block"
}
```

### Changing Grid Size

In `BlockCatalog.lua`, change:
```lua
BlockCatalog.GridSize = 4  -- Change to desired grid size
```

### Adjusting Max Distance

In `BuildingSystem.lua`, change:
```lua
MaxPlacementDistance = 100,  -- Change to desired distance
```

## 🐛 Troubleshooting

### Build menu won't open
- ✅ Check that `BuildingGui.lua` is a **LocalScript** in StarterGui
- ✅ Check console (F9) for errors
- ✅ Make sure `BlockCatalog.lua` is in ReplicatedStorage/Modules

### Blocks won't place (red preview)
- ✅ You might be too far away (max 100 studs)
- ✅ Block might be overlapping with another block
- ✅ Try a different position

### Can't delete blocks
- ✅ Make sure delete mode is ON (press X)
- ✅ You can only delete blocks you placed
- ✅ Click directly on the block

### Preview not showing
- ✅ Make sure you selected a block from the menu
- ✅ Check if `BuildingSystem.lua` loaded (check console)
- ✅ Try pressing B to reopen the menu

## 📚 Documentation

- **BUILDING_SYSTEM_GUIDE.md** - Complete feature documentation
- **TROUBLESHOOTING.md** - Detailed troubleshooting guide

## 🎯 Technical Details

- **Grid System**: 4-stud grid snapping
- **Collision**: Region3-based detection
- **Ownership**: UserId-based block ownership
- **Max Distance**: 100 studs from player
- **Block Types**: 24 pre-configured blocks
- **Categories**: 7 organized categories

## 🚀 Future Features

Potential additions:
- Save/load builds to DataStore
- Building templates
- Color customization
- Team building permissions
- Block limits per player
- Build zones/plots
- Material variants

## 📝 License

Free to use and modify for your Roblox games!

## 💡 Tips

- **Start with Foundations**: Build a solid base first
- **Use Grid Snapping**: Blocks automatically align perfectly
- **Plan Ahead**: Think about your structure before building
- **Rotate Early**: Press R before placing to set rotation
- **Delete Mode**: Use X for quick deletion instead of selecting each block

## 🎮 Have Fun Building!

This system is designed to be simple yet powerful. Start with basic structures and work your way up to complex buildings. Happy building! 🏗️
