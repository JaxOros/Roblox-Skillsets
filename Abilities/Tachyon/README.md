# Tachyon Skill - Roblox Skill System

**Tachyon** is a custom speed-based skill for Roblox that enhances the player's movement and generates dynamic glyph effects. (Inspired by Agnes Tachyon, THE GOAT)

---

## Features

- **Speed-Based Skill Activation**
  - Activates Tachyon mode, increasing the player's movement speed.
  - WalkSpeed ramps up dynamically while the skill is active.
  - Supports smooth ramp-in and ramp-out of the effect.

- **Glyph Effects**
  - Spawns dynamic Tachyon glyphs around the player while moving.
  - Glyphs are fully script-controlled, including size, lifetime, transparency, and rotation.
  - Color and texture variations create a visually rich field effect.

- **Camera FOV Adjustment (LocalScript)**
  - FOV dynamically changes based on player speed.
  - Smooth interpolation for cinematic, speed-based zoom effects.
  - Resets FOV when Tachyon mode ends.

- **Automatic Cleanup**
  - Removes glyphs and disconnects connections when the player dies or skill is deactivated.
  - Ensures no leftover objects or memory leaks.

---

## Installation

1. Clone or download the repository into your Roblox Studio project.
2. Place all files under a Tool in StarterPack.
3. Ensure the `State` BoolValue exists in the tool to track Tachyon activation.
4. No RemoteEvents are required for Tachyon’s local effects, but you may extend it for server interactions.
5. Adjust constants in the script (speed thresholds, spawn rate, glyph colors, etc.) to fit your gameplay.

---

## Usage

- **Server Script (Optional)**
  - Can be extended to handle speed buffs, damage interactions, or multiplayer sync.

- **LocalScript (Client)**
  - Listens to the `State` BoolValue to trigger glyph spawning and camera FOV adjustments.
  - Dynamically spawns glyphs around the player based on speed and movement direction.
  - Smoothly interpolates camera FOV for a high-speed effect.

---

## Configuration

- **Skill Constants**
  - `SPEED_ON` / `SPEED_MAX` – thresholds for Tachyon activation and maximum speed.
  - `RATE_MIN` / `RATE_MAX` – glyph spawn rate based on player speed.
  - `FWD_MIN` / `FWD_MAX` – forward offset of glyphs relative to player.
  - `RAD_MIN` / `RAD_MAX` – radial distance of glyphs from player.
  - `LIFE_MIN` / `LIFE_MAX` – glyph lifetime before disappearing.
  - `COLOR_A` / `COLOR_B` – primary colors used for glyphs.

- **Camera Settings**
  - `minFOV` / `maxFOV` – minimum and maximum Field of View for Tachyon mode.
  - `k` – exponential growth factor for speed → FOV.
  - `lerpSpeed` – smoothing speed for FOV transitions.

---

## Notes

- Make sure your character exists and has a `HumanoidRootPart` for glyph spawning.
- Glyphs are parented to a temporary Folder in Workspace; they are automatically cleaned up.
- Adjust glyph textures (`TEXTURE_IDS`) to customize visual style.

---

## License

MIT License ©JaxOros

---

## Contributions

Contributions, issues, and feature requests are welcome! Feel free to fork the repository and submit pull requests.
