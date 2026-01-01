------------------------------------------------------------
-- SYMBOL DEFINITIONS
-- Static data for all slot machine symbols
------------------------------------------------------------

local Colors = require("src.colors")

local Symbols = {
    {
        id = "cherry",
        icon = "CHRRY",
        name = "CHERRY",
        value = 3,
        color = Colors.red,
        image = "src/assests/symbol_cherry.png",
        weight = 20,  -- Common
    },
    {
        id = "lemon",
        icon = "LEMN",
        name = "LEMON",
        value = 4,
        color = Colors.gold,
        image = "src/assests/symbol_lemon.png",
        weight = 18,
    },
    {
        id = "bell",
        icon = "BELL",
        name = "BELL",
        value = 5,
        color = Colors.gold,
        image = "src/assests/symbol_bell.png",
        weight = 15,
    },
    {
        id = "star",
        icon = "STAR",
        name = "STAR",
        value = 7,
        color = Colors.cyan,
        image = "src/assests/symbol_star.png",
        weight = 12,
    },
    {
        id = "clover",
        icon = "CLOVR",
        name = "CLOVER",
        value = 10,
        color = Colors.win,
        image = "src/assests/symbol_clover.png",
        weight = 10,
    },
    {
        id = "diamond",
        icon = "DIAM",
        name = "DIAMOND",
        value = 15,
        color = Colors.blue,
        image = "src/assests/symbol_diamond.png",
        weight = 8,
    },
    {
        id = "seven",
        icon = "7777",
        name = "SEVEN",
        value = 25,
        color = Colors.gold,
        image = "src/assests/symbol_seven.png",
        weight = 5,  -- Rare
    },
    {
        id = "skull",
        icon = "SKULL",
        name = "WILD",
        value = 0,
        color = Colors.purple,
        image = "src/assests/symbol_skull.png",
        weight = 4,  -- Wild base weight
        wild = true,
    },
}

------------------------------------------------------------
-- HELPER FUNCTIONS
------------------------------------------------------------

-- Get symbol by ID
function Symbols.get(id)
    for _, sym in ipairs(Symbols) do
        if sym.id == id then
            return sym
        end
    end
    return nil
end

-- Get all non-wild symbols
function Symbols.get_regular()
    local result = {}
    for _, sym in ipairs(Symbols) do
        if not sym.wild then
            table.insert(result, sym)
        end
    end
    return result
end

-- Get wild symbol
function Symbols.get_wild()
    for _, sym in ipairs(Symbols) do
        if sym.wild then
            return sym
        end
    end
    return nil
end

return Symbols
