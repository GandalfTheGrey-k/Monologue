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
    -- Tier1_MajorCD: the Battle Cry fallback (when a character has no BattleCry pool).
    -- Tier3_LowHP: said when your health drops low.
    SpellReactions = {
        Tier1_MajorCD = {
            "Now. All in.",
            "No more hiding.",
            "Fast and quiet. Go.",
            "Every blade I've got.",
            "Shadows, with me.",
            "In, out, gone.",
            "They'll never see the rest.",
            "Quick hands!",
        },
        Tier3_LowHP = {
            "Need to vanish. Soon.",
            "This is why I stay behind them.",
            "Bleeding. Don't tell anyone.",
            "Too much face time.",
            "Get me out of here.",
            "Cut deep. Mine, for once.",
            "This is why I don't do fair fights.",
            "Leather's no plate.",
            "Keep it busy. I need a moment.",
            "Where's a shadow when you need one?",
        },
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
    CombatOpeners = {
        "Over your shoulder.",
        "You didn't hear a thing.",
        "Keep looking forward.",
        "Poison's fresh.",
        "The shadows were kind tonight.",
        "Hush now.",
        "Don't turn around.",
        "I've been here a while.",
        "Quiet steps, sharp knives.",
        "Nice purse. Mine later.",
        "Blades out.",
        "You're easier to sneak up on than a guard.",
        "Nobody saw me come in.",
        "Mind your back. Too late.",
        "Hello, mark.",
    },
    -- Signature moves: a spell's own lines. Pull lines when you open a fight with it;
    -- big = true lets a cooldown speak mid-fight, midChance lets crowd control, interrupts
    -- and heals speak mid-fight now and then. .Player lines are for enemy players.
    SpellLines = {
        ["Eviscerate"] = {
            midChance = 0.3,
            "Pay up.",
            "That settles it.",
            "Account closed.",
            "All of it, at once.",
            "Every cut adds up.",
            "Collecting now.",
            "Open it all up.",
            "There. Done.",
            "You were bleeding anyway.",
            "Final cut.",
            "I always collect.",
            "Paid in full!",
            Player = {
                "Settled, {target}.",
                "Every cut was counting, {target}.",
                "Collecting on you, {target}.",
                "You never saw it adding up.",
                "That's the end of it, {target}.",
                "I keep a tab, {target}.",
            },
        },
        ["Cheap Shot"] = {
            "Hi.",
            "Couldn't resist.",
            "Fair's not my thing.",
            "Off your feet.",
            "Surprise.",
            "Don't get up.",
            "Bit of a low blow. Sorry.",
            "Hello from behind.",
            "Stunned? It happens.",
            "Rude, I know.",
            "You'll feel that in the morning.",
            "Gotcha!",
            Player = {
                "Evening, {target}.",
                "Didn't hear me, {target}?",
                "Low blow. Worth it.",
                "Stay put a moment, {target}.",
                "Sorry, not sorry, {target}.",
                "Down on the ground, {target}.",
            },
        },
        ["Sinister Strike"] = {
            "Quick cut.",
            "Again.",
            "Another.",
            "Fast hands.",
            "Keep up.",
            "Sharp.",
            "In and out.",
            "Sting.",
            "Nicked.",
            "Blink and you'll miss it.",
            "There's more where that came from.",
            "Steel's quicker than you!",
        },
        ["Backstab"] = {
            "Right between the shoulders.",
            "Wrong way to face.",
            "From behind. Always.",
            "Should've turned around.",
            "That's the soft spot.",
            "Your back's my favorite side.",
            "Didn't see me there.",
            "A knife in the back. Classic.",
            "Behind you the whole time.",
            "Mind the kidneys.",
            "Just under the ribs.",
            "Surprise from behind!",
        },
        ["Ambush"] = {
            "Here's the knife.",
            "Out of the dark.",
            "You walked right past me.",
            "Waiting just for you.",
            "From the shadows.",
            "Deep cut.",
            "That's what patience buys.",
            "I've been here all along.",
        },
        ["Sap"] = {
            "Sleep.",
            "Night night.",
            "Quiet. Lie down.",
            "Shh. Rest.",
            "You won't remember this.",
            "Nap time.",
            "Dream sweet.",
            "Sleep it off.",
        },
        ["Kick"] = {
            midChance = 0.3,
            "Put that spell away.",
            "No spells.",
            "Stop talking.",
            "Keep your words.",
            "Not that one.",
            "Quiet, you.",
            "Nope.",
            "Mid-sentence, sorry.",
        },
        ["Gouge"] = {
            midChance = 0.3,
            "Eyes up. Oops.",
            "Can't see? Shame.",
            "In the eye.",
            "Blink it off.",
            "Rub your eyes later.",
            "Stay dizzy.",
            "Dirty trick. Works.",
            "Look away now.",
        },
        ["Blind"] = {
            midChance = 0.3,
            "Powder in the eyes.",
            "Can't see me now.",
            "Wander off.",
            "Blinded. Stumble around.",
            "Where'd I go?",
            "Sneezing yet?",
            "Out of sight.",
            "Lost, are we?",
        },
        ["Kidney Shot"] = {
            midChance = 0.3,
            "Right in the kidney.",
            "Stay folded.",
            "That one lingers.",
            "Doubled over. Good.",
            "Low and hard.",
            "Feel that in your back.",
            "Can't stand? Don't.",
            "Hold still while I work.",
        },
        ["Vanish"] = {
            big = true,
            "Gone.",
            "Wasn't here.",
            "Poof.",
            "See you never.",
            "Smoke and nothing.",
            "Later.",
            "Look for me. Go on.",
            "Not here anymore.",
        },
        ["Evasion"] = {
            big = true,
            "Swing all you like.",
            "Miss. Miss again.",
            "Too quick for you.",
            "Keep swinging.",
            "Nimble.",
            "Dodging's free.",
            "Not even close.",
            "Try harder.",
        },
    },
    pvpStyle = "Opportunistic Assassin"
}
