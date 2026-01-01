------------------------------------------------------------
-- STORY DEFINITIONS
-- Dialogue and narrative beats for each Ante
------------------------------------------------------------

local StoryDefs = {}

StoryDefs.antes = {
    [1] = {
        boss_name = "The Welcome",
        intro = {
            "Welcome to the Liminal Lounge. Leave your coat, keep your soul... for now.",
            "First time? Try not to stain the carpet when you dissolve.",
            "The rules are simple: Spin, win, and pray the House doesn't notice you.",
            "You're Ante 1. Fresh meat. Let's see how long you last.",
            "I'm Luna. I'll be your dealer until... well, until you run out."
        },
        win = {
            "Beginner's luck? Or something else?",
            "Don't get cocky. The machine is just warming up.",
            "You survived the lobby. Cute.",
            "Satisfactory. But the rent is due soon.",
            "Hmm. You might actually be worth watching."
        },
        loss = {
            "Just like the rest. Another cherry for the machine...",
            "House wins. House always wins.",
            "Don't worry, you'll make a lovely decorative plant.",
            "Insufficient funds. Insufficient soul.",
            "And... scene. Better luck in the next life."
        },
        story = "Most people panic by round 3. You... you're calm. I've been dealing cards here for what feels like a thousand years. I've seen a million faces, and they all end up on the reels eventually. Don't make me add yours to the collection."
    },
    [2] = {
        boss_name = "The Miser",
        intro = {
            "We're entering the Miser's floor. Everything costs more here.",
            "Inflation is a killer in Purgatory. Shop prices just doubled.",
            "Hope you saved your pocket change. The House is feeling greedy.",
            "The Miser hates charity. You'll have to pay a premium to survive.",
            "Tighten your belt, darling. It's going to be an expensive climb."
        },
        win = {
            "You're thrifty. I like that.",
            "Most people go broke here. You... you're interesting.",
            "Managed the budget well. The Miser is weeping.",
            "Impressive economy. You might have a head for numbers.",
            "You spent wisely. A rare trait among the damned."
        },
        loss = {
            "Ran out of funds? Should have budgeted better.",
            "The economy claims another victim.",
            "Bankruptcy is fatal here.",
            "You can't buy freedom with empty pockets.",
            "The Miser takes what's left. Which is everything."
        },
        story = "The Miser who runs this floor... he wasn't always a monster. He was a man who couldn't let go of a single coin. Now he's just a rule in the system. That's what happens here. You obsess over something until it consumes you, and then... *poof*. You become a modifier."
    },
    [3] = {
        boss_name = "The Blind",
        intro = {
            "Watch your step. The lighting here is... unreliable.",
            "One reel is hidden. You'll have to play by feel.",
            "Trust your gut, not your eyes. The House loves illusions.",
            "Can you win without seeing the cards? Let's find out.",
            "The Blind floor. Where hope is the only thing you can see."
        },
        win = {
            "You have good instincts. Or devilish luck.",
            "Maybe you can see things I can't.",
            "You navigated the dark perfectly.",
            "The Blind couldn't fool you.",
            "I'm starting to think you're not just guessing."
        },
        loss = {
            "Stumbled in the dark. It happens to the best of us.",
            "Blind luck only goes so far.",
            "You didn't see that coming, did you?",
            "Lost in the shadows.",
            "Lights out. Permanently."
        },
        story = "I used to have trouble seeing in the dark here. But after the first century, your eyes adjust. Or maybe the darkness just gets inside you. You're doing well, though. Better than the last one. He... well, let's just say he's the 'Bell' symbol now."
    },
    [4] = {
        boss_name = "The Taxman",
        intro = {
            "The Taxman cometh. And he's taking a cut.",
            "The House hates hoarders. They'll drain your credits every round.",
            "Spend it or lose it, honey. The tax is mandatory.",
            "Nothing is certain but death and... well, you know.",
            "Keep your balance moving. Standing still is expensive."
        },
        win = {
            "You survived the audit. Barely.",
            "I haven't seen someone beat the Taxman in eons.",
            "Loophole found. You kept your earnings.",
            "The Taxman leaves empty-handed. I love to see it.",
            "You're good at evasion. Useful skill."
        },
        loss = {
            "Audited into oblivion. A tragic way to go.",
            "Garnished to death.",
            "The House collected its due.",
            "You couldn't pay the toll.",
            "Liquidated assets. Liquidated player."
        },
        story = "We're getting higher up. The air is thinner here. Do you feel it? The weight of the House pressing down? I remember when I first arrived, I tried to calculate the odds of leaving. I stopped counting after the first million spins. But you... the math around you is weird."
    },
    [5] = {
        boss_name = "The Cursed",
        intro = {
            "Do you see those symbols on the reels? One is... defective.",
            "One symbol is worthless now. Don't rely on it.",
            "The machine is rejecting a specific frequency. Watch out.",
            "A curse has settled on the reels. Avoid the tainted symbol.",
            "Something's rotting in the machine. Play around it."
        },
        win = {
            "You're not like the others, are you?",
            "You look at the machine differently. You see the patterns.",
            "The curse didn't touch you.",
            "Clean win on a dirty floor.",
            "You stepped right over the trap."
        },
        loss = {
            "Join them. Become part of the reel.",
            "The curse spreads. You're next.",
            "Rotten luck. Literally.",
            "You held onto the dead weight too long.",
            "Consumed by the glitch."
        },
        story = "I should tell you the truth. The machine... it's not just code. Those symbols? The Cherry, the Lemon, the Seven? They used to be people. Gamblers. Like you. The 'Cursed' symbol you just dealt with? That was a baker named Thomas who bet his bakery and lost. Don't let the machine eat you too."
    },
    [6] = {
        boss_name = "The Gambler",
        intro = {
            "No small bets allowed on this floor. High rollers only.",
            "High risk, high reward. That's how I lost my freedom.",
            "Put your money where your mouth is. 50% minimum.",
            "Scared money makes no money. Bet big or go home.",
            "The Gambler wants to see you sweat. Show him your chips."
        },
        win = {
            "Bold. Very bold. I remember that feeling.",
            "I remember when I had that kind of courage.",
            "You looked the House in the eye and didn't blink.",
            "A true gambler. For better or worse.",
            "Respect. You put it all on the line."
        },
        loss = {
            "Folded under pressure. Disappointing.",
            "You blinked.",
            "The stakes were too high for you.",
            "Busted. The classic way to go.",
            "You didn't have the stomach for it."
        },
        story = "This floor... it reminds me of my mistake. I had a Royal Flush. I was so sure. I bet my life, my name, my future. And the House turned over five Jokers. That's when I learned: The House doesn't play by the rules. It *is* the rules. But maybe rules can be broken."
    },
    [7] = {
        boss_name = "The Mirror",
        intro = {
            "Look in the mirror. What do you see?",
            "Everything is backwards here. Paylines are flipped.",
            "Up is down. Left is right. Don't get dizzy.",
            "I see myself in you. That... worries me deeply.",
            "The Mirror distorts everything. Keep your head straight."
        },
        win = {
            "You broke the mirror. Seven years of bad luck for the House.",
            "Maybe your fate isn't reflected in mine after all.",
            "You saw through the inversion.",
            "Reflections can't hurt you if you don't flinch.",
            "You're real. The rest is just smoke and mirrors."
        },
        loss = {
            "Trapped in the reflection forever.",
            "Shattered.",
            "You couldn't tell real from fake.",
            "The mirror claims another face.",
            "Lost in the funhouse."
        },
        story = "You remind me of myself before the fall. Hopeful. Skilled. Stupid. I'm starting to think... maybe I shouldn't be just watching you. Maybe I should be helping you. The House monitors my dealing, but... I know a few tricks it doesn't."
    },
    [8] = {
        boss_name = "The Void",
        intro = {
            "It feels empty here, doesn't it? The air is dead.",
            "The Void eats magic. One of your Joker slots is gone.",
            "You'll have to win on skill alone. No crutches.",
            "Something is missing. Can you feel the absence?",
            "The Void is hungry. Don't let it take your best cards."
        },
        win = {
            "You filled the void with sheer luck.",
            "My heart is beating fast. Why?",
            "You didn't need that slot anyway.",
            "The Void choked on your success.",
            "Impossible. You beat the nothingness."
        },
        loss = {
            "Consumed by the nothingness.",
            "Deleted.",
            "Into the abyss with you.",
            "The Void is full now.",
            "You simply ceased to be."
        },
        story = "Listen closely. The symbols are souls, yes. But the Jokers? They are the deals made in the dark. 'The Necromancer', 'The High Roller'... they are aspects of the House's power. By using them against it, you're using its own weapons. Keep doing that. It hates it."
    },
    [9] = {
        boss_name = "The Flood",
        intro = {
            "The House is angry. It's expanding the board.",
            "More rows, but the targets are astronomical. It wants you to drown.",
            "Please... be careful. I don't want you to lose now.",
            "The floodgates are open. Swim or sink.",
            "It's trying to overwhelm you with data. Focus."
        },
        win = {
            "You're actually doing it. You're swimming.",
            "You might actually beat the House.",
            "The Flood recedes. You're still standing.",
            "I've never seen anyone get this far.",
            "Keep going! Don't stop!"
        },
        loss = {
            "Drowned in the numbers. I'm sorry.",
            "Washed away.",
            "The current was too strong.",
            "Another one lost to the depths.",
            "I tried to warn you..."
        },
        story = "I've checked the records. No one has reached Ante 10 in three hundred years. The management is getting nervous. I can feel the walls vibrating. They're going to try to starve you out next. Get ready."
    },
    [10] = {
        boss_name = "The Drought",
        intro = {
            "They're cutting off our resources. The taps are dry.",
            "Fewer spins. Every click needs to count. Precision is key.",
            "Focus. We're so close. Don't waste a single movement.",
            "The Drought is here. No wasted spins allowed.",
            "Efficiency is your only water in this desert."
        },
        win = {
            "Water from a stone! Miracle worker!",
            "I'm starting to believe... maybe I can leave too?",
            "You squeezed every drop of luck out of that machine.",
            "The Drought is broken. Rain falls.",
            "We're doing this. We're really doing this."
        },
        loss = {
            "Ran dry. We were so close...",
            "Thirst took you.",
            "Dust to dust.",
            "Not enough momentum.",
            "The well is empty."
        },
        story = "Do you know why I'm trapped here? I didn't just lose. I cheated. I tried to rig the game against the House. Irony is, now I'm the one rigging it *for* the House. But you... you're breaking the game just by playing it. You're the glitch I've been waiting for."
    },
    [11] = {
        boss_name = "The Chaos",
        intro = {
            "The reality of the Lounge is breaking down.",
            "Symbols are shifting. The machine is glitching hard.",
            "Hold on tight to your sanity! Physics is optional here.",
            "The House is panicking. It's throwing chaos at you.",
            "Order is gone. Only luck remains."
        },
        win = {
            "You ordered the chaos! Masterful!",
            "The door is visible. Just a little further!",
            "You surfed the glitch right to the exit.",
            "Chaos theory proved. You win.",
            "Nothing makes sense, but you won anyway!"
        },
        loss = {
            "Lost in the noise. Goodbye, friend.",
            "Scrambled.",
            "Entropy wins.",
            "Disintegrated by the glitch.",
            "You lost your frequency."
        },
        story = "The House is shaking. Can you feel it? The neon is flickering. The logic circuits are frying. You're hurting it. Good. Hurt it more. We have one more major barrier before the owner steps in. Don't falter now."
    },
    [12] = {
        boss_name = "The Gauntlet",
        intro = {
            "This is the security system. All of it. At once.",
            "The House is throwing everything at you. It's scared.",
            "I'm with you. Let's break this bank once and for all.",
            "Every curse, every rule, every trap. Dodge them all.",
            "The Gauntlet. If you survive this, you're a legend."
        },
        win = {
            "ONE. MORE. STEP.",
            "Are you ready to face the owner?",
            "You survived the Gauntlet. Unbelievable.",
            "The path is clear. To the Penthouse.",
            "My hands are shaking. We're going to the top."
        },
        loss = {
            "Stopped at the gates. Tragic.",
            "So close to the end.",
            "The security system caught you.",
            "You fought well. Rest now.",
            "The House protects its own."
        },
        story = "There's no turning back. The next floor is the Penthouse. Ante 13. Legend says if you beat it, the whole
        casino dissolves. If you lose... well, I'll be dealing your soul to the next player. But I'm betting on you. I'm betting everything."
    },
    [13] = {
        boss_name = "Luna Unchained",
        intro = {
            "This is it. The 13th Floor. The Penthouse.",
            "The House demands a sacrifice. A final test.",
            "I'm betting my freedom on your next spins.",
            "Don't let me down, partner. We leave together or not at all.",
            "The final wager. Your soul, my freedom, the House's ruin."
        },
        win = {
            "YOU DID IT! THE CHAINS ARE GONE!",
            "We're free... We're actually free.",
            "The House is crumbling! Look at the sky!",
            "You beat the devil at his own game.",
            "Thank you. Thank you for setting me free."
        },
        loss = {
            "I gambled everything... and lost again.",
            "So close to the sun...",
            "We almost made it.",
            "Trapped together. Forever.",
            "The House always... always... wins."
        },
        story = "..." -- No story text needed here, game ends or credits roll
    }
}

return StoryDefs