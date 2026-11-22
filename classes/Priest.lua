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
    SpellReactions = {
        Tier1_MajorCD = {
            "Faith will carry us through!",
            "Power flows through me!",
            "Be strong. I will not let you fall!",
            "Hear my prayer, and answer it!",
            "The Light answers!",
            "Bear witness to faith!",
            "Shadows, rise!",
            "Feel the power of belief!",
        },
        Tier2_Routine = {
            "Your suffering is a lesson.",
            "Be still and be judged.",
            "A small mercy, a smaller warning.",
            "Mind over matter, friend.",
            "Repent.",
            "Be still.",
            "Light, guide this.",
            "Your sins catch up with you.",
        },
        Tier3_LowHP = {
            "I need a moment of prayer!",
            "Even the faithful bleed!",
            "Someone shield me, please!",
            "My faith is not so easily broken!",
            "Light, preserve me!",
            "I need a moment of grace!",
            "My faith holds!",
            "Shield me!",
        }
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
    -- Pull lines (see Engine:ResolvePullPool): SpellLines[<spell name>] is used when you pull
    -- or open with that spell; CombatOpeners otherwise. Each pool is drawn as a shuffled deck,
    -- so every line comes up once before any repeats. Keys are English spell names.
    CombatOpeners = {
        "The Light have mercy on you. I won't.",
        "Begone!",
        "Your soul trembles.",
        "Faith is a weapon too.",
        "Pray, while you can.",
        "I see the darkness in you.",
        "Hear my prayer, and suffer!",
        "Even healers bite.",
        "Light, guide my hand.",
        "Shadow and light both answer me.",
        "Kneel.",
        "You will find no sanctuary here.",
        "Blessed are the swift. You are not.",
        "My sermon begins!",
        "Repent now!",
    },
    SpellLines = {
        ["Smite"] = {
            "Smite!",
            "The Light strikes!",
            "Holy fire!",
            "Be smitten!",
            "By the Light!",
            "Heaven's wrath!",
            "Feel the holy flame!",
            "A blessing, of sorts!",
            "The Light burns!",
            "Divine retribution!",
            "Struck by faith!",
            "Bow before the Light!",
        },
        ["Shadow Word: Pain"] = {
            "Suffer.",
            "Pain, shadow-born.",
            "Feel it creep in.",
            "The shadows whisper your name.",
            "A word of pain.",
            "It only gets worse.",
            "Agony, slowly.",
            "Darkness bites.",
            "Writhe.",
            "One word is all it takes.",
            "Your mind will break before your body.",
            "The shadow takes its toll.",
        },
        ["Mind Blast"] = {
            "Feel your mind break!",
            "Think about that!",
            "Mind Blast!",
            "Your thoughts betray you!",
            "A headache, perhaps?",
            "Shattered!",
            "Out of your mind!",
            "Consider yourself enlightened!",
            "Your mind is mine!",
            "Think fast!",
            "Mental anguish!",
            "The mind bleeds too.",
        },
        ["Power Word: Shield"] = {
            "Shielded!",
            "The Light protects you.",
            "You're covered.",
            "Stand behind this.",
            "A ward of faith.",
            "Nothing gets through.",
            "Be safe.",
            "Shield up!",
            "The Light is your armor.",
            "Go! You're protected!",
            "Hold the line, I've got you.",
            "Faith is a shield.",
        },
    },
    pvpStyle = "Devout Support"
}
