------------------------------------------------------------
-- BOSS MODIFIERS SYSTEM
-- Manages boss effects throughout gameplay
------------------------------------------------------------

local Bosses = require("src.data.boss_defs")
local Events = require("src.core.events")

local BossModifiers = {}

-- Current boss state
local current_boss = nil
local boss_state = {}

------------------------------------------------------------
-- INITIALIZATION
------------------------------------------------------------

function BossModifiers.init(ante)
    current_boss = Bosses.get(ante)
    boss_state = {}

    if current_boss then
        Events.emit("boss_changed", {boss = current_boss})
    end

    return current_boss
end

function BossModifiers.get_current()
    return current_boss
end

function BossModifiers.get_state()
    return boss_state
end

------------------------------------------------------------
-- LIFECYCLE HOOKS
------------------------------------------------------------

-- Called at the start of each round
function BossModifiers.on_round_start(game_state)
    if not current_boss then return end

    -- Copy relevant state for boss to modify
    boss_state.credits = game_state.credits
    boss_state.bet = game_state.bet
    boss_state.max_bet = game_state.max_bet or 10
    boss_state.jokers = game_state.jokers or {}

    -- Run boss effect
    current_boss.on_round_start(boss_state)

    -- Apply state changes back
    if boss_state.credits ~= game_state.credits then
        local diff = game_state.credits - boss_state.credits
        game_state.credits = boss_state.credits
        if diff > 0 then
            Events.emit("boss_tax", {amount = diff, boss = current_boss})
        end
    end

    if boss_state.bet and boss_state.bet ~= game_state.bet then
        game_state.bet = boss_state.bet
    end

    return boss_state
end

-- Called when a spin completes
function BossModifiers.on_spin(game_state)
    if not current_boss then return end

    boss_state.spinning = false
    current_boss.on_spin(boss_state)
end

-- Called when calculating win amount - returns modified score
function BossModifiers.on_win(game_state, score)
    if not current_boss then return score end

    return current_boss.on_win(boss_state, score)
end

-- Called when shop opens
function BossModifiers.on_shop_open(game_state)
    if not current_boss then return end

    current_boss.on_shop_open(boss_state)
end

------------------------------------------------------------
-- MODIFIER QUERIES
------------------------------------------------------------

-- Get shop price multiplier (for The Miser, The Final)
function BossModifiers.get_price_multiplier()
    if not current_boss then return 1.0 end
    return current_boss.price_multiplier or 1.0
end

-- Get target multiplier (for The Flood, Luna Unchained)
function BossModifiers.get_target_multiplier()
    if not current_boss then return 1.0 end
    return current_boss.target_multiplier or 1.0
end

-- Get spin reduction (for The Drought, The Final)
function BossModifiers.get_spin_reduction()
    if not current_boss then return 0 end
    return current_boss.spin_reduction or 0
end

-- Get extra rows (for The Flood)
function BossModifiers.get_extra_rows()
    if not current_boss then return 0 end
    return current_boss.extra_rows or 0
end

-- Get hidden reel index (for The Blind)
function BossModifiers.get_hidden_reel()
    if not current_boss then return nil end
    return boss_state.boss_hidden_reel
end

-- Get minimum bet override (for The Gambler)
function BossModifiers.get_min_bet()
    return boss_state.boss_min_bet
end

-- Get disabled joker slot (for The Void)
function BossModifiers.get_disabled_joker_slot()
    if not current_boss then return nil end
    return boss_state.boss_disabled_joker
end

-- Check if paylines should be mirrored (for The Mirror)
function BossModifiers.should_mirror_paylines()
    return boss_state.boss_mirror_paylines == true
end

-- Get cursed symbol (for The Cursed)
function BossModifiers.get_cursed_symbol()
    return boss_state.boss_cursed_symbol
end

-- Check if a symbol is cursed
function BossModifiers.is_symbol_cursed(symbol_id)
    return boss_state.boss_cursed_symbol == symbol_id
end

------------------------------------------------------------
-- UI HELPERS
------------------------------------------------------------

function BossModifiers.get_display_info()
    if not current_boss then
        return {
            name = "No Boss",
            icon = "---",
            desc = "",
            effect_desc = "",
            color = {1, 1, 1}
        }
    end

    return {
        name = current_boss.name,
        icon = current_boss.icon,
        desc = current_boss.desc,
        effect_desc = current_boss.effect_desc,
        color = current_boss.color
    }
end

-- Get formatted boss info for display
function BossModifiers.format_boss_text()
    if not current_boss then return "" end

    return string.format("[%s] %s: %s",
        current_boss.icon,
        current_boss.name,
        current_boss.desc
    )
end

------------------------------------------------------------
-- RESET
------------------------------------------------------------

function BossModifiers.reset()
    current_boss = nil
    boss_state = {}
end

return BossModifiers
