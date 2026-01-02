------------------------------------------------------------
-- CONFIG MODULE
-- Game constants and layout configuration
-- Data definitions are in src/data/
------------------------------------------------------------

local Config = {}

------------------------------------------------------------
-- SCREEN SETTINGS
------------------------------------------------------------
Config.SCREEN_W = 1920
Config.SCREEN_H = 1080

------------------------------------------------------------
-- LAYOUT REGIONS
------------------------------------------------------------
Config.LAYOUT = {
    padding = 10,

    title_bar = {
        x = 0, y = 0,
        w = Config.SCREEN_W, h = 70,
    },

    -- Left panel (Luna) - extends to bottom of screen
    portrait = {
        x = 10, y = 80,
        w = 380, h = 990,
    },

    -- Center reels area - snaps to action bar
    reels = {
        x = 400, y = 80,
        w = 900, h = 780,
    },

    -- Right panel (Game Status) - extends to bottom of screen
    stats_panel = {
        x = 1310, y = 80,
        w = 600, h = 990,
    },

    -- Action bar - between side panels
    action_bar = {
        x = 400, y = 870,
        w = 900, h = 200,
        -- Full area for reference (side panels cover the corners)
        full_x = 10, full_y = 870,
        full_w = Config.SCREEN_W - 20,
    },
}

------------------------------------------------------------
-- ANTE & ROUND SETTINGS (Roguelike progression)
------------------------------------------------------------
Config.ROUNDS_PER_ANTE = 10
Config.SPINS_PER_ROUND = 10
Config.BASE_TARGET = 100
Config.TARGET_ROUND_SCALING = 1.15
Config.TARGET_ANTE_SCALING = 2.0

------------------------------------------------------------
-- REEL SETTINGS
------------------------------------------------------------
Config.NUM_REELS = 3
Config.REEL_WIDTH = 220
Config.REEL_HEIGHT = 420
Config.REEL_SPACING = 40
Config.SYMBOL_HEIGHT = 110
Config.SPIN_SPEED = 2000
Config.SPIN_DECEL = 0.91

------------------------------------------------------------
-- BUTTON SETTINGS
------------------------------------------------------------
Config.BTN_HEIGHT = 75
Config.BTN_SPACING = 20

------------------------------------------------------------
-- GAME SETTINGS
------------------------------------------------------------
Config.STARTING_CREDITS = 100
Config.STARTING_BET = 1
Config.MAX_BET = 10
Config.MAX_JOKERS = 5
Config.REROLL_COST = 25

------------------------------------------------------------
-- DATA REFERENCES (loaded on demand)
-- These provide backward compatibility for existing code
------------------------------------------------------------
local _symbols, _jokers, _buffs, _slot_changers

function Config.get_symbols()
    if not _symbols then
        _symbols = require("src.data.symbols")
    end
    return _symbols
end

function Config.get_jokers()
    if not _jokers then
        _jokers = require("src.data.joker_defs")
    end
    return _jokers
end

function Config.get_buffs()
    if not _buffs then
        _buffs = require("src.data.buff_defs")
    end
    return _buffs
end

function Config.get_slot_changers()
    if not _slot_changers then
        _slot_changers = require("src.data.slot_changers")
    end
    return _slot_changers
end

-- Legacy properties (for backward compatibility)
-- These are populated when first accessed
setmetatable(Config, {
    __index = function(t, k)
        if k == "SYMBOLS" then
            return Config.get_symbols()
        elseif k == "JOKERS" then
            return Config.get_jokers()
        elseif k == "ANTE_BUFFS" then
            return Config.get_buffs()
        elseif k == "SLOT_CHANGERS" then
            return Config.get_slot_changers()
        end
        return nil
    end
})

return Config
