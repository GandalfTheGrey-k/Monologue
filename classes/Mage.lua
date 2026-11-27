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
    -- Tier1_MajorCD: the Battle Cry fallback (when a character has no BattleCry pool).
    -- Tier3_LowHP: said when your health drops low.
    SpellReactions = {
        Tier1_MajorCD = {
            "Everything I have. Now.",
            "Years of study. One moment.",
            "Stand clear of the casting.",
            "The Kirin Tor would blush.",
            "All of it. Every rune.",
            "Now you see why we study.",
            "Let it all go!",
            "Full power.",
        },
        Tier3_LowHP = {
            "I need distance. Now.",
            "Cloth does nothing. Nothing!",
            "That was my last ward.",
            "Out of mana and out of patience.",
            "Not in my notes. Not in any notes.",
            "Somebody pull it off me!",
            "One blink left. Maybe.",
            "Robes torn. Pride too.",
            "I'm a scholar, not a shield.",
            "Focus. Just focus.",
        },
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
    CombatOpeners = {
        "Three schools to choose from. Fire, then.",
        "Hold my books.",
        "I've read about creatures like you.",
        "Let's test a theory.",
        "Stand back. Further than that.",
        "Allow me.",
        "Mana's full. Patience isn't.",
        "I'll make this brief.",
        "I didn't spend years in Dalaran for nothing.",
        "Fascinating. Hold still a moment.",
        "Careful. I've been reading again.",
        "Let me get my sleeves out of the way.",
        "A practical lesson, then.",
        "Theory's over. Practice.",
        "You'll do for an experiment!",
    },
    -- Signature moves: a spell's own lines. Pull lines when you open a fight with it;
    -- big = true lets a cooldown speak mid-fight, midChance lets crowd control, interrupts
    -- and heals speak mid-fight now and then. .Player lines are for enemy players.
    SpellLines = {
        ["Fireball"] = {
            "A bit of heat.",
            "Warm enough?",
            "Fire never needs explaining.",
            "Straight from the hand.",
            "Mind the eyebrows.",
            "Burns hotter than it looks.",
            "That'll leave a scorch mark.",
            "Something warm to start.",
            "A little flame first.",
            "Smell that? That's you.",
            "Lighting it was the easy part.",
            "First lesson: fire hurts!",
            Player = {
                "You came looking for a fire, {target}.",
                "Sleeves up, {target}. This is going to sting.",
                "Cloth and flame. I'll take my chances.",
                "Warm yourself on that, {target}.",
                "I studied for this, {target}. You didn't.",
                "Smoke on the wind, {target}. Yours.",
            },
        },
        ["Frostbolt"] = {
            "Cold as a Dun Morogh winter.",
            "Your legs will stiffen.",
            "Stiff joints now.",
            "Frost on your breath.",
            "Ice in the blood.",
            "Chilly, isn't it?",
            "A northern wind, straight to you.",
            "There. Numb all over.",
            "Shiver for me.",
            "Keep moving. If you can.",
            "Winter came early.",
            "Cold hands, clear head!",
        },
        ["Arcane Missiles"] = {
            "Five little lessons.",
            "Count them as they land.",
            "Hold still for the rest.",
            "Pure arcane, no fuss.",
            "Don't flinch. Too late.",
            "Each one finds you.",
            "Channeling. Don't interrupt.",
            "A volley, politely delivered.",
            "Raw mana. Mind your fingers.",
            "Purple, I know. It still hurts.",
            "A steady stream of trouble.",
            "Keep counting!",
        },
        ["Frost Nova"] = {
            midChance = 0.3,
            "Everyone, stay where you are.",
            "Feet frozen. Good.",
            "Nobody move. Literally.",
            "A ring of ice. Step back.",
            "Iced to the floor.",
            "There. Now I can think.",
            "Rooted. Give me a moment.",
            "Stuck fast.",
            "Cold underfoot.",
            "Room to cast, at last!",
            Player = {
                "Cold feet, {target}?",
                "Planted, {target}. I'll be over there.",
                "Ice holds. You don't.",
                "Wriggle all you like.",
                "Frozen in place. Lovely.",
                "Stay put while I walk away, {target}.",
            },
        },
        ["Polymorph"] = {
            midChance = 0.3,
            "Baa.",
            "Much better as a sheep.",
            "Sheep. Stay a sheep.",
            "Wool suits you.",
            "Don't make me try the chicken next time.",
            "Graze quietly.",
            "There. Harmless.",
            "Nobody hit the sheep.",
            "Ten seconds of peace.",
            "You're cuter this way.",
            "Nibble the grass for a bit.",
            "Leave that one alone, it's wool now!",
            Player = {
                "Say baa, {target}.",
                "Sit this one out, {target}. As a sheep.",
                "Wool looks good on you, {target}.",
                "Graze a while. I'll be busy.",
                "No spells from a sheep, {target}.",
                "Fluffy and harmless, {target}.",
            },
        },
        ["Counterspell"] = {
            midChance = 0.3,
            "Not that spell.",
            "I'll be having that.",
            "Your casting's done.",
            "Wrong school. Try another.",
            "Sloppy hands. I noticed.",
            "No. Not today.",
            "Mid-word? How rude of me.",
            "I read your hands.",
            "Interrupted. Again.",
            "Quiet in the library!",
            Player = {
                "I saw that coming, {target}.",
                "Your teacher should have warned you.",
                "Not while I'm watching, {target}.",
                "I read your hands from here, {target}.",
                "No more of that school for you.",
                "Rude of me. I'm not sorry, {target}.",
            },
        },
        ["Blink"] = {
            midChance = 0.2,
            "Not there anymore.",
            "Excuse me.",
            "Over here now.",
            "A short step.",
            "Distance, please.",
            "Gone. Well, twenty yards gone.",
            "Out of reach.",
            "Too close for comfort.",
        },
        ["Ice Block"] = {
            big = true,
            "Give me a moment.",
            "Cold, quiet, safe.",
            "Pausing. Don't wait up.",
            "I'll be in here.",
            "Knock all you like.",
            "Time out.",
            "The ice holds. Think, think.",
            "Wait it out.",
        },
        ["Evocation"] = {
            big = true,
            "Give me a few breaths.",
            "Topping up.",
            "Keep them off me. I'm drinking the air.",
            "Mana, come back.",
            "Nearly empty. Fixing that.",
            "Just a moment of quiet.",
            "Don't touch me while I do this.",
            "Patience. I'm refilling.",
        },
        ["Arcane Power"] = {
            big = true,
            "All the arcane I can hold.",
            "Raw and loud.",
            "Careful. This is the dangerous part.",
            "Mana's going fast. So are you.",
            "Let's not hold back.",
            "All the power, none of the restraint.",
            "Burning through it now.",
            "No more careful casting!",
        },
        ["Combustion"] = {
            big = true,
            "Hotter.",
            "Every spark at once.",
            "Let it catch.",
            "Hold your noses.",
            "Now it really burns.",
            "The whole room's warming up.",
            "Fire on fire.",
            "Burn bright!",
        },
    },
    pvpStyle = "Glass Cannon"
}
