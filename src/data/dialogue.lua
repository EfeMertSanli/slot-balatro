------------------------------------------------------------
-- DIALOGUE DEFINITIONS
-- Luna's speech lines organized by expression/context
------------------------------------------------------------

local Dialogue = {}

------------------------------------------------------------
-- EXPRESSION-BASED DIALOGUE
------------------------------------------------------------
Dialogue.expressions = {
    idle = {
        "Ready when you are~",
        "Feeling lucky?",
        "Take your time...",
        "The reels await...",
        "Let's see what fate has in store!",
    },
    watching = {
        "Here we go...",
        "Come on...",
        "...",
        "Spin, spin, spin!",
        "I can feel it!",
    },
    neutral = {
        "Better luck next spin!",
        "Don't give up!",
        "The reels are fickle...",
        "Keep trying!",
        "Not this time...",
    },
    small_win = {
        "Nice one!",
        "There you go!",
        "Good start~",
        "Not bad!",
        "A little something!",
    },
    good_win = {
        "Well played!",
        "Looking good!",
        "Keep it up!",
        "Ooh, nice!",
        "Getting warmer!",
    },
    big_win = {
        "Amazing!!",
        "Incredible spin!",
        "You're on fire!",
        "WOW!!",
        "That's what I'm talking about!",
    },
    jackpot = {
        "JACKPOT!!!",
        "UNBELIEVABLE!!",
        "MASSIVE WIN!!!",
        "I CAN'T BELIEVE IT!",
        "YOU DID IT!!!",
    },
    mega_jackpot = {
        "LEGENDARY!!!",
        "I CAN'T BELIEVE IT!!!",
        "HISTORY MADE!!!",
        "IMPOSSIBLE!!!",
        "THE STARS ALIGNED!!!",
    },
    losing_streak = {
        "Hang in there...",
        "Luck will turn...",
        "I believe in you...",
        "Don't lose hope...",
        "The next one, I feel it!",
    },
    broke = {
        "Maybe take a break?",
        "It's just a game...",
        "You'll bounce back...",
        "Oh no...",
        "Better luck next run...",
    },
    comeback = {
        "YES! I knew it!",
        "What a comeback!",
        "Never give up!",
        "FROM THE ASHES!",
        "That's the spirit!",
    },
    shop = {
        "See anything you like?",
        "Great choices today~",
        "Invest wisely!",
        "Upgrades await!",
        "Choose carefully...",
    },
    round_end = {
        "Good round!",
        "Ready for the shop?",
        "Let's see your options!",
        "Time to upgrade!",
        "Round complete!",
    },
    ante_complete = {
        "ANTE CLEARED!",
        "You made it!",
        "Choose your reward!",
        "Impressive!",
        "One step closer...",
    },
    game_over = {
        "Thanks for playing...",
        "See you next time...",
        "You did your best!",
        "The house always... well...",
        "Until we meet again...",
    },
}

------------------------------------------------------------
-- CONTEXT-SPECIFIC DIALOGUE
------------------------------------------------------------
Dialogue.contexts = {
    first_spin = {
        "Good luck on your first spin!",
        "Here we go! First spin!",
        "Let's see what the reels have in store!",
    },
    low_credits = {
        "Running a bit low...",
        "Careful with those bets...",
        "Every credit counts now!",
    },
    high_bet = {
        "High risk, high reward!",
        "A bold bet!",
        "Going all in?",
    },
    near_target = {
        "So close to the target!",
        "Just a bit more!",
        "You can do it!",
    },
    target_reached = {
        "TARGET REACHED!",
        "You made it!",
        "Success!",
    },
    last_spin = {
        "Final spin...",
        "This is it!",
        "Last chance...",
    },
    wild_appeared = {
        "A wild appeared!",
        "Skull power!",
        "Wild card!",
    },
    multiple_paylines = {
        "Multiple wins!",
        "Paylines everywhere!",
        "So many lines!",
    },
    new_joker = {
        "Nice addition!",
        "Good choice!",
        "That'll help!",
    },
    ante_start = {
        "New ante begins!",
        "Ready for the challenge?",
        "Let's do this!",
    },
}

