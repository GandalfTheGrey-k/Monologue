--[[
    Monologue Data Module: Rogue Class
    PURE DATA TABLE.

    Lines suit any race of Rogue. Stealth-opening abilities (Vanish, Cheap Shot, Sap) are
    deliberately left out of SpellTriggers: the Voice Box stays silent while stealthed.
    SpellTriggers use Classic-era rank-specific IDs, verified in-game with /mono triggers.
    No Cloak of Shadows or other later-expansion abilities.
--]]

MonologueEngine.Data.Classes["ROGUE"] = {
    -- Class dialect: sits UNDERNEATH the race dialect, so a race (or persona or profile) that
    -- defines the same swap or list wins. The words and phrases here are Rogue-specific
    -- (stealth, theft, secrets) so they rarely collide with a race's own vocabulary.
    Dialect = {
        wordSwaps = {
            ["sneak"] = { "slip", "creep", "skulk" },
            ["steal"] = { "lift", "pilfer", "pocket" },
            ["secret"] = { "whisper", "quiet matter", "confidence" },
            ["silent"] = { "hushed", "soundless", "still as shadow" },
            ["dagger"] = { "blade", "knife", "shiv" },
            ["daggers"] = { "blades", "knives", "shivs" },
        },
        phraseSwaps = {
            ["don't tell anyone"] = { "this stays between us", "keep it quiet" },
            ["stay hidden"] = { "keep to the shadows", "stay out of sight" },
            ["keep it down"] = { "softly now", "quiet as a cat" },
            ["follow me quietly"] = { "stay in my shadow", "keep to my steps" },
            ["no one saw"] = { "nobody's the wiser", "not a soul noticed" },
            ["i'll scout ahead"] = { "I'll slip ahead", "let me take a look" },
            ["it's a trap"] = { "that smells of a trap", "something's rigged" },
        },
    },
    SpellReactions = {
        Tier1_MajorCD = {
            "Blades flashing, shadows burning!",
            "You'll never lay a hand on me!",
            "Too slow. Far too slow.",
            "Now you see how a real fight goes.",
            "Now you see me...",
            "Faster than you can blink!",
            "Time to get serious.",
            "Let's end this quickly.",
        },
        Tier2_Routine = {
            "Right between the ribs.",
            "Surprise.",
            "Lights out.",
            "Should've watched your back.",
            "Quick cut.",
            "Too slow.",
            "Oops. Did that hurt?",
            "Mind the knives.",
        },
        Tier3_LowHP = {
            "Time to slip away...",
            "That one nearly found something vital!",
            "I'll bleed you for it later.",
            "No honor in dying here.",
            "Time to vanish!",
            "This is getting dicey!",
            "Not my best idea.",
            "Exit, stage left!",
        }
    },
    SpellTriggers = {
        [5277] = "Tier1_MajorCD",   -- Evasion (rank 1)
        [26669] = "Tier1_MajorCD",  -- Evasion (rank 2)
        [13750] = "Tier1_MajorCD",  -- Adrenaline Rush
        [13877] = "Tier1_MajorCD",  -- Blade Flurry
        [14177] = "Tier1_MajorCD",  -- Cold Blood
        [14185] = "Tier1_MajorCD",  -- Preparation
        [1766] = "Tier2_Routine",   -- Kick (rank 1)
        [1767] = "Tier2_Routine",   -- Kick (rank 2)
        [1768] = "Tier2_Routine",   -- Kick (rank 3)
        [1769] = "Tier2_Routine",   -- Kick (rank 4)
        [1776] = "Tier2_Routine",   -- Gouge (rank 1)
        [1777] = "Tier2_Routine",   -- Gouge (rank 2)
        [8629] = "Tier2_Routine",   -- Gouge (rank 3)
        [11285] = "Tier2_Routine",  -- Gouge (rank 4)
        [11286] = "Tier2_Routine",  -- Gouge (rank 5)
        [2094] = "Tier2_Routine",   -- Blind
        [408] = "Tier2_Routine",    -- Kidney Shot (rank 1)
        [8643] = "Tier2_Routine",   -- Kidney Shot (rank 2)
        [14278] = "Tier2_Routine",  -- Ghostly Strike
    },
    SpellNames = {
        [5277] = "Evasion", [26669] = "Evasion", [13750] = "Adrenaline Rush",
        [13877] = "Blade Flurry", [14177] = "Cold Blood", [14185] = "Preparation",
        [1766] = "Kick", [1767] = "Kick", [1768] = "Kick", [1769] = "Kick",
        [1776] = "Gouge", [1777] = "Gouge", [8629] = "Gouge", [11285] = "Gouge", [11286] = "Gouge",
        [2094] = "Blind", [408] = "Kidney Shot", [8643] = "Kidney Shot",
        [14278] = "Ghostly Strike",
    },
    -- Pull lines (see Engine:ResolvePullPool): SpellLines[<spell name>] is used when you pull
    -- or open with that spell; CombatOpeners otherwise. Each pool is drawn as a shuffled deck,
    -- so every line comes up once before any repeats. Keys are English spell names.
    CombatOpeners = {
        "Surprise.",
        "Didn't hear me, did you?",
        "Shh. It's almost over.",
        "Your purse or your life? Both.",
        "Behind you.",
        "Nothing personal. Mostly.",
        "Quick and quiet.",
        "Should've watched the shadows.",
        "Let's make this fast.",
        "You look valuable.",
        "Hello there.",
        "This won't take long.",
        "I'm already gone. You just don't know it yet.",
        "Blades out, lights off.",
        "Every shadow has a knife in it.",
    },
    SpellLines = {
        ["Sinister Strike"] = {
            "Sinister!",
            "Quick cut!",
            "There's another!",
            "Snick!",
            "Slash and smile!",
            "Blade's hungry!",
            "Faster than you!",
            "Mind the edge!",
            "Too slow!",
            "Cut, cut, cut!",
            "Another one!",
            "Fancy footwork!",
        },
        ["Cheap Shot"] = {
            "Cheap? Effective.",
            "Sucker punch!",
            "Down you go!",
            "Dirty fighting wins fights!",
            "Stay down a moment.",
            "Honor is overrated.",
            "Seeing stars?",
            "That's how it's done in the alleys!",
            "Nighty-night!",
            "Low blow, high reward!",
            "Took you by surprise!",
            "Can't fight what you can't see!",
        },
        Backstab = {
            "Behind you!",
            "Surprise!",
            "Never turn your back.",
            "Right between the shoulders!",
            "Should've looked behind you.",
            "Hello from back here.",
            "Stab!",
            "Classic.",
            "Your back looked lonely.",
            "Got you good!",
            "Always watch your back.",
            "That's what you get!",
        },
        Eviscerate = {
            "Finish him!",
            "And... done.",
            "Eviscerated!",
            "That's the finale!",
            "Goodnight.",
            "Cut to pieces!",
            "The big one!",
            "Lights out!",
            "Wrapped up nicely.",
            "Final cut!",
            "That's all, folks.",
            "Bow out gracefully.",
        },
    },
    pvpStyle = "Opportunistic Assassin"
}
