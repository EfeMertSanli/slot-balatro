# Slot Balatro - Development Plan

## Premise: "Luna's Liminal Lounge"

You've stumbled into a casino that exists between worlds — a neon-lit purgatory where lost souls gamble for their freedom. **Luna**, a mischievous spirit dealer, offers you a deal: reach the **13th Ante** and you can leave. But no one ever has.

Each ante represents a "floor" of the casino, with the house's advantage growing exponentially. Luna isn't your enemy — she's trapped here too, bound to deal forever. Help her by proving the house *can* be beaten.

**Tone:** Melancholic yet hopeful. Dark humor. PC-98 aesthetic suggests late-night loneliness, vaporwave nostalgia, and surreal dreamscapes.

---

## Core Gameplay Loop (Current)

```
┌─────────────────────────────────────────────────────────────┐
│  SPIN PHASE (10 spins per round)                            │
│  └→ Match symbols, trigger joker effects, build credits     │
├─────────────────────────────────────────────────────────────┤
│  ROUND END                                                  │
│  └→ Meet target? → SHOP                                     │
│  └→ Fail target? → GAME OVER (keep permanent buffs)         │
├─────────────────────────────────────────────────────────────┤
│  SHOP PHASE                                                 │
│  └→ Buy jokers, slot upgrades, consumables                  │
│  └→ Manage economy for future rounds                        │
├─────────────────────────────────────────────────────────────┤
│  ANTE COMPLETE (every 10 rounds)                            │
│  └→ Choose 1 of 3 permanent buffs                           │
│  └→ Face new BOSS MODIFIER for next ante                    │
│  └→ Luna dialogue/story progression                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Planned Features

### 1. Boss Modifiers (Per-Ante Challenges)

Each ante introduces a persistent rule that changes strategy:

| Ante | Boss Name | Modifier |
|------|-----------|----------|
| 1 | The Welcome | (Tutorial - no modifier) |
| 2 | The Miser | Shop prices +50% |
| 3 | The Blind | One reel is hidden until spin ends |
| 4 | The Taxman | Lose 10% of credits each round |
| 5 | The Cursed | One random symbol becomes worthless |
| 6 | The Gambler | Bet minimum is 50% of max bet |
| 7 | The Mirror | Paylines are reversed |
| 8 | The Void | One joker slot is disabled |
| 9 | The Flood | +2 rows, but targets +100% |
| 10 | The Drought | -2 spins per round |
| 11 | The Chaos | Symbol positions shuffle each spin |
| 12 | The Final | All previous modifiers at 50% |
| 13 | Luna Unchained | Beat Luna's personal challenge |

**Implementation:** `src/systems/boss_modifiers.lua`
- Store active modifier in State
- Apply modifier effects at appropriate points (shop, spin, round start)
- Display modifier in UI

---

### 2. Combo System

Consecutive wins build a combo multiplier:

```
Win 1: 1.0x
Win 2: 1.2x
Win 3: 1.5x
Win 4: 2.0x
Win 5+: 2.5x (MAX)
```

Any loss resets the combo. Creates tension and excitement.

**Implementation:** `src/systems/combo.lua`
- Track consecutive wins in State
- Apply multiplier in check_win()
- Display combo counter in UI
- Visual effects for high combos

---

### 3. Consumables (One-Time Use Items)

Buyable in shop, usable during spins:

| Item | Cost | Effect |
|------|------|--------|
| **Rewind Token** | $50 | Undo last spin |
| **Wild Card** | $30 | Force one wild on next spin |
| **Time Freeze** | $40 | +3 spins this round |
| **Lucky Coin** | $25 | Double next win |
| **Mulligan** | $60 | Reroll current reel results |

**Implementation:** `src/data/consumables.lua` + `src/systems/consumables.lua`
- Add consumables inventory to State
- Shop generates consumable offers
- Hotkeys to use consumables during play
- UI display for owned consumables

---

### 4. Special Events (Random Encounters)

5% chance per round to trigger:

- **Lucky Hour:** All payouts doubled this round
- **Cursed Reel:** One reel only shows low symbols
- **Ghost Spin:** A free "phantom" spin that doesn't count
- **The Collector:** Trade a joker for double its value
- **Luna's Gift:** Free consumable
- **High Roller:** Minimum bet x5, but payouts x3

**Implementation:** `src/systems/events.lua`
- Roll for event at round start
- Apply event modifiers
- Display event notification
- Clear event at round end

---

### 5. Luna Affinity System

Build relationship with Luna through play:

| Level | Requirement | Bonus |
|-------|-------------|-------|
| 1 | Start | Luna gives basic tips |
| 2 | Reach Ante 3 | Luna warns about bad spins |
| 3 | Reach Ante 5 | Unlock Luna's backstory |
| 4 | 10 total runs | Luna offers "mercy spin" on game over |
| 5 | Reach Ante 8 | Luna secretly helps (wild appears more) |
| 6 | Reach Ante 10 | Luna's true form revealed |
| 7 | Beat Ante 13 | Ending unlocked |

**Implementation:** Extend `src/systems/luna.lua`
- Track affinity level in persistent save
- Unlock dialogues based on affinity
- Apply hidden bonuses at higher levels
- Trigger story events

---

### 6. Symbol Evolution

Symbols can be upgraded permanently across runs:

```
CHERRY (1x) → GOLDEN CHERRY (2x) → DIVINE CHERRY (3x + special)
```

**Evolution Currency:** "Stardust" — earned by:
- Completing antes
- Achieving combos
- Finding rare events

Each evolved symbol gains a **passive effect**:
- **Divine Cherry:** Heals 1 spin when matched
- **Divine Diamond:** +10% to all wins this round
- **Divine Seven:** Guarantees next spin has a 7

**Implementation:** `src/systems/evolution.lua`
- Track evolution levels in persistent save
- Modify symbol values/effects based on evolution
- Stardust economy
- Evolution UI screen

---

### 7. Meta Progression (Across All Runs)

**Unlockables:**
- New joker pool expands as you reach higher antes
- New symbols unlock (themed sets)
- Alternate Luna outfits/expressions
- "Challenge Runs" with special rules
- Lore entries in a codex

**Achievements → Unlocks:**
```
"First Blood"      - Win 100 credits in one spin  → Unlock JOKER: Blood Pact
"Survivor"         - Reach Ante 5                 → Unlock SYMBOL SET: Arcana
"High Roller"      - Bet max 50 times             → Unlock CONSUMABLE: All-In Token
"Luna's Friend"    - 20 total runs                → Unlock LUNA OUTFIT: Casual
"The Impossible"   - Reach Ante 13                → Unlock TRUE ENDING
```

**Implementation:** `src/systems/meta.lua` + `src/core/save.lua`
- Persistent save file for unlocks/achievements
- Achievement tracking system
- Unlock conditions checked on relevant events
- Codex/collection UI screen

---

### 8. Story Beats

| Ante | Story Event |
|------|-------------|
| 1 | Luna introduces herself, explains the rules. Cheerful but hints at something darker. |
| 3 | Luna admits she's been here "a long time." Centuries? She's lost count. |
| 5 | Luna reveals others have tried. They all failed. Their spirits became the symbols on the reels. |
| 7 | Luna confesses she was once a gambler too. She bet her soul and lost. |
| 10 | Luna begins rooting for you genuinely. "Maybe you're different." |
| 12 | Luna reveals the house is a sentient entity. It feeds on hope. |
| 13 | The Final Gamble. Luna bets her freedom alongside yours. |

**Endings:**
- **Normal Ending:** Beat Ante 13. Luna is freed. The casino crumbles. You wake up somewhere... different.
- **Secret Ending:** Reach Ante 13 with Luna at max affinity — she comes with you.

---

## Implementation Priority

| Priority | Feature | Complexity | Impact |
|----------|---------|------------|--------|
| 1 | Boss Modifiers | Medium | High - variety per ante |
| 2 | Combo System | Low | High - feel-good mechanic |
| 3 | Consumables | Medium | Medium - player agency |
| 4 | Special Events | Medium | Medium - variety |
| 5 | Luna Affinity | Medium | High - emotional investment |
| 6 | Meta Progression | High | High - long-term engagement |
| 7 | Symbol Evolution | High | Medium - deep customization |
| 8 | Story/Dialogue | Low | Medium - polish |

---

## Technical Notes

### File Organization for New Features

```
src/
├── systems/
│   ├── boss_modifiers.lua   # Ante-specific challenges
│   ├── combo.lua            # Consecutive win tracking
│   ├── consumables.lua      # One-time use items
│   ├── events.lua           # Random encounters
│   ├── evolution.lua        # Symbol upgrades
│   └── meta.lua             # Achievements, unlocks
│
├── data/
│   ├── boss_defs.lua        # Boss modifier definitions
│   ├── consumable_defs.lua  # Consumable item definitions
│   ├── event_defs.lua       # Random event definitions
│   ├── achievement_defs.lua # Achievement definitions
│   └── story_defs.lua       # Story dialogue/events
│
└── screens/
    ├── codex.lua            # Collection/lore viewer
    └── evolution.lua        # Symbol evolution UI
```

### Save System Requirements

```lua
-- src/core/save.lua
Save = {
    -- Meta progression (persistent forever)
    achievements = {},
    unlocks = {},
    total_runs = 0,
    highest_ante_ever = 0,
    luna_affinity = 0,

    -- Symbol evolution (persistent)
    symbol_levels = {},
    stardust = 0,

    -- Current run (cleared on game over)
    current_run = {
        ante = 1,
        credits = 100,
        jokers = {},
        buffs = {},
    }
}
```

---

## Art/Asset Requirements

### Luna Expressions (Additional)
- `luna_thinking.png` - For shop decisions
- `luna_worried.png` - Low credits warning
- `luna_mysterious.png` - Story reveals
- `luna_determined.png` - High ante support
- `luna_freed.png` - Ending scene

### Boss Visuals
- Boss icon for each ante (13 icons)
- Boss modifier overlay effects

### UI Elements
- Combo counter display
- Consumable item icons
- Achievement notification popup
- Stardust currency icon

---

## Notes

- Keep PC-98 aesthetic consistent (limited palette, pixel art, neon glow)
- Luna should feel like a companion, not just UI decoration
- Balance: Game should feel winnable but challenging
- Target: Skilled player can reach Ante 8-10, Ante 13 is exceptional
