# Teleportation Tags - Roblox Skill System

**Teleportation Tags** is a custom skill for Roblox that allows players to place teleportation tags in the world and teleport to them. The system uses a combination of RemoteEvents, tag objects, and user input for flexible movement mechanics.
(Inspired by Minato's Flying Thunder God)
---

## Features

- **Tag Placement**
  - Left-click to place a teleportation tag on a nearby object.
  - Left-click near an existing tag removes it.
  - Tags automatically weld to objects to stay in place.

- **Teleportation**
  - Right-click to teleport to the nearest tag in the camera's direction.
  - Teleportation is limited to a short distance from the player.
  - Ensures safe movement by slightly offsetting the player's position above the tag.

- **Server-Client Communication**
  - Server handles the actual teleportation for validation and security.
  - Client handles tag placement, aiming, and input detection.

- **Visual Tags**
  - Tags are based on a template object (`Mark`) that can include any visual effects or indicators.
  - Supports multiple tags at once.

---

## Installation

1. Clone or download the repository into your Roblox Studio project.
2. Place the scripts inside a Tool object.
3. Add the `Mark` template inside the tool for the tag visuals.
4. Create a remote event under the tool name `RemoteEvent`.
5. Ensure the tool is parented to the player character or StarterPack for testing.

---

## Usage

- **Tag Placement**
  - Equip the tool.
  - Left-click to place a tag on a nearby surface.
  - Left-click near an existing tag to remove it.

- **Teleportation**
  - Equip the tool.
  - Right-click while aiming near a tag to teleport to it.

- **Server Handling**
  - The server script ensures players are only teleported to valid positions.
  - Teleportation is sent via a RemoteEvent from the client.

---

## Configuration

- **Mark Template**
  - Parent to the tool.
  - Include any visual indicators (parts, meshes, particle effects).
  
- **Teleport Events**
  - `RemoteEvent` RemoteEvent: optional feedback for tag placement.

- **Distance Limit**
  - The maximum distance a player can place a tag from their character is 10 studs.
  - The teleport ray checks up to 500 studs in the camera's direction.

---

## Notes

- Tags are limited to the placement distance from the player to prevent long-range exploits.
- Teleportation positions are slightly offset vertically to avoid clipping into the ground.
- Clean up tags by removing or destroying them manually when not needed to avoid clutter in the workspace.

---

## License

MIT License ©JaxOros

---

## Contributions

Contributions, issues, and feature requests are welcome! Feel free to fork the repository and submit pull requests.
