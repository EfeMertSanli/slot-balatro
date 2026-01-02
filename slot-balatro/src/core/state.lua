------------------------------------------------------------
-- STATE MODULE
-- Central game state - single source of truth
-- All systems read/write state through this module
------------------------------------------------------------

local State = {}

------------------------------------------------------------
-- SCREEN STATE
------------------------------------------------------------
State.current_screen = "play"  -- play, shop, jokers, ante_reward, game_over

------------------------------------------------------------
-- CREDITS & BETTING
------------------------------------------------------------
State.credits = 100
State.bet = 1
State.max_bet = 10
State.last_win = 0
State.last_win_type = ""  -- "pair", "triple", ""
State.highest_credits = 100

------------------------------------------------------------
-- PROGRESSION (Roguelike)
------------------------------------------------------------
State.ante = 1
State.round = 1
State.round_in_ante = 1
State.round_target = 100
State.spins_per_round = 10
State.spins_this_round = 0
State.total_spins = 0
State.highest_ante = 1
State.games_played = 0

------------------------------------------------------------
-- PERMANENT BUFFS (persist across runs)
------------------------------------------------------------
State.perm = {
    starting_credits = 0,
    win_bonus = 0,
    target_reduction = 0,
    extra_spins = 0,
    free_reroll = false,
    symbol_bonus = 0,
    wild_bonus = 0,
    shop_discount = 0,
    payline_bonus = 0,
}

------------------------------------------------------------
-- ANTE REWARD SELECTION
------------------------------------------------------------
State.ante_reward_choices = {}
State.selected_ante_reward = 0

------------------------------------------------------------
-- COLLECTIONS
------------------------------------------------------------
State.jokers = {}
State.max_jokers = 5
State.slot_changers = {}

------------------------------------------------------------
-- SHOP STATE
------------------------------------------------------------
State.shop_items = {}
State.shop_slot_changers = {}
State.shop_bought_joker = false
State.shop_bought_changer = false
State.shop_rerolled = false

------------------------------------------------------------
-- SLOT CONFIGURATION
------------------------------------------------------------
State.num_reels = 3
State.num_rows = 3
State.num_paylines = 1
State.paylines = {0}
State.wild_magnet = false

------------------------------------------------------------
-- SPINNING STATE
------------------------------------------------------------
State.spinning = false
State.reels = {}

------------------------------------------------------------
-- WIN DETECTION STATE
------------------------------------------------------------
State.winning_paylines = {}
State.win_reveal_active = false
State.win_reveal_queue = {}
State.win_reveal_index = 0
State.win_reveal_timer = 0
State.win_reveal_delay = 0.8
State.current_reveal_payline = nil
State.lit_symbols = {}
State.payline_scores = {}
State.pending_round_end_check = false

------------------------------------------------------------
-- ANIMATION STATE
------------------------------------------------------------
State.fast_forward = false
State.normal_reveal_delay = 0.8
State.fast_reveal_delay = 0.2
State.win_flash = 0

------------------------------------------------------------
-- UI STATE
------------------------------------------------------------
State.message = "GOOD LUCK!"
State.sub_message = "Press SPACE to spin"

------------------------------------------------------------
-- LUNA STATE
------------------------------------------------------------
State.luna_expression = "idle"
State.luna_loss_streak = 0

------------------------------------------------------------
-- STATE MANAGEMENT FUNCTIONS
------------------------------------------------------------

-- Reset for new run (keep permanent buffs)
function State.reset_run(config)
    State.current_screen = "play"
    State.ante = 1
    State.round = 1
    State.round_in_ante = 1
    State.credits = config.STARTING_CREDITS + State.perm.starting_credits
    State.bet = config.STARTING_BET
    State.max_bet = config.MAX_BET
    State.last_win = 0
    State.last_win_type = ""
    State.spins_this_round = 0
    State.total_spins = 0

    State.jokers = {}
    State.max_jokers = config.MAX_JOKERS
    State.slot_changers = {}
    State.num_reels = config.NUM_REELS
    State.num_rows = 3
    State.num_paylines = 1
    State.paylines = {0}
    State.wild_magnet = false

    State.shop_items = {}
    State.shop_slot_changers = {}
    State.shop_bought_joker = false
    State.shop_bought_changer = false
    State.shop_rerolled = false

    State.spinning = false
    State.winning_paylines = {}
    State.win_reveal_active = false
    State.win_reveal_queue = {}
    State.win_reveal_index = 0
    State.lit_symbols = {}
    State.payline_scores = {}

    State.fast_forward = false
    State.win_reveal_delay = State.normal_reveal_delay
    State.win_flash = 0

    State.message = "GOOD LUCK!"
    State.sub_message = "Press SPACE to spin"

    State.luna_expression = "idle"
    State.luna_loss_streak = 0
end

-- Full reset (including permanent buffs)
function State.reset_all(config)
    State.perm = {
        starting_credits = 0,
        win_bonus = 0,
        target_reduction = 0,
        extra_spins = 0,
        free_reroll = false,
        symbol_bonus = 0,
        wild_bonus = 0,
        shop_discount = 0,
        payline_bonus = 0,
    }
    State.highest_credits = config.STARTING_CREDITS
    State.highest_ante = 1
    State.games_played = 0
    State.reset_run(config)
end

-- Initialize state with config values
function State.init(config)
    State.credits = config.STARTING_CREDITS
    State.bet = config.STARTING_BET
    State.max_bet = config.MAX_BET
    State.max_jokers = config.MAX_JOKERS
    State.num_reels = config.NUM_REELS
    State.spins_per_round = config.SPINS_PER_ROUND
    State.highest_credits = config.STARTING_CREDITS
end

return State
