--[[
    Monologue Data Module: Orc Race
    PURE DATA TABLE. Key matches UnitRace("player") raceFile "Orc".
    Lore: Orgrimmar, Durotar, Warchief Thrall, the Horde. WoW Forever canon only.

    Dialect format: see the top of Monologue_Translator.lua. A string value is one fixed swap;
    a list of strings is a set of variants, one picked at random (the last 3 are avoided).
    Orcs speak tersely and with honor, so the cadence is clipped and formal.
--]]

MonologueEngine.Data.Races["Orc"] = {
    Dialect = {
        wordSwaps = {
            ["hello"] = { "lok'tar", "well met", "strength to you", "hail" },
            ["hi"] = { "lok'tar", "hail", "well met" },
            ["goodbye"] = { "victory or death", "lok'tar ogar", "strength and honor", "until the next battle" },
            ["yes"] = { "aye", "it is so", "true", "indeed" },
            ["thanks"] = { "my thanks", "you have my gratitude", "I owe you", "honor to you" },
            ["friend"] = { "brother", "comrade", "clansman", "kin" },
            ["friends"] = { "brothers", "comrades", "the clan" },
            ["enemy"] = { "foe", "blood-enemy", "challenger" },
            ["weak"] = { "feeble", "frail", "puny" },
            ["fight"] = { "battle", "war", "clash" },
            ["strong"] = { "mighty", "fierce", "unbroken" },
            ["kill"] = { "slay", "crush", "destroy" },
            ["coward"] = { "craven", "weakling", "dishonorable one" },
            ["glory"] = { "honor", "victory", "renown" },
        },
        phraseSwaps = {
            ["thank you"] = { "you have my thanks", "I owe you a debt", "honor to you" },
            ["thanks a lot"] = { "I owe you much", "my thanks, warrior" },
            ["watch out"] = { "beware", "guard yourself", "look to your back" },
            ["be careful"] = { "stay sharp", "keep your blade ready", "guard your flank" },
            ["good job"] = { "well fought", "a worthy blow", "strong work" },
            ["let's go"] = { "to battle", "for the Horde", "let us march" },
            ["on my way"] = { "I march now", "I come", "already moving" },
            ["good luck"] = { "strength to your arm", "victory or death", "may your axe stay sharp" },
            ["good morning"] = { "a new day for glory", "rise and fight" },
            ["good night"] = { "rest, warrior", "sleep well, and dream of battle" },
            ["come on"] = { "move", "step up", "to me" },
            ["help me"] = { "stand with me", "I need your strength" },
            ["i don't know"] = { "I know not", "who can say" },
            ["i'm sorry"] = { "forgive me", "the fault is mine" },
        },
        contractions = {
            -- Clipped, formal cadence: contractions open up now and then
            ["can't"] = "cannot",
            ["won't"] = "will not",
            ["don't"] = "do not",
            ["it's"] = "it is",
        },
        phonetics = {
            ["^cant$"] = "cannot",
            ["^wont$"] = "will not",
            ["^gonna$"] = "going to",
        },
        interjections = { "hah", "mark me", "by my blade", "truly" },
        openers = {
            "Lok'tar,",
            "Hear me,",
            "Listen well,",
            "For the Horde,",
            "Blood and thunder,",
            "Know this,",
            "By my axe,",
            "Mark this,",
        },
        closers = {
            ", lok'tar ogar!",
            ", for the Horde!",
            ", blood and thunder!",
            ", victory or death!",
            ", by my axe.",
            ", and so it is.",
            ", strength and honor.",
            ", for the Warchief!",
        },
    },
    GuildGreetings = {
        Standard = {
            "Lok'tar, brother. The Horde stands strong.",
            "Strength and honor. Fight well today.",
            "Blood and thunder! Let us find some glory.",
            "Lok'tar, brothers and sisters! For the Horde!",
            "Strength and honor to all who stand here.",
            "Durotar is harsh. So are we. Welcome.",
            "Sharpen your axes. There is glory waiting.",
            "Blood and thunder, friends! What hunt today?",
        }
    },
    FriendGreetings = {
        Ally = {
            "{target}. Blood and thunder, comrade.",
            "Good to see a warrior I trust.",
            "We fight together again. Good.",
            "You have earned your place beside me.",
            "Throm-ka. Ready for the next battle?",
        },
        Default = {
            "Lok'tar, {target}! The Horde stands strong with you.",
            "{target}! Good to fight beside a friend again.",
            "Hail, {target}! Strength and honor!",
            "{target}, my friend! Stand with me and we fear nothing.",
            "{target}! Come, share the fire and a tale of glory.",
            "{target}! Lok'tar! Good to see you, friend.",
            "Well met, {target}. Strength and honor to you.",
            "{target}! Sit by my fire. We have much to talk about.",
            "Ha! {target}! The Horde is stronger with you here.",
        },
    },
    DuelWin = {
        "Well fought, {target}! You have honor!",
        "A good duel! Your blows are strong, {target}!",
        "Victory is mine, {target}, but you earned my respect.",
        "Rise, {target}. Again, when you are ready!",
        "Strong fight, {target}. You honor me.",
        "Lok'tar! Well fought, {target}!",
        "You did not run, {target}. That is worth much.",
        "Rise, {target}. You will be stronger next time.",
    },
    DuelLoss = {
        "You fought with honor, {target}! I yield.",
        "Strong arm, {target}! Next time, I win.",
        "Well fought, {target}. I respect strength.",
        "You bested me, {target}. I will train harder.",
        "Your strength is real, {target}. I yield.",
        "Lok'tar, {target}! A true warrior's victory.",
        "I will remember this, {target}. With respect.",
        "Good. You fight like an orc, {target}.",
    },
    PvPLines = {
        FirstClash = {
            "You stand in {zone} like prey, {target}. Draw your weapon!",
            "Another challenger. Show me your strength, {target}.",
            "You picked the wrong orc, {target}!",
            "Face me, {target}! Lok'tar!",
        },
        DejaVu = {
            "{zone} again. The earth here drinks deep.",
            "More blood in {zone}. Good. I was getting bored.",
            "{zone} again. Good. More glory.",
            "The soil of {zone} knows the Horde well.",
        },
        Rematch = {
            "You return, {target}? Your courage outweighs your wisdom.",
            "Again! Let us see if you have grown.",
            "You return, {target}. Good. I was hungry.",
            "Again, {target}? The axe remembers you.",
        },
        Vendetta = {
            "I have not forgotten {lastzone}, {target}. My blade has not either.",
            "You shamed me in {lastzone}. I will repay it, {target}!",
            "Blood was spilled at {lastzone}, {target}. Yours is next.",
            "{lastzone} is not forgotten, {target}!",
        },
        Dominance = {
            "Feeble, {target}. You have fallen before and you will fall again.",
            "Run while you still can, {target}.",
            "You fell to me before, {target}. Stay down.",
            "Weak, {target}. Again.",
        },
        Nemesis = {
            "{target}! Lok'tar ogar! Victory or death, and today it is your death!",
            "Our blood feud ends here, {target}. I will see you back in {lastzone}, in pieces!",
            "{target}! Only one of us leaves this field!",
            "Lok'tar ogar! {target}, your end is here!",
        },
    },
    -- Racial Temperament Presets (My Voice tab). A preset replaces openers/closers, merges
    -- FriendGreetings, replaces BattleCry and may shift intensity by -1..+1.
    Presets = {
        HonorBound = {
            name = "Honor-Bound Warrior",
            blurb = "Disciplined and proud: Durotar's honor code, spoken plainly.",
            dialectIntensity = 0,
            openers = {
                "By my honor,",
                "Hear me,",
                "Lok'tar,",
                "Stand tall,",
                "Warrior's word,",
                "Honor demands,",
            },
            closers = {
                ", lok'tar ogar!",
                ", by my honor.",
                ", as the warriors do.",
                ", and I will not waver.",
                ", with honor.",
                ", so I swear.",
            },
            FriendGreetings = {
                Default = {
                    "{target}! Lok'tar! You honor me with your presence.",
                    "Well met, {target}. A strong ally is rare.",
                    "{target}. Stand with me, warrior.",
                },
            },
            BattleCry = {
                "Lok'tar ogar!",
                "For honor and for the Horde!",
                "Victory or death!",
            },
        },
        SpiritCaller = {
            name = "Spirit-Caller",
            blurb = "Thoughtful, reverent and in tune with the elements of the Horde's shamanic tradition.",
            dialectIntensity = -1,
            openers = {
                "The spirits say,",
                "Hear the earth,",
                "As the elements speak,",
                "By ancestors' word,",
                "Listen,",
                "The totems know,",
            },
            closers = {
                ", so the spirits whisper.",
                ", the ancestors guide.",
                ", as the earth wills.",
                ", in the elements' name.",
                ", and so be it.",
                ", spirits willing.",
            },
            FriendGreetings = {
                Default = {
                    "{target}. The spirits are gentle upon your arrival.",
                    "Well met, {target}. May the ancestors watch you.",
                    "{target}. Sit with me by the fire.",
                },
            },
            BattleCry = {
                "Spirits, lend me your strength!",
                "By earth and fire!",
                "The elements answer!",
            },
        },
        BloodAndThunder = {
            name = "Blood-and-Thunder Brawler",
            blurb = "Loud, aggressive, delighted by battle.",
            dialectIntensity = 1,
            openers = {
                "Ha!",
                "Hear this,",
                "Come on,",
                "Blood and thunder,",
                "Stand and fight,",
                "Mok'gora,",
            },
            closers = {
                ", and let's break something!",
                ", ha!",
                ", blood and thunder!",
                ", or get out of the way!",
                ", let's go!",
                ", I like these odds.",
            },
            FriendGreetings = {
                Default = {
                    "{target}! There you are! Ready for a fight?",
                    "Ha! {target}! Ale or axes first?",
                    "{target}! Good! I was getting bored.",
                },
            },
            BattleCry = {
                "BLOOD AND THUNDER!",
                "Break them all!",
                "Lok'tar ogar, come get some!",
            },
        },
    },
    EmoteReplies = {
        Wave = {
            "Lok'tar, {target}!",
            "Throm-ka, {target}.",
            "Well met, {target}.",
            "Strength to you, {target}!",
        },
        Bow = {
            "Rise, {target}. Orcs bow to no one, and neither should you.",
            "Your respect is noted, {target}.",
            "Stand tall, {target}.",
            "Honor to you as well, {target}.",
        },
        Cheer = {
            "LOK'TAR, {target}!",
            "Ha! For the Horde, {target}!",
            "Blood and thunder, {target}!",
            "That is the spirit of a warrior, {target}!",
        },
        Toast = {
            "To victory, {target}!",
            "To the Horde, {target}!",
            "To strength and honor, {target}!",
            "Drink deep, {target}!",
        },
        Hug = {
            "Ha! A strong grip, {target}!",
            "Careful, {target}. I might crush you back.",
            "Brother! Sister! Good to see you, {target}!",
            "Enough, {target}! The others are watching.",
        },
        Rude = {
            "Say that to my axe, {target}.",
            "You test me, {target}.",
            "Careful, {target}. Orcs do not forget.",
            "Again, and you bleed, {target}.",
        },
        Challenge = {
            "Ha! I accept, {target}!",
            "Name the place, {target}. I will be there.",
            "You will regret that, {target}. Gladly.",
            "Blood and thunder, {target}! Come!",
        },
    },
    RivalOpeners = {
        Vendetta = {
            "{target}! For {lastzone}! LOK'TAR!",
            "Blood for {lastzone}, {target}!",
            "{target}! The axe remembers {lastzone}!",
            "You will pay for {lastzone}, {target}!",
        },
        SwornFoe = {
            "{target}! Again! Good!",
            "You never learn, {target}!",
            "Ha! {target}, back for more!",
            "{target}! My axe missed you!",
        },
        Nemesis = {
            "{target}! THIS ENDS NOW! LOK'TAR OGAR!",
            "FOR THE HORDE! {target}, FALL!",
            "{target}! Only one of us walks away!",
            "Blood and thunder, {target}! Your end!",
        },
        Default = {
            "Lok'tar, {target}!",
            "For the Horde, {target}!",
            "Face me, {target}!",
            "Blood and thunder, {target}!",
        },
    },
    StanceGreetings = {
        WARM = {
            "Lok'tar, {target}! The {targetrace} are welcome at our fires.",
            "Well met, {target}. Strength to your people.",
            "{target}! A true friend of the Horde.",
            "Throm-ka, {target}. It is good to see you.",
        },
        ADMIRING = {
            "{target}. Your people's strength is known even in Orgrimmar.",
            "Lok'tar, {target}! The {targetrace} fight with honor.",
            "{target}, I would stand beside your kind in any battle.",
            "Honor to you, {target}. Your people have earned it.",
        },
        PLAYFUL = {
            "Ha! {target}! You look soft. Eat more meat.",
            "{target}! Still alive? Impressive!",
            "Lok'tar, {target}! Try to keep up this time.",
            "{target}! I could carry you AND your pack.",
        },
        WARY = {
            "{target}. Prove your worth.",
            "Hm. {target}. The Horde watches.",
            "{target}. Trust is paid in blood.",
            "Careful, {target}. I am watching.",
        },
        GRUFF = {
            "{target}. Out of my way.",
            "Hmph. {target}. Weak.",
            "{target}. Do not waste my time.",
            "{target}. Move.",
        },
        DISDAINFUL = {
            "{target}. Small and weak.",
            "Hah. One of the {targetrace}. How fragile.",
            "{target}. You would not last a day in Durotar.",
            "{target}. I have seen stronger kodo calves.",
        },
        Tauren = {
            WARM = {
                "{target}! Cairne's people are our truest friends.",
                "Well met, {target}. The Horde owes the tauren much.",
                "{target}! Strength of the plains, strength of the Horde!",
            },
            GRUFF = {
                "{target}. Less meditating, more fighting.",
                "Hmph. {target}. Your people are too slow to anger.",
                "{target}. Must every tauren speak in riddles?",
            },
        },
        Troll = {
            WARM = {
                "{target}! Darkspear and orc, side by side, as Thrall wills.",
                "Lok'tar, {target}! Vol'jin's people are welcome here.",
                "{target}! The Echo Isles stand with the Horde.",
            },
            GRUFF = {
                "{target}. Keep your voodoo away from my food.",
                "Hmph. {target}. Stop grinning.",
                "{target}. Trolls talk too much.",
            },
        },
        Scourge = {
            WARM = {
                "{target}. The Horde gave your people a home. Stand with us.",
                "Well met, {target}. Strength to the Forsaken.",
                "{target}. You fight well for one without a heartbeat.",
            },
            GRUFF = {
                "{target}. You smell of the grave.",
                "Hmph. {target}. I do not trust your Dark Lady.",
                "{target}. Keep your plagues in Lordaeron.",
            },
        },
    },
    -- Racial combat openers: mixed into signature-move pull lines now and then
    -- (homeland, kin and pride; the class and spell pools cover the rest)
    CombatOpeners = {
        "Lok'tar ogar.",
        "For the Horde. For Durotar.",
        "Blood and thunder.",
        "My ancestors are watching. I will not shame them.",
        "Strength and honor.",
        "Thrall freed us for this. To stand and fight.",
        "The Frostwolves sing of fights like this.",
        "No chains. Not ever again.",
        "Durotar's red earth raised me. Come taste it.",
        "Hold nothing back.",
        "Victory or death. I prefer victory.",
    },
    -- Clans / lineages: chosen on the My Voice tab (only this race's appear). Combat lines
    -- join pull lines now and then, Greet lines friendly greetings, Idle lines idle chatter.
    Clans = {
        { key = "Frostwolf", name = "Frostwolf Clan",
            Combat = {
                "For the Frostwolves. For Thrall.",
                "The wolves of Alterac run with me.",
                "Durotan's honor guides my axe.",
                "Cold teaches patience. Then it bites.",
            },
            Greet = {
                "The Frostwolves greet you, {target}.",
                "Warm yourself. You are among friends.",
                "Thrall's clan keeps its word. So do I.",
            },
            Idle = {
                "Durotar is too warm. I miss the snow.",
                "My wolf has grown lazy in this heat.",
                "The elders still sing of Durotan.",
            },
        },
        { key = "Warsong", name = "Warsong Clan",
            Combat = {
                "The Warsong never stopped singing.",
                "Grom died free. I fight the same way.",
                "Hellscream's clan does not hold back.",
                "Charge. That is the Warsong way.",
            },
            Greet = {
                "The Warsong salutes you, {target}.",
                "You have a warrior's look. Good.",
                "Grom's spirit would approve of you.",
            },
            Idle = {
                "The Ashenvale lumber camps need more axes.",
                "Grom broke the curse. Never forget that.",
                "Too quiet. The Warsong prefer noise.",
            },
        },
        { key = "ShatteredHand", name = "Shattered Hand Clan",
            Combat = {
                "The Shattered Hand gives nothing back.",
                "I cut away my weakness. Watch.",
                "Blades where hands should be. Fitting.",
                "Pain is just a teacher.",
            },
            Greet = {
                "{target}. You keep strange company.",
                "The Shattered Hand respects those who endure.",
                "Few greet us warmly. I notice when one does.",
            },
            Idle = {
                "Orgrimmar's shadows suit our clan.",
                "The old clan marks still ache in the cold.",
                "Ask no questions about my hand. I won't lie.",
            },
        },
        { key = "Blackrock", name = "Blackrock / Bleeding Hollow",
            Combat = {
                "Blackrock iron does not break.",
                "The Hollow bleeds. So will you.",
                "My clan stood at the Dark Portal. You are nothing.",
                "Old blood, old fury.",
            },
            Greet = {
                "Well met, {target}. My clan has a long history. Not all of it ugly.",
                "Blackrock or Bleeding Hollow, I fight for the Horde now.",
                "Strength and honor, friend.",
            },
            Idle = {
                "Blackrock Mountain still holds our shame.",
                "Some of my clan never left the old ways.",
                "The Bleeding Hollow hunt by night. I still do.",
            },
        },
        { key = "Dragonmaw", name = "Dragonmaw Clan",
            Combat = {
                "The Dragonmaw broke dragons. You are smaller.",
                "Grim Batol remembers my clan.",
                "I've seen red dragons bleed.",
                "Fire does not frighten a Dragonmaw.",
            },
            Greet = {
                "{target}. Do not ask about the Wetlands.",
                "The Dragonmaw serve the Horde now. Mostly.",
                "Well met. Mind the smell of sulfur. It never washes out.",
            },
            Idle = {
                "Grim Batol's walls still haunt me.",
                "My clan rode dragons once. Now I walk.",
                "The Wetlands are too damp for proper fire.",
            },
        },
    },
}
