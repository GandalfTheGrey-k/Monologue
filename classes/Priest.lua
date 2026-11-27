--[[
    Monologue Data Module: Priest Class
    PURE DATA TABLE.

    Lines suit any race of Priest, whether their faith is Light or shadow. SpellTriggers
    use Classic-era rank-specific IDs, verified in-game with /mono triggers.
    No later-expansion abilities.
--]]

MonologueEngine.Data.Classes["PRIEST"] = {
    -- Class dialect: sits UNDERNEATH the race dialect, so a race (or persona or profile) that
    -- defines the same swap or list wins. The words and phrases here are Priest-specific
    -- (prayer, mercy, devotion) so they rarely collide with a race's own vocabulary.
    Dialect = {
        wordSwaps = {
            ["pray"] = { "beseech", "entreat", "offer prayers" },
            ["forgive"] = { "absolve", "pardon", "grant mercy" },
            ["faith"] = { "devotion", "belief", "the light within" },
            ["sin"] = { "transgression", "failing", "wrong" },
            ["wounds"] = { "hurts", "injuries", "afflictions" },
            ["holy"] = { "blessed", "hallowed", "sacred" },
        },
        phraseSwaps = {
            ["rest in peace"] = { "may they find peace", "peace be upon them" },
            ["say a prayer"] = { "offer a prayer", "a prayer for them" },
            ["forgive me"] = { "grant me mercy", "I beg absolution" },
            ["heal me"] = { "restore me", "I need your mercy" },
            ["have mercy"] = { "show mercy", "be merciful" },
            ["bless you"] = { "blessings upon you", "the Light keep you" },
            ["i'll pray for you"] = { "you are in my prayers", "I will beseech the Light for you" },
        },
    },
    -- Tier1_MajorCD: the Battle Cry fallback (when a character has no BattleCry pool).
    -- Tier3_LowHP: said when your health drops low.
    SpellReactions = {
        Tier1_MajorCD = {
            "Light, hear me!",
            "Stand together. I've got you all.",
            "Nobody falls on my watch.",
            "Hold on. Help is here.",
            "Faith, now and loud.",
            "Shadow or Light, it all answers me.",
            "Stay in my sight!",
            "Everyone, close to me.",
        },
        Tier3_LowHP = {
            "Your healer needs healing.",
            "I can't heal myself and you at once.",
            "These robes do nothing!",
            "Get it off me. Please.",
            "Pray for me a moment.",
            "A little help, before I'm a ghost.",
            "Light, a little faster.",
            "My hands are shaking.",
            "This is why I stand at the back.",
            "Somebody watch my back!",
        },
    },
    SpellTriggers = {
        [10060] = "Tier1_MajorCD",  -- Power Infusion
        [6346] = "Tier1_MajorCD",   -- Fear Ward
        [14751] = "Tier1_MajorCD",  -- Inner Focus
        [13908] = "Tier1_MajorCD",  -- Desperate Prayer (rank 1)
        [19236] = "Tier1_MajorCD",  -- Desperate Prayer (rank 2)
        [19238] = "Tier1_MajorCD",  -- Desperate Prayer (rank 3)
        [19240] = "Tier1_MajorCD",  -- Desperate Prayer (rank 4)
        [19241] = "Tier1_MajorCD",  -- Desperate Prayer (rank 5)
        [19242] = "Tier1_MajorCD",  -- Desperate Prayer (rank 6)
        [19243] = "Tier1_MajorCD",  -- Desperate Prayer (rank 7)
        [8122] = "Tier2_Routine",   -- Psychic Scream (rank 1)
        [8124] = "Tier2_Routine",   -- Psychic Scream (rank 2)
        [10888] = "Tier2_Routine",  -- Psychic Scream (rank 3)
        [10890] = "Tier2_Routine",  -- Psychic Scream (rank 4)
        [605] = "Tier2_Routine",    -- Mind Control (rank 1)
        [10911] = "Tier2_Routine",  -- Mind Control (rank 2)
        [10912] = "Tier2_Routine",  -- Mind Control (rank 3)
        [15487] = "Tier2_Routine",  -- Silence
        [8092] = "Tier2_Routine",   -- Mind Blast (rank 1)
        [8102] = "Tier2_Routine",   -- Mind Blast (rank 2)
        [8103] = "Tier2_Routine",   -- Mind Blast (rank 3)
        [8104] = "Tier2_Routine",   -- Mind Blast (rank 4)
        [8105] = "Tier2_Routine",   -- Mind Blast (rank 5)
        [8106] = "Tier2_Routine",   -- Mind Blast (rank 6)
        [10945] = "Tier2_Routine",  -- Mind Blast (rank 7)
        [10946] = "Tier2_Routine",  -- Mind Blast (rank 8)
        [10947] = "Tier2_Routine",  -- Mind Blast (rank 9)
    },
    SpellNames = {
        [10060] = "Power Infusion", [6346] = "Fear Ward", [14751] = "Inner Focus",
        [13908] = "Desperate Prayer", [19236] = "Desperate Prayer", [19238] = "Desperate Prayer",
        [19240] = "Desperate Prayer", [19241] = "Desperate Prayer", [19242] = "Desperate Prayer",
        [19243] = "Desperate Prayer",
        [8122] = "Psychic Scream", [8124] = "Psychic Scream", [10888] = "Psychic Scream", [10890] = "Psychic Scream",
        [605] = "Mind Control", [10911] = "Mind Control", [10912] = "Mind Control",
        [15487] = "Silence",
        [8092] = "Mind Blast", [8102] = "Mind Blast", [8103] = "Mind Blast", [8104] = "Mind Blast",
        [8105] = "Mind Blast", [8106] = "Mind Blast", [10945] = "Mind Blast", [10946] = "Mind Blast",
        [10947] = "Mind Blast",
    },
    CombatOpeners = {
        "Light guide this.",
        "Stay near me, everyone.",
        "I'll keep you standing.",
        "Mind your health. I'm watching it.",
        "A short prayer, then.",
        "Candles lit. Let's begin.",
        "Faith first. Then fists, if needed.",
        "I'll be right behind you.",
        "Don't make me waste a heal.",
        "May this be quick.",
        "I'll mend what breaks.",
        "Easy now. I have you.",
        "The shadows are listening.",
        "The Light is patient. The shadow less so.",
        "Keep your heads, and I'll keep you alive!",
    },
    -- Signature moves: a spell's own lines. Pull lines when you open a fight with it;
    -- big = true lets a cooldown speak mid-fight, midChance lets crowd control, interrupts
    -- and heals speak mid-fight now and then. .Player lines are for enemy players.
    SpellLines = {
        ["Smite"] = {
            "Holy light, sharp end first.",
            "The Light strikes.",
            "A small judgment.",
            "A word from the Cathedral.",
            "The Light rebukes you.",
            "Bright and brief.",
            "Down from the heavens.",
            "A gentle correction.",
            "Faith has an edge.",
            "Let it sting.",
            "Struck from on high.",
            "Light, make your point!",
        },
        ["Shadow Word: Pain"] = {
            "Hurts, doesn't it?",
            "It'll keep hurting.",
            "Shadow under your skin.",
            "Pain is a patient teacher.",
            "Let it settle in.",
            "One word, and you suffer.",
            "Whispers in the dark.",
            "I'll let that work.",
            "Slow and certain.",
            "The shadow knows your name now.",
            "It gets worse.",
            "Suffer quietly.",
            Player = {
                "Feel that, {target}? It stays.",
                "The shadow knows you now, {target}.",
                "I can wait. Can you?",
                "It won't stop, {target}.",
                "Pain's a teacher. Learn something.",
                "Hush now, {target}. It only spreads.",
            },
        },
        ["Mind Blast"] = {
            "Your mind, opened.",
            "That must sting behind the eyes.",
            "Thoughts scattered.",
            "A headache. A big one.",
            "Straight into your head.",
            "Let me in.",
            "I heard what you were thinking.",
            "Hold your skull together.",
            "Quiet in there now.",
            "Mind first, body next.",
            "Can you think? No?",
            "Shatter!",
        },
        ["Power Word: Shield"] = {
            midChance = 0.2,
            "Shielded. Go.",
            "You're covered.",
            "Light around you.",
            "Take the blow. You won't feel it.",
            "Protected.",
            "Go on. I've got you.",
            "Bubble's up.",
            "Safe for now.",
            "The barrier's on you.",
            "Charge in. You're warded.",
            "Stay safe.",
            "Covered. Fight!",
        },
        ["Psychic Scream"] = {
            midChance = 0.3,
            "Run. All of you.",
            "Scatter.",
            "Go away. All of you.",
            "Out of my head, out of my sight.",
            "Terror suits you.",
            "Flee!",
            "Fear's an old friend.",
            "Everyone, off me.",
            "Hear that? Run.",
            "Room to breathe.",
            Player = {
                "Run along, {target}.",
                "Scared, {target}? Good.",
                "Go on, {target}. Run.",
                "Fear finds everyone.",
                "Scream if you like. Then run.",
                "Keep running, {target}. I'll wait.",
            },
        },
        ["Fade"] = {
            midChance = 0.2,
            "Not me. Look elsewhere.",
            "I'm not here.",
            "Nothing to see.",
            "Forget about me.",
            "The shadow's hiding me.",
            "Over there. Not here.",
            "Quietly, quietly.",
            "Pay me no mind.",
        },
        ["Mind Control"] = {
            midChance = 0.4,
            "You're mine now.",
            "Walk where I say.",
            "Your hands, my will.",
            "About face.",
            "Fight for me a while.",
            "Obey.",
            "Go on. Turn on your friends.",
            "Strings attached.",
            "Your mind, my puppet.",
            "Dance.",
            Player = {
                "You belong to me now, {target}.",
                "Walk with me, {target}.",
                "Your hands answer to me.",
                "Your friends won't like this.",
                "Feel that, {target}? That's me.",
                "Kneel to me, {target}.",
            },
        },
        ["Silence"] = {
            midChance = 0.3,
            "Hush.",
            "No more words.",
            "Quiet.",
            "Not another sound.",
            "Words fail you.",
            "Speak when spoken to.",
            "Shh.",
            "Silent now.",
        },
        ["Shadowform"] = {
            big = true,
            "Into the dark.",
            "The shadow takes me.",
            "No more holding back.",
            "The whispers are louder now.",
            "Shadow, wrap me.",
            "The Light can wait.",
            "Dark and quiet.",
            "Let the shadows speak.",
        },
        ["Flash Heal"] = {
            midChance = 0.15,
            "Quick. Hold still.",
            "There. Mended.",
            "A fast mend.",
            "Don't die on me.",
            "Light, quickly.",
            "Patched.",
            "Back in it.",
            "Closed that one.",
            "Keep fighting. I've got you.",
            "Up you go.",
        },
    },
    pvpStyle = "Devout Support"
}
