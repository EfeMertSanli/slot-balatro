------------------------------------------------------------
-- COMBO SYSTEM
-- Tracks consecutive wins for multiplier bonuses
------------------------------------------------------------

local Events = require("src.core.events")

local Combo = {}

-- Combo state
local consecutive_wins = 0
local current_multiplier = 1.0

-- Combo multiplier tiers
local COMBO_TIERS = {
    {wins = 1, mult = 1.0},   -- First win
    {wins = 2, mult = 1.2},   -- 2 in a row
    {wins = 3, mult = 1.5},   -- 3 in a row
    {wins = 4, mult = 2.0},   -- 4 in a row
    {wins = 5, mult = 2.5},   -- 5+ in a row (MAX)
}

------------------------------------------------------------
-- COMBO MANAGEMENT
------------------------------------------------------------

-- Called when a spin results in a win
function Combo.on_win()
    consecutive_wins = consecutive_wins + 1
    current_multiplier = Combo.get_multiplier_for_wins(consecutive_wins)

    Events.emit("combo_increased", {
        wins = consecutive_wins,
        multiplier = current_multiplier
    })

    return current_multiplier
end

-- Called when a spin results in no win
function Combo.on_loss()
    if consecutive_wins > 0 then
        Events.emit("combo_broken", {
            final_wins = consecutive_wins,
            final_multiplier = current_multiplier
        })
    end

    consecutive_wins = 0
    current_multiplier = 1.0
end

-- Get multiplier for a given number of consecutive wins
function Combo.get_multiplier_for_wins(wins)
    local mult = 1.0

    for _, tier in ipairs(COMBO_TIERS) do
        if wins >= tier.wins then
            mult = tier.mult
        end
    end

    return mult
end

------------------------------------------------------------
-- GETTERS
------------------------------------------------------------

function Combo.get_consecutive_wins()
    return consecutive_wins
end

function Combo.get_current_multiplier()
    return current_multiplier
end

function Combo.is_active()
    return consecutive_wins >= 2  -- Combo starts at 2 wins
end

function Combo.get_next_multiplier()
    return Combo.get_multiplier_for_wins(consecutive_wins + 1)
end

-- Get combo display info
function Combo.get_display_info()
    return {
        wins = consecutive_wins,
        multiplier = current_multiplier,
        is_active = Combo.is_active(),
        is_max = consecutive_wins >= 5,
        next_mult = Combo.get_next_multiplier()
    }
end

------------------------------------------------------------
-- RESET
------------------------------------------------------------

function Combo.reset()
    consecutive_wins = 0
    current_multiplier = 1.0
end

return Combo
