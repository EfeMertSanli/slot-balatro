------------------------------------------------------------
-- LUNA AFFINITY SYSTEM
-- Tracks relationship with Luna across all runs
------------------------------------------------------------

local Events = require("src.core.events")

local LunaAffinity = {}

-- Affinity level definitions
local AFFINITY_LEVELS = {
    {
        level = 1,
        name = "Stranger",
        requirement = "Start",
        bonus = "Luna gives basic tips",
        dialogue_pool = "stranger",
        wild_bonus = 0,
        mercy_spin = false,
    },
    {
        level = 2,
        name = "Acquaintance",
        requirement = "Reach Ante 3",
        bonus = "Luna warns about bad spins",
        dialogue_pool = "acquaintance",
        wild_bonus = 0,
        mercy_spin = false,
        unlock_ante = 3,
    },
    {
        level = 3,
        name = "Friend",
        requirement = "Reach Ante 5",
        bonus = "Unlock Luna's backstory",
        dialogue_pool = "friend",
        wild_bonus = 0,
        mercy_spin = false,
        unlock_ante = 5,
    },
    {
        level = 4,
        name = "Close Friend",
        requirement = "10 total runs",
        bonus = "Luna offers mercy spin on game over",
        dialogue_pool = "close_friend",
        wild_bonus = 0,
        mercy_spin = true,
        unlock_runs = 10,
    },
    {
        level = 5,
        name = "Trusted",
        requirement = "Reach Ante 8",
        bonus = "Luna secretly helps (wilds +5% more common)",
        dialogue_pool = "trusted",
        wild_bonus = 0.05,
        mercy_spin = true,
        unlock_ante = 8,
    },
    {
        level = 6,
        name = "Confidant",
        requirement = "Reach Ante 10",
        bonus = "Luna's true form revealed",
        dialogue_pool = "confidant",
        wild_bonus = 0.08,
        mercy_spin = true,
        unlock_ante = 10,
    },
    {
        level = 7,
        name = "Soulbound",
        requirement = "Beat Ante 13",
        bonus = "Ending unlocked, Luna's full support",
        dialogue_pool = "soulbound",
        wild_bonus = 0.10,
        mercy_spin = true,
        unlock_ante = 13,
        requires_win = true,
    },
}

-- Persistent state (should be saved)
local affinity_data = {
    level = 1,
    highest_ante_ever = 0,
    total_runs = 0,
    has_beaten_game = false,
    mercy_spins_used = 0,
}

------------------------------------------------------------
-- AFFINITY QUERIES
------------------------------------------------------------

function LunaAffinity.get_level()
    return affinity_data.level
end

function LunaAffinity.get_level_info()
    return AFFINITY_LEVELS[affinity_data.level] or AFFINITY_LEVELS[1]
end

function LunaAffinity.get_level_name()
    local info = LunaAffinity.get_level_info()
    return info.name
end

function LunaAffinity.get_next_level_info()
    local next_level = affinity_data.level + 1
    if next_level > #AFFINITY_LEVELS then
        return nil  -- Max level
    end
    return AFFINITY_LEVELS[next_level]
end

function LunaAffinity.get_all_levels()
    return AFFINITY_LEVELS
end

------------------------------------------------------------
-- BONUS QUERIES
------------------------------------------------------------

-- Get wild symbol weight bonus from affinity
function LunaAffinity.get_wild_bonus()
    local info = LunaAffinity.get_level_info()
    return info.wild_bonus or 0
end

-- Check if mercy spin is available
function LunaAffinity.has_mercy_spin()
    local info = LunaAffinity.get_level_info()
    return info.mercy_spin == true
end

-- Get dialogue pool for current level
function LunaAffinity.get_dialogue_pool()
    local info = LunaAffinity.get_level_info()
    return info.dialogue_pool or "stranger"
end

------------------------------------------------------------
-- PROGRESSION
------------------------------------------------------------

