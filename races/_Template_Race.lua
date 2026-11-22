--[[
    Monologue Data Module: Race Template
    PURE DATA TABLE. NO ENGINE LOGIC ALLOWED.

    Key: the exact raceFile returned by UnitRace("player"), e.g. "Dwarf", "NightElf",
    "Scourge", "Skyborne". Copy this file, rename it, and change the key below.
    Keys beginning with "_Template" are never matched to a player.

    Tokens usable in any line: {target} {zone} {lastzone} {rpname} {rank} {opener}
    ({opener} is a fighting oath from Dialect.oaths, written as its own sentence)

    Dialect rules (full format notes are at the top of Monologue_Translator.lua):
      wordSwaps     case-insensitive word replacement (Light intensity and up). A string is one
                    fixed swap; a list of strings gives variants, one picked at random with the
                    last 3 used avoided
      phraseSwaps   whole expressions ("thank you", "watch out"), applied before wordSwaps,
                    longest first; strings or variant lists
      phonetics     Lua patterns applied per lower-cased word (Standard intensity and up)
      contractions  like phraseSwaps, but each match is used only part of the time
      oaths         { Greet = {...}, Fight = {...}, Hurt = {...} }: short exclamations,
                    each its own sentence, said now and then before a greeting (Greet),
                    a kill line or battle cry (Fight) or a low-health line (Hurt)

    Canon guardrail: WoW Forever canon only (Classic Azeroth plus WoW Forever additions).
    No Outland, Northrend, Cataclysm, Pandaria, Shadowlands or Dragon Isles references.

    OPTIONAL: Presets and StanceGreetings (chosen in the My Voice tab)
      Presets = { Key = { name, blurb, dialectIntensity (-1..+1), oaths,
                          FriendGreetings = { Default = {...} }, BattleCry = {...} } }
        A preset replaces oaths/BattleCry, merges FriendGreetings, and shifts the
        translation intensity tier. Applied right after the race pack, before class/persona.
      StanceGreetings = {
          WARM = {...}, ADMIRING = {...}, PLAYFUL = {...},       -- general lines, any target race
          WARY = {...}, GRUFF = {...}, DISDAINFUL = {...},
          TargetRace = { WARM = {...}, GRUFF = {...} },           -- signature pairings (optional)
      }
        Used when the player sets a stance toward a race (My Voice tab). Lookup order:
        StanceGreetings[TargetRace][STANCE], then the engine's kin lines for your own race,
        then StanceGreetings[STANCE], then the engine's general lines. Tokens: {target},
        {targetrace}. A friend note pool (e.g. FriendGreetings.Duo) still takes priority.
        Stances only fire on friendly players, so pair with races of your own faction.

    OPTIONAL: EmoteReplies and RivalOpeners
      EmoteReplies = { Wave, Bow, Cheer, Toast, Hug, Rude, Challenge = { lines } }
        Said when a player emotes at you. {target} = who emoted. Missing kinds use the
        engine's general replies.
      RivalOpeners = { Vendetta, SwornFoe, Nemesis, Default = { lines } }
        Called out when you attack a known rival. {target}, {lastzone}.

    OPTIONAL: CombatOpeners (10-12 lines)
      CombatOpeners = { "For Khaz Modan.", "Stone remembers. So do I.", ... }
        Racial pull lines: homeland, kin, pride and culture, never a specific spell. When a
        signature move (Charge, Pyroblast, ...) says a pull line, about 1 in 4 comes from
        here instead of the spell's own pool. Read straight from the race pack, so a class
        pack's CombatOpeners never hide them. Filler moves still never speak.

    OPTIONAL: FriendGreetings.Ally (4-5 lines)
      FriendGreetings = { Default = {...}, Ally = {...} }
        Any FriendGreetings key matching a friend's note is used for that friend. The Roster's
        "Ally" quick-pick sets the note to Ally (comrades-in-arms lines); "Duo" uses
        FriendGreetings.Duo. With no matching pool the friend gets their race pool, then
        Default.

    Pool sizes (so lines don't repeat quickly): 8+ for pools that fire often
    (FriendGreetings.Default, GuildGreetings.Standard, DuelWin, DuelLoss); 4+ for each
    PvPLines tier, each EmoteReplies kind, each stance and each RivalOpeners tier.
--]]

MonologueEngine.Data.Races["_Template_Race"] = {
    Dialect = {
        wordSwaps = {
            ["hello"] = "greetings",
            ["friend"] = "companion",
            ["yes"] = "indeed",
        },
        phonetics = {
            ["ing%f[%A]"] = "in'",
        },
    },
    GuildGreetings = {
        Standard = {
            "Greetings, traveler.",
            "May your path be clear.",
        }
    },
    PvPLines = {
        FirstClash = { "A stranger in {zone}? State your business, {target}." },
        DejaVu = { "{zone} again... this ground has seen too many fights." },
        Rematch = { "You return for more?" },
        Vendetta = { "I haven't forgotten what happened back in {lastzone}, {target}!" },
        Dominance = { "Yield, you are outmatched!" },
        Nemesis = { "Our clash ends here today, {target}! I'll send you back to {lastzone}!" },
    },
    FriendGreetings = {
        Default = { "Good to see you, {target}." },
        Ally = { "{target}. Glad you're with me." },
    },
    CombatOpeners = {
        "For my homeland.",
        "My people taught me to stand my ground.",
    },
}
