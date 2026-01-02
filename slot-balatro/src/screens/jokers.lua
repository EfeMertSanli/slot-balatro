------------------------------------------------------------
-- JOKERS SCREEN
-- Joker management overlay - view and delete jokers
------------------------------------------------------------

local Colors = require("src.colors")
local Config = require("src.config")
local UI = require("src.ui")
local Game = require("src.game")

local JokersScreen = {}

-- Selected joker for details
local selected_joker = 0
local confirm_delete = false

function JokersScreen.reset()
    selected_joker = 0
    confirm_delete = false
end

function JokersScreen.draw()
    -- Darken background
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, Config.SCREEN_W, Config.SCREEN_H)

    -- Main panel
    local panel_w = 900
    local panel_h = 700
    local panel_x = (Config.SCREEN_W - panel_w) / 2
    local panel_y = (Config.SCREEN_H - panel_h) / 2

    UI.draw_double_box(panel_x, panel_y, panel_w, panel_h, Colors.bg_panel, Colors.highlight, true)

    -- Title
    love.graphics.setColor(Colors.highlight)
    love.graphics.rectangle("fill", panel_x + 4, panel_y + 4, panel_w - 8, 40)
    love.graphics.setColor(Colors.black)
    love.graphics.setFont(UI.get_font(24, true))
    love.graphics.printf("JOKER COLLECTION", panel_x, panel_y + 12, panel_w, "center")

    -- Subtitle
    love.graphics.setColor(Colors.dim)
    love.graphics.setFont(UI.get_font(14))
    love.graphics.printf("Click a joker to select, then DELETE to sell (25% refund)", panel_x, panel_y + 50, panel_w, "center")

    -- Joker grid
    local grid_x = panel_x + 30
    local grid_y = panel_y + 80
    local card_w = 160
    local card_h = 180
    local cards_per_row = 5
    local spacing = 10

    if #Game.jokers == 0 then
        love.graphics.setColor(Colors.dim)
        love.graphics.setFont(UI.get_font(24))
        love.graphics.printf("No jokers yet!", panel_x, panel_y + 180, panel_w, "center")
        love.graphics.setFont(UI.get_font(16))
        love.graphics.printf("Complete a round to visit the shop\nand buy some jokers!", panel_x, panel_y + 220, panel_w, "center")
    else
        for i, joker in ipairs(Game.jokers) do
            local col = (i - 1) % cards_per_row
            local row = math.floor((i - 1) / cards_per_row)
            local card_x = grid_x + col * (card_w + spacing)
            local card_y = grid_y + row * (card_h + spacing)

            local is_selected = (i == selected_joker)
            local border_color = is_selected and Colors.yellow or joker.color

            -- Card glow for selected
            if is_selected then
                for g = 3, 1, -1 do
                    love.graphics.setColor(Colors.yellow[1], Colors.yellow[2], Colors.yellow[3], 0.15)
                    love.graphics.rectangle("fill", card_x - g*3, card_y - g*3, card_w + g*6, card_h + g*6, 4, 4)
                end
            end

            UI.draw_double_box(card_x, card_y, card_w, card_h, Colors.bg2, border_color, false)

            -- Icon
            love.graphics.setColor(joker.color)
            love.graphics.setFont(UI.get_font(36, true))
            love.graphics.printf(joker.icon, card_x, card_y + 20, card_w, "center")

            -- Name
            love.graphics.setColor(Colors.white)
            love.graphics.setFont(UI.get_font(14, true))
            love.graphics.printf(joker.name, card_x + 5, card_y + 70, card_w - 10, "center")

            -- Effect
            love.graphics.setColor(Colors.dim)
            love.graphics.setFont(UI.get_font(11))
            love.graphics.printf(joker.effect or "", card_x + 5, card_y + 95, card_w - 10, "center")

            -- Sell value
            local refund = math.floor((joker.cost or 50) * 0.25)
            love.graphics.setColor(Colors.gold)
            love.graphics.setFont(UI.get_font(12, true))
            love.graphics.printf("Sell: " .. refund, card_x, card_y + card_h - 25, card_w, "center")

            -- Selection number
            love.graphics.setColor(Colors.cyan_dim)
            love.graphics.setFont(UI.get_font(12))
            love.graphics.print("[" .. i .. "]", card_x + 5, card_y + 5)
        end
    end

    -- Slot changers section
    local changers_y = panel_y + 460
    love.graphics.setColor(Colors.cyan)
    love.graphics.setFont(UI.get_font(18, true))
    love.graphics.printf("SLOT UPGRADES", panel_x, changers_y, panel_w, "center")

    changers_y = changers_y + 30
    if #Game.slot_changers == 0 then
        love.graphics.setColor(Colors.dim)
        love.graphics.setFont(UI.get_font(14))
        love.graphics.printf("No slot upgrades yet!", panel_x, changers_y, panel_w, "center")
    else
        local sc_card_w = 180
        local sc_total_w = #Game.slot_changers * (sc_card_w + 10) - 10
        local sc_start_x = panel_x + (panel_w - sc_total_w) / 2

        for i, sc in ipairs(Game.slot_changers) do
            local sc_x = sc_start_x + (i - 1) * (sc_card_w + 10)
            UI.draw_double_box(sc_x, changers_y, sc_card_w, 70, Colors.bg2, sc.color, false)

            love.graphics.setColor(sc.color)
            love.graphics.setFont(UI.get_font(16, true))
            love.graphics.printf(sc.icon, sc_x, changers_y + 8, sc_card_w, "center")

            love.graphics.setColor(Colors.white)
            love.graphics.setFont(UI.get_font(12, true))
            love.graphics.printf(sc.name, sc_x, changers_y + 30, sc_card_w, "center")

            love.graphics.setColor(Colors.dim)
            love.graphics.setFont(UI.get_font(10))
            love.graphics.printf(sc.effect_short, sc_x, changers_y + 48, sc_card_w, "center")
        end
    end

    -- Stats
    local stats_y = changers_y + 90
    love.graphics.setColor(Colors.cyan_dim)
    love.graphics.setFont(UI.get_font(14))
    love.graphics.printf("Reels: " .. Game.num_reels .. "  |  Paylines: " .. Game.num_paylines .. "  |  Total Spins: " .. Game.total_spins, panel_x, stats_y, panel_w, "center")

    -- Delete confirmation
    if confirm_delete and selected_joker > 0 then
        local joker = Game.jokers[selected_joker]
        if joker then
            local confirm_y = panel_y + panel_h - 80
            love.graphics.setColor(Colors.red[1], Colors.red[2], Colors.red[3], 0.3)
            love.graphics.rectangle("fill", panel_x + 100, confirm_y, panel_w - 200, 50, 5, 5)
            love.graphics.setColor(Colors.red)
            love.graphics.setFont(UI.get_font(16, true))
            love.graphics.printf("Sell " .. joker.name .. "? Press [Y] to confirm, [N] to cancel", panel_x + 100, confirm_y + 15, panel_w - 200, "center")
        end
    end

    -- Controls
    love.graphics.setColor(Colors.dim)
    love.graphics.setFont(UI.get_font(14))
    love.graphics.printf("[1-5] Select Joker  |  [D] Delete Selected  |  [ESC/J] Close", panel_x, panel_y + panel_h - 30, panel_w, "center")
