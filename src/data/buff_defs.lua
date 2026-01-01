------------------------------------------------------------
-- BUFF DEFINITIONS
-- Permanent buffs earned at ante completion
------------------------------------------------------------

local Colors = require("src.colors")

local Buffs = {
    ------------------------------------------------------------
    -- CREDIT BUFFS
    ------------------------------------------------------------
    {
        id = "starting_bonus",
        name = "Head Start",
        icon = "$$$",
        color = Colors.gold,
        category = "credits",
        desc = "+50 starting credits",
        effect = function(state)
            state.perm.starting_credits = state.perm.starting_credits + 50
        end
    },
    {
        id = "win_bonus",
        name = "Winner's Edge",
        icon = "+%+",
        color = Colors.win,
        category = "credits",
        desc = "+10% to all wins",
        effect = function(state)
            state.perm.win_bonus = state.perm.win_bonus + 0.10
        end
    },
    {
        id = "target_reduction",
        name = "Lower Standards",
        icon = "TGT",
        color = Colors.cyan,
        category = "credits",
        desc = "-15% target requirements",
        effect = function(state)
            state.perm.target_reduction = state.perm.target_reduction + 0.15
        end
    },

    ------------------------------------------------------------
    -- SPIN BUFFS
    ------------------------------------------------------------
    {
        id = "extra_spin",
        name = "Extra Spin",
        icon = "+1S",
        color = Colors.highlight,
        category = "spins",
        desc = "+1 spin per round",
        effect = function(state)
            state.perm.extra_spins = state.perm.extra_spins + 1
        end
    },
    {
        id = "free_reroll",
        name = "Lucky Reroll",
        icon = "RRL",
        color = Colors.purple,
        category = "spins",
        desc = "Free shop reroll each round",
        effect = function(state)
            state.perm.free_reroll = true
        end
    },

    ------------------------------------------------------------
    -- SYMBOL BUFFS
    ------------------------------------------------------------
    {
        id = "symbol_value",
        name = "Precious Symbols",
        icon = "GEM",
        color = Colors.blue,
        category = "symbols",
        desc = "+2 to all symbol values",
        effect = function(state)
            state.perm.symbol_bonus = state.perm.symbol_bonus + 2
        end
    },
    {
        id = "wild_chance",
        name = "Wild Fortune",
        icon = "W!W",
        color = Colors.purple,
        category = "symbols",
        desc = "Increased wild frequency",
        effect = function(state)
            state.perm.wild_bonus = state.perm.wild_bonus + 1
        end
    },

    ------------------------------------------------------------
    -- JOKER BUFFS
    ------------------------------------------------------------
    {
        id = "joker_slot",
        name = "Joker Space",
        icon = "J+1",
        color = Colors.highlight,
        category = "jokers",
        desc = "+1 max joker slot",
        effect = function(state)
            state.max_jokers = state.max_jokers + 1
        end
    },
    {
        id = "cheaper_shop",
        name = "Discount Card",
        icon = "-$-",
        color = Colors.gold,
        category = "shop",
        desc = "-20% shop prices",
        effect = function(state)
            state.perm.shop_discount = state.perm.shop_discount + 0.20
        end
    },

    ------------------------------------------------------------
    -- PAYLINE BUFFS
    ------------------------------------------------------------
    {
        id = "payline_bonus",
        name = "Line Master",
        icon = "===",
        color = Colors.cyan,
        category = "paylines",
        desc = "+5 bonus per active payline",
        effect = function(state)
            state.perm.payline_bonus = state.perm.payline_bonus + 5
        end
    },
}

------------------------------------------------------------
-- HELPER FUNCTIONS
------------------------------------------------------------

-- Get buff by ID
function Buffs.get(id)
    for _, buff in ipairs(Buffs) do
        if buff.id == id then
            return buff
        end
    end
    return nil
end

-- Get buffs by category
function Buffs.get_by_category(category)
    local result = {}
    for _, buff in ipairs(Buffs) do
        if buff.category == category then
            table.insert(result, buff)
        end
    end
    return result
end

-- Get random selection of N buffs
function Buffs.get_random(count)
    local available = {}
    for i, buff in ipairs(Buffs) do
        table.insert(available, i)
    end

    -- Shuffle
    for i = #available, 2, -1 do
        local j = math.random(i)
        available[i], available[j] = available[j], available[i]
    end

    -- Pick count
    local result = {}
    for i = 1, math.min(count, #available) do
        table.insert(result, Buffs[available[i]])
    end
    return result
end

return Buffs
