------------------------------------------------------------
-- ACHIEVEMENT DEFINITIONS
-- Unlockable achievements and their rewards
------------------------------------------------------------

local Colors = require("src.colors")

local Achievements = {}

-- All achievement definitions
local achievement_list = {
    -- Early game achievements
    {
        id = "first_blood",
        name = "First Blood",
        icon = "!!!",
        color = Colors.red,
        desc = "Win 100 credits in one spin",
        category = "wins",
        requirement = {type = "single_win", amount = 100},
        unlock = {type = "joker", id = "blood_pact"},
        unlock_desc = "Unlocks JOKER: Blood Pact",
    },
    {
        id = "lucky_start",
        name = "Lucky Start",
        icon = "777",
        color = Colors.gold,
        desc = "Get 3 sevens on your first spin of a run",
        category = "special",
        requirement = {type = "first_spin_triple_seven"},
        unlock = {type = "title", id = "lucky"},
        unlock_desc = "Unlocks title: The Lucky",
    },
    {
        id = "combo_king",
        name = "Combo King",
        icon = "x5x",
        color = Colors.cyan,
        desc = "Reach a 5x combo multiplier",
        category = "combo",
        requirement = {type = "combo", amount = 5},
        unlock = {type = "joker", id = "combo_master"},
        unlock_desc = "Unlocks JOKER: Combo Master",
    },

    -- Progress achievements
    {
        id = "survivor",
        name = "Survivor",
        icon = "ANT",
        color = Colors.green,
        desc = "Reach Ante 5",
        category = "progress",
        requirement = {type = "reach_ante", ante = 5},
        unlock = {type = "symbol_set", id = "arcana"},
        unlock_desc = "Unlocks SYMBOL SET: Arcana",
    },
    {
        id = "veteran",
        name = "Veteran",
        icon = "VET",
        color = Colors.blue,
        desc = "Reach Ante 8",
        category = "progress",
        requirement = {type = "reach_ante", ante = 8},
        unlock = {type = "joker", id = "veterans_luck"},
        unlock_desc = "Unlocks JOKER: Veteran's Luck",
    },
    {
        id = "elite",
        name = "Elite",
        icon = "ELI",
        color = Colors.purple,
        desc = "Reach Ante 10",
        category = "progress",
        requirement = {type = "reach_ante", ante = 10},
        unlock = {type = "consumable", id = "elite_token"},
        unlock_desc = "Unlocks CONSUMABLE: Elite Token",
    },
    {
        id = "the_impossible",
        name = "The Impossible",
        icon = "WIN",
        color = Colors.gold,
        desc = "Beat Ante 13 and win the game",
        category = "progress",
        requirement = {type = "beat_game"},
        unlock = {type = "ending", id = "true_ending"},
        unlock_desc = "Unlocks TRUE ENDING",
    },

    -- Economy achievements
    {
        id = "high_roller",
        name = "High Roller",
        icon = "MAX",
        color = Colors.gold,
        desc = "Bet max 50 times",
        category = "economy",
        requirement = {type = "max_bets", amount = 50},
        unlock = {type = "consumable", id = "all_in_token"},
        unlock_desc = "Unlocks CONSUMABLE: All-In Token",
    },
    {
        id = "millionaire",
        name = "Millionaire",
        icon = "$M$",
        color = Colors.gold,
        desc = "Have 1000+ credits at once",
        category = "economy",
        requirement = {type = "credits", amount = 1000},
        unlock = {type = "joker", id = "midas_touch"},
        unlock_desc = "Unlocks JOKER: Midas Touch",
    },
    {
        id = "penny_pincher",
        name = "Penny Pincher",
        icon = "1c",
        color = Colors.green,
        desc = "Win a round with exactly 1 credit remaining",
        category = "economy",
        requirement = {type = "exact_credits", amount = 1},
        unlock = {type = "joker", id = "lucky_penny"},
        unlock_desc = "Unlocks JOKER: Lucky Penny",
    },

    -- Run count achievements
    {
        id = "persistent",
        name = "Persistent",
        icon = "x10",
        color = Colors.blue,
        desc = "Complete 10 runs",
        category = "runs",
        requirement = {type = "total_runs", amount = 10},
        unlock = {type = "luna_outfit", id = "casual"},
        unlock_desc = "Unlocks LUNA OUTFIT: Casual",
    },
    {
        id = "dedicated",
        name = "Dedicated",
        icon = "x25",
        color = Colors.purple,
        desc = "Complete 25 runs",
        category = "runs",
        requirement = {type = "total_runs", amount = 25},
        unlock = {type = "luna_outfit", id = "formal"},
        unlock_desc = "Unlocks LUNA OUTFIT: Formal",
    },
    {
        id = "lunas_friend",
        name = "Luna's Friend",
        icon = "<3>",
        color = Colors.magenta,
        desc = "Complete 50 runs",
        category = "runs",
        requirement = {type = "total_runs", amount = 50},
        unlock = {type = "luna_outfit", id = "true_form"},
        unlock_desc = "Unlocks LUNA OUTFIT: True Form",
    },

    -- Special achievements
    {
        id = "wild_child",
        name = "Wild Child",
        icon = "[W]",
        color = Colors.cyan,
        desc = "Get 3 wilds in one spin",
        category = "special",
        requirement = {type = "triple_wild"},
        unlock = {type = "joker", id = "wild_heart"},
        unlock_desc = "Unlocks JOKER: Wild Heart",
    },
    {
        id = "event_hunter",
        name = "Event Hunter",
        icon = "EVT",
        color = Colors.purple,
        desc = "Trigger 10 different special events",
        category = "special",
        requirement = {type = "unique_events", amount = 10},
        unlock = {type = "consumable", id = "event_charm"},
        unlock_desc = "Unlocks CONSUMABLE: Event Charm",
    },
    {
        id = "joker_collector",
        name = "Joker Collector",
        icon = "JKR",
        color = Colors.gold,
        desc = "Own 5 jokers at once",
        category = "special",
        requirement = {type = "joker_count", amount = 5},
        unlock = {type = "joker_slot"},
        unlock_desc = "Unlocks +1 Joker Slot",
    },
}

------------------------------------------------------------
-- HELPER FUNCTIONS
------------------------------------------------------------

function Achievements.get_all()
    local result = {}
    for _, achievement in ipairs(achievement_list) do
        local copy = {}
        for k, v in pairs(achievement) do
            copy[k] = v
        end
        table.insert(result, copy)
    end
    return result
end

function Achievements.get_by_id(id)
    for _, achievement in ipairs(achievement_list) do
        if achievement.id == id then
            return achievement
        end
    end
    return nil
end

function Achievements.get_by_category(category)
    local result = {}
    for _, achievement in ipairs(achievement_list) do
        if achievement.category == category then
            local copy = {}
            for k, v in pairs(achievement) do
                copy[k] = v
            end
            table.insert(result, copy)
        end
    end
    return result
end

function Achievements.get_categories()
    return {"progress", "wins", "economy", "runs", "combo", "special"}
end

function Achievements.get_count()
    return #achievement_list
end

return Achievements
