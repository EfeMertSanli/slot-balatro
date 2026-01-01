# Slot Balatro - Claude Development Guide

## Project Overview

A Balatro-inspired slot machine roguelike built with Love2D (Lua). Features PC-98 aesthetic with neon glow effects, anime mascot "Luna", and roguelike progression with permanent buffs.

## Architecture

```
slot-balatro/
├── main.lua                    # Entry point, Love2D callbacks, button creation
├── src/
│   ├── core/                   # Core systems
│   │   ├── state.lua           # Central state (future: single source of truth)
│   │   ├── events.lua          # Event bus for decoupled communication
│   │   └── save.lua            # Persistent save/load system
│   │
│   ├── systems/                # Game logic systems
│   │   ├── reels.lua           # Reel spinning, symbol placement
│   │   ├── paylines.lua        # Win detection, payline logic
│   │   ├── progression.lua     # Antes, rounds, targets, scaling
│   │   ├── luna.lua            # Luna expressions, dialogue
│   │   ├── luna_affinity.lua   # Luna relationship progression
│   │   ├── boss_modifiers.lua  # Per-ante boss challenge effects
│   │   ├── combo.lua           # Consecutive win multiplier tracking
│   │   ├── consumables.lua     # One-time use item management
│   │   ├── special_events.lua  # Random encounter events
│   │   ├── meta.lua            # Achievements and meta progression
│   │   └── story.lua           # Story dialogue and narrative management
│   │
│   ├── data/                   # Static definitions (DATA ONLY, no logic)
│   │   ├── symbols.lua         # Symbol definitions with weights
│   │   ├── joker_defs.lua      # Joker cards and effects
│   │   ├── buff_defs.lua       # Permanent buff definitions
│   │   ├── slot_changers.lua   # Slot upgrade definitions
│   │   ├── dialogue.lua        # Luna's speech lines + affinity dialogue
│   │   ├── boss_defs.lua       # Boss modifier definitions (13 bosses)
│   │   ├── consumable_defs.lua # Consumable item definitions
│   │   ├── event_defs.lua      # Special event definitions
│   │   ├── achievement_defs.lua # Achievement definitions
│   │   └── story_defs.lua      # Story dialogue per ante (13 bosses)
│   │
│   ├── screens/                # UI screens
│   │   ├── play.lua            # Main gameplay screen
│   │   ├── shop.lua            # Shop screen
│   │   ├── jokers.lua          # Jokers management overlay
│   │   ├── rules.lua           # Rules/info popup
│   │   ├── ante_reward.lua     # Buff selection after ante
│   │   ├── game_over.lua       # Game over screen
│   │   └── story_popup.lua     # Story narrative popup
│   │
│   ├── config.lua              # Constants only (layout, timing, limits)
│   ├── colors.lua              # Color palette
│   ├── effects.lua             # Particles, screen shake, floating text
│   ├── ui.lua                  # UI components, buttons, drawing helpers
│   └── game.lua                # Game coordinator (being refactored)
│
└── assets/                     # Images, fonts
```

## Key Patterns

### 1. Data vs Logic Separation
- `src/data/` contains ONLY static definitions (tables of data)
- `src/systems/` contains logic that operates on data
- Never put functions in data files, never put data arrays in system files

### 2. Event Bus (src/core/events.lua)
```lua
-- Emit events instead of direct function calls
Events.emit("spin_complete", {symbols = symbols})

-- Listen in other systems
Events.on("spin_complete", function(data)
    Luna.react_to_spin(data.symbols)
end)
```

### 3. State Bridge Pattern
When systems need Game state but expect State module format:
```lua
local state_bridge = {
    perm = {
        starting_credits = Game.perm_starting_credits or 0,
        -- ...
    }
}
buff.effect(state_bridge)
-- Copy back to Game
Game.perm_starting_credits = state_bridge.perm.starting_credits
```

### 4. Backward Compatibility
Config.lua uses metatable for lazy loading:
```lua
-- Old code still works:
for _, sym in ipairs(Config.SYMBOLS) do ...

-- New code can use direct imports:
local Symbols = require("src.data.symbols")
```

## Token-Efficient Workflow

### Reading Files
1. **Don't read game.lua entirely** - it's 1200+ lines
2. Read specific sections using offset/limit
3. Use Grep to find specific functions first

### Making Changes
1. **Identify the right file first**:
   - Adding joker? → `src/data/joker_defs.lua`
   - Changing win logic? → `src/systems/paylines.lua`
   - Changing Luna reactions? → `src/systems/luna.lua`
   - UI layout? → `src/config.lua` (LAYOUT section)

