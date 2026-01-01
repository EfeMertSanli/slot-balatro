------------------------------------------------------------
-- SLOT BALATRO
-- A Balatro-inspired slot machine roguelike
-- PC-98 aesthetic with neon glow effects
------------------------------------------------------------

-- Load modules
local Colors = require("src.colors")
local Config = require("src.config")
local UI = require("src.ui")
local Game = require("src.game")
local Effects = require("src.effects")

-- Load screens
local PlayScreen = require("src.screens.play")
local ShopScreen = require("src.screens.shop")
local JokersScreen = require("src.screens.jokers")
local AnteRewardScreen = require("src.screens.ante_reward")
local GameOverScreen = require("src.screens.game_over")
local RulesScreen = require("src.screens.rules")
local StoryPopup = require("src.screens.story_popup")

------------------------------------------------------------
-- CRT SHADER
------------------------------------------------------------
local crt_shader = nil
local canvas_game = nil
local settings = {
    crt_intensity = 50,
}

local crt_shader_code = [[
    extern vec2 screen_size;
    extern float intensity;
    extern float time;

    // Bayer 4x4 ordered dithering matrix (PC-98 style)
    float bayer4x4(vec2 pos) {
        int x = int(mod(pos.x, 4.0));
        int y = int(mod(pos.y, 4.0));
        int index = x + y * 4;

        // Bayer 4x4 threshold values (0-15 normalized to 0-1)
        if (index == 0) return 0.0 / 16.0;
        if (index == 1) return 8.0 / 16.0;
        if (index == 2) return 2.0 / 16.0;
        if (index == 3) return 10.0 / 16.0;
        if (index == 4) return 12.0 / 16.0;
        if (index == 5) return 4.0 / 16.0;
        if (index == 6) return 14.0 / 16.0;
        if (index == 7) return 6.0 / 16.0;
        if (index == 8) return 3.0 / 16.0;
        if (index == 9) return 11.0 / 16.0;
        if (index == 10) return 1.0 / 16.0;
        if (index == 11) return 9.0 / 16.0;
        if (index == 12) return 15.0 / 16.0;
        if (index == 13) return 7.0 / 16.0;
        if (index == 14) return 13.0 / 16.0;
        return 5.0 / 16.0;
    }

    vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
        vec2 uv = tc;
        vec4 texColor = Texel(tex, uv);

        // Logarithmic intensity scaling (50 = normal, scales up/down from there)
        float logScale = log(1.0 + intensity * 0.19) / log(1.0 + 50.0 * 0.19);

        // Visible scanlines - every 2nd row darker (2x stronger)
        float scanlineY = floor(uv.y * screen_size.y);
        float scanline = mod(scanlineY, 2.0);
        float scanlineStrength = logScale * 0.5;  // 50% darkening on alt rows
        texColor.rgb *= 1.0 - scanline * scanlineStrength;

        // Brightness compensation for scanlines (keeps overall brightness same)
        float scanlineCompensation = 1.0 + scanlineStrength * 0.5;
        texColor.rgb *= scanlineCompensation;

        // Phosphor dot pattern (RGB subpixels) - 2x stronger
        float pixelX = floor(uv.x * screen_size.x);
        float subpixel = mod(pixelX, 3.0);
        float phosphorStrength = logScale * 0.08;
        if (subpixel < 1.0) {
            texColor.r += phosphorStrength;
        } else if (subpixel < 2.0) {
            texColor.g += phosphorStrength;
        } else {
            texColor.b += phosphorStrength;
        }

        // Ordered dithering (Bayer 4x4 pattern - classic PC-98 look)
        vec2 pixelPos = floor(uv * screen_size);
        float bayerValue = bayer4x4(pixelPos);
        float ditherStrength = logScale * 0.08;
        texColor.rgb += (bayerValue - 0.5) * ditherStrength;

        // Vignette (darkens edges) - 2x stronger with compensation
        vec2 center = uv - 0.5;
        float vignetteStrength = dot(center, center) * 1.0 * logScale;
        float vignette = 1.0 - vignetteStrength;
        float vignetteCompensation = 1.0 + vignetteStrength * 0.3;
        texColor.rgb *= vignette * vignetteCompensation;

        // Brightness flicker - reduces as filter strength increases
        float flickerStrength = 0.02 / (0.5 + logScale);
        float flicker = 1.0 - sin(time * 50.0) * flickerStrength;
        texColor.rgb *= flicker;

        return texColor * color;
    }
]]

