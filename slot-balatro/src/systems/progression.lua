------------------------------------------------------------
-- PROGRESSION SYSTEM
-- Antes, rounds, targets, and scaling
------------------------------------------------------------

local Config = require("src.config")
local Events = require("src.core.events")
local BuffDefs = require("src.data.buff_defs")

local Progression = {}

------------------------------------------------------------
-- TARGET CALCULATION
------------------------------------------------------------

-- Calculate target for current ante/round with permanent reductions
function Progression.calculate_target(ante, round_in_ante, target_reduction)
    target_reduction = target_reduction or 0

    -- Base target scaled by ante (exponential) and round within ante (linear)
    local ante_mult = math.pow(Config.TARGET_ANTE_SCALING, ante - 1)
    local round_mult = math.pow(Config.TARGET_ROUND_SCALING, round_in_ante - 1)
    local base_target = Config.BASE_TARGET * ante_mult * round_mult

    -- Apply permanent target reduction (cap at 50%)
    local reduction = 1 - math.min(target_reduction, 0.5)

    return math.floor(base_target * reduction)
end

-- Get effective spins per round (base + permanent bonus)
function Progression.get_effective_spins(extra_spins)
    extra_spins = extra_spins or 0
    return Config.SPINS_PER_ROUND + extra_spins
end

------------------------------------------------------------
-- ANTE REWARDS
------------------------------------------------------------

-- Generate random buff choices for ante completion
function Progression.generate_reward_choices(count)
    count = count or 3
    return BuffDefs.get_random(count)
end

-- Apply a buff effect using state bridge pattern
function Progression.apply_buff(buff, game_state)
    if not buff or not buff.effect then return false end

    -- Create state bridge for buff effects
    local state_bridge = {
        perm = {
            starting_credits = game_state.perm_starting_credits or 0,
            win_bonus = game_state.perm_win_bonus or 0,
            target_reduction = game_state.perm_target_reduction or 0,
            extra_spins = game_state.perm_extra_spins or 0,
            free_reroll = game_state.perm_free_reroll or false,
            symbol_bonus = game_state.perm_symbol_bonus or 0,
            wild_bonus = game_state.perm_wild_bonus or 0,
            shop_discount = game_state.perm_shop_discount or 0,
            payline_bonus = game_state.perm_payline_bonus or 0,
        },
        max_jokers = game_state.max_jokers,
    }

    -- Apply buff effect
    buff.effect(state_bridge)

    -- Copy back to game state
    game_state.perm_starting_credits = state_bridge.perm.starting_credits
    game_state.perm_win_bonus = state_bridge.perm.win_bonus
    game_state.perm_target_reduction = state_bridge.perm.target_reduction
    game_state.perm_extra_spins = state_bridge.perm.extra_spins
    game_state.perm_free_reroll = state_bridge.perm.free_reroll
    game_state.perm_symbol_bonus = state_bridge.perm.symbol_bonus
    game_state.perm_wild_bonus = state_bridge.perm.wild_bonus
    game_state.perm_shop_discount = state_bridge.perm.shop_discount
    game_state.perm_payline_bonus = state_bridge.perm.payline_bonus
    game_state.max_jokers = state_bridge.max_jokers

    Events.emit(Events.NAMES.ANTE_REWARD_SELECTED, {buff = buff})
    return true
end

------------------------------------------------------------
-- ROUND/ANTE TRANSITIONS
------------------------------------------------------------

-- Check if ante is complete
function Progression.is_ante_complete(round_in_ante)
    return round_in_ante >= Config.ROUNDS_PER_ANTE
end

-- Calculate ante completion bonus
function Progression.get_ante_bonus(ante)
    return 50 * ante
end

-- Calculate round completion bonus
function Progression.get_round_bonus(round)
    return 20 + round * 5
end

------------------------------------------------------------
-- DIFFICULTY SCALING INFO
------------------------------------------------------------

-- Get scaling info for display
function Progression.get_scaling_info()
    return {
        rounds_per_ante = Config.ROUNDS_PER_ANTE,
        spins_per_round = Config.SPINS_PER_ROUND,
        base_target = Config.BASE_TARGET,
        round_scaling = Config.TARGET_ROUND_SCALING,
        ante_scaling = Config.TARGET_ANTE_SCALING,
    }
end

-- Preview targets for upcoming rounds
function Progression.preview_targets(ante, round_in_ante, count, target_reduction)
    local targets = {}
    local current_ante = ante
    local current_round = round_in_ante

    for i = 1, count do
        table.insert(targets, {
            ante = current_ante,
            round = current_round,
            target = Progression.calculate_target(current_ante, current_round, target_reduction)
        })

        current_round = current_round + 1
        if current_round > Config.ROUNDS_PER_ANTE then
            current_round = 1
            current_ante = current_ante + 1
        end
    end

    return targets
end

return Progression
