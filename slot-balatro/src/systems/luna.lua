------------------------------------------------------------
-- LUNA SYSTEM
-- Mascot expressions, dialogue, and reactions
------------------------------------------------------------

local Dialogue = require("src.data.dialogue")
local Events = require("src.core.events")

local Luna = {}

-- Expression list
local EXPRESSIONS = {
    "idle", "watching", "neutral", "small_win", "good_win",
    "big_win", "jackpot", "mega_jackpot", "losing_streak",
    "broke", "comeback", "shop", "round_end"
}

-- Loaded images
local images = {}

-- Current state
local current_expression = "idle"
local loss_streak = 0

------------------------------------------------------------
-- IMAGE LOADING
------------------------------------------------------------

function Luna.load_images(asset_path)
    asset_path = asset_path or "src/assests/"

    for _, expr in ipairs(EXPRESSIONS) do
        local path = asset_path .. "luna_" .. expr .. ".png"
        local success, img = pcall(love.graphics.newImage, path)
        if success then
            images[expr] = img
            img:setFilter("nearest", "nearest")
        end
    end
end

function Luna.get_image(expression)
    return images[expression] or images["idle"]
end

function Luna.get_current_image()
    return Luna.get_image(current_expression)
end

function Luna.has_image(expression)
    return images[expression] ~= nil
end

------------------------------------------------------------
-- EXPRESSION MANAGEMENT
------------------------------------------------------------

function Luna.get_expression()
    return current_expression
end

function Luna.set_expression(expression)
    if current_expression ~= expression then
        current_expression = expression
        Events.emit(Events.NAMES.LUNA_EXPRESSION_CHANGED, {expression = expression})
    end
end

function Luna.get_loss_streak()
    return loss_streak
end

function Luna.reset_loss_streak()
    loss_streak = 0
end

function Luna.increment_loss_streak()
    loss_streak = loss_streak + 1
end

------------------------------------------------------------
-- EXPRESSION DETERMINATION
------------------------------------------------------------

-- Determine Luna's expression based on game state
function Luna.update_expression(game_state)
    local new_expression = "idle"

    if game_state.state == "game_over" then
        new_expression = "broke"
    elseif game_state.state == "ante_reward" then
        new_expression = "jackpot"
    elseif game_state.state == "shop" then
        new_expression = "shop"
    elseif game_state.spinning then
        new_expression = "watching"
    elseif game_state.win_reveal_active then
        -- During win reveal, show excitement based on win amount
        new_expression = Luna.get_win_expression(game_state.last_win)
    elseif game_state.last_win > 0 then
        -- After win reveal complete
        if loss_streak >= 3 then
            new_expression = "comeback"
            loss_streak = 0
        else
            new_expression = Luna.get_win_expression(game_state.last_win)
        end
    elseif game_state.credits <= 5 then
        new_expression = "broke"
    elseif loss_streak >= 3 then
        new_expression = "losing_streak"
    elseif game_state.spins_this_round >= game_state.spins_per_round then
        new_expression = "round_end"
    else
        new_expression = "idle"
    end

    -- Fallback if expression image doesn't exist
    if not images[new_expression] then
        if game_state.last_win > 0 and images["small_win"] then
            new_expression = "small_win"
        elseif images["neutral"] then
            new_expression = "neutral"
        elseif images["idle"] then
            new_expression = "idle"
        end
    end

    Luna.set_expression(new_expression)
end

-- Get appropriate expression for a win amount
function Luna.get_win_expression(win_amount)
    if win_amount >= 500 then
        return "mega_jackpot"
    elseif win_amount >= 100 then
        return "jackpot"
    elseif win_amount >= 50 then
        return "big_win"
    elseif win_amount >= 20 then
        return "good_win"
    else
        return "small_win"
    end
end

------------------------------------------------------------
-- DIALOGUE
------------------------------------------------------------

function Luna.get_dialogue()
    return Dialogue.get_line(current_expression)
end

function Luna.get_context_dialogue(context)
    return Dialogue.get_context_line(context)
end

-- Get all dialogue lines for current expression
function Luna.get_all_dialogue_lines()
    return Dialogue.expressions[current_expression] or {}
end

------------------------------------------------------------
-- EVENT REACTIONS
------------------------------------------------------------

-- React to spin result
function Luna.on_spin_result(win_amount)
    if win_amount > 0 then
        loss_streak = 0
    else
        loss_streak = loss_streak + 1
    end
end

-- React to round end
function Luna.on_round_end(met_target)
    if met_target then
        current_expression = "round_end"
    else
        current_expression = "broke"
    end
end

-- React to ante complete
function Luna.on_ante_complete()
    current_expression = "jackpot"
end

-- React to game over
function Luna.on_game_over()
    current_expression = "broke"
    loss_streak = 0
end

-- Reset for new run
function Luna.reset()
    current_expression = "idle"
    loss_streak = 0
end

return Luna