local function update_crt_settings()
    if crt_shader then
        crt_shader:send("intensity", settings.crt_intensity)
    end
end

------------------------------------------------------------
-- BUTTON CREATION
------------------------------------------------------------
local function create_all_buttons()
    UI.clear_buttons()

    -- Play screen buttons - positioned in action bar
    local action = Config.LAYOUT.action_bar
    local play_btn_y = action.y + 70  -- Below progress bar
    local btn_h = 70

    local spin_w = 280
    local small_btn_w = 100
    local shop_btn_w = 140
    local paytable_btn_w = 140
    local spacing = 25

    local total_width = small_btn_w + spacing + spin_w + spacing + small_btn_w + spacing + shop_btn_w + spacing + paytable_btn_w
    local start_x = action.x + (action.w - total_width) / 2

    UI.add_button(UI.create_button("bet_down", start_x, play_btn_y, small_btn_w, btn_h, "-", function()
        if not Game.spinning then
            local min_bet = Game.get_min_bet()
            Game.bet = math.max(Game.bet - 1, min_bet)
        end
    end, "normal"))

    UI.add_button(UI.create_button("spin", start_x + small_btn_w + spacing, play_btn_y, spin_w, btn_h, "SPIN", function()
        if not Game.spinning and Game.state == "play" then
            if Game.spins_this_round >= Game.spins_per_round then
                Game.end_round()
                UI.invalidate_button_cache()
            else
                Game.spin()
            end
        end
    end, "primary"))

    UI.add_button(UI.create_button("bet_up", start_x + small_btn_w + spacing + spin_w + spacing, play_btn_y, small_btn_w, btn_h, "+", function()
        if not Game.spinning then
            Game.bet = math.min(Game.bet + 1, Game.credits, Game.max_bet)
        end
    end, "normal"))

    UI.add_button(UI.create_button("jokers_btn", start_x + small_btn_w + spacing + spin_w + spacing + small_btn_w + spacing, play_btn_y, shop_btn_w, btn_h, "JOKERS", function()
        if Game.state == "play" then
            Game.state = "jokers"
            JokersScreen.reset()
            UI.invalidate_button_cache()
        end
    end, "normal"))

    -- Paytable/Rules button (in action bar, next to jokers)
    UI.add_button(UI.create_button("paytable", start_x + small_btn_w + spacing + spin_w + spacing + small_btn_w + spacing + shop_btn_w + spacing, play_btn_y, paytable_btn_w, btn_h, "RULES", function()
        RulesScreen.toggle()
    end, "normal"))

    -- Fast forward button (right side of action bar)
    local ff_btn_y = play_btn_y + btn_h + 10
    local ff_btn_w = 180
    local ff_btn_x = action.x + action.w - ff_btn_w - 20
    UI.add_button(UI.create_button("fast_forward", ff_btn_x, ff_btn_y, ff_btn_w, 35, ">> FAST", function()
        Game.toggle_fast_forward()
    end, "small"))

    -- CRT buttons (in title bar)
    local title = Config.LAYOUT.title_bar
    UI.add_button(UI.create_button("crt_down", Config.SCREEN_W - 140, title.y + 20, 32, 32, "-", function()
        settings.crt_intensity = math.max(0, settings.crt_intensity - 10)
        update_crt_settings()
    end, "small"))

    UI.add_button(UI.create_button("crt_up", Config.SCREEN_W - 55, title.y + 20, 32, 32, "+", function()
        settings.crt_intensity = math.min(100, settings.crt_intensity + 10)
        update_crt_settings()
    end, "small"))

    -- Shop buttons
    local shop_btn_w = 250
    local shop_btn_h = 60
    local center_x = Config.SCREEN_W / 2

    UI.add_button(UI.create_button("reroll", center_x - shop_btn_w - 20, 860, shop_btn_w, shop_btn_h, "REROLL", function()
        Game.reroll_shop()
    end, "normal"))

    UI.add_button(UI.create_button("continue", center_x + 20, 860, shop_btn_w, shop_btn_h, "CONTINUE", function()
        Game.state = "play"
        Game.start_round()
        UI.invalidate_button_cache()
    end, "primary"))

    -- Shop buy buttons for jokers (positioned over the card buy areas)
    local card_w = 340
    local card_spacing = 40
    local total_cards_w = 3 * card_w + 2 * card_spacing
    local cards_start_x = Config.SCREEN_W/2 - total_cards_w/2

    for i = 1, 3 do
        local card_x = cards_start_x + (i-1) * (card_w + card_spacing)
        local btn_x = card_x + card_w/2 - 80
        local btn_y = 200 + 320  -- card_y + button offset within card
        UI.add_button(UI.create_button("buy_joker_" .. i, btn_x, btn_y, 160, 45, "BUY", function()
            if Game.buy_joker(i) then
                UI.invalidate_button_cache()
            end
        end, "normal"))
    end

    -- Shop buy buttons for slot changers
    local changer_card_w = 280
    local changer_spacing = 30
    for i = 1, 2 do
        local total_changers_w = 2 * changer_card_w + changer_spacing
        local changers_start_x = Config.SCREEN_W/2 - total_changers_w/2
        local card_x = changers_start_x + (i-1) * (changer_card_w + changer_spacing)
        local btn_x = card_x + changer_card_w/2
        local btn_y = 620 + 70  -- section_y + 30 + 70
        UI.add_button(UI.create_button("buy_changer_" .. i, btn_x, btn_y, changer_card_w/2, 25, "BUY", function()
            if Game.buy_slot_changer(i) then
                UI.invalidate_button_cache()
            end
        end, "small"))
    end
