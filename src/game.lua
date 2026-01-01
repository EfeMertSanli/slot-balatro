------------------------------------------------------------
-- GAME MODULE
-- Game state, reels, spinning logic, and win detection
------------------------------------------------------------

local Config = require("src.config")
local Colors = require("src.colors")
local Effects = require("src.effects")

-- New modular data imports
local Symbols = require("src.data.symbols")
local JokerDefs = require("src.data.joker_defs")
local BuffDefs = require("src.data.buff_defs")
local SlotChangerDefs = require("src.data.slot_changers")
local Dialogue = require("src.data.dialogue")

-- Core modules
local State = require("src.core.state")
local Events = require("src.core.events")

-- System modules
local ReelsSystem = require("src.systems.reels")
local PaylinesSystem = require("src.systems.paylines")
local ProgressionSystem = require("src.systems.progression")
local LunaSystem = require("src.systems.luna")
local BossModifiers = require("src.systems.boss_modifiers")
local Combo = require("src.systems.combo")
local ConsumablesSystem = require("src.systems.consumables")
local ConsumableDefs = require("src.data.consumable_defs")
local SpecialEvents = require("src.systems.special_events")
local LunaAffinity = require("src.systems.luna_affinity")
local Meta = require("src.systems.meta")
local Story = require("src.systems.story")
local Save = require("src.core.save")

local Game = {}

------------------------------------------------------------
-- GAME STATE
------------------------------------------------------------
Game.state = "play"  -- play, shop, jokers, ante_reward, game_over
Game.credits = Config.STARTING_CREDITS
Game.bet = Config.STARTING_BET
Game.max_bet = Config.MAX_BET
Game.last_win = 0
Game.last_win_type = ""  -- "pair" or "triple" or ""
Game.message = "GOOD LUCK!"
Game.sub_message = "Press SPACE to spin"
Game.spinning = false
Game.win_flash = 0

-- Ante & Round tracking (roguelike progression)
Game.ante = 1                      -- Current ante (major milestone)
Game.round_in_ante = 1             -- Current round within ante (1-10)
Game.round = 1                     -- Total rounds played
Game.round_target = 100            -- Current round's credit target
Game.spins_per_round = Config.SPINS_PER_ROUND
Game.spins_this_round = 0
Game.total_spins = 0
Game.highest_credits = Config.STARTING_CREDITS
Game.highest_ante = 1
Game.games_played = 0

-- Permanent buffs (persist across ante, reset on game over for now)
Game.perm_starting_credits = 0
Game.perm_win_bonus = 0
Game.perm_target_reduction = 0
Game.perm_extra_spins = 0
Game.perm_free_reroll = false
Game.perm_symbol_bonus = 0
Game.perm_wild_bonus = 0
Game.perm_shop_discount = 0
Game.perm_payline_bonus = 0

-- Ante reward selection
Game.ante_reward_choices = {}      -- 3 buff choices
Game.selected_ante_reward = 0      -- Selected index (1-3)

-- Jokers
Game.jokers = {}
Game.max_jokers = Config.MAX_JOKERS
Game.shop_items = {}
Game.shop_slot_changers = {}

-- Shop purchase limits (reset each shop visit)
Game.shop_bought_joker = false
Game.shop_bought_changer = false
Game.shop_rerolled = false

-- Slot configuration (modifiable by slot_changers)
Game.num_reels = Config.NUM_REELS
Game.num_rows = 3      -- Visible rows (3 = top/center/bottom, can expand to 5)
Game.num_paylines = 1  -- Start with 1 payline (center)
Game.paylines = {0}    -- Offset from center: 0 = center, -1 = top, 1 = bottom, -2 = far top, 2 = far bottom

-- Slot changers owned
Game.slot_changers = {}
Game.wild_magnet = false  -- Set by Wild Magnet slot changer

-- Winning paylines (for visual feedback)
Game.winning_paylines = {}  -- {offset = true} for each winning payline

-- Sequential win reveal system
Game.win_reveal_active = false      -- Is win reveal sequence active?
Game.win_reveal_queue = {}          -- Ordered list of {payline, score, win_type, symbol}
Game.win_reveal_index = 0           -- Current payline being revealed
Game.win_reveal_timer = 0           -- Timer for current reveal
Game.win_reveal_delay = 0.8         -- Delay between each payline reveal
Game.current_reveal_payline = nil   -- Currently showing payline
Game.lit_symbols = {}               -- {reel_index = row_offset} for symbols to light up
Game.payline_scores = {}            -- {payline = score} for displaying on lines

-- Animation speed control
Game.fast_forward = false           -- Speed up animations
Game.normal_reveal_delay = 0.8
Game.fast_reveal_delay = 0.2

------------------------------------------------------------
-- SYMBOL IMAGES
------------------------------------------------------------
local symbol_images = {}

function Game.load_symbol_images()
    for _, sym in ipairs(Config.SYMBOLS) do
        if sym.image then
            local success, img = pcall(love.graphics.newImage, sym.image)
            if success then
                symbol_images[sym.id] = img
                -- Set filter for crisp pixel art
                img:setFilter("nearest", "nearest")
            else
                print("Warning: Could not load image for " .. sym.id .. ": " .. sym.image)
            end
        end
    end
end

function Game.get_symbol_image(symbol_id)
    return symbol_images[symbol_id]
end

------------------------------------------------------------
-- LUNA MASCOT (delegates to LunaSystem)
------------------------------------------------------------
Game.luna_expression = "idle"
Game.luna_loss_streak = 0

function Game.load_luna_images()
    LunaSystem.load_images("src/assests/")
end

function Game.get_luna_image(expression)
    return LunaSystem.get_image(expression)
end

function Game.get_current_luna_image()
    return LunaSystem.get_current_image()
end

