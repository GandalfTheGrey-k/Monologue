--[[
    Monologue Data Module: Swappable Persona Override Template
    PURE DATA TABLE.

    Personas sit above race and class and below the character profile. Players pick one
    per growth stage (levels 1-19 / 20-49 / 50-60) in /mono ui. Any race/class/profile
    key may be overridden here: Dialect, SpellReactions, PvPLines, GuildGreetings.

    displayName is optional and is the label shown in the config panel.
    Keys beginning with "_Template" are hidden from the panel.
--]]

MonologueEngine.Data.Personas["_Template_Persona"] = {
    displayName = "Template Persona",
    Dialect = {
        wordSwaps = {
            ["yes"] = "affirmative",
            ["no"] = "negative",
        }
    },
    SpellReactions = {
        Tier1_MajorCD = {
            "Executing primary combat protocol!",
        }
    },
    PvPLines = {
        FirstClash = { "Target acquired in {zone}." },
    }
}
