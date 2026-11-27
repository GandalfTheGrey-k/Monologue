--[[
    Monologue Data Module: Shaman Class
    PURE DATA TABLE.

    Lines suit every race that walks the Shaman's path in WoW Forever, Dwarf Shamans and
    Skyborne Shamans included: they speak of the elements and the spirits, never of one
    people's tradition. SpellTriggers use Classic-era rank-specific IDs, verified in-game
    with /mono triggers. No Bloodlust, Heroism or other later-expansion abilities.
--]]

MonologueEngine.Data.Classes["SHAMAN"] = {
    -- Class dialect: sits UNDERNEATH the race dialect, so a race (or persona or profile) that
    -- defines the same swap or list wins. The words and phrases here are Shaman-specific
    -- (elements, spirits, totems) so they rarely collide with a race's own vocabulary.
    Dialect = {
        wordSwaps = {
            ["fire"] = { "flame", "ember", "blaze" },
            ["water"] = { "tide", "stream", "flow" },
            ["ancestor"] = { "elder spirit", "forebear", "ancestral spirit" },
            ["ancestors"] = { "elder spirits", "forebears", "ancestral spirits" },
            ["balance"] = { "harmony", "equilibrium", "the balance" },
            ["lightning"] = { "thunder-fire", "the storm's fire", "lightning" },
        },
        phraseSwaps = {
            ["the spirits are angry"] = { "the elements are restless", "the spirits stir in anger" },
            ["call the totems"] = { "raise the totems", "summon the spirit-poles" },
            ["feel the earth"] = { "listen to the earth", "the ground speaks" },
            ["ask the spirits"] = { "consult the spirits", "the spirits will answer" },
            ["in balance"] = { "in harmony", "with the elements at peace" },
            ["thank the spirits"] = { "give thanks to the spirits", "the spirits are generous" },
        },
    },
    -- Tier1_MajorCD: the Battle Cry fallback (when a character has no BattleCry pool).
    -- Tier3_LowHP: said when your health drops low.
    SpellReactions = {
        Tier1_MajorCD = {
            "Spirits, answer.",
            "Earth, fire, water, wind!",
            "The elements are with us.",
            "Ancestors, now!",
            "Storm, come down!",
            "The Earth Mother is watching.",
            "All four. Now.",
            "Thunder, answer me.",
        },
        Tier3_LowHP = {
            "The spirits feel far away.",
            "Bleeding. Earth, steady me.",
            "I hear the ancestors calling. Not yet.",
            "Totems down, help me up.",
            "The wind's going out of me.",
            "Too much, too fast.",
            "Need water. The healing kind.",
            "Ancestors, a little strength.",
            "My ankh's in my bag. I'd rather not use it.",
            "Still breathing. Spirits be thanked.",
        },
    },
    SpellTriggers = {
        [20608] = "Tier1_MajorCD",  -- Reincarnation
        [16188] = "Tier1_MajorCD",  -- Nature's Swiftness
        [16166] = "Tier1_MajorCD",  -- Elemental Mastery
        [16190] = "Tier1_MajorCD",  -- Mana Tide Totem
        [8177] = "Tier1_MajorCD",   -- Grounding Totem
        [8143] = "Tier1_MajorCD",   -- Tremor Totem
        [2484] = "Tier2_Routine",   -- Earthbind Totem
        [8042] = "Tier2_Routine",   -- Earth Shock (rank 1)
        [8044] = "Tier2_Routine",   -- Earth Shock (rank 2)
        [8045] = "Tier2_Routine",   -- Earth Shock (rank 3)
        [8046] = "Tier2_Routine",   -- Earth Shock (rank 4)
        [10412] = "Tier2_Routine",  -- Earth Shock (rank 5)
        [10413] = "Tier2_Routine",  -- Earth Shock (rank 6)
        [10414] = "Tier2_Routine",  -- Earth Shock (rank 7)
        [8050] = "Tier2_Routine",   -- Flame Shock (rank 1)
        [8052] = "Tier2_Routine",   -- Flame Shock (rank 2)
        [8053] = "Tier2_Routine",   -- Flame Shock (rank 3)
        [10447] = "Tier2_Routine",  -- Flame Shock (rank 4)
        [10448] = "Tier2_Routine",  -- Flame Shock (rank 5)
        [29228] = "Tier2_Routine",  -- Flame Shock (rank 6)
        [370] = "Tier2_Routine",    -- Purge (rank 1)
        [8012] = "Tier2_Routine",   -- Purge (rank 2)
        [17364] = "Tier2_Routine",  -- Stormstrike
    },
    SpellNames = {
        [20608] = "Reincarnation", [16188] = "Nature's Swiftness", [16166] = "Elemental Mastery",
        [16190] = "Mana Tide Totem", [8177] = "Grounding Totem", [8143] = "Tremor Totem",
        [2484] = "Earthbind Totem",
        [8042] = "Earth Shock", [8044] = "Earth Shock", [8045] = "Earth Shock", [8046] = "Earth Shock",
        [10412] = "Earth Shock", [10413] = "Earth Shock", [10414] = "Earth Shock",
        [8050] = "Flame Shock", [8052] = "Flame Shock", [8053] = "Flame Shock",
        [10447] = "Flame Shock", [10448] = "Flame Shock", [29228] = "Flame Shock",
        [370] = "Purge", [8012] = "Purge", [17364] = "Stormstrike",
    },
    CombatOpeners = {
        "The earth is restless today.",
        "Totems down. Let's begin.",
        "The wind told me you'd come.",
        "Spirits, watch this one.",
        "I'll ask the elements nicely. Once.",
        "Fire's eager today.",
        "The ancestors are listening.",
        "Smell that? Storm's coming.",
        "Water, earth, fire, air. Pick.",
        "The ground is on my side.",
        "You disturbed the balance.",
        "Earth Mother, steady my hands.",
        "The spirits don't like you.",
        "Thunder first, then talk.",
        "Let the storm speak!",
    },
    -- Signature moves: a spell's own lines. Pull lines when you open a fight with it;
    -- big = true lets a cooldown speak mid-fight, midChance lets crowd control, interrupts
    -- and heals speak mid-fight now and then. .Player lines are for enemy players.
    SpellLines = {
        ["Lightning Bolt"] = {
            "The sky has an opinion.",
            "Thunder follows.",
            "Straight from the clouds.",
            "Spark, then storm.",
            "Feel the air crackle.",
            "Mind the hair.",
            "Wind and lightning, old friends.",
            "A gift from the storm.",
            "That smell? That's the storm.",
            "Clouds remember.",
            "Snap and crackle.",
            "Thunder speaks!",
            Player = {
                "The storm picked you, {target}.",
                "Your hair's standing up, {target}.",
                "Thunder knows your name, {target}.",
                "Hear that? You're next.",
                "The sky doesn't miss, {target}.",
                "The storm's on my side today.",
            },
        },
        ["Earth Shock"] = {
            midChance = 0.3,
            "The earth says no.",
            "Ground under your words.",
            "Quiet. The stone is speaking.",
            "Shake loose.",
            "Spell broken.",
            "Shaken.",
            "Stone stops tongues.",
            "Rattled? You should be.",
            "Words don't survive tremors.",
            "The earth interrupts.",
            "Feet off the ground.",
            "Quake!",
            Player = {
                "The stone won't let you, {target}.",
                "Swallow that spell, {target}.",
                "Rattled, {target}?",
                "Stone beats spells.",
                "Not while I stand on this ground.",
                "Your words fall flat, {target}.",
            },
        },
        ["Flame Shock"] = {
            "Fire under the skin.",
            "Let it smolder.",
            "The flame takes its time.",
            "A little heat that stays.",
            "Burn slowly.",
            "The fire spirits are hungry.",
            "An ember in the blood.",
            "It'll keep burning.",
            "Smoke rises.",
            "Fire remembers.",
            "Catch and hold.",
            "Smolder for me!",
        },
        ["Frost Shock"] = {
            midChance = 0.3,
            "Cold water, cold feet.",
            "Slow, like a winter river.",
            "Ice in your step.",
            "Frozen, partly.",
            "Water spirits, hold them.",
            "The river's cold today.",
            "Slower now.",
            "Numb toes.",
            "The chill settles in.",
            "Winter's breath.",
            "Not so quick now.",
            "Frozen tracks!",
        },
        ["Chain Lightning"] = {
            midChance = 0.3,
            "One for each of you.",
            "Pass it along.",
            "The storm doesn't play favorites.",
            "Lightning jumps.",
            "All of you, share this.",
            "Every one of you.",
            "It travels.",
            "Spread out next time.",
        },
        ["Stormstrike"] = {
            midChance = 0.3,
            "Storm in the blade.",
            "Thunder in my hand.",
            "Struck by the storm.",
            "The weapon sings.",
            "Lightning, up close.",
            "Hit by the sky.",
            "Steel and storm.",
            "Crackle!",
        },
        ["Purge"] = {
            midChance = 0.3,
            "That's not yours.",
            "Stripped.",
            "No more help.",
            "Your magic is borrowed. I'm taking it back.",
            "A clean slate.",
            "Let's take that off.",
            "Spirits, unmake it.",
            "No shields for you.",
        },
        ["Earthbind Totem"] = {
            midChance = 0.2,
            "The ground's holding you.",
            "Heavy feet here.",
            "Stay near the stone.",
            "The earth grabs.",
            "Slow going.",
            "Walk through mud.",
            "Earth holds.",
            "Can't run here.",
        },
        ["Elemental Mastery"] = {
            big = true,
            "All of the storm. Now.",
            "Hear me, every spirit.",
            "Full force.",
            "The elements obey.",
            "Now, completely.",
            "No holding back.",
            "The storm's mine.",
            "Everything, at once!",
        },
        ["Healing Wave"] = {
            midChance = 0.15,
            "Water, mend them.",
            "The spirits heal.",
            "Wash it away.",
            "Cool and clean.",
            "Breathe. Better?",
            "Rest on the wave.",
            "Healing waters.",
            "There, whole again.",
            "Back to it.",
            "The river mends.",
        },
    },
    pvpStyle = "Elemental Skirmisher"
}
