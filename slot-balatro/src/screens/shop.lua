------------------------------------------------------------
-- SHOP SCREEN
-- Joker purchase interface
------------------------------------------------------------

local Colors = require("src.colors")
local Config = require("src.config")
local UI = require("src.ui")
local Game = require("src.game")

local ShopScreen = {}

function ShopScreen.draw()
    ShopScreen.draw_background()
    ShopScreen.draw_title()
    ShopScreen.draw_credits()
    ShopScreen.draw_cards()
    ShopScreen.draw_slot_changers()
    ShopScreen.draw_current_jokers()
    ShopScreen.draw_buttons()
    ShopScreen.draw_message()
    ShopScreen.draw_controls()
end

function ShopScreen.draw_background()
    love.graphics.setColor(Colors.bg)
    love.graphics.rectangle("fill", 0, 0, Config.SCREEN_W, Config.SCREEN_H)

    -- Grid pattern
    love.graphics.setColor(Colors.bg2[1], Colors.bg2[2], Colors.bg2[3], 0.3)
    for x = 0, Config.SCREEN_W, 40 do
        love.graphics.line(x, 0, x, Config.SCREEN_H)
    end
    for y = 0, Config.SCREEN_H, 40 do
        love.graphics.line(0, y, Config.SCREEN_W, y)
    end
end

function ShopScreen.draw_title()
    UI.draw_rigid_box(Config.SCREEN_W/2 - 200, 30, 400, 70, Colors.bg2, Colors.gold, 4)
    love.graphics.setFont(UI.get_font(48, true))
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.printf("SHOP", 2, 45, Config.SCREEN_W, "center")
    love.graphics.setColor(Colors.gold)
    love.graphics.printf("SHOP", 0, 43, Config.SCREEN_W, "center")
end

function ShopScreen.draw_credits()
    love.graphics.setColor(Colors.dim)
    love.graphics.setFont(UI.get_font(20))
    love.graphics.printf("YOUR CREDITS", 0, 115, Config.SCREEN_W, "center")
    love.graphics.setColor(Colors.gold)
    love.graphics.setFont(UI.get_font(42, true))
    love.graphics.printf(tostring(Game.credits), 0, 140, Config.SCREEN_W, "center")
end

function ShopScreen.draw_cards()
    local card_w = 340
    local card_spacing = 40
    local total_w = 3 * card_w + 2 * card_spacing
    local start_x = Config.SCREEN_W/2 - total_w/2

    for i = 1, 3 do
        local item = Game.shop_items[i]
        local card_x = start_x + (i-1) * (card_w + card_spacing)
        local card_y = 200
        ShopScreen.draw_shop_card(card_x, card_y, i, item, card_w)
    end
end

function ShopScreen.draw_shop_card(x, y, index, item, w)
    local h = 380

    if not item then
        -- Sold out
        UI.draw_rigid_box(x, y, w, h, Colors.bg2, Colors.dim, 3)
        love.graphics.setColor(Colors.dim)
        love.graphics.setFont(UI.get_font(24, true))
        love.graphics.printf("SOLD", x, y + h/2 - 12, w, "center")
        return
    end

    -- Card background
    UI.draw_rigid_box(x, y, w, h, Colors.bg2, item.color, 3)

    -- Joker icon
    love.graphics.setColor(item.color)
    love.graphics.setFont(UI.get_font(64, true))
    love.graphics.printf(item.icon, x, y + 40, w, "center")

    -- Name
    love.graphics.setColor(Colors.white)
    love.graphics.setFont(UI.get_font(28, true))
    love.graphics.printf(item.name, x, y + 130, w, "center")

    -- Effect description
    love.graphics.setColor(Colors.dim)
    love.graphics.setFont(UI.get_font(18))
    love.graphics.printf(item.effect, x + 20, y + 180, w - 40, "center")

    -- Cost
    UI.draw_rigid_box(x + w/2 - 60, y + 260, 120, 50, Colors.bg, Colors.gold, 2)
    love.graphics.setColor(Colors.gold)
    love.graphics.setFont(UI.get_font(28, true))
    love.graphics.printf("$" .. item.cost, x, y + 270, w, "center")

    -- Buy button
    local can_afford = Game.credits >= item.cost and #Game.jokers < Game.max_jokers
    local can_buy = can_afford and not Game.shop_bought_joker
    local btn_color = can_buy and Colors.win or Colors.dim

    UI.draw_rigid_box(x + w/2 - 80, y + 320, 160, 45, Colors.bg, btn_color, 2)
    love.graphics.setColor(can_buy and Colors.white or Colors.dim)
    love.graphics.setFont(UI.get_font(20, true))
    if Game.shop_bought_joker then
        love.graphics.printf("LIMIT 1", x, y + 332, w, "center")
    else
        love.graphics.printf("BUY [" .. index .. "]", x, y + 332, w, "center")
    end
end

