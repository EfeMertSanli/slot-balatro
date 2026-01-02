------------------------------------------------------------
-- EVENT DEFINITIONS
-- Random encounters that can occur at round start
------------------------------------------------------------

local Colors = require("src.colors")

local Events = {}

-- Event trigger chance (5% per round)
Events.TRIGGER_CHANCE = 0.05

-- All event definitions
local event_list = {
    {
        id = "lucky_hour",
        name = "Lucky Hour",
        icon = "!!!",
        color = Colors.gold,
        desc = "All payouts doubled this round!",
        effect_desc = "Lady luck smiles upon you...",
        rarity = "common",
        -- Modifiers applied during event
        payout_multiplier = 2.0,
        -- Duration: entire round
        duration = "round",
    },
    {
        id = "cursed_reel",
        name = "Cursed Reel",
        icon = "X_X",
        color = Colors.purple,
        desc = "One reel only shows low symbols",
        effect_desc = "Something feels wrong with reel 2...",
        rarity = "common",
        -- Which reel is cursed (will be randomized)
        cursed_reel = 2,
        -- Low symbols only
        low_symbols_only = true,
        duration = "round",
    },
    {
        id = "ghost_spin",
        name = "Ghost Spin",
        icon = "~~~",
        color = Colors.cyan,
        desc = "A free phantom spin!",
        effect_desc = "The reels spin on their own...",
        rarity = "uncommon",
        -- Grants one free spin
        free_spins = 1,
        duration = "instant",
    },
    {
        id = "the_collector",
        name = "The Collector",
        icon = "$$$",
        color = Colors.gold,
        desc = "Trade a joker for double its value",
        effect_desc = "A mysterious figure offers a deal...",
        rarity = "rare",
        -- Joker trade multiplier
        trade_multiplier = 2.0,
        duration = "round",
        -- Requires at least one joker
        requires_joker = true,
    },
    {
        id = "lunas_gift",
        name = "Luna's Gift",
        icon = "<3>",
        color = Colors.magenta,
        desc = "Luna gives you a free consumable!",
        effect_desc = "Luna winks and slides something across...",
        rarity = "uncommon",
        -- Grants a random consumable
        free_consumable = true,
        duration = "instant",
    },
    {
        id = "high_roller",
        name = "High Roller",
        icon = "MAX",
        color = Colors.red,
        desc = "Min bet x5, but payouts x3!",
        effect_desc = "The stakes have never been higher...",
        rarity = "rare",
        -- Minimum bet multiplier
        min_bet_multiplier = 5,
        -- Payout multiplier
        payout_multiplier = 3.0,
        duration = "round",
    },
    {
        id = "lucky_seven",
        name = "Lucky Seven",
        icon = "777",
        color = Colors.gold,
        desc = "7s appear more frequently!",
        effect_desc = "Seven is your lucky number today...",
        rarity = "uncommon",
        -- Increases 7 symbol weight
        boosted_symbol = "seven",
        symbol_weight_bonus = 3,
        duration = "round",
    },
    {
        id = "wild_surge",
        name = "Wild Surge",
        icon = "[W]",
        color = Colors.cyan,
        desc = "Wilds appear more often!",
        effect_desc = "The wilds are restless...",
        rarity = "uncommon",
        -- Increases wild weight
        boosted_symbol = "wild",
        symbol_weight_bonus = 2,
        duration = "round",
    },
}

------------------------------------------------------------
-- HELPER FUNCTIONS
------------------------------------------------------------

function Events.get_all()
    local result = {}
    for _, event in ipairs(event_list) do
        local copy = {}
        for k, v in pairs(event) do
            copy[k] = v
        end
        table.insert(result, copy)
    end
    return result
end

function Events.get_by_id(id)
    for _, event in ipairs(event_list) do
        if event.id == id then
            return event
        end
    end
    return nil
end

function Events.get_random()
    -- Filter events that can trigger
    local available = {}
    for _, event in ipairs(event_list) do
        table.insert(available, event)
    end

    if #available == 0 then
        return nil
    end

    -- Weight by rarity
    local weighted = {}
    for _, event in ipairs(available) do
        local copies = 1
        if event.rarity == "common" then
            copies = 3
        elseif event.rarity == "uncommon" then
            copies = 2
        elseif event.rarity == "rare" then
            copies = 1
        end
        for _ = 1, copies do
            table.insert(weighted, event)
        end
    end

    local selected = weighted[math.random(#weighted)]

    -- Return a copy
    local copy = {}
    for k, v in pairs(selected) do
        copy[k] = v
    end
    return copy
end

function Events.get_by_rarity(rarity)
    local result = {}
    for _, event in ipairs(event_list) do
        if event.rarity == rarity then
            local copy = {}
            for k, v in pairs(event) do
                copy[k] = v
            end
            table.insert(result, copy)
        end
    end
    return result
end

function Events.get_trigger_chance()
    return Events.TRIGGER_CHANCE
end

return Events
