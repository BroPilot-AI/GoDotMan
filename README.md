# 🤖 GoDotman

A 3D platformer starring Godot's robot mascots. Pick **Gobot**, **GDBot** or **Sophia**, stomp your way through bees, beetles and bats across nine worlds, grab power-ups, and bring down the giant waiting in world 10.

Built in **Godot 4.7** with **GDScript** and **Jolt Physics**, using GDQuest's open 3D characters.

[![Download for Windows](https://img.shields.io/badge/Download-Windows-2ea44f?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/BroPilot-AI/GoDotMan/releases/latest)
[![Made with Godot](https://img.shields.io/badge/Made%20with-Godot%204.7-478cbf?style=for-the-badge&logo=godotengine&logoColor=white)](https://godotengine.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

---

## ✨ Features

- **Three heroes** — play as Gobot, GDBot or Sophia, picked from the main menu.
- **Ten worlds** — nine platforming levels, each ending at a flag, then a boss arena.
- **Tight platforming** — double jump, coyote time, jump buffering, variable jump height and a **ground pound** that flattens anything nearby when you land.
- **Stomp to win** — bounce off enemies' heads, or get hit and lose a life.
- **Five power-ups** — bolt shots, a star, a laser sword, hover boots and extra lives.
- **A giant boss** — the world 10 giant takes ten hits to bring down.
- **Bolts and score** — collect bolts, stomp enemies and finish levels for points. You start with three lives.
- **Keyboard or gamepad** — every action works on both.

## ⚡ Power-ups

| Power-up | What it does | Lasts |
|----------|--------------|-------|
| 🔩 **Bolt Shot** | Attack fires bolts | 15 s |
| ⭐ **Star** | Enemies are destroyed on touch | 8 s |
| 🗡️ **Laser Sword** | Attack swings a sword | 20 s |
| 🥾 **Hover Boots** | Hold jump to hover in the air | 20 s |
| ❤️ **Extra Life** | One more life | — |

## 🏆 Scoring

| Action | Points |
|--------|--------|
| Collect a bolt | 100 |
| Stomp, pound or shoot an enemy | 200 |
| Slash an enemy with the Laser Sword | 500 |
| Grab a power-up | 500 |
| Reach the flag | 1,000 |
| Defeat the giant | 10,000 |

## 🎮 Controls

| Action | Keyboard | Gamepad |
|--------|----------|---------|
| **Move** | W A S D or arrow keys | Left stick |
| **Jump / double jump** | Space | A / Cross |
| **Attack** (with Bolt Shot or Laser Sword) | F | X / Square |
| **Ground pound** (in the air) | Shift | RB / R1 |
| **Camera** | Arrow keys | Right stick |

## 🚀 Play it

1. Grab **GoDotman-Windows.zip** from the **[latest release](https://github.com/BroPilot-AI/GoDotMan/releases/latest)**.
2. Unzip it anywhere and run **GoDotman.exe**. Nothing to install.

Windows may show a SmartScreen warning because the exe isn't signed: click **More info**, then **Run anyway**.

## 🛠️ Running from source

1. Install **[Godot 4.7](https://godotengine.org/download)** (the standard build, not .NET).
2. Open `new-game-project/project.godot` in the Godot editor and press **F5**.

To build the exe, use **Project → Export → Windows Desktop**, or:

```
godot --headless --path new-game-project --export-release "Windows Desktop" build/GoDotman.exe
```

The `.godot/` import cache is rebuilt automatically on first open and is not tracked.

## 🎨 Credits & licensing

- **Characters and enemies** — Gobot, GDBot, Sophia, Bee Bot, Beetle Bot and Round Bat by **[GDQuest](https://www.gdquest.com/)**, from their open [Godot 4 3D character](https://github.com/gdquest-demos) packs. Their code is MIT; their art (models and textures) is **[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)**. Full text in [`new-game-project/addons/LICENSE-GDQuest.md`](new-game-project/addons/LICENSE-GDQuest.md).
- **Physics** — [Jolt Physics](https://github.com/jrouwe/JoltPhysics), built into Godot.

**Code license:** [MIT](LICENSE). The GDQuest art in `new-game-project/addons/` keeps its own CC BY-NC-SA 4.0 licence, so the game as a whole may not be sold.
**Engine:** made with [Godot Engine](https://godotengine.org), used under its MIT license. The release zip includes its licence text.
