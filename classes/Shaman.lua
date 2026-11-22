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
    SpellReactions = {
        Tier1_MajorCD = {
            "The elements answer my call!",
            "Earth, wind and fire, heed me!",
            "The spirits stand with us!",
            "Let the storm break!",
            "Storm, earth and fire!",
            "Spirits, empower me!",
            "Feel the fury of the land!",
            "Thunder answers thunder!",
            "The totems roar!",
        },
        Tier2_Routine = {
            "Feel the fury of the elements!",
            "The earth trembles at your folly!",
            "Shocking, isn't it?",
            "The spirits are not pleased with you!",
            "The earth shakes.",
            "Struck by the storm.",
            "The elements disapprove.",
            "Balance must be kept.",
        },
        Tier3_LowHP = {
            "The spirits are slow to answer... I need aid!",
            "Earthmother, hold me up!",
            "I'm not done. The elements aren't done!",
            "Heal me, or the storm ends here!",
            "Spirits, mend me!",
            "The earth holds me up!",
            "Ancestors, guide me!",
            "Water, heal these wounds!",
        }
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
    -- Pull lines (see Engine:ResolvePullPool): SpellLines[<spell name>] is used when you pull
    -- or open with that spell; CombatOpeners otherwise. Each pool is drawn as a shuffled deck,
    -- so every line comes up once before any repeats. Keys are English spell names.
    CombatOpeners = {
        "The elements rise against you!",
        "Spirits, guide my hand!",
        "Storm and stone, answer me!",
        "The earth trembles for you.",
        "Feel the fury of the elements!",
        "The ancestors are watching.",
        "Totems down, fight on!",
        "Wind, fire, earth, water: pick one.",
        "The spirits demand balance!",
        "The storm comes!",
        "Earth beneath, sky above, and you between!",
        "Hear the thunder!",
        "The elements do not forgive!",
        "Spirits of the land, rise!",
        "I am the storm's voice!",
    },
    SpellLines = {
        ["Lightning Bolt"] = {
            "Lightning!",
            "Feel the storm!",
            "Thunder follows!",
            "Crackle and burn!",
            "The sky strikes!",
            "Bolt from the blue!",
            "Shocking, isn't it?",
            "The storm answers!",
            "Struck down!",
            "Hair standing up yet?",
            "Sky-fire!",
            "Ride the lightning!",
        },
        ["Earth Shock"] = {
            "The earth shakes you!",
            "Earth Shock!",
            "Silence, by stone!",
            "The ground rejects you!",
            "Shaken!",
            "Stone strikes!",
            "Feel the earth's anger!",
            "Rattled to the bones!",
            "Rock solid hit!",
            "The mountain answers!",
            "Quake!",
            "Bedrock fury!",
        },
        ["Flame Shock"] = {
            "Burn!",
            "Fire answers!",
            "Flame Shock!",
            "Feel the flames!",
            "Scorched!",
            "The fire spirits rage!",
            "Burning from within!",
            "Let it smolder!",
            "Fire, take them!",
            "Hot enough for you?",
            "The flame is hungry!",
            "Ignited!",
        },
        ["Frost Shock"] = {
            "Freeze!",
            "Cold as the north wind!",
            "Frost Shock!",
            "Chill out!",
            "Water's wrath, frozen!",
            "Slow down!",
            "Ice in your veins!",
            "The cold bites!",
            "Frozen solid!",
            "Winter's grip!",
            "Stay put!",
            "Feel the frost!",
        },
    },
    pvpStyle = "Elemental Skirmisher"
}
