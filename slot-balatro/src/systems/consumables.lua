------------------------------------------------------------
-- CONSUMABLES SYSTEM
-- Manages consumable item inventory and usage
------------------------------------------------------------

local ConsumableDefs = require("src.data.consumable_defs")
local Events = require("src.core.events")

local Consumables = {}

-- Maximum consumables player can hold
local MAX_CONSUMABLES = 5

-- Player's consumable inventory
local inventory = {}

-- Active effects (buffs applied but not yet consumed)
local active_effects = {
    wild_guaranteed = false,    -- Wild Card: force wild on next spin
    double_next_win = false,    -- Lucky Coin: double next win
}

-- State for rewind
local last_spin_credits = nil

------------------------------------------------------------
-- INVENTORY MANAGEMENT
------------------------------------------------------------

function Consumables.add(consumable_id)
    if #inventory >= MAX_CONSUMABLES then
        return false, "Inventory full"
    end

    local def = ConsumableDefs.get_by_id(consumable_id)
    if not def then
        return false, "Unknown consumable"
    end

    -- Add copy to inventory
    local item = {}
    for k, v in pairs(def) do
        item[k] = v
    end
    table.insert(inventory, item)

    Events.emit("consumable_acquired", {item = item})
    return true
end

function Consumables.remove(index)
    if index < 1 or index > #inventory then
        return false
    end

    local item = table.remove(inventory, index)
    Events.emit("consumable_removed", {item = item})
    return true
end

function Consumables.get_inventory()
    return inventory
end

function Consumables.get_count()
    return #inventory
end

function Consumables.is_full()
    return #inventory >= MAX_CONSUMABLES
end

function Consumables.get_max()
    return MAX_CONSUMABLES
end

------------------------------------------------------------
-- USAGE
------------------------------------------------------------

function Consumables.can_use(index, game_state)
    local item = inventory[index]
    if not item then
        return false, "No item at index"
    end

    if item.can_use then
        return item.can_use(game_state)
    end

    return true
end

function Consumables.use(index, game_state)
    local item = inventory[index]
    if not item then
        return false, "No item at index"
    end

    -- Check if usable
    local can, reason = Consumables.can_use(index, game_state)
    if not can then
        return false, reason
    end

    -- Apply effect based on item type
    local success, msg = Consumables.apply_effect(item, game_state)
    if not success then
        return false, msg
    end

    -- Remove from inventory
    table.remove(inventory, index)

    Events.emit("consumable_used", {item = item})
    return true
end

function Consumables.apply_effect(item, game_state)
    if item.id == "rewind_token" then
        -- Restore credits from before last spin
        if last_spin_credits then
            local restored = last_spin_credits - game_state.credits
            game_state.credits = last_spin_credits
            return true, "Restored " .. restored .. " credits"
        end
        return false, "No spin to rewind"

    elseif item.id == "wild_card" then
        -- Flag for next spin
        active_effects.wild_guaranteed = true
        return true, "Wild guaranteed on next spin"

    elseif item.id == "time_freeze" then
        -- Add 3 spins
        game_state.spins_per_round = game_state.spins_per_round + 3
        return true, "+3 spins added"

    elseif item.id == "lucky_coin" then
        -- Double next win
        active_effects.double_next_win = true
        return true, "Next win doubled"

    elseif item.id == "mulligan" then
        -- Set flag to trigger respin
        active_effects.mulligan_pending = true
        return true, "Rerolling reels..."
    end

    return false, "Unknown effect"
end

------------------------------------------------------------
-- ACTIVE EFFECTS
------------------------------------------------------------

-- Check if wild is guaranteed (Wild Card effect)
function Consumables.is_wild_guaranteed()
    return active_effects.wild_guaranteed
end

-- Clear wild guarantee (call after spin)
function Consumables.clear_wild_guarantee()
    active_effects.wild_guaranteed = false
end

-- Check if next win is doubled (Lucky Coin effect)
function Consumables.is_double_win_active()
    return active_effects.double_next_win
end

-- Clear double win (call after a winning spin)
function Consumables.clear_double_win()
    active_effects.double_next_win = false
end

-- Check if mulligan is pending
function Consumables.is_mulligan_pending()
    return active_effects.mulligan_pending
end

-- Clear mulligan
function Consumables.clear_mulligan()
    active_effects.mulligan_pending = false
end

-- Get all active effects for UI display
function Consumables.get_active_effects()
    local effects = {}
    if active_effects.wild_guaranteed then
        table.insert(effects, {id = "wild", name = "Wild Guaranteed"})
    end
    if active_effects.double_next_win then
        table.insert(effects, {id = "double", name = "2x Next Win"})
    end
    return effects
end

------------------------------------------------------------
-- SPIN TRACKING (for Rewind Token)
------------------------------------------------------------

function Consumables.store_pre_spin_state(credits)
    last_spin_credits = credits
end

function Consumables.get_last_spin_credits()
    return last_spin_credits
end

------------------------------------------------------------
-- RESET
------------------------------------------------------------

function Consumables.reset()
    inventory = {}
    active_effects = {
        wild_guaranteed = false,
        double_next_win = false,
        mulligan_pending = false,
    }
    last_spin_credits = nil
end

return Consumables
