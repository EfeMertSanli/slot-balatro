------------------------------------------------------------
-- RULES SCREEN
-- Two-tab popup showing basic rules and current game state
------------------------------------------------------------

local Colors = require("src.colors")
local Config = require("src.config")
local UI = require("src.ui")
local Game = require("src.game")
local Symbols = require("src.data.symbols")

local RulesScreen = {}

-- State
local current_tab = 1  -- 1 = Basic Rules, 2 = Current Game
local is_visible = false

function RulesScreen.show()
    is_visible = true
    current_tab = 1
end

function RulesScreen.hide()
    is_visible = false
end

function RulesScreen.toggle()
    is_visible = not is_visible
    if is_visible then
        current_tab = 1
    end
end

function RulesScreen.is_visible()
    return is_visible
end

function RulesScreen.draw()
    if not is_visible then return end

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, Config.SCREEN_W, Config.SCREEN_H)

    local panel_w = 1200
    local panel_h = 800
    local panel_x = Config.SCREEN_W / 2 - panel_w / 2
    local panel_y = Config.SCREEN_H / 2 - panel_h / 2

    -- Main panel
    UI.draw_double_box(panel_x, panel_y, panel_w, panel_h, Colors.bg_panel, Colors.cyan, true)

    -- Title
    love.graphics.setColor(Colors.cyan)
    love.graphics.rectangle("fill", panel_x + 4, panel_y + 4, panel_w - 8, 40)
    love.graphics.setColor(Colors.black)
    love.graphics.setFont(UI.get_font(24, true))
    love.graphics.printf("GAME RULES & INFO", panel_x + 4, panel_y + 12, panel_w - 8, "center")

    -- Tab buttons
    local tab_y = panel_y + 55
    local tab_w = 300
    local tab_h = 40

    -- Tab 1: Basic Rules
    local tab1_x = panel_x + panel_w / 2 - tab_w - 20
    local tab1_active = current_tab == 1
    UI.draw_rigid_box(tab1_x, tab_y, tab_w, tab_h,
        tab1_active and Colors.cyan_dim or Colors.bg2,
        tab1_active and Colors.cyan or Colors.dim, 2)
    love.graphics.setColor(tab1_active and Colors.white or Colors.dim)
    love.graphics.setFont(UI.get_font(18, true))
    love.graphics.printf("BASIC RULES", tab1_x, tab_y + 10, tab_w, "center")

    -- Tab 2: Current Game
    local tab2_x = panel_x + panel_w / 2 + 20
    local tab2_active = current_tab == 2
    UI.draw_rigid_box(tab2_x, tab_y, tab_w, tab_h,
        tab2_active and Colors.cyan_dim or Colors.bg2,
        tab2_active and Colors.cyan or Colors.dim, 2)
    love.graphics.setColor(tab2_active and Colors.white or Colors.dim)
    love.graphics.setFont(UI.get_font(18, true))
    love.graphics.printf("CURRENT GAME", tab2_x, tab_y + 10, tab_w, "center")

    -- Content area
    local content_x = panel_x + 30
    local content_y = tab_y + tab_h + 20
    local content_w = panel_w - 60
    local content_h = panel_h - (content_y - panel_y) - 60

    if current_tab == 1 then
        RulesScreen.draw_basic_rules(content_x, content_y, content_w, content_h)
    else
        RulesScreen.draw_current_game(content_x, content_y, content_w, content_h)
    end

    -- Close button hint
    love.graphics.setColor(Colors.cyan_dim)
    love.graphics.setFont(UI.get_font(14))
    love.graphics.printf("[ESC] Close  |  [1] Basic Rules  |  [2] Current Game", panel_x, panel_y + panel_h - 35, panel_w, "center")
end