function Game.update_luna_expression()
    -- Pass game state to Luna system
    LunaSystem.update_expression({
        state = Game.state,
        spinning = Game.spinning,
        win_reveal_active = Game.win_reveal_active,
        last_win = Game.last_win,
        credits = Game.credits,
        spins_this_round = Game.spins_this_round,
        spins_per_round = Game.spins_per_round,
    })
    -- Sync back to Game for backward compatibility
    Game.luna_expression = LunaSystem.get_expression()
    Game.luna_loss_streak = LunaSystem.get_loss_streak()
end

------------------------------------------------------------
-- PERSISTENCE
------------------------------------------------------------

function Game.init_persistence()
    -- Register systems with save module
    Save.register("luna_affinity", LunaAffinity)
    Save.register("meta", Meta)
    Save.register("story", Story)

    -- Load existing save
    Save.load()
end

------------------------------------------------------------
-- REELS
------------------------------------------------------------
local reels = {}

function Game.init_reels()
    reels = {}
    for i = 1, Game.num_reels do
        local reel = {
            symbols = {},
            position = 0,
            target_position = 0,
            spinning = false,
            speed = 0,
            stop_time = 0,
        }
        -- Fill with weighted random symbols
        for j = 1, 20 do
            table.insert(reel.symbols, Game.get_weighted_symbol())
        end
        table.insert(reels, reel)
    end
end

-- Add a new reel (called by slot changer)
function Game.add_reel()
    Game.num_reels = Game.num_reels + 1
    local reel = {
        symbols = {},
        position = 0,
        target_position = 0,
        spinning = false,
        speed = 0,
        stop_time = 0,
    }
    for j = 1, 20 do
        table.insert(reel.symbols, Game.get_weighted_symbol())
    end
    table.insert(reels, reel)
end

-- Add a new payline (called by slot changer)
function Game.add_payline(offset)
    Game.num_paylines = Game.num_paylines + 1
    table.insert(Game.paylines, offset)
end

-- Add a diagonal payline
-- "down" = top-left to bottom-right, "up" = bottom-left to top-right
function Game.add_diagonal_payline(direction)
    Game.num_paylines = Game.num_paylines + 1
    -- Store as special string identifier
    table.insert(Game.paylines, "diag_" .. direction)
end

-- Add a new visible row (called by slot changer)
function Game.add_row()
    if Game.num_rows < 5 then
        Game.num_rows = Game.num_rows + 1
    end
end

-- Check if player owns a specific slot changer
function Game.has_slot_changer(id)
    for _, sc in ipairs(Game.slot_changers) do
        if sc.id == id then
            return true
        end
    end
    return false
end

-- Get a weighted random symbol (common symbols appear more often)
function Game.get_weighted_symbol()
    local wild_mult = 1
    if Game.wild_magnet then
        wild_mult = 2  -- Double wild frequency with Wild Magnet
    end

    -- Use weights from Symbols data
    local total = 0
    for _, sym in ipairs(Symbols) do
        local weight = sym.weight or 10
        if sym.wild then
            weight = weight * wild_mult
        end
        total = total + weight
    end

    local roll = math.random() * total
    local cumulative = 0

    for _, sym in ipairs(Symbols) do
        local weight = sym.weight or 10
        if sym.wild then
            weight = weight * wild_mult
        end
        cumulative = cumulative + weight
        if roll <= cumulative then
            return sym
        end
    end

    return Symbols[1]
end

function Game.get_reels()
    return reels
end

------------------------------------------------------------
-- SPIN LOGIC
------------------------------------------------------------
function Game.spin()
    if Game.spinning or Game.credits < Game.bet or Game.win_reveal_active then
        return false
    end

    -- Store pre-spin credits for Rewind Token
    ConsumablesSystem.store_pre_spin_state(Game.credits)

    Game.credits = Game.credits - Game.bet
    Game.spinning = true
    Game.last_win = 0
    Game.last_win_type = ""
    Game.message = "SPINNING..."
    Game.sub_message = ""
    Game.spins_this_round = Game.spins_this_round + 1
    Game.total_spins = Game.total_spins + 1

    -- Check for Wild Card consumable effect
    local force_wild = ConsumablesSystem.is_wild_guaranteed()
    local wild_reel = force_wild and math.random(Game.num_reels) or nil
    if force_wild then
        ConsumablesSystem.clear_wild_guarantee()
    end

    -- Determine if this spin will be a "lucky" spin (higher chance of 3-of-a-kind)
    local lucky_spin = math.random() < 0.25  -- 25% chance of lucky spin
    local lucky_symbol = nil
    if lucky_spin then
        lucky_symbol = Game.get_weighted_symbol()
    end

    -- Start each reel
    for i, reel in ipairs(reels) do
        reel.spinning = true
        reel.speed = Config.SPIN_SPEED
        reel.stop_time = love.timer.getTime() + 0.5 + (i - 1) * 0.3

        -- Randomize symbols for next spin
        for j = 1, #reel.symbols do
            -- Force wild on center row of designated reel (Wild Card consumable)
            if wild_reel == i and j == 2 then
                reel.symbols[j] = Symbols.get_wild()
            elseif lucky_spin and lucky_symbol and math.random() < 0.6 then
                -- 60% chance to place the lucky symbol
                reel.symbols[j] = lucky_symbol
            else
                reel.symbols[j] = Game.get_weighted_symbol()
            end
        end

        -- Set target position
        reel.target_position = reel.position + Config.SYMBOL_HEIGHT * (10 + math.random(5))
    end

    return true
end

function Game.update_reels(dt)
    if not Game.spinning then return end

    local all_stopped = true
    local current_time = love.timer.getTime()

    for i, reel in ipairs(reels) do
        if reel.spinning then
            all_stopped = false

            if current_time >= reel.stop_time then
                -- Decelerate
                reel.speed = reel.speed * Config.SPIN_DECEL

                if reel.speed < 50 then
                    -- Snap to position
                    reel.position = math.floor(reel.position / Config.SYMBOL_HEIGHT + 0.5) * Config.SYMBOL_HEIGHT
                    reel.spinning = false
                    reel.speed = 0
                end
            end

            reel.position = reel.position + reel.speed * dt
        end
    end

    if all_stopped then
        Game.spinning = false
        Game.check_win()
    end
