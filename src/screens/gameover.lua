------------------------------------------------------------
-- GAME OVER SCREEN
-- End of game display
------------------------------------------------------------

local Colors = require("src.colors")
local Config = require("src.config")
local UI = require("src.ui")
local Game = require("src.game")

local GameOverScreen = {}

function GameOverScreen.draw()
    -- Darken background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, Config.SCREEN_W, Config.SCREEN_H)

    -- Game over box
    local box_w, box_h = 700, 500
    local box_x = Config.SCREEN_W/2 - box_w/2
    local box_y = Config.SCREEN_H/2 - box_h/2

    UI.draw_rigid_box(box_x, box_y, box_w, box_h, Colors.bg2, Colors.red, 5)

    -- Title
    love.graphics.setFont(UI.get_font(72, true))
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.printf("GAME OVER", 3, box_y + 43, Config.SCREEN_W, "center")
    love.graphics.setColor(Colors.red)
    love.graphics.printf("GAME OVER", 0, box_y + 40, Config.SCREEN_W, "center")

    -- Stats
    love.graphics.setColor(Colors.white)
    love.graphics.setFont(UI.get_font(32, true))
    love.graphics.printf("FINAL ROUND: " .. Game.round, 0, box_y + 150, Config.SCREEN_W, "center")

    love.graphics.setColor(Colors.gold)
    love.graphics.printf("FINAL CREDITS: " .. Game.credits, 0, box_y + 200, Config.SCREEN_W, "center")

    love.graphics.setColor(Colors.dim)
    love.graphics.setFont(UI.get_font(22))
    love.graphics.printf("JOKERS COLLECTED: " .. #Game.jokers, 0, box_y + 260, Config.SCREEN_W, "center")

    -- Target info
    love.graphics.setColor(Colors.red)
    love.graphics.setFont(UI.get_font(20))
    love.graphics.printf("Target was: " .. Game.round_target .. " credits", 0, box_y + 300, Config.SCREEN_W, "center")

    -- Restart button
    for _, btn in ipairs(UI.get_visible_buttons()) do
        if btn.id == "restart" then
            local bg = btn.hover and Colors.button_hover or Colors.button
            UI.draw_rigid_box(btn.x, btn.y, btn.w, btn.h, bg, Colors.highlight, 3)
            love.graphics.setColor(Colors.white)
            love.graphics.setFont(UI.get_font(28, true))
            love.graphics.printf(btn.text, btn.x, btn.y + btn.h/2 - 14, btn.w, "center")
        end
    end

    -- Hint
    love.graphics.setColor(Colors.dim)
    love.graphics.setFont(UI.get_font(16))
    love.graphics.printf("Press [R] or click RESTART to play again", 0, box_y + box_h - 40, Config.SCREEN_W, "center")
end

return GameOverScreen