end

------------------------------------------------------------
-- LOVE CALLBACKS
------------------------------------------------------------
function love.load()
    love.window.setTitle("Slot Balatro")
    love.window.setMode(Config.SCREEN_W, Config.SCREEN_H, {
        resizable = false,
        vsync = 1,
        minwidth = 800,
        minheight = 600,
    })

    -- Load fonts
    UI.load_fonts()

    -- Create canvas and shader
    canvas_game = love.graphics.newCanvas(Config.SCREEN_W, Config.SCREEN_H)
    crt_shader = love.graphics.newShader(crt_shader_code)
    crt_shader:send("screen_size", {Config.SCREEN_W, Config.SCREEN_H})
    update_crt_settings()

    -- Load symbol images
    Game.load_symbol_images()

    -- Load Luna mascot images
    Game.load_luna_images()

    -- Initialize persistence (load saved progress)
    Game.init_persistence()

    -- Initialize game
    Game.init_reels()
    Game.start_round()

    -- Create buttons
    create_all_buttons()
    UI.update_visible_buttons(Game.state)
end

function love.update(dt)
    -- Update game
    Game.update(dt)

    -- Update shader time
    if crt_shader then
        crt_shader:send("time", love.timer.getTime())
    end

    -- Update visible buttons if state changed
    UI.update_visible_buttons(Game.state)

    -- Update button hover states
    local mx, my = love.mouse.getPosition()
    local shake_x, shake_y = Effects.get_screen_shake()
    UI.update_button_hover(mx - shake_x, my - shake_y)
end

function love.draw()
    -- Get screen shake offset
    local shake_x, shake_y = Effects.get_screen_shake()

    -- Draw to canvas
    love.graphics.setCanvas(canvas_game)
    love.graphics.clear(Colors.bg)
    love.graphics.push()
    love.graphics.translate(shake_x, shake_y)

    -- Draw current screen
    if Game.state == "play" then
        PlayScreen.draw()
    elseif Game.state == "shop" then
        ShopScreen.draw()
    elseif Game.state == "jokers" then
        PlayScreen.draw()  -- Draw play screen in background
        JokersScreen.draw()
    elseif Game.state == "ante_reward" then
        PlayScreen.draw()  -- Draw play screen in background
        AnteRewardScreen.draw()
    elseif Game.state == "game_over" then
        PlayScreen.draw()  -- Draw play screen in background
        GameOverScreen.draw()
    end

    -- Draw story popup overlay (after ante completion)
    if Game.is_story_popup_active() then
        StoryPopup.draw()
    end

    -- Draw rules overlay on top of any screen
    if RulesScreen.is_visible() then
        RulesScreen.draw()
    end

    -- Draw effects on top
    Effects.draw_particles()
    Effects.draw_floating_texts(UI.get_font)

    -- Win flash overlay
    if Game.win_flash > 0 then
        love.graphics.setColor(Colors.yellow[1], Colors.yellow[2], Colors.yellow[3], Game.win_flash * 0.15)
        love.graphics.rectangle("fill", 0, 0, Config.SCREEN_W, Config.SCREEN_H)
    end

    love.graphics.pop()
    love.graphics.setCanvas()

    -- Draw canvas with CRT shader
    love.graphics.setColor(1, 1, 1, 1)
    if settings.crt_intensity > 0 and crt_shader then
        love.graphics.setShader(crt_shader)
    end
    love.graphics.draw(canvas_game, 0, 0)
    love.graphics.setShader()
