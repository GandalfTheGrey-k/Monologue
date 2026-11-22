--[[
    Monologue Data Module: Multi-File Character Profile - Carl Nage (1/4) - Core
    PURE DATA TABLE. Dialect & basic character info for Carl Nage, Dwarf Warrior.

    Matching: the engine matches this key to the logged-in character by exact name first,
    then ignoring case, spaces and hyphens, so "CarlNage" matches a character shown as
    "Carl Nage", "Carl-Nage" or "Carl" on a realm named "Nage".

    Layering: race (Dwarf) < class (WARRIOR) < Growth Arc persona < this profile. Sequence
    pools defined here (greetings, lines) replace the lower layers' pools.
    The Dwarf accent still runs over spoken lines (-ing -> -in', you -> ye, my -> me,
    to -> tae), so lines may be written in plain English or already in dialect.
--]]

MonologueEngine.Data.Profiles["CarlNage"] = MonologueEngine.Data.Profiles["CarlNage"] or {}

MonologueEngine.Data.Profiles["CarlNage"].Dialect = {
    -- Single strings (one fixed swap) and lists (random variants) can be mixed freely here
    wordSwaps = {
        ["gold"] = "coin",
        ["battle"] = "scrap",
        ["warrior"] = { "soldier", "fighter" },
        -- Grudging elf acceptance. Phrases are matched before single words, so
        -- "night elf" becomes "tree-pointy" rather than "night pointy".
        ["elf"] = "pointy",
        ["elves"] = "pointies",
        ["night elf"] = "tree-pointy",
        ["night elves"] = "tree-pointies",
    },
    -- Carl's own idioms; these win over the Dwarf race's for the same phrase
    phraseSwaps = {
        ["watch out"] = { "mind yer head, lad", "duck, ye fool", "look sharp" },
    },
}


-- Spoken when Carl targets a friendly player of that race (keys are the target's raceFile,
-- e.g. "NightElf") and no guild-rank greeting applies. A grumble, but an honest one.
MonologueEngine.Data.Profiles["CarlNage"].RaceGreetings = {
    NightElf = {
        "Pointies. Tall ears an' a tree fer a house. Still, they hold their end o' the line.",
        "Evenin', tree-hugger. Don't tell anyone, but yer lot holds yer end o' the Alliance line.",
        "Them ears are taller than me hammer, but I'll grant it: pointies don't run from a scrap.",
        "Aye, aye, ye talk ta trees. Hold yer end o' the line an' we'll get along fine.",
        "Bah, tall ears an' moonlight. Good fighters, though. Don't let it go ta yer head.",
        "I'd sooner share a mountain wit' a trogg than a forest wit' a pointy. ...Ye stand yer ground, though. I'll give ye that.",
        "Don't look at me like that, pointy. I said ye hold the line. Never said I liked the ears.",
        "Tree-hugger! Ha! Ye hold yer end o' the Alliance, an' that's good enough fer a dwarf.",
    },
}

-- Spoken when Carl targets a player he has marked with /mono friend (or the portrait
-- menu). Lookup order: a pool whose key matches the friend's note (e.g. a note of
-- "drinking buddy" would use a "DrinkingBuddy" key), then the friend's race (NightElf
-- below), then Default. {target} is the friend's name.
MonologueEngine.Data.Profiles["CarlNage"].FriendGreetings = {
    Default = {
        "{target}. Me shield-brother. Pull up a stool.",
        "There ye are, {target}. Ye still owe me an ale.",
        "Good to see a friendly face out here.",
        "Ah, {target}. The one I'd want at me back.",
        "Ho, {target}. Tankards later, aye?",
        "Clan Battlehammer's table has a seat for ye, {target}.",
        "Look what the trogg dragged in.",
        "Safe road, {target}. Keep yer hammer oiled.",
    },
    NightElf = {
        "{target}! One o' the good pointies! Sit down, have a drink... aye, I know ye don't, sit anyway!",
        "If all pointies were like {target}, I'd stop complainin'. Almost.",
        "Well met, {target}. Yer ears are still too tall, but yer heart's in the right place.",
        "Don't tell the lads, {target}, but ye're one o' the good pointies.",
    },
}

MonologueEngine.Data.Profiles["CarlNage"].GuildGreetings = {
    Standard = {
        "Mornin', ye hairy lot.",
        "Clan's all here, I see.",
        "Who's buyin' the first round?",
        "Keep yer feet on the ground, lads.",
        "Long live the clan.",
        "Axes sharp? Good.",
        "Anyone seen me other boot?",
        "Ha. Me favourite lot.",
    },
}
