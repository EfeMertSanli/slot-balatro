------------------------------------------------------------
-- CALCULATION DISPLAY SYSTEM
-- Shows animated breakdown of score calculations
-- Syncs with payline reveals for dramatic effect
------------------------------------------------------------

local Colors = require("src.colors")

-- Sound module (lazy loaded)
local Sound = nil
local function get_sound()
    if not Sound then
        Sound = require("src.sound")
    end
    return Sound
end

local CalcDisplay = {}

------------------------------------------------------------
-- STATE
------------------------------------------------------------

local state = {
    -- Calculation steps queue
    steps = {},
    current_step = 0,

    -- Payline phase tracking
    payline_steps = {},      -- Steps that are payline values (added during sync)
    payline_count = 0,       -- How many paylines to expect
    paylines_revealed = 0,   -- How many have been revealed
    in_payline_phase = true, -- Are we still revealing paylines?

    -- Animation timing
    step_timer = 0,
    step_duration = 0.5,      -- Time per step (normal speed)
    step_duration_fast = 0.12, -- Time per step (fast forward)

    -- Display state
    active = false,
    running_total = 0,
    payline_subtotal = 0,    -- Sum of payline values
    final_total = 0,

    -- Animation state per step
    step_animations = {},  -- {glow = 0, jump = 0, scale = 1, shake = 0}

    -- Fast forward
    fast_forward = false,

    -- Pending multiplier steps (added after paylines)
    pending_steps = {},
}

------------------------------------------------------------
-- STEP TYPES
------------------------------------------------------------

local STEP_TYPES = {
    PAYLINE_VALUE = "payline_value", -- Individual payline score
    SUBTOTAL = "subtotal",           -- Sum of paylines
    BASE = "base",                   -- Base symbol value
    BET = "bet",                     -- Bet multiplier
    PAYLINE = "payline",             -- Payline win
    JOKER = "joker",                 -- Joker effect
    PERM_BONUS = "perm",             -- Permanent bonus
    COMBO = "combo",                 -- Combo multiplier
    DOUBLE = "double",               -- Lucky coin double
    EVENT = "event",                 -- Special event multiplier
    BOSS = "boss",                   -- Boss modifier
    TOTAL = "total",                 -- Final total
}

CalcDisplay.STEP_TYPES = STEP_TYPES

------------------------------------------------------------
-- INITIALIZATION
------------------------------------------------------------

-- Start a new calculation display
function CalcDisplay.start(final_total, expected_paylines)
    state.steps = {}
    state.current_step = 0
    state.step_timer = 0
    state.active = true
    state.running_total = 0
    state.payline_subtotal = 0
    state.final_total = final_total or 0
    state.step_animations = {}
    state.payline_steps = {}
    state.payline_count = expected_paylines or 0
    state.paylines_revealed = 0
    state.in_payline_phase = true
    state.pending_steps = {}
end

-- Add a payline value step (will be revealed when payline lights up)
function CalcDisplay.add_payline_step(payline_name, value, color)
    local step = {
        type = STEP_TYPES.PAYLINE_VALUE,
        label = payline_name,
        value = value,
        operator = "+",
        color = color or Colors.cyan,
        icon = "",
        result = 0,
        revealed = false,
    }
    table.insert(state.payline_steps, step)
end

-- Add a calculation step (queued until payline phase is done)
function CalcDisplay.add_step(step_type, label, value, operator, color, icon)
    local step = {
        type = step_type,
        label = label,
        value = value,
        operator = operator or "+",
        color = color or Colors.white,
        icon = icon or "",
        result = 0,
    }

    -- Queue multiplier steps for after payline phase
    table.insert(state.pending_steps, step)
end

