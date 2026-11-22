--[[
    Monologue Data Module: Multi-File Character Profile - Webb Page (3/4) - PvP
    PURE DATA TABLE. Open-world rival lines and friendly duel banter.

    PvPLines are the rival lines (the engine reads the key "PvPLines"). Tiers: FirstClash,
    DejaVu, Rematch, Vendetta, Dominance, Nemesis. Tokens: {target} = the rival, {zone} =
    where you are, {lastzone} = where you last fought them, {opener} = a fighting
    oath.

    DuelWin / DuelLoss are spoken when a duel ends (/mono duels lists records). They are
    friendly tavern-brawl banter, kept apart from rivals.
--]]

MonologueEngine.Data.Profiles["WebbPage"] = MonologueEngine.Data.Profiles["WebbPage"] or {}

MonologueEngine.Data.Profiles["WebbPage"].DuelWin = {
    "Good duel, {target}! You nearly had me.",
    "Nature wins this round, {target}! Rematch soon?",
    "Well fought, {target}! No bears were harmed. Mostly.",
    "That's a win, {target}! Don't let it sting too much.",
    "Fur and thorns win again! Good fight!",
    "The wild wins, {target}!",
    "Good fight, {target}! You're no weed.",
    "Ha! Fur beats steel, {target}!",
}

MonologueEngine.Data.Profiles["WebbPage"].DuelLoss = {
    "You got me, {target}! Fair and square.",
    "Ow! Well fought, {target}. I'll be back, and furrier.",
    "Ha! Round to you, {target}. Rematch?",
    "Nicely done, {target}. Even nature loses sometimes.",
    "Good duel! I'll heal up and try again.",
    "You got me, {target}! Well done!",
    "My roots slipped, {target}!",
    "Well struck, {target}. Rematch?",
}

-- Called out by name as Webb closes in on a known rival (cast at them: Feral Charge,
-- Moonfire, Faerie Fire, or the first spell of the fight). {target} is the rival's full
-- name. Tier lookup: Vendetta, SwornFoe (repeat foes), Nemesis, then Default.
MonologueEngine.Data.Profiles["WebbPage"].RivalOpeners = {
    Vendetta = {
        "{target}! I owe you from {lastzone}. Roots remember!",
        "Not this time, {target}. The wild's on my side!",
        "{target}! The grove remembers {lastzone}!",
        "For {lastzone}, {target}! Claws out!",
    },
    SwornFoe = {
        "{target}, again? The wild never tires of you!",
        "Here we go again, {target}. Bear or cat, you choose!",
        "{target}! Back in my garden?",
        "You again, {target}? Weeds always return.",
    },
    Nemesis = {
        "{target}! The winds have brought you to me at last!",
        "I've waited for this, {target}. Fur and thorns!",
        "{target}! The storm and the wild both want you!",
        "No more, {target}! This ends!",
    },
    Default = {
        "{target}! Let's see what you've got!",
        "Coming for you, {target}!",
        "Here comes the wild, {target}!",
        "Thorns out, {target}!",
    },
}

MonologueEngine.Data.Profiles["WebbPage"].PvPLines = {
    FirstClash = {
        "Nothing personal, {target}, but the wild doesn't back down in {zone}.",
        "Stand clear, {target}. I'd rather not shift for this.",
        "You trampled my garden, {target}!",
        "The wild doesn't like you, {target}.",
    },
    DejaVu = {
        "{zone} again. The wild remembers every fight.",
        "Another scrap in {zone}. Fine by me.",
        "{zone} again? The roots here are angry.",
        "{zone}. Weeds keep coming back.",
    },
    Rematch = {
        "Back for more, {target}? The wild is patient.",
        "Same fight, {target}. Bigger claws this time.",
        "You again, {target}? Persistent weed.",
        "Round two, {target}!",
    },
    Vendetta = {
        "You owe me from {lastzone}, {target}.",
        "I haven't forgotten {lastzone}, {target}. Roots remember.",
        "{lastzone}, {target}! The grove remembers!",
        "You owe the wild for {lastzone}, {target}!",
    },
    Dominance = {
        "You've lost to me before, {target}. Walk away.",
        "Not again, {target}. I'd rather not shift for this one.",
        "Stay down, {target}. Become compost.",
        "Again, {target}? Sigh.",
    },
    Nemesis = {
        "{opener} {target}, we end this where it started: {lastzone}!",
        "{target}. Every thorn in my side leads back to you.",
        "{target}! The garden demands your end!",
        "No more weeds, {target}!",
    },
}
