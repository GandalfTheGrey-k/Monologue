--[[
    Monologue Data Module: Tauren Race
    PURE DATA TABLE. Key matches UnitRace("player") raceFile "Tauren".
    Lore: Mulgore, Thunder Bluff, High Chieftain Cairne Bloodhoof, the Earth Mother,
    the Kolkar centaur. WoW Forever canon only.

    Dialect format: see the top of Monologue_Translator.lua. A string value is one fixed swap;
    a list of strings is a set of variants, one picked at random (the last 3 are avoided).
    Tauren speak slowly and calmly, with reverence for the Earth Mother.
--]]

MonologueEngine.Data.Races["Tauren"] = {
    Dialect = {
        wordSwaps = {
            ["hello"] = { "well met", "peace to you", "greetings", "walk well" },
            ["hi"] = { "well met", "peace", "greetings" },
            ["goodbye"] = { "walk with the Earth Mother", "go in peace", "until we meet again", "may the earth guide you" },
            ["yes"] = { "yes", "it is so", "indeed", "truly" },
            ["thanks"] = { "my thanks, kin", "the Earth Mother thanks you", "you have my gratitude" },
            ["friend"] = { "kin", "friend of the herd", "fellow walker" },
            ["friends"] = { "kin", "friends of the herd", "fellow walkers" },
            ["hurry"] = { "walk with purpose", "step lively", "move swiftly" },
            ["strong"] = { "strong", "mighty", "sturdy as the bluffs" },
            ["slow"] = { "steady", "patient", "unhurried" },
            ["danger"] = { "peril", "a threat", "trouble on the wind" },
            ["enemy"] = { "foe", "one who threatens the herd", "adversary" },
            ["fight"] = { "struggle", "battle", "clash" },
            ["great"] = { "mighty", "grand", "noble" },
        },
        phraseSwaps = {
            ["thank you"] = { "the Earth Mother thanks you", "my thanks, kin", "you honor me" },
            ["thanks a lot"] = { "you honor me greatly", "my deepest thanks, kin" },
            ["watch out"] = { "be wary", "take heed", "mind the wind" },
            ["be careful"] = { "walk with care", "tread lightly", "go gently" },
            ["good job"] = { "well done, kin", "a worthy effort", "the spirits are pleased" },
            ["let's go"] = { "let us walk", "onward, together", "the path calls" },
            ["on my way"] = { "I walk to you now", "I come, steady and sure", "on my way, kin" },
            ["good luck"] = { "may the Earth Mother guide you", "walk well", "may your hooves find the path" },
            ["good morning"] = { "may the sun greet you", "morning, kin", "a blessed dawn" },
            ["good night"] = { "rest well beneath the stars", "sleep, the earth holds you" },
            ["come on"] = { "come, kin", "do not linger" },
            ["help me"] = { "stand with me, kin", "I need the herd" },
            ["i don't know"] = { "I cannot say", "the spirits are silent" },
            ["i'm sorry"] = { "forgive me, kin", "the fault is mine" },
        },
        contractions = {
            -- Slow, deliberate cadence: contractions open up now and then
            ["can't"] = "cannot",
            ["don't"] = "do not",
            ["won't"] = "will not",
            ["it's"] = "it is",
            ["let's"] = "let us",
        },
        phonetics = {
            ["^gonna$"] = "going to",
            ["^wanna$"] = "wish to",
        },
        interjections = { "it is said", "truly", "as the elders say", "kin" },
        openers = {
            "Hear me, kin,",
            "Earth Mother guide me,",
            "By the Earth Mother,",
            "Listen,",
            "Walk with me,",
            "The elders say,",
            "Think on this,",
            "Peace,",
        },
        closers = {
            ", Earth Mother guide you.",
            ", so the elders say.",
            ", and the hunt goes on.",
            ", so it is.",
            ", walk well.",
            ", may the earth hold you.",
            ", as the winds allow.",
            ", for the herd.",
        },
    },
    GuildGreetings = {
        Standard = {
            "Well met, kin. The Earth Mother watches over this gathering.",
            "Walk with the Earth Mother, and let the hunt be good.",
            "Thunder Bluff stands strong on the strength of those who gather here.",
            "Peace and strength to all of you, friends.",
            "The Earth Mother watches over this gathering.",
            "Welcome, kin. Rest, and then we hunt.",
            "Walk with honor today. The ancestors are listening.",
            "Thunder Bluff sends its greetings, friends.",
        }
    },
    FriendGreetings = {
        Ally = {
            "{target}. The herd is stronger with you.",
            "Walk with me again, comrade.",
            "I am glad of your strength beside mine.",
            "The Earth Mother put good allies in my path.",
            "We stand together. As before.",
        },
        Default = {
            "Well met, {target}, kin of my heart. Walk with me a while.",
            "{target}! The Earth Mother smiles on this meeting.",
            "Peace, {target}. It is good to stand beside you.",
            "Welcome, {target}. My fire is yours.",
            "{target}, kin. The herd is stronger with you in it.",
            "{target}. The Earth Mother brings us together again.",
            "Well met, {target}. Sit, rest your feet.",
            "{target}! It warms my heart to see you.",
            "Peace, {target}. The plains are kinder with you here.",
        },
    },
    DuelWin = {
        "Well fought, {target}. No shame in a clash of strength.",
        "The Earth Mother lent me strength today, {target}.",
        "You fought bravely, {target}. Stand, and we will share a meal.",
        "A good test of strength, {target}.",
        "Well fought, {target}. You have a warrior's heart.",
        "The Earth Mother tests us both, {target}.",
        "Rise, {target}. There is no shame in falling.",
        "Strong, {target}. Very strong. But not today.",
    },
    DuelLoss = {
        "You were stronger today, {target}. I honor you.",
        "Well fought, {target}. I will learn from this.",
        "The earth shifts, {target}. Today it favors you.",
        "A fine duel, {target}. My thanks for the lesson.",
        "You are swift, {target}. I am humbled.",
        "Well struck, {target}. The Earth Mother smiles on you.",
        "A good lesson, {target}. Thank you.",
        "Even the kodo stumbles, {target}. Well fought.",
    },
    PvPLines = {
        FirstClash = {
            "You walk on sacred ground in {zone}, {target}. Turn back.",
            "I do not seek this fight, {target}, but I will not run from it.",
            "You will find no welcome in {zone}, {target}.",
            "The plains stand against you, {target}.",
        },
        DejaVu = {
            "{zone} again. The Earth Mother grieves for this land.",
            "Another battle in {zone}. The spirits grow restless.",
            "{zone} again. The earth grows tired of blood.",
            "Too many have fallen in {zone}.",
        },
        Rematch = {
            "You return, {target}. The Earth Mother is patient; I am less so.",
            "Again? So be it.",
            "You return, {target}. The herd remembers.",
            "Again, {target}? So be it.",
        },
        Vendetta = {
            "I carry the memory of {lastzone}, {target}. The spirits do not forget.",
            "You bested me in {lastzone}. I will answer, {target}.",
            "The ancestors remember {lastzone}, {target}.",
            "{lastzone} weighs on me, {target}. Today it ends.",
        },
        Dominance = {
            "You have fallen before my hooves, {target}. Withdraw.",
            "A bull does not run from a calf, {target}. Go home.",
            "Stay down, {target}. This is not your day.",
            "You have fallen before me, {target}. Learn from it.",
        },
        Nemesis = {
            "{target}. The spirits have waited long for this. We finish what began in {lastzone}!",
            "By the Earth Mother, this feud ends today, {target}!",
            "{target}! By the Earth Mother, this ends!",
            "The thunder of the plains comes for you, {target}!",
        },
    },
    -- Racial Temperament Presets (My Voice tab). A preset replaces openers/closers, merges
    -- FriendGreetings, replaces BattleCry and may shift intensity by -1..+1.
    Presets = {
        EarthMotherPilgrim = {
            name = "Earth Mother's Pilgrim",
            blurb = "Gentle and devout, walks the plains in service of the Earth Mother.",
            dialectIntensity = -1,
            openers = {
                "The Earth Mother's blessing,",
                "Walk softly,",
                "Peace upon you,",
                "The land listens,",
                "As the plains whisper,",
                "In harmony,",
            },
            closers = {
                ", the Earth Mother watch over you.",
                ", may the earth hold you.",
                ", walk in peace.",
                ", as the grass bends.",
                ", the land remembers.",
                ", be at peace.",
            },
            FriendGreetings = {
                Default = {
                    "The Earth Mother's blessing upon you, {target}.",
                    "Well met, {target}. Walk beside me for a time.",
                    "{target}. May the plains be kind to you.",
                },
            },
            BattleCry = {
                "The Earth Mother guides my hoof!",
                "For the plains and the herd!",
                "Earth Mother, lend me strength!",
            },
        },
        PlainsHunter = {
            name = "Plains Hunter",
            blurb = "Patient and fierce, a spear-wielder who lives by the herds of Mulgore.",
            dialectIntensity = 0,
            openers = {
                "Steady,",
                "The wind carries,",
                "Track the herd,",
                "Hunt well,",
                "Wait,",
                "On the plains,",
            },
            closers = {
                ", the hunt is honest.",
                ", the wind agrees.",
                ", steady now.",
                ", the plains provide.",
                ", as the herd moves.",
                ", with patience.",
            },
            FriendGreetings = {
                Default = {
                    "{target}. Good hunting to you.",
                    "Well met, {target}. The herd is calm.",
                    "{target}. Share a fire with me?",
                },
            },
            BattleCry = {
                "For the herd!",
                "The hunt begins!",
                "Spear and hoof!",
            },
        },
        ElderSpeaker = {
            name = "Elder Speaker",
            blurb = "Slow, weighty and proverb-laden: speaks as if each word were counted.",
            dialectIntensity = -1,
            openers = {
                "As the elders say,",
                "Long ago,",
                "Remember,",
                "The old saying goes,",
                "Hear a thing,",
                "Patience,",
            },
            closers = {
                ", so the elders taught.",
                ", that is the way.",
                ", and the land agrees.",
                ", as it has always been.",
                ", mark it well.",
                ", and be wise.",
            },
            FriendGreetings = {
                Default = {
                    "{target}. Come, listen. The tale is long and worth it.",
                    "Well met, {target}. Young as you are, I see strength.",
                    "{target}. The elders would smile at your path.",
                },
            },
            BattleCry = {
                "As the elders taught, I stand!",
                "The old ways endure!",
                "Strength of the Earth Mother!",
            },
        },
    },
    EmoteReplies = {
        Wave = {
            "Peace, {target}.",
            "Earth Mother guide you, {target}.",
            "Well met, {target}.",
            "Walk with the wind, {target}.",
        },
        Bow = {
            "The Earth Mother honors your respect, {target}.",
            "And I bow to you, {target}.",
            "Rise, {target}. We are equals here.",
            "Your manners honor your people, {target}.",
        },
        Cheer = {
            "Ha! Well done, {target}!",
            "The plains rejoice, {target}!",
            "Thunder and joy, {target}!",
            "May your spirit soar, {target}!",
        },
        Toast = {
            "To the Earth Mother, {target}.",
            "To the plains and the herd, {target}!",
            "To friendship, {target}.",
            "May your cup be as deep as the lakes, {target}.",
        },
        Hug = {
            "Ha! Careful, {target}, I am large.",
            "Come here, {target}. A proper tauren embrace.",
            "You are always welcome, {target}.",
            "Gently, {target}. The horns.",
        },
        Rude = {
            "The Earth Mother sees your heart, {target}. Mend it.",
            "Calm yourself, {target}.",
            "I will forgive that, {target}. Once.",
            "Words are wind, {target}. Mine is stronger.",
        },
        Challenge = {
            "You challenge a tauren, {target}? Brave.",
            "Very well, {target}. Choose your ground.",
            "The plains have tested stronger, {target}.",
            "Ha! Come, {target}. Let the earth decide.",
        },
    },
    RivalOpeners = {
        Vendetta = {
            "{target}! The ancestors cry out for {lastzone}!",
            "For {lastzone}, {target}! Earth Mother, guide me!",
            "{target}. {lastzone} ends here.",
            "I have not forgotten {lastzone}, {target}.",
        },
        SwornFoe = {
            "Again, {target}? The herd does not flee.",
            "{target}! You will learn this time.",
            "You return, {target}. As the storm does.",
            "{target}. The plains remember you.",
        },
        Nemesis = {
            "{target}! THE EARTH MOTHER DEMANDS IT!",
            "For Thunder Bluff! {target}, your end!",
            "{target}! The stampede comes!",
            "Enough, {target}! This is the last time!",
        },
        Default = {
            "For the Earth Mother, {target}!",
            "Stand aside, {target}!",
            "The plains strike, {target}!",
            "Feel the thunder, {target}!",
        },
    },
    StanceGreetings = {
        WARM = {
            "Peace, {target}. The {targetrace} are always welcome among the herd.",
            "Well met, {target}. May the Earth Mother bless your people.",
            "{target}. Your kind is a friend of Thunder Bluff.",
            "Walk with the wind, {target}.",
        },
        ADMIRING = {
            "{target}. Your people's strength reminds me of the ancient ones.",
            "An honor, {target}. The {targetrace} have much wisdom.",
            "{target}. I have learned much from your kind.",
            "The Earth Mother made your people strong, {target}.",
        },
        PLAYFUL = {
            "{target}! So small! Shall I carry you?",
            "Ha! {target}! You walk fast for such short legs.",
            "{target}! You look hungry. Eat with us.",
            "Ho, {target}! Try not to get stepped on.",
        },
        WARY = {
            "{target}. The herd watches strangers.",
            "Hm. {target}. Show me your heart.",
            "{target}. I will wait and see.",
            "{target}. Peace. For now.",
        },
        GRUFF = {
            "{target}. Move along.",
            "{target}. I have no time today.",
            "Hmph. {target}. Not now.",
            "{target}. Leave me to my thoughts.",
        },
        DISDAINFUL = {
            "{target}. Your people have forgotten the land.",
            "Ah, one of the {targetrace}. So much hurry, so little peace.",
            "{target}. You know nothing of the Earth Mother.",
            "{target}. The herd has seen your kind come and go.",
        },
        Orc = {
            WARM = {
                "{target}. Thrall helped us when no one else would.",
                "Well met, {target}. The orcs gave us a home in the Horde.",
                "{target}! Strength and honor, brother of the Horde.",
            },
            GRUFF = {
                "{target}. Less fury. More patience.",
                "Hmph. {target}. Your people are always angry.",
                "{target}. Lower your voice. The kodo are sleeping.",
            },
        },
        Troll = {
            WARM = {
                "{target}! Your people's laughter is good medicine.",
                "Well met, {target}. The loa and the Earth Mother, side by side.",
                "{target}. Wise in spirit, light in heart.",
            },
            GRUFF = {
                "{target}. Leave my totems alone.",
                "Hmph. {target}. Too much mischief.",
                "{target}. Not every spirit needs to be bargained with.",
            },
        },
        Scourge = {
            WARM = {
                "{target}. The Earth Mother does not turn away the lost.",
                "Peace, {target}. Your people suffered much.",
                "{target}. You are welcome here, whatever you are.",
            },
            GRUFF = {
                "{target}. Your plagues sicken the land.",
                "Hmph. {target}. The dead should rest.",
                "{target}. Keep your poisons from the plains.",
            },
        },
    },
    -- Racial combat openers: mixed into signature-move pull lines now and then
    -- (homeland, kin and pride; the class and spell pools cover the rest)
    CombatOpeners = {
        "Earth Mother, give me strength.",
        "For Mulgore, and the herds.",
        "The plains are wide. There is nowhere to hide.",
        "Cairne would stand his ground. So will I.",
        "Hooves set. Horns down.",
        "Walk with the Earth Mother, or fall to her.",
        "Thunder Bluff sees far. It sees you.",
        "I would rather be at peace. You chose otherwise.",
        "The spirits of the hunt run with me.",
        "Slow to anger. Slow to stop.",
        "An Ha. Let it be quick.",
    },
    -- Clans / lineages: chosen on the My Voice tab (only this race's appear). Combat lines
    -- join pull lines now and then, Greet lines friendly greetings, Idle lines idle chatter.
    Clans = {
        { key = "Bloodhoof", name = "Bloodhoof Tribe",
            Combat = {
                "For Cairne and the Bloodhoof.",
                "Mulgore stands behind me.",
                "The Bloodhoof do not break.",
                "Earth Mother, steady my hooves.",
            },
            Greet = {
                "The Bloodhoof welcome you, {target}.",
                "Walk with the Earth Mother, friend.",
                "Sit. There is always room at a Bloodhoof fire.",
            },
            Idle = {
                "The kodo herds will be moving soon.",
                "Bloodhoof Village smells of bread this time of year.",
                "Cairne says patience wins more than strength.",
            },
        },
        { key = "Runetotem", name = "Runetotem Tribe",
            Combat = {
                "The spirits of the land rise with me.",
                "Hamuul taught me nature's anger.",
                "Root and stone, answer me.",
                "The balance demands this.",
            },
            Greet = {
                "Peace to you, {target}. The land speaks well of you.",
                "The Runetotem greet you, friend.",
                "Walk lightly. The earth notices.",
            },
            Idle = {
                "The Moonglade calls me back soon.",
                "The land is restless today.",
                "Some herbs grow only after rain. Remember that.",
            },
        },
        { key = "Grimtotem", name = "Grimtotem Exile",
            Combat = {
                "I left Magatha's tribe. Not her fury.",
                "Grimtotem blood runs hot.",
                "Exile made me harder.",
                "No tribe to protect. Only me.",
            },
            Greet = {
                "{target}. Few trust a Grimtotem. I thank you.",
                "I left the Grimtotem. Judge me by what I do.",
                "Well met. Do not fear the markings.",
            },
            Idle = {
                "Thousand Needles still haunts my sleep.",
                "Magatha's whispers reach even here.",
                "An exile learns to sleep lightly.",
            },
        },
    },
}