function RulesScreen.draw_basic_rules(x, y, w, h)
    local line_h = 28
    local section_gap = 15
    local cy = y

    -- HOW TO PLAY
    love.graphics.setColor(Colors.gold)
    love.graphics.setFont(UI.get_font(22, true))
    love.graphics.print("HOW TO PLAY", x, cy)
    cy = cy + line_h + 5

    love.graphics.setColor(Colors.white)
    love.graphics.setFont(UI.get_font(16))
    local rules = {
        "Spin the reels and match symbols on paylines to win credits.",
        "Match 2 symbols (PAIR) for a small payout, or 3+ (TRIPLE) for big wins!",
        "WILD skulls match any symbol and can complete winning combinations.",
        "Reach the TARGET credits before running out of spins to advance.",
    }
    for _, rule in ipairs(rules) do
        love.graphics.print("  " .. rule, x, cy)
        cy = cy + line_h
    end
    cy = cy + section_gap

    -- ANTE SYSTEM
    love.graphics.setColor(Colors.gold)
    love.graphics.setFont(UI.get_font(22, true))
    love.graphics.print("ANTE SYSTEM", x, cy)
    cy = cy + line_h + 5

    love.graphics.setColor(Colors.white)
    love.graphics.setFont(UI.get_font(16))
    local ante_rules = {
        "The game is divided into ANTES, each containing " .. Config.ROUNDS_PER_ANTE .. " rounds.",
        "Each round gives you " .. Config.SPINS_PER_ROUND .. " spins to reach the target.",
        "Targets increase each round, and grow MUCH faster with each new ante!",
        "Complete an ante to choose a PERMANENT BUFF that helps future runs.",
        "If you fail to meet a target, it's GAME OVER - but your buffs remain!",
    }
    for _, rule in ipairs(ante_rules) do
        love.graphics.print("  " .. rule, x, cy)
        cy = cy + line_h
    end
    cy = cy + section_gap

    -- SYMBOLS
    love.graphics.setColor(Colors.gold)
    love.graphics.setFont(UI.get_font(22, true))
    love.graphics.print("SYMBOL VALUES (Triple Match)", x, cy)
    cy = cy + line_h + 5

    local sym_x = x
    local sym_col_w = 180
    for i, sym in ipairs(Symbols) do
        love.graphics.setColor(sym.color)
        love.graphics.setFont(UI.get_font(16, true))
        love.graphics.print(sym.icon, sym_x, cy)
        love.graphics.setColor(Colors.dim)
        love.graphics.setFont(UI.get_font(14))
        love.graphics.print(" = " .. sym.value .. "x bet", sym_x + 50, cy + 2)

        sym_x = sym_x + sym_col_w
        if i % 4 == 0 then
            sym_x = x
            cy = cy + line_h
        end
    end
    cy = cy + line_h + section_gap

    -- SHOP
    love.graphics.setColor(Colors.gold)
    love.graphics.setFont(UI.get_font(22, true))
    love.graphics.print("SHOP", x, cy)
    cy = cy + line_h + 5

    love.graphics.setColor(Colors.white)
    love.graphics.setFont(UI.get_font(16))
    local shop_rules = {
        "After each round, visit the SHOP to buy upgrades.",
        "JOKERS provide passive bonuses that affect your wins.",
        "SLOT CHANGERS add paylines, reels, or rows to your machine.",
        "You can buy 1 joker and 1 upgrade per shop visit.",
    }
    for _, rule in ipairs(shop_rules) do
        love.graphics.print("  " .. rule, x, cy)
        cy = cy + line_h
    end
end

