# 99 Nights in the Forest - Roblox Survival Horror Game

A survival horror game inspired by "99 Nights in the Forest" where players must survive 99 nights in a dark forest, managing resources, fighting enemies, and keeping their campfire burning.

## 🎮 Game Overview

Survive 99 nights in a haunted forest by managing your survival stats, gathering resources, maintaining your campfire, and defending against nighttime creatures. Each night brings increasing danger, and you must balance exploration during the day with survival at night.

## ✨ Current Features

### Core Survival Mechanics
- **Day/Night Cycle System**: 5-minute days for gathering, 4-minute nights for survival
- **Campfire Management**: Central survival mechanic - must keep the fire fueled to survive
- **Survival Stats**: Hunger, Sanity, Temperature, and Health tracking
- **Resource Gathering**: Collect wood, stone, and berries from the forest

### Player Systems
- **Inventory System**: Track collected resources and items
- **Stat Drain**: Hunger drains constantly, sanity drops at night
- **Damage from Low Stats**: Take damage when hunger or temperature are too low
- **Campfire Healing**: Regenerate health near lit campfires

### Environment
- **Procedural Forest**: Hundreds of trees spawned around the map
- **Resource Nodes**: Trees (wood), Rocks (stone), Berry Bushes (food)
- **Atmospheric Effects**: Dynamic lighting, fog, and visual transitions
- **Large Playable Area**: 500x500 stud forest environment

### UI Systems
- **Survival Stats Display**: Real-time health, hunger, sanity, and temperature bars
- **Night Counter**: Shows current night and time remaining
- **Inventory UI**: Press Tab to view full inventory and use items
- **Quick Resources**: Always-visible resource counter
- **Dusk Warning**: Alert when night is approaching

## 🎯 Controls

| Key | Action |
|-----|--------|
| **WASD** | Move |
| **Space** | Jump |
| **E** | Interact (gather resources, add fuel to campfire) |
| **Tab** | Open/Close Inventory |
| **B** | Build Menu (legacy system) |

## 🎯 Planned Features (Not Yet Implemented)

### Enemies
- **The Deer**: Main antagonist that stalks players at night
- **Cultists**: Hostile humans that attack the campfire
- **Wildlife**: Wolves, bears, and other dangerous animals
- **Jumpscare System**: Horror elements for enemy encounters

### Combat & Weapons
- **Melee Weapons**: Axe, spear for close combat
- **Ranged Weapons**: Bow, pistol, rifle for defense
- **Weapon Crafting**: Combine resources to create weapons
- **Ammo Management**: Track arrows and bullets

### Quest System
- **Missing Children**: Rescue 4 lost children to reduce nights needed
- **Progression System**: Each child rescued reduces required nights by 20

### Advanced Features
- **Biome System**: Volcanic and Snow biomes with unique challenges
- **Echo System**: Harness forest spirits for weapon upgrades
- **Temperature Management**: Freeze in snow biome, overheat in volcanic
- **Building System**: Construct shelters and defenses
- **Multiplayer Scaling**: Difficulty increases with player count

## 📂 Project Structure

```
venice-backend/
├── ServerScriptService/
│   ├── GameController.lua           # Main game initialization
│   ├── DayNightCycle.lua           # Day/night cycle management
│   ├── CampfireSystem.lua          # Campfire mechanics
│   ├── PlayerStatsSystem.lua       # Player survival stats
│   ├── ResourceSystem.lua          # Resource gathering & inventory
│   └── WorkspaceSetup.lua          # Forest environment generation
├── ReplicatedStorage/Modules/
│   ├── GameConfig.lua              # Centralized configuration
│   └── BlockCatalog.lua            # (Legacy building system)
├── StarterGui/
│   ├── SurvivalUI.lua              # Stats and timer display
│   ├── InventoryUI.lua             # Inventory management UI
│   └── BuildingGui/                # (Legacy building system)
└── StarterPlayer/StarterPlayerScripts/
    └── BuildingSystem.lua          # (Legacy building system)
```

## 🚀 How to Play

### Starting the Game
1. Players spawn in the center of the forest near the campfire
2. Start with 10 wood and 3 berries in inventory
3. First night begins after 5 minutes

### During the Day (5 minutes)
1. **Gather Resources**:
   - Chop trees for wood (hold E on trees)
   - Mine rocks for stone (hold E on rocks)
   - Gather berries for food (hold E on bushes)
