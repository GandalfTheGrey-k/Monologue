--[[
    Monologue Data Module: Skyborne Race (Shen'dorei)
    PURE DATA TABLE. Key matches UnitRace("player") raceFile "Skyborne".
    Lore: Zephras Isle, the sky and the winds. A faction-choice race: Alliance Skyborne
    are arcane exiles of the High Order; Horde Skyborne are the Windshapers.

    DIALECT (see Monologue_Translator.lua for the full format):
      wordSwaps    one word -> a string, or a list of variants (one is picked at random,
                   avoiding the last 3 used)
      phraseSwaps  common expressions -> idioms; applied before wordSwaps, longest first
      contractions formal cadence: "can't" -> "cannot", applied only part of the time
      oaths        short exclamations (Greet / Fight / Hurt) said before a fitting line

    FactionSubtypes is keyed by the englishFaction string from UnitFactionGroup("player").
    The engine merges the matching subtype over the base race data. Inside a subtype the
    swap tables merge key by key (a subtype entry replaces the base entry for that key), and
    lists (oaths, greetings, lines) replace the base list outright.
    WoW Forever canon only.
--]]

MonologueEngine.Data.Races["Skyborne"] = {
    Dialect = {
        wordSwaps = {
            -- Greetings and farewells
            ["hello"] = { "fair winds", "skies be kind", "well met on the wind" },
            ["hi"] = { "fair winds", "skies be kind" },
            ["goodbye"] = { "fair skies", "safe flight", "until the winds meet us again" },
            ["thanks"] = { "my thanks", "well given" },
            ["yes"] = { "indeed", "truly", "so the wind says" },

            -- People
            ["friend"] = { "kindred", "wind-friend", "companion of the sky" },
            ["friends"] = { "kindred", "wind-friends" },
            ["ally"] = { "wing-mate", "kin-in-arms", "friend of the winds" },
            ["allies"] = { "wing-mates", "kin-in-arms" },
            ["enemy"] = { "foe", "storm-bringer", "rival of the wind" },
            ["enemies"] = { "foes", "storm-bringers" },

            -- Sky, wind and weather
            ["sky"] = { "heavens", "open air", "blue expanse" },
            ["wind"] = { "gale", "breeze", "draft" },
            ["storm"] = { "tempest", "squall", "thunderhead" },
            ["horizon"] = { "skyline", "far edge", "distant rim" },
            ["fly"] = { "soar", "take wing", "ride the wind" },
            ["flying"] = { "soaring", "riding the wind" },
            ["high"] = { "lofty", "high-flown", "sky-high" },

            -- Travel, danger, magic and the ground
            ["travel"] = { "journey", "wander" },
            ["danger"] = { "peril", "hazard" },
            ["magic"] = { "the arcane", "aether", "the art" },
            ["ground"] = { "earth", "lowlands", "land below" },
            ["earth"] = { "lowlands", "land below" },
        },
        phraseSwaps = {
            ["thank you"] = { "my thanks upon the wind", "well given, kindred", "gratitude to you" },
            ["thanks a lot"] = { "my deepest thanks", "well given indeed" },
            ["watch out"] = { "mind the winds", "keep your eyes aloft", "beware the squall" },
            ["look out"] = { "beware the squall", "eyes to the sky" },
            ["be careful"] = { "fly safe", "mind your wings", "tread the sky with care" },
            ["on my way"] = { "already aloft", "winging to you", "riding the wind to you" },
            ["good job"] = { "well flown", "fine work, wing-mate", "the skies applaud you" },
            ["well done"] = { "well flown", "a fine flight" },
            ["let's go"] = { "take wing", "up and away", "to the winds" },
            ["come here"] = { "come to me on the wind", "fly to me" },
            ["help me"] = { "lend me your wings", "wing to my aid" },
            ["good luck"] = { "fair winds to you", "may the skies favor you" },
            ["good morning"] = { "bright dawn to you", "fair dawn" },
            ["good night"] = { "soft winds tonight", "fair skies and sound sleep" },
            ["i'll be back"] = { "the winds will return me", "I'll ride the wind back" },
            ["what's up"] = { "how fly the winds", "what winds blow" },
        },
        contractions = {
            -- A formal, measured cadence: contractions open up now and then
            ["can't"] = "cannot",
            ["don't"] = "do not",
            ["won't"] = "will not",
            ["it's"] = "it is",
            ["let's"] = "let us",
            ["i'm"] = "I am",
        },
        phonetics = {
            ["^gonna$"] = "going to",
            ["^wanna$"] = "wish to",
        },
        -- Oaths: short exclamations said now and then before a greeting (Greet), a kill
        -- line or battle cry (Fight) or a low-health line (Hurt). Each stands as its own sentence.
        oaths = {
            Greet = { "Fair winds!", "Well met!", "Winds be kind to you!", "Hail, friend!" },
            Fight = { "By the winds!", "Ride the storm!", "Into the gale!", "For Zephras!", "Storm take you!" },
            Hurt = { "Storm's teeth!", "Not yet!", "Steady, steady!", "I've weathered worse!", "The winds hold me!" },
        },
    },
    GuildGreetings = {
        Standard = {
            "Fair winds, kindred. May the skies be kind to us.",
            "Zephras Isle is far below, but its winds still guide us.",
            "Rise with the dawn, and may your wings never tire.",
            "Fair winds, kindred. Together we soar.",
            "The sky is wide, and we are many. Welcome.",
            "May your wings be tireless today, friends.",
            "Zephras Isle would be proud of this gathering.",
            "The breeze is good. Let us make the most of it.",
        }
    },
    FriendGreetings = {
        Ally = {
            "{target}. Wing-mate. Good winds today.",
            "We fly together again.",
            "With you beside me, the storm feels smaller.",
            "Kindred in arms. Ready?",
            "The sky remembers good companions. So do I.",
        },
        Default = {
            "Fair winds, {target}! The sky is lighter with you in it.",
            "{target}! The winds said you'd come. Well met, kindred.",
            "Well met, {target}. Fly with me a while?",
            "There you are, {target}! Kindred of the sky, always welcome.",
            "{target}, my wing-mate! Shall we see what the winds bring?",
            "{target}! The winds have brought you back to me.",
            "Fair skies, {target}. It is good to see you.",
            "{target}! Come, the breeze is pleasant today.",
            "Kindred {target}. Well met beneath open skies.",
        },
    },
    DuelWin = {
        "Well flown, {target}! A fine duel.",
        "The winds favored me today, {target}. You fought bravely!",
        "A spirited bout, {target}! Rise, and we will go again.",
        "You pressed me hard, {target}. Well fought, wing-mate.",
        "The wind was at my back, {target}. Well flown.",
        "A fine bout, {target}. The sky smiles on us both.",
        "You flew well, {target}. Not well enough, today.",
        "Rise, {target}. The horizon waits for a rematch.",
    },
    DuelLoss = {
        "You were the swifter, {target}. Well flown!",
        "The winds favored you today, {target}. I yield with honor.",
        "A fine lesson, {target}. My thanks, wing-mate.",
        "Well struck, {target}. I will rise again.",
        "You were swift as the gale, {target}. I yield.",
        "Well struck, {target}. The winds turned against me.",
        "I am grounded, {target}. Well done.",
        "A lesson worth learning, {target}. My thanks.",
    },
    PvPLines = {
        FirstClash = {
            "You stand beneath open sky in {zone}, {target}. Choose your next step carefully.",
            "The winds warn me of you, {target}. Draw your weapon.",
            "The winds carried me to you, {target}.",
            "You are far from safe skies, {target}.",
        },
        DejaVu = {
            "{zone} again. Even the wind has begun to tire of this place.",
            "Another battle in {zone}. The skies keep their own count.",
            "{zone} again. The winds here taste of blood.",
            "So many storms over {zone}.",
        },
        Rematch = {
            "You return, {target}. The winds carried me back to you.",
            "Again, {target}? So be it.",
            "You return, {target}. As the tide does.",
            "Again, {target}? The gale is patient.",
        },
        Vendetta = {
            "I have not forgotten {lastzone}, {target}. The winds carry memory.",
            "You grounded me in {lastzone}. I rise again, {target}.",
            "The winds remember {lastzone}, {target}.",
            "{lastzone} still stings, {target}. It ends now.",
        },
        Dominance = {
            "You have fallen before me, {target}. Do not make me repeat it.",
            "The wind favors me, {target}. Go home.",
            "You have fallen before me, {target}. Fall again.",
            "The sky is mine, {target}.",
        },
        Nemesis = {
            "{target}. The winds have circled back to you at last. We end this where it began: {lastzone}!",
            "No more circling, {target}. This storm breaks today!",
            "{target}! The storm breaks on you today!",
            "By the winds, {target}, your flight ends!",
        },
    },
    FactionSubtypes = {
        Alliance = {
            subtypeName = "High Order",
            Dialect = {
                wordSwaps = {
                    ["magic"] = { "the Order's art", "the High Order's craft", "the arcane arts" },
                    ["mage"] = { "Order adept", "High Order scholar" },
                    ["teacher"] = { "master of the Order", "tutor" },
                    ["knowledge"] = { "the Order's lore", "lore" },
                    ["spell"] = { "working", "incantation" },
                },
                phraseSwaps = {
                    ["good job"] = { "well reasoned", "a worthy working" },
                    ["watch out"] = { "mind the wards", "beware the working" },
                    ["thank you"] = { "the Order thanks you", "my thanks, scholar" },
                },
            },
            GuildGreetings = {
                Standard = {
                    "Fair winds, kindred. The High Order is honored by your company.",
                    "Knowledge is the truest sky. Well met.",
                    "Exiles we may be, but the Order endures. Welcome.",
                },
            },
            PvPLines = {
                Nemesis = {
                    "{target}. The High Order has studied your every move since {lastzone}. Your pattern ends today!",
                    "A true adept finishes what they begin, {target}. Let me finish you.",
                },
            },
        },
        Horde = {
            subtypeName = "Windshapers",
            Dialect = {
                wordSwaps = {
                    ["wind"] = { "gale", "shaped wind", "breath of the sky" },
                    ["storm"] = { "windstorm", "shaper's tempest" },
                    ["power"] = { "the wind's gift", "windforce" },
                    ["fly"] = { "ride the gale", "soar", "shape the wind beneath me" },
                },
                phraseSwaps = {
                    ["good job"] = { "well shaped", "the wind approves" },
                    ["let's go"] = { "let the gale carry us", "with the wind" },
                    ["watch out"] = { "the gale turns", "mind the shifting wind" },
                },
            },
            GuildGreetings = {
                Standard = {
                    "Fair winds, kindred. The Windshapers stand with you.",
                    "Let the wind carry your voice, and the Horde hear it.",
                    "Shape the wind and it shapes the day. Well met.",
                },
            },
            PvPLines = {
                Nemesis = {
                    "{target}. The wind has marked you since {lastzone}. It will not lose your scent!",
                    "I am a Windshaper. I do not chase; I wait for the gale to bring you to me, {target}.",
                },
            },
        },
    },
    -- Racial Temperament Presets (My Voice tab). A preset may replace the oaths, merges
    -- FriendGreetings, replaces BattleCry and may shift intensity by -1..+1.
    Presets = {
        HighOrder = {
            name = "High Order Formal",
            blurb = "Precise and scholarly: the formal cadence of the High Order.",
            dialectIntensity = -1,
            FriendGreetings = {
                Default = {
                    "Well met, {target}. The Order is honored by your company.",
                    "{target}. A pleasure; shall we exchange what we have learned?",
                    "Greetings, {target}. The winds have favored this meeting.",
                },
            },
            BattleCry = {
                "By the Order's craft, I answer!",
                "Let the wards hold and the working strike!",
                "The High Order does not yield!",
            },
        },
        Windshaper = {
            name = "Windshaper Wanderer",
            blurb = "Free and shifting like the gale; a shaper of winds who owes nothing to walls.",
            dialectIntensity = 0,
            FriendGreetings = {
                Default = {
                    "Fair winds, {target}! The gale carried you here.",
                    "{target}! Walk with me a while; the wind has stories.",
                    "Well met, {target}. Shall we see where the breeze leads?",
                },
            },
            BattleCry = {
                "The gale answers me!",
                "Ride the shaped wind!",
                "Wind, rise and carry my strike!",
            },
        },
        Stormchaser = {
            name = "Storm-Chaser",
            blurb = "Bold and thrilling: chases the thunderhead and laughs at the lightning.",
            dialectIntensity = 1,
            FriendGreetings = {
                Default = {
                    "{target}! The storm's rising; come fly with me!",
                    "{target}, there you are! I was chasing thunderheads and thinking of you.",
                    "Well met, {target}! Ready to ride into some weather?",
                },
            },
            BattleCry = {
                "Into the storm!",
                "Thunder and wings!",
                "Let the tempest take them!",
            },
        },
    },
    -- Cross-race stance greetings: StanceGreetings[TargetRace].WARM / .GRUFF.
    -- Tokens: {target} (name) and {targetrace} (their race).
    StanceGreetings = {
        Human = {
        WARM = {
            "Fair winds, {target}. The {targetrace} gave us shelter when we had none.",
            "{target}, friend of the lowlands. Well met.",
        },
        GRUFF = {
            "{target}. A {targetrace}, earthbound and certain of it. We shall see.",
            "Mind the sky, {target}. Not all of us fly for your convenience.",
        },
        },
        Dwarf = {
        WARM = {
            "{target}! A {targetrace} so sturdy; the earth must be proud of you.",
            "Fair winds, {target}. Your craft is admired, even from the heavens.",
        },
        GRUFF = {
            "{target}. A {targetrace} who loves the ground a little too much, I think.",
            "Hail, {target}. Do not expect me to descend for your forge.",
        },
        },
        Orc = {
        WARM = {
            "{target}. The wind carries respect to a {targetrace} who earns it. Well met.",
            "Fair winds, {target}. Your honor speaks well of you.",
        },
        GRUFF = {
            "{target}. A {targetrace}. The winds tell me to keep distance.",
            "I see you, {target}. Do not make the sky regret it.",
        },
        },
        ADMIRING = {
            "{target}. Your people stand firm where we would drift. I admire that.",
            "An honor, {target}. The {targetrace} inspire us.",
            "{target}. Your kind's courage reaches even the high skies.",
            "The winds speak well of the {targetrace}, {target}.",
        },
        PLAYFUL = {
            "{target}! Still walking everywhere? How quaint!",
            "Ha! {target}! Look up sometime!",
            "{target}! You'd love flying. Probably.",
            "Oh, {target}. Feet on the ground, as always.",
        },
        WARY = {
            "{target}. The winds whisper caution.",
            "Hm. {target}. I will watch the sky around you.",
            "{target}. Trust drifts in slowly.",
            "{target}. We shall see.",
        },
        DISDAINFUL = {
            "{target}. So earthbound.",
            "Ah, one of the {targetrace}. Always looking down.",
            "{target}. You will never know the sky.",
            "{target}. How very... grounded.",
        },
        WARM = {
            "Fair winds, {target}. The {targetrace} are kindred to us.",
            "{target}. Your people gave us shelter. We remember.",
            "Well met, {target}. Skies be kind to your kind.",
            "{target}! A welcome face on the wind.",
        },
        GRUFF = {
            "{target}. Out of my airspace.",
            "Hmph. {target}. Not now.",
            "{target}. You block the breeze.",
            "{target}. Move along.",
        },
    },
    EmoteReplies = {
        Wave = {
            "Fair winds, {target}!",
            "Well met, {target}!",
            "Skies be kind, {target}!",
            "Greetings on the breeze, {target}!",
        },
        Bow = {
            "Rise, {target}. The sky honors us both.",
            "Gracious, {target}. My thanks.",
            "And to you, {target}.",
            "No need, {target}. We are kindred.",
        },
        Cheer = {
            "To the skies, {target}!",
            "Well flown, {target}!",
            "The winds rejoice, {target}!",
            "Ha! Splendid, {target}!",
        },
        Toast = {
            "To fair winds, {target}!",
            "To open skies, {target}!",
            "To Zephras Isle, {target}!",
            "To the horizon, {target}!",
        },
        Hug = {
            "Oh! Mind the feathers, {target}.",
            "A warm gust, {target}. Thank you.",
            "Kindred, {target}. Always.",
            "Gently, {target}. Gently.",
        },
        Rude = {
            "The wind carries your words away, {target}.",
            "How earthbound of you, {target}.",
            "Mind yourself, {target}.",
            "A storm brews, {target}. Careful.",
        },
        Challenge = {
            "You challenge the sky, {target}? Bold.",
            "Very well, {target}. Meet me on the wind.",
            "The gale accepts, {target}.",
            "Careful, {target}. I fly faster than I fall.",
        },
    },
    RivalOpeners = {
        Vendetta = {
            "{target}! The winds remember {lastzone}!",
            "For {lastzone}, {target}! Take wing!",
            "{target}. {lastzone} ends here.",
            "I flew back from {lastzone} for this, {target}.",
        },
        SwornFoe = {
            "Again, {target}? The gale returns.",
            "{target}. The sky circles back to you.",
            "You never tire, {target}. Neither do I.",
            "{target}! Round again!",
        },
        Nemesis = {
            "{target}! THE STORM BREAKS!",
            "By every wind, {target}, you fall!",
            "{target}! The sky has waited for this!",
            "No more circling, {target}!",
        },
        Default = {
            "On the wind, {target}!",
            "From above, {target}!",
            "Take wing, {target}!",
            "The gale strikes, {target}!",
        },
    },
    -- Racial combat openers: mixed into signature-move pull lines now and then
    -- (homeland, kin and pride; the class and spell pools cover the rest)
    CombatOpeners = {
        "The winds turn against you.",
        "Zephras watches from above.",
        "Fair winds to me. Foul ones to you.",
        "I have fallen from greater heights than this.",
        "Mind the gale. It answers to me.",
        "The sky is patient. I am less so.",
        "The isle taught me to strike like a squall.",
        "Grounded? Only for a moment.",
        "Feel the pressure drop. That's me.",
        "By the open sky, then.",
        "Every storm begins with a single gust.",
    },
    -- Clans / lineages: chosen on the My Voice tab (only this race's appear). Combat lines
    -- join pull lines now and then, Greet lines friendly greetings, Idle lines idle chatter.
    Clans = {
        { key = "Cloudreach", name = "High Cloudreach / Sky-Guard",
            Combat = {
                "The Sky-Guard does not falter.",
                "High Cloudreach sends its regards.",
                "Strike from above, as always.",
                "The air bends for me.",
            },
            Greet = {
                "Fair winds, {target}. The Sky-Guard sees you.",
                "Welcome, wing-friend.",
                "The Cloudreach honors you.",
            },
            Idle = {
                "Too low here. I miss the clouds.",
                "The patrol routes need walking.",
                "The wind tastes different down here.",
            },
        },
        { key = "Lowland", name = "Lowland / Ground-Walker",
            Combat = {
                "I walk the earth. I fight on it too.",
                "Ground-Walkers hold the line.",
                "Low and steady.",
                "No wings needed for this.",
            },
            Greet = {
                "Well met, {target}. Feet on the ground, eh?",
                "Ground-Walkers greet you.",
                "Good to meet one who walks.",
            },
            Idle = {
                "The soil here is rich. Good farming.",
                "The sky folk forget the ground. I don't.",
                "Mud on my boots. As it should be.",
            },
        },
        { key = "StormKindred", name = "Storm-Kindred",
            Combat = {
                "The storm answers me.",
                "Thunder on my side.",
                "Feel the pressure drop.",
                "Lightning before the rain.",
            },
            Greet = {
                "{target}. The storms are kind today.",
                "Storm-Kindred greet you.",
                "Mind the static.",
            },
            Idle = {
                "A storm is coming. I can feel it.",
                "My hair stands up before thunder.",
                "Quiet skies make me restless.",
            },
        },
    },
    -- Battle cries (/mono cry and the Battle Cry button). A temperament preset or a
    -- character profile may replace them; My Voice battle cries are added on top.
    BattleCry = {
        "FOR ZEPHRAS!",
        "RIDE THE STORM!",
        "WINGS AND THUNDER!",
        "THE SKY IS OURS!",
        "FAIR WINDS, FOUL END!",
        "INTO THE GALE!",
        "THE TEMPEST ANSWERS!",
        "SKYBORNE RISE!",
    },
}
