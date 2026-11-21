--[[
    Monologue Data Module: Night Elf Race
    PURE DATA TABLE. Key matches UnitRace("player") raceFile "NightElf".
    Lore: Teldrassil, Darnassus, Ashenvale, Elune, the Sentinels. WoW Forever canon only.

    Dialect format: see the top of Monologue_Translator.lua. A string value is one fixed swap;
    a list of strings is a set of variants, one picked at random (the last 3 are avoided).
    Night elves speak with calm, measured formality, so the cadence is unhurried.
--]]

MonologueEngine.Data.Races["NightElf"] = {
    Dialect = {
        wordSwaps = {
            ["hello"] = { "ishnu-alah", "well met", "moonlight upon you", "greetings" },
            ["hi"] = { "ishnu-alah", "well met", "greetings" },
            ["goodbye"] = { "until the moon rises again", "Elune watch over you", "farewell", "walk with the moon" },
            ["bye"] = { "farewell", "Elune keep you", "until we meet again" },
            ["yes"] = { "indeed", "truly", "so it is", "it is so" },
            ["thanks"] = { "my thanks", "Elune bless you", "gratitude" },
            ["friend"] = { "kindred", "companion", "friend of the forest", "dear one" },
            ["friends"] = { "kindred", "companions", "friends of the forest" },
            ["night"] = { "moonlit night", "starlit night", "deep night" },
            ["forest"] = { "wildwood", "sacred grove", "deepwood" },
            ["enemy"] = { "foe", "adversary", "threat" },
            ["fight"] = { "battle", "struggle", "skirmish" },
            ["strong"] = { "steadfast", "enduring", "mighty" },
            ["danger"] = { "peril", "threat", "shadow" },
        },
        phraseSwaps = {
            ["thank you"] = { "Elune bless you", "my deepest thanks", "you have my gratitude" },
            ["thanks a lot"] = { "my deepest thanks", "I am grateful beyond words" },
            ["watch out"] = { "beware", "take heed", "mind the shadows" },
            ["be careful"] = { "tread softly", "walk with care", "go gently" },
            ["good job"] = { "well done", "gracefully done", "Elune smiles on you" },
            ["let's go"] = { "come, let us go", "let us walk", "onward, kindred" },
            ["on my way"] = { "I come swiftly", "I am already walking", "on silent feet" },
            ["good luck"] = { "may Elune guide you", "walk beneath her light", "fair fortune" },
            ["good morning"] = { "a bright dawn to you", "morning light upon you" },
            ["good night"] = { "rest beneath the stars", "Elune guard your sleep" },
            ["come on"] = { "come, quickly", "do not tarry" },
            ["help me"] = { "lend me your aid", "I need your strength" },
            ["i don't know"] = { "I cannot say", "the moon has not told me" },
        },
        contractions = {
            -- Formal, measured speech: contractions open up now and then
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
        interjections = { "mark me", "truly", "by Elune", "it is said" },
        openers = {
            "By Elune,",
            "Hear me,",
            "Beneath the moon,",
            "Kindred,",
            "Listen,",
            "Mark my words,",
            "In the grove's name,",
            "Ishnu-alah,",
        },
        closers = {
            ", Elune-adore.",
            ", by the grace of Elune.",
            ", as the moon is my witness.",
            ", so the forest remembers.",
            ", beneath the stars.",
            ", Elune willing.",
            ", thus it is.",
            ", may the grove endure.",
        },
    },
    GuildGreetings = {
        Standard = {
            "Ishnu-alah. May Elune light your path.",
            "The forest remembers those who tread it gently. Well met.",
            "Walk softly, and may the moon guard you.",
            "Ishnu'alah, friends. May the moon guide our steps.",
            "Elune watch over every one of us today.",
            "The night is long, but we walk it together.",
            "Shan'do teach patience. Today, I teach it to you. Welcome.",
            "Darnassus sends its blessings, kin of the guild.",
        }
    },
    FriendGreetings = {
        Ally = {
            "{target}. The forest is safer with you in it.",
            "Shall we hunt together again?",
            "I would trust you on any night watch.",
            "Ishnu-alah, comrade.",
            "Elune smiles on the two of us, I think.",
        },
        Default = {
            "Ishnu-alah, {target}! The forest is brighter for your presence.",
            "{target}! Elune has guided you to me again.",
            "Well met, {target}. Walk with me a while?",
            "My heart lifts to see you, {target}.",
            "{target}, dear one. The moon smiles on this meeting.",
            "Ishnu'alah, {target}. Elune smiles on our meeting.",
            "{target}. The forest is quieter, and kinder, with you near.",
            "Well met, {target}. Walk with me beneath the moon.",
            "{target}! A friendly face in a long night.",
        },
    },
    DuelWin = {
        "A graceful duel, {target}. Well fought!",
        "Elune guided my hand today, {target}. You fought bravely!",
        "No shame in this, {target}. Rise, and fight again.",
        "You pressed me hard, {target}. Well fought!",
        "Swift, {target}, but the moon was with me tonight.",
        "A graceful bout, {target}. Thank you.",
        "Well done, {target}. You fought with honor.",
        "Ten thousand years of practice, {target}. Do not despair.",
    },
    DuelLoss = {
        "You were the swifter, {target}. Well fought!",
        "Elune favored you today, {target}. I yield with honor.",
        "A lesson learned, {target}. My thanks.",
        "Well struck, {target}. I will remember it.",
        "Well struck, {target}. Elune favored you.",
        "You are quick, {target}. I will remember it.",
        "A worthy victory, {target}. I yield.",
        "Even the oldest oak bends, {target}. Well fought.",
    },
    PvPLines = {
        FirstClash = {
            "You tread on sacred ground in {zone}, {target}. Turn back.",
            "The Sentinels do not forget an intruder. Step away, {target}.",
            "You trespass in {zone}, {target}. Leave, or fall.",
            "The forest has eyes, {target}. You were seen.",
        },
        DejaVu = {
            "{zone} again. The earth grows weary of this bloodshed.",
            "Another battle in {zone}. Elune, grant me patience.",
            "{zone} again. The trees remember every fight.",
            "The roots of {zone} drink too much blood.",
        },
        Rematch = {
            "You return, {target}. The moon's patience is not endless.",
            "Back so soon? Very well.",
            "Again, {target}? The moon is patient. I am not.",
            "You return, {target}. Unwise.",
        },
        Vendetta = {
            "I have not forgotten {lastzone}, {target}. The moon remembers.",
            "You struck me down in {lastzone}. I will answer that, {target}.",
            "{lastzone} is not forgotten, {target}.",
            "The forest remembers {lastzone}, {target}. So do I.",
        },
        Dominance = {
            "You have bled against my blades before, {target}. Yield.",
            "Withdraw, {target}. I would spare you a second defeat.",
            "You have fallen before, {target}. You will again.",
            "Kneel, {target}. You know the outcome.",
        },
        Nemesis = {
            "{target}. Our reckoning is long overdue. It ends here, as it began in {lastzone}.",
            "Elune guide my blade. This feud ends today, {target}.",
            "{target}. Ten thousand years have taught me patience. It is over.",
            "Elune, guide my blade. {target} falls tonight!",
        },
    },
    -- Racial Temperament Presets (My Voice tab). A preset replaces openers/closers, merges
    -- FriendGreetings, replaces BattleCry and may shift intensity by -1..+1.
    Presets = {
        MoonlitSentinel = {
            name = "Moonlit Sentinel",
            blurb = "Vigilant and solemn, a watcher who guards the night for Elune.",
            dialectIntensity = 0,
            openers = {
                "Elune watches,",
                "Stay vigilant,",
                "Under the moon,",
                "The night is long,",
                "Be watchful,",
                "By Elune's light,",
            },
            closers = {
                ", Elune guide us.",
                ", under the moonlight.",
                ", the watch continues.",
                ", in Elune's name.",
                ", the night remembers.",
                ", stay vigilant.",
            },
            FriendGreetings = {
                Default = {
                    "Elune's light upon you, {target}. The watch is quieter with you here.",
                    "{target}. I am glad to see you safe tonight.",
                    "Ishnu'alah, {target}. Walk beneath the moon with me.",
                },
            },
            BattleCry = {
                "Elune, guide my arrow!",
                "For the watch, for the night!",
                "Let the moon bear witness!",
            },
        },
        GroveWarden = {
            name = "Grove Warden",
            blurb = "Nurturing and ancient, speaks for the forest and its slow wisdom.",
            dialectIntensity = -1,
            openers = {
                "The grove whispers,",
                "Listen to the leaves,",
                "As the roots remember,",
                "Patience, little one,",
                "Ancient oaks say,",
                "By root and bough,",
            },
            closers = {
                ", as the seasons turn.",
                ", so the grove grows.",
                ", root and bough.",
                ", the forest remembers.",
                ", gently now.",
                ", all things in their time.",
            },
            FriendGreetings = {
                Default = {
                    "{target}. The forest is gladdened by your steps.",
                    "Well met, {target}. Rest awhile beneath the boughs.",
                    "{target}, little one of the wild. Welcome.",
                },
            },
            BattleCry = {
                "The forest awakens!",
                "Roots and thorns, answer me!",
                "The grove will not fall!",
            },
        },
        MoonSwift = {
            name = "Moon-Swift Wanderer",
            blurb = "Sharp-tongued and restless, a long-lived wanderer with a taste for mischief.",
            dialectIntensity = 1,
            openers = {
                "Mmm, well,",
                "Ten thousand years and still,",
                "Oh, do keep up,",
                "Quickly now,",
                "A thought,",
                "As I was saying,",
            },
            closers = {
                ", if you must know.",
                ", and it amuses me.",
                ", naturally.",
                ", but what do I know?",
                ", moving on.",
                ", ever so briefly.",
            },
            FriendGreetings = {
                Default = {
                    "{target}! You've aged a decade since I blinked. Well met.",
                    "Ah, {target}. Entertain me, will you?",
                    "{target}, there you are. I was almost bored.",
                },
            },
            BattleCry = {
                "Try to keep up!",
                "Swift as the moon!",
                "Do enjoy this part!",
            },
        },
    },
    -- Cross-race stance greetings: StanceGreetings[TargetRace].WARM / .GRUFF.
    -- Tokens: {target} (name) and {targetrace} (their race).
    StanceGreetings = {
        Dwarf = {
        WARM = {
            "Ishnu'alah, {target}. Dwarves hold what they love as the oaks hold the earth. I admire that.",
            "{target}. You build things that last. A virtue even for those of us who count in millennia.",
            "Well met, {target}. Beneath the stone and the soil, we are not so different.",
        },
        GRUFF = {
            "{target}. A {targetrace}. So much noise for such short a life.",
            "Please, {target}, mind the forest. Axes and groves rarely end well.",
            "{target}. You smell of the forge. Stay downwind.",
        },
        },
        Human = {
        WARM = {
            "Ishnu'alah, {target}. Your people burn brightly, and briefly. I respect it.",
            "{target}. The {targetrace} have been steadfast friends; be welcome.",
        },
        GRUFF = {
            "{target}. How hurried your kind is, always.",
            "A {targetrace}. You will be dust before I finish this thought.",
        },
        },
        Orc = {
        WARM = {
            "{target}. The orcs have known grief and endured it. Elune light your way.",
            "Well met, {target}. Honor wears many faces.",
        },
        GRUFF = {
            "{target}. A {targetrace}. The forest has not forgotten the axes.",
            "Keep your distance from the trees, {target}.",
        },
        },
        ADMIRING = {
            "{target}. Your people burn bright in so short a time. I admire that.",
            "An honor, {target}. The {targetrace} have courage I have seldom seen.",
            "{target}, your kind amazes even an elder like me.",
            "Elune smiles on the {targetrace}, {target}. As do I.",
        },
        PLAYFUL = {
            "{target}! Still in a hurry, as ever.",
            "Ah, {target}. You look as if you've aged a day since I blinked.",
            "{target}! Don't trip over the roots this time.",
            "Hello, {target}. Do try to keep up.",
        },
        WARY = {
            "{target}. The forest watches you. So do I.",
            "Hm. {target}. I will reserve judgment.",
            "{target}. Tread lightly in our woods.",
            "Be still, {target}. Let me see your intent.",
        },
        DISDAINFUL = {
            "{target}. Such short lives, and so much noise.",
            "Oh. One of the {targetrace}. How quaint.",
            "{target}. You will be dust before I finish this thought.",
            "{target}. Do try not to break anything.",
        },
        Gnome = {
            WARM = {
                "{target}! Your people's cleverness delights me.",
                "Ishnu'alah, {target}. Gnomeregan will shine again.",
                "{target}. Small in stature, great in spirit.",
            },
            GRUFF = {
                "{target}. No machines in the grove.",
                "Hmph. {target}. The smoke of your devices offends the forest.",
                "{target}. Keep your gears away from the trees.",
            },
        },
        WARM = {
            "Ishnu'alah, {target}. The {targetrace} are welcome in our forests.",
            "Well met, {target}. Elune's light on your people.",
            "{target}. I am glad of your company.",
            "Greetings, {target}. Our peoples are stronger together.",
        },
        GRUFF = {
            "{target}. Mind the trees.",
            "{target}. Do not linger.",
            "Hmph. {target}. Our forests are not for you.",
            "{target}. You are tolerated. Nothing more.",
        },
    },
    EmoteReplies = {
        Wave = {
            "Ishnu'alah, {target}.",
            "Elune light your way, {target}.",
            "Well met, {target}.",
            "Greetings, {target}. Walk in peace.",
        },
        Bow = {
            "Rise, {target}. Your respect is noted.",
            "And mine to you, {target}.",
            "Gracious, {target}. Elune sees it.",
            "There is no need, {target}. But thank you.",
        },
        Cheer = {
            "Ha! Well said, {target}.",
            "The forest sings with you, {target}!",
            "Your spirit is bright, {target}.",
            "Elune rejoices, {target}!",
        },
        Toast = {
            "To the moon and the stars, {target}.",
            "May your cup never empty, {target}.",
            "To the long night, {target}.",
            "Elune's blessing on your cup, {target}.",
        },
        Hug = {
            "Oh! Gently, {target}.",
            "Warm, {target}. Thank you.",
            "It has been long, {target}.",
            "Careful, {target}. My glaive is sharp.",
        },
        Rude = {
            "How very young of you, {target}.",
            "I have outlived greater insults, {target}.",
            "Mind yourself, {target}.",
            "Elune forgive you, {target}. I may not.",
        },
        Challenge = {
            "You challenge a Sentinel, {target}? Bold.",
            "Patience, {target}. You are not ready.",
            "Very well, {target}. Choose your ground.",
            "The moon will judge us, {target}.",
        },
    },
    RivalOpeners = {
        Vendetta = {
            "{target}. For {lastzone}, Elune guide my blade!",
            "The forest remembers {lastzone}, {target}!",
            "{target}! You will answer for {lastzone}.",
            "Not again, {target}. Not after {lastzone}.",
        },
        SwornFoe = {
            "You return, {target}. As expected.",
            "{target}. The hunt resumes.",
            "Again, {target}? Let us dance.",
            "I know your steps, {target}.",
        },
        Nemesis = {
            "{target}! The moon will not save you tonight!",
            "ELUNE, WITNESS! {target} falls!",
            "{target}! Ten thousand years of fury, for you!",
            "This ends under the moon, {target}!",
        },
        Default = {
            "{target}! The forest strikes back!",
            "For Elune, {target}!",
            "You are seen, {target}!",
            "Feel the moon's wrath, {target}!",
        },
    },
    -- Racial combat openers: mixed into signature-move pull lines now and then
    -- (homeland, kin and pride; the class and spell pools cover the rest)
    CombatOpeners = {
        "Elune guide my aim.",
        "Ten thousand years. I am patient. You are not.",
        "The forest marks every step you take.",
        "Teldrassil's roots run deeper than your courage.",
        "By moonlight, then.",
        "The Sentinels taught me silence. Then this.",
        "You trespass on old ground.",
        "Cenarius watches. Make it worth his time.",
        "The night is long, and so is my memory.",
        "Shan'do Stormrage would expect no less.",
        "Quiet. The woods are listening.",
    },
    -- Clans / lineages: chosen on the My Voice tab (only this race's appear). Combat lines
    -- join pull lines now and then, Greet lines friendly greetings, Idle lines idle chatter.
    Clans = {
        { key = "Darnassian", name = "Darnassian / Teldrassil",
            Combat = {
                "For Teldrassil.",
                "Darnassus does not forgive trespass.",
                "The great tree watches over me.",
                "By Tyrande's will.",
            },
            Greet = {
                "Ishnu-alah, {target}. Darnassus welcomes you.",
                "The temple bells ring for friends.",
                "May the great tree shelter you.",
            },
            Idle = {
                "I miss the quiet of the Temple Gardens.",
                "The hippogryphs were restless last night.",
                "Teldrassil's leaves never quite fall.",
            },
        },
        { key = "Sentinel", name = "Sentinel Order",
            Combat = {
                "Sentinels, with me.",
                "The watch never ends.",
                "Ten thousand years of standing guard.",
                "Moon blade, steady.",
            },
            Greet = {
                "Hold, {target}. Friend. Pass.",
                "A Sentinel's greeting: keep your eyes open.",
                "The Sentinels note your service.",
            },
            Idle = {
                "Ashenvale's borders need more watchers.",
                "The Warsong cut deeper every season.",
                "A Sentinel never truly sleeps.",
            },
        },
        { key = "Highborne", name = "Shen'dralar / Highborne Exile",
            Combat = {
                "The old magic remembers its purpose.",
                "Eldre'Thalas taught me more than you know.",
                "Arcane does not fade. It waits.",
                "Quel'dorei or Kaldorei, the blood is old.",
            },
            Greet = {
                "{target}. A rare pleasure. Most avoid me.",
                "The Shen'dralar greet you. Discreetly.",
                "Speak softly. Some still hate my kind.",
            },
            Idle = {
                "The libraries of Dire Maul hold my heart.",
                "Magic hums in my bones. Always.",
                "Darnassus barely tolerates us. I understand why.",
            },
        },
    },
}
