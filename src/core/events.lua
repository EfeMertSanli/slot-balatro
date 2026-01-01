------------------------------------------------------------
-- EVENTS MODULE
-- Event bus for decoupled communication between systems
-- Systems emit events, other systems listen and react
------------------------------------------------------------

local Events = {}

-- Internal listener storage
local listeners = {}

------------------------------------------------------------
-- CORE API
------------------------------------------------------------

-- Register a callback for an event
-- Returns an ID that can be used to unsubscribe
function Events.on(event_name, callback)
    if not listeners[event_name] then
        listeners[event_name] = {}
    end
    local id = #listeners[event_name] + 1
    listeners[event_name][id] = callback
    return {event = event_name, id = id}
end

-- Remove a listener by its handle
function Events.off(handle)
    if handle and listeners[handle.event] then
        listeners[handle.event][handle.id] = nil
    end
end

-- Emit an event with optional data
function Events.emit(event_name, data)
    if listeners[event_name] then
        for _, callback in pairs(listeners[event_name]) do
            if callback then
                callback(data)
            end
        end
    end
end

-- Clear all listeners (useful for reset)
function Events.clear()
    listeners = {}
end

-- Clear listeners for a specific event
function Events.clear_event(event_name)
    listeners[event_name] = nil
end

------------------------------------------------------------
-- EVENT NAMES (documentation / constants)
-- Using these helps avoid typos and documents the system
------------------------------------------------------------
Events.NAMES = {
    -- Spin lifecycle
    SPIN_REQUESTED = "spin_requested",
    SPIN_STARTED = "spin_started",
    REEL_STOPPED = "reel_stopped",
    SPIN_COMPLETE = "spin_complete",

    -- Win events
    WIN_DETECTED = "win_detected",
    WIN_REVEAL_START = "win_reveal_start",
    WIN_REVEAL_NEXT = "win_reveal_next",
    WIN_REVEAL_COMPLETE = "win_reveal_complete",
    NO_WIN = "no_win",

    -- Round/Ante lifecycle
    ROUND_START = "round_start",
    ROUND_END = "round_end",
    ROUND_FAILED = "round_failed",
    ANTE_COMPLETE = "ante_complete",
    ANTE_REWARD_SELECTED = "ante_reward_selected",

    -- Game lifecycle
    GAME_START = "game_start",
    GAME_OVER = "game_over",
    NEW_RUN = "new_run",

    -- Economy
    CREDITS_CHANGED = "credits_changed",
    BET_CHANGED = "bet_changed",

    -- Shop
    SHOP_OPENED = "shop_opened",
    SHOP_REROLLED = "shop_rerolled",
    JOKER_BOUGHT = "joker_bought",
    JOKER_SOLD = "joker_sold",
    UPGRADE_BOUGHT = "upgrade_bought",

    -- Luna
    LUNA_EXPRESSION_CHANGED = "luna_expression_changed",

    -- Effects
    TRIGGER_PARTICLES = "trigger_particles",
    TRIGGER_SCREEN_SHAKE = "trigger_screen_shake",
    TRIGGER_FLOATING_TEXT = "trigger_floating_text",
}

return Events
