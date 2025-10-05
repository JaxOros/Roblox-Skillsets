# Zone Teleporter Script - Roblox

**Author:** JaxOros  
**Description:** A simple teleporter system that allows players to queue and teleport to a chosen zone. Includes a countdown timer and capacity tracking, as well as GUI integration for player feedback.

---

## Features

- Teleports players to a selected zone after a countdown timer.
- Tracks the number of players currently queued for teleportation.
- Configurable maximum capacity per teleporter.
- Displays timer and capacity using BillboardGui text labels.
- Fires GUI events for the first player to queue.
- Prevents duplicate entries in the teleporter queue.
- Automatically resets timer after teleportation.

---

## Installation

1. Place the `Teleporter` model in the desired location in your game.
2. Ensure it contains the following structure:
    - `Timer_Holder` → `BillboardGui` → `TextLabel`
    - `Text_Holder` → `BillboardGui` → `TextLabel`
3. Add a `RemoteEvent` named `Zone_GUI` under `ReplicatedStorage.Remotes`.
4. Parent the script to the `Teleporter` model.
5. Adjust initial timer and capacity values in the GUI text labels.

---

## Usage

- Players walk onto the teleporter pad to join the queue.
- The script automatically tracks who is inside and updates the capacity display.
- The first player in the queue fires the GUI event to open the zone selection GUI.
- When the countdown timer ends, all queued players are teleported to the selected zone.
- If players leave the teleporter, they are removed from the queue.

---

## Configuration

- **Timer**: Set via the `TextLabel` under `Timer_Holder`. Format: `Time Left: X`
- **Capacity**: Set via the `TextLabel` under `Text_Holder`. Format: `0 / N Players`
- **GUI Remote**: The script uses `Zone_GUI` in `ReplicatedStorage.Remotes` to notify the first queued player.

---

## Notes

- Supports multiple players but respects the teleporter capacity limit.
- Uses tags (`Teleporting <TeleporterName>`) to track players queued for teleportation.
- The timer resets automatically after each teleportation cycle.
- Debounce ensures the GUI event only fires once per cycle.

---

## License

MIT License © JaxOros
