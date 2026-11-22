--[[
    Monologue Data Module: Troll Race
    PURE DATA TABLE. Key matches UnitRace("player") raceFile "Troll".
    Lore: the Darkspear tribe, the Echo Isles, Sen'jin Village, Vol'jin, the loa,
    Zul'Gurub and Hakkar the Soulflayer. WoW Forever canon only.

    Dialect format: see the top of Monologue_Translator.lua. A string value is one fixed swap;
    a list of strings is a set of variants, one picked at random (the last 3 are avoided).
    The core Troll accent (da, dis, dat, ya, th -> d) stays fixed so it always reads the same;
    everything else varies. th -> d belongs to the Troll pack alone.
--]]

MonologueEngine.Data.Races["Troll"] = {
    Dialect = {
        wordSwaps = {
            -- The core accent: always the same
            ["the"] = "da",
            ["this"] = "dis",
            ["that"] = "dat",
            ["them"] = "dem",
            ["they"] = "dey",
            ["there"] = "dere",
            ["with"] = "wit'",
            ["you"] = "ya",
            ["your"] = "ya",

            -- Everything else varies
            ["hello"] = { "hey, mon", "hail", "wha's up", "ya, mon" },
            ["hi"] = { "hey, mon", "hail", "wha's up" },
            ["goodbye"] = { "later, mon", "walk da path", "stay safe, mon", "da loa watch ya" },
            ["yes"] = { "ya", "yeah, mon", "aye", "fo' sure" },
            ["thanks"] = { "t'anks", "t'ank ya", "much appreciated, mon" },
            ["friend"] = { "mon", "bruddah", "kinfolk", "friend" },
            ["friends"] = { "mon", "bruddahs", "kinfolk" },
            ["enemy"] = { "foe", "enemy o' da tribe", "punk" },
            ["weak"] = { "puny", "soft", "weak" },
            ["fight"] = { "scrap", "battle", "dust-up" },
            ["strong"] = { "strong", "tough", "mighty" },
            ["danger"] = { "trouble", "bad juju", "peril" },
            ["magic"] = { "juju", "voodoo", "loa's gift" },
            ["food"] = { "grub", "eats", "vittles" },
            ["money"] = { "coin", "shinies", "gold" },
        },
        phraseSwaps = {
            ["thank you"] = { "t'ank ya, mon", "t'anks a lot", "I owe ya, mon" },
            ["thanks a lot"] = { "t'anks a lot, mon", "big t'anks" },
            ["watch out"] = { "watch yo' back", "look sharp, mon", "bad juju ahead" },
            ["be careful"] = { "careful, mon", "go easy", "mind da path" },
            ["good job"] = { "nicely done, mon", "dat be good work", "good work, mon" },
            ["let's go"] = { "let's move, mon", "off we go", "da path calls" },
            ["on my way"] = { "I be comin'", "on me way, mon", "comin' quick" },
            ["good luck"] = { "da loa watch ya", "luck be wit' ya, mon", "may da loa smile on ya" },
            ["good morning"] = { "mornin', mon", "da sun be up" },
            ["good night"] = { "sleep easy, mon", "da loa watch yo' dreams" },
            ["come on"] = { "come on, mon", "hurry up, mon" },
            ["help me"] = { "gimme a hand, mon", "I need ya, mon" },
            ["i don't know"] = { "I dunno, mon", "who can say" },
            ["what's up"] = { "wha's good, mon", "wha's happenin'" },
        },
        contractions = {
            -- Loose, easygoing cadence
            ["is not"] = "ain't",
            ["isn't"] = "ain't",
            ["are not"] = "ain't",
            ["aren't"] = "ain't",
            ["going to"] = "gonna",
        },
        phonetics = {
            ["%f[%a]th"] = "d",
            ["ing%f[%A]"] = "in'",
        },
        interjections = { "mon", "ya know", "dat be true", "I tell ya" },
        openers = {
            "Listen, mon,",
            "Hey,",
            "Hear me,",
            "Ya know,",
            "Da loa say,",
            "Mark dis,",
            "Let me tell ya,",
            "Easy, mon,",
        },
        closers = {
            ", mon.",
            ", da loa watch ya.",
            ", ya know?",
            ", I tell ya.",
            ", dat be da truth.",
            ", fo' sure.",
            ", by da loa.",
            ", easy, mon.",
        },
    },
    GuildGreetings = {
        Standard = {
            "Well met, mon. Da Darkspear stand wit' ya.",
            "Da loa smile on dis gatherin'.",
            "Walk easy, mon, an' bring da victory home.",
            "Eh, everybody! Da gang be all here!",
            "Darkspear salute ya, mon. Good ta see ya.",
            "Da spirits be good today. Let's go make trouble!",
            "Stay sharp, mon. Da loa be watchin'.",
            "Welcome back, mon! Who be ready fa da hunt?",
        }
    },
    FriendGreetings = {
        Ally = {
            "{target}! Me comrade, mon.",
            "Ready for some trouble together, eh?",
            "Da loa smile when we fight side by side.",
            "Good to see ya. Watch my back, I watch yours.",
            "We make a good team, you an' me.",
        },
        Default = {
            "Well met, {target}, mon! Da loa smile on dis meetin'!",
            "{target}! Ya a sight fo' sore eyes!",
            "Hey, {target}! Stick wit' me an' trouble stays away!",
            "{target}, mon! Come, share da fire!",
            "Dere ya are, {target}! Da loa told me ya'd come!",
            "Eh, {target}! Good ta see ya, mon!",
            "{target}! Da spirits told me you be comin'.",
            "Hey, {target}! Sit, sit, have a drink wit' me.",
            "{target}, mon! Ya look good. Real good.",
        },
    },
    DuelWin = {
        "Good scrap, {target}, mon! Ya almost had me!",
        "Da loa be wit' me today, {target}! Well fought!",
        "Dat be a good duel, {target}! Rematch?",
        "Ha! Well fought, mon!",
        "Heh! Da loa favor me today, {target}!",
        "Good fight, {target}! Ya almost had me. Almost.",
        "Ya fight good, {target}. Not good enough, mon!",
        "Get up, {target}! Dat was fun!",
    },
    DuelLoss = {
        "Ya got me, {target}, mon! Fair an' square!",
        "Next time I win, {target}! Ya mark me words!",
        "Good fight, {target}! I be back!",
        "Da loa favor ya today, {target}. Well fought!",
        "Ha! Ya got me, {target}! Respect, mon.",
        "Da spirits be laughin' at me now, {target}.",
        "Okay okay, {target}, ya win dis one!",
        "Next time da voodoo be stronger, {target}!",
    },
    PvPLines = {
        FirstClash = {
            "Ya picked da wrong troll in {zone}, {target}!",
            "Ya come lookin' for trouble, {target}? Trouble found ya.",
            "Ya be lost in {zone}, {target}? Let me help ya. Down!",
            "Da Darkspear see ya, {target}!",
        },
        DejaVu = {
            "{zone} again, mon? Da spirits keep draggin' us back here.",
            "Another fight in {zone}. Da loa be amused.",
            "{zone} again, mon? Da spirits be tired.",
            "Too much blood in {zone}, mon.",
        },
        Rematch = {
            "Ya back, {target}? Ya like da pain, eh?",
            "Again? Dis be easy, mon.",
            "Back again, {target}? Heh, ya like pain.",
            "Ya never learn, {target}!",
        },
        Vendetta = {
            "Me not forget {lastzone}, {target}. Da loa remember.",
            "Ya got lucky in {lastzone}, {target}. Luck run out today!",
            "Da loa remember {lastzone}, {target}. So do I.",
            "{lastzone}, mon! Ya owe me!",
        },
        Dominance = {
            "Ya fall before, {target}. Ya fall again.",
            "Run along, {target}. Dis troll is too much for ya.",
            "Ya keep fallin', {target}. Maybe stay down dis time.",
            "Heh. Again, {target}?",
        },
        Nemesis = {
            "{target}! Da loa demand ya blood. We end dis where it started: {lastzone}!",
            "No more runnin', {target}! Dis feud ends today, mon!",
            "{target}! Da spirits gonna feast tonight!",
            "Dis be da end, {target}! Darkspear never die!",
        },
    },
    -- Racial Temperament Presets (My Voice tab). A preset replaces openers/closers, merges
    -- FriendGreetings, replaces BattleCry and may shift intensity by -1..+1.
    Presets = {
        LoaDevotee = {
            name = "Loa Devotee",
            blurb = "Reverent and mystical, speaks of the loa and ancient Zul'jin-era wisdom.",
            dialectIntensity = 0,
            openers = {
                "The loa say,",
                "Hear dis,",
                "By de spirits,",
                "Mon,",
                "De ancestors know,",
                "Mark da voodoo,",
            },
            closers = {
                ", so da loa watch.",
                ", by da spirits.",
                ", dat is da way.",
                ", mon.",
                ", da loa willin'.",
                ", an' dat's da truth.",
            },
            FriendGreetings = {
                Default = {
                    "{target}, mon! Da loa smile on dis meetin'.",
                    "Well met, {target}. Spirits wit' ya.",
                    "{target}! Come, sit by da fire.",
                },
            },
            BattleCry = {
                "Da loa guide me!",
                "Voodoo, rise!",
                "By de spirits, strike!",
            },
        },
        JungleHunter = {
            name = "Jungle Hunter",
            blurb = "Quiet and sharp-eyed: the stalker from the Echo Isles.",
            dialectIntensity = 0,
            openers = {
                "Shh,",
                "Watch,",
                "Stay low,",
                "Da trail says,",
                "Listen close,",
                "Eyes open,",
            },
            closers = {
                ", quiet now.",
                ", watch da brush.",
                ", da hunt goes on.",
                ", stay low.",
                ", mon.",
                ", da jungle knows.",
            },
            FriendGreetings = {
                Default = {
                    "{target}. Quiet steps, I like dat.",
                    "Well met, {target}. I smell no trouble.",
                    "{target}, mon. Come, da trail's clear.",
                },
            },
            BattleCry = {
                "Hunt begins!",
                "Da prey runs, I follow!",
                "Da jungle takes dem!",
            },
        },
        Trickster = {
            name = "Grinning Trickster",
            blurb = "Teasing, fast-talking and irreverent; the Darkspear prankster.",
            dialectIntensity = 1,
            openers = {
                "Ya see,",
                "Heh heh,",
                "Ooh, listen,",
                "Mon, mon, mon,",
                "Guess what,",
                "Pay attention,",
            },
            closers = {
                ", heh heh.",
                ", an' dat's da joke.",
                ", mon, ya wish.",
                ", or maybe not.",
                ", what a day!",
                ", surprise!",
            },
            FriendGreetings = {
                Default = {
                    "{target}! Ya look terrible! Dat's a joke, mon!",
                    "Ooh, {target}! Come, I got a story!",
                    "{target}! Hide yer purse, I'm here!",
                },
            },
            BattleCry = {
                "HERE COME DA TROLL!",
                "Surprise, mon!",
                "DA PARTY START NOW!",
            },
        },
    },
    EmoteReplies = {
        Wave = {
            "Eh, {target}!",
            "Hey hey, {target}!",
            "Ya, {target}! What's up, mon?",
            "Wavin' back, {target}!",
        },
        Bow = {
            "Heh, no need fa bowin', {target}.",
            "Ya show respect, {target}. I like dat.",
            "Get up, mon! {target}, ya too kind.",
            "Da loa see ya manners, {target}.",
        },
        Cheer = {
            "Heh heh! Yeah, {target}!",
            "Ya got da spirit, {target}!",
            "Woo! Dat's right, {target}!",
            "Darkspear cheer wit' ya, {target}!",
        },
        Toast = {
            "Ta da loa, {target}!",
            "Drink up, {target}!",
            "Ta da Darkspear, mon! Cheers, {target}!",
            "Bottoms up, {target}, mon!",
        },
        Hug = {
            "Whoa, {target}! Ya squeeze too hard, mon!",
            "Heh, ya missed me, {target}?",
            "Careful wit' da tusks, {target}!",
            "Aight aight, {target}. Love ya too.",
        },
        Rude = {
            "Ya rude, {target}. Da loa be watchin'.",
            "Watch ya mouth, {target}. I got voodoo.",
            "Heh. Ya gonna regret dat, {target}.",
            "Ooh, {target}, dat was not nice, mon.",
        },
        Challenge = {
            "Ya wanna fight, {target}? Heh, okay!",
            "Bring it, {target}! I be ready.",
            "Ya think ya can take me, {target}? Cute.",
            "Da spirits say ya lose, {target}.",
        },
    },
    RivalOpeners = {
        Vendetta = {
            "{target}! Da loa remember {lastzone}!",
            "Dis be fa {lastzone}, {target}!",
            "{target}! I been waitin' since {lastzone}, mon!",
            "Ya owe me fa {lastzone}, {target}!",
        },
        SwornFoe = {
            "Heh, {target} again! Ya never learn, mon!",
            "{target}! Back fa more, eh?",
            "Ya just love da pain, {target}!",
            "Again, {target}? Okay okay!",
        },
        Nemesis = {
            "{target}! DA SPIRITS DEMAND YA DEATH!",
            "DARKSPEAR NEVER DIE! {target}, ya done!",
            "{target}! Dis be da final dance!",
            "Da loa gonna feast on ya, {target}!",
        },
        Default = {
            "Here I come, {target}!",
            "Da hunt begin, {target}!",
            "Darkspear strike, {target}!",
            "Heh! Got ya, {target}!",
        },
    },
    StanceGreetings = {
        WARM = {
            "Eh, {target}! Da {targetrace} always welcome wit' da Darkspear.",
            "{target}, mon! Ya people be good people.",
            "Hey, {target}! Good ta see ya, friend.",
            "Da spirits like ya, {target}. So do I.",
        },
        ADMIRING = {
            "{target}. Da {targetrace} be strong, mon. Respect.",
            "Ya people got good spirit, {target}.",
            "{target}! Da loa smile on ya kind.",
            "Respect, {target}. Ya people earn it.",
        },
        PLAYFUL = {
            "Heh! {target}! Ya look like ya need some voodoo, mon.",
            "{target}! So serious! Smile, mon!",
            "Ooh, {target}. Ya walk funny. Heh!",
            "{target}! Ya smell like ya been in da swamp, mon!",
        },
        WARY = {
            "{target}. Da spirits not sure about ya yet.",
            "Hmm. {target}. I be watchin', mon.",
            "{target}. Trust come slow, mon.",
            "Easy, {target}. Da loa be suspicious.",
        },
        GRUFF = {
            "{target}. Move, mon.",
            "Eh. {target}. Not now.",
            "{target}. Ya botherin' me, mon.",
            "Hmph. {target}. Go away.",
        },
        DISDAINFUL = {
            "{target}. Ya people don't know nothin' about da spirits.",
            "Heh. One of da {targetrace}. Soft.",
            "{target}. Ya wouldn't last a day in da jungle.",
            "{target}. Da loa laugh at ya, mon.",
        },
        Orc = {
            WARM = {
                "{target}! Thrall saved da Darkspear. We never forget, mon.",
                "Eh, {target}! Orcs an' trolls, best of friends!",
                "{target}, mon! For da Horde!",
            },
            GRUFF = {
                "{target}. Ya too serious, mon. Lighten up.",
                "Hmph. {target}. Orcs always shoutin'.",
                "{target}. Stop growlin' at me, mon.",
            },
        },
        Tauren = {
            WARM = {
                "{target}! Big friend! Da spirits love ya people.",
                "Eh, {target}! Da Earth Mother an' da loa, good friends.",
                "{target}, mon! Ya always kind ta us.",
            },
            GRUFF = {
                "{target}. Ya too slow, mon.",
                "Hmph. {target}. Stop lecturin' me about da land.",
                "{target}. Da loa an' da Earth Mother don't always agree, mon.",
            },
        },
        Scourge = {
            WARM = {
                "{target}! Ya dead, but ya fun, mon!",
                "Eh, {target}. Da spirits respect ya people.",
                "{target}! Death not stoppin' ya, heh. I like dat.",
            },
            GRUFF = {
                "{target}. Ya smell like a swamp corpse, mon.",
                "Hmph. {target}. Da dead should stay dead.",
                "{target}. Keep ya plagues away from da Echo Isles.",
            },
        },
    },
    -- Racial combat openers: mixed into signature-move pull lines now and then
    -- (homeland, kin and pride; the class and spell pools cover the rest)
    CombatOpeners = {
        "Darkspear never kneel, mon.",
        "Loa be watchin'. Make it good.",
        "Bwonsamdi takin' names today.",
        "Echo Isles taught me teeth and patience.",
        "Stay away from da voodoo.",
        "Vol'jin's people don't run.",
        "Ya smell like dinner, mon.",
        "Ancient blood in me. Older than your whole line.",
        "Sen'jin's spirit go with me.",
        "Feel dat? Da spirits be restless.",
        "One more for da shrine, mon.",
    },
    -- Clans / lineages: chosen on the My Voice tab (only this race's appear). Combat lines
    -- join pull lines now and then, Greet lines friendly greetings, Idle lines idle chatter.
    Clans = {
        { key = "Darkspear", name = "Darkspear Tribe",
            Combat = {
                "Darkspear never kneel, mon.",
                "For Vol'jin and da Echo Isles.",
                "Da spear find you, mon.",
                "Sen'jin watchin'. Make it good.",
            },
            Greet = {
                "Ay, {target}. Da Darkspear say hello.",
                "Come sit by da fire, mon.",
                "Stay a while, mon. Da loa like company.",
            },
            Idle = {
                "Miss da Echo Isles. Da sand, da sea.",
                "Vol'jin got big plans for us, mon.",
                "Got me some voodoo to work on later.",
            },
        },
        { key = "Revantusk", name = "Revantusk Tribe",
            Combat = {
                "Revantusk hunt dis land long before you.",
                "Da Hinterlands sharpen us, mon.",
                "Fast blade, faster feet.",
                "Da Witherbark be next. You first.",
            },
            Greet = {
                "Ay, {target}. Revantusk remember friends.",
                "Good to see ya, mon. Da Hinterlands be lonely.",
                "Revantusk village always got room.",
            },
            Idle = {
                "Da sea air in Revantusk, mon. Nothing like it.",
                "Da Wildhammer be watchin' us again.",
                "Got fish to dry back home.",
            },
        },
        { key = "Zandalari", name = "Zandalari / Gurubashi Exile",
            Combat = {
                "Old empire blood in me, mon.",
                "Hakkar's temples taught me worse.",
                "Da Gurubashi fall. I not.",
                "Zul'Gurub remember my name.",
            },
            Greet = {
                "{target}. You show respect. Good.",
                "Da old empire bow to few. You lucky, mon.",
                "Come, mon. Hear a story about da old days.",
            },
            Idle = {
                "Da jungle temples call to me at night.",
                "Da Soulflayer awake again, dey say.",
                "Once we rule everything, mon. Everything.",
            },
        },
    },
    -- Battle cries (/mono cry and the Battle Cry button). A temperament preset or a
    -- character profile may replace them; My Voice battle cries are added on top.
    BattleCry = {
        "DARKSPEAR NEVER DIE!",
        "FOR VOL'JIN!",
        "DA LOA BE WIT' US!",
        "DARKSPEAR RISE!",
        "BWONSAMDI WAITIN'!",
        "FOR DA HORDE, MON!",
        "SPEARS UP!",
        "DA JUNGLE TAKE DEM!",
    },
}
