--[[
    Monologue Data Module: Multi-File Character Profile - Webb Page (4/4) - Growth
    PURE DATA TABLE. Level-bracket progression hooks and boss feats.

    GrowthStages: the stage matching Webb's level is layered over _Combat.lua while it is
    active. Brackets: Stage1_Early = levels 1-19, Stage2_Mid = 20-49, Stage3_Late = 50-60.
    (The engine's key for the last bracket is Stage3_Late; a veteran-voiced stage belongs
    there.) Any pool the engine reads can go in a stage: SpellReactions, PvPLines,
    DuelWin, DuelLoss, FriendGreetings, and so on. Pools that a stage doesn't define fall
    through to the ones in _Combat.lua and _PvP.lua.

    BossFeats unlock automatically when the boss is defeated (key = a registered WoW Forever
    raid boss, e.g. RAGNAROS, ONYXIA, NEFARIAN, HAKKAR; /mono feat <KEY> unlocks one by
    hand) and are layered over everything else. Keep lore within WoW Forever canon.
--]]

MonologueEngine.Data.Profiles["WebbPage"] = MonologueEngine.Data.Profiles["WebbPage"] or {}

MonologueEngine.Data.Profiles["WebbPage"].GrowthStages = {
    Stage1_Early = { -- Levels 1-19: new to the shapes, keen and a little clumsy
        SpellReactions = {
            Tier1_MajorCD = {
                "Okay okay okay, hope I remember how this works!",
                "Here goes nothing! Please be a bear, please be a bear!",
                "The wild is on my side! I think!",
                "Watch this! ...Watch this! It's about to be great!",
                "I can do this! Probably!",
                "Little sprout, big roar!",
                "Watch me, Tara!",
                "The wild is with me!",
            },
        },
    },

    Stage2_Mid = { -- Levels 20-49: comfortable in fur and bark
        SpellReactions = {
            Tier1_MajorCD = {
                "Stand behind me. I've got this one.",
                "Bark up! This is the fun part!",
                "Nature's with us today. Let's use it!",
                "I've done this before. Mostly on purpose.",
                "Nature's got my back!",
                "Claws and thorns!",
                "Feel the wild!",
                "The grove grows strong!",
            },
        },
    },

    Stage3_Late = { -- Levels 50-60: seasoned, calm, a little dangerous
        SpellReactions = {
            Tier1_MajorCD = {
                "The wild runs deep, and I run with it!",
                "Steady now. The garden does not lose.",
                "I've weathered worse storms than you.",
                "Roots and bark and years of practice. Move.",
                "The ancient wild answers!",
                "Every root, every branch, with me!",
                "Old as the forest, fierce as the storm!",
                "The wild is eternal!",
            },
            Tier3_LowHP = {
                "Old oaks bend. They don't break.",
                "Not my first brush with death. Barely my tenth.",
                "Keep it off me a moment while I mend.",
                "The wild isn't done with me yet.",
                "Bark and stone, hold!",
                "The grove will not fall!",
                "Mend me, wild!",
                "I've weathered worse storms!",
            },
        },
    },
}

-- Placeholders: each unlocks once the boss is defeated. Add more by copying a block and
-- changing the key (see the list in the header above).
MonologueEngine.Data.Profiles["WebbPage"].BossFeats = {
    RAGNAROS = { -- Unlocked after defeating Ragnaros in Molten Core
        PvPLines = {
            Nemesis = {
                "{opener} I stood in the Firelord's halls and kept my fur, {target}! You can't burn me! {closer}",
                "I walked through Molten Core with my roots intact, {target}!",
                "The Firelord couldn't burn the wild out of me, {target}!",
                "Fire and fury, {target}? I've seen worse!",
            },
        },
    },
    ONYXIA = { -- Unlocked after defeating Onyxia
        PvPLines = {
            Dominance = {
                "I've faced a dragon in her own lair, {target}. You're no trouble at all.",
                "Dragonslayer, {target}. You're just a lizard.",
                "Onyxia's lair was scarier than you, {target}.",
                "I've pruned bigger pests than you, {target}.",
            },
        },
    },
    -- NEFARIAN = { PvPLines = { Vendetta = { "..." } } },
    -- HAKKAR   = { PvPLines = { Rematch  = { "..." } } },
}
