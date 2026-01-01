------------------------------------------------------------
-- PLAY SCREEN
-- Main gameplay screen drawing
------------------------------------------------------------

local Colors = require("src.colors")
local Config = require("src.config")
local UI = require("src.ui")
local Game = require("src.game")
local Effects = require("src.effects")
local Story = require("src.systems.story")

local PlayScreen = {}

-- State for toggleable paytable
local show_paytable = false

------------------------------------------------------------
-- MAIN DRAW
------------------------------------------------------------
function PlayScreen.draw()
    PlayScreen.draw_background()
    PlayScreen.draw_title_bar()
    PlayScreen.draw_portrait_area()
    PlayScreen.draw_reel_area()
    PlayScreen.draw_stats_panel()
    PlayScreen.draw_info_bar()
    PlayScreen.draw_action_bar()
end

function PlayScreen.toggle_paytable()
    show_paytable = not show_paytable
end

------------------------------------------------------------
-- DEALER CHARACTER (LUNA)
------------------------------------------------------------
function PlayScreen.draw_dealer(x, y, w, h)
    local time = love.timer.getTime()
    local cx = x + w / 2

    -- Get Luna's current image
    local luna_img = Game.get_current_luna_image()

    if luna_img then
        -- Draw Luna's image
        local img_w, img_h = luna_img:getDimensions()

        -- Calculate scale to fill the portrait area (no padding)
        local scale = math.max(w / img_w, h / img_h)

        local draw_w = img_w * scale
        local draw_h = img_h * scale
        local draw_x = x + (w - draw_w) / 2
        local draw_y = y + (h - draw_h) / 2

        -- Subtle bob animation
        local bob = math.sin(time * 2) * 2
        draw_y = draw_y + bob

        -- Glow effect for exciting expressions
        local expression = Game.luna_expression
        if expression == "jackpot" or expression == "mega_jackpot" or expression == "big_win" then
            -- Golden glow behind Luna
            local glow_pulse = 0.5 + math.sin(time * 4) * 0.3
            for i = 4, 1, -1 do
                love.graphics.setColor(Colors.gold[1], Colors.gold[2], Colors.gold[3], 0.1 * glow_pulse)
                love.graphics.rectangle("fill", draw_x - i*4, draw_y - i*4, draw_w + i*8, draw_h + i*8, 8, 8)
            end
        elseif expression == "small_win" or expression == "good_win" then
            -- Subtle cyan glow
            local glow_pulse = 0.4 + math.sin(time * 3) * 0.2
            for i = 2, 1, -1 do
                love.graphics.setColor(Colors.cyan[1], Colors.cyan[2], Colors.cyan[3], 0.08 * glow_pulse)
                love.graphics.rectangle("fill", draw_x - i*3, draw_y - i*3, draw_w + i*6, draw_h + i*6, 6, 6)
            end
        end

        -- Draw Luna
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(luna_img, draw_x, draw_y, 0, scale, scale)

        -- Highlight overlay for wins
        if expression == "jackpot" or expression == "mega_jackpot" then
            local flash = 0.1 + math.sin(time * 8) * 0.1
            love.graphics.setBlendMode("add")
            love.graphics.setColor(1, 1, 1, flash)
            love.graphics.draw(luna_img, draw_x, draw_y, 0, scale, scale)
            love.graphics.setBlendMode("alpha")
        end
    else
        -- Fallback: draw placeholder
        love.graphics.setColor(Colors.bg2)
        love.graphics.rectangle("fill", x + 10, y + 10, w - 20, h - 20, 8, 8)
        love.graphics.setColor(Colors.cyan_dim)
        love.graphics.rectangle("line", x + 10, y + 10, w - 20, h - 20, 8, 8)

        love.graphics.setColor(Colors.dim)
        love.graphics.setFont(UI.get_font(14))
        love.graphics.printf("LUNA", x, y + h/2 - 20, w, "center")
        love.graphics.setFont(UI.get_font(10))
        love.graphics.printf("(" .. Game.luna_expression .. ")", x, y + h/2, w, "center")
    end

    love.graphics.setLineWidth(1)
end

------------------------------------------------------------
-- BACKGROUND
------------------------------------------------------------
function PlayScreen.draw_background()
    love.graphics.setColor(Colors.bg)
    love.graphics.rectangle("fill", 0, 0, Config.SCREEN_W, Config.SCREEN_H)

    -- Subtle grid pattern
    love.graphics.setColor(Colors.bg2[1], Colors.bg2[2], Colors.bg2[3], 0.3)
    for x = 0, Config.SCREEN_W, 40 do
        love.graphics.line(x, 0, x, Config.SCREEN_H)
    end
    for y = 0, Config.SCREEN_H, 40 do
        love.graphics.line(0, y, Config.SCREEN_W, y)
    end
end

------------------------------------------------------------
-- [A] TITLE BAR
------------------------------------------------------------
function PlayScreen.draw_title_bar()
    local r = Config.LAYOUT.title_bar
    UI.draw_double_box(r.x, r.y, r.w, r.h, Colors.bg_panel, Colors.cyan, true)

    -- Round and Ante info (left)
    love.graphics.setColor(Colors.cyan)
    love.graphics.setFont(UI.get_font(20, true))
    love.graphics.print("ANTE " .. Game.ante, r.x + 20, r.y + 12)

    -- Boss name (below ante)
    local boss_name = Story.get_boss_name(Game.ante)
    love.graphics.setColor(Colors.magenta)
    love.graphics.setFont(UI.get_font(16, true))
    love.graphics.print(boss_name, r.x + 20, r.y + 36)

    -- Title (center) with glow
    local time = love.timer.getTime()
    local pulse = 0.8 + math.sin(time * 2) * 0.2
    for i = 3, 1, -1 do
        love.graphics.setColor(Colors.highlight[1], Colors.highlight[2], Colors.highlight[3], 0.15 * pulse)
        love.graphics.setFont(UI.get_font(36, true))
        love.graphics.printf("SLOT BALATRO", r.x + i, r.y + 15 + i, r.w, "center")
        love.graphics.printf("SLOT BALATRO", r.x - i, r.y + 15 - i, r.w, "center")
    end
    love.graphics.setColor(Colors.highlight[1] * pulse + 0.5, Colors.highlight[2], Colors.highlight[3])
    love.graphics.printf("SLOT BALATRO", r.x, r.y + 15, r.w, "center")

    -- CRT indicator (right)
    love.graphics.setColor(Colors.dim)
    love.graphics.setFont(UI.get_font(16))
    love.graphics.printf("CRT", r.x + r.w - 180, r.y + 25, 40, "center")
