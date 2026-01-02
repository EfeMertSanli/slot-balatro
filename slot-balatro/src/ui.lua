------------------------------------------------------------
-- UI MODULE
-- Drawing helper functions, buttons, and UI components
------------------------------------------------------------

local Colors = require("src.colors")
local Config = require("src.config")

local UI = {}

-- Sound module (lazy loaded to avoid circular dependency)
local Sound = nil
local function get_sound()
    if not Sound then
        Sound = require("src.sound")
    end
    return Sound
end

------------------------------------------------------------
-- FONTS
------------------------------------------------------------
local fonts = {}
local font_paths = {
    regular = "PixelMplus-20130602/PixelMplus12-Regular.ttf",
    bold = "PixelMplus-20130602/PixelMplus12-Bold.ttf",
}

function UI.load_fonts()
    local sizes = {10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 32, 36, 42, 48, 64, 72}
    for _, size in ipairs(sizes) do
        fonts[size] = {
            regular = love.graphics.newFont(font_paths.regular, size),
            bold = love.graphics.newFont(font_paths.bold, size),
        }
    end
end

function UI.get_font(size, bold)
    local font_size = fonts[size]
    if not font_size then
        -- Fallback to closest available size
        local closest = 16
        for s, _ in pairs(fonts) do
            if math.abs(s - size) < math.abs(closest - size) then
                closest = s
            end
        end
        font_size = fonts[closest]
    end
    return bold and font_size.bold or font_size.regular
end

------------------------------------------------------------
-- BOX DRAWING FUNCTIONS
------------------------------------------------------------
function UI.draw_rigid_box(x, y, w, h, fill_color, border_color, border_width)
    -- Fill
    love.graphics.setColor(fill_color)
    love.graphics.rectangle("fill", x, y, w, h)

    -- Outer border
    love.graphics.setColor(border_color)
    love.graphics.setLineWidth(border_width)
    love.graphics.rectangle("line", x, y, w, h)

    -- Inner highlight (top-left)
    love.graphics.setColor(border_color[1] + 0.2, border_color[2] + 0.2, border_color[3] + 0.2, 0.5)
    love.graphics.setLineWidth(1)
    love.graphics.line(x + border_width, y + border_width, x + w - border_width, y + border_width)
    love.graphics.line(x + border_width, y + border_width, x + border_width, y + h - border_width)

    -- Inner shadow (bottom-right)
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.line(x + w - border_width, y + border_width, x + w - border_width, y + h - border_width)
    love.graphics.line(x + border_width, y + h - border_width, x + w - border_width, y + h - border_width)
end

function UI.draw_neon_box(x, y, w, h, fill_color, border_color, border_width)
    -- Neon glow layers
    for i = 3, 1, -1 do
        love.graphics.setColor(border_color[1], border_color[2], border_color[3], 0.15)
        love.graphics.setLineWidth(border_width + i * 4)
        love.graphics.rectangle("line", x - i, y - i, w + i*2, h + i*2, 3, 3)
    end

    -- Fill
    love.graphics.setColor(fill_color)
    love.graphics.rectangle("fill", x, y, w, h)

    -- Main border (bright)
    love.graphics.setColor(border_color)
    love.graphics.setLineWidth(border_width)
    love.graphics.rectangle("line", x, y, w, h)

    -- Inner white highlight for neon effect
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.setLineWidth(1)
    love.graphics.line(x + border_width, y + border_width, x + w - border_width, y + border_width)
    love.graphics.line(x + border_width, y + border_width, x + border_width, y + h - border_width)
end

function UI.draw_double_box(x, y, w, h, fill_color, border_color, with_glow)
    -- PC-98 style double-line box
    if with_glow then
        for i = 2, 1, -1 do
            love.graphics.setColor(border_color[1], border_color[2], border_color[3], 0.1)
            love.graphics.setLineWidth(i * 3)
            love.graphics.rectangle("line", x - i, y - i, w + i*2, h + i*2)
        end
    end

    -- Fill
    love.graphics.setColor(fill_color)
    love.graphics.rectangle("fill", x, y, w, h)

    -- Outer border
    love.graphics.setColor(border_color)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h)

    -- Inner border (3px inset)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x + 4, y + 4, w - 8, h - 8)
end

function UI.draw_panel(x, y, w, h, title)
    UI.draw_double_box(x, y, w, h, Colors.bg_panel, Colors.cyan, true)

    if title then
        love.graphics.setColor(Colors.cyan)
        love.graphics.rectangle("fill", x + 4, y + 4, w - 8, 24)
        love.graphics.setColor(Colors.black)
        love.graphics.setFont(UI.get_font(16, true))
        love.graphics.printf(title, x + 4, y + 7, w - 8, "center")
    end
end

function UI.draw_section_header(x, y, w, text)
    love.graphics.setColor(Colors.cyan_dim)
    love.graphics.setLineWidth(1)
    love.graphics.line(x, y + 10, x + 30, y + 10)
    love.graphics.line(x + w - 30, y + 10, x + w, y + 10)

    love.graphics.setColor(Colors.cyan)
    love.graphics.setFont(UI.get_font(14, true))
    love.graphics.printf(text, x, y, w, "center")
end

