# Lingering Snow - Roblox Skill System

**Lingering Snow** is a custom skill for Roblox that features dynamic hitboxes, visual effects, and a cinematic skill camera. (Inspired by ZZZ Miyabi Ultimate)

---

## Features

- **Skill Hitbox System**
  - Configurable hitboxes with start and end effects.
  - Automatic damage detection within hitbox bounds.
  - Supports multiple damage phases.
  
- **Effects Management**
  - Beam and ParticleEmitter activation/deactivation.
  - Sound playback management with safe cloning and cleanup.
  
- **Skill Camera**
  - Cinematic, smooth camera following the character and hitbox.
  - Returns to default view after skill ends.
  - Fully scriptable and adjustable with angle, height, and distance parameters.

---

## Installation

1. Clone or download the repository into your Roblox Studio project.
2. Place all files under a tool. (Ensure require handle is set to false)
3. Ensure all RemoteEvents are in `ReplicatedStorage`, particularly `LingeringSnow`.
4. Make your character model `Archivable` for clones to work properly.
5. Adjust hitbox, anchors, and effects in the tool to match your skill design.

---

## Usage

- **Server Script**
  - Handles hitbox detection, damage application, and phantom dashes.
  - Fires the `LingeringSnow` RemoteEvent to trigger camera effects on the client.

- **LocalScript (Client)**
  - Listens to `LingeringSnow` RemoteEvent.
  - Smoothly moves the camera to follow the skill and returns it afterward.
  - Camera parameters can be customized (angle, height, distance, lerp speed).

---

## Configuration

- **Anchors**
  - Found inside the hitbox `Movement` folder.
  - Named `Slash1S`/`Slash1E`, `Slash2S`/`Slash2E`, etc.
  - Determines the path for phantom dash clones.

- **Effects**
  - `Start` and `End` folders inside hitbox contain visual effects.
  - Beams and ParticleEmitters will automatically be activated/deactivated during skill phases.

- **Camera Settings (Client)**
  - `camAngle` – pitch, yaw, roll in degrees.
  - `camDistance` – distance behind the character.
  - `camHeight` – vertical offset.
  - `camLerpSpeed` – smoothing speed for camera movement.

---

## Notes

- Make sure your character models are **Archivable**, otherwise clones won’t be created.
- Avoid adding effects inside the cloned models; effects are meant to remain on the original tool to prevent duplicates.
- Adjust `phantomDash` duration and distance for smoother visuals.

---

## License

MIT License ©JaxOros

---

## Contributions

Contributions, issues, and feature requests are welcome! Feel free to fork the repository and submit pull requests.