2. **Small, focused edits**:
   - Edit one function at a time
   - Test after each change
   - Don't refactor surrounding code

### File Size Guidelines
- Data files: ~100-200 lines each
- System files: ~200-400 lines each
- Screen files: ~200-400 lines each
- config.lua: ~150 lines (constants only)

## Game State Reference

### Core State (in Game module, migrating to State module)
```lua
Game.state          -- "play", "shop", "jokers", "ante_reward", "game_over"
Game.credits        -- Current credits
Game.bet            -- Current bet amount
Game.ante           -- Current ante (1-13)
Game.round_in_ante  -- Current round within ante (1-10)
Game.spins_this_round -- Spins used this round
Game.spinning       -- Is reels currently spinning?
```

### Permanent Buffs (persist across runs)
```lua
Game.perm_starting_credits  -- Bonus starting credits
Game.perm_win_bonus         -- Win multiplier bonus (0.1 = +10%)
Game.perm_target_reduction  -- Target reduction (0.15 = -15%)
Game.perm_extra_spins       -- Bonus spins per round
Game.perm_symbol_bonus      -- Bonus to symbol values
Game.perm_shop_discount     -- Shop price reduction
```

### Collections
```lua
Game.jokers         -- Owned joker cards
Game.slot_changers  -- Owned slot upgrades
Game.paylines       -- Active paylines (0, -1, 1, "diag_up", etc.)
```

## Adding New Content

### New Joker
Edit `src/data/joker_defs.lua`:
```lua
{
    id = "my_joker",
    name = "My Joker",
    icon = "MYJ",
    color = Colors.cyan,
    cost = 50,
    rarity = "common",
    effect = "Description shown in UI",
    effect_short = "Short desc",
    apply = function(score, symbols, state)
        return score * 1.5
    end
}
```

### New Symbol
Edit `src/data/symbols.lua`:
```lua
{
    id = "ruby",
    icon = "RUBY",
    name = "RUBY",
    value = 20,
    color = Colors.red,
    image = "src/assets/symbol_ruby.png",
    weight = 6,  -- Lower = rarer
}
```

### New Permanent Buff
Edit `src/data/buff_defs.lua`:
```lua
{
    id = "my_buff",
    name = "My Buff",
    icon = "MYB",
    color = Colors.gold,
    category = "credits",
    desc = "+100 starting credits",
    effect = function(state)
        state.perm.starting_credits = state.perm.starting_credits + 100
    end
}
```

### New Luna Expression
1. Add image: `src/assets/luna_excited.png`
2. Add to `src/data/dialogue.lua`:
```lua
Dialogue.expressions.excited = {
    "This is amazing!",
    "I can't believe it!",
}
```
3. Update `src/systems/luna.lua` to trigger the expression

## Common Tasks

| Task | File(s) to Edit |
|------|-----------------|
| Adjust symbol weights | `src/data/symbols.lua` |
| Change target scaling | `src/config.lua` (TARGET_* constants) |
| Add new joker | `src/data/joker_defs.lua` |
| Change Luna's dialogue | `src/data/dialogue.lua` |
| Modify win calculations | `src/systems/paylines.lua` |
| Change spin animation | `src/systems/reels.lua` |
| Adjust layout | `src/config.lua` (LAYOUT section) |
| Add new screen | `src/screens/`, update `main.lua` |

## Testing

Run the game with Love2D:
```bash
love .
```

Key test scenarios:
1. Spin and win detection works
2. Shop buying jokers/upgrades works
3. Ante completion and buff selection works
4. Game over and restart works
5. Luna expressions change appropriately
6. Boss modifiers affect gameplay per ante
7. Combo multipliers build on consecutive wins
8. Consumables can be bought and used

## Implemented Systems

### Boss Modifiers (src/systems/boss_modifiers.lua)
Each ante has a unique boss that modifies gameplay:
- `BossModifiers.init(ante)` - Initialize boss for an ante
- `BossModifiers.on_round_start(state)` - Apply round start effects
- `BossModifiers.on_win(state, score)` - Modify win score
- `BossModifiers.get_price_multiplier()` - Shop price modifier
- `BossModifiers.get_target_multiplier()` - Target modifier
- `BossModifiers.get_spin_reduction()` - Spin count modifier

Boss definitions in `src/data/boss_defs.lua` (13 bosses, one per ante).

### Combo System (src/systems/combo.lua)
Consecutive wins build a multiplier:
- Win 1: 1.0x, Win 2: 1.2x, Win 3: 1.5x, Win 4: 2.0x, Win 5+: 2.5x
- `Combo.on_win()` - Called on win, returns multiplier
- `Combo.on_loss()` - Called on loss, resets combo
- `Combo.get_display_info()` - Returns {wins, multiplier, is_active, is_max}

