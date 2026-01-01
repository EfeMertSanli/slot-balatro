------------------------------------------------------------
-- STORY SYSTEM
-- Manages narrative dialogue and story progression
------------------------------------------------------------

local StoryDefs = require("src.data.story_defs")

local Story = {}

------------------------------------------------------------
-- STATE
------------------------------------------------------------

local state = {
    -- Track which story beats have been shown (persistent)
    story_shown = {},  -- [ante] = true if story beat was shown

    -- Current display state (transient)
    active_dialogue = nil,  -- Currently displayed dialogue
    dialogue_type = nil,    -- "intro", "win", "loss", "story"
    dialogue_timer = 0,
    dialogue_duration = 0,

    -- Story popup state
    story_popup_active = false,
    story_popup_text = nil,
    story_popup_ante = nil,
}

------------------------------------------------------------
-- DIALOGUE RETRIEVAL
------------------------------------------------------------

-- Get a random intro line for an ante
function Story.get_intro(ante)
    local ante_data = StoryDefs.antes[ante]
    if not ante_data or not ante_data.intro then
        return nil
    end
    return ante_data.intro[math.random(#ante_data.intro)]
end

-- Get a random win line for an ante
function Story.get_win_line(ante)
    local ante_data = StoryDefs.antes[ante]
    if not ante_data or not ante_data.win then
        return nil
    end
    return ante_data.win[math.random(#ante_data.win)]
end

-- Get a random loss line for an ante
function Story.get_loss_line(ante)
    local ante_data = StoryDefs.antes[ante]
    if not ante_data or not ante_data.loss then
        return nil
    end
    return ante_data.loss[math.random(#ante_data.loss)]
end

-- Get the story beat for an ante
function Story.get_story(ante)
    local ante_data = StoryDefs.antes[ante]
    if not ante_data then
        return nil
    end
    return ante_data.story
end

-- Get boss name for an ante
function Story.get_boss_name(ante)
    local ante_data = StoryDefs.antes[ante]
    if not ante_data then
        return "Unknown"
    end
    return ante_data.boss_name or "Unknown"
end

------------------------------------------------------------
-- STORY BEAT TRACKING
------------------------------------------------------------

-- Check if story beat was shown for this ante
function Story.was_story_shown(ante)
    return state.story_shown[ante] == true
end

-- Mark story beat as shown
function Story.mark_story_shown(ante)
    state.story_shown[ante] = true
end

-- Should we show the story beat? (first time completing ante)
function Story.should_show_story(ante)
    if state.story_shown[ante] then
        return false
    end
    local story = Story.get_story(ante)
    return story ~= nil
end

------------------------------------------------------------
-- DIALOGUE DISPLAY
------------------------------------------------------------

-- Show a dialogue line (for Luna to speak)
function Story.show_dialogue(text, dialogue_type, duration)
    if not text then return end

    state.active_dialogue = text
    state.dialogue_type = dialogue_type or "generic"
    state.dialogue_timer = 0
    state.dialogue_duration = duration or 5
end

-- Clear active dialogue
function Story.clear_dialogue()
    state.active_dialogue = nil
    state.dialogue_type = nil
    state.dialogue_timer = 0
end

-- Get active dialogue
function Story.get_active_dialogue()
    return state.active_dialogue, state.dialogue_type
end

-- Check if dialogue is active
function Story.has_active_dialogue()
    return state.active_dialogue ~= nil
end

------------------------------------------------------------
-- STORY POPUP
------------------------------------------------------------

-- Show story popup (longer narrative text)
function Story.show_story_popup(ante)
    local story = Story.get_story(ante)
    if not story then return false end

    state.story_popup_active = true
    state.story_popup_text = story
    state.story_popup_ante = ante
    return true
end

-- Close story popup
function Story.close_story_popup()
    if state.story_popup_active then
        Story.mark_story_shown(state.story_popup_ante)
    end
    state.story_popup_active = false
    state.story_popup_text = nil
    state.story_popup_ante = nil
end

-- Check if story popup is active
function Story.is_story_popup_active()
    return state.story_popup_active
end

-- Get story popup data
function Story.get_story_popup()
    return {
        active = state.story_popup_active,
        text = state.story_popup_text,
        ante = state.story_popup_ante,
        boss_name = state.story_popup_ante and Story.get_boss_name(state.story_popup_ante)
    }
end

------------------------------------------------------------
-- UPDATE
------------------------------------------------------------

function Story.update(dt)
    -- Update dialogue timer
    if state.active_dialogue then
        state.dialogue_timer = state.dialogue_timer + dt
        if state.dialogue_timer >= state.dialogue_duration then
            Story.clear_dialogue()
        end
    end
end

------------------------------------------------------------
-- GAME EVENT HOOKS
------------------------------------------------------------

-- Called when a new ante starts
function Story.on_ante_start(ante)
    local intro = Story.get_intro(ante)
    if intro then
        Story.show_dialogue(intro, "intro", 6)
    end
    return intro
end

-- Called when player wins an ante
function Story.on_ante_win(ante)
    local win_line = Story.get_win_line(ante)
    if win_line then
        Story.show_dialogue(win_line, "win", 5)
    end

    -- Check if we should show story beat
    if Story.should_show_story(ante) then
        return true  -- Signal to show story popup
    end
    return false
end

-- Called when player loses
function Story.on_game_over(ante)
    local loss_line = Story.get_loss_line(ante)
    if loss_line then
        Story.show_dialogue(loss_line, "loss", 5)
    end
    return loss_line
end

------------------------------------------------------------
-- PERSISTENCE
------------------------------------------------------------

function Story.get_save_data()
    return {
        story_shown = state.story_shown,
    }
end

function Story.load_save_data(data)
    if data.story_shown then
        state.story_shown = data.story_shown
    end
end

-- Reset for new game (keeps persistent data)
function Story.reset_transient()
    state.active_dialogue = nil
    state.dialogue_type = nil
    state.dialogue_timer = 0
    state.story_popup_active = false
    state.story_popup_text = nil
    state.story_popup_ante = nil
end

-- Full reset (for testing)
function Story.reset_all()
    state.story_shown = {}
    Story.reset_transient()
end

return Story
