------------------------------------------------------------
-- META PROGRESSION SYSTEM
-- Tracks achievements, unlocks, and persistent progress
------------------------------------------------------------

local AchievementDefs = require("src.data.achievement_defs")
local Events = require("src.core.events")

local Meta = {}

-- Persistent meta data
local meta_data = {
    -- Achievement tracking
    achievements_unlocked = {},  -- Set of unlocked achievement IDs

    -- Statistics
    stats = {
        total_runs = 0,
        total_wins = 0,
        highest_ante_ever = 0,
        highest_credits_ever = 0,
        total_spins = 0,
        total_credits_won = 0,
        max_bets_placed = 0,
        biggest_single_win = 0,
        highest_combo = 0,
        events_seen = {},  -- Set of event IDs seen
        jokers_collected = {},  -- Set of joker IDs ever owned
    },

    -- Unlocks
    unlocks = {
        jokers = {},  -- Additional joker IDs unlocked
        consumables = {},  -- Additional consumable IDs unlocked
        symbol_sets = {},  -- Symbol set IDs unlocked
        luna_outfits = {},  -- Luna outfit IDs unlocked
        titles = {},  -- Title IDs unlocked
        endings = {},  -- Ending IDs unlocked
        extra_joker_slots = 0,  -- Bonus joker slots
    },

    -- Run tracking
    current_run = {
        spin_count = 0,
        first_spin = true,
        max_bet_count = 0,
    },
}

------------------------------------------------------------
-- ACHIEVEMENT CHECKING
------------------------------------------------------------

-- Check if an achievement is unlocked
function Meta.is_achievement_unlocked(achievement_id)
    return meta_data.achievements_unlocked[achievement_id] == true
end

-- Unlock an achievement
function Meta.unlock_achievement(achievement_id)
    if Meta.is_achievement_unlocked(achievement_id) then
        return false  -- Already unlocked
    end

    local achievement = AchievementDefs.get_by_id(achievement_id)
    if not achievement then
        return false
    end

    meta_data.achievements_unlocked[achievement_id] = true

    -- Apply unlock reward
    if achievement.unlock then
        Meta.apply_unlock(achievement.unlock)
    end

    Events.emit("achievement_unlocked", {
        achievement = achievement,
    })

    return true
end

-- Apply an unlock reward
function Meta.apply_unlock(unlock)
    if unlock.type == "joker" then
        meta_data.unlocks.jokers[unlock.id] = true
    elseif unlock.type == "consumable" then
        meta_data.unlocks.consumables[unlock.id] = true
    elseif unlock.type == "symbol_set" then
        meta_data.unlocks.symbol_sets[unlock.id] = true
    elseif unlock.type == "luna_outfit" then
        meta_data.unlocks.luna_outfits[unlock.id] = true
    elseif unlock.type == "title" then
        meta_data.unlocks.titles[unlock.id] = true
    elseif unlock.type == "ending" then
        meta_data.unlocks.endings[unlock.id] = true
    elseif unlock.type == "joker_slot" then
        meta_data.unlocks.extra_joker_slots = meta_data.unlocks.extra_joker_slots + 1
    end
end

-- Check all achievements against current state
function Meta.check_achievements(game_state)
    local newly_unlocked = {}

    for _, achievement in ipairs(AchievementDefs.get_all()) do
        if not Meta.is_achievement_unlocked(achievement.id) then
            if Meta.check_requirement(achievement.requirement, game_state) then
                Meta.unlock_achievement(achievement.id)
                table.insert(newly_unlocked, achievement)
            end
        end
    end

    return newly_unlocked
end

-- Check if a specific requirement is met
function Meta.check_requirement(req, game_state)
    if req.type == "single_win" then
        return meta_data.stats.biggest_single_win >= req.amount

    elseif req.type == "reach_ante" then
        return meta_data.stats.highest_ante_ever >= req.ante

    elseif req.type == "beat_game" then
        return meta_data.stats.highest_ante_ever >= 13 and meta_data.stats.total_wins > 0

    elseif req.type == "total_runs" then
        return meta_data.stats.total_runs >= req.amount

    elseif req.type == "credits" then
        return meta_data.stats.highest_credits_ever >= req.amount

    elseif req.type == "max_bets" then
        return meta_data.stats.max_bets_placed >= req.amount

    elseif req.type == "combo" then
        return meta_data.stats.highest_combo >= req.amount

    elseif req.type == "unique_events" then
        local count = 0
        for _, _ in pairs(meta_data.stats.events_seen) do
            count = count + 1
        end
        return count >= req.amount

    elseif req.type == "joker_count" then
        if game_state and game_state.jokers then
            return #game_state.jokers >= req.amount
        end
        return false

    elseif req.type == "exact_credits" then
        if game_state then
            return game_state.credits == req.amount
        end
        return false

    elseif req.type == "triple_wild" then
        -- This needs to be tracked during spin
        return meta_data.stats.has_triple_wild == true

    elseif req.type == "first_spin_triple_seven" then
        return meta_data.stats.has_first_spin_triple_seven == true
    end

    return false
end

------------------------------------------------------------
-- STAT TRACKING
------------------------------------------------------------