end

------------------------------------------------------------
-- WIN DETECTION
------------------------------------------------------------
function Game.get_symbols_at_offset(offset)
    -- offset: 0 = center, -1 = one above center, 1 = one below center, etc.
    -- Must match the draw logic in play.lua draw_reel_dynamic
    -- center_j = floor(num_rows / 2), so for 3 rows center_j = 1
    -- row_offset = j - center_j, so offset 0 -> j = center_j
    -- Formula: j = center_j + offset, so sym_idx = ((base_idx + center_j + offset) % #symbols) + 1
    local symbols = {}
    local center_j = math.floor(Game.num_rows / 2)
    for i, reel in ipairs(reels) do
        local base_idx = math.floor(reel.position / Config.SYMBOL_HEIGHT)
        local idx = ((base_idx + center_j + offset) % #reel.symbols) + 1
        table.insert(symbols, reel.symbols[idx])
    end
    return symbols
end

-- Get symbols along a diagonal line
-- direction: "down" = top-left to bottom-right, "up" = bottom-left to top-right
function Game.get_diagonal_symbols(direction)
    local symbols = {}
    local num_reels = #reels
    local center_j = math.floor(Game.num_rows / 2)

    -- Calculate max offset based on number of rows
    -- For 3 rows: max offset is 1 (rows -1, 0, 1)
    -- For 5 rows: max offset is 2 (rows -2, -1, 0, 1, 2)
    local max_offset = math.floor(Game.num_rows / 2)

    for i, reel in ipairs(reels) do
        local base_idx = math.floor(reel.position / Config.SYMBOL_HEIGHT)

        -- Interpolate offset across reels: 0 at first reel, 1 at last reel
        local t = (i - 1) / (num_reels - 1)
        local offset

        if direction == "down" then
            -- Top-left (-max) to bottom-right (+max)
            offset = math.floor(-max_offset + t * max_offset * 2 + 0.5)
        else -- "up"
            -- Bottom-left (+max) to top-right (-max)
            offset = math.floor(max_offset - t * max_offset * 2 + 0.5)
        end

        -- Clamp to valid range
        offset = math.max(-max_offset, math.min(max_offset, offset))

        local idx = ((base_idx + center_j + offset) % #reel.symbols) + 1
        table.insert(symbols, reel.symbols[idx])
    end
    return symbols
end

function Game.get_center_symbols()
    return Game.get_symbols_at_offset(0)
end

function Game.check_payline(symbols)
    -- Delegates to PaylinesSystem
    return PaylinesSystem.check_payline(
        symbols,
        Game.num_reels,
        Game.bet,
        Game.perm_symbol_bonus or 0
    )
end

function Game.check_win()
    local total_score = 0
    local best_win_type = ""
    local best_match_count = 0
    local all_symbols = {}

    -- Reset winning paylines and reveal system
    Game.winning_paylines = {}
    Game.win_reveal_queue = {}
    Game.win_reveal_index = 0
    Game.win_reveal_active = false
    Game.current_reveal_payline = nil

    -- Check all paylines and collect wins
    for _, payline in ipairs(Game.paylines) do
        local symbols

        -- Check if payline is diagonal (string) or horizontal offset (number)
        if type(payline) == "string" then
            if payline == "diag_down" then
                symbols = Game.get_diagonal_symbols("down")
            elseif payline == "diag_up" then
                symbols = Game.get_diagonal_symbols("up")
            else
                symbols = Game.get_center_symbols()  -- fallback
            end
        else
            symbols = Game.get_symbols_at_offset(payline)
        end

        local score, win_type, best_symbol, match_count = Game.check_payline(symbols)

        if score > 0 then
            -- Add to reveal queue
            table.insert(Game.win_reveal_queue, {
                payline = payline,
                score = score,
                win_type = win_type,
                symbol = best_symbol,
                match_count = match_count,
                symbols = symbols
            })

            total_score = total_score + score
            if match_count > best_match_count then
                best_match_count = match_count
                best_win_type = win_type
            end
        end

        -- Collect all symbols for joker effects
        for _, sym in ipairs(symbols) do
            table.insert(all_symbols, sym)
        end
    end

    -- Determine win type for animations
    local is_triple = best_match_count >= Game.num_reels
    Game.last_win_type = is_triple and "triple" or (best_match_count >= 2 and "pair" or "")

    -- Apply joker effects (only on wins)
    if total_score > 0 then
        local center_symbols = Game.get_center_symbols()
        for _, joker in ipairs(Game.jokers) do
            if joker.apply then
                total_score = joker.apply(total_score, center_symbols, Game)
            end
        end
    end

    -- Apply joker on_spin effects
    local center_symbols = Game.get_center_symbols()
    for _, joker in ipairs(Game.jokers) do
        if joker.on_spin then
            joker.on_spin(Game, center_symbols)
        end
    end

    -- Update game state
    if total_score > 0 then
        -- Apply permanent win bonus
        local win_mult = 1 + (Game.perm_win_bonus or 0)
        total_score = math.floor(total_score * win_mult)

        -- Apply payline bonus (bonus per active payline)
        local payline_bonus = (#Game.paylines) * (Game.perm_payline_bonus or 0)
        total_score = total_score + payline_bonus

        -- Apply combo multiplier (consecutive wins)
        local combo_mult = Combo.on_win()
        if combo_mult > 1.0 then
            local combo_info = Combo.get_display_info()
            total_score = math.floor(total_score * combo_mult)
            -- Store combo info for UI display
            Game.last_combo_mult = combo_mult
            Game.last_combo_wins = combo_info.wins
        else
            Game.last_combo_mult = nil
            Game.last_combo_wins = nil
        end

        -- Apply Lucky Coin double win effect
        if ConsumablesSystem.is_double_win_active() then
            total_score = total_score * 2
            ConsumablesSystem.clear_double_win()
            Game.last_double_win = true
        else
            Game.last_double_win = false
        end

        -- Apply special event payout multiplier (e.g., Lucky Hour, High Roller)
        local event_mult = SpecialEvents.get_payout_multiplier()
        if event_mult > 1.0 then
            total_score = math.floor(total_score * event_mult)
            Game.last_event_mult = event_mult
        else
            Game.last_event_mult = nil
        end

        -- Apply boss on_win modifier (e.g., The Chaos randomizes score)
        total_score = BossModifiers.on_win(Game, total_score)

        Game.credits = Game.credits + total_score
        Game.last_win = total_score

        -- Reset loss streak on win (sync with LunaSystem)
        LunaSystem.reset_loss_streak()
        Game.luna_loss_streak = 0

        -- Start sequential win reveal if multiple wins
        if #Game.win_reveal_queue > 0 then
            Game.win_reveal_active = true
            Game.win_reveal_index = 1
            Game.win_reveal_timer = Game.win_reveal_delay
            Game.reveal_next_win()  -- Show first win immediately
        end

        -- Track highest credits
        if Game.credits > Game.highest_credits then
            Game.highest_credits = Game.credits
        end
    else
        -- Check for Safety Net joker using PaylinesSystem
        local has_safety_net = PaylinesSystem.has_safety_net(Game.jokers)

        -- Break combo on loss
        Combo.on_loss()
        Game.last_combo_mult = nil
        Game.last_combo_wins = nil

        -- Increment loss streak (sync with LunaSystem)
        LunaSystem.increment_loss_streak()
        Game.luna_loss_streak = LunaSystem.get_loss_streak()

        if has_safety_net then
            Game.credits = Game.credits + Game.bet
            Game.message = "NO MATCH"
            Game.sub_message = "Safety Net: Bet refunded!"
        else
            Game.message = "NO MATCH"
            Game.sub_message = "Try again!"
        end
    end

    -- Check round end (will be shown after reveal completes)
    Game.pending_round_end_check = true
end

-- Reveal the next winning payline in sequence
function Game.reveal_next_win()
    if Game.win_reveal_index > #Game.win_reveal_queue then
        -- All wins revealed, show total
        Game.win_reveal_active = false
        Game.current_reveal_payline = nil
        Game.lit_symbols = {}  -- Clear lit symbols

        -- Mark all winning paylines as revealed
        for _, win_data in ipairs(Game.win_reveal_queue) do
            Game.winning_paylines[win_data.payline] = true
        end

        -- Show final message
        if #Game.win_reveal_queue > 1 then
            Game.message = #Game.win_reveal_queue .. " PAYLINES WIN!"
            Game.sub_message = "Total: +" .. Game.last_win .. " credits!"
        end

        -- Check round end now
        Game.check_round_end_message()
        return
    end

    local win_data = Game.win_reveal_queue[Game.win_reveal_index]

    -- Mark this payline as currently revealing
    Game.current_reveal_payline = win_data.payline
    Game.winning_paylines[win_data.payline] = true
    Game.payline_scores[win_data.payline] = win_data.score

    -- Calculate which symbols to light up for this payline
    Game.lit_symbols = Game.get_payline_symbol_positions(win_data.payline)

    -- Update message for this payline
    local payline_name = Game.get_payline_name(win_data.payline)
    Game.message = win_data.win_type
    if #Game.win_reveal_queue > 1 then
        Game.sub_message = payline_name .. ": +" .. win_data.score .. " (" .. Game.win_reveal_index .. "/" .. #Game.win_reveal_queue .. ")"
    else
        Game.sub_message = "+" .. win_data.score .. " credits!"
    end

    -- Trigger effects for this win
    local is_triple = win_data.match_count >= Game.num_reels
    if is_triple then
        Game.win_flash = Game.fast_forward and 0.3 or 1.0
        local cx = Config.LAYOUT.reels.x + Config.LAYOUT.reels.w / 2
        local cy = Config.LAYOUT.reels.y + Config.LAYOUT.reels.h / 2
        Effects.trigger_win_effects(win_data.score, win_data.win_type, cx, cy)
    else
        Game.win_flash = Game.fast_forward and 0.15 or 0.4
    end
end

-- Get symbol positions for a payline (delegates to PaylinesSystem)
function Game.get_payline_symbol_positions(payline)
    return PaylinesSystem.get_symbol_positions(payline, Game.num_reels, Game.num_rows)
end

-- Toggle fast forward mode
function Game.toggle_fast_forward()
    Game.fast_forward = not Game.fast_forward
    Game.win_reveal_delay = Game.fast_forward and Game.fast_reveal_delay or Game.normal_reveal_delay
end

-- Get human-readable name for a payline (delegates to PaylinesSystem)
function Game.get_payline_name(payline)
    return PaylinesSystem.get_name(payline)
end

-- Check and show round end message
function Game.check_round_end_message()
    local spins_left = Game.spins_per_round - Game.spins_this_round
    if spins_left <= 0 then
        Game.sub_message = "Round over! Press SPACE"
    elseif spins_left <= 2 then
        if Game.last_win > 0 then
            Game.sub_message = "+" .. Game.last_win .. " credits! (" .. spins_left .. " spins left)"
        end
    end
end

------------------------------------------------------------
-- TARGET CALCULATION (delegates to ProgressionSystem)
------------------------------------------------------------
function Game.calculate_target()
    local base_target = ProgressionSystem.calculate_target(
        Game.ante,
        Game.round_in_ante,
        Game.perm_target_reduction or 0
    )

    -- Apply boss target multiplier (e.g., The Flood doubles targets)
    local boss_mult = BossModifiers.get_target_multiplier()
    return math.floor(base_target * boss_mult)
end

function Game.get_effective_spins()
    local base_spins = ProgressionSystem.get_effective_spins(Game.perm_extra_spins or 0)

    -- Apply boss spin reduction (e.g., The Drought reduces spins)
    local reduction = BossModifiers.get_spin_reduction()
    return math.max(1, base_spins - reduction)  -- Minimum 1 spin
end

------------------------------------------------------------
-- ROUND MANAGEMENT (ANTE-BASED ROGUELIKE)
------------------------------------------------------------
function Game.start_round()
    Game.spins_this_round = 0
    Game.spins_per_round = Game.get_effective_spins()
    Game.round_target = Game.calculate_target()

    -- Clear any previous special event
    SpecialEvents.clear()

    -- Story intro for first round of each ante
    if Game.round_in_ante == 1 then
        local intro = Story.on_ante_start(Game.ante)
        if intro then
            Game.story_dialogue = intro
            Game.story_dialogue_type = "intro"
        end
    end

    -- Apply boss round start effects (may modify credits, bet, etc.)
    BossModifiers.on_round_start(Game)

    -- Try to trigger a special event
    local event = SpecialEvents.try_trigger(Game)
    if event then
        Game.current_event = event
        Game.message = "[" .. event.icon .. "] " .. event.name .. "!"
        Game.sub_message = event.effect_desc

        -- Apply instant effects
        if event.free_spins then
            Game.spins_per_round = Game.spins_per_round + event.free_spins
        end
        if event.free_consumable and not ConsumablesSystem.is_full() then
            local random_consumable = ConsumableDefs.get_random(1)[1]
            if random_consumable then
                ConsumablesSystem.add(random_consumable.id)
            end
        end
    else
        Game.current_event = nil
        Game.message = "ANTE " .. Game.ante .. " - ROUND " .. Game.round_in_ante
        Game.sub_message = "Target: " .. Game.round_target .. " credits"

        -- Show boss info if there's an active modifier
        local boss_info = BossModifiers.get_display_info()
        if boss_info.name ~= "No Boss" and Game.ante > 1 then
            Game.sub_message = Game.sub_message .. " | " .. boss_info.icon .. " " .. boss_info.desc
        end
    end

    -- Track highest credits
    if Game.credits > Game.highest_credits then
        Game.highest_credits = Game.credits
    end
end

function Game.end_round()
    local met_target = Game.credits >= Game.round_target

    if met_target then
        -- Success! Check if ante is complete
        if Game.round_in_ante >= Config.ROUNDS_PER_ANTE then
            -- ANTE COMPLETE - go to ante reward selection
            Game.complete_ante()
        else
            -- Round complete, go to shop
            local bonus = 20 + Game.round * 5
            Game.credits = Game.credits + bonus
            Game.message = "ROUND COMPLETE! +" .. bonus
            Game.sub_message = "Target bonus earned!"

            Game.round = Game.round + 1
            Game.round_in_ante = Game.round_in_ante + 1
            Game.state = "shop"
            Game.generate_shop()
        end
    else
        -- FAILED - Game Over
        Game.trigger_game_over()
    end
end

function Game.complete_ante()
    -- Ante completed! Give reward selection
    Game.message = "ANTE " .. Game.ante .. " COMPLETE!"
    Game.sub_message = "Choose a permanent buff!"

    -- Story win dialogue
    local show_story = Story.on_ante_win(Game.ante)
    if show_story then
        Game.pending_story_popup = Game.ante
    end
    local win_line = Story.get_win_line(Game.ante)
    if win_line then
        Game.story_dialogue = win_line
        Game.story_dialogue_type = "win"
    end

    -- Check if game is won (ante 13 completed)
    if Game.ante >= 13 then
        LunaAffinity.on_game_beaten()
        local leveled_up, new_level = LunaAffinity.on_run_end(Game, true)
        if leveled_up then
            Game.luna_level_up = new_level
        end

        -- Update meta progression for win
        local new_achievements = Meta.on_run_end(true, Game)
        if #new_achievements > 0 then
            Game.new_achievements = new_achievements
        end

        -- Save progress
        Save.save_now()

        Game.message = "YOU WON!"
        Game.sub_message = "You and Luna are free..."
        Game.state = "game_over"
        Game.game_won = true
        Events.emit("game_won", {ante = Game.ante})
        return
    end

    -- Generate 3 random buff choices using BuffDefs module
    Game.ante_reward_choices = BuffDefs.get_random(3)

    Game.selected_ante_reward = 0
    Game.state = "ante_reward"

    -- Track highest ante
    if Game.ante > Game.highest_ante then
        Game.highest_ante = Game.ante
    end

    -- Check for Luna affinity level up
    local leveled_up, new_level = LunaAffinity.check_level_up(Game)
    if leveled_up then
        Game.luna_level_up = new_level
    end

    -- Emit event for other systems
    Events.emit(Events.NAMES.ANTE_COMPLETE, {ante = Game.ante})
end

function Game.select_ante_reward(index)
    if index < 1 or index > #Game.ante_reward_choices then return end

    local buff = Game.ante_reward_choices[index]
    if buff and buff.effect then
        -- Create a state-like object for buff effects (bridges old and new format)
        local state_bridge = {
            perm = {
                starting_credits = Game.perm_starting_credits or 0,
                win_bonus = Game.perm_win_bonus or 0,
                target_reduction = Game.perm_target_reduction or 0,
                extra_spins = Game.perm_extra_spins or 0,
                free_reroll = Game.perm_free_reroll or false,
                symbol_bonus = Game.perm_symbol_bonus or 0,
                wild_bonus = Game.perm_wild_bonus or 0,
                shop_discount = Game.perm_shop_discount or 0,
                payline_bonus = Game.perm_payline_bonus or 0,
            },
            max_jokers = Game.max_jokers,
        }

        buff.effect(state_bridge)

        -- Copy back to Game
        Game.perm_starting_credits = state_bridge.perm.starting_credits
        Game.perm_win_bonus = state_bridge.perm.win_bonus
        Game.perm_target_reduction = state_bridge.perm.target_reduction
        Game.perm_extra_spins = state_bridge.perm.extra_spins
        Game.perm_free_reroll = state_bridge.perm.free_reroll
        Game.perm_symbol_bonus = state_bridge.perm.symbol_bonus
        Game.perm_wild_bonus = state_bridge.perm.wild_bonus
        Game.perm_shop_discount = state_bridge.perm.shop_discount
        Game.perm_payline_bonus = state_bridge.perm.payline_bonus
        Game.max_jokers = state_bridge.max_jokers

        Game.message = "BUFF ACQUIRED: " .. buff.name
        Game.sub_message = buff.desc
    end

    -- Advance to next ante
    Game.ante = Game.ante + 1
    Game.round_in_ante = 1
    Game.round = Game.round + 1

    -- Initialize boss for new ante
    Game.current_boss = BossModifiers.init(Game.ante)

    -- Ante completion bonus
    local ante_bonus = 50 * Game.ante
    Game.credits = Game.credits + ante_bonus

    -- Show story popup if pending (story beat for completed ante)
    if Game.pending_story_popup then
        Story.show_story_popup(Game.pending_story_popup)
        Game.pending_story_popup = nil
    end

    -- Go to shop
    Game.state = "shop"
    Game.generate_shop()
end

function Game.trigger_game_over()
    Game.message = "GAME OVER"
    Game.sub_message = "Ante " .. Game.ante .. " - Round " .. Game.round_in_ante

    -- Story loss dialogue
    local loss_line = Story.on_game_over(Game.ante)
    if loss_line then
        Game.story_dialogue = loss_line
        Game.story_dialogue_type = "loss"
    end

    Game.games_played = Game.games_played + 1

    -- Update Luna affinity with run stats
    local leveled_up, new_level = LunaAffinity.on_run_end(Game, false)
    if leveled_up then
        Game.luna_level_up = new_level
    end

    -- Update meta progression
    local new_achievements = Meta.on_run_end(false, Game)
    if #new_achievements > 0 then
        Game.new_achievements = new_achievements
    end

    -- Save progress
    Save.save_now()

    -- Check for mercy spin availability
    Game.mercy_spin_available = LunaAffinity.has_mercy_spin()

    Game.state = "game_over"
end

-- Use mercy spin (Luna's gift at high affinity)
function Game.use_mercy_spin()
    if not Game.mercy_spin_available then
        return false
    end

    if LunaAffinity.use_mercy_spin() then
        Game.mercy_spin_available = false
        -- Give player one more spin and some credits
        Game.credits = math.max(Game.credits, Game.bet * 3)
        Game.spins_per_round = Game.spins_per_round + 1
        Game.state = "play"
        Game.message = "LUNA'S MERCY"
        Game.sub_message = "One more chance..."
        return true
    end

    return false
end

function Game.start_new_run()
    -- Reset run-specific state
    Game.ante = 1
    Game.round_in_ante = 1
    Game.round = 1
    Game.credits = Config.STARTING_CREDITS + (Game.perm_starting_credits or 0)
    Game.bet = Config.STARTING_BET
    Game.last_win = 0
    Game.spins_this_round = 0
    Game.total_spins = 0

    -- Reset jokers and upgrades
    Game.jokers = {}
    Game.slot_changers = {}
    Game.num_reels = Config.NUM_REELS
    Game.num_rows = 3
    Game.paylines = {0}
    Game.wild_magnet = false

    -- Reset shop state
    Game.shop_bought_joker = false
    Game.shop_bought_changer = false
    Game.shop_rerolled = false

    -- Reset win reveal
    Game.win_reveal_active = false
    Game.win_reveal_queue = {}
    Game.lit_symbols = {}
    Game.payline_scores = {}

    -- Reset Luna (sync with LunaSystem)
    LunaSystem.reset()
    Game.luna_expression = "idle"
    Game.luna_loss_streak = 0

    -- Reset combo
    Combo.reset()
    Game.last_combo_mult = nil
    Game.last_combo_wins = nil

    -- Reset consumables
    ConsumablesSystem.reset()

    -- Reset special events
    SpecialEvents.reset()
    Game.current_event = nil

    -- Reset story (transient state only, keeps persistent progress)
    Story.reset_transient()
    Game.story_dialogue = nil
    Game.story_dialogue_type = nil
    Game.pending_story_popup = nil

    -- Initialize boss for ante 1
    Game.current_boss = BossModifiers.init(Game.ante)

    -- Start fresh
    Game.state = "play"
    Game.init_reels()
    Game.start_round()
    Effects.clear()

    Events.emit(Events.NAMES.NEW_RUN, {})
end

-- Delete a joker by index
function Game.delete_joker(index)
    if index > 0 and index <= #Game.jokers then
        local joker = Game.jokers[index]
        -- Refund 25% of cost
        local refund = math.floor((joker.cost or 50) * 0.25)
        Game.credits = Game.credits + refund
        table.remove(Game.jokers, index)
        Game.message = "Sold " .. joker.name
        Game.sub_message = "+" .. refund .. " credits refunded"
        return true
    end
    return false
end

------------------------------------------------------------
-- SHOP
------------------------------------------------------------
function Game.generate_shop()
    Game.shop_items = {}
    Game.shop_slot_changers = {}

    -- Reset purchase limits for this shop visit
    Game.shop_bought_joker = false
    Game.shop_bought_changer = false
    Game.shop_rerolled = false

    -- Call boss on_shop_open (clears some boss state)
    BossModifiers.on_shop_open(Game)

    -- Get boss price multiplier (e.g., The Miser increases prices)
    local boss_price_mult = BossModifiers.get_price_multiplier()

    -- Generate jokers using JokerDefs module
    local available = JokerDefs.get_all()

    -- Shuffle and pick 3
    for i = #available, 2, -1 do
        local j = math.random(i)
        available[i], available[j] = available[j], available[i]
    end

    for i = 1, math.min(3, #available) do
        local joker = {}
        for k, v in pairs(available[i]) do
            joker[k] = v
        end
        -- Vary the cost slightly, apply shop discount and boss multiplier
        local discount = 1 - (Game.perm_shop_discount or 0)
        joker.cost = math.floor(joker.cost * (0.8 + math.random() * 0.4) * discount * boss_price_mult)
        table.insert(Game.shop_items, joker)
    end

    -- Generate slot changers using SlotChangerDefs module
    local available_changers = SlotChangerDefs.get_available(Game)

    -- Shuffle and pick up to 2
    for i = #available_changers, 2, -1 do
        local j = math.random(i)
        available_changers[i], available_changers[j] = available_changers[j], available_changers[i]
    end

    for i = 1, math.min(2, #available_changers) do
        local changer = {}
        for k, v in pairs(available_changers[i]) do
            changer[k] = v
        end
        -- Apply shop discount and boss multiplier
        local discount = 1 - (Game.perm_shop_discount or 0)
        changer.cost = math.floor(changer.cost * discount * boss_price_mult)
        table.insert(Game.shop_slot_changers, changer)
    end

    -- Generate consumables (if player has room)
    Game.shop_consumables = {}
    if not ConsumablesSystem.is_full() then
        local available_consumables = ConsumableDefs.get_random(2)

        for i = 1, math.min(2, #available_consumables) do
            local consumable = {}
            for k, v in pairs(available_consumables[i]) do
                consumable[k] = v
            end
            -- Apply shop discount and boss multiplier
            local discount = 1 - (Game.perm_shop_discount or 0)
            consumable.cost = math.floor(consumable.cost * discount * boss_price_mult)
            table.insert(Game.shop_consumables, consumable)
        end
    end
end

function Game.buy_joker(index)
    local item = Game.shop_items[index]
    if not item then return false end

    -- Check purchase limit (1 joker per shop visit)
    if Game.shop_bought_joker then
        Game.message = "Already bought a joker!"
        Game.sub_message = "One per shop visit"
        return false
    end

    if Game.credits < item.cost then
        Game.message = "Not enough credits!"
        return false
    end

    if #Game.jokers >= Game.max_jokers then
        Game.message = "Joker slots full!"
        return false
    end

    Game.credits = Game.credits - item.cost
    table.insert(Game.jokers, item)
    Game.shop_items[index] = nil
    Game.shop_bought_joker = true  -- Mark as purchased
    Game.message = "Bought " .. item.name .. "!"

    -- Apply on_acquire effect if present
    if item.on_acquire then
        item.on_acquire(Game)
    end

    return true
end

-- Helper functions for slot changer effects
local slot_changer_helpers = {
    add_payline = function(state, offset)
        state.num_paylines = state.num_paylines + 1
        table.insert(state.paylines, offset)
    end,
    add_diagonal_payline = function(state, direction)
        state.num_paylines = state.num_paylines + 1
        table.insert(state.paylines, "diag_" .. direction)
    end,
    add_reel = function(state)
        Game.add_reel()  -- Call the existing Game function
    end,
    add_row = function(state)
        if state.num_rows < 5 then
            state.num_rows = state.num_rows + 1
        end
    end,
}

function Game.buy_slot_changer(index)
    local item = Game.shop_slot_changers[index]
    if not item then return false end

    -- Check purchase limit (1 slot changer per shop visit)
    if Game.shop_bought_changer then
        Game.message = "Already bought an upgrade!"
        Game.sub_message = "One per shop visit"
        return false
    end

    if Game.credits < item.cost then
        Game.message = "Not enough credits!"
        return false
    end

    Game.credits = Game.credits - item.cost
    table.insert(Game.slot_changers, item)
    Game.shop_slot_changers[index] = nil
    Game.shop_bought_changer = true  -- Mark as purchased
    Game.message = "Unlocked " .. item.name .. "!"

    -- Apply the slot changer effect with helpers
    if item.on_acquire then
        item.on_acquire(Game, slot_changer_helpers)
    end

    return true
end

function Game.buy_consumable(index)
    local item = Game.shop_consumables[index]
    if not item then return false end

    -- Check inventory space
    if ConsumablesSystem.is_full() then
        Game.message = "Consumable inventory full!"
        Game.sub_message = "Max " .. ConsumablesSystem.get_max() .. " items"
        return false
    end

    if Game.credits < item.cost then
        Game.message = "Not enough credits!"
        return false
    end

    Game.credits = Game.credits - item.cost
    ConsumablesSystem.add(item.id)
    Game.shop_consumables[index] = nil
    Game.message = "Bought " .. item.name .. "!"
    Game.sub_message = item.effect_desc

    return true
end

function Game.reroll_shop()
    -- Check reroll limit (1 reroll per shop visit)
    if Game.shop_rerolled then
        Game.message = "Already rerolled!"
        Game.sub_message = "One reroll per visit"
        return false
    end

    if Game.credits < Config.REROLL_COST then
        Game.message = "Need " .. Config.REROLL_COST .. " to reroll"
        return false
    end

    Game.credits = Game.credits - Config.REROLL_COST

    -- Keep the rerolled flag but regenerate items
    local was_rerolled = true
    Game.generate_shop()
    Game.shop_rerolled = was_rerolled  -- Restore flag after generate_shop resets it
    Game.message = "Shop rerolled!"
    return true
end

------------------------------------------------------------
-- RESET
------------------------------------------------------------
function Game.restart()
    Game.state = "play"
    Game.credits = Config.STARTING_CREDITS
    Game.bet = Config.STARTING_BET
    Game.last_win = 0
    Game.last_win_type = ""
    Game.round = 1
    Game.spins_this_round = 0
    Game.total_spins = 0
    Game.highest_credits = Config.STARTING_CREDITS
    Game.jokers = {}
    Game.shop_items = {}
    Game.shop_slot_changers = {}
    Game.slot_changers = {}
    Game.message = "GOOD LUCK!"
    Game.sub_message = "Press SPACE to spin"
    Game.win_flash = 0
    Game.spinning = false

    -- Reset shop purchase flags
    Game.shop_bought_joker = false
    Game.shop_bought_changer = false
    Game.shop_rerolled = false

    -- Reset slot configuration
    Game.num_reels = Config.NUM_REELS
    Game.num_rows = 3
    Game.num_paylines = 1
    Game.paylines = {0}
    Game.wild_magnet = false
    Game.winning_paylines = {}

    -- Reset win reveal system
    Game.win_reveal_active = false
    Game.win_reveal_queue = {}
    Game.win_reveal_index = 0
    Game.win_reveal_timer = 0
    Game.current_reveal_payline = nil
    Game.lit_symbols = {}
    Game.payline_scores = {}
    Game.fast_forward = false
    Game.win_reveal_delay = Game.normal_reveal_delay

    -- Reset Luna state (sync with LunaSystem)
    LunaSystem.reset()
    Game.luna_expression = "idle"
    Game.luna_loss_streak = 0

    Game.init_reels()
    Game.start_round()
    Effects.clear()
end

------------------------------------------------------------
-- UPDATE
------------------------------------------------------------
function Game.update(dt)
    Game.update_reels(dt)

    -- Update win flash
    if Game.win_flash > 0 then
        Game.win_flash = Game.win_flash - dt * 2
    end

    -- Update win reveal sequence
    if Game.win_reveal_active and not Game.spinning then
        Game.win_reveal_timer = Game.win_reveal_timer - dt
        if Game.win_reveal_timer <= 0 then
            -- Move to next win
            Game.win_reveal_index = Game.win_reveal_index + 1
            Game.win_reveal_timer = Game.win_reveal_delay
            Game.reveal_next_win()
        end
    end

    -- Update Luna's expression
    Game.update_luna_expression()

    -- Update story system
    Story.update(dt)

    Effects.update(dt)
end

------------------------------------------------------------
-- BOSS HELPERS
------------------------------------------------------------

-- Get current boss modifier info
function Game.get_boss()
    return BossModifiers.get_current()
end

function Game.get_boss_info()
    return BossModifiers.get_display_info()
end

-- Get minimum bet (considering boss modifier and special events)
function Game.get_min_bet()
    local boss_min = BossModifiers.get_min_bet() or 1

    -- Apply special event minimum bet multiplier (e.g., High Roller)
    local event_mult = SpecialEvents.get_min_bet_multiplier()
    local event_min = math.ceil(boss_min * event_mult)

    return math.max(boss_min, event_min)
end

------------------------------------------------------------
-- COMBO HELPERS
------------------------------------------------------------

function Game.get_combo()
    return Combo.get_display_info()
end

function Game.is_combo_active()
    return Combo.is_active()
end

------------------------------------------------------------
-- CONSUMABLES HELPERS
------------------------------------------------------------

function Game.get_consumables()
    return ConsumablesSystem.get_inventory()
end

function Game.get_consumables_count()
    return ConsumablesSystem.get_count()
end

function Game.use_consumable(index)
    local success, msg = ConsumablesSystem.use(index, Game)
    if success then
        Game.message = "Used item!"
        Game.sub_message = msg or ""

        -- Handle Mulligan (needs to trigger respin)
        if ConsumablesSystem.is_mulligan_pending() then
            ConsumablesSystem.clear_mulligan()
            -- Respin without using a spin count
            Game.spins_this_round = Game.spins_this_round - 1
            Game.spin()
        end
    else
        Game.message = "Can't use that now!"
        Game.sub_message = msg or ""
    end
    return success
end

function Game.get_active_consumable_effects()
    return ConsumablesSystem.get_active_effects()
end

------------------------------------------------------------
-- SPECIAL EVENT HELPERS
------------------------------------------------------------

function Game.get_active_event()
    return SpecialEvents.get_active()
end

function Game.is_event_active()
    return SpecialEvents.is_active()
end

function Game.get_event_info()
    return SpecialEvents.get_display_info()
end

-- Check if collector trade is available
function Game.can_collector_trade()
    return SpecialEvents.is_collector_active() and #Game.jokers > 0
end

-- Perform collector trade (sell joker for double value)
function Game.collector_trade(joker_index)
    if not Game.can_collector_trade() then
        return false
    end

    local joker = Game.jokers[joker_index]
    if not joker then
        return false
    end

    local mult = SpecialEvents.get_collector_multiplier()
    local value = math.floor((joker.cost or 50) * mult)

    table.remove(Game.jokers, joker_index)
    Game.credits = Game.credits + value
    SpecialEvents.complete_collector_trade()

    Game.message = "The Collector takes " .. joker.name
    Game.sub_message = "+" .. value .. " credits!"

    return true
end

------------------------------------------------------------
-- LUNA AFFINITY HELPERS
------------------------------------------------------------

function Game.get_luna_affinity()
    return LunaAffinity.get_level()
end

function Game.get_luna_affinity_info()
    return LunaAffinity.get_level_info()
end

function Game.get_luna_stats()
    return LunaAffinity.get_stats()
end

function Game.get_luna_wild_bonus()
    return LunaAffinity.get_wild_bonus()
end

------------------------------------------------------------
-- STORY HELPERS
------------------------------------------------------------

function Game.get_story_dialogue()
    return Game.story_dialogue, Game.story_dialogue_type
end

function Game.get_boss_name()
    return Story.get_boss_name(Game.ante)
end

function Game.show_story_popup()
    if Game.pending_story_popup then
        Story.show_story_popup(Game.pending_story_popup)
        Game.pending_story_popup = nil
        return true
    end
    return false
end

function Game.close_story_popup()
    Story.close_story_popup()
end

function Game.is_story_popup_active()
    return Story.is_story_popup_active()
end

function Game.get_story_popup()
    return Story.get_story_popup()
end

------------------------------------------------------------
-- META PROGRESSION HELPERS
------------------------------------------------------------

function Game.get_achievements()
    return Meta.get_unlocked_achievements()
end

function Game.get_locked_achievements()
    return Meta.get_locked_achievements()
end

function Game.get_achievement_progress()
    return Meta.get_achievement_progress()
end

function Game.get_meta_stats()
    return Meta.get_stats()
end

function Game.get_extra_joker_slots()
    return Meta.get_extra_joker_slots()
end

return Game
