------------------------------------------------------------
-- JOKER DEFINITIONS
-- Static data for all joker cards
-- Each joker has: id, name, icon, color, cost, effect text, apply function
------------------------------------------------------------

local Colors = require("src.colors")

local Jokers = {
    ------------------------------------------------------------
    -- COMMON JOKERS (Cost: 35-50)
    ------------------------------------------------------------
    {
        id = "greedy",
        name = "Golden Touch",
        icon = "G$G",
        color = Colors.gold,
        cost = 40,
        rarity = "common",
        effect = "All wins +25%",
        effect_short = "+25% wins",
        apply = function(score, symbols, state)
            return math.floor(score * 1.25)
        end
    },
    {
        id = "lucky_clover",
        name = "Lucky Clover",
        icon = "^.^",
        color = Colors.win,
        cost = 35,
        rarity = "common",
        effect = "+15 bonus on any win",
        effect_short = "Win +15",
        apply = function(score, symbols, state)
            if score > 0 then return score + 15 end
            return score
        end
    },
    {
        id = "cherry_bomb",
        name = "Cherry Bomb",
        icon = "*!*",
        color = Colors.red,
        cost = 45,
        rarity = "common",
        effect = "+20 per cherry shown",
        effect_short = "Cherry+20",
        apply = function(score, symbols, state)
            local bonus = 0
            for _, s in ipairs(symbols) do
                if s.id == "cherry" then bonus = bonus + 20 end
            end
            return score + bonus
        end
    },
    {
        id = "lemon_squeeze",
        name = "Lemon Squeeze",
        icon = "L%L",
        color = Colors.gold,
        cost = 45,
        rarity = "common",
        effect = "Lemons pay x2",
        effect_short = "Lemon x2",
        apply = function(score, symbols, state)
            for _, s in ipairs(symbols) do
                if s.id == "lemon" then return score * 2 end
            end
            return score
        end
    },

    ------------------------------------------------------------
    -- UNCOMMON JOKERS (Cost: 55-75)
    ------------------------------------------------------------
    {
        id = "lucky_seven",
        name = "Lucky Seven",
        icon = "777",
        color = Colors.win,
        cost = 75,
        rarity = "uncommon",
        effect = "Sevens pay triple",
        effect_short = "7s x3",
        apply = function(score, symbols, state)
            for _, s in ipairs(symbols) do
                if s.id == "seven" then return score * 3 end
            end
            return score
        end
    },
    {
        id = "clover_collector",
        name = "Clover Hunter",
        icon = "^.^",
        color = Colors.win,
        cost = 60,
        rarity = "uncommon",
        effect = "Clovers give +40 bonus",
        effect_short = "Clover +40",
        apply = function(score, symbols, state)
            for _, s in ipairs(symbols) do
                if s.id == "clover" then return score + 40 end
            end
            return score
        end
    },
    {
        id = "diamond_cutter",
        name = "Diamond Cutter",
        icon = "<>",
        color = Colors.blue,
        cost = 70,
        rarity = "uncommon",
        effect = "Diamonds pay x2.5",
        effect_short = "Diam x2.5",
        apply = function(score, symbols, state)
            for _, s in ipairs(symbols) do
                if s.id == "diamond" then return math.floor(score * 2.5) end
            end
            return score
        end
    },
    {
        id = "star_power",
        name = "Star Power",
        icon = "*+*",
        color = Colors.cyan,
        cost = 65,
        rarity = "uncommon",
        effect = "Stars grant extra spin",
        effect_short = "Star=spin",
        apply = function(score, symbols, state)
            return score
        end,
        on_spin = function(state, symbols)
            for _, s in ipairs(symbols) do
                if s.id == "star" then
                    state.spins_this_round = math.max(0, state.spins_this_round - 1)
                    return true
                end
            end
            return false
        end
    },
    {
        id = "bell_ringer",
        name = "Bell Ringer",
        icon = "BEL",
        color = Colors.gold,
        cost = 55,
        rarity = "uncommon",
        effect = "Bells add +30 always",
        effect_short = "Bell +30",
        apply = function(score, symbols, state)
            local bonus = 0
            for _, s in ipairs(symbols) do
                if s.id == "bell" then bonus = bonus + 30 end
            end
            return score + bonus
        end
    },

    ------------------------------------------------------------
    -- RARE JOKERS (Cost: 80-100)
    ------------------------------------------------------------
    {
        id = "necromancer",
        name = "Skull Lord",
        icon = "S+S",
        color = Colors.purple,
        cost = 90,
        rarity = "rare",
        effect = "Each wild doubles score",
        effect_short = "Wild x2",
        apply = function(score, symbols, state)
            local wild_count = 0
            for _, s in ipairs(symbols) do
                if s.wild then wild_count = wild_count + 1 end
            end
            if wild_count > 0 then
                return score * (2 ^ wild_count)
            end
            return score
        end
    },
    {
        id = "high_roller",
        name = "High Roller",
        icon = "MAX",
        color = Colors.gold,
        cost = 100,
        rarity = "rare",
        effect = "Max bet: wins x2",
        effect_short = "MaxBet x2",
        apply = function(score, symbols, state)
            if state and state.bet >= state.max_bet then
                return score * 2
            end
            return score
        end
    },
    {
        id = "combo_king",
        name = "Combo King",
        icon = "CMB",
        color = Colors.cyan,
        cost = 85,
        rarity = "rare",
        effect = "+50% per consecutive win",
        effect_short = "Streak+",
        apply = function(score, symbols, state)
            if state and state.last_win > 0 then
                return math.floor(score * 1.5)
            end
            return score
        end
    },
    {
        id = "insurance",
        name = "Safety Net",
        icon = "NET",
        color = Colors.blue,
        cost = 80,
        rarity = "rare",
        effect = "Refund bet on no match",
        effect_short = "No loss",
        apply = function(score, symbols, state)
            return score
        end,
        -- Note: Actual refund logic handled in win detection
    },

    ------------------------------------------------------------
    -- LEGENDARY JOKERS (Cost: 120-200)
    ------------------------------------------------------------
    {
        id = "jackpot",
        name = "Jackpot Joker",
        icon = "J!P",
        color = Colors.yellow,
        cost = 150,
        rarity = "legendary",
        effect = "Pure triple = x5",
        effect_short = "Pure x5",
        apply = function(score, symbols, state)
            -- Only if all 3 symbols are exactly the same (no wilds)
            if #symbols >= 3 and symbols[1].id == symbols[2].id and symbols[2].id == symbols[3].id and not symbols[1].wild then
                return score * 5
            end
            return score
        end
    },
    {
        id = "chaos_dealer",
        name = "Chaos Dealer",
        icon = "???",
        color = Colors.purple,
        cost = 120,
        rarity = "legendary",
        effect = "Random x1 to x4 multiplier",
        effect_short = "Rnd x1-4",
        apply = function(score, symbols, state)
            local mult = 1 + math.random() * 3
            return math.floor(score * mult)
        end
    },
    {
        id = "midas",
        name = "Midas Touch",
        icon = "AU!",
        color = Colors.gold,
        cost = 200,
        rarity = "legendary",
        effect = "All symbols +5 value",
        effect_short = "All +5",
        apply = function(score, symbols, state)
            return score + (#symbols * 25)
        end
    },
    {
        id = "time_warp",
        name = "Time Warp",
        icon = "<->",
        color = Colors.cyan,
        cost = 130,
        rarity = "legendary",
        effect = "+2 spins per round",
        effect_short = "+2 spins",
        apply = function(score, symbols, state)
            return score
        end,
        on_acquire = function(state)
            state.spins_per_round = state.spins_per_round + 2
        end
    },
}

------------------------------------------------------------
-- HELPER FUNCTIONS
------------------------------------------------------------

-- Get joker by ID
function Jokers.get(id)
    for _, joker in ipairs(Jokers) do
        if joker.id == id then
            return joker
        end
    end
    return nil
end

-- Get jokers by rarity
function Jokers.get_by_rarity(rarity)
    local result = {}
    for _, joker in ipairs(Jokers) do
        if joker.rarity == rarity then
            table.insert(result, joker)
        end
    end
    return result
end

-- Get all jokers (shallow copy)
function Jokers.get_all()
    local result = {}
    for _, joker in ipairs(Jokers) do
        table.insert(result, joker)
    end
    return result
end

return Jokers