2. **Manage Hunger**: Eat berries to restore hunger (Tab → Eat)
3. **Prepare for Night**: Stock up on wood for the campfire

### During the Night (4 minutes)
1. **Stay Near Campfire**: Heal and stay warm near the fire
2. **Feed the Campfire**: Use wood to keep fuel above 0
3. **Monitor Stats**: Watch hunger and sanity levels
4. **Survive**: If campfire goes out, you're vulnerable

### Winning the Game
- Survive 99 nights (currently no enemies, so focus on stat management)
- Future: Rescue all 4 missing children to reduce nights needed

## 🔧 Configuration

All game settings are centralized in `ReplicatedStorage/Modules/GameConfig.lua`:

### Key Settings
- **Total Nights**: 99 (can be adjusted for testing)
- **Day Length**: 300 seconds (5 minutes)
- **Night Length**: 240 seconds (4 minutes)
- **Campfire Fuel Drain**: 0.5 per second during night
- **Hunger Drain**: 0.1 per second (constant)
- **Sanity Drain**: 0.3 per second at night

### Resource Values
- **Wood per Tree**: 10
- **Stone per Rock**: 5
- **Berries Hunger Restore**: 10
- **Wood Fuel Amount**: 20

## 💀 Death Conditions

- Health reaches 0
- Hunger drops below 20 (causes damage over time)
- Temperature drops below 20 (causes freezing damage)
- Future: Killed by enemies

## 🔥 Campfire Mechanics

The campfire is the heart of the game:

### Functions
- **Heals Players**: Restores 2 HP/second within 15 studs
- **Provides Light**: Illuminates the area at night
- **Fuel Management**: Holds max 100 fuel, drains 0.5/second at night
- **Adding Fuel**: Costs 1 wood, adds 20 fuel

### States
- **Lit**: Fire visible, provides healing and light
- **Extinguished**: No fire, no healing, very dangerous at night

## 📊 Stats Explained

### Health (Max 100)
- Reduced by hunger damage, freezing, and enemy attacks
- Regenerates near lit campfire (2/second)

### Hunger (Max 100)
- Drains constantly at 0.1/second
- Restore by eating berries (10), raw meat (15), or cooked meat (30)
- Below 20: Take 1 damage/second

### Sanity (Max 100)
- Drains at night (0.3/second)
- Extra drain when near enemies (0.5/second)
- Below 30: Visual effects (planned)
- Recovers slowly during day (0.2/second)

### Temperature (Max 100)
- Affected by biome (snow drains, volcanic raises)
- Campfire warms you up (0.5/second)
- Below 20: Take 2 freezing damage/second

## 🛠️ Development Status

### ✅ Completed Systems
- [x] Core game configuration
- [x] Day/night cycle with dynamic lighting
- [x] Campfire placement and fuel management
- [x] Player survival stats (health, hunger, sanity, temperature)
- [x] Survival UI with stat bars and timers
- [x] Forest environment generation
- [x] Resource gathering (trees, rocks, berries)
- [x] Inventory system with UI
- [x] Proximity-based interactions

### 🚧 Planned Next
- [ ] Enemy AI system
- [ ] Weapon and combat mechanics
- [ ] Missing children quest system
- [ ] Biome system (volcanic, snow)
- [ ] Advanced building integration
- [ ] Save/load system
- [ ] Sound effects and music

## 🧪 Testing Tips

### Quick Testing Adjustments
To test faster, edit `GameConfig.lua`:

```lua
-- Shorter days/nights for testing
GameConfig.DAY_LENGTH_SECONDS = 30  -- 30 second days
GameConfig.NIGHT_LENGTH_SECONDS = 20  -- 20 second nights

-- Less nights needed
GameConfig.TOTAL_NIGHTS_REQUIRED = 5  -- Win after 5 nights

-- Slower stat drain
GameConfig.HUNGER_DRAIN_PER_SECOND = 0.01  -- Very slow hunger
```

## 📝 Notes

- This is a work in progress - core survival mechanics are complete
- Enemy system and combat are planned for next phase
- Building system from previous version is still present but not integrated
- Game is playable in current state with focus on resource management

## 🤝 Credits

Inspired by the Roblox game "99 Nights in the Forest"

## 📜 Version History

**v0.1 - Initial Survival Framework** (Current)
- Core survival mechanics
- Day/night cycle
- Campfire system
- Basic resource gathering
- Player stats and UI
- Forest environment

---

**Good luck surviving the forest! 🌲🔥💀**