-- Called when a payline is revealed on the reels
function CalcDisplay.reveal_payline(index)
    if index > #state.payline_steps then return end

    local step = state.payline_steps[index]
    if step.revealed then return end

    step.revealed = true
    state.paylines_revealed = state.paylines_revealed + 1
    state.payline_subtotal = state.payline_subtotal + step.value

    -- Play escalating line hit sound
    get_sound().line_hit(state.paylines_revealed)
    get_sound().score_add()

    -- Add to main steps list
    table.insert(state.steps, step)
    local step_index = #state.steps

    -- Initialize animation state with extra punch
    state.step_animations[step_index] = {
        glow = 1.5,      -- Extra bright glow
        jump = 1.5,      -- Bigger jump
        scale = 1.6,     -- Bigger scale
        shake = 1.0,     -- Screen shake effect
        revealed = true,
        pulse = 0,       -- Continuous pulse
    }

    state.current_step = step_index
    step.result = state.payline_subtotal
    state.running_total = state.payline_subtotal

    -- Check if all paylines revealed
    if state.paylines_revealed >= #state.payline_steps then
        -- Add subtotal step
        if #state.payline_steps > 1 then
            local subtotal_step = {
                type = STEP_TYPES.SUBTOTAL,
                label = "LINES TOTAL",
                value = state.payline_subtotal,
                operator = "=",
                color = Colors.gold,
                icon = "Σ",
                result = state.payline_subtotal,
            }
            table.insert(state.steps, subtotal_step)
            state.step_animations[#state.steps] = {
                glow = 0,
                jump = 0,
                scale = 1,
                shake = 0,
                revealed = false,
                pulse = 0,
            }
        end

        -- Now add all the pending multiplier steps
        for _, pending in ipairs(state.pending_steps) do
            table.insert(state.steps, pending)
            state.step_animations[#state.steps] = {
                glow = 0,
                jump = 0,
                scale = 1,
                shake = 0,
                revealed = false,
                pulse = 0,
            }
        end

        -- Calculate results for multiplier steps
        local running = state.payline_subtotal
        local start_idx = #state.payline_steps + (#state.payline_steps > 1 and 1 or 0) + 1

        for i = start_idx, #state.steps do
            local step = state.steps[i]
            if step.operator == "+" then
                running = running + step.value
            elseif step.operator == "x" then
                running = math.floor(running * step.value)
            elseif step.operator == "=" then
                running = step.value
            elseif step.operator == "-" then
                running = running - step.value
            end
            step.result = running
        end

        state.in_payline_phase = false
        state.step_timer = 0
    end
end

-- Finalize (called after all steps added, starts multiplier reveal)
function CalcDisplay.finalize()
    -- If no paylines, just reveal multiplier steps normally
    if #state.payline_steps == 0 then
        state.in_payline_phase = false

        -- Calculate results
        local running = 0
        for i, step in ipairs(state.steps) do
            if step.operator == "+" then
                running = running + step.value
            elseif step.operator == "x" then
                running = math.floor(running * step.value)
            elseif step.operator == "=" then
                running = step.value
            elseif step.operator == "-" then
                running = running - step.value
            end
            step.result = running
        end

        if #state.steps > 0 then
            state.current_step = 1
            state.step_timer = 0
            CalcDisplay.trigger_step_animation(1)
        end
    end
    -- If we have paylines, wait for them to be revealed via reveal_payline()
end

-- Clear and deactivate
function CalcDisplay.clear()
    state.steps = {}
    state.current_step = 0
    state.active = false
    state.running_total = 0
    state.payline_subtotal = 0
    state.step_animations = {}
    state.payline_steps = {}
    state.pending_steps = {}
    state.in_payline_phase = true
end

------------------------------------------------------------
-- ANIMATION
------------------------------------------------------------

function CalcDisplay.trigger_step_animation(step_index)
    if state.step_animations[step_index] then
        state.step_animations[step_index].glow = 1.5
        state.step_animations[step_index].jump = 1.2
        state.step_animations[step_index].scale = 1.5
        state.step_animations[step_index].shake = 0.8
        state.step_animations[step_index].revealed = true
        state.step_animations[step_index].pulse = 1.0

        -- Play appropriate sound based on step type
        local step = state.steps[step_index]
        if step then
            if step.type == STEP_TYPES.SUBTOTAL then
                get_sound().score_add()
            elseif step.type == STEP_TYPES.JOKER then
                get_sound().multiplier()
                get_sound().score_add()
            elseif step.type == STEP_TYPES.COMBO then
                get_sound().combo()
                get_sound().score_add()
            elseif step.type == STEP_TYPES.PERM_BONUS then
                get_sound().multiplier()
            elseif step.type == STEP_TYPES.DOUBLE then
                get_sound().combo()
                get_sound().score_add()
            elseif step.type == STEP_TYPES.EVENT then
                get_sound().multiplier()
                get_sound().score_add()
            elseif step.type == STEP_TYPES.BOSS then
                get_sound().multiplier()
            elseif step.type == STEP_TYPES.TOTAL then
                get_sound().total_reveal()
            elseif step.operator == "x" then
                get_sound().multiplier()
            elseif step.operator == "+" then
                get_sound().score_add()
            end
        end
    end