end

------------------------------------------------------------
-- INPUT HANDLING
------------------------------------------------------------
function love.keypressed(key)
    -- Handle story popup first (highest priority modal)
    if Game.is_story_popup_active() then
        if StoryPopup.keypressed(key) then
            return
        end
    end

    -- Handle rules screen (it's an overlay on any screen)
    if RulesScreen.is_visible() then
        if RulesScreen.keypressed(key) then
            return
        end
    end

    -- Handle overlay screens first
    if Game.state == "jokers" then
        if JokersScreen.keypressed(key) then
            UI.invalidate_button_cache()
            return
        end
    elseif Game.state == "ante_reward" then
        if AnteRewardScreen.keypressed(key) then
            UI.invalidate_button_cache()
            return
        end
    elseif Game.state == "game_over" then
        if GameOverScreen.keypressed(key) then
            UI.invalidate_button_cache()
            return
        end
    end

    if key == "escape" then
        if Game.state == "jokers" then
            Game.state = "play"
            JokersScreen.reset()
            UI.invalidate_button_cache()
        elseif Game.state == "game_over" then
            love.event.quit()
        else
            love.event.quit()
        end
    elseif key == "space" then
        if Game.state == "play" then
            if Game.spins_this_round >= Game.spins_per_round then
                Game.end_round()
                UI.invalidate_button_cache()
            else
                Game.spin()
            end
        elseif Game.state == "shop" then
            Game.state = "play"
            Game.start_round()
            UI.invalidate_button_cache()
        end
    elseif key == "up" then
        if Game.state == "play" and not Game.spinning then
            Game.bet = math.min(Game.bet + 1, Game.credits, Game.max_bet)
        end
    elseif key == "down" then
        if Game.state == "play" and not Game.spinning then
            Game.bet = math.max(Game.bet - 1, 1)
        end
    elseif key == "left" then
        settings.crt_intensity = math.max(0, settings.crt_intensity - 10)
        update_crt_settings()
    elseif key == "right" then
        settings.crt_intensity = math.min(100, settings.crt_intensity + 10)
        update_crt_settings()
    elseif key == "r" then
        if Game.state == "shop" then
            Game.reroll_shop()
        end
    elseif key == "1" or key == "2" or key == "3" then
        if Game.state == "shop" then
            Game.buy_joker(tonumber(key))
        end
    elseif key == "4" or key == "5" then
        if Game.state == "shop" then
            Game.buy_slot_changer(tonumber(key) - 3)
        end
    elseif key == "p" then
        RulesScreen.toggle()
    elseif key == "j" then
        if Game.state == "play" then
            Game.state = "jokers"
            JokersScreen.reset()
            UI.invalidate_button_cache()
        elseif Game.state == "jokers" then
            Game.state = "play"
            JokersScreen.reset()
            UI.invalidate_button_cache()
        end
    elseif key == "f" then
        if Game.state == "play" then
            Game.toggle_fast_forward()
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        -- Handle story popup first (highest priority modal)
        if Game.is_story_popup_active() then
            if StoryPopup.mousepressed(x, y, button) then
                return
            end
        end

        -- Handle rules screen (it's an overlay on any screen)
        if RulesScreen.is_visible() then
            if RulesScreen.mousepressed(x, y, button) then
                return
            end
        end

        if Game.state == "jokers" then
            JokersScreen.mousepressed(x, y, button)
        elseif Game.state == "ante_reward" then
            if AnteRewardScreen.mousepressed(x, y, button) then
                UI.invalidate_button_cache()
            end
        elseif Game.state == "game_over" then
            if GameOverScreen.mousepressed(x, y, button) then
                UI.invalidate_button_cache()
            end
        else
            UI.handle_button_press(x, y)
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        UI.handle_button_release(x, y)
    end
end
