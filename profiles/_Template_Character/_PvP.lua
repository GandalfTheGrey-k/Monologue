--[[
    Monologue Data Module: Multi-File Character Profile (3/4) - PvP
    PURE DATA TABLE. Rivalry & PvP speech pools.
    Tiers: FirstClash, DejaVu, Rematch, Vendetta, Dominance, Nemesis.
--]]

MonologueEngine.Data.Profiles["_Template_Character_Split"] = MonologueEngine.Data.Profiles["_Template_Character_Split"] or {}

MonologueEngine.Data.Profiles["_Template_Character_Split"].PvPLines = {
    FirstClash = { "{opener} I don't know you, {target}, but {zone} is no place to linger." },
    DejaVu = { "{zone} again. Blood keeps getting spilled here." },
    Rematch = { "Back for more, {target}?" },
    Vendetta = { "I haven't forgotten our duel in {lastzone}, {target}!" },
    Dominance = { "You've fallen to me before, {target}. Walk away." },
    Nemesis = { "{opener} You again? I'll make sure you stay down, {target}!" },
}
