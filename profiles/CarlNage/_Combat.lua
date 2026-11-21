--[[
    Monologue Data Module: Multi-File Character Profile - Carl Nage (2/4) - Combat
    PURE DATA TABLE. Spell & combat lines for Carl Nage, Dwarf Warrior.

    Only signature moves speak (see VOICE_GUIDE.md). Carl's SpellLines replace the Warrior
    class's Default pool for the same spell; when a persona is set on My Voice, that persona's
    lines (from classes/Warrior.lua) are used instead. Filler moves (Heroic Strike, Rend, ...)
    stay silent.
--]]

MonologueEngine.Data.Profiles["CarlNage"] = MonologueEngine.Data.Profiles["CarlNage"] or {}

-- Shouted on demand by /mono cry and the Battle Cry button. Battle cries may shout.
MonologueEngine.Data.Profiles["CarlNage"].BattleCry = {
    "FER IRONFORGE!",
    "BY MAGNI'S BEARD, TA ARMS!",
    "CLAN BATTLEHAMMER STANDS!",
    "COME GET SOME, YE BEARDLESS WHELPS!",
    "HAMMER DOWN! HAMMER DOWN!",
    "NO DWARF EVER BACKED OFF A SCRAP!",
}

MonologueEngine.Data.Profiles["CarlNage"].SpellReactions = {
    -- Battle Cry fallback only (Carl has his own BattleCry pool above)
    Tier1_MajorCD = {
        "On me, Battlehammers!",
        "Shields together.",
        "We don't move.",
        "Nobody leaves the line.",
        "For the clan, an' for the ale after.",
        "Dig in, lads.",
        "Make it a story worth tellin'.",
        "Ironforge is watchin'.",
    },
    -- Said when Carl's health drops low
    Tier3_LowHP = {
        "Me beard's singed. I'm fine.",
        "That one stung.",
        "Healer! Whenever ye like!",
        "Not dyin' somewhere this ugly.",
        "Bit o' blood. Seen worse.",
        "Hold. Breathe. Swing.",
        "Still here. Still angry.",
        "Somebody patch me up before I get cross.",
    },
}

-- Carl's own voice for his signature moves (replaces the Warrior Default pool for these)
MonologueEngine.Data.Profiles["CarlNage"].SpellLines = {
    ["Charge"] = {
        Default = {
            "Mind yer toes.",
            "Here's Carl.",
            "Hold still, I'm comin' to ye.",
            "Short legs. Long reach.",
            "Out o' the road!",
            "Ale's waitin'. Let's be quick.",
            "Head down. Beard first.",
            "Stay there. I'll come to you.",
            "Ye'll want to brace for this.",
            "Battlehammer comin' through.",
            "I've run uphill in Dun Morogh snow. This is nothin'.",
            "Oi!",
        },
    },
    ["Intercept"] = {
        Default = {
            "Where d'ye think ye're off to?",
            "Back here, you.",
            "I'm short, not slow.",
            "Ye'll not get far on those legs.",
            "Not done wi' ye yet.",
            "Sit down.",
            "Runnin's for pointies.",
            "Oi! I'm talkin' to ye.",
        },
    },
    ["Execute"] = {
        Default = {
            "That's yer lot.",
            "Stay down. Ale's gettin' warm.",
            "Another page for the book.",
            "Done. Who's buyin'?",
            "Good scrap. Over now.",
            "Down ye go.",
            "That'll be the end of it.",
            "Rest easy. Or don't. Not me problem.",
            "One for the clan.",
            "Ha. There.",
        },
    },
}

-- Carl's own world reactions (over the Dwarf and shared Situations pools)
MonologueEngine.Data.Profiles["CarlNage"].Situations = {
    Revenge = {
        "{killer}. Carl Nage doesn't forget a face. Or a snout.",
        "Ye got me once. That's all ye get.",
        "Back from the graveyard, an' it's yer turn.",
        "Thought ye'd seen the last o' me? Shame.",
        "Grudge settled in three, two...",
        "Same beast. Different dwarf. Angrier one.",
    },
    GrindStreak = {
        "{mob} number {count}. I'll have a rug made.",
        "That's {count} o' the {mob} lot down. The clan'll call it a cull.",
        "{mob} number {count}. Keep 'em comin'.",
        "Losin' count. Nae, wait. That's {mob} number {count}.",
        "{count} o' yer kin, {mob}. Ye'd think they'd learn.",
        "Another {mob} for the tally. That makes {count}.",
    },
}
