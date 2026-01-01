------------------------------------------------------------
-- PAYLINES SYSTEM
-- Win detection, payline management, and score calculation
------------------------------------------------------------

local Events = require("src.core.events")

local Paylines = {}

------------------------------------------------------------
-- PAYLINE CHECKING
------------------------------------------------------------

-- Check a single payline for wins
-- Returns: score, win_type, best_symbol, match_count
function Paylines.check_payline(symbols, num_reels, bet, symbol_bonus)
    symbol_bonus = symbol_bonus or 0

    -- Count symbols and wilds
    local counts = {}
    local wild_count = 0
    for _, sym in ipairs(symbols) do
        if sym.wild then
            wild_count = wild_count + 1
        else
            counts[sym.id] = (counts[sym.id] or 0) + 1
        end
    end

    -- Find best match
    local best_match = 0
    local best_symbol = nil
    for id, count in pairs(counts) do
        local total = count + wild_count
        if total >= 2 and total > best_match then
            best_match = total
            for _, sym in ipairs(symbols) do
                if sym.id == id then
                    best_symbol = sym
                    break
                end
            end
        end
    end

    -- Special case: all wilds
    if wild_count >= num_reels then
        best_match = num_reels
        best_symbol = {name = "WILD", value = 15, id = "wild"}
    elseif wild_count >= 2 and best_match < wild_count then
        best_match = wild_count
        best_symbol = {name = "WILD", value = 15, id = "wild"}
    end

    -- No winning combination
    if best_symbol == nil then
        return 0, "", nil, 0
    end

    -- Calculate score
    local effective_value = best_symbol.value + symbol_bonus
    local score = 0
    local win_type = ""

    if best_match >= num_reels then
        -- Full match
        score = effective_value * bet * 5
        if num_reels == 4 then
            win_type = "QUAD " .. best_symbol.name .. "!"
        else
            win_type = "TRIPLE " .. best_symbol.name .. "!"
        end
    elseif best_match >= 2 then
        -- Pair
        score = math.floor(effective_value * bet * 0.5)
        win_type = "PAIR " .. best_symbol.name
    end

    return score, win_type, best_symbol, best_match
end

------------------------------------------------------------
-- PAYLINE HELPERS
------------------------------------------------------------

-- Get human-readable name for a payline
function Paylines.get_name(payline)
    if type(payline) == "string" then
        if payline == "diag_down" then return "Diagonal \\"
        elseif payline == "diag_up" then return "Diagonal /"
        else return "Line"
        end
    else
        if payline == 0 then return "Center Line"
        elseif payline == -1 then return "Top Line"
        elseif payline == 1 then return "Bottom Line"
        elseif payline == -2 then return "Far Top Line"
        elseif payline == 2 then return "Far Bottom Line"
        else return "Line " .. payline
        end
    end
end

-- Get symbol positions for a payline (reel_index -> row_offset)
function Paylines.get_symbol_positions(payline, num_reels, num_rows)
    local positions = {}
    local max_offset = math.floor(num_rows / 2)

    if type(payline) == "string" then
        -- Diagonal paylines
        for i = 1, num_reels do
            local t = (i - 1) / (num_reels - 1)
            local offset
            if payline == "diag_down" then
                offset = math.floor(-max_offset + t * max_offset * 2 + 0.5)
            else -- diag_up
                offset = math.floor(max_offset - t * max_offset * 2 + 0.5)
            end
            offset = math.max(-max_offset, math.min(max_offset, offset))
            positions[i] = offset
        end
    else
        -- Horizontal paylines
        for i = 1, num_reels do
            positions[i] = payline
        end
    end

    return positions
end

------------------------------------------------------------
-- PAYLINE MANAGEMENT
------------------------------------------------------------

-- Add a horizontal payline
function Paylines.add_horizontal(paylines_table, offset)
    table.insert(paylines_table, offset)
    return #paylines_table
end

-- Add a diagonal payline
function Paylines.add_diagonal(paylines_table, direction)
    table.insert(paylines_table, "diag_" .. direction)
    return #paylines_table
end

-- Check if payline exists
function Paylines.has_payline(paylines_table, payline)
    for _, pl in ipairs(paylines_table) do
        if pl == payline then
            return true
        end
    end
    return false
end

------------------------------------------------------------
-- JOKER EFFECTS
------------------------------------------------------------

-- Apply joker effects to a score
function Paylines.apply_joker_effects(score, symbols, jokers, state)
    if score <= 0 then return score end

    for _, joker in ipairs(jokers) do
        if joker.apply then
            score = joker.apply(score, symbols, state)
        end
    end

    return score
end

-- Run joker on_spin effects
function Paylines.run_joker_spin_effects(jokers, state, symbols)
    for _, joker in ipairs(jokers) do
        if joker.on_spin then
            joker.on_spin(state, symbols)
        end
    end
end

-- Check if player has safety net joker
function Paylines.has_safety_net(jokers)
    for _, joker in ipairs(jokers) do
        if joker.id == "insurance" then
            return true
        end
    end
    return false
end

return Paylines
