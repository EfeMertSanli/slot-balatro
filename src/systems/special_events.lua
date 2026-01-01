------------------------------------------------------------
-- SPECIAL EVENTS SYSTEM
-- Manages random encounters that occur during rounds
------------------------------------------------------------

local EventDefs = require("src.data.event_defs")
local CoreEvents = require("src.core.events")

local SpecialEvents = {}

-- Current active event (nil if none)
local active_event = nil

-- Event state
local event_state = {
    free_spins_granted = 0,
    collector_active = false,
}

------------------------------------------------------------
-- EVENT TRIGGERING
------------------------------------------------------------

-- Roll for event at round start
function SpecialEvents.try_trigger(game_state)
    -- Don't trigger during ante 1 (tutorial)
    if game_state.ante <= 1 then
        return nil
    end

    -- Roll against trigger chance
    local chance = EventDefs.get_trigger_chance()
    if math.random() > chance then
        return nil
    end

    -- Get a random event
    local event = EventDefs.get_random()
    if not event then
        return nil
    end

    -- Check requirements
    if event.requires_joker and (not game_state.jokers or #game_state.jokers == 0) then
        -- Reroll if requires joker but player has none
        event = EventDefs.get_random()
        if event and event.requires_joker then
            return nil
        end
    end

    -- Set as active
    active_event = event
    event_state = {
        free_spins_granted = 0,
        collector_active = event.id == "the_collector",
    }

    -- Randomize cursed reel if applicable
    if event.cursed_reel then
        event.cursed_reel = math.random(game_state.num_reels or 3)
        event.effect_desc = "Something feels wrong with reel " .. event.cursed_reel .. "..."
    end

    CoreEvents.emit("special_event_triggered", {event = event})

    return event
end

-- Clear event at round end
function SpecialEvents.clear()
    if active_event then
        CoreEvents.emit("special_event_ended", {event = active_event})
    end
    active_event = nil
    event_state = {
        free_spins_granted = 0,
        collector_active = false,
    }
end

------------------------------------------------------------
-- GETTERS
------------------------------------------------------------

function SpecialEvents.get_active()
    return active_event
end

function SpecialEvents.is_active()
    return active_event ~= nil
end

function SpecialEvents.get_event_state()
    return event_state
end

------------------------------------------------------------
-- MODIFIER QUERIES
------------------------------------------------------------

-- Get payout multiplier from active event
function SpecialEvents.get_payout_multiplier()
    if not active_event then return 1.0 end
    return active_event.payout_multiplier or 1.0
end

-- Get minimum bet multiplier from active event
function SpecialEvents.get_min_bet_multiplier()
    if not active_event then return 1 end
    return active_event.min_bet_multiplier or 1
end

-- Get cursed reel (if any)
function SpecialEvents.get_cursed_reel()
    if not active_event then return nil end
    return active_event.cursed_reel
end

-- Check if low symbols only for a reel
function SpecialEvents.is_low_symbols_only(reel_index)
    if not active_event then return false end
    return active_event.low_symbols_only and active_event.cursed_reel == reel_index
end

-- Get boosted symbol info
function SpecialEvents.get_symbol_boost()
    if not active_event then return nil, 0 end
    if active_event.boosted_symbol then
        return active_event.boosted_symbol, active_event.symbol_weight_bonus or 0
    end
    return nil, 0
end

-- Check if free consumable should be granted
function SpecialEvents.should_grant_consumable()
    if not active_event then return false end
    return active_event.free_consumable == true
end

-- Get free spins from event
function SpecialEvents.get_free_spins()
    if not active_event then return 0 end
    if active_event.free_spins and event_state.free_spins_granted == 0 then
        event_state.free_spins_granted = active_event.free_spins
        return active_event.free_spins
    end
    return 0
end

-- Check if collector trade is available
function SpecialEvents.is_collector_active()
    return event_state.collector_active
end

-- Get collector trade multiplier
function SpecialEvents.get_collector_multiplier()
    if not active_event or active_event.id ~= "the_collector" then
        return 1.0
    end
    return active_event.trade_multiplier or 2.0
end

-- Complete collector trade (disables further trades this event)
function SpecialEvents.complete_collector_trade()
    event_state.collector_active = false
end

------------------------------------------------------------
-- DISPLAY HELPERS
------------------------------------------------------------

function SpecialEvents.get_display_info()
    if not active_event then
        return nil
    end

    return {
        name = active_event.name,
        icon = active_event.icon,
        desc = active_event.desc,
        effect_desc = active_event.effect_desc,
        color = active_event.color,
    }
end

function SpecialEvents.format_event_text()
    if not active_event then return "" end

    return string.format("[%s] %s: %s",
        active_event.icon,
        active_event.name,
        active_event.desc
    )
end

------------------------------------------------------------
-- RESET
------------------------------------------------------------

function SpecialEvents.reset()
    active_event = nil
    event_state = {
        free_spins_granted = 0,
        collector_active = false,
    }
end

return SpecialEvents
