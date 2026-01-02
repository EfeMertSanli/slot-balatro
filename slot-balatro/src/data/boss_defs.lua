------------------------------------------------------------
-- BOSS DEFINITIONS
-- Each ante has a unique boss modifier that changes gameplay
------------------------------------------------------------

local Colors = require("src.colors")

local Bosses = {
    {
        id = "welcome",
        ante = 1,
        name = "The Welcome",
        icon = ">>>",
        color = Colors.cyan,
        desc = "No modifier - Tutorial",
        effect_desc = "Good luck!",
        -- No modifier for ante 1
        on_round_start = function(state) end,
        on_spin = function(state) end,
        on_win = function(state, score) return score end,
        on_shop_open = function(state) end,
    },
    {
        id = "miser",
        ante = 2,
        name = "The Miser",
        icon = "$$$",
        color = Colors.gold,
        desc = "Shop prices +50%",
        effect_desc = "Everything costs more...",
        price_multiplier = 1.5,
        on_round_start = function(state) end,
        on_spin = function(state) end,
        on_win = function(state, score) return score end,
        on_shop_open = function(state)
            -- Prices increased in shop generation
        end,
    },
    {
        id = "blind",
        ante = 3,
        name = "The Blind",
        icon = "???",
        color = Colors.dim,
        desc = "One reel hidden until spin ends",
        effect_desc = "What's behind reel 2?",
        hidden_reel = 2,  -- Middle reel hidden
        on_round_start = function(state)
            state.boss_hidden_reel = 2
        end,
        on_spin = function(state) end,
        on_win = function(state, score) return score end,
        on_shop_open = function(state)
            state.boss_hidden_reel = nil
        end,
    },
    {
        id = "taxman",
        ante = 4,
        name = "The Taxman",
        icon = "-%-",
        color = Colors.red,
        desc = "Lose 10% of credits each round",
        effect_desc = "The house takes its cut",
        tax_rate = 0.10,
        on_round_start = function(state)
            local tax = math.floor(state.credits * 0.10)
            state.credits = state.credits - tax
            state.boss_tax_paid = tax
        end,
        on_spin = function(state) end,
        on_win = function(state, score) return score end,
        on_shop_open = function(state) end,
    },
    {
        id = "cursed",
        ante = 5,
        name = "The Cursed",
        icon = "X_X",
        color = Colors.purple,
        desc = "One random symbol is worthless",
        effect_desc = "Cherries are cursed!",
        on_round_start = function(state)
            -- Pick a random non-wild symbol to curse
            local symbols = {"cherry", "lemon", "bell", "star", "clover", "diamond", "seven"}
            state.boss_cursed_symbol = symbols[math.random(#symbols)]
        end,
        on_spin = function(state) end,
        on_win = function(state, score) return score end,
        on_shop_open = function(state) end,
    },
    {
        id = "gambler",
        ante = 6,
        name = "The Gambler",
        icon = "ALL",
        color = Colors.gold,
        desc = "Minimum bet is 50% of max",
        effect_desc = "Go big or go home",
        on_round_start = function(state)
            local min_bet = math.ceil(state.max_bet * 0.5)
            if state.bet < min_bet then
                state.bet = min_bet
            end
            state.boss_min_bet = min_bet
        end,
        on_spin = function(state) end,
        on_win = function(state, score) return score end,
        on_shop_open = function(state)
            state.boss_min_bet = nil
        end,
    },
    {
        id = "mirror",
        ante = 7,
        name = "The Mirror",
        icon = "<=>",
        color = Colors.cyan,
        desc = "Paylines are reversed",
        effect_desc = "Everything is backwards",
        on_round_start = function(state)
            state.boss_mirror_paylines = true
        end,
        on_spin = function(state) end,
        on_win = function(state, score) return score end,
        on_shop_open = function(state)
            state.boss_mirror_paylines = nil
        end,
    },
    {
        id = "void",
        ante = 8,
        name = "The Void",
        icon = "[X]",
        color = Colors.purple,
        desc = "One joker slot is disabled",
        effect_desc = "Lost in the void...",
        on_round_start = function(state)
            state.boss_disabled_joker = math.min(#state.jokers, 1)
        end,
        on_spin = function(state) end,
        on_win = function(state, score) return score end,
        on_shop_open = function(state) end,
    },
    {
        id = "flood",
        ante = 9,
        name = "The Flood",
        icon = "~~~",
        color = Colors.blue,
        desc = "+2 rows, but targets +100%",
        effect_desc = "More symbols, harder goals",
        target_multiplier = 2.0,
        extra_rows = 2,
        on_round_start = function(state)
            -- Rows added in game setup
        end,
        on_spin = function(state) end,
        on_win = function(state, score) return score end,
        on_shop_open = function(state) end,
    },
    {
        id = "drought",
        ante = 10,
        name = "The Drought",
        icon = "...",
        color = Colors.orange,
        desc = "-2 spins per round",
        effect_desc = "Make every spin count",
        spin_reduction = 2,
        on_round_start = function(state) end,
        on_spin = function(state) end,
        on_win = function(state, score) return score end,
        on_shop_open = function(state) end,
    },
    {
        id = "chaos",
        ante = 11,
        name = "The Chaos",
        icon = "?!?",
        color = Colors.purple,
        desc = "Win multipliers randomized",
        effect_desc = "Anything can happen!",
        on_round_start = function(state) end,
        on_spin = function(state) end,
        on_win = function(state, score)
            -- Random multiplier between 0.5x and 2.0x
            local mult = 0.5 + math.random() * 1.5
            return math.floor(score * mult)
        end,
        on_shop_open = function(state) end,
    },
    {
        id = "final",
        ante = 12,
        name = "The Final",
        icon = "!!!",
        color = Colors.red,
        desc = "All modifiers at 50% strength",
        effect_desc = "Everything at once...",
        -- Combines multiple effects at reduced strength
        price_multiplier = 1.25,
        tax_rate = 0.05,
        spin_reduction = 1,
        on_round_start = function(state)
            -- Apply reduced tax
            local tax = math.floor(state.credits * 0.05)
            state.credits = state.credits - tax
        end,
        on_spin = function(state) end,
        on_win = function(state, score)
            -- Slight random variance
            local mult = 0.8 + math.random() * 0.4
            return math.floor(score * mult)
        end,
        on_shop_open = function(state) end,
    },
    {
        id = "luna",
        ante = 13,
        name = "Luna Unchained",
        icon = "***",
        color = Colors.gold,
        desc = "Luna's personal challenge",
        effect_desc = "This is it. Win, and we're both free.",
        -- Final boss - tough but fair
        target_multiplier = 1.5,
        on_round_start = function(state) end,
        on_spin = function(state) end,
        on_win = function(state, score)
            -- Luna helps a bit - bonus on big wins
            if score >= 50 then
                return math.floor(score * 1.2)
            end
            return score
        end,
        on_shop_open = function(state) end,
    },
}

------------------------------------------------------------
-- HELPER FUNCTIONS
------------------------------------------------------------

function Bosses.get(ante)
    for _, boss in ipairs(Bosses) do
        if boss.ante == ante then
            return boss
        end
    end
    -- Return first boss as fallback
    return Bosses[1]
end

function Bosses.get_by_id(id)
    for _, boss in ipairs(Bosses) do
        if boss.id == id then
            return boss
        end
    end
    return nil
end

return Bosses
