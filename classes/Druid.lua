--[[
    Monologue Data Module: Druid Class
    PURE DATA TABLE.

    Lines suit any race of Druid, Skyborne included, and speak of nature, the wild and
    the balance in general terms. SpellTriggers use Classic-era rank-specific IDs, verified
    in-game with /mono triggers. No later-expansion abilities.
--]]

MonologueEngine.Data.Classes["DRUID"] = {
    -- Class dialect: sits UNDERNEATH the race dialect. Where a race (or persona or profile)
    -- defines the same swap or list, theirs wins; this fills in everything they leave open,
    -- so a Druid of any race has some nature flavor in speech.
    Dialect = {
        -- Druid-specific vocabulary, chosen so it doesn't collide with a race's own words
        -- (where a race defines the same key, the race wins and the class swap never shows)
        wordSwaps = {
            ["animal"] = { "beast", "critter", "wild-kin" },
            ["animals"] = { "beasts", "critters", "wild-kin" },
            ["heal"] = { "mend", "tend", "soothe" },
            ["healing"] = { "mending", "tending", "soothing" },
            ["tree"] = { "elder oak", "ancient tree", "great tree" },
            ["seed"] = { "seedling", "sprout", "acorn" },
        },
        phraseSwaps = {
            ["shift forms"] = { "change shape", "take another form" },
            ["bear form"] = { "the bear's shape", "bear-shape" },
            ["cat form"] = { "the cat's shape", "cat-shape" },
            ["calm down"] = { "ease, friend", "settle, the wild is patient" },
            ["nature calls"] = { "the wild calls", "the grove calls" },
        },
    },
    SpellReactions = {
        Tier1_MajorCD = {
            "Nature's fury, unleashed!",
            "The wild answers me!",
            "Let the forest remember this day!",
            "Tooth and claw, as the wild intended!",
            "The wild surges through me!",
            "Root and claw, unleashed!",
            "Nature's fury!",
            "The forest itself fights!",
        },
        Tier2_Routine = {
            "The wild takes what it is owed.",
            "Nature has patience, but I do not.",
            "Be still, little one.",
            "Roots and thorns!",
            "The wild bites.",
            "Back to the earth.",
            "Nature takes its course.",
            "Thorns!",
        },
        Tier3_LowHP = {
            "The wild does not forsake its own!",
            "Even oaks bend in a storm!",
            "I need to mend before I break!",
            "Nature, restore me!",
            "The grove sustains me!",
            "Bark, protect me!",
            "Regrowth!",
            "Nature, mend me!",
        }
    },
    SpellTriggers = {
        [29166] = "Tier1_MajorCD",  -- Innervate
        [22812] = "Tier1_MajorCD",  -- Barkskin
        [17116] = "Tier1_MajorCD",  -- Nature's Swiftness
        [740] = "Tier1_MajorCD",    -- Tranquility (rank 1)
        [8918] = "Tier1_MajorCD",   -- Tranquility (rank 2)
        [9862] = "Tier1_MajorCD",   -- Tranquility (rank 3)
        [9863] = "Tier1_MajorCD",   -- Tranquility (rank 4)
        [20484] = "Tier1_MajorCD",  -- Rebirth (rank 1)
        [20739] = "Tier1_MajorCD",  -- Rebirth (rank 2)
        [20742] = "Tier1_MajorCD",  -- Rebirth (rank 3)
        [20747] = "Tier1_MajorCD",  -- Rebirth (rank 4)
        [20748] = "Tier1_MajorCD",  -- Rebirth (rank 5)
        [22842] = "Tier1_MajorCD",  -- Frenzied Regeneration (rank 1)
        [22895] = "Tier1_MajorCD",  -- Frenzied Regeneration (rank 2)
        [22896] = "Tier1_MajorCD",  -- Frenzied Regeneration (rank 3)
        [5211] = "Tier2_Routine",   -- Bash (rank 1)
        [6798] = "Tier2_Routine",   -- Bash (rank 2)
        [8983] = "Tier2_Routine",   -- Bash (rank 3)
        [2637] = "Tier2_Routine",   -- Hibernate (rank 1)
        [18657] = "Tier2_Routine",  -- Hibernate (rank 2)
        [18658] = "Tier2_Routine",  -- Hibernate (rank 3)
        [339] = "Tier2_Routine",    -- Entangling Roots (rank 1)
        [1062] = "Tier2_Routine",   -- Entangling Roots (rank 2)
        [5195] = "Tier2_Routine",   -- Entangling Roots (rank 3)
        [5196] = "Tier2_Routine",   -- Entangling Roots (rank 4)
        [9852] = "Tier2_Routine",   -- Entangling Roots (rank 5)
        [9853] = "Tier2_Routine",   -- Entangling Roots (rank 6)
        [16979] = "Tier2_Routine",  -- Feral Charge
        [18562] = "Tier2_Routine",  -- Swiftmend
    },
    SpellNames = {
        [29166] = "Innervate", [22812] = "Barkskin", [17116] = "Nature's Swiftness",
        [740] = "Tranquility", [8918] = "Tranquility", [9862] = "Tranquility", [9863] = "Tranquility",
        [20484] = "Rebirth", [20739] = "Rebirth", [20742] = "Rebirth", [20747] = "Rebirth", [20748] = "Rebirth",
        [22842] = "Frenzied Regeneration", [22895] = "Frenzied Regeneration", [22896] = "Frenzied Regeneration",
        [5211] = "Bash", [6798] = "Bash", [8983] = "Bash",
        [2637] = "Hibernate", [18657] = "Hibernate", [18658] = "Hibernate",
        [339] = "Entangling Roots", [1062] = "Entangling Roots", [5195] = "Entangling Roots",
        [5196] = "Entangling Roots", [9852] = "Entangling Roots", [9853] = "Entangling Roots",
        [16979] = "Feral Charge", [18562] = "Swiftmend",
    },
    -- Pull lines (see Engine:ResolvePullPool): SpellLines[<spell name>] is used when you pull
    -- or open with that spell; CombatOpeners otherwise. Each pool is drawn as a shuffled deck,
    -- so every line comes up once before any repeats. Keys are English spell names.
    CombatOpeners = {
        "The wild stirs against you.",
        "Nature has no patience for your kind.",
        "Root and claw, here we go.",
        "The grove sends its regards.",
        "Balance demands this.",
        "You've trespassed long enough.",
        "The forest is watching.",
        "Thorn and fang, at your service.",
        "Let the wild decide.",
        "The seasons turn. So does your luck.",
        "I speak for the trees, and they are angry.",
        "You should have stayed out of the woods.",
        "Feel the wrath of the wild!",
        "Even the moss is against you.",
        "Bark, bite and moonlight. Pick one.",
    },
    SpellLines = {
        ["Moonfire"] = {
            "Elune's light finds you!",
            "Moonfire!",
            "Burn beneath the moon!",
            "Silver fire!",
            "The moon sees all.",
            "Let the moonlight sting!",
            "A gift from the night sky!",
            "Feel the moon's judgment!",
            "Glow a little, will you?",
            "The night burns too!",
            "Moonlight never misses.",
            "Elune, mark this one!",
            "Silver and searing!",
        },
        ["Wrath"] = {
            "Nature's wrath!",
            "Feel the wild's anger!",
            "The earth is furious!",
            "Wrath of the grove!",
            "Green fury!",
            "The forest strikes back!",
            "Nature does not forgive!",
            "A storm of leaves and anger!",
            "Taste the wild!",
            "Thorns and thunder!",
            "This is what balance looks like!",
            "The wild bites back!",
        },
        ["Rake"] = {
            "Claws out!",
            "Rip and tear!",
            "Fresh scratches!",
            "From the shadows of the grass!",
            "Feel the cat's claws!",
            "Swipe!",
            "Bleed, prey!",
            "Hunt's on!",
            "Teeth and talons!",
            "Quick, quiet, deadly!",
            "The cat plays rough!",
            "Scratch that!",
        },
        ["Entangling Roots"] = {
            "Stay put.",
            "Roots, hold!",
            "The earth grips you.",
            "Going somewhere? No.",
            "Rooted!",
            "Nature says: wait.",
            "The ground has claimed you.",
            "Struggle all you like.",
            "Grow where you stand!",
            "Tangled up, are we?",
            "The forest holds you fast.",
            "Not one step further!",
        },
        ["Starfire"] = {
            "Starfire!",
            "The stars fall on you!",
            "Light from the heavens!",
            "Feel the cosmos!",
            "Stars, burn bright!",
            "The sky itself attacks!",
            "A falling star, just for you!",
            "Heaven's fire!",
            "Elune's stars descend!",
            "Look up! Too late.",
            "Starlight never forgives!",
            "Burn like the stars!",
        },
        ["Faerie Fire"] = {
            "No hiding now.",
            "Glowing, are we?",
            "The faeries have marked you!",
            "You're lit up like a festival!",
            "Shine, little target!",
            "Can't vanish now!",
            "Marked by the fae!",
            "Sparkle and suffer!",
            "Easy to see you now.",
            "There you are!",
            "Glow for me!",
            "The wild sees you!",
        },
    },
    pvpStyle = "Shapeshifting Skirmisher"
}