-- Check and update affinity level based on game state
function LunaAffinity.check_level_up(game_state)
    local current_level = affinity_data.level
    local new_level = current_level

    -- Update tracking stats
    if game_state.ante and game_state.ante > affinity_data.highest_ante_ever then
        affinity_data.highest_ante_ever = game_state.ante
    end

    -- Check each level's requirements
    for _, level_info in ipairs(AFFINITY_LEVELS) do
        if level_info.level > current_level then
            local meets_requirements = true

            -- Check ante requirement
            if level_info.unlock_ante then
                if affinity_data.highest_ante_ever < level_info.unlock_ante then
                    meets_requirements = false
                end
            end

            -- Check runs requirement
            if level_info.unlock_runs then
                if affinity_data.total_runs < level_info.unlock_runs then
                    meets_requirements = false
                end
            end

            -- Check win requirement (for level 7)
            if level_info.requires_win then
                if not affinity_data.has_beaten_game then
                    meets_requirements = false
                end
            end

            if meets_requirements then
                new_level = level_info.level
            else
                break  -- Levels must be unlocked in order
            end
        end
    end

    -- Level up occurred
    if new_level > current_level then
        affinity_data.level = new_level
        local new_info = AFFINITY_LEVELS[new_level]
        Events.emit("luna_affinity_up", {
            old_level = current_level,
            new_level = new_level,
            level_info = new_info,
        })
        return true, new_info
    end

    return false, nil
end

-- Called when a run ends (game over or win)
function LunaAffinity.on_run_end(game_state, won)
    affinity_data.total_runs = affinity_data.total_runs + 1

    if won then
        affinity_data.has_beaten_game = true
    end

    -- Check for level up
    return LunaAffinity.check_level_up(game_state)
end

-- Called when game is beaten (ante 13 completed)
function LunaAffinity.on_game_beaten()
    affinity_data.has_beaten_game = true
end

-- Use mercy spin (if available)
function LunaAffinity.use_mercy_spin()
    if LunaAffinity.has_mercy_spin() then
        affinity_data.mercy_spins_used = affinity_data.mercy_spins_used + 1
        Events.emit("mercy_spin_used", {total_used = affinity_data.mercy_spins_used})
        return true
    end
    return false
end

------------------------------------------------------------
-- PERSISTENCE
------------------------------------------------------------

-- Get data for saving
function LunaAffinity.get_save_data()
    return {
        level = affinity_data.level,
        highest_ante_ever = affinity_data.highest_ante_ever,
        total_runs = affinity_data.total_runs,
        has_beaten_game = affinity_data.has_beaten_game,
        mercy_spins_used = affinity_data.mercy_spins_used,
    }
end

-- Load saved data
function LunaAffinity.load_save_data(data)
    if not data then return end

    affinity_data.level = data.level or 1
    affinity_data.highest_ante_ever = data.highest_ante_ever or 0
    affinity_data.total_runs = data.total_runs or 0
    affinity_data.has_beaten_game = data.has_beaten_game or false
    affinity_data.mercy_spins_used = data.mercy_spins_used or 0

    -- Validate level
    if affinity_data.level < 1 then affinity_data.level = 1 end
    if affinity_data.level > #AFFINITY_LEVELS then
        affinity_data.level = #AFFINITY_LEVELS
    end
end

-- Get stats
function LunaAffinity.get_stats()
    return {
        level = affinity_data.level,
        level_name = LunaAffinity.get_level_name(),
        highest_ante = affinity_data.highest_ante_ever,
        total_runs = affinity_data.total_runs,
        has_beaten_game = affinity_data.has_beaten_game,
        mercy_spins_used = affinity_data.mercy_spins_used,
    }
end

------------------------------------------------------------
-- RESET (for testing/debug)
------------------------------------------------------------

function LunaAffinity.reset()
    affinity_data = {
        level = 1,
        highest_ante_ever = 0,
        total_runs = 0,
        has_beaten_game = false,
        mercy_spins_used = 0,
    }
end

return LunaAffinity
