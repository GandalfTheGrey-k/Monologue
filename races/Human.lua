--[[
    Monologue Data Module: Human Race
    PURE DATA TABLE. Key matches UnitRace("player") raceFile "Human".
    Lore: Stormwind, Elwynn Forest, the Light, the Alliance. WoW Forever canon only.

    Dialect format: see the top of Monologue_Translator.lua. A string value is one fixed swap;
    a list of strings is a set of variants, one picked at random (the last 3 are avoided).
    Humans speak plainly and courteously, so the swaps are gentle and the cadence formal.
--]]

MonologueEngine.Data.Races["Human"] = {
    Dialect = {
        wordSwaps = {
            ["hello"] = { "well met", "good day", "greetings", "hail" },
            ["hi"] = { "well met", "good day", "hail" },
            ["goodbye"] = { "fare thee well", "safe travels", "farewell", "until next we meet" },
            ["bye"] = { "farewell", "safe travels", "fare thee well" },
            ["yes"] = { "aye", "indeed", "of course", "certainly" },
            ["thanks"] = { "my thanks", "much obliged", "I thank you" },
            ["friend"] = { "comrade", "companion", "good fellow", "friend" },
            ["friends"] = { "comrades", "companions", "good folk" },
            ["enemy"] = { "foe", "adversary", "scoundrel" },
            ["fight"] = { "battle", "skirmish", "clash", "fray" },
            ["strong"] = { "stalwart", "sturdy", "mighty" },
            ["gold"] = { "coin", "gold", "crowns" },
            ["great"] = { "splendid", "grand", "magnificent" },
            ["problem"] = { "trouble", "difficulty", "predicament" },
        },
        phraseSwaps = {
            ["thank you"] = { "my thanks", "I thank you kindly", "much obliged" },
            ["thanks a lot"] = { "many thanks", "I am in your debt" },
            ["watch out"] = { "look sharp", "mind yourself", "take care" },
            ["be careful"] = { "take care", "tread carefully", "mind your step" },
            ["good job"] = { "well done", "fine work", "splendidly done" },
            ["let's go"] = { "let us be off", "onward then", "shall we" },
            ["on my way"] = { "I'm on my way, friend", "I'm away at once", "coming straightaway" },
            ["good luck"] = { "fortune favor you", "the Light keep you", "good fortune" },
            ["good morning"] = { "good morrow", "a fair morning to you" },
            ["good night"] = { "good night, and rest well", "sleep well" },
            ["come on"] = { "come along", "hurry now" },
            ["help me"] = { "lend me aid", "I need aid" },
            ["i don't know"] = { "I could not say", "I haven't the faintest" },
            ["watch your back"] = { "keep your guard up", "eyes sharp" },
        },
        contractions = {
            -- A courteous, formal cadence: contractions open up now and then
            ["can't"] = "cannot",
            ["don't"] = "do not",
            ["won't"] = "will not",
            ["it's"] = "it is",
        },
        phonetics = {
            ["^gonna$"] = "going to",
            ["^wanna$"] = "want to",
        },
        interjections = { "mark you", "truly", "I say", "by the Light" },
        openers = {
            "Well met,",
            "By the Light,",
            "Hear me,",
            "Mark this,",
            "In Stormwind's name,",
            "Friend,",
            "Listen well,",
            "Truly,",
        },
        closers = {
            ", by the Light.",
            ", for the Alliance!",
            ", so say I.",
            ", in Stormwind's name.",
            ", mark my words.",
            ", good sir.",
            ", and that's the truth.",
            ", Light willing.",
        },
    },
    GuildGreetings = {
        Standard = {
            "Well met. Stormwind stands because of folk like you.",
            "The Light keep you, friend.",
            "Another day, another banner raised. Well met!",
            "For Stormwind and for each other. Good to see you all.",
            "The Light keep you, friends. Who's riding out today?",
            "Another day in Azeroth, and the guild's still standing. Good.",
            "Mind the roads, friends. The Defias are bold these days.",
            "Shoulder to shoulder, as always. Welcome back.",
        }
    },
    FriendGreetings = {
        Ally = {
            "{target}. Glad you're with me.",
            "Shoulder to shoulder again, friend.",
            "There's someone I'd trust with my back.",
            "Ready when you are. Same as always.",
            "The Alliance is stronger with you in it.",
        },
        Default = {
            "Well met, {target}! The Alliance is better with you in it.",
            "{target}! Good to see a friendly face!",
            "Ho, {target}! Come, share a bench by the fire!",
            "There you are, {target}! Fine day for an adventure!",
            "Hail, {target}! The Light keeps you well, I hope.",
            "{target}! Good to see a friendly face on the road.",
            "Well met, {target}! Elwynn is a little brighter with you in it.",
            "{target}, old friend! Walk with me a while?",
            "There you are, {target}. I was hoping our paths would cross.",
        },
    },
    DuelWin = {
        "Well fought, {target}! A fine duel!",
        "A close one, {target}! Good sport!",
        "Honor to you, {target}. Another round some day?",
        "The Light favored me today, {target}. Well fought!",
        "Well fought, {target}! You made me earn that one.",
        "A fine bout, {target}. Again sometime?",
        "You held your ground well, {target}. My hat's off to you.",
        "That was close, {target}. Too close!",
    },
    DuelLoss = {
        "You bested me fair, {target}! Well fought!",
        "A good duel, {target}. I'll be back stronger.",
        "Well struck, {target}! My honor stands, if bruised.",
        "The Light favors you today, {target}. Congratulations!",
        "Well struck, {target}. I yield!",
        "You've a sharp blade, {target}. Lesson learned.",
        "Ha! You had me there, {target}. Well done.",
        "Next time, {target}. Next time it's mine.",
    },
    PvPLines = {
        FirstClash = {
            "Draw your steel, {target}. {zone} is no place to linger.",
            "You've chosen a poor place to stand, {target}.",
            "For the Alliance! Stand and fight, {target}!",
            "You're a long way from home, {target}. Turn back.",
        },
        DejaVu = {
            "{zone} again. Blood keeps getting spilled on this ground.",
            "Another fight in {zone}. Will it never end?",
            "{zone} runs red again. Will it ever end?",
            "Every season brings more of you to {zone}.",
        },
        Rematch = {
            "Back for another go, {target}? So be it.",
            "We meet again. The Light favors the stubborn.",
            "You again, {target}? Then let's finish it.",
            "I know your face, {target}. Let's settle this.",
        },
        Vendetta = {
            "I haven't forgotten what happened back in {lastzone}, {target}!",
            "You bested me in {lastzone}. Not today, {target}!",
            "You remember {lastzone}, {target}? I do.",
            "I've waited since {lastzone} for this, {target}.",
        },
        Dominance = {
            "You've fallen to me before, {target}. Walk away while you can.",
            "Stormwind's steel has your measure, {target}.",
            "Again, {target}? You've fallen to me before.",
            "Yield, {target}. You know how this ends.",
        },
        Nemesis = {
            "{target}! Our feud ends here. I'll send you back to {lastzone}!",
            "Again, {target}? Every road leads back to you. Not this time!",
            "By the Light, {target}, this ends today!",
            "No more running, {target}. For Stormwind!",
        },
    },
    -- Racial Temperament Presets (My Voice tab). A preset replaces openers/closers, merges
    -- FriendGreetings, replaces BattleCry and may shift intensity by -1..+1.
    Presets = {
        NobleOfStormwind = {
            name = "Noble of Stormwind",
            blurb = "Courtly and proper, a Stormwind noble with a taste for ceremony.",
            dialectIntensity = 0,
            openers = {
                "By the Light and the Crown,",
                "Do attend,",
                "If I may,",
                "With the King's favor,",
                "Most assuredly,",
                "In good company,",
            },
            closers = {
                ", if you please.",
                ", as befits Stormwind.",
                ", with respect.",
                ", by the Crown.",
                ", and so it is.",
                ", most civilly.",
            },
            FriendGreetings = {
                Default = {
                    "Good day, {target}. Stormwind is the brighter for your presence.",
                    "{target}! A pleasure, a genuine pleasure.",
                    "Well met, {target}. Do allow me to offer you my arm.",
                },
            },
            BattleCry = {
                "For the Crown and for Stormwind!",
                "By the Light, stand firm!",
                "For the King!",
            },
        },
        WeatheredSoldier = {
            name = "Weathered Soldier",
            blurb = "Dry, tired and loyal: a veteran of the Second War who has seen enough.",
            dialectIntensity = 0,
            openers = {
                "Right,",
                "Look,",
                "Here's the thing,",
                "Straight talk,",
                "Let's be clear,",
                "Keep your head down,",
            },
            closers = {
                ", that's all there is to it.",
                ", and don't argue.",
                ", get on with it.",
                ", trust me on that.",
                ", I've seen worse.",
                ", that's the long and short.",
            },
            FriendGreetings = {
                Default = {
                    "{target}. Good to see you in one piece.",
                    "Easy, {target}. Stay sharp.",
                    "{target}, you made it. Come on, keep moving.",
                },
            },
            BattleCry = {
                "Steady, and hit them hard!",
                "For Stormwind, no retreat!",
                "Hold the line!",
            },
        },
        WestfallFarmhand = {
            name = "Westfall Farmhand",
            blurb = "Cheerful, plain-spoken and hardworking, with dirt under the nails.",
            dialectIntensity = 1,
            openers = {
                "Well, I'll be,",
                "Shucks,",
                "Say now,",
                "Right neighborly of you,",
                "Gosh,",
                "I reckon,",
            },
            closers = {
                ", and that's a fact.",
                ", or so they say.",
                ", honest as the harvest.",
                ", by my reckoning.",
                ", good as gold.",
                ", plain and simple.",
            },
            FriendGreetings = {
                Default = {
                    "Well howdy, {target}! Come sit a while!",
                    "{target}! Heard you were around; good to see you!",
                    "Why, {target}! Always glad to see a friendly face.",
                },
            },
            BattleCry = {
                "Time to bring in the harvest!",
                "For hearth and home!",
                "This'll be a bumper crop of trouble!",
            },
        },
    },
    -- Cross-race stance greetings: StanceGreetings[TargetRace].WARM / .GRUFF.
    -- Tokens: {target} (name) and {targetrace} (their race).
    StanceGreetings = {
        Dwarf = {
        WARM = {
            "{target}! Ironforge's finest. Dwarven steel has saved more of us than we like to admit.",
            "Good day, {target}. The {targetrace} and humans have always stood shoulder to shoulder.",
        },
        GRUFF = {
            "{target}. A {targetrace}. Don't start in on the ale, will you?",
            "Hmph. {target}. Stand back; I won't have beards in my soup.",
        },
        },
        NightElf = {
        WARM = {
            "{target}. Your people's watch in the woods has kept more safe than we ever knew.",
            "Well met, {target}. Teldrassil is a marvel; I'd love to hear of it.",
        },
        GRUFF = {
            "{target}. A {targetrace}. So grand, so far above us. Well.",
            "Mind yourself, {target}. We shorter-lived folk do not forget a slight.",
        },
        },
        Orc = {
        WARM = {
            "{target}. We have a history, you and I; but I'll judge a {targetrace} by what they do.",
            "Well met, {target}. Peace is a fragile thing; let us tend it.",
        },
        GRUFF = {
            "{target}. A {targetrace}. I remember the Second War. Keep your distance.",
            "Not so close, {target}.",
        },
        },
        ADMIRING = {
            "{target}, your people's courage is the stuff of songs in Stormwind.",
            "An honor, {target}. The {targetrace} have shown us much.",
            "{target}! I've always admired your kind.",
            "Well met, {target}. Stormwind owes your people more than it says.",
        },
        PLAYFUL = {
            "{target}! Try not to get lost in Stormwind again.",
            "Ah, {target}. Come to show us how it's really done?",
            "{target}! Still taller than me in the stories, I see.",
            "Well, if it isn't {target}. Behave, now.",
        },
        WARY = {
            "{target}. Keep your hands where I can see them.",
            "Hmm. {target}. I'll trust you when you've earned it.",
            "{target}. Stormwind's watching. So am I.",
            "Easy, {target}. We'll see.",
        },
        DISDAINFUL = {
            "{target}. How... rustic.",
            "Oh. One of the {targetrace}. Charming.",
            "{target}. Do try to keep up with civilized folk.",
            "{target}. I suppose every city needs its visitors.",
        },
        Gnome = {
            WARM = {
                "{target}! Gnomeregan will rise again, and Stormwind will help.",
                "Well met, {target}! Your inventions saved my hide more than once.",
                "{target}! Fine work in Tinker Town, I hear.",
            },
            GRUFF = {
                "{target}. Keep your gadgets away from my horse.",
                "Hmph. {target}. The last one of your contraptions caught fire.",
                "{target}. If it ticks, I don't want it near me.",
            },
        },
        WARM = {
            "Well met, {target}! Always glad to see one of the {targetrace} folk.",
            "{target}! A friend of the Alliance is a friend of mine.",
            "Good day, {target}. Your people have my respect.",
            "Hail, {target}! Safe roads to you.",
        },
        GRUFF = {
            "{target}. Keep moving.",
            "Hmph. {target}. Don't make trouble in my city.",
            "{target}. You've no friend in me.",
            "I'll be watching you, {target}.",
        },
    },
    EmoteReplies = {
        Wave = {
            "Well met, {target}!",
            "Good day to you, {target}!",
            "Hello there, {target}!",
            "Ho, {target}! Fair travels!",
        },
        Bow = {
            "You honor me, {target}.",
            "And my respects to you, {target}.",
            "Please, {target}, no ceremony needed.",
            "A gracious bow, {target}. Thank you.",
        },
        Cheer = {
            "Ha! Well said, {target}!",
            "For the Alliance, {target}!",
            "That's the spirit, {target}!",
            "Huzzah, {target}!",
        },
        Toast = {
            "To your health, {target}!",
            "To Stormwind, {target}!",
            "Cheers, {target}! Long may we stand!",
            "To good friends, {target}!",
        },
        Hug = {
            "Ha! Good to see you too, {target}!",
            "Easy now, {target}! Armor pinches.",
            "Missed you too, {target}.",
            "Alright, {target}, alright!",
        },
        Rude = {
            "Mind your manners, {target}.",
            "That's hardly called for, {target}.",
            "Watch yourself, {target}.",
            "I'll pretend I didn't see that, {target}.",
        },
        Challenge = {
            "A challenge, {target}? Name the time.",
            "Careful, {target}. I don't scare easily.",
            "Big words, {target}. Back them up.",
            "Ha! You'll have to do better than that, {target}.",
        },
    },
    RivalOpeners = {
        Vendetta = {
            "{target}! I haven't forgotten {lastzone}!",
            "For {lastzone}, {target}! Have at you!",
            "You'll answer for {lastzone}, {target}!",
            "{target}! Today we settle {lastzone}!",
        },
        SwornFoe = {
            "{target}, again? Good. I'm ready.",
            "Back for more, {target}? So be it!",
            "I know your tricks, {target}!",
            "Not this time, {target}!",
        },
        Nemesis = {
            "{target}! By the Light, this ends NOW!",
            "FOR STORMWIND! {target}, face me!",
            "{target}! No more running!",
            "This is for every fallen friend, {target}!",
        },
        Default = {
            "{target}! Have at you!",
            "Stand and fight, {target}!",
            "For the Alliance, {target}!",
            "On your guard, {target}!",
        },
    },
    -- Racial combat openers: mixed into signature-move pull lines now and then
    -- (homeland, kin and pride; the class and spell pools cover the rest)
    CombatOpeners = {
        "For Stormwind.",
        "For the king, and the people behind me.",
        "Elwynn raised me. You won't put me down.",
        "Light, steady my hand.",
        "Lordaeron fell. Not me. Not today.",
        "Stand fast. That's what we do.",
        "Arathor's blood still runs in us.",
        "I've walked from Goldshire to here. One more fight.",
        "Northshire never lost a farmhand to the likes of you.",
        "Shield up. Chin up. Forward.",
        "The Alliance holds.",
    },
    -- Clans / lineages: chosen on the My Voice tab (only this race's appear). Combat lines
    -- join pull lines now and then, Greet lines friendly greetings, Idle lines idle chatter.
    Clans = {
        { key = "Stormwind", name = "Stormwind Native",
            Combat = {
                "For Stormwind and the crown.",
                "Elwynn raised me tougher than you'd think.",
                "The Lion of Stormwind roars.",
                "Stormwind's walls were rebuilt. So was I.",
            },
            Greet = {
                "Well met, {target}. Long live the king.",
                "Good to see a friendly face out here.",
                "Stormwind's gates are always open to you.",
            },
            Idle = {
                "I could do with a Goldshire pie.",
                "The Trade District will be packed by now.",
                "Wonder if the stonemasons ever got paid.",
            },
        },
        { key = "Lordaeron", name = "Lordaeron Survivor",
            Combat = {
                "For Lordaeron. What's left of her.",
                "I watched my home burn. You're nothing.",
                "Terenas' kingdom deserves better than you.",
                "I survived the plague. I'll survive you.",
            },
            Greet = {
                "{target}. Every friendly face matters now.",
                "Well met. We few still standing.",
                "Lordaeron lives in those who remember it.",
            },
            Idle = {
                "The capital's walls still stand. Hollow now.",
                "I dream of Andorhal's harvest festival.",
                "Some days I can still smell the plague.",
            },
        },
        { key = "KulTiran", name = "Kul Tiran",
            Combat = {
                "Kul Tiras breeds sailors, not cowards.",
                "Proudmoore's fleet taught me this.",
                "Hold steady. Like a deck in a storm.",
                "Anchors aweigh.",
            },
            Greet = {
                "Ahoy, {target}. Fair seas to you.",
                "A friend of Theramore is a friend of mine.",
                "Well met. Lord Admiral Proudmoore would like you.",
            },
            Idle = {
                "The sea's calling. Always is.",
                "I've not seen Boralus in years.",
                "Land under my feet feels wrong some days.",
            },
        },
        { key = "Stromgarde", name = "Stromgarde / Arathi",
            Combat = {
                "Stromgarde endures.",
                "Arathor's oldest blood. Stand back.",
                "Thoras Trollbane fought harder than this.",
                "The highlands raised me strong.",
            },
            Greet = {
                "Well met, {target}. Stromgarde remembers its friends.",
                "Arathi greets you.",
                "Strength and honor, friend.",
            },
            Idle = {
                "Stromgarde Keep half in ruins. Still ours.",
                "The Syndicate infest the hills again.",
                "Arathor was the first kingdom. Never forget.",
            },
        },
        { key = "Dalaran", name = "Dalaran / Alterac Exile",
            Combat = {
                "Dalaran's lessons still burn in me.",
                "I've lost a city. I won't lose this.",
                "Alterac's shame isn't mine.",
                "Exile sharpens everything.",
            },
            Greet = {
                "{target}. Well met, from one wanderer to another.",
                "No city of mine to offer you. Just company.",
                "Kind of you to stop for an exile.",
            },
            Idle = {
                "Dalaran's dome still glows over the ruins.",
                "Alterac's betrayal still stings.",
                "One day I'll walk those violet streets again.",
            },
        },
    },
}
