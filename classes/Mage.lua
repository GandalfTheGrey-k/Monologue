--[[
    Monologue Data Module: Mage Class
    PURE DATA TABLE.

    Lines suit any race of Mage, Skyborne arcanists included, and speak of the arcane,
    fire and frost in general terms. SpellTriggers use Classic-era rank-specific IDs,
    verified in-game with /mono triggers. No later-expansion abilities.
--]]

MonologueEngine.Data.Classes["MAGE"] = {
    -- Class dialect: sits UNDERNEATH the race dialect, so a race (or persona or profile) that
    -- defines the same swap or list wins. The words and phrases here are Mage-specific
    -- (fire, frost, study, portals) so they rarely collide with a race's own vocabulary.
    Dialect = {
        wordSwaps = {
            ["ice"] = { "frost", "rime", "glacial cold" },
            ["fire"] = { "flame", "blaze", "pyre" },
            ["burn"] = { "scorch", "incinerate", "sear" },
            ["freeze"] = { "chill", "frost over", "rime" },
            ["portal"] = { "gateway", "rift", "portal" },
            ["wizard"] = { "mage", "arcanist", "scholar of the art" },
        },
        phraseSwaps = {
            ["i'm busy"] = { "I'm mid-incantation", "one moment, I'm casting" },
            ["stand back"] = { "clear the area", "give me room to work" },
            ["that's elementary"] = { "that's quite simple", "child's play, really" },
            ["cast a spell"] = { "weave a working", "speak the words" },
            ["i need a moment"] = { "give me a moment to concentrate", "one moment, calculating" },
            ["open a portal"] = { "open a gateway", "tear open a rift" },
        },
    },
    SpellReactions = {
        Tier1_MajorCD = {
            "Behold the arcane, unbound!",
            "Power beyond your understanding!",
            "Time bends to my will!",
            "Let the elements burn!",
            "Behold, the arcane!",
            "Witness true power!",
            "Now for the impressive part!",
            "Magic, unleashed!",
        },
        Tier2_Routine = {
            "A little flame never hurt anyone. Much.",
            "Stand still, this won't take long.",
            "Fascinating. Observe.",
            "You're about to learn something.",
            "Elementary.",
            "Simple magic.",
            "As expected.",
            "Textbook.",
        },
        Tier3_LowHP = {
            "That wasn't in the calculations!",
            "A moment, I need distance!",
            "Never mind my robes. Protect my head!",
            "Even a mage can run out of tricks!",
            "Need a moment to concentrate!",
            "This is not in the textbook!",
            "Blink! Blink!",
            "Somebody distract it!",
        }
    },
    SpellTriggers = {
        [27619] = "Tier1_MajorCD",  -- Ice Block
        [12051] = "Tier1_MajorCD",  -- Evocation
        [12043] = "Tier1_MajorCD",  -- Presence of Mind
        [12042] = "Tier1_MajorCD",  -- Arcane Power
        [11129] = "Tier1_MajorCD",  -- Combustion
        [12472] = "Tier1_MajorCD",  -- Icy Veins
        [11958] = "Tier1_MajorCD",  -- Cold Snap
        [2139] = "Tier2_Routine",   -- Counterspell
        [118] = "Tier2_Routine",    -- Polymorph (rank 1)
        [12824] = "Tier2_Routine",  -- Polymorph (rank 2)
        [12825] = "Tier2_Routine",  -- Polymorph (rank 3)
        [12826] = "Tier2_Routine",  -- Polymorph (rank 4)
        [122] = "Tier2_Routine",    -- Frost Nova (rank 1)
        [865] = "Tier2_Routine",    -- Frost Nova (rank 2)
        [6131] = "Tier2_Routine",   -- Frost Nova (rank 3)
        [10230] = "Tier2_Routine",  -- Frost Nova (rank 4)
        [1953] = "Tier2_Routine",   -- Blink
    },
    SpellNames = {
        [27619] = "Ice Block", [12051] = "Evocation", [12043] = "Presence of Mind",
        [12042] = "Arcane Power", [11129] = "Combustion", [12472] = "Icy Veins",
        [11958] = "Cold Snap", [2139] = "Counterspell",
        [118] = "Polymorph", [12824] = "Polymorph", [12825] = "Polymorph", [12826] = "Polymorph",
        [122] = "Frost Nova", [865] = "Frost Nova", [6131] = "Frost Nova", [10230] = "Frost Nova",
        [1953] = "Blink",
    },
    -- Pull lines (see Engine:ResolvePullPool): SpellLines[<spell name>] is used when you pull
    -- or open with that spell; CombatOpeners otherwise. Each pool is drawn as a shuffled deck,
    -- so every line comes up once before any repeats. Keys are English spell names.
    CombatOpeners = {
        "Let's warm things up.",
        "Arcane, fire or frost? Decisions.",
        "You're about to learn something.",
        "Class is in session!",
        "Mind the robes.",
        "I've studied for exactly this.",
        "Allow me to demonstrate.",
        "Magic, as it should be: violent!",
        "The Kirin Tor would approve.",
        "Stand back. Further.",
        "Prepare to be polymorphed. Or worse.",
        "Elementary.",
        "A little magic goes a long way.",
        "Shall we begin?",
        "Watch closely. There's a test.",
    },
    SpellLines = {
        ["Fireball"] = {
            "Fireball!",
            "Burn!",
            "Catch!",
            "Hot hot hot!",
            "It's getting warm!",
            "Flame on!",
            "Feel the heat!",
            "Up in smoke!",
            "Fire solves most problems!",
            "Ignite!",
            "Warmth, delivered!",
            "Toasty!",
            "A classic for a reason!",
        },
        ["Frostbolt"] = {
            "Chill out!",
            "Frostbolt!",
            "Freeze!",
            "Cold shoulder!",
            "Ice to meet you!",
            "Slow down!",
            "A winter's kiss!",
            "Brr!",
            "Frozen in place!",
            "Stay cool!",
            "Feel the frost!",
            "Winter is here!",
        },
        ["Arcane Missiles"] = {
            "Arcane Missiles!",
            "Pew pew pew!",
            "Missiles away!",
            "A volley of arcana!",
            "Five for you!",
            "Magic in motion!",
            "Seeking you out!",
            "Arcane barrage!",
            "Can't dodge these!",
            "Raw magic!",
            "Purple pain incoming!",
            "One, two, three, four, five!",
        },
        ["Frost Nova"] = {
            "Freeze!",
            "Stay right there!",
            "Frost Nova!",
            "Everyone, freeze!",
            "Chilly, isn't it?",
            "Rooted in ice!",
            "Hold still!",
            "Ice to meet you all!",
            "Frozen in place!",
            "Nobody move!",
            "Cold feet?",
            "Stuck!",
        },
    },
    pvpStyle = "Glass Cannon"
}