------------------------------------------------------------
-- ARROW AND DECORATION
------------------------------------------------------------
function UI.draw_arrow(x, y, size, direction, color)
    love.graphics.setColor(color)
    if direction == "right" then
        love.graphics.polygon("fill", x, y - size/2, x + size, y, x, y + size/2)
    elseif direction == "left" then
        love.graphics.polygon("fill", x, y - size/2, x - size, y, x, y + size/2)
    end
end

function UI.draw_corner_decoration(x, y, dx, dy)
    local size = 20
    love.graphics.setColor(Colors.highlight)
    love.graphics.setLineWidth(3)
    love.graphics.line(x, y, x + size * dx, y)
    love.graphics.line(x, y, x, y + size * dy)

    love.graphics.setColor(Colors.gold)
    love.graphics.setLineWidth(1)
    love.graphics.line(x + 5*dx, y + 5*dy, x + (size-5) * dx, y + 5*dy)
    love.graphics.line(x + 5*dx, y + 5*dy, x + 5*dx, y + (size-5) * dy)
end

------------------------------------------------------------
-- BUTTON SYSTEM
------------------------------------------------------------
local buttons = {}
local cached_visible_buttons = {}
local cached_game_state = nil

function UI.create_button(id, x, y, w, h, text, callback, style)
    return {
        id = id,
        x = x, y = y,
        w = w, h = h,
        text = text,
        callback = callback,
        style = style or "normal",
        hover = false,
        pressed = false,
    }
end

function UI.get_buttons()
    return buttons
end

function UI.set_buttons(btns)
    buttons = btns
end

function UI.add_button(btn)
    table.insert(buttons, btn)
end

function UI.clear_buttons()
    buttons = {}
end

function UI.update_visible_buttons(game_state)
    if cached_game_state == game_state then
        return cached_visible_buttons
    end

    cached_game_state = game_state
    cached_visible_buttons = {}

    for _, btn in ipairs(buttons) do
        local show = false
        if btn.id == "crt_up" or btn.id == "crt_down" then
            show = (game_state ~= "jokers")  -- Hide during jokers screen
        elseif game_state == "play" then
            show = btn.id == "spin" or btn.id == "bet_up" or btn.id == "bet_down" or btn.id == "jokers_btn" or btn.id == "paytable" or btn.id == "fast_forward"
        elseif game_state == "shop" then
            show = btn.id:match("^buy_") or btn.id == "reroll" or btn.id == "continue"
        elseif game_state == "jokers" then
            show = false  -- Jokers screen uses its own controls
        end
        if show then
            table.insert(cached_visible_buttons, btn)
        end
    end
    return cached_visible_buttons
end

function UI.get_visible_buttons()
    return cached_visible_buttons
end

function UI.invalidate_button_cache()
    cached_game_state = nil
end

function UI.update_button_hover(mx, my)
    for _, btn in ipairs(cached_visible_buttons) do
        btn.hover = mx >= btn.x and mx <= btn.x + btn.w and
                   my >= btn.y and my <= btn.y + btn.h
    end
end

function UI.handle_button_press(mx, my)
    for _, btn in ipairs(cached_visible_buttons) do
        if btn.hover then
            btn.pressed = true
        end
    end
end

function UI.handle_button_release(mx, my)
    for _, btn in ipairs(cached_visible_buttons) do
        if btn.pressed and btn.hover and btn.callback then
            get_sound().click()  -- Play click sound
            btn.callback()
        end
        btn.pressed = false
    end
end

------------------------------------------------------------
-- BUTTON DRAWING
------------------------------------------------------------
function UI.draw_action_button(btn)
    local bg = Colors.button
    local border = Colors.cyan_dim
    local text_col = Colors.white
    local glow = false

    if btn.style == "primary" then
        border = Colors.highlight
        glow = true
        if btn.hover then
            bg = {0.15, 0.08, 0.25}
        end
    else
        if btn.hover then
            bg = Colors.button_hover
            border = Colors.cyan
        end
    end

    if btn.pressed then
        bg = Colors.button_press
    end

    if glow then
        for i = 2, 1, -1 do
            love.graphics.setColor(border[1], border[2], border[3], 0.15)
            love.graphics.setLineWidth(i * 4)
            love.graphics.rectangle("line", btn.x - i*2, btn.y - i*2, btn.w + i*4, btn.h + i*4)
        end
    end

    UI.draw_double_box(btn.x, btn.y, btn.w, btn.h, bg, border, false)

    love.graphics.setColor(text_col)
    love.graphics.setFont(UI.get_font(btn.style == "primary" and 32 or 24, true))
    love.graphics.printf(btn.text, btn.x, btn.y + btn.h/2 - (btn.style == "primary" and 16 or 12), btn.w, "center")
end

function UI.draw_small_button(btn)
    local bg = btn.hover and Colors.button_hover or Colors.button
    local border = btn.hover and Colors.cyan or Colors.cyan_dim
    if btn.pressed then bg = Colors.button_press end

    UI.draw_double_box(btn.x, btn.y, btn.w, btn.h, bg, border, false)
    love.graphics.setColor(Colors.white)
    love.graphics.setFont(UI.get_font(18, true))
    love.graphics.printf(btn.text, btn.x, btn.y + btn.h/2 - 9, btn.w, "center")
end

return UI
