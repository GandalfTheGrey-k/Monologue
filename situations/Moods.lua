--[[
    Monologue Data Module: Moods
    PURE DATA TABLE.

    A mood is how your character feels today (/mono mood, or the My Voice tab). While a mood
    is set, about 40% of greetings, idle chatter, kill lines and low-health lines come from
    its pool below; the rest stay your normal voice. Moods also nudge how chatty you are
    (Weary and Grim speak a little less, Cheerful a little more).

      Greet   saying hello to a friendly player ({target} is their name)
      Idle    idle chatter on an out-of-combat ability press
      Kill    after a kill
      LowHP   badly hurt in a fight

    Shared by every race and class: keep them faction- and class-neutral.
    Follow VOICE_GUIDE.md: specific, in-world, calm.
--]]

MonologueEngine.Data.MoodLines = {
    Grim = {
        Greet = {
            "{target}. Still breathing, then.",
            "Evening, {target}. Bad roads today.",
            "{target}. Keep your blade close.",
            "Good to see a face that isn't trying to kill me, {target}.",
            "{target}. Don't ask how my day went.",
            "Still standing, {target}? Good.",
            "{target}. Watch the treeline.",
            "Hm. {target}.",
        },
        Idle = {
            "Every road out here ends in a grave. Most of them, anyway.",
            "Too quiet. I don't trust it.",
            "Another day, another fight.",
            "Somewhere in {zone}, something's sharpening its teeth.",
            "I've buried better than me.",
            "Nothing out here is free.",
            "Keep walking. Don't look back.",
            "The dark comes early in {zone}.",
        },
        Kill = {
            "One less.",
            "It's done.",
            "Stay down.",
            "That's how it ends. For all of us, one day.",
            "Clean it off. There'll be more.",
            "Quick. Better than it gave me.",
            "No joy in it. Just work.",
            "Next.",
        },
        LowHP = {
            "Not like this.",
            "Not today. Not here.",
            "I've had worse. I think.",
            "If I fall, make it cost them.",
            "Still standing. Barely.",
            "Blood in my eyes. Keep swinging.",
            "Hold. Just hold.",
            "Not done yet.",
        },
    },
    Weary = {
        Greet = {
            "Oh. {target}. Hello.",
            "{target}. Long day. Long week.",
            "Hey, {target}. Don't mind me, just tired.",
            "{target}. If you're going somewhere, I'm not.",
            "Evening, {target}. Or morning. I've lost track.",
            "{target}. Tell me there's an inn close by.",
            "Hello, {target}. My feet hate me.",
            "{target}. Good to see you. Sit a while?",
        },
        Idle = {
            "I could sleep standing up.",
            "Just one more, then I rest. That's what I said an hour ago.",
            "My boots have holes in the holes.",
            "{zone} goes on forever when you're this tired.",
            "Need a bed. Any bed.",
            "Is it supper yet?",
            "Five minutes. That's all I want. Five minutes.",
            "Every pack I carry gets heavier.",
        },
        Kill = {
            "Finally.",
            "There. Can I sit down now?",
            "Done. About time.",
            "That took longer than it should have.",
            "Phew. One more down.",
            "Good. Now let's be done for a while.",
            "That's enough for one day.",
            "Down it goes. So will I, soon.",
        },
        LowHP = {
            "Too tired for this.",
            "I can't keep this up.",
            "Somebody... a little help.",
            "Just need to breathe.",
            "Legs are going.",
            "Not much left in me.",
            "Should've rested when I had the chance.",
            "Come on. One more push.",
        },
    },
    Cheerful = {
        Greet = {
            "{target}! Good to see you!",
            "Well met, {target}! Lovely day, isn't it?",
            "{target}! Just the face I wanted to see.",
            "Ho there, {target}! Fancy meeting you here.",
            "{target}! How's the road treating you?",
            "Morning, {target}! Or afternoon. Either way, a good one.",
            "{target}! Come, walk with me a while.",
            "Hello, {target}! Isn't {zone} grand today?",
        },
        Idle = {
            "What a day for it.",
            "{zone} looks fine today.",
            "Good weather, good company. Can't complain.",
            "Something good's coming. I can feel it.",
            "I could walk all day like this.",
            "Every road's an adventure, if you ask me.",
            "Who wants to hear a song? No? Your loss.",
            "Ha. Life's not so bad.",
        },
        Kill = {
            "Ha! Got it!",
            "That's how it's done!",
            "Lovely. Next!",
            "Good fight!",
            "Not bad at all!",
            "And down it goes!",
            "Hah! Easy as you like!",
            "Another one! Keep 'em coming!",
        },
        LowHP = {
            "Ow! Well, that's a scratch.",
            "Still smiling! Mostly.",
            "Ha. That one stung!",
            "Bit of a pickle, this!",
            "I'll laugh about this later!",
            "Not my best moment!",
            "Ow, ow, ow. Fine. I'm fine!",
            "Still here! Still here!",
        },
    },
    Fierce = {
        Greet = {
            "{target}. Ready for a fight?",
            "{target}! Good. We'll need strong arms.",
            "{target}. You look like you could hit something.",
            "Well met, {target}. Point me at the enemy.",
            "{target}! Stand with me.",
            "{target}. Sharpen up. Trouble's close.",
            "{target}. Seen anything worth killing?",
            "Ha! {target}. Let's go hunting.",
        },
        Idle = {
            "Come on. Something come at me.",
            "My blood's up. Where's the fight?",
            "Too long without a scrap.",
            "{zone} had better have something worth fighting.",
            "Hands are itching.",
            "Waiting's the worst part.",
            "I didn't come out here to pick flowers.",
            "Let them come.",
        },
        Kill = {
            "Who's next?",
            "Down you go!",
            "Ha! More!",
            "That all you had?",
            "Next one!",
            "Stay down!",
            "Too easy!",
            "Bring me another!",
        },
        LowHP = {
            "Is that all?!",
            "Come on, then!",
            "I'm not done!",
            "Bleed me, then! I'll bleed you too!",
            "You'll have to do better!",
            "Not yet! NOT YET!",
            "Still standing! Come finish it!",
            "Pain's nothing!",
        },
    },
}
