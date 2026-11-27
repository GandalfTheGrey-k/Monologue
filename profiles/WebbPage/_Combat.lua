--[[
    Monologue Data Module: Multi-File Character Profile - Webb Page (2/4) - Combat
    PURE DATA TABLE. Druid-flavored combat lines. Each pool is a plain list: add, remove or
    reword lines freely. These replace the Druid class pools of the same name, and the
    GrowthStages in _Growth.lua layer over them by level bracket.

    Lines stay within Classic Druid flavor (Bear Form, Cat Form, roots, Barkskin, Innervate,
    Rebirth). They avoid abilities that came later (no Mangle, Cyclone, Berserk, Tree of Life).
--]]

MonologueEngine.Data.Profiles["WebbPage"] = MonologueEngine.Data.Profiles["WebbPage"] or {}

-- Shouted on demand by /mono cry and the Battle Cry button. If this pool is removed the
-- button uses Tier1_MajorCD below instead.
MonologueEngine.Data.Profiles["WebbPage"].BattleCry = {
    "FUR AND THORNS!",
    "THE WILD ANSWERS!",
    "ROOTS UP, CLAWS OUT!",
    "NOBODY MESSES WITH THE GARDEN!",
    "BEAR NECESSITIES, COMING THROUGH!",
    "FOR NATURE! AND SNACKS!",
}

MonologueEngine.Data.Profiles["WebbPage"].SpellReactions = {
    -- Major cooldowns: Innervate, Barkskin, Rebirth, Tranquility, Nature's Swiftness, ...
    Tier1_MajorCD = {
        "Nature, lend me your strength!",
        "Bark up, fur out!",
        "Rise again, in the wild's name!",
        "Breathe easy, everyone. The wild's got us.",
        "Roots, thorns and a very bad mood!",
        "Quick as the wind, tough as the oak!",
        "The winds are with me, and so is the wild!",
        "The wild and the winds, together!",
    },

    -- Routine fighting: roots, shapeshifting, everyday spellwork
    Tier2_Routine = {
        "Stay put, little one.",
        "Shift and strike!",
        "The wild takes what it's owed.",
        "Hold still, I'm busy being scary.",
        "Roots, then claws. That's the order.",
        "Nature has patience. I do not.",
        "Wind at my back, roots at your feet.",
        "Thorns on the breeze!",
    },

    -- Low health (25% or less, once per scare, in combat)
    Tier3_LowHP = {
        "Ow! Okay, that's the bad kind of bite!",
        "I need to mend before I break!",
        "Somebody keep it off me for a second!",
        "Bears don't die. Bears get annoyed.",
        "Even oaks bend in a storm!",
        "I need a patch-up, and I need it now!",
        "Bark and feathers, hold!",
        "Tara, little help?",
    },
}

-- Pull lines for this character: these replace the class pack's CombatOpeners, and the
-- SpellLines entries replace the class lines for those spells only (other spells keep
-- the class pools). See Engine:ResolvePullPool in Monologue_Core.lua.
MonologueEngine.Data.Profiles["WebbPage"].CombatOpeners = {
    "The winds and the wild, both against you!",
    "Feathers ruffled? Good.",
    "From sky to root, you're surrounded.",
    "Zephras Isle never taught me to back down.",
    "The grove sent me. The sky came along.",
    "You picked a fight with the weather.",
    "Wings, claws and moonlight. Your choice.",
    "Easy now, this will only hurt a lot.",
    "The wild is my garden. You're weeds.",
    "Hold still, I'm gardening.",
    "Fair winds to me. Foul ones to you.",
    "Let's see how you handle a storm with fur.",
    "I don't scare easy.",
    "Nature called. I answered.",
    "Thorns out!",
}

MonologueEngine.Data.Profiles["WebbPage"].SpellLines = {
    ["Moonfire"] = {
        "Moonlight from Zephras Isle!",
        "Silver fire from the high skies!",
        "Elune and the winds agree!",
        "Look up! Moonfire!",
        "Moon's out, so is my temper!",
        "A little moonlight for you!",
        "The sky glows for you!",
        "Silver burn!",
        "From the moon, with sharp regards!",
        "Lit by moonlight, burned by it too!",
        "Night-sky fire!",
        "Glow, weed!",
    },
    ["Wrath"] = {
        "Garden's wrath!",
        "Feel the wild and the wind!",
        "Weeds get pulled!",
        "The grove is very cross with you!",
        "Green and furious!",
        "Thorns on the breeze!",
        "Nature's temper, sky-delivered!",
        "Wrath of the wild!",
        "Pruning time!",
        "The forest and the storm, together!",
        "The wild says no!",
        "Leave this one to me!",
    },
}
