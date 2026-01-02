------------------------------------------------------------
-- ANTE REWARD SCREEN
-- Buff selection after completing an ante
------------------------------------------------------------

local Colors = require("src.colors")
local Config = require("src.config")
local UI = require("src.ui")
local Game = require("src.game")

local AnteRewardScreen = {}

function AnteRewardScreen.draw()
    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, Config.SCREEN_W, Config.SCREEN_H)

    local time = love.timer.getTime()

    -- Title with glow
    local title_y = 120
    for i = 3, 1, -1 do
        love.graphics.setColor(Colors.gold[1], Colors.gold[2], Colors.gold[3], 0.15)
        love.graphics.setFont(UI.get_font(64, true))
        love.graphics.printf("ANTE " .. Game.ante .. " COMPLETE!", i, title_y + i, Config.SCREEN_W, "center")
    end
    love.graphics.setColor(Colors.gold)
    love.graphics.printf("ANTE " .. Game.ante .. " COMPLETE!", 0, title_y, Config.SCREEN_W, "center")

    -- Subtitle
    love.graphics.setColor(Colors.cyan)
    love.graphics.setFont(UI.get_font(28))
    love.graphics.printf("Choose a Permanent Buff", 0, title_y + 80, Config.SCREEN_W, "center")

    -- Draw buff cards
    local card_w = 400
    local card_h = 350
    local card_spacing = 50
    local total_w = 3 * card_w + 2 * card_spacing
    local start_x = Config.SCREEN_W / 2 - total_w / 2
    local card_y = 280

    for i, buff in ipairs(Game.ante_reward_choices) do
        local card_x = start_x + (i - 1) * (card_w + card_spacing)
        local is_hovered = Game.selected_ante_reward == i

        -- Card glow when hovered
        if is_hovered then
            local glow = 0.5 + math.sin(time * 6) * 0.3
            for j = 4, 1, -1 do
                love.graphics.setColor(buff.color[1], buff.color[2], buff.color[3], 0.15 * glow)
                love.graphics.rectangle("fill", card_x - j*4, card_y - j*4, card_w + j*8, card_h + j*8, 10, 10)
            end
        end

        -- Card background
        local bg_color = is_hovered and {0.15, 0.12, 0.2} or Colors.bg2
        UI.draw_rigid_box(card_x, card_y, card_w, card_h, bg_color, buff.color, is_hovered and 4 or 2)

        -- Icon
        love.graphics.setColor(buff.color)
        love.graphics.setFont(UI.get_font(72, true))
        love.graphics.printf(buff.icon, card_x, card_y + 40, card_w, "center")

        -- Name
        love.graphics.setColor(Colors.white)
        love.graphics.setFont(UI.get_font(32, true))
        love.graphics.printf(buff.name, card_x, card_y + 140, card_w, "center")

        -- Description
        love.graphics.setColor(Colors.dim)
        love.graphics.setFont(UI.get_font(20))
        love.graphics.printf(buff.desc, card_x + 20, card_y + 190, card_w - 40, "center")

        -- Selection indicator
        love.graphics.setColor(is_hovered and Colors.gold or Colors.cyan_dim)
        love.graphics.setFont(UI.get_font(24, true))
        love.graphics.printf("[" .. i .. "]", card_x, card_y + card_h - 60, card_w, "center")

        if is_hovered then
            love.graphics.setColor(Colors.gold)
            love.graphics.setFont(UI.get_font(20))
            love.graphics.printf("Press SPACE to select", card_x, card_y + card_h - 35, card_w, "center")
        end
    end

    -- Stats display
    local stats_y = card_y + card_h + 50
    love.graphics.setColor(Colors.dim)
    love.graphics.setFont(UI.get_font(18))
    love.graphics.printf("Credits: " .. Game.credits .. "  |  Rounds Completed: " .. Game.round .. "  |  Best Ante: " .. Game.highest_ante, 0, stats_y, Config.SCREEN_W, "center")

    -- Controls
    love.graphics.setColor(Colors.cyan_dim)
    love.graphics.setFont(UI.get_font(16))
    love.graphics.printf("[1-3] Select  |  [SPACE] Confirm Selection", 0, Config.SCREEN_H - 60, Config.SCREEN_W, "center")
end

function AnteRewardScreen.keypressed(key)
    if key == "1" then
        Game.selected_ante_reward = 1
    elseif key == "2" then
        Game.selected_ante_reward = 2
    elseif key == "3" then
        Game.selected_ante_reward = 3
    elseif key == "space" or key == "return" then
        if Game.selected_ante_reward > 0 then
            Game.select_ante_reward(Game.selected_ante_reward)
            return true
        end
    end
    return false
end

function AnteRewardScreen.mousepressed(x, y, button)
    if button == 1 then
        -- Check if clicking on a card
        local card_w = 400
        local card_h = 350
        local card_spacing = 50
        local total_w = 3 * card_w + 2 * card_spacing
        local start_x = Config.SCREEN_W / 2 - total_w / 2
        local card_y = 280

        for i = 1, 3 do
            local card_x = start_x + (i - 1) * (card_w + card_spacing)
            if x >= card_x and x <= card_x + card_w and y >= card_y and y <= card_y + card_h then
                if Game.selected_ante_reward == i then
                    -- Double click to confirm
                    Game.select_ante_reward(i)
                else
                    Game.selected_ante_reward = i
                end
                return true
            end
        end
    end
    return false
end

return AnteRewardScreen