function RulesScreen.draw_current_game(x, y, w, h)
    local col_w = w / 3 - 10
    local line_h = 24
    local small_line_h = 20

    -- COLUMN 1: Stats
    local c1x = x
    local cy = y

    love.graphics.setColor(Colors.gold)
    love.graphics.setFont(UI.get_font(18, true))
    love.graphics.print("STATUS", c1x, cy)
    cy = cy + line_h + 5

    love.graphics.setFont(UI.get_font(14))
    local stats = {
        {"Ante", Game.ante},
        {"Round", Game.round_in_ante .. "/" .. Config.ROUNDS_PER_ANTE},
        {"Credits", Game.credits},
        {"Target", Game.round_target},
        {"Spins/Round", Game.spins_per_round},
        {"Reels", Game.num_reels},
        {"Rows", Game.num_rows},
        {"Paylines", #Game.paylines},
    }

    for _, stat in ipairs(stats) do
        love.graphics.setColor(Colors.dim)
        love.graphics.print(stat[1] .. ":", c1x + 5, cy)
        love.graphics.setColor(Colors.cyan)
        love.graphics.printf(tostring(stat[2]), c1x + 5, cy, col_w - 15, "right")
        cy = cy + small_line_h
    end
    cy = cy + 10

    -- Paylines detail
    love.graphics.setColor(Colors.gold)
    love.graphics.setFont(UI.get_font(16, true))
    love.graphics.print("PAYLINES", c1x, cy)
    cy = cy + line_h

    love.graphics.setColor(Colors.white)
    love.graphics.setFont(UI.get_font(12))
    local max_paylines_shown = 7
    for i, payline in ipairs(Game.paylines) do
        if i > max_paylines_shown then
            love.graphics.setColor(Colors.dim)
            love.graphics.print("  +" .. (#Game.paylines - max_paylines_shown) .. " more...", c1x + 5, cy)
            break
        end
        local name = "Unknown"
        if type(payline) == "number" then
            if payline == 0 then name = "Center"
            elseif payline == -1 then name = "Top"
            elseif payline == 1 then name = "Bottom"
            elseif payline == -2 then name = "Far Top"
            elseif payline == 2 then name = "Far Bottom"
            end
        elseif payline == "diag_down" then
            name = "Diag \\"
        elseif payline == "diag_up" then
            name = "Diag /"
        end
        love.graphics.print("  " .. name, c1x + 5, cy)
        cy = cy + 18
    end

    -- COLUMN 2: Jokers
    local c2x = x + col_w + 20
    cy = y

    love.graphics.setColor(Colors.gold)
    love.graphics.setFont(UI.get_font(18, true))
    love.graphics.print("JOKERS (" .. #Game.jokers .. "/" .. (Game.max_jokers or 5) .. ")", c2x, cy)
    cy = cy + line_h + 5

    if #Game.jokers == 0 then
        love.graphics.setColor(Colors.dim)
        love.graphics.setFont(UI.get_font(12))
        love.graphics.print("  No jokers equipped", c2x, cy)
        cy = cy + small_line_h
    else
        local max_jokers_shown = 6
        for i, joker in ipairs(Game.jokers) do
            if i > max_jokers_shown then
                love.graphics.setColor(Colors.dim)
                love.graphics.setFont(UI.get_font(12))
                love.graphics.print("  +" .. (#Game.jokers - max_jokers_shown) .. " more...", c2x + 5, cy)
                cy = cy + small_line_h
                break
            end
            love.graphics.setColor(joker.color)
            love.graphics.setFont(UI.get_font(14, true))
            love.graphics.print(joker.icon .. " " .. joker.name, c2x + 5, cy)
            love.graphics.setColor(Colors.dim)
            love.graphics.setFont(UI.get_font(11))
            local effect_text = joker.effect_short or joker.effect or ""
            if #effect_text > 35 then
                effect_text = effect_text:sub(1, 32) .. "..."
            end
            love.graphics.print("  " .. effect_text, c2x + 5, cy + 16)
            cy = cy + 36
        end
    end
    cy = cy + 10

    -- Slot Changers (in column 2)
    love.graphics.setColor(Colors.cyan)
    love.graphics.setFont(UI.get_font(16, true))
    love.graphics.print("UPGRADES", c2x, cy)
    cy = cy + line_h

    if #Game.slot_changers == 0 then
        love.graphics.setColor(Colors.dim)
        love.graphics.setFont(UI.get_font(12))
        love.graphics.print("  None purchased", c2x, cy)
    else
        love.graphics.setColor(Colors.white)
        love.graphics.setFont(UI.get_font(12))
        local max_changers_shown = 5
        for i, changer in ipairs(Game.slot_changers) do
            if i > max_changers_shown then
                love.graphics.setColor(Colors.dim)
                love.graphics.print("  +" .. (#Game.slot_changers - max_changers_shown) .. " more...", c2x + 5, cy)
                break
            end
            love.graphics.print("  " .. changer.icon .. " " .. changer.name, c2x + 5, cy)
            cy = cy + 18
        end
    end

    -- COLUMN 3: Buffs & Consumables
    local c3x = x + col_w * 2 + 40
    cy = y

    love.graphics.setColor(Colors.purple)
    love.graphics.setFont(UI.get_font(18, true))
    love.graphics.print("PERMANENT BUFFS", c3x, cy)
    cy = cy + line_h + 5

    local buffs = {}
    if (Game.perm_starting_credits or 0) > 0 then
        table.insert(buffs, "+" .. Game.perm_starting_credits .. " Start $")
    end
    if (Game.perm_win_bonus or 0) > 0 then
        table.insert(buffs, "+" .. math.floor(Game.perm_win_bonus * 100) .. "% Wins")
    end
    if (Game.perm_target_reduction or 0) > 0 then
        table.insert(buffs, "-" .. math.floor(Game.perm_target_reduction * 100) .. "% Target")
    end
    if (Game.perm_extra_spins or 0) > 0 then
        table.insert(buffs, "+" .. Game.perm_extra_spins .. " Spins")
    end
    if Game.perm_free_reroll then
        table.insert(buffs, "Free Reroll")
    end
    if (Game.perm_symbol_bonus or 0) > 0 then
        table.insert(buffs, "+" .. Game.perm_symbol_bonus .. " Symbol Val")
    end
    if (Game.perm_payline_bonus or 0) > 0 then
        table.insert(buffs, "+" .. Game.perm_payline_bonus .. "/Payline")
    end
    if (Game.perm_shop_discount or 0) > 0 then
        table.insert(buffs, "-" .. math.floor(Game.perm_shop_discount * 100) .. "% Shop")
    end

    if #buffs == 0 then
        love.graphics.setColor(Colors.dim)
        love.graphics.setFont(UI.get_font(12))
        love.graphics.print("  No buffs yet", c3x, cy)
        love.graphics.print("  (Complete ante)", c3x, cy + 16)
        cy = cy + 36
    else
        love.graphics.setColor(Colors.white)
        love.graphics.setFont(UI.get_font(12))
        for _, buff in ipairs(buffs) do
            love.graphics.print("  " .. buff, c3x + 5, cy)
            cy = cy + 18
        end
    end
    cy = cy + 15

    -- Consumables (if system exists)
    local consumables = Game.get_consumables and Game.get_consumables() or {}
    love.graphics.setColor(Colors.magenta)
    love.graphics.setFont(UI.get_font(16, true))
    love.graphics.print("CONSUMABLES (" .. #consumables .. "/5)", c3x, cy)
    cy = cy + line_h

    if #consumables == 0 then
        love.graphics.setColor(Colors.dim)
        love.graphics.setFont(UI.get_font(12))
        love.graphics.print("  None owned", c3x, cy)
        cy = cy + small_line_h
    else
        love.graphics.setFont(UI.get_font(12))
        for _, item in ipairs(consumables) do
            love.graphics.setColor(item.color or Colors.white)
            love.graphics.print("  " .. (item.icon or "?") .. " " .. item.name, c3x + 5, cy)
            cy = cy + 18
        end
    end
    cy = cy + 15

    -- Luna Affinity (if system exists)
    local affinity_info = Game.get_luna_affinity_info and Game.get_luna_affinity_info()
    if affinity_info then
        love.graphics.setColor(Colors.magenta)
        love.graphics.setFont(UI.get_font(16, true))
        love.graphics.print("LUNA AFFINITY", c3x, cy)
        cy = cy + line_h

        love.graphics.setColor(Colors.white)
        love.graphics.setFont(UI.get_font(12))
        love.graphics.print("  Lv." .. affinity_info.level .. " " .. affinity_info.name, c3x + 5, cy)
        cy = cy + 18
        love.graphics.setColor(Colors.dim)
        local bonus_text = affinity_info.bonus or ""
        if #bonus_text > 25 then
            bonus_text = bonus_text:sub(1, 22) .. "..."
        end
        love.graphics.print("  " .. bonus_text, c3x + 5, cy)
    end
end

function RulesScreen.keypressed(key)
    if not is_visible then return false end

    if key == "escape" or key == "p" then
        RulesScreen.hide()
        return true
    elseif key == "1" then
        current_tab = 1
        return true
    elseif key == "2" then
        current_tab = 2
        return true
    elseif key == "tab" then
        current_tab = current_tab == 1 and 2 or 1
        return true
    end
    return false
end

function RulesScreen.mousepressed(x, y, button)
    if not is_visible then return false end

    if button == 1 then
        local panel_w = 1200
        local panel_h = 800
        local panel_x = Config.SCREEN_W / 2 - panel_w / 2
        local panel_y = Config.SCREEN_H / 2 - panel_h / 2

        -- Check tab clicks
        local tab_y = panel_y + 55
        local tab_w = 300
        local tab_h = 40

        local tab1_x = panel_x + panel_w / 2 - tab_w - 20
        local tab2_x = panel_x + panel_w / 2 + 20

        if y >= tab_y and y <= tab_y + tab_h then
            if x >= tab1_x and x <= tab1_x + tab_w then
                current_tab = 1
                return true
            elseif x >= tab2_x and x <= tab2_x + tab_w then
                current_tab = 2
                return true
            end
        end

        -- Click outside panel to close
        if x < panel_x or x > panel_x + panel_w or y < panel_y or y > panel_y + panel_h then
            RulesScreen.hide()
            return true
        end
    end
    return false
end

return RulesScreen
