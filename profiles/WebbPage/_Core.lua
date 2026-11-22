--[[
    Monologue Data Module: Multi-File Character Profile - Webb Page (1/4) - Core
    PURE DATA TABLE. Voice, friends and greetings for Webb Page, a Skyborne Druid.

    Race: Skyborne. The Skyborne race pack (races/Skyborne.lua) already supplies the "fair
    winds" accent and, depending on faction, the High Order or Windshapers flavor. This
    profile sits above it, so its word swaps avoid the race's own keys (hello, friend, yes,
    fly, high, ...). /mono status shows race=Skyborne and the active subtype.

    Matching: the engine matches this key to the logged-in character by exact name first,
    then ignoring case, spaces and hyphens, so "WebbPage" matches a character shown as
    "Webb Page" or "Webb-Page".

    Layering: race < class (DRUID) < Growth Arc persona < guild pack < this profile.
    Lists defined here (greetings, lines) REPLACE the lower layers' lists of
    the same name; word swaps MERGE into the race's, so only pick swap words the race pack
    doesn't already use. The race accent still runs over spoken lines.

    TWEAKING WEBB'S PERSONALITY: edit the three clearly marked blocks below
    (Dialect.wordSwaps, Dialect.phraseSwaps). Everything else in the
    profile (combat, PvP, growth) lives in the sibling files in this folder.
--]]

MonologueEngine.Data.Profiles["WebbPage"] = MonologueEngine.Data.Profiles["WebbPage"] or {}

-- ---------------------------------------------------------------------------------------
-- DIALECT: how Webb talks. Applies to chat Webb types (at Light intensity and up) and to
-- automatic lines. Keys are lower-case words or phrases; capitalisation is carried over.
-- ---------------------------------------------------------------------------------------
MonologueEngine.Data.Profiles["WebbPage"].Dialect = {
    -- Single words. A string is one fixed swap; a list gives random variants (the last 3
    -- used are avoided). Both can be mixed. Add or change pairs freely:
    --   ["word you type"] = "what Webb says",   or   ["word"] = { "variant one", "variant two" },
    wordSwaps = {
        ["mob"] = { "critter", "beastie", "little problem" },
        ["mobs"] = { "critters", "beasties", "little problems" },
        ["dungeon"] = "deep den",
    },
    -- Whole expressions, applied before the single words (longest first). Webb's win over the
    -- Skyborne race's and the Druid class's for the same phrase.
    phraseSwaps = {
        ["pull the mob"] = { "fetch the critter", "invite the critter over" },
    },
    -- Optional oaths. Left out on purpose so the Skyborne race's own oaths stay. To give
    -- Webb their own (it replaces the race's), uncomment:
    -- oaths = { Fight = { "Fur and thorns!", "By the winds!" }, Hurt = { "Easy now!" } },
}

-- ---------------------------------------------------------------------------------------
-- FRIEND GREETINGS: spoken when Webb targets a player marked with /mono friend.
-- Lookup order: a pool whose key matches the friend's NOTE (case, spaces and punctuation
-- ignored), then a pool for the friend's race (e.g. NightElf), then Default.
--   To use the Tara pool:  target Tara Page and type   /mono friend Tara Page
--   To use the Duo pool:   target a partner and type   /mono friend Duo
-- Add more pools the same way, e.g. a "Healer" key matches a note of "Healer".
-- {target} is the friend's name.
-- ---------------------------------------------------------------------------------------
MonologueEngine.Data.Profiles["WebbPage"].FriendGreetings = {
    -- Note "Tara Page" (any spacing or case)
    TaraPage = {
        "{target}! Right on time. I'll grab the bear, you grab the snacks!",
        "There's my favorite partner! Ready to get chased by half the zone again?",
        "{target}, you pull, I'll tank. Or I'll pull and you heal. Either way something's getting set on fire.",
        "Fur out, {target}! Last one in cat form buys the next round of potions!",
        "Heads up, {target}: I'm the bear, you're the squishy. Stand behind me. Seriously.",
        "{target}! Remember {zone}? We nearly died three times. Best day ever!",
        "Keep me alive, {target}, and I promise to only pull what we can eat. Deal?",
        "Roots on the left, you on the right, {target}. Between us nothing gets through!",
        "{target}, did you shapeshift mid-pull again? Show-off. Do it once more.",
        "Partners to the end, {target}. Now, who pulled that?",
    },

    -- Note "Duo"
    Duo = {
        "Partner in crime reporting for duty!",
        "Okay partner, the plan: look brave, pull everything.",
        "Two of us, zero fear, one very questionable plan!",
        "Back to back, partner. Like always.",
        "You and me against the whole zone, again!",
    },

    -- A marked friend who is also Skyborne (matched by race; a note pool above wins first)
    Skyborne = {
        "{target}! Fair winds, kindred! Even the sky feels smaller with you around.",
        "Another one from the high winds! Well met, {target}!",
        "{target}, you made it! The wind said you would. The wind is smug about it.",
    },

    -- Everyone else you have marked as a friend
    Default = {
        "{target}! Good to see a friendly face out here!",
        "Well met, {target}! Need a hand, or just a hug from a bear?",
        "{target}! The wild's better with you in it.",
        "Hey, {target}! Stay close, I've got your back.",
        "Ah, {target}! Between us we can handle anything.",
        "{target}, there you are! I was starting to talk to the trees.",
        "Safe journey, {target}, and watch the roots!",
        "{target}! The garden missed you!",
    },
}

-- ---------------------------------------------------------------------------------------
-- GUILD GREETINGS (placeholder): used for guildmates when no guild pack has a line for
-- their rank. Replace or extend freely. A full guild pack (rank-by-rank lines and mottos)
-- belongs in guilds/ and takes priority when your guild matches it.
-- ---------------------------------------------------------------------------------------
MonologueEngine.Data.Profiles["WebbPage"].GuildGreetings = {
    Standard = {
        "Well met, guildmate! The wild's glad you're here.",
        "Hey there! Need anything? I've got bark and fur to spare.",
        "Fair winds and green leaves, friends!",
        "Hello, garden! I mean, guild!",
        "Who needs a heal? Or a hug?",
        "The grove sends its love!",
        "Morning, everyone! Bear form is optional.",
        "Let's go make something grow!",
    },
}

-- ---------------------------------------------------------------------------------------
-- RACE GREETINGS (placeholder): spoken when Webb targets a friendly player of that race,
-- if no friend or guild greeting applies. Keys are race codes: Human, Dwarf, NightElf,
-- Gnome, Orc, Scourge, Tauren, Troll, Skyborne. Example to uncomment and edit:
--   NightElf = { "Kindred of the forest! Well met." },
-- ---------------------------------------------------------------------------------------
MonologueEngine.Data.Profiles["WebbPage"].RaceGreetings = {
    -- Webb's own people. Add more races by copying this block with another race code.
    Skyborne = {
        "Fair winds, kindred! Nice to meet someone else who looks down on mountains.",
        "A fellow Skyborne! Well met. Try not to scare the roots.",
        "The winds carried you right to me. Well met!",
        "Fair winds, {target}! A fellow child of the sky!",
        "{target}! Kindred of Zephras Isle!",
    },
}