end

function CalcDisplay.set_fast_forward(enabled)
    state.fast_forward = enabled
end

function CalcDisplay.is_fast_forward()
    return state.fast_forward
end

------------------------------------------------------------
-- UPDATE
------------------------------------------------------------

function CalcDisplay.update(dt)
    if not state.active then return end
    if #state.steps == 0 then return end

    -- Speed multiplier for fast forward
    local speed_mult = state.fast_forward and 4.0 or 1.0
    local current_duration = state.fast_forward and state.step_duration_fast or state.step_duration

    -- Only auto-advance if not in payline phase (paylines are revealed externally)
    if not state.in_payline_phase then
        state.step_timer = state.step_timer + dt * speed_mult

        -- Find next unrevealed step after paylines
        local next_step = nil
        for i = state.current_step + 1, #state.steps do
            if state.step_animations[i] and not state.step_animations[i].revealed then
                next_step = i
                break
            end
        end

        if state.step_timer >= current_duration and next_step then
            state.current_step = next_step
            state.step_timer = 0
            CalcDisplay.trigger_step_animation(next_step)
            state.running_total = state.steps[next_step].result
        end
    end

    -- Update animations for all steps
    for i, anim in pairs(state.step_animations) do
        -- Decay glow (slower for more drama)
        if anim.glow > 0 then
            anim.glow = anim.glow - dt * speed_mult * 1.5
            if anim.glow < 0 then anim.glow = 0 end
        end

        -- Decay jump (bouncy)
        if anim.jump > 0 then
            anim.jump = anim.jump - dt * speed_mult * 2.5
            if anim.jump < 0 then anim.jump = 0 end
        end

        -- Decay scale back to 1
        if anim.scale > 1 then
            anim.scale = anim.scale - dt * speed_mult * 1.5
            if anim.scale < 1 then anim.scale = 1 end
        end

        -- Decay shake
        if anim.shake and anim.shake > 0 then
            anim.shake = anim.shake - dt * speed_mult * 3
            if anim.shake < 0 then anim.shake = 0 end
        end

        -- Continuous pulse for revealed items
        if anim.revealed and anim.pulse then
            anim.pulse = anim.pulse + dt * 4
        end
    end
end

------------------------------------------------------------
-- GETTERS
------------------------------------------------------------

function CalcDisplay.is_active()
    return state.active
end

function CalcDisplay.is_complete()
    if not state.active then return false end
    if state.in_payline_phase then return false end

    -- Check if all steps are revealed
    for i, anim in pairs(state.step_animations) do
        if not anim.revealed then return false end
    end

    local current_duration = state.fast_forward and state.step_duration_fast or state.step_duration
    return state.step_timer >= current_duration
end

function CalcDisplay.is_in_payline_phase()
    return state.in_payline_phase
end

function CalcDisplay.get_steps()
    return state.steps
end

function CalcDisplay.get_current_step()
    return state.current_step
end

function CalcDisplay.get_running_total()
    return state.running_total
end

function CalcDisplay.get_payline_subtotal()
    return state.payline_subtotal
end

function CalcDisplay.get_step_animation(index)
    return state.step_animations[index] or {glow = 0, jump = 0, scale = 1, shake = 0, revealed = false, pulse = 0}
end

function CalcDisplay.get_revealed_steps()
    local revealed = {}
    for i, step in ipairs(state.steps) do
        local anim = state.step_animations[i]
        if anim and anim.revealed then
            table.insert(revealed, {
                step = step,
                animation = anim,
                index = i,
            })
        end
    end
    return revealed
end

-- Skip to end (for impatient players)
function CalcDisplay.skip_to_end()
    -- Reveal all paylines first
    for i = 1, #state.payline_steps do
        if not state.payline_steps[i].revealed then
            CalcDisplay.reveal_payline(i)
        end
    end

    state.in_payline_phase = false
    state.current_step = #state.steps
    state.step_timer = state.step_duration

    -- Reveal all steps
    for i, anim in pairs(state.step_animations) do
        anim.revealed = true
        anim.glow = 0
        anim.jump = 0
        anim.scale = 1
        anim.shake = 0
    end

    if #state.steps > 0 then
        state.running_total = state.steps[#state.steps].result
    end
end

return CalcDisplay