-- Update stats after a spin
function Meta.on_spin(win_amount, symbols, game_state)
    meta_data.stats.total_spins = meta_data.stats.total_spins + 1
    meta_data.current_run.spin_count = meta_data.current_run.spin_count + 1

    if win_amount > 0 then
        meta_data.stats.total_credits_won = meta_data.stats.total_credits_won + win_amount

        if win_amount > meta_data.stats.biggest_single_win then
            meta_data.stats.biggest_single_win = win_amount
        end
    end

    -- Check for max bet
    if game_state and game_state.bet and game_state.max_bet then
        if game_state.bet >= game_state.max_bet then
            meta_data.stats.max_bets_placed = meta_data.stats.max_bets_placed + 1
            meta_data.current_run.max_bet_count = meta_data.current_run.max_bet_count + 1
        end
    end

    -- Track credits
    if game_state and game_state.credits then
        if game_state.credits > meta_data.stats.highest_credits_ever then
            meta_data.stats.highest_credits_ever = game_state.credits
        end
    end

    -- Check for triple wild (if symbols provided)
    if symbols then
        local wild_count = 0
        for _, sym in ipairs(symbols) do
            if sym and sym.wild then
                wild_count = wild_count + 1
            end
        end
        if wild_count >= 3 then
            meta_data.stats.has_triple_wild = true
        end

        -- Check first spin triple seven
        if meta_data.current_run.first_spin then
            meta_data.current_run.first_spin = false
            local seven_count = 0
            for _, sym in ipairs(symbols) do
                if sym and sym.id == "seven" then
                    seven_count = seven_count + 1
                end
            end
            if seven_count >= 3 then
                meta_data.stats.has_first_spin_triple_seven = true
            end
        end
    end

    -- Check achievements
    return Meta.check_achievements(game_state)
end

-- Update combo tracking
function Meta.on_combo(combo_count)
    if combo_count > meta_data.stats.highest_combo then
        meta_data.stats.highest_combo = combo_count
    end
end

-- Track special event
function Meta.on_event(event_id)
    meta_data.stats.events_seen[event_id] = true
end

-- Track joker acquisition
function Meta.on_joker_acquired(joker_id)
    meta_data.stats.jokers_collected[joker_id] = true
end

-- Update ante tracking
function Meta.on_ante_change(ante)
    if ante > meta_data.stats.highest_ante_ever then
        meta_data.stats.highest_ante_ever = ante
    end
end

-- Called when run ends
function Meta.on_run_end(won, game_state)
    meta_data.stats.total_runs = meta_data.stats.total_runs + 1

    if won then
        meta_data.stats.total_wins = meta_data.stats.total_wins + 1
    end

    -- Reset run tracking
    meta_data.current_run = {
        spin_count = 0,
        first_spin = true,
        max_bet_count = 0,
    }

    -- Final achievement check
    return Meta.check_achievements(game_state)
end

------------------------------------------------------------
-- UNLOCK QUERIES
------------------------------------------------------------

function Meta.get_unlocked_jokers()
    local result = {}
    for id, _ in pairs(meta_data.unlocks.jokers) do
        table.insert(result, id)
    end
    return result
end

function Meta.is_joker_unlocked(joker_id)
    return meta_data.unlocks.jokers[joker_id] == true
end

function Meta.get_extra_joker_slots()
    return meta_data.unlocks.extra_joker_slots
end

function Meta.is_outfit_unlocked(outfit_id)
    return meta_data.unlocks.luna_outfits[outfit_id] == true
end

function Meta.is_ending_unlocked(ending_id)
    return meta_data.unlocks.endings[ending_id] == true
end

------------------------------------------------------------
-- ACHIEVEMENT QUERIES
------------------------------------------------------------

function Meta.get_unlocked_achievements()
    local result = {}
    for id, _ in pairs(meta_data.achievements_unlocked) do
        local achievement = AchievementDefs.get_by_id(id)
        if achievement then
            table.insert(result, achievement)
        end
    end
    return result
end

function Meta.get_locked_achievements()
    local result = {}
    for _, achievement in ipairs(AchievementDefs.get_all()) do
        if not Meta.is_achievement_unlocked(achievement.id) then
            table.insert(result, achievement)
        end
    end
    return result
end

function Meta.get_achievement_progress()
    local total = AchievementDefs.get_count()
    local unlocked = 0
    for _, _ in pairs(meta_data.achievements_unlocked) do
        unlocked = unlocked + 1
    end
    return unlocked, total
end

------------------------------------------------------------
-- STATS QUERIES
------------------------------------------------------------

function Meta.get_stats()
    return {
        total_runs = meta_data.stats.total_runs,
        total_wins = meta_data.stats.total_wins,
        highest_ante = meta_data.stats.highest_ante_ever,
        highest_credits = meta_data.stats.highest_credits_ever,
        total_spins = meta_data.stats.total_spins,
        total_credits_won = meta_data.stats.total_credits_won,
        biggest_win = meta_data.stats.biggest_single_win,
        highest_combo = meta_data.stats.highest_combo,
    }
end

------------------------------------------------------------
-- PERSISTENCE
------------------------------------------------------------

function Meta.get_save_data()
    return {
        achievements_unlocked = meta_data.achievements_unlocked,
        stats = meta_data.stats,
        unlocks = meta_data.unlocks,
    }
end

function Meta.load_save_data(data)
    if not data then return end

    meta_data.achievements_unlocked = data.achievements_unlocked or {}
    meta_data.stats = data.stats or meta_data.stats
    meta_data.unlocks = data.unlocks or meta_data.unlocks
end

------------------------------------------------------------
-- RESET
------------------------------------------------------------

function Meta.reset()
    meta_data = {
        achievements_unlocked = {},
        stats = {
            total_runs = 0,
            total_wins = 0,
            highest_ante_ever = 0,
            highest_credits_ever = 0,
            total_spins = 0,
            total_credits_won = 0,
            max_bets_placed = 0,
            biggest_single_win = 0,
            highest_combo = 0,
            events_seen = {},
            jokers_collected = {},
        },
        unlocks = {
            jokers = {},
            consumables = {},
            symbol_sets = {},
            luna_outfits = {},
            titles = {},
            endings = {},
            extra_joker_slots = 0,
        },
        current_run = {
            spin_count = 0,
            first_spin = true,
            max_bet_count = 0,
        },
    }
end

return Meta