end

function JokersScreen.keypressed(key)
    if key == "escape" or key == "j" then
        if confirm_delete then
            confirm_delete = false
        else
            Game.state = "play"
            JokersScreen.reset()
        end
        return true
    end

    -- Number keys to select joker
    local num = tonumber(key)
    if num and num >= 1 and num <= #Game.jokers then
        selected_joker = num
        confirm_delete = false
        return true
    end

    -- D to initiate delete
    if key == "d" and selected_joker > 0 and selected_joker <= #Game.jokers then
        confirm_delete = true
        return true
    end

    -- Confirm delete
    if confirm_delete then
        if key == "y" then
            Game.delete_joker(selected_joker)
            selected_joker = 0
            confirm_delete = false
            return true
        elseif key == "n" then
            confirm_delete = false
            return true
        end
    end

    return false
end

function JokersScreen.mousepressed(x, y, button)
    if button ~= 1 then return false end

    local panel_w = 900
    local panel_h = 700
    local panel_x = (Config.SCREEN_W - panel_w) / 2
    local panel_y = (Config.SCREEN_H - panel_h) / 2

    local grid_x = panel_x + 30
    local grid_y = panel_y + 80
    local card_w = 160
    local card_h = 180
    local cards_per_row = 5
    local spacing = 10

    -- Check if clicked on a joker card
    for i, joker in ipairs(Game.jokers) do
        local col = (i - 1) % cards_per_row
        local row = math.floor((i - 1) / cards_per_row)
        local card_x = grid_x + col * (card_w + spacing)
        local card_y = grid_y + row * (card_h + spacing)

        if x >= card_x and x <= card_x + card_w and y >= card_y and y <= card_y + card_h then
            if selected_joker == i then
                -- Double click to delete
                confirm_delete = true
            else
                selected_joker = i
                confirm_delete = false
            end
            return true
        end
    end

    return false
end

return JokersScreen
