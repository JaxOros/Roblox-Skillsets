# Stat Manager Extended - Roblox

**Author:** JaxOros  
**Description:** A server-authoritative system for managing player stats, abilities, progression, equipment, passive regeneration, and data persistence in Roblox games.

---

## Features

- **Stat Management**
  - Tracks core stats: Health, Mana, Stamina, Strength, Agility, Intelligence, Experience, Level.
  - Supports base values, maximum values, modifiers, and passive regeneration.
  - Automatic stat clamping to prevent invalid values.

- **Modifiers**
  - Additive or multiplicative modifiers for any stat.
  - Supports timed modifiers that expire after a duration.
  - Equipment and abilities can apply modifiers dynamically.

- **Experience & Leveling**
  - Adds experience and handles level-ups automatically.
  - Configurable experience scaling for progressive leveling.
  - Level-up callbacks for UI or gameplay effects.

- **Abilities System**
  - Register abilities per player with cooldowns, requirements, and custom on-use behavior.
  - Ability interactions for AoE, buffs, or other effects.
  - Ability use callbacks for custom reactions.

- **Equipment System**
  - Equip and unequip items with stat modifiers.
  - Level requirements for equipment.
  - Optional equip/unequip callbacks.
  - Retrieves currently equipped items.

- **Passive Regeneration**
  - Automatically regenerates Health, Mana, and Stamina over time.
  - Regeneration intervals and amounts configurable per stat.

- **Data Persistence**
  - Automatic saving and loading of player stats, abilities, and equipment using `DataStoreService`.
  - Ensures persistent progression across sessions.

---

## Installation

1. Place the `StatManager` module in `ServerScriptService` or a `Modules` folder.
2. Require it in a server script:
   ```lua
   local StatManager = require(game.ServerScriptService.Modules.StatManager)
   ```
3. Players' stats, abilities, and equipment will be automatically created on join.
4. Passive regeneration and data persistence are handled automatically.

---

## Usage Examples

- **Basic Stat Operations**
```lua
-- Get current health
local health = StatManager.getStat(player, "Health")

-- Set health to a specific value
StatManager.setStat(player, "Health", 50)

-- Add a temporary strength boost
StatManager.applyModifier(player, "Strength", "PowerPotion", "Add", 10, 30) -- lasts 30 seconds

-- Remove a modifier
StatManager.removeModifier(player, "Strength", "PowerPotion")
```

- **Experience and Leveling**
```lua
-- Add experience points
StatManager.addExperience(player, 150)
```

- **Abilities**
```lua
-- Register an ability
StatManager.registerAbility(player, "Fireball", 5, function(p)
    return StatManager.getStat(p, "Mana") >= 10
end, function(p)
    print(p.Name .. " used Fireball!")
end)

-- Use an ability
StatManager.useAbility(player, "Fireball")

-- Listen for ability usage
StatManager.addAbilityUseListener(player, function(p, abilityName)
    print(p.Name .. " used ability:", abilityName)
end)
```

- **Equipment**
```lua
-- Equip an item
local swordData = {
    Name = "IronSword",
    LevelReq = 1,
    Modifiers = {
        {Stat="Strength", Type="Add", Amount=5}
    },
    OnEquip = function(p) print(p.Name .. " equipped Iron Sword!") end,
    OnUnequip = function(p) print(p.Name .. " unequipped Iron Sword!") end
}
StatManager.equipItem(player, swordData)

-- Unequip an item
StatManager.unequipItem(player, "IronSword")

-- Get all equipped items
local equipped = StatManager.getEquipment(player)
```

---

## Notes

- **Passive regeneration runs automatically every second.**
- **Player data is saved on leaving and loaded on joining.**
- **Callbacks can be used to trigger UI updates, effects, or logging.**
- **Equipment and abilities can interact with the stat system for complex mechanics.**

---

## License

MIT License ©JaxOros