### Consumables (src/systems/consumables.lua)
One-time use items bought in shop:
- `ConsumablesSystem.add(id)` - Add item to inventory
- `ConsumablesSystem.use(index, state)` - Use an item
- `ConsumablesSystem.get_inventory()` - Get owned items
- Max 5 consumables at once

Available consumables (src/data/consumable_defs.lua):
- Rewind Token ($50): Undo last spin
- Wild Card ($30): Force one wild on next spin
- Time Freeze ($40): +3 spins this round
- Lucky Coin ($25): Double next win
- Mulligan ($60): Reroll reel results

### Special Events (src/systems/special_events.lua)
Random encounters that trigger at round start (5% chance):
- `SpecialEvents.try_trigger(state)` - Roll for event
- `SpecialEvents.get_active()` - Get current event
- `SpecialEvents.get_payout_multiplier()` - Event payout modifier
- `SpecialEvents.clear()` - End event at round end

Events defined in `src/data/event_defs.lua`:
- Lucky Hour: All payouts doubled
- Cursed Reel: One reel shows only low symbols
- Ghost Spin: Free phantom spin
- The Collector: Trade joker for double value
- Luna's Gift: Free consumable
- High Roller: Min bet x5, payouts x3
- Lucky Seven / Wild Surge: Symbol weight bonuses

### Luna Affinity (src/systems/luna_affinity.lua)
Relationship with Luna that persists across runs:
- 7 levels: Stranger → Acquaintance → Friend → Close Friend → Trusted → Confidant → Soulbound
- `LunaAffinity.get_level()` - Current level (1-7)
- `LunaAffinity.on_run_end(state, won)` - Check for level up
- `LunaAffinity.has_mercy_spin()` - Level 4+ grants mercy spin
- `LunaAffinity.get_wild_bonus()` - Level 5+ gives wild bonus

Bonuses by level:
- Level 2: Luna warns about bad spins
- Level 3: Unlock Luna's backstory
- Level 4: Mercy spin on game over
- Level 5: +5% wild appearance
- Level 6: Luna's true form revealed, +8% wilds
- Level 7: Ending unlocked, +10% wilds

### Meta Progression (src/systems/meta.lua)
Achievements and unlocks that persist forever:
- `Meta.check_achievements(state)` - Check for new unlocks
- `Meta.on_spin(win, symbols, state)` - Track spin stats
- `Meta.on_run_end(won, state)` - Track run completion
- `Meta.get_achievements()` - Get unlocked achievements

Achievements defined in `src/data/achievement_defs.lua`:
- Progress: Reach specific antes
- Economy: Credit milestones, max bets
- Combo: High combo multipliers
- Special: Triple wilds, event hunting

### Save System (src/core/save.lua)
Persistent storage for meta progress:
- `Save.register(name, system)` - Register system for persistence
- `Save.save()` / `Save.load()` - Manual save/load
- `Save.save_now()` - Force immediate save
- Auto-saves every 60 seconds
- Systems must implement `get_save_data()` and `load_save_data(data)`

### Story System (src/systems/story.lua)
Narrative dialogue and story progression for each ante:
- `Story.get_intro(ante)` - Get random intro line for an ante
- `Story.get_win_line(ante)` - Get random win line
- `Story.get_loss_line(ante)` - Get random loss line
- `Story.get_story(ante)` - Get the story beat text
- `Story.get_boss_name(ante)` - Get boss name for an ante
- `Story.on_ante_start(ante)` - Called when ante starts (shows intro)
- `Story.on_ante_win(ante)` - Called when ante is won
- `Story.on_game_over(ante)` - Called on game over

Story popup (longer narrative after beating an ante):
- `Story.show_story_popup(ante)` - Display story beat popup
- `Story.close_story_popup()` - Close the popup
- `Story.is_story_popup_active()` - Check if popup is visible

Story definitions in `src/data/story_defs.lua`:
- 13 antes with unique boss names
- Intro lines (shown at ante start)
- Win lines (shown on ante completion)
- Loss lines (shown on game over)
- Story beats (deeper narrative, shown once per ante)

## Future Plans

See PLAN.md for remaining features:
- Symbol evolution system
- Additional achievements/unlocks

## Notes

- Assets are in `src/assets/` (note: folder is misspelled as "assests" in some paths)
- Luna mascot has multiple expressions: idle, watching, small_win, jackpot, etc.
- PC-98 aesthetic: neon colors, CRT shader, pixel art style
- Save file stored via love.filesystem in user data directory