end

------------------------------------------------------------
-- [B] PORTRAIT AREA + PAYTABLE TOGGLE
------------------------------------------------------------
function PlayScreen.draw_portrait_area()
    local r = Config.LAYOUT.portrait
    UI.draw_double_box(r.x, r.y, r.w, r.h, Colors.bg_panel, Colors.cyan, true)

    -- Title
    love.graphics.setColor(Colors.cyan)
    love.graphics.rectangle("fill", r.x + 4, r.y + 4, r.w - 8, 28)
    love.graphics.setColor(Colors.black)
    love.graphics.setFont(UI.get_font(16, true))
    love.graphics.printf("LUNA", r.x + 4, r.y + 8, r.w - 8, "center")

    -- Portrait area - bigger to fill more space
    local portrait_h = 420
    local px = r.x + 10
    local py = r.y + 40
    local pw = r.w - 20

    -- Draw background
    love.graphics.setColor(Colors.bg2)
    love.graphics.rectangle("fill", px, py, pw, portrait_h)

    -- Use scissor to clip Luna within the portrait area
    love.graphics.setScissor(px, py, pw, portrait_h)
    PlayScreen.draw_dealer(px, py, pw, portrait_h)
    love.graphics.setScissor()

    -- Draw border on top (after scissor reset)
    love.graphics.setColor(Colors.cyan_dim)
    love.graphics.rectangle("line", px, py, pw, portrait_h)

    -- Expression label
    local expression = Game.luna_expression:upper():gsub("_", " ")
    local expr_color = Colors.cyan
    if Game.luna_expression == "jackpot" or Game.luna_expression == "mega_jackpot" then
        expr_color = Colors.gold
    elseif Game.luna_expression == "small_win" or Game.luna_expression == "good_win" or Game.luna_expression == "big_win" then
        expr_color = Colors.win
    elseif Game.luna_expression == "losing_streak" or Game.luna_expression == "broke" then
        expr_color = Colors.red
    end

    love.graphics.setColor(expr_color)
    love.graphics.setFont(UI.get_font(14, true))
    love.graphics.printf("[ " .. expression .. " ]", r.x + 10, r.y + portrait_h + 50, r.w - 20, "center")

    -- Speech bubble - bigger
    local bubble_y = r.y + portrait_h + 75
    local bubble_h = 100
    UI.draw_double_box(r.x + 10, bubble_y, r.w - 20, bubble_h, Colors.bg2, Colors.cyan_dim, false)

    -- Check for story dialogue first (uses Story module's timed dialogue)
    local story_dialogue, story_type = Story.get_active_dialogue()
    local speech, speech_color

    if story_dialogue then
        -- Use story dialogue (intro, win, loss lines)
        speech = story_dialogue
        if story_type == "win" then
            speech_color = Colors.gold
        elseif story_type == "loss" then
            speech_color = Colors.red
        elseif story_type == "intro" then
            speech_color = Colors.cyan
        else
            speech_color = Colors.white
        end
    else
        -- Dynamic speech based on Luna's expression
        local speech_lines = {
            idle = {"Ready when you are~", "Feeling lucky?", "Take your time..."},
            watching = {"Here we go...", "Come on...", "..."},
            neutral = {"Better luck next spin!", "Don't give up!", "The reels are fickle..."},
            small_win = {"Nice one!", "There you go!", "Good start~"},
            good_win = {"Well played!", "Looking good!", "Keep it up!"},
            big_win = {"Amazing!!", "Incredible spin!", "You're on fire!"},
            jackpot = {"JACKPOT!!!", "UNBELIEVABLE!!", "MASSIVE WIN!!!"},
            mega_jackpot = {"LEGENDARY!!!", "I CAN'T BELIEVE IT!!!", "HISTORY MADE!!!"},
            losing_streak = {"Hang in there...", "Luck will turn...", "I believe in you..."},
            broke = {"Maybe take a break?", "It's just a game...", "You'll bounce back..."},
            comeback = {"YES! I knew it!", "What a comeback!", "Never give up!"},
            shop = {"See anything you like?", "Great choices today~", "Invest wisely!"},
            round_end = {"Good round!", "Ready for the shop?", "Let's see your options!"},
        }

        local lines = speech_lines[Game.luna_expression] or speech_lines["idle"]
        -- Use a slow-changing index based on time
        local line_idx = math.floor(love.timer.getTime() / 3) % #lines + 1
        speech = lines[line_idx]

        speech_color = Colors.white
        if Game.luna_expression == "jackpot" or Game.luna_expression == "mega_jackpot" then
            speech_color = Colors.gold
        end
    end

    love.graphics.setColor(speech_color)
    love.graphics.setFont(UI.get_font(24, true))
    love.graphics.printf(speech, r.x + 15, bubble_y + 35, r.w - 30, "center")

    -- PAYTABLE (if visible) - show below speech bubble
    if show_paytable then
        local pay_y = bubble_y + bubble_h + 10
        local pay_h = r.h - (pay_y - r.y) - 10
        UI.draw_double_box(r.x + 10, pay_y, r.w - 20, pay_h, Colors.bg2, Colors.cyan_dim, false)

        love.graphics.setColor(Colors.cyan)
        love.graphics.setFont(UI.get_font(12, true))
        love.graphics.printf("PAYTABLE", r.x + 10, pay_y + 8, r.w - 20, "center")

        local sym_y = pay_y + 30
        for i, sym in ipairs(Config.SYMBOLS) do
            if sym_y < pay_y + pay_h - 20 then
                love.graphics.setColor(sym.color)
                love.graphics.setFont(UI.get_font(14, true))
                love.graphics.print(sym.icon, r.x + 20, sym_y)
                love.graphics.setColor(Colors.dim)
                love.graphics.setFont(UI.get_font(12))
                love.graphics.printf("x" .. sym.value, r.x + 10, sym_y + 2, r.w - 30, "right")
                sym_y = sym_y + 22
            end
        end
    end
end

------------------------------------------------------------
-- [C] REEL AREA - WITH CRT OVERLAY EFFECT
------------------------------------------------------------
function PlayScreen.draw_reel_area()
    local r = Config.LAYOUT.reels

    -- Draw outer frame
    UI.draw_double_box(r.x, r.y, r.w, r.h, Colors.bg_panel, Colors.cyan, true)

    -- Title with glow
    love.graphics.setColor(Colors.cyan)
    love.graphics.rectangle("fill", r.x + 4, r.y + 4, r.w - 8, 32)
    love.graphics.setColor(Colors.black)
    love.graphics.setFont(UI.get_font(20, true))
    love.graphics.printf("REELS", r.x + 4, r.y + 10, r.w - 8, "center")

    -- Reel container dimensions
    local reel_container_x = r.x + 10
    local reel_container_y = r.y + 45
    local reel_container_w = r.w - 20
    local reel_container_h = r.h - 55

    -- Draw CRT bezel (background frame)
    PlayScreen.draw_crt_bezel(reel_container_x, reel_container_y, reel_container_w, reel_container_h)

    -- Calculate dynamic reel height based on visible rows
    local num_rows = Game.num_rows or 3
    local dynamic_reel_height = num_rows * Config.SYMBOL_HEIGHT

    -- Draw reel background
    love.graphics.setColor(Colors.reel_bg)
    love.graphics.rectangle("fill", reel_container_x, reel_container_y, reel_container_w, reel_container_h)

    -- Win flash
    if Game.win_flash > 0 then
        love.graphics.setColor(Colors.yellow[1], Colors.yellow[2], Colors.yellow[3], Game.win_flash * 0.3)
        love.graphics.rectangle("fill", reel_container_x, reel_container_y, reel_container_w, reel_container_h)
    end

    -- Draw reels directly (dynamic number of reels)
    local reels = Game.get_reels()
    local num_reels = Game.num_reels
    local reel_width = Config.REEL_WIDTH
    local reel_spacing = Config.REEL_SPACING

    -- Adjust reel width if we have more than 3 reels
    if num_reels > 3 then
        reel_width = math.floor((reel_container_w - 60 - (num_reels - 1) * 20) / num_reels)
        reel_spacing = 20
    end

    local total_reels_w = num_reels * reel_width + (num_reels - 1) * reel_spacing
    local reel_start_x = reel_container_x + (reel_container_w - total_reels_w) / 2
    local reel_start_y = reel_container_y + (reel_container_h - dynamic_reel_height) / 2

    for i, reel in ipairs(reels) do
        local rx = reel_start_x + (i-1) * (reel_width + reel_spacing)
        PlayScreen.draw_reel_dynamic(reel, rx, reel_start_y, i, reel_width)
    end

    -- Win lines with animated glow (support multiple paylines including diagonals)
    -- Payline Y position must match where symbols are actually drawn:
    -- Symbol j is drawn at: y + j * SYMBOL_HEIGHT + SYMBOL_HEIGHT * 0.15
    -- Center of symbol j: y + j * SYMBOL_HEIGHT + SYMBOL_HEIGHT * 0.15 + SYMBOL_HEIGHT/2
    -- For j=1 (center, offset=0): y + 1*110 + 16.5 + 55 = y + 181.5
    -- For j=0 (top, offset=-1): y + 0 + 16.5 + 55 = y + 71.5
    -- Formula: line_y = reel_start_y + (1 + offset) * SYMBOL_HEIGHT + SYMBOL_HEIGHT * 0.65
    local time = love.timer.getTime()

    -- Synced glow pulse - all lines pulse together
    local sync_pulse = 0.6 + math.sin(time * 6) * 0.4

    -- Define colors for each payline type
    local payline_colors = {
        [0] = Colors.highlight,       -- Center line (magenta)
        [-1] = Colors.cyan,           -- Top line (cyan)
        [1] = Colors.gold,            -- Bottom line (gold)
        [-2] = Colors.blue,           -- Far top (4th row up)
        [2] = Colors.red,             -- Far bottom (4th row down)
        ["diag_down"] = Colors.orange, -- Diagonal down (orange)
        ["diag_up"] = Colors.purple,   -- Diagonal up (purple)
    }

    -- Helper function to get Y position for a row offset
    -- offset: 0 = center, -1 = one above, 1 = one below, -2 = two above, 2 = two below
    local center_row = math.floor(num_rows / 2)
    local function get_row_y(offset)
        local row_index = center_row + offset
        return reel_start_y + row_index * Config.SYMBOL_HEIGHT + Config.SYMBOL_HEIGHT * 0.65
    end

    for idx, payline in ipairs(Game.paylines) do
        local line_color = payline_colors[payline] or Colors.highlight

        -- Check if this payline is a winner
        local is_winner = Game.winning_paylines[payline] and not Game.spinning

        -- Check if this is the currently revealing payline
        local is_current_reveal = Game.current_reveal_payline == payline and Game.win_reveal_active

        -- Enhanced glow for winning paylines (using synced pulse)
        local glow_intensity, glow_pulse_mod, line_alpha

        if is_current_reveal then
            -- Currently revealing - maximum emphasis with synced fast pulse
            glow_intensity = 1.5
            glow_pulse_mod = 0.7 + math.sin(time * 15) * 0.3
            line_alpha = 1.0
        elseif is_winner then
            if Game.win_reveal_active then
                -- Already revealed but not current - show dimmed but synced
                glow_intensity = 0.5
                glow_pulse_mod = sync_pulse * 0.8
                line_alpha = 0.6
            else
                -- Normal winner display (after reveal complete) - synced glow
                glow_intensity = 1.0
                glow_pulse_mod = sync_pulse
                line_alpha = 1.0
            end
        else
            -- Non-winning payline - subtle synced pulse
            glow_intensity = 0.3
            glow_pulse_mod = sync_pulse * 0.5
            line_alpha = 0.4 + sync_pulse * 0.2
        end

        -- Get payout for this payline if it's a winner
        local payline_score = Game.payline_scores[payline]

        if type(payline) == "string" then
            -- Diagonal paylines - draw lines connecting reel centers diagonally
            local points = {}
            local max_offset = math.floor(num_rows / 2)
            for i = 1, num_reels do
                local rx = reel_start_x + (i-1) * (reel_width + reel_spacing) + reel_width / 2

                -- Interpolate offset across reels using full row range
                local t = (i - 1) / (num_reels - 1)
                local offset
                if payline == "diag_down" then
                    -- Top-left (-max) to bottom-right (+max)
                    offset = math.floor(-max_offset + t * max_offset * 2 + 0.5)
                else -- diag_up
                    -- Bottom-left (+max) to top-right (-max)
                    offset = math.floor(max_offset - t * max_offset * 2 + 0.5)
                end
                offset = math.max(-max_offset, math.min(max_offset, offset))

                local ry = get_row_y(offset)
                table.insert(points, rx)
                table.insert(points, ry)
            end

            -- Draw glow layers
            local glow_width_mult = is_current_reveal and 8 or (is_winner and 6 or 4)
            for g = 4, 1, -1 do
                love.graphics.setColor(line_color[1], line_color[2], line_color[3], 0.15 * glow_intensity * glow_pulse_mod)
                love.graphics.setLineWidth(4 + g * glow_width_mult)
                love.graphics.line(unpack(points))
            end

            -- Main diagonal line
            local main_line_width = is_current_reveal and 6 or (is_winner and 4 or 2)
            love.graphics.setColor(line_color[1], line_color[2], line_color[3], line_alpha)
            love.graphics.setLineWidth(main_line_width)
            love.graphics.line(unpack(points))

            -- Show payout on winning diagonal paylines (right upper edge)
            if (is_current_reveal or is_winner) and payline_score then
                local label_size = is_current_reveal and 18 or 14
                local label_alpha = is_current_reveal and 1.0 or glow_pulse_mod

                -- Position at right upper edge of the diagonal
                local label_x = reel_container_x + reel_container_w - 70
                local label_y = payline == "diag_down" and get_row_y(-1) - 25 or get_row_y(-1) - 25

                -- Glow behind text
                for g = 3, 1, -1 do
                    love.graphics.setColor(line_color[1], line_color[2], line_color[3], 0.3 * label_alpha)
                    love.graphics.setFont(UI.get_font(label_size, true))
                    love.graphics.print("+" .. payline_score, label_x + g, label_y + g)
                end

                love.graphics.setColor(1, 1, 1, label_alpha)
                love.graphics.setFont(UI.get_font(label_size, true))
                love.graphics.print("+" .. payline_score, label_x, label_y)
            end
        else
            -- Horizontal paylines
            local line_y = get_row_y(payline)

            local glow_width_mult = is_current_reveal and 8 or (is_winner and 6 or 4)
            for g = 4, 1, -1 do
                love.graphics.setColor(line_color[1], line_color[2], line_color[3], 0.15 * glow_intensity * glow_pulse_mod)
                love.graphics.setLineWidth(4 + g * glow_width_mult)
                love.graphics.line(reel_container_x + 15, line_y, reel_container_x + reel_container_w - 15, line_y)
            end

            -- Main line
            local main_line_width = is_current_reveal and 6 or (is_winner and 4 or 2)
            love.graphics.setColor(line_color[1], line_color[2], line_color[3], line_alpha)
            love.graphics.setLineWidth(main_line_width)
            love.graphics.line(reel_container_x + 15, line_y, reel_container_x + reel_container_w - 15, line_y)

            -- Arrows for horizontal paylines
            local arrow_size = is_current_reveal and 22 or (is_winner and 18 or 12)
            love.graphics.setColor(line_color[1], line_color[2], line_color[3], line_alpha)
            love.graphics.polygon("fill",
                reel_container_x + 8, line_y,
                reel_container_x + 8 + arrow_size, line_y - arrow_size * 0.8,
                reel_container_x + 8 + arrow_size, line_y + arrow_size * 0.8)
            love.graphics.polygon("fill",
                reel_container_x + reel_container_w - 8, line_y,
                reel_container_x + reel_container_w - 8 - arrow_size, line_y - arrow_size * 0.8,
                reel_container_x + reel_container_w - 8 - arrow_size, line_y + arrow_size * 0.8)

            -- Show payout on winning horizontal paylines (right upper edge)
            if (is_current_reveal or is_winner) and payline_score then
                local label_size = is_current_reveal and 18 or 14
                local label_alpha = is_current_reveal and 1.0 or glow_pulse_mod

                -- Position at right upper edge
                local label_x = reel_container_x + reel_container_w - 70
                local label_y = line_y - 25

                -- Glow behind text
                for g = 3, 1, -1 do
                    love.graphics.setColor(line_color[1], line_color[2], line_color[3], 0.3 * label_alpha)
                    love.graphics.setFont(UI.get_font(label_size, true))
                    love.graphics.print("+" .. payline_score, label_x + g, label_y + g)
                end

                love.graphics.setColor(1, 1, 1, label_alpha)
                love.graphics.setFont(UI.get_font(label_size, true))
                love.graphics.print("+" .. payline_score, label_x, label_y)
            end
        end
    end

    -- Draw CRT curve overlay on top
    PlayScreen.draw_crt_curve_overlay(reel_container_x, reel_container_y, reel_container_w, reel_container_h)

    -- Reset state
    love.graphics.setLineWidth(1)
end

function PlayScreen.draw_crt_bezel(x, y, w, h)
    -- Outer dark bezel frame
    local bezel = 10
    love.graphics.setColor(0.04, 0.04, 0.06, 1)
    love.graphics.rectangle("fill", x - bezel, y - bezel, w + bezel*2, h + bezel*2, 6, 6)

    -- Metallic edge highlight (top-left)
    love.graphics.setColor(0.15, 0.15, 0.2, 1)
    love.graphics.setLineWidth(2)
    love.graphics.line(x - bezel + 2, y - bezel + 2, x + w + bezel - 2, y - bezel + 2)
    love.graphics.line(x - bezel + 2, y - bezel + 2, x - bezel + 2, y + h + bezel - 2)

    -- Shadow edge (bottom-right)
    love.graphics.setColor(0.01, 0.01, 0.02, 1)
    love.graphics.line(x + w + bezel - 2, y - bezel + 2, x + w + bezel - 2, y + h + bezel - 2)
    love.graphics.line(x - bezel + 2, y + h + bezel - 2, x + w + bezel - 2, y + h + bezel - 2)

    -- Inner shadow
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", x - 3, y - 3, w + 6, h + 6, 2, 2)
end

-- CRT curve overlay effect
function PlayScreen.draw_crt_curve_overlay(x, y, w, h)
    -- Curved corner shadows (simulates barrel distortion)
    local corner_size = 50
    for i = 0, corner_size do
        local curve = (1 - (i / corner_size)) ^ 2  -- Quadratic falloff for curve
        local alpha = curve * 0.5

        -- Top-left corner curve
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.rectangle("fill", x, y + i, corner_size - i * 0.8, 1)
        love.graphics.rectangle("fill", x + i, y, 1, corner_size - i * 0.8)

        -- Top-right corner curve
        love.graphics.rectangle("fill", x + w - (corner_size - i * 0.8), y + i, corner_size - i * 0.8, 1)
        love.graphics.rectangle("fill", x + w - i - 1, y, 1, corner_size - i * 0.8)

        -- Bottom-left corner curve
        love.graphics.rectangle("fill", x, y + h - i - 1, corner_size - i * 0.8, 1)
        love.graphics.rectangle("fill", x + i, y + h - (corner_size - i * 0.8), 1, corner_size - i * 0.8)

        -- Bottom-right corner curve
        love.graphics.rectangle("fill", x + w - (corner_size - i * 0.8), y + h - i - 1, corner_size - i * 0.8, 1)
        love.graphics.rectangle("fill", x + w - i - 1, y + h - (corner_size - i * 0.8), 1, corner_size - i * 0.8)
    end

    -- Edge darkening (top/bottom) - curved falloff
    for i = 0, 25 do
        local curve = (1 - (i / 25)) ^ 1.5
        local alpha = curve * 0.18
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.rectangle("fill", x + 30, y + i, w - 60, 1)
        love.graphics.rectangle("fill", x + 30, y + h - i - 1, w - 60, 1)
    end

    -- Edge darkening (left/right) - curved falloff
    for i = 0, 20 do
        local curve = (1 - (i / 20)) ^ 1.5
        local alpha = curve * 0.15
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.rectangle("fill", x + i, y + 30, 1, h - 60)
        love.graphics.rectangle("fill", x + w - i - 1, y + 30, 1, h - 60)
    end

    -- Glass reflection highlight (curved)
    love.graphics.setColor(1, 1, 1, 0.04)
    love.graphics.ellipse("fill", x + w * 0.28, y + h * 0.22, w * 0.22, h * 0.1)

    -- Scanlines
    love.graphics.setColor(0, 0, 0, 0.035)
    for sy = y, y + h, 3 do
        love.graphics.rectangle("fill", x, sy, w, 1)
    end

    -- Inner curved border glow
    love.graphics.setColor(Colors.cyan[1], Colors.cyan[2], Colors.cyan[3], 0.05)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x + 3, y + 3, w - 6, h - 6, 8, 8)
