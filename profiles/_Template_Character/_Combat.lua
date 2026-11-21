--[[
    Monologue Data Module: Multi-File Character Profile (2/4) - Combat
    PURE DATA TABLE. Spell & combat reactions.
--]]

MonologueEngine.Data.Profiles["_Template_Character_Split"] = MonologueEngine.Data.Profiles["_Template_Character_Split"] or {}

MonologueEngine.Data.Profiles["_Template_Character_Split"].SpellReactions = {
    Tier1_MajorCD = {
        "{opener} this ends now!",
    },
    Tier2_Routine = {
        "Again!",
    },
    Tier3_LowHP = {
        "Not like this... not in {zone}!",
    },
}
