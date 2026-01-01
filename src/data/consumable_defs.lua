------------------------------------------------------------
-- CONSUMABLE DEFINITIONS
-- One-time use items bought in shop, used during play
------------------------------------------------------------

local Colors = require("src.colors")

local Consumables = {}

-- All consumable item definitions
local items = {
    {
        id = "rewind_token",
        name = "Rewind Token",
        icon = "<-|",
        color = Colors.cyan,
        cost = 50,
        rarity = "uncommon",
        desc = "Undo last spin",
        effect_desc = "Restore credits from before the last spin",
        -- Use timing: after a spin completes
        use_timing = "after_spin",
        -- Requires a previous spin to exist
        can_use = function(state)
            return state.last_spin_credits ~= nil and not state.spinning
        end,
    },
    {
        id = "wild_card",
        name = "Wild Card",
        icon = "[W]",
        color = Colors.gold,
        cost = 30,
        rarity = "common",
        desc = "Force one wild on next spin",
        effect_desc = "Guarantee at least one WILD symbol",
        -- Use timing: before a spin
        use_timing = "before_spin",
        can_use = function(state)
            return not state.spinning
        end,
    },
    {
        id = "time_freeze",
        name = "Time Freeze",
        icon = "[+]",
        color = Colors.blue,
        cost = 40,
        rarity = "uncommon",
        desc = "+3 spins this round",
        effect_desc = "Gain 3 extra spins immediately",
        -- Use timing: anytime during play
        use_timing = "anytime",
        can_use = function(state)
            return state.state == "play" and not state.spinning
        end,
    },
    {
        id = "lucky_coin",
        name = "Lucky Coin",
        icon = "[$]",
        color = Colors.gold,
        cost = 25,
        rarity = "common",
        desc = "Double next win",
        effect_desc = "Your next winning spin pays 2x",
        -- Use timing: before a spin
        use_timing = "before_spin",
        can_use = function(state)
            return not state.spinning
        end,
    },
    {
        id = "mulligan",
        name = "Mulligan",
        icon = "[R]",
        color = Colors.purple,
        cost = 60,
        rarity = "rare",
        desc = "Reroll current reel results",
        effect_desc = "Respin all reels without using a spin",
        -- Use timing: after a spin completes
        use_timing = "after_spin",
        can_use = function(state)
            return state.state == "play" and not state.spinning and state.spins_this_round > 0
        end,
    },
}

------------------------------------------------------------
-- HELPER FUNCTIONS
------------------------------------------------------------

function Consumables.get_all()
    local result = {}
    for _, item in ipairs(items) do
        -- Deep copy
        local copy = {}
        for k, v in pairs(item) do
            copy[k] = v
        end
        table.insert(result, copy)
    end
    return result
end

function Consumables.get_by_id(id)
    for _, item in ipairs(items) do
        if item.id == id then
            return item
        end
    end
    return nil
end

function Consumables.get_random(count)
    local available = Consumables.get_all()

    -- Shuffle
    for i = #available, 2, -1 do
        local j = math.random(i)
        available[i], available[j] = available[j], available[i]
    end

    -- Pick count
    local result = {}
    for i = 1, math.min(count, #available) do
        table.insert(result, available[i])
    end
    return result
end

function Consumables.get_by_rarity(rarity)
    local result = {}
    for _, item in ipairs(items) do
        if item.rarity == rarity then
            local copy = {}
            for k, v in pairs(item) do
                copy[k] = v
            end
            table.insert(result, copy)
        end
    end
    return result
end

return Consumables
