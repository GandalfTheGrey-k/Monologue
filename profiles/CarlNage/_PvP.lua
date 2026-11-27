--[[
    Monologue Data Module: Multi-File Character Profile - Carl Nage (3/4) - PvP
    PURE DATA TABLE. Rival call-outs, duel lines and PvP lines for Carl Nage.
    Tokens: {target} (the player), {zone}, {lastzone} (where you last fought them).
--]]

MonologueEngine.Data.Profiles["CarlNage"] = MonologueEngine.Data.Profiles["CarlNage"] or {}

-- Called out when Carl attacks a known rival with a gap-closer (Charge, Intercept) or a
-- signature move as his first attack
MonologueEngine.Data.Profiles["CarlNage"].RivalOpeners = {
    Vendetta = {
        "{target}. I've a page wi' yer name on it from {lastzone}.",
        "Remember {lastzone}? I've thought o' little else.",
        "Settlin' {lastzone} today, {target}.",
        "Ye owe me for {lastzone}. I'm collectin'.",
    },
    SwornFoe = {
        "You again. Grand.",
        "Back for more, {target}? Fine by me.",
        "I was hopin' I'd see ye.",
        "Third time, {target}. Mind the beard.",
    },
    Nemesis = {
        "{target}! Me whole book's about ye!",
        "No more, {target}. It ends here.",
        "Every grudge I've got, {target}. All of it.",
        "This is the last page, {target}.",
    },
    Default = {
        "Oi. You.",
        "Here I come again.",
        "Steady now, {target}.",
        "Ye'll do.",
    },
}

-- Spoken when a duel ends (tavern brawl, not a war)
MonologueEngine.Data.Profiles["CarlNage"].DuelWin = {
    "Good scrap, {target}. Ale's on me.",
    "Ha! Ye nearly had me there.",
    "Up ye get. No hard feelin's.",
    "That's a proper tavern brawl, that is.",
    "Ye've a fine arm, {target}. Mine's finer.",
    "Stone chin, see? Comes wi' the beard.",
    "Again sometime? I enjoyed that.",
    "Well fought. Now buy me a drink.",
}

MonologueEngine.Data.Profiles["CarlNage"].DuelLoss = {
    "Bah. Fair's fair, {target}.",
    "Ye got me. Next round's mine.",
    "Me pride's bruised. Me ale's still cold.",
    "Well struck. I'll be feelin' that tomorrow.",
    "Lucky swing. Mostly skill. Mostly.",
    "Rematch. Not now. After a drink.",
    "Don't tell the clan.",
    "Ye've earned that one, {target}.",
}

-- Spoken (in your chat, or on your next ability) during world PvP
MonologueEngine.Data.Profiles["CarlNage"].PvPLines = {
    FirstClash = {
        "Ye're a long way from home, {target}.",
        "Turn round and I'll pretend I didn't see ye.",
        "Wrong road, {target}.",
        "Easy now. Or don't. Yer choice.",
    },
    DejaVu = {
        "{zone} again. I should start chargin' rent.",
        "Every time I'm in {zone}, there's one o' yous.",
        "Same dirt, same {zone}, same scrap.",
        "I know every rock in {zone} by now.",
    },
    Rematch = {
        "You again? Grand.",
        "Back for seconds, {target}?",
        "I remember yer face. Unfortunately.",
        "Didn't learn last time, did ye?",
    },
    Vendetta = {
        "{lastzone}. I've not forgotten.",
        "Ye got lucky in {lastzone}, {target}.",
        "This one's for {lastzone}.",
        "I owe ye one from {lastzone}.",
    },
    Dominance = {
        "Stay down this time, {target}.",
        "We've done this before. Ye lost.",
        "Same endin' as last time, lad.",
        "Ye could just lie down. Save us both the bother.",
    },
    Nemesis = {
        "Ye're the whole reason I keep a book, {target}.",
        "Every page, {target}. Every one o' them.",
        "One of us goes home tonight.",
        "I've been waitin' for this since {lastzone}.",
    },
}