function ShopScreen.draw_slot_changers()
    -- Slot changers section (below joker cards)
    local section_y = 590

    love.graphics.setColor(Colors.purple)
    love.graphics.setFont(UI.get_font(20, true))
    love.graphics.printf("SLOT UPGRADES", 0, section_y, Config.SCREEN_W, "center")

    local changers = Game.shop_slot_changers or {}
    if not changers or #changers == 0 then
        love.graphics.setColor(Colors.dim)
        love.graphics.setFont(UI.get_font(14))
        local msg = #(Game.slot_changers or {}) >= 3 and "All slot upgrades owned!" or "No upgrades available this round"
        love.graphics.printf(msg, 0, section_y + 30, Config.SCREEN_W, "center")
        return
    end

    local card_w = 280
    local card_h = 100
    local spacing = 30
    local total_w = #changers * card_w + (#changers - 1) * spacing
    local start_x = Config.SCREEN_W/2 - total_w/2

    for i, item in ipairs(changers) do
        if item then
            local card_x = start_x + (i-1) * (card_w + spacing)
            local card_y = section_y + 30

            -- Card
            UI.draw_rigid_box(card_x, card_y, card_w, card_h, Colors.bg2, item.color, 2)

            -- Icon
            love.graphics.setColor(item.color)
            love.graphics.setFont(UI.get_font(24, true))
            love.graphics.print(item.icon, card_x + 15, card_y + 10)

            -- Name
            love.graphics.setColor(Colors.white)
            love.graphics.setFont(UI.get_font(16, true))
            love.graphics.print(item.name, card_x + 70, card_y + 10)

            -- Effect
            love.graphics.setColor(Colors.dim)
            love.graphics.setFont(UI.get_font(12))
            love.graphics.printf(item.effect, card_x + 70, card_y + 32, card_w - 85, "left")

            -- Cost and buy
            local can_afford = Game.credits >= item.cost
            local can_buy = can_afford and not Game.shop_bought_changer
            love.graphics.setColor(Colors.gold)
            love.graphics.setFont(UI.get_font(18, true))
            love.graphics.printf("$" .. item.cost, card_x, card_y + 70, card_w/2, "center")

            love.graphics.setColor(can_buy and Colors.win or Colors.dim)
            love.graphics.setFont(UI.get_font(14, true))
            if Game.shop_bought_changer then
                love.graphics.printf("LIMIT 1", card_x + card_w/2, card_y + 72, card_w/2, "center")
            else
                love.graphics.printf("[" .. (i + 3) .. "] BUY", card_x + card_w/2, card_y + 72, card_w/2, "center")
            end
        end
    end
end

function ShopScreen.draw_current_jokers()
    local panel_w = 600
    local panel_y = 750
    UI.draw_rigid_box(Config.SCREEN_W/2 - panel_w/2, panel_y, panel_w, 90, Colors.bg2, Colors.frame, 2)

    love.graphics.setColor(Colors.white)
    love.graphics.setFont(UI.get_font(16))
    love.graphics.printf("YOUR JOKERS (" .. #Game.jokers .. "/" .. Game.max_jokers .. ")", 0, panel_y + 10, Config.SCREEN_W, "center")

    if #Game.jokers > 0 then
        local jx = Config.SCREEN_W/2 - (#Game.jokers * 65) / 2
        for i, j in ipairs(Game.jokers) do
            UI.draw_rigid_box(jx + (i-1) * 65, panel_y + 35, 55, 45, Colors.bg, j.color, 2)
            love.graphics.setColor(j.color)
            love.graphics.setFont(UI.get_font(18, true))
            love.graphics.printf(j.icon, jx + (i-1) * 65, panel_y + 43, 55, "center")
        end
    else
        love.graphics.setColor(Colors.dim)
        love.graphics.setFont(UI.get_font(14))
        love.graphics.printf("Empty - buy jokers above!", 0, panel_y + 45, Config.SCREEN_W, "center")
    end
end

function ShopScreen.draw_buttons()
    for _, btn in ipairs(UI.get_visible_buttons()) do
        if btn.id == "reroll" or btn.id == "continue" then
            local bg = btn.hover and Colors.button_hover or Colors.button
            local border = btn.style == "primary" and Colors.highlight or Colors.frame

            -- Check if reroll is disabled
            local is_disabled = (btn.id == "reroll" and Game.shop_rerolled)
            if is_disabled then
                bg = Colors.bg2
                border = Colors.dim
            end

            if btn.pressed and not is_disabled then bg = Colors.button_press end

            UI.draw_rigid_box(btn.x, btn.y, btn.w, btn.h, bg, border, 3)
            love.graphics.setColor(is_disabled and Colors.dim or Colors.white)
            love.graphics.setFont(UI.get_font(24, true))

            local text = btn.text
            if btn.id == "reroll" then
                if Game.shop_rerolled then
                    text = "REROLLED"
                else
                    text = "REROLL ($" .. Config.REROLL_COST .. ")"
                end
            end

            love.graphics.printf(text, btn.x, btn.y + btn.h/2 - 12, btn.w, "center")
        end
    end
end

function ShopScreen.draw_message()
    love.graphics.setColor(Colors.white)
    love.graphics.setFont(UI.get_font(22))
    love.graphics.printf(Game.message, 0, 930, Config.SCREEN_W, "center")
end

function ShopScreen.draw_controls()
    love.graphics.setColor(Colors.dim)
    love.graphics.setFont(UI.get_font(14))
    love.graphics.printf("[1-3] Buy Joker (1 max)  |  [4-5] Buy Upgrade (1 max)  |  [R] Reroll (1 max)  |  [SPACE] Continue", 0, 1000, Config.SCREEN_W, "center")
end

return ShopScreen