end

-- Draw reel with scissor clipping (original fixed width)
function PlayScreen.draw_reel(reel, x, y, reel_index)
    PlayScreen.draw_reel_dynamic(reel, x, y, reel_index, Config.REEL_WIDTH)
end

-- Draw reel with dynamic width
function PlayScreen.draw_reel_dynamic(reel, x, y, reel_index, reel_width)
    -- Calculate reel height based on visible rows
    local num_rows = Game.num_rows or 3
    local reel_height = num_rows * Config.SYMBOL_HEIGHT

    -- Reel background
    UI.draw_double_box(x, y, reel_width, reel_height, Colors.reel_bg, Colors.cyan_dim, false)

    -- Use scissor for clipping
    love.graphics.setScissor(x + 2, y + 2, reel_width - 4, reel_height - 4)

    local offset = reel.position % Config.SYMBOL_HEIGHT
    local base_idx = math.floor(reel.position / Config.SYMBOL_HEIGHT)
    local time = love.timer.getTime()

    -- Adjust font size based on reel width
    local icon_font_size = reel_width > 180 and 42 or 32
    local name_font_size = reel_width > 180 and 12 or 10

    -- Calculate row range based on num_rows
    local j_start = -1
    local j_end = num_rows + 1  -- Extra for scrolling buffer

    -- Row offset mapping based on num_rows
    local center_j = math.floor(num_rows / 2)

    for j = j_start, j_end do
        local sym_idx = ((base_idx + j) % #reel.symbols) + 1
        local sym = reel.symbols[sym_idx]
        local sym_y = y + j * Config.SYMBOL_HEIGHT - offset + Config.SYMBOL_HEIGHT * 0.15

        -- Calculate row offset for this symbol position (relative to center)
        local row_offset = j - center_j

        -- Check if this symbol should be lit up (part of winning payline)
        local is_lit = Game.lit_symbols[reel_index] == row_offset and Game.win_reveal_active

        local is_center = (j == center_j)
        local is_visible_row = (j >= 0 and j < num_rows)

        -- Get symbol image
        local sym_image = Game.get_symbol_image(sym.id)

        if is_visible_row and not Game.spinning then
            -- Check if symbol should glow (center always, or lit symbols)
            local should_glow = is_center or is_lit

            if should_glow then
                -- GLOWING SYMBOL - either center or lit up
                local glow_pulse = is_lit and (0.8 + math.sin(time * 12) * 0.2) or (0.7 + math.sin(time * 4 + reel_index) * 0.3)
                local glow_intensity = is_lit and 1.5 or 1.0

                -- Multiple glow layers
                for i = 4, 1, -1 do
                    local glow_alpha = is_lit and 0.2 or 0.08
                    love.graphics.setColor(sym.color[1], sym.color[2], sym.color[3], glow_alpha * glow_pulse * glow_intensity)
                    love.graphics.rectangle("fill", x + 8 - i*4, sym_y - i*4, reel_width - 16 + i*8, Config.SYMBOL_HEIGHT - 10 + i*8, 6, 6)
                end

                -- Symbol box
                local box_brightness = is_lit and 0.3 or 0.15
                love.graphics.setColor(sym.color[1] * box_brightness, sym.color[2] * box_brightness, sym.color[3] * box_brightness, 0.95)
                love.graphics.rectangle("fill", x + 8, sym_y, reel_width - 16, Config.SYMBOL_HEIGHT - 10, 4, 4)

                -- Border glow
                local border_width = is_lit and 4 or 2
                love.graphics.setColor(sym.color[1], sym.color[2], sym.color[3], (is_lit and 1.0 or 0.9) * glow_pulse)
                love.graphics.setLineWidth(border_width)
                love.graphics.rectangle("line", x + 8, sym_y, reel_width - 16, Config.SYMBOL_HEIGHT - 10, 4, 4)

                -- Draw symbol (image or text fallback) - 50% bigger
                if sym_image then
                    -- Calculate image dimensions and centering
                    local img_w, img_h = sym_image:getDimensions()
                    local target_size = math.min(reel_width - 10, Config.SYMBOL_HEIGHT - 10) * 0.9
                    local scale = target_size / math.max(img_w, img_h)
                    local draw_w, draw_h = img_w * scale, img_h * scale
                    local img_x = x + (reel_width - draw_w) / 2
                    local img_y = sym_y + (Config.SYMBOL_HEIGHT - 10 - draw_h) / 2

                    -- Image glow layers (colored)
                    local glow_layers = is_lit and 6 or 4
                    for i = glow_layers, 1, -1 do
                        local glow_alpha = is_lit and 0.3 or 0.15
                        love.graphics.setColor(sym.color[1], sym.color[2], sym.color[3], glow_alpha * glow_pulse)
                        love.graphics.draw(sym_image, img_x - i*2, img_y - i*2, 0, scale * (1 + i*0.02), scale * (1 + i*0.02))
                    end

                    -- Main image with color tint
                    love.graphics.setColor(sym.color[1] * 0.8 + 0.2, sym.color[2] * 0.8 + 0.2, sym.color[3] * 0.8 + 0.2, 1)
                    love.graphics.draw(sym_image, img_x, img_y, 0, scale, scale)

                    -- White highlight overlay (brighter for lit symbols)
                    local white_alpha = is_lit and (0.5 + math.sin(time * 15) * 0.3) or (0.25 * glow_pulse)
                    love.graphics.setBlendMode("add")
                    love.graphics.setColor(1, 1, 1, white_alpha)
                    love.graphics.draw(sym_image, img_x, img_y, 0, scale, scale)
                    love.graphics.setBlendMode("alpha")
                else
                    -- Fallback to text
                    love.graphics.setFont(UI.get_font(icon_font_size, true))
                    local text_glow_layers = is_lit and 6 or 4
                    for i = text_glow_layers, 1, -1 do
                        local text_glow_alpha = is_lit and 0.25 or 0.15
                        love.graphics.setColor(sym.color[1], sym.color[2], sym.color[3], text_glow_alpha * glow_pulse)
                        love.graphics.printf(sym.icon, x + i, sym_y + 18 + i, reel_width, "center")
                        love.graphics.printf(sym.icon, x - i, sym_y + 18 - i, reel_width, "center")
                    end
                    love.graphics.setColor(sym.color)
                    love.graphics.printf(sym.icon, x, sym_y + 18, reel_width, "center")
                    local white_alpha = is_lit and (0.6 + math.sin(time * 15) * 0.3) or (0.4 * glow_pulse)
                    love.graphics.setColor(1, 1, 1, white_alpha)
                    love.graphics.printf(sym.icon, x, sym_y + 18, reel_width, "center")
                end

                -- Symbol name
                love.graphics.setColor(is_lit and Colors.white or Colors.dim)
                love.graphics.setFont(UI.get_font(name_font_size))
                love.graphics.printf(sym.name, x, sym_y + Config.SYMBOL_HEIGHT - 25, reel_width, "center")
            else
                -- Non-center, non-lit symbols (dimmed but visible) - 50% bigger
                if sym_image then
                    local img_w, img_h = sym_image:getDimensions()
                    local target_size = math.min(reel_width - 10, Config.SYMBOL_HEIGHT - 10) * 0.75
                    local scale = target_size / math.max(img_w, img_h)
                    local draw_w, draw_h = img_w * scale, img_h * scale
                    local img_x = x + (reel_width - draw_w) / 2
                    local img_y = sym_y + (Config.SYMBOL_HEIGHT - 10 - draw_h) / 2

                    -- Dimmed image
                    love.graphics.setColor(0.4, 0.4, 0.4, 0.7)
                    love.graphics.draw(sym_image, img_x, img_y, 0, scale, scale)
                else
                    love.graphics.setColor(Colors.dim[1] * 0.6, Colors.dim[2] * 0.6, Colors.dim[3] * 0.6)
                    love.graphics.setFont(UI.get_font(reel_width > 180 and 36 or 28, false))
                    love.graphics.printf(sym.icon, x, sym_y + 25, reel_width, "center")
                end
            end
        else
            -- Symbols outside visible area or spinning (dimmed) - 50% bigger
            if sym_image then
                local img_w, img_h = sym_image:getDimensions()
                local target_size = math.min(reel_width - 10, Config.SYMBOL_HEIGHT - 10) * 0.65
                local scale = target_size / math.max(img_w, img_h)
                local draw_w, draw_h = img_w * scale, img_h * scale
                local img_x = x + (reel_width - draw_w) / 2
                local img_y = sym_y + (Config.SYMBOL_HEIGHT - 10 - draw_h) / 2

                -- Very dimmed during spin
                love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
                love.graphics.draw(sym_image, img_x, img_y, 0, scale, scale)
            else
                love.graphics.setColor(Colors.dim[1] * 0.6, Colors.dim[2] * 0.6, Colors.dim[3] * 0.6)
                love.graphics.setFont(UI.get_font(reel_width > 180 and 36 or 28, false))
                love.graphics.printf(sym.icon, x, sym_y + 25, reel_width, "center")
            end
        end
    end

    love.graphics.setScissor()
    love.graphics.setLineWidth(1)
end

------------------------------------------------------------
-- [D] STATS PANEL - SIMPLIFIED (no paytable)
------------------------------------------------------------
function PlayScreen.draw_stats_panel()
    local r = Config.LAYOUT.stats_panel
    UI.draw_double_box(r.x, r.y, r.w, r.h, Colors.bg_panel, Colors.cyan, true)

    -- Title
    love.graphics.setColor(Colors.cyan)
    love.graphics.rectangle("fill", r.x + 4, r.y + 4, r.w - 8, 32)
    love.graphics.setColor(Colors.black)
    love.graphics.setFont(UI.get_font(18, true))
    love.graphics.printf("GAME STATUS", r.x + 4, r.y + 10, r.w - 8, "center")

    local content_x = r.x + 20
    local content_w = r.w - 40
    local content_y = r.y + 50

    -- CREDITS - Large display with glow
    UI.draw_section_header(content_x, content_y, content_w, "CREDITS")
    content_y = content_y + 30

    local time = love.timer.getTime()
    local credit_glow = 0.7 + math.sin(time * 2) * 0.3

    for i = 2, 1, -1 do
        love.graphics.setColor(Colors.text_gold[1], Colors.text_gold[2], Colors.text_gold[3], 0.2 * credit_glow)
        love.graphics.setFont(UI.get_font(64, true))
        love.graphics.printf(tostring(Game.credits), content_x + i, content_y + i, content_w, "center")
    end
    love.graphics.setColor(Colors.text_gold)
    love.graphics.printf(tostring(Game.credits), content_x, content_y, content_w, "center")

    content_y = content_y + 80

    -- BET and LAST WIN side by side
    local half_w = (content_w - 20) / 2

    love.graphics.setColor(Colors.dim)
    love.graphics.setFont(UI.get_font(14))
    love.graphics.print("BET", content_x, content_y)
    love.graphics.setColor(Colors.highlight)
    love.graphics.setFont(UI.get_font(36, true))
    love.graphics.print(tostring(Game.bet), content_x, content_y + 18)

    love.graphics.setColor(Colors.dim)
    love.graphics.setFont(UI.get_font(14))
    love.graphics.print("LAST WIN", content_x + half_w + 20, content_y)
    love.graphics.setColor(Game.last_win > 0 and Colors.yellow or Colors.dim)
    love.graphics.setFont(UI.get_font(36, true))
    love.graphics.print(tostring(Game.last_win), content_x + half_w + 20, content_y + 18)

    content_y = content_y + 80

    -- JOKERS SECTION
    UI.draw_section_header(content_x, content_y, content_w, "JOKERS (" .. #Game.jokers .. "/" .. Game.max_jokers .. ")")
    content_y = content_y + 30

    if #Game.jokers == 0 then
        love.graphics.setColor(Colors.dim)
        love.graphics.setFont(UI.get_font(14))
        love.graphics.printf("No jokers - visit shop!", content_x, content_y, content_w, "center")
    else
        local card_w = 90
        local card_h = 70
        local cards_per_row = math.floor(content_w / (card_w + 8))
        for i, joker in ipairs(Game.jokers) do
            local col = (i - 1) % cards_per_row
            local row = math.floor((i - 1) / cards_per_row)
            local card_x = content_x + col * (card_w + 8)
            local card_y = content_y + row * (card_h + 8)

            UI.draw_double_box(card_x, card_y, card_w, card_h, Colors.bg2, joker.color, false)

            love.graphics.setColor(joker.color)
            love.graphics.setFont(UI.get_font(20, true))
            love.graphics.printf(joker.icon, card_x, card_y + 12, card_w, "center")

            love.graphics.setColor(Colors.white)
            love.graphics.setFont(UI.get_font(10))
            love.graphics.printf(joker.name:sub(1, 10), card_x + 2, card_y + 40, card_w - 4, "center")

            love.graphics.setColor(Colors.dim)
            love.graphics.setFont(UI.get_font(8))
            love.graphics.printf(joker.effect_short or "", card_x + 2, card_y + 54, card_w - 4, "center")
        end
    end
end

------------------------------------------------------------
-- [E] INFO BAR
------------------------------------------------------------
function PlayScreen.draw_info_bar()
    local r = Config.LAYOUT.info_bar
    UI.draw_double_box(r.x, r.y, r.w, r.h, Colors.bg_panel, Colors.cyan, true)

    -- Message with glow effect
    local time = love.timer.getTime()
    if Game.last_win > 0 then
        local pulse = 0.8 + math.sin(time * 6) * 0.2
        for i = 2, 1, -1 do
            love.graphics.setColor(Colors.yellow[1], Colors.yellow[2], Colors.yellow[3], 0.3 * pulse)
            love.graphics.setFont(UI.get_font(36, true))
            love.graphics.printf(Game.message, r.x + 20 + i, r.y + 8 + i, r.w - 40, "center")
        end
        love.graphics.setColor(Colors.yellow)
    else
        love.graphics.setColor(Colors.white)
    end
    love.graphics.setFont(UI.get_font(36, true))
    love.graphics.printf(Game.message, r.x + 20, r.y + 8, r.w - 40, "center")

    -- Sub message
    love.graphics.setColor(Colors.dim)
    love.graphics.setFont(UI.get_font(16))
    love.graphics.printf(Game.sub_message, r.x + 20, r.y + 50, r.w - 40, "center")
end

------------------------------------------------------------
-- [F] ACTION BAR - WITH ROUND PROGRESS
------------------------------------------------------------
function PlayScreen.draw_action_bar()
    local r = Config.LAYOUT.action_bar
    UI.draw_double_box(r.x, r.y, r.w, r.h, Colors.bg_panel, Colors.cyan, true)

    -- ANTE & ROUND PROGRESS SECTION (top of action bar)
    local progress_y = r.y + 12
    local progress_w = r.w - 40
    local progress_x = r.x + 20

    -- Ante and Round info (left side)
    love.graphics.setColor(Colors.gold)
    love.graphics.setFont(UI.get_font(18, true))
    love.graphics.print("ANTE " .. Game.ante, progress_x, progress_y)

    love.graphics.setColor(Colors.cyan)
    love.graphics.print("ROUND " .. Game.round_in_ante .. "/" .. Config.ROUNDS_PER_ANTE, progress_x + 100, progress_y)

    -- Target (center)
    love.graphics.setColor(Colors.white)
    love.graphics.setFont(UI.get_font(16, true))
    love.graphics.printf("TARGET: " .. Game.round_target, progress_x, progress_y, progress_w, "center")

    -- Spins remaining (right side)
    local spins_left = Game.spins_per_round - Game.spins_this_round
    love.graphics.setColor(spins_left <= 2 and Colors.red or Colors.win)
    love.graphics.setFont(UI.get_font(16, true))
    love.graphics.printf("SPINS: " .. spins_left .. "/" .. Game.spins_per_round, progress_x, progress_y, progress_w, "right")

    -- Progress bar
    local bar_y = progress_y + 25
    local bar_h = 28
    love.graphics.setColor(Colors.bg)
    love.graphics.rectangle("fill", progress_x, bar_y, progress_w, bar_h)
    love.graphics.setColor(Colors.cyan_dim)
    love.graphics.rectangle("line", progress_x, bar_y, progress_w, bar_h)

    local progress = math.min(Game.credits / Game.round_target, 1)
    if progress > 0 then
        local fill_w = (progress_w - 4) * progress
        -- Gradient fill
        for i = 0, fill_w, 2 do
            local t = i / progress_w
            local r_col = Colors.highlight[1] * (1-t) + Colors.win[1] * t
            local g_col = Colors.highlight[2] * (1-t) + Colors.win[2] * t
            local b_col = Colors.highlight[3] * (1-t) + Colors.win[3] * t
            love.graphics.setColor(r_col, g_col, b_col)
            love.graphics.rectangle("fill", progress_x + 2 + i, bar_y + 2, 2, bar_h - 4)
        end
    end

    -- Progress text
    love.graphics.setColor(Colors.white)
    love.graphics.setFont(UI.get_font(14, true))
    love.graphics.printf(Game.credits .. " / " .. Game.round_target .. " (" .. math.floor(progress * 100) .. "%)", progress_x, bar_y + 6, progress_w, "center")

    -- Draw buttons (handled by UI system)
    for _, btn in ipairs(UI.get_visible_buttons()) do
        if btn.id == "fast_forward" then
            -- Special drawing for fast forward toggle
            local is_active = Game.fast_forward
            local bg = is_active and Colors.highlight or (btn.hover and Colors.button_hover or Colors.button)
            local border = is_active and Colors.yellow or (btn.hover and Colors.cyan or Colors.cyan_dim)
            if btn.pressed then bg = Colors.button_press end

            UI.draw_double_box(btn.x, btn.y, btn.w, btn.h, bg, border, false)
            love.graphics.setColor(is_active and Colors.black or Colors.white)
            love.graphics.setFont(UI.get_font(14, true))
            local text = is_active and ">> FAST ON" or "[F] FAST"
            love.graphics.printf(text, btn.x, btn.y + btn.h/2 - 7, btn.w, "center")
        elseif btn.id ~= "crt_up" and btn.id ~= "crt_down" then
            UI.draw_action_button(btn)
        else
            UI.draw_small_button(btn)
        end
    end

    -- Controls hint
    love.graphics.setColor(Colors.dim)
    love.graphics.setFont(UI.get_font(12))
    love.graphics.printf("[SPACE] Spin  |  [UP/DOWN] Bet  |  [J] Jokers  |  [F] Fast  |  [P] Paytable  |  [LEFT/RIGHT] CRT", r.x, r.y + r.h - 22, r.w, "center")
end

return PlayScreen
