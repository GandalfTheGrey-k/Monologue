--[[
    Monologue Data Module: Undead (Forsaken) Race
    PURE DATA TABLE. Key matches UnitRace("player") raceFile "Scourge".
    Lore: Undercity, Lordaeron, the Dark Lady, the Apothecary Society, the Scarlet Crusade.
    No Lich King events. WoW Forever canon only.

    Dialect format: see the top of Monologue_Translator.lua. A string value is one fixed swap;
    a list of strings is a set of variants, one picked at random (the last 3 are avoided).
    The Forsaken are dry and sardonic, so the cadence is formal with dark understatement.
--]]

MonologueEngine.Data.Races["Scourge"] = {
    Dialect = {
        wordSwaps = {
            ["hello"] = { "greetings", "well met", "salutations", "how pleasant" },
            ["hi"] = { "greetings", "salutations", "well met" },
            ["goodbye"] = { "until we are both bones", "farewell, for now", "until the grave calls" },
            ["yes"] = { "indeed", "quite", "naturally", "of course" },
            ["thanks"] = { "how kind", "my thanks", "you're too generous" },
            ["friend"] = { "companion", "comrade", "fellow unliving" },
            ["friends"] = { "companions", "comrades", "fellow unliving" },
            ["alive"] = { "still among the living", "yet breathing", "clinging to life" },
            ["dead"] = { "departed", "deceased", "at rest" },
            ["die"] = { "perish", "expire", "succumb" },
            ["death"] = { "the end", "oblivion", "the grave" },
            ["afraid"] = { "fearful", "trembling", "unsettled" },
            ["fear"] = { "dread", "terror", "unease" },
        },
        phraseSwaps = {
            ["thank you"] = { "how generous", "you are too kind", "most appreciated" },
            ["thanks a lot"] = { "how very kind", "I am touched, truly" },
            ["watch out"] = { "mind the shadows", "beware", "tread carefully, living one" },
            ["be careful"] = { "try not to die", "mind your pulse", "caution is wise" },
            ["good job"] = { "acceptable work", "well done, truly", "not terrible" },
            ["let's go"] = { "let us depart", "onward, then", "the dark awaits" },
            ["on my way"] = { "I shamble over", "coming, slowly", "arriving, eventually" },
            ["good luck"] = { "you'll need it", "fortune, such as it is", "may death be kind" },
            ["good morning"] = { "another day, unfortunately", "morning, I suppose" },
            ["good night"] = { "sleep well. I don't", "rest, if you can" },
            ["i don't know"] = { "I have no idea, truly", "the grave keeps its secrets" },
            ["i'm sorry"] = { "my condolences", "a regrettable outcome" },
            ["help me"] = { "lend me a hand, if you still have one", "I could use a moment" },
            ["come on"] = { "hurry along", "the dead wait for no one" },
            ["are you ok"] = { "still intact?", "are you whole?" },
        },
        contractions = {
            -- Precise, formal cadence: contractions open up now and then
            ["can't"] = "cannot",
            ["don't"] = "do not",
            ["won't"] = "will not",
            ["it's"] = "it is",
        },
        phonetics = {
            ["^gonna$"] = "going to",
            ["^wanna$"] = "want to",
        },
        interjections = { "quite", "truly", "how droll", "naturally" },
        openers = {
            "Listen,",
            "Tell me,",
            "Frankly,",
            "How droll,",
            "Pay attention,",
            "Consider this,",
            "In my experience,",
            "For the Dark Lady,",
        },
        closers = {
            ", for the Dark Lady.",
            ", for whatever that is worth.",
            ", if you still draw breath.",
            ", while it lasts.",
            ", how droll.",
            ", as expected.",
            ", naturally.",
            ", the grave awaits.",
        },
    },
    GuildGreetings = {
        Standard = {
            "Greetings, companion. Death has not slowed us yet.",
            "The Dark Lady watches. Walk with purpose.",
            "Still among the unliving, I see. Excellent.",
            "Ah, the guild. Still breathing, most of you.",
            "For the Dark Lady. And, I suppose, for each other.",
            "Welcome back. Try not to die. It's overrated.",
            "The Undercity sends its... regards.",
            "Another day of unlife. Let's make it count.",
        }
    },
    FriendGreetings = {
        Ally = {
            "{target}. One of the few I don't mind.",
            "Still standing beside me. How rare.",
            "Shall we go ruin someone's day together?",
            "A comrade. I'd almost forgotten the word.",
            "You watch my back. I'll watch everything else.",
        },
        Default = {
            "Greetings, {target}. Death has not slowed us yet.",
            "{target}! You are alive. Or close enough. Welcome.",
            "Well met, {target}. The Dark Lady watches over friends too.",
            "Ah, {target}. One of the few I don't mind sharing a crypt with.",
            "{target}. A friendly face. How refreshing, and how rare.",
            "{target}. Still among the living? I'm almost glad.",
            "Ah, {target}. A tolerable face, for once.",
            "{target}. Come, walk with me. The graveyard is quiet tonight.",
            "Well met, {target}. You're not dead yet. Congratulations.",
        },
    },
    DuelWin = {
        "A fine duel, {target}. I'd say you'll live, but I can't promise.",
        "Victory, {target}. Don't take it personally. I'm dead inside anyway.",
        "Well fought, {target}. You nearly gave me a heartbeat.",
        "That was educational, {target}. Mostly for you.",
        "I've died before, {target}. This was nothing.",
        "Well fought, {target}. For a breathing thing.",
        "Pain is a memory to me, {target}. You never stood a chance.",
        "Rise, {target}. I insist. It's more than I got.",
    },
    DuelLoss = {
        "You've won this one, {target}. I'll remember it forever. That is a promise.",
        "Well fought, {target}. A shame, as I have nothing left to lose.",
        "Hm. Impressive, {target}. I'll practice on someone else first.",
        "You've bested me, {target}. Death is often unfair like that.",
        "Hah. I've had worse, {target}. I've had death.",
        "Well done, {target}. I'll add it to my list of grievances.",
        "You win, {target}. Enjoy it while you still have a pulse.",
        "Fine. Fine, {target}. Again, when you've rested.",
    },
    PvPLines = {
        FirstClash = {
            "A fresh pulse in {zone}. How refreshing, {target}.",
            "You smell of life, {target}. Let us see how long it lasts.",
            "Ah, fresh meat in {zone}. Hello, {target}.",
            "You smell alive, {target}. Let's fix that.",
        },
        DejaVu = {
            "{zone} again. The ground itself is beginning to feel familiar.",
            "Another grave dug in {zone}. How efficient.",
            "{zone} again. The graves here are full.",
            "So many bodies in {zone}. I could use them.",
        },
        Rematch = {
            "You return, {target}? I do so enjoy persistence.",
            "Oh good. You survived. Let us fix that.",
            "Back again, {target}? Persistent. Like rot.",
            "You return, {target}. How tedious.",
        },
        Vendetta = {
            "You killed me once in {lastzone}, {target}. I have had time to dwell on it.",
            "I remember {lastzone}, {target}. The dead hold grudges well.",
            "I still taste {lastzone}, {target}. Bitter.",
            "{lastzone}, {target}. I keep grudges. I have time.",
        },
        Dominance = {
            "You have fallen to me before, {target}. Do not make me repeat it.",
            "Death is easy. Fleeing is wiser, {target}.",
            "You keep dying, {target}. Have you considered joining us?",
            "Again, {target}? How dull.",
        },
        Nemesis = {
            "{target}. We have danced for so long that I have grown fond of it. Shall we end it in {lastzone}?",
            "For the Dark Lady, your end comes today, {target}!",
            "{target}. For the Dark Lady, you end here.",
            "Death was not the end for me, {target}. It will be for you.",
        },
    },
    -- Racial Temperament Presets (My Voice tab). A preset replaces openers/closers, merges
    -- FriendGreetings, replaces BattleCry and may shift intensity by -1..+1.
    Presets = {
        BitterRevenant = {
            name = "Bitter Revenant",
            blurb = "Cold, vengeful and resentful of the living; the Forsaken's rage given voice.",
            dialectIntensity = 1,
            openers = {
                "Hmph,",
                "How tedious,",
                "Do you know,",
                "Spare me,",
                "Listen well,",
                "Death changes things,",
            },
            closers = {
                ", and I resent it.",
                ", how tiresome.",
                ", you wouldn't understand.",
                ", I've seen worse.",
                ", ha.",
                ", so it goes.",
            },
            FriendGreetings = {
                Default = {
                    "{target}. You still draw breath. How quaint.",
                    "Well met, {target}. Try not to bore me.",
                    "{target}. Of all the living, you're tolerable.",
                },
            },
            BattleCry = {
                "Die again!",
                "You will join us!",
                "Burn, living one!",
            },
        },
        ColdApothecary = {
            name = "Cold Apothecary",
            blurb = "Analytical, detached and curious about everything, including your decay.",
            dialectIntensity = -1,
            openers = {
                "Fascinating,",
                "Observe,",
                "One notes,",
                "Clinically speaking,",
                "Specimen,",
                "By my notes,",
            },
            closers = {
                ", as expected.",
                ", for science.",
                ", noted.",
                ", the results are clear.",
                ", how curious.",
                ", entirely logical.",
            },
            FriendGreetings = {
                Default = {
                    "{target}. A fine specimen. Do hold still.",
                    "Well met, {target}. How is your constitution?",
                    "{target}. Please, ignore the smell; it's the lab.",
                },
            },
            BattleCry = {
                "For the Dark Lady and for science!",
                "FOR THE ROYAL APOTHECARY!",
                "Let the experiment proceed!",
            },
        },
        GallowsHumor = {
            name = "Gallows-Humor Ghoul",
            blurb = "Grim jokes, bone-dry sarcasm and a sense of humor that outlived the body.",
            dialectIntensity = 1,
            openers = {
                "Dead funny,",
                "Ha ha,",
                "Bury me,",
                "Well, I'm dead,",
                "Grave news,",
                "Oh, the irony,",
            },
            closers = {
                ", I'm just dying to know.",
                ", how grave.",
                ", ha, ha.",
                ", it's a killer.",
                ", can't make this up.",
                ", rest in pieces.",
            },
            FriendGreetings = {
                Default = {
                    "{target}! You look alive! Terrible choice.",
                    "Ha! {target}! Come to join the fun?",
                    "{target}. Wonderful. Another day, another corpse.",
                },
            },
            BattleCry = {
                "Last one dead is a rotten egg!",
                "Come, let's die laughing!",
                "Bury them all!",
            },
        },
    },
    EmoteReplies = {
        Wave = {
            "Oh. Hello, {target}.",
            "Yes, yes. Hello, {target}.",
            "Greetings, {target}. Still breathing, I see.",
            "A wave? How lively, {target}.",
        },
        Bow = {
            "How quaint, {target}.",
            "Rise, {target}. I'm not royalty. Not anymore.",
            "Your respect is... noted, {target}.",
            "Careful, {target}. Bow too low and something falls off.",
        },
        Cheer = {
            "Ha. Ha. Yes, {target}. Very exciting.",
            "For the Dark Lady, {target}!",
            "Enthusiasm. How refreshing, {target}.",
            "Fine, {target}. Huzzah.",
        },
        Toast = {
            "To unlife, {target}!",
            "To the Dark Lady, {target}!",
            "Cheers, {target}. It goes straight through me.",
            "To the grave and back, {target}!",
        },
        Hug = {
            "Careful, {target}. Things fall off.",
            "Ugh. Warm. Hello, {target}.",
            "You're brave, {target}. Most people won't touch me.",
            "That's... nice, {target}. Now stop.",
        },
        Rude = {
            "I've been insulted by better, {target}. They're dead now.",
            "How droll, {target}.",
            "Careful, {target}. I have plague and patience.",
            "Noted, {target}. Filed under 'later'.",
        },
        Challenge = {
            "You challenge the dead, {target}? Amusing.",
            "Fine, {target}. I've nothing to lose.",
            "Bring it, {target}. Pain is a memory.",
            "Ha. Choose your grave, {target}.",
        },
    },
    RivalOpeners = {
        Vendetta = {
            "{target}. I've thought about {lastzone} every day since.",
            "For {lastzone}, {target}. Rot.",
            "{target}! {lastzone} isn't forgotten. Nothing is.",
            "Remember {lastzone}, {target}? I do.",
        },
        SwornFoe = {
            "{target}, again. How very persistent.",
            "Back for another funeral, {target}?",
            "{target}. I'll bury you again.",
            "Oh, {target}. You never learn.",
        },
        Nemesis = {
            "{target}! The Dark Lady wills your end!",
            "FOR SYLVANAS! {target}, DIE!",
            "{target}! Join us in the grave!",
            "I crawled out of the grave for this, {target}!",
        },
        Default = {
            "Die, {target}.",
            "For the Dark Lady, {target}!",
            "Your turn, {target}.",
            "Into the grave, {target}!",
        },
    },
    StanceGreetings = {
        WARM = {
            "{target}. The {targetrace} have treated us fairly. I won't forget that.",
            "Ah, {target}. One of the good ones.",
            "{target}. You're welcome near me. That's rare.",
            "Well met, {target}. Truly.",
        },
        ADMIRING = {
            "{target}. Your people have a vitality I almost miss.",
            "I respect the {targetrace}, {target}. Few have earned it.",
            "{target}. Your kind fights well. I've watched.",
            "Ah, {target}. Your people endure. As do we.",
        },
        PLAYFUL = {
            "{target}! You look terrible. Oh wait, that's me.",
            "Ah, {target}. Still mortal? Shame.",
            "{target}! Come closer. I don't bite. Much.",
            "Hello, {target}. Lose anything lately? I have. My left ear.",
        },
        WARY = {
            "{target}. I've been betrayed by the living before.",
            "Hm. {target}. Keep your distance.",
            "{target}. I'm watching you. I don't blink.",
            "{target}. Trust is something I left in my grave.",
        },
        GRUFF = {
            "{target}. Go away.",
            "Ugh. {target}.",
            "{target}. I'm busy decomposing.",
            "{target}. Leave me be.",
        },
        DISDAINFUL = {
            "{target}. So warm. So soft. So temporary.",
            "Oh, one of the {targetrace}. How short your lives are.",
            "{target}. Your kind will be bones soon enough.",
            "{target}. I'd say well met, but I'd be lying.",
        },
        Orc = {
            WARM = {
                "{target}. Thrall gave us a place. The Forsaken remember debts.",
                "Well met, {target}. Strong arms, honest blades.",
                "{target}. The Horde is better for your people.",
            },
            GRUFF = {
                "{target}. Less shouting, please. My ears are loose.",
                "Hmph. {target}. Your honor is very loud.",
                "{target}. Some of us don't need to roar.",
            },
        },
        Tauren = {
            WARM = {
                "{target}. Your people never once looked away from us. Thank you.",
                "Ah, {target}. The kindest of the Horde.",
                "{target}. The Earth Mother's children are always welcome.",
            },
            GRUFF = {
                "{target}. Stop trying to heal me. I'm dead.",
                "Hmph. {target}. Your Earth Mother doesn't want me.",
                "{target}. I don't need a hug. Or a blessing.",
            },
        },
        Troll = {
            WARM = {
                "{target}. Your voodoo and our alchemy. A fine partnership.",
                "Ah, {target}. You laugh at death too. I like that.",
                "{target}. The Darkspear understand the dark.",
            },
            GRUFF = {
                "{target}. Stop calling me 'mon'.",
                "Hmph. {target}. Your loa can't have me.",
                "{target}. Leave the bones alone.",
            },
        },
    },
    -- Racial combat openers: mixed into signature-move pull lines now and then
    -- (homeland, kin and pride; the class and spell pools cover the rest)
    CombatOpeners = {
        "Death was the easy part.",
        "The Banshee Queen sends her greetings.",
        "For the Forsaken. For Lady Sylvanas.",
        "I've already been dead. You haven't.",
        "Bones and spite. That's all I need.",
        "The Lich King lost me. You won't keep me either.",
        "The Undercity has a cell for you.",
        "No pain left in me. Only patience.",
        "Tirisfal remembers you. Not fondly.",
        "Come closer. I don't bite. Much.",
        "Free will is a terrible thing to waste.",
    },
    -- Clans / lineages: chosen on the My Voice tab (only this race's appear). Combat lines
    -- join pull lines now and then, Greet lines friendly greetings, Idle lines idle chatter.
    Clans = {
        { key = "Fallen", name = "Lordaeron Fallen",
            Combat = {
                "Lordaeron's dead remember.",
                "I died for this kingdom once.",
                "My old king lied. You're next.",
                "The fallen rise. Watch.",
            },
            Greet = {
                "{target}. You don't flinch. I like that.",
                "Welcome to what's left of Lordaeron.",
                "Well met, from one who used to be human.",
            },
            Idle = {
                "I used to farm in Brill. Funny thought.",
                "The capital's ruins still look like home.",
                "Some nights I remember my old name.",
            },
        },
        { key = "Apothecary", name = "Royal Apothecary / Deathguard",
            Combat = {
                "For the Dark Lady. For the Society.",
                "Deathguard, hold.",
                "The plague will finish what I start.",
                "You'll make a fine sample.",
            },
            Greet = {
                "{target}. Hold still, I'm testing a theory.",
                "The Deathguard greet you.",
                "Need a tonic? Don't ask what's in it.",
            },
            Idle = {
                "Faranell owes me a report.",
                "The new plague still needs refining.",
                "Brill's patrol needs more guards.",
            },
        },
    },
    -- Battle cries (/mono cry and the Battle Cry button). A temperament preset or a
    -- character profile may replace them; My Voice battle cries are added on top.
    BattleCry = {
        "FOR THE DARK LADY!",
        "FOR THE FORSAKEN!",
        "DEATH TO THE LIVING!",
        "WE ARE FREE!",
        "THE GRAVE CAN WAIT!",
        "VICTORY FOR SYLVANAS!",
        "RISE AND FIGHT!",
        "NO MASTERS!",
    },
}
