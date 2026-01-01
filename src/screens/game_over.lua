------------------------------------------------------------
-- GAME OVER SCREEN
-- Shows run stats and allows restart
------------------------------------------------------------

local Colors = require("src.colors")
local Config = require("src.config")
local UI = require("src.ui")
local Game = require("src.game")

local GameOverScreen = {}

function GameOverScreen.draw()
    -- Dark overlay
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 0, 0, Config.SCREEN_W, Config.SCREEN_H)

    local time = love.timer.getTime()

    -- GAME OVER title with red glow
    local title_y = 150
    for i = 3, 1, -1 do
        love.graphics.setColor(Colors.red[1], Colors.red[2], Colors.red[3], 0.2)
        love.graphics.setFont(UI.get_font(72, true))
        love.graphics.printf("GAME OVER", i, title_y + i, Config.SCREEN_W, "center")
    end
    love.graphics.setColor(Colors.red)
    love.graphics.printf("GAME OVER", 0, title_y, Config.SCREEN_W, "center")

    -- Failed at
    love.graphics.setColor(Colors.dim)
    love.graphics.setFont(UI.get_font(28))
    love.graphics.printf("Failed at Ante " .. Game.ante .. " - Round " .. Game.round_in_ante, 0, title_y + 90, Config.SCREEN_W, "center")

    -- Stats panel
    local panel_w = 600
    local panel_h = 350
    local panel_x = Config.SCREEN_W / 2 - panel_w / 2
    local panel_y = 320

    UI.draw_double_box(panel_x, panel_y, panel_w, panel_h, Colors.bg2, Colors.cyan_dim, true)

    -- Stats title
    love.graphics.setColor(Colors.cyan)
    love.graphics.rectangle("fill", panel_x + 4, panel_y + 4, panel_w - 8, 35)
    love.graphics.setColor(Colors.black)
    love.graphics.setFont(UI.get_font(20, true))
    love.graphics.printf("RUN STATISTICS", panel_x + 4, panel_y + 10, panel_w - 8, "center")

    -- Stats content
    local stat_y = panel_y + 55
    local stat_spacing = 45
    local label_x = panel_x + 40
    local value_x = panel_x + panel_w - 40

    local stats = {
        {"Highest Ante Reached", Game.ante},
        {"Total Rounds Played", Game.round},
        {"Total Spins", Game.total_spins},
        {"Highest Credits", Game.highest_credits},
        {"Final Credits", Game.credits},
        {"Games Played", Game.games_played},
    }

    for i, stat in ipairs(stats) do
        love.graphics.setColor(Colors.dim)
        love.graphics.setFont(UI.get_font(20))
        love.graphics.print(stat[1], label_x, stat_y)

        love.graphics.setColor(i == 1 and Colors.gold or (i == 4 and Colors.win or Colors.white))
        love.graphics.setFont(UI.get_font(24, true))
        love.graphics.printf(tostring(stat[2]), label_x, stat_y, panel_w - 80, "right")

        stat_y = stat_y + stat_spacing
    end

    -- Permanent buffs display (if any)
    local buffs_y = panel_y + panel_h + 30
    local has_buffs = (Game.perm_starting_credits or 0) > 0 or
                      (Game.perm_win_bonus or 0) > 0 or
                      (Game.perm_extra_spins or 0) > 0 or
                      (Game.perm_symbol_bonus or 0) > 0

    if has_buffs then
        love.graphics.setColor(Colors.purple)
        love.graphics.setFont(UI.get_font(18, true))
        love.graphics.printf("PERMANENT BUFFS EARNED", 0, buffs_y, Config.SCREEN_W, "center")

        local buff_text = ""
        if (Game.perm_starting_credits or 0) > 0 then
            buff_text = buff_text .. "+" .. Game.perm_starting_credits .. " Starting Credits  "
        end
        if (Game.perm_win_bonus or 0) > 0 then
            buff_text = buff_text .. "+" .. math.floor(Game.perm_win_bonus * 100) .. "% Wins  "
        end
        if (Game.perm_extra_spins or 0) > 0 then
            buff_text = buff_text .. "+" .. Game.perm_extra_spins .. " Spins  "
        end

        love.graphics.setColor(Colors.dim)
        love.graphics.setFont(UI.get_font(16))
        love.graphics.printf(buff_text, 0, buffs_y + 25, Config.SCREEN_W, "center")
    end

    -- Restart button area
    local btn_y = Config.SCREEN_H - 200
    local pulse = 0.7 + math.sin(time * 4) * 0.3

    -- Glow
    for i = 3, 1, -1 do
        love.graphics.setColor(Colors.highlight[1], Colors.highlight[2], Colors.highlight[3], 0.1 * pulse)
        love.graphics.rectangle("fill", Config.SCREEN_W/2 - 200 - i*4, btn_y - i*4, 400 + i*8, 70 + i*8, 8, 8)
    end

    UI.draw_rigid_box(Config.SCREEN_W/2 - 200, btn_y, 400, 70, Colors.bg2, Colors.highlight, 3)
    love.graphics.setColor(Colors.white)
    love.graphics.setFont(UI.get_font(32, true))
    love.graphics.printf("TRY AGAIN", 0, btn_y + 18, Config.SCREEN_W, "center")

    -- Controls
    love.graphics.setColor(Colors.cyan_dim)
    love.graphics.setFont(UI.get_font(16))
    love.graphics.printf("[SPACE] Start New Run  |  [ESC] Quit", 0, Config.SCREEN_H - 50, Config.SCREEN_W, "center")
end

function GameOverScreen.keypressed(key)
    if key == "space" or key == "return" then
        Game.start_new_run()
        return true
    elseif key == "escape" then
        love.event.quit()
        return true
    end
    return false
end

function GameOverScreen.mousepressed(x, y, button)
    if button == 1 then
        -- Check if clicking restart button
        local btn_y = Config.SCREEN_H - 200
        if x >= Config.SCREEN_W/2 - 200 and x <= Config.SCREEN_W/2 + 200 and
           y >= btn_y and y <= btn_y + 70 then
            Game.start_new_run()
            return true
        end
    end
    return false
end

return GameOverScreen
