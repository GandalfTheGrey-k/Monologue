--[[
    Monologue Data Module: Paladin Class
    PURE DATA TABLE.

    Lines are written for every race that can walk the Paladin's path in WoW Forever,
    Undead Paladins included: they speak of the Light's answer and a sworn vow, never of
    a particular homeland. SpellTriggers use Classic-era rank-specific IDs, verified in-game
    with /mono triggers. No Avenging Wrath or other later-expansion abilities.
--]]

MonologueEngine.Data.Classes["PALADIN"] = {
    -- Class dialect: sits UNDERNEATH the race dialect, so a race (or persona or profile) that
    -- defines the same swap or list wins. The words and phrases here are Paladin-specific
    -- (faith, protection, justice) so they rarely collide with a race's own vocabulary.
    Dialect = {
        wordSwaps = {
            ["holy"] = { "sacred", "hallowed", "blessed" },
            ["evil"] = { "wicked", "unrighteous", "foul" },
            ["protect"] = { "shield", "guard", "ward" },
            ["justice"] = { "righteousness", "judgment", "what is right" },
            ["hope"] = { "faith", "a beacon", "promise" },
            ["blessing"] = { "grace", "benediction", "boon" },
        },
        phraseSwaps = {
            ["i'll protect you"] = { "my shield is yours", "none shall harm you" },
            ["heal me"] = { "mend my wounds", "I need the Light's touch" },
            ["have faith"] = { "trust in the Light", "keep the faith" },
            ["say a prayer"] = { "offer a prayer", "pray with me" },
            ["bless you"] = { "the Light bless you", "be blessed" },
            ["for justice"] = { "for righteousness", "for what is right" },
            ["stand with me"] = { "stand beside me", "walk with me in the Light" },
        },
    },
    SpellReactions = {
        Tier1_MajorCD = {
            "The Light answers my vow!",
            "Bathed in radiance, I cannot fall!",
            "By the Light, stand firm!",
            "My oath holds. Let none pass!",
            "The Light is with me!",
            "By the Silver Hand!",
            "Righteousness, unleashed!",
            "Feel the wrath of the Light!",
        },
        Tier2_Routine = {
            "Face the Light's judgment!",
            "Justice will be served!",
            "Yield, or be humbled!",
            "The Light guides my hand!",
            "The Light guides my hammer.",
            "Be cleansed.",
            "Justice, swift and sure.",
            "Stand down, wretch.",
        },
        Tier3_LowHP = {
            "The Light is not done with me yet!",
            "I will not break my vow here!",
            "Light, lend me strength!",
            "Hold the line... I need a moment!",
            "Light, grant me strength!",
            "My faith will not falter!",
            "I will not fall while the Light shines!",
            "Hold fast! The Light protects!",
        }
    },
    SpellTriggers = {
        [642] = "Tier1_MajorCD",    -- Divine Shield (rank 1)
        [1020] = "Tier1_MajorCD",   -- Divine Shield (rank 2)
        [498] = "Tier1_MajorCD",    -- Divine Protection (rank 1)
        [5573] = "Tier1_MajorCD",   -- Divine Protection (rank 2)
        [633] = "Tier1_MajorCD",    -- Lay on Hands (rank 1)
        [2800] = "Tier1_MajorCD",   -- Lay on Hands (rank 2)
        [10310] = "Tier1_MajorCD",  -- Lay on Hands (rank 3)
        [1022] = "Tier1_MajorCD",   -- Blessing of Protection (rank 1)
        [5599] = "Tier1_MajorCD",   -- Blessing of Protection (rank 2)
        [10278] = "Tier1_MajorCD",  -- Blessing of Protection (rank 3)
        [20216] = "Tier1_MajorCD",  -- Divine Favor
        [853] = "Tier2_Routine",    -- Hammer of Justice (rank 1)
        [5588] = "Tier2_Routine",   -- Hammer of Justice (rank 2)
        [5589] = "Tier2_Routine",   -- Hammer of Justice (rank 3)
        [10308] = "Tier2_Routine",  -- Hammer of Justice (rank 4)
        [20473] = "Tier2_Routine",  -- Holy Shock (rank 1)
        [20929] = "Tier2_Routine",  -- Holy Shock (rank 2)
        [20930] = "Tier2_Routine",  -- Holy Shock (rank 3)
        [20271] = "Tier2_Routine",  -- Judgement
        [20066] = "Tier2_Routine",  -- Repentance
    },
    SpellNames = {
        [642] = "Divine Shield", [1020] = "Divine Shield",
        [498] = "Divine Protection", [5573] = "Divine Protection",
        [633] = "Lay on Hands", [2800] = "Lay on Hands", [10310] = "Lay on Hands",
        [1022] = "Blessing of Protection", [5599] = "Blessing of Protection", [10278] = "Blessing of Protection",
        [20216] = "Divine Favor",
        [853] = "Hammer of Justice", [5588] = "Hammer of Justice",
        [5589] = "Hammer of Justice", [10308] = "Hammer of Justice",
        [20473] = "Holy Shock", [20929] = "Holy Shock", [20930] = "Holy Shock",
        [20271] = "Judgement", [20066] = "Repentance",
    },
    -- Pull lines (see Engine:ResolvePullPool): SpellLines[<spell name>] is used when you pull
    -- or open with that spell; CombatOpeners otherwise. Each pool is drawn as a shuffled deck,
    -- so every line comes up once before any repeats. Keys are English spell names.
    CombatOpeners = {
        "The Light shall judge you!",
        "Stand fast in the Light!",
        "By the Light, face me!",
        "Your darkness ends here.",
        "For the Light and for Lordaeron's memory!",
        "I am the Light's shield!",
        "Repent, or fall!",
        "Justice comes for you!",
        "The Silver Hand stands!",
        "My faith is my armor!",
        "Have at you, in the Light's name!",
        "Evil does not endure.",
        "Hold, wretch. Judgement is here.",
        "Light give me strength!",
        "Steel and faith, together!",
    },
    SpellLines = {
        ["Judgement"] = {
            "Judgement!",
            "The Light has judged you!",
            "Your sins are counted!",
            "Guilty!",
            "Justice is swift!",
            "The verdict is in!",
            "Judged and found wanting!",
            "By the Light, you are condemned!",
            "Feel the weight of your deeds!",
            "Light's judgement falls!",
            "No appeal!",
            "The sentence is pain!",
        },
        ["Exorcism"] = {
            "Begone, foul thing!",
            "Exorcism!",
            "Out, darkness!",
            "The Light burns the unclean!",
            "Back to the shadows with you!",
            "Be cleansed!",
            "The Light purges you!",
            "No evil survives this!",
            "Unholy thing, perish!",
            "Burn in holy fire!",
            "Light, drive it out!",
            "Your corruption ends now!",
        },
        ["Holy Light"] = {
            "Light, mend this flesh.",
            "Be whole again.",
            "The Light heals all wounds.",
            "Rise, and fight on!",
            "Holy Light, hear me!",
            "The Light restores.",
            "Breathe easy. The Light is here.",
            "Not today. Not while I stand.",
            "Be healed, friend.",
            "Light, guide my hands.",
            "Your wounds are mended.",
            "The Light does not abandon us.",
        },
        ["Hammer of Justice"] = {
            "Justice!",
            "Be still!",
            "Hammer down!",
            "Kneel before justice!",
            "Stay down, wretch!",
            "The Light stuns the wicked!",
            "Halt!",
            "You'll answer for that!",
            "Feel the hammer of the Light!",
            "Down you go!",
            "No escape from justice!",
            "Stopped cold!",
        },
    },
    pvpStyle = "Zealous Bulwark"
}