------------------------------------------------------------
-- AFFINITY-BASED DIALOGUE
-- Different dialogue pools based on relationship level
------------------------------------------------------------
Dialogue.affinity = {
    stranger = {
        greeting = "Welcome to the Liminal Lounge.",
        tip = "Match symbols to win credits.",
        encouragement = "Keep trying.",
        warning = nil,  -- No warnings at this level
    },
    acquaintance = {
        greeting = "Oh, you're back. Let's see what you've got.",
        tip = "Watch out for losing streaks - they can drain you fast.",
        encouragement = "You're getting the hang of this.",
        warning = "I've got a bad feeling about this spin...",
    },
    friend = {
        greeting = "Good to see you again! Ready for another run?",
        tip = "Jokers can really turn the tide - choose wisely.",
        encouragement = "I believe in you!",
        warning = "Careful... the reels feel cold.",
        backstory = "I've been here a long time, you know. Centuries, maybe.",
    },
    close_friend = {
        greeting = "Hey! I was hoping you'd come back.",
        tip = "Sometimes it's worth saving credits for the shop.",
        encouragement = "We make a great team!",
        warning = "Wait! Let me help you...",
        backstory = "I wasn't always like this. I was a gambler once, like you.",
        mercy = "One more chance. Don't waste it.",
    },
    trusted = {
        greeting = "There you are! I've been looking forward to this.",
        tip = "I'll try to help wilds appear more often. Our little secret.",
        encouragement = "Together, we can beat this place!",
        warning = "Something's off... be careful!",
        backstory = "I bet my soul in this very casino. And I lost.",
    },
    confidant = {
        greeting = "My dearest friend. Let's show the house what we're made of.",
        tip = "Feel that? The wilds are drawn to you now.",
        encouragement = "I've never believed in anyone like I believe in you.",
        warning = "I sense danger... but I'm here with you.",
        backstory = "The house is alive. It feeds on hope and despair alike.",
        true_form = "You see me as I truly am now. Not just a dealer... but a friend.",
    },
    soulbound = {
        greeting = "Together, we've proven the impossible. Ready for more?",
        tip = "The reels bend to our combined will.",
        encouragement = "We are unstoppable!",
        warning = "Even now, I'll protect you.",
        backstory = "You freed me. Whatever happens next, we face it together.",
        victory = "We did it. We're both free now.",
    },
}

-- Story beats for specific antes
Dialogue.story = {
    [1] = "Welcome to Luna's Liminal Lounge. I'm Luna, your dealer. And your only friend here.",
    [3] = "You're doing well. Most don't make it this far. I've seen countless souls try...",
    [5] = "Can I tell you a secret? These symbols on the reels... they used to be people.",
    [7] = "I made a bet once, in this very seat. I wagered my soul. And I lost.",
    [10] = "You're different. Maybe... maybe you can actually do this.",
    [12] = "This is it. The house throws everything at you now. But I'm rooting for you.",
    [13] = "The final gamble. I'm betting my freedom alongside yours. Win, and we're both free.",
}

------------------------------------------------------------
-- HELPER FUNCTIONS
------------------------------------------------------------

-- Get random line for expression
function Dialogue.get_line(expression)
    local lines = Dialogue.expressions[expression]
    if lines and #lines > 0 then
        return lines[math.random(#lines)]
    end
    return "..."
end

-- Get affinity-specific dialogue
function Dialogue.get_affinity_line(affinity_pool, line_type)
    local pool = Dialogue.affinity[affinity_pool]
    if pool and pool[line_type] then
        return pool[line_type]
    end
    return nil
end

-- Get story dialogue for specific ante
function Dialogue.get_story_line(ante)
    return Dialogue.story[ante]
end

-- Get random line for context
function Dialogue.get_context_line(context)
    local lines = Dialogue.contexts[context]
    if lines and #lines > 0 then
        return lines[math.random(#lines)]
    end
    return nil
end

-- Get all expressions
function Dialogue.get_expression_names()
    local names = {}
    for name, _ in pairs(Dialogue.expressions) do
        table.insert(names, name)
    end
    return names
end

return Dialogue
