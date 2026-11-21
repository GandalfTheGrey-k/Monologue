--[[
    Monologue Data Module: Multi-File Character Profile (4/4) - Growth
    PURE DATA TABLE. GrowthStages & BossFeats progression.
    Stage1_Early = levels 1-19, Stage2_Mid = 20-49, Stage3_Late = 50-60.
    BossFeats keys must be registered WoW Forever raid bosses.
--]]

MonologueEngine.Data.Profiles["_Template_Character_Split"] = MonologueEngine.Data.Profiles["_Template_Character_Split"] or {}

MonologueEngine.Data.Profiles["_Template_Character_Split"].GrowthStages = {
    Stage1_Early = { -- Levels 1-19: Idealistic novice
        SpellReactions = {
            Tier1_MajorCD = { "I hope this works!" },
        },
    },
    Stage2_Mid = { -- Levels 20-49: Battle-tested adventurer
        SpellReactions = {
            Tier1_MajorCD = { "Stand behind me!" },
        },
    },
    Stage3_Late = { -- Levels 50-60: Veteran hero
        SpellReactions = {
            Tier1_MajorCD = { "By my honor, you fall today!" },
        },
    },
}

MonologueEngine.Data.Profiles["_Template_Character_Split"].BossFeats = {
    RAGNAROS = { -- Unlocked after defeating Ragnaros in Molten Core
        PvPLines = {
            Nemesis = { "{opener} I have faced the Firelord himself, {target}! You cannot burn me {closer}" },
        },
    },
    ONYXIA = { -- Unlocked after defeating Onyxia
        PvPLines = {
            Dominance = { "I've slain dragons in their lair, {target}! You are nothing!" },
        },
    },
}
