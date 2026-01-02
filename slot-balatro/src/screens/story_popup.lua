------------------------------------------------------------
-- STORY POPUP SCREEN
-- Displays story narrative after completing an ante
------------------------------------------------------------

local Colors = require("src.colors")
local Config = require("src.config")
local UI = require("src.ui")
local Game = require("src.game")

local StoryPopup = {}

function StoryPopup.draw()
    local popup = Game.get_story_popup()
    if not popup.active then return end

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 0, 0, Config.SCREEN_W, Config.SCREEN_H)

    local time = love.timer.getTime()

    -- Calculate popup dimensions
    local popup_w = 800
    local popup_h = 500
    local popup_x = Config.SCREEN_W / 2 - popup_w / 2
    local popup_y = Config.SCREEN_H / 2 - popup_h / 2

    -- Animated glow
    local glow = 0.3 + math.sin(time * 2) * 0.1
    for i = 5, 1, -1 do
        love.graphics.setColor(Colors.magenta[1], Colors.magenta[2], Colors.magenta[3], glow / i)
        love.graphics.rectangle("fill", popup_x - i*6, popup_y - i*6, popup_w + i*12, popup_h + i*12, 15, 15)
    end

    -- Main popup background
    UI.draw_rigid_box(popup_x, popup_y, popup_w, popup_h, Colors.bg, Colors.magenta, 3)

    -- Boss name header
    love.graphics.setColor(Colors.magenta)
    love.graphics.setFont(UI.get_font(18, true))
    love.graphics.printf("ANTE " .. (popup.ante or 0) .. " - " .. (popup.boss_name or "???"), popup_x, popup_y + 20, popup_w, "center")

    -- Luna says header
    love.graphics.setColor(Colors.cyan)
    love.graphics.setFont(UI.get_font(28, true))
    love.graphics.printf("Luna speaks...", popup_x, popup_y + 55, popup_w, "center")

    -- Decorative line
    love.graphics.setColor(Colors.cyan_dim)
    love.graphics.rectangle("fill", popup_x + 50, popup_y + 95, popup_w - 100, 2)

    -- Story text with typing effect simulation
    local text = popup.text or ""

    -- Wrap the text and draw it
    love.graphics.setColor(Colors.white)
    love.graphics.setFont(UI.get_font(22))

    local text_x = popup_x + 50
    local text_y = popup_y + 120
    local text_w = popup_w - 100
    local text_h = popup_h - 200

    love.graphics.printf(text, text_x, text_y, text_w, "left")

    -- Decorative bottom line
    love.graphics.setColor(Colors.cyan_dim)
    love.graphics.rectangle("fill", popup_x + 50, popup_y + popup_h - 85, popup_w - 100, 2)

    -- Continue prompt with pulsing
    local pulse = 0.5 + math.sin(time * 4) * 0.5
    love.graphics.setColor(Colors.gold[1], Colors.gold[2], Colors.gold[3], 0.5 + pulse * 0.5)
    love.graphics.setFont(UI.get_font(20, true))
    love.graphics.printf("Press SPACE or click to continue...", popup_x, popup_y + popup_h - 55, popup_w, "center")
end

function StoryPopup.keypressed(key)
    if not Game.is_story_popup_active() then return false end

    if key == "space" or key == "return" or key == "escape" then
        Game.close_story_popup()
        return true
    end
    return false
end

function StoryPopup.mousepressed(x, y, button)
    if not Game.is_story_popup_active() then return false end

    if button == 1 then
        Game.close_story_popup()
        return true
    end
    return false
end

return StoryPopup
