# Solemn Lament - Roblox Weapon Set

**Solemn Lament** is a custom skill for Roblox featuring synchronized animations, sound effects, and input-driven critical attacks. This system provides both client-side and server-side components for a polished gameplay experience.
(Inspired by the goat Yesod and Yi Sang)
---

## Features

- **Animation System**
  - Idle and walk animations automatically switch based on player movement.
  - Celebration animation plays when a skill click is triggered.
  - Critical animation triggered by pressing the `R` key.
  
- **Sound Effects**
  - Ping and pong sounds play alongside skill animations.
  - Supports multiple sound clones without interfering with gameplay.

- **Input Handling**
  - Listens for key input (`R`) to trigger critical attacks.
  - Debounce system prevents spamming.

- **Hitbox Management**
  - Works with server-side hitbox scripts to deal damage.
  - Supports multiple hitbox phases for advanced attacks.

---

## Installation

1. Clone or download the repository into your Roblox Studio project.
2. Place the scripts under the corresponding tool (`Solemn Lament`) in the player's inventory.
3. Ensure `Events` folder exists in `ReplicatedStorage` with `Clicked` and `Crit` RemoteEvents.
4. Ensure `Animations` folder exists inside the tool with the following Animation objects:
   - `idle`
   - `walk`
   - `celebration`
   - `crit`
5. Adjust `ping` and `pong` SoundIds to your preferred sound assets.

---

## Usage

- **LocalScript (Client)**
  - Handles animations, sounds, and input detection.
  - Plays idle/walk animations dynamically.
  - Triggers skill effects when `Clicked` or `Crit` events are fired from the server.

- **Server Scripts**
  - Handles hitboxes and damage application (optional for integration).
  - Fires `Clicked` and `Crit` events to clients when skill actions occur.

---

## Configuration

- **Animations**
  - Stored inside the tool under the `Animations` folder.
  - Load priorities:
    - Idle → `Enum.AnimationPriority.Idle`
    - Walk → `Enum.AnimationPriority.Movement`
    
- **Sounds**
  - `ping` and `pong` sounds are instantiated locally on the client.
  - Configurable SoundId, volume, and parent.

- **Cooldowns & Debounce**
  - `R` key critical attack has a 5-second cooldown by default.
  - Debounce prevents spamming of both click and critical events.

---

## Notes

- Ensure the player's character has a `Humanoid` and `Animator`.
- Animations and sound effects are client-side for smoother gameplay.
- Can be combined with server-side hitbox scripts for full skill effects.

---

## License

MIT License © JaxOros

---

## Contributions

Contributions, issues, and feature requests are welcome! Fork the repository and submit pull requests to improve or extend the system.
