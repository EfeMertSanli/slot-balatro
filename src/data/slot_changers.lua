------------------------------------------------------------
-- SLOT CHANGER DEFINITIONS
-- Permanent upgrades that modify the slot machine
------------------------------------------------------------

local Colors = require("src.colors")

local SlotChangers = {
    ------------------------------------------------------------
    -- PAYLINE UPGRADES - Horizontal
    ------------------------------------------------------------
    {
        id = "payline_top",
        name = "Top Line",
        icon = "---",
        color = Colors.cyan,
        cost = 150,
        category = "payline",
        effect = "Adds top row payline",
        effect_short = "+Top line",
        on_acquire = function(state, helpers)
            helpers.add_payline(state, -1)
        end
    },
    {
        id = "payline_bottom",
        name = "Bottom Line",
        icon = "___",
        color = Colors.gold,
        cost = 150,
        category = "payline",
        effect = "Adds bottom row payline",
        effect_short = "+Bottom line",
        on_acquire = function(state, helpers)
            helpers.add_payline(state, 1)
        end
    },
    {
        id = "payline_all_horizontal",
        name = "All Rows",
        icon = "===",
        color = Colors.win,
        cost = 250,
        category = "payline",
        effect = "Adds top AND bottom paylines",
        effect_short = "+2 lines",
        on_acquire = function(state, helpers)
            local has_top, has_bottom = false, false
            for _, pl in ipairs(state.paylines) do
                if pl == -1 then has_top = true end
                if pl == 1 then has_bottom = true end
            end
            if not has_top then helpers.add_payline(state, -1) end
            if not has_bottom then helpers.add_payline(state, 1) end
        end
    },

    ------------------------------------------------------------
    -- PAYLINE UPGRADES - Diagonal
    ------------------------------------------------------------
    {
        id = "payline_diag_down",
        name = "Diagonal \\",
        icon = "\\\\\\",
        color = Colors.orange,
        cost = 300,
        category = "payline",
        effect = "Diagonal: top-left to bottom-right",
        effect_short = "+Diag \\",
        on_acquire = function(state, helpers)
            helpers.add_diagonal_payline(state, "down")
        end
    },
    {
        id = "payline_diag_up",
        name = "Diagonal /",
        icon = "///",
        color = Colors.purple,
        cost = 300,
        category = "payline",
        effect = "Diagonal: bottom-left to top-right",
        effect_short = "+Diag /",
        on_acquire = function(state, helpers)
            helpers.add_diagonal_payline(state, "up")
        end
    },
    {
        id = "payline_both_diag",
        name = "X Pattern",
        icon = "X",
        color = Colors.yellow,
        cost = 500,
        category = "payline",
        effect = "Adds BOTH diagonal paylines",
        effect_short = "+X lines",
        on_acquire = function(state, helpers)
            local has_down, has_up = false, false
            for _, pl in ipairs(state.paylines) do
                if pl == "diag_down" then has_down = true end
                if pl == "diag_up" then has_up = true end
            end
            if not has_down then helpers.add_diagonal_payline(state, "down") end
            if not has_up then helpers.add_diagonal_payline(state, "up") end
        end
    },

    ------------------------------------------------------------
    -- REEL UPGRADES (columns)
    ------------------------------------------------------------
    {
        id = "fourth_reel",
        name = "Fourth Reel",
        icon = "+[4]",
        color = Colors.highlight,
        cost = 500,
        category = "reel",
        effect = "Adds a 4th reel column",
        effect_short = "+1 reel",
        on_acquire = function(state, helpers)
            helpers.add_reel(state)
        end
    },
    {
        id = "fifth_reel",
        name = "Fifth Reel",
        icon = "+[5]",
        color = Colors.red,
        cost = 800,
        category = "reel",
        requires = "fourth_reel",
        effect = "Adds a 5th reel column",
        effect_short = "+1 reel",
        on_acquire = function(state, helpers)
            helpers.add_reel(state)
        end
    },

    ------------------------------------------------------------
    -- ROW UPGRADES (expands visible symbols)
    ------------------------------------------------------------
    {
        id = "fourth_row",
        name = "Fourth Row",
        icon = "+R4",
        color = Colors.cyan,
        cost = 350,
        category = "row",
        effect = "Adds 4th symbol row (above top)",
        effect_short = "+1 row",
        on_acquire = function(state, helpers)
            helpers.add_row(state)
        end
    },
    {
        id = "fifth_row",
        name = "Fifth Row",
        icon = "+R5",
        color = Colors.orange,
        cost = 500,
        category = "row",
        requires = "fourth_row",
        effect = "Adds 5th symbol row (below bottom)",
        effect_short = "+1 row",
        on_acquire = function(state, helpers)
            helpers.add_row(state)
        end
    },

    ------------------------------------------------------------
    -- PAYLINES FOR EXPANDED ROWS
    ------------------------------------------------------------
    {
        id = "payline_far_top",
        name = "Far Top Line",
        icon = "^^^",
        color = Colors.blue,
        cost = 200,
        category = "payline",
        requires = "fourth_row",
        effect = "Adds far top row payline (requires 4+ rows)",
        effect_short = "+Top2 line",
        on_acquire = function(state, helpers)
            helpers.add_payline(state, -2)
        end
    },
    {
        id = "payline_far_bottom",
        name = "Far Bottom Line",
        icon = "vvv",
        color = Colors.red,
        cost = 200,
        category = "payline",
        requires = "fifth_row",
        effect = "Adds far bottom row payline (requires 5 rows)",
        effect_short = "+Bot2 line",
        on_acquire = function(state, helpers)
            helpers.add_payline(state, 2)
        end
    },

    ------------------------------------------------------------
    -- SPECIAL UPGRADES
    ------------------------------------------------------------
    {
        id = "wild_magnet",
        name = "Wild Magnet",
        icon = "W+W",
        color = Colors.purple,
        cost = 400,
        category = "special",
        effect = "Doubles wild symbol frequency",
        effect_short = "2x wilds",
        on_acquire = function(state, helpers)
            state.wild_magnet = true
        end
    },
    {
        id = "max_lines",
        name = "Full Board",
        icon = "#=#",
        color = Colors.cyan,
        cost = 750,
        category = "payline",
        effect = "Adds ALL remaining paylines for current rows",
        effect_short = "+All lines",
        on_acquire = function(state, helpers)
            local has = {}
            for _, pl in ipairs(state.paylines) do has[pl] = true end
            if not has[-1] then helpers.add_payline(state, -1) end
            if not has[1] then helpers.add_payline(state, 1) end
            if not has["diag_down"] then helpers.add_diagonal_payline(state, "down") end
            if not has["diag_up"] then helpers.add_diagonal_payline(state, "up") end
            if state.num_rows >= 4 and not has[-2] then helpers.add_payline(state, -2) end
            if state.num_rows >= 5 and not has[2] then helpers.add_payline(state, 2) end
        end
    },
}

------------------------------------------------------------
-- HELPER FUNCTIONS
------------------------------------------------------------

-- Get slot changer by ID
function SlotChangers.get(id)
    for _, sc in ipairs(SlotChangers) do
        if sc.id == id then
            return sc
        end
    end
    return nil
end

-- Check if player owns a slot changer
function SlotChangers.is_owned(state, id)
    for _, sc in ipairs(state.slot_changers) do
        if sc.id == id then
            return true
        end
    end
    return false
end

-- Get available slot changers (not owned, prerequisites met)
function SlotChangers.get_available(state)
    local result = {}
    for _, sc in ipairs(SlotChangers) do
        local owned = SlotChangers.is_owned(state, sc.id)
        local prereq_met = true
        if sc.requires then
            prereq_met = SlotChangers.is_owned(state, sc.requires)
        end
        if not owned and prereq_met then
            table.insert(result, sc)
        end
    end
    return result
end

-- Get by category
function SlotChangers.get_by_category(category)
    local result = {}
    for _, sc in ipairs(SlotChangers) do
        if sc.category == category then
            table.insert(result, sc)
        end
    end
    return result
end

return SlotChangers
