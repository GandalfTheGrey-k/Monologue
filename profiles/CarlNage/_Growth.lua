--[[
    Monologue Data Module: Multi-File Character Profile - Carl Nage (4/4) - Growth
    PURE DATA TABLE. GrowthStages & BossFeats for Carl Nage, Dwarf Warrior.

    Stage1_Early = levels 1-19, Stage2_Mid = 20-49, Stage3_Late = 50-60. A stage's pools
    replace the matching pools from _Combat.lua while that stage is active: here, Carl's
    battle cries change as he grows, and at 50+ so do his low-health lines.

    BossFeats unlock automatically when the boss is defeated (key = registered WoW Forever
    raid boss; /mono feat <KEY> unlocks one by hand). Lore stays within WoW Forever canon:
    the Dark Iron dwarves of Blackrock Mountain, the Firelord, Onyxia, Nefarian and Hakkar.
--]]

MonologueEngine.Data.Profiles["CarlNage"] = MonologueEngine.Data.Profiles["CarlNage"] or {}

MonologueEngine.Data.Profiles["CarlNage"].GrowthStages = {
    Stage1_Early = { -- Levels 1-19: green recruit, loud and eager
        BattleCry = {
            "BATTLEHAMMER! AT 'EM!",
            "FER IRONFORGE!",
            "KHAZ MODAN!",
            "FER THE CLAN!",
            "AXE UP! CHARGE!",
            "FIRST BLOOD TA THE BATTLEHAMMERS!",
        },
    },
    Stage2_Mid = { -- Levels 20-49: seasoned fighter, cocky and sharp
        BattleCry = {
            "BATTLEHAMMER STANDS!",
            "INTO 'EM, LADS!",
            "HOLD THE LINE!",
            "FER IRONFORGE!",
            "BATTLEHAMMERS, FORWARD!",
            "GOL'KOSH!",
        },
    },
    Stage3_Late = { -- Levels 50-60: hardened veteran, calm and dangerous
        BattleCry = {
            "BATTLEHAMMER ETERNAL!",
            "REMEMBER GRIM BATOL!",
            "STAND WI' ME, KIN!",
            "THE OLD HAMMER STILL FALLS!",
            "KHAZ MODAN!",
            "FROM THE FORGE TA THE GRAVE!",
        },
        SpellReactions = {
            Tier3_LowHP = {
                "Old bones, stubborn heart.",
                "Bled worse in Blackrock.",
                "Not me last stand. Not yet.",
                "A dwarf dies when he's ready. I'm not.",
                "Patch me up. I've a tab to settle.",
                "Stone cracks. It doesnae crumble.",
                "Hurts. Good. Means I'm alive.",
                "Keep swingin', old man.",
            },
        },
    },
}

MonologueEngine.Data.Profiles["CarlNage"].BossFeats = {
    RAGNAROS = { -- Unlocked after defeating Ragnaros in Molten Core
        PvPLines = {
            Nemesis = {
                "I stood in the Firelord's own hall, {target}. Ye don't scare me.",
                "Molten Core singed me beard. Ye won't.",
                "I've felt hotter than you, {target}.",
                "Fire couldnae finish me. Ye'll not either.",
            },
        },
    },
    ONYXIA = { -- Unlocked after defeating Onyxia
        PvPLines = {
            Dominance = {
                "I've stared down a dragon, {target}. Ye're a lizard.",
                "Dragonslayer, lad. Mind yer manners.",
                "Onyxia was taller. And smarter.",
                "After a dragon's breath, yours is nothin'.",
            },
        },
    },
    NEFARIAN = { -- Unlocked after defeating Nefarian in Blackwing Lair
        PvPLines = {
            Vendetta = {
                "I've cleared Blackwing Lair, {target}. {lastzone} was a scrape.",
                "Nefarian bled. So will ye.",
                "I broke a black dragon's brood. Ye're one dwarf's grudge.",
                "After Blackrock, {lastzone} was a stroll.",
            },
        },
    },
    HAKKAR = { -- Unlocked after defeating Hakkar in Zul'Gurub
        PvPLines = {
            Rematch = {
                "I've bled the Soulflayer, {target}. Ye're a lesser terror.",
                "Zul'Gurub taught me not to fear masks.",
                "Hakkar was scarier. Smelled better too.",
                "Back for more? So was Hakkar. Once.",
            },
        },
    },
}
