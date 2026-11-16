# MMA-Online 🥊

A 3D MMA Fighting Game prototype built with **Godot Engine 4.3**, inspired by *UFC Undisputed 3* combat mechanics.

![Godot Engine 4.3](https://img.shields.io/badge/Godot-v4.3--stable-478cbf?logo=godotengine&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Windows%20x64-blue)

---

## ⚡ Quick Start (Clone & Play)

Clone the repository and run immediately:

```bash
git clone https://github.com/tkhoa789/MMA-Online.git
cd MMA-Online
```

- **Play Game**: Double-click `run_game.bat`
- **Open in Editor**: Double-click `open_editor.bat`

> *Note: If Godot 4.3 executable is not present in the folder, `run_game.bat` will automatically fetch the official portable Godot 4.3 runtime.*

---

## 🎮 Controls

The game supports both **Gamepad (Xbox / PlayStation)** and **Keyboard**:

### Movement & Stance
- **Move / Circle Opponent**: `Left Stick` or `WASD` / `Arrow Keys`
- **Lock-On Focus**: Both fighters automatically face each other in an authentic Orthodox MMA stance.

### Combat & Strikes
| Action | Gamepad | Keyboard | Description |
| :--- | :--- | :--- | :--- |
| **Lead Jab** | `X` | `J` | Fast left straight punch to establish distance |
| **Rear Cross** | `Y` | `K` | Powerful right power punch with shoulder rotation |
| **Lead Body Kick** | `A` | `U` | Left kick to body/liver with hip turnover (`úp hông`) |
| **Rear Body Kick** | `B` | `I` | Fast right body kick from rear leg |
| **High Guard / Block** | `LT` / `L2` | `Shift` | Earmuff tight guard (absorbs 80% damage) |

---

## 🏗️ Architecture

```
MMA-Online/
├── assets/
│   └── models/               # 3D GLB fighter rigs & textures
├── scenes/
│   ├── main.tscn             # Main combat scene
│   ├── arena.tscn            # 3D Octagon ring with ropes & lighting
│   ├── fighter_female.tscn   # Blue corner combatant
│   └── fighter_male.tscn     # Red corner combatant
├── scripts/
│   ├── fighter_controller.gd # Kinematics, movement & strike animation logic
│   ├── camera_controller.gd  # Dynamic tracking & orbit camera
│   ├── fight_hud.gd          # Health, stamina, & combat UI
│   └── arena.gd              # Ring physics & lighting
├── project.godot             # Godot 4.3 project configuration
├── run_game.bat              # 1-click launcher (auto-downloads Godot if missing)
└── open_editor.bat           # 1-click editor launcher
```

---

## 📜 License
MIT License. Free for modification, learning, and extension.
