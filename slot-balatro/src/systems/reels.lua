------------------------------------------------------------
-- REELS SYSTEM
-- Handles reel spinning, symbol placement, and animations
------------------------------------------------------------

local Config = require("src.config")
local Symbols = require("src.data.symbols")
local Events = require("src.core.events")

local Reels = {}

-- Internal state
local reels = {}
local spinning = false
local wild_magnet = false

------------------------------------------------------------
-- INITIALIZATION
------------------------------------------------------------

function Reels.init(num_reels)
    reels = {}
    for i = 1, num_reels do
        local reel = {
            symbols = {},
            position = 0,
            target_position = 0,
            spinning = false,
            speed = 0,
            stop_time = 0,
        }
        -- Fill with weighted random symbols
        for j = 1, 20 do
            table.insert(reel.symbols, Reels.get_weighted_symbol())
        end
        table.insert(reels, reel)
    end
    spinning = false
end

-- Add a new reel (for slot changers)
function Reels.add_reel()
    local reel = {
        symbols = {},
        position = 0,
        target_position = 0,
        spinning = false,
        speed = 0,
        stop_time = 0,
    }
    for j = 1, 20 do
        table.insert(reel.symbols, Reels.get_weighted_symbol())
    end
    table.insert(reels, reel)
    return #reels
end

------------------------------------------------------------
-- SYMBOL SELECTION
------------------------------------------------------------

function Reels.set_wild_magnet(enabled)
    wild_magnet = enabled
end

function Reels.get_weighted_symbol()
    local wild_mult = wild_magnet and 2 or 1

    -- Calculate total weight
    local total = 0
    for _, sym in ipairs(Symbols) do
        local weight = sym.weight or 10
        if sym.wild then
            weight = weight * wild_mult
        end
        total = total + weight
    end

    -- Roll and select
    local roll = math.random() * total
    local cumulative = 0

    for _, sym in ipairs(Symbols) do
        local weight = sym.weight or 10
        if sym.wild then
            weight = weight * wild_mult
        end
        cumulative = cumulative + weight
        if roll <= cumulative then
            return sym
        end
    end

    return Symbols[1]
end

------------------------------------------------------------
-- SPINNING
------------------------------------------------------------

function Reels.spin()
    if spinning then
        return false
    end

    spinning = true

    -- Determine if this spin will be a "lucky" spin
    local lucky_spin = math.random() < 0.25
    local lucky_symbol = nil
    if lucky_spin then
        lucky_symbol = Reels.get_weighted_symbol()
    end

    -- Start each reel
    for i, reel in ipairs(reels) do
        reel.spinning = true
        reel.speed = Config.SPIN_SPEED
        reel.stop_time = love.timer.getTime() + 0.5 + (i - 1) * 0.3

        -- Randomize symbols for next spin
        for j = 1, #reel.symbols do
            if lucky_spin and lucky_symbol and math.random() < 0.6 then
                reel.symbols[j] = lucky_symbol
            else
                reel.symbols[j] = Reels.get_weighted_symbol()
            end
        end

        -- Set target position
        reel.target_position = reel.position + Config.SYMBOL_HEIGHT * (10 + math.random(5))
    end

    Events.emit(Events.NAMES.SPIN_STARTED, {})
    return true
end

function Reels.update(dt)
    if not spinning then return false end

    local all_stopped = true
    local current_time = love.timer.getTime()

    for i, reel in ipairs(reels) do
        if reel.spinning then
            all_stopped = false

            if current_time >= reel.stop_time then
                -- Decelerate
                reel.speed = reel.speed * Config.SPIN_DECEL

                if reel.speed < 50 then
                    -- Snap to position
                    reel.position = math.floor(reel.position / Config.SYMBOL_HEIGHT + 0.5) * Config.SYMBOL_HEIGHT
                    reel.spinning = false
                    reel.speed = 0
                    Events.emit(Events.NAMES.REEL_STOPPED, {reel_index = i})
                end
            end

            reel.position = reel.position + reel.speed * dt
        end
    end

    if all_stopped then
        spinning = false
        Events.emit(Events.NAMES.SPIN_COMPLETE, {reels = reels})
        return true  -- Spin complete
    end

    return false
end

------------------------------------------------------------
-- ACCESSORS
------------------------------------------------------------

function Reels.get_reels()
    return reels
end

function Reels.get_reel(index)
    return reels[index]
end

function Reels.get_count()
    return #reels
end

function Reels.is_spinning()
    return spinning
end

-- Get symbols at a specific row offset from center
function Reels.get_symbols_at_offset(offset, num_rows)
    local symbols = {}
    local center_j = math.floor(num_rows / 2)
    for i, reel in ipairs(reels) do
        local base_idx = math.floor(reel.position / Config.SYMBOL_HEIGHT)
        local idx = ((base_idx + center_j + offset) % #reel.symbols) + 1
        table.insert(symbols, reel.symbols[idx])
    end
    return symbols
end

-- Get symbols along a diagonal
function Reels.get_diagonal_symbols(direction, num_rows)
    local symbols = {}
    local num_reels = #reels
    local center_j = math.floor(num_rows / 2)
    local max_offset = math.floor(num_rows / 2)

    for i, reel in ipairs(reels) do
        local base_idx = math.floor(reel.position / Config.SYMBOL_HEIGHT)
        local t = (i - 1) / (num_reels - 1)
        local offset

        if direction == "down" then
            offset = math.floor(-max_offset + t * max_offset * 2 + 0.5)
        else -- "up"
            offset = math.floor(max_offset - t * max_offset * 2 + 0.5)
        end

        offset = math.max(-max_offset, math.min(max_offset, offset))
        local idx = ((base_idx + center_j + offset) % #reel.symbols) + 1
        table.insert(symbols, reel.symbols[idx])
    end
    return symbols
end

function Reels.get_center_symbols(num_rows)
    return Reels.get_symbols_at_offset(0, num_rows)
end

return Reels
