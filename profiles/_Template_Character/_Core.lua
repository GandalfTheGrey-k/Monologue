--[[
    Monologue Data Module: Multi-File Character Profile (1/4) - Core
    PURE DATA TABLE. Dialect & basic character info.
    Load order in the .toc: _Core, _Combat, _PvP, _Growth (any order works; each file
    only extends the shared profile table).
--]]

MonologueEngine.Data.Profiles["_Template_Character_Split"] = MonologueEngine.Data.Profiles["_Template_Character_Split"] or {}

MonologueEngine.Data.Profiles["_Template_Character_Split"].Dialect = {
    wordSwaps = {
        ["gold"] = "shinies",
    },
}


MonologueEngine.Data.Profiles["_Template_Character_Split"].GuildGreetings = {
    Standard = {
        "{opener} Well met, {rank}.",
    },
}
