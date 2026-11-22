--[[
    Monologue Data Module: Character-Specific Override Template
    PURE DATA TABLE. Top tier priority in the 4-layer fallback merger.

    Key: the character's name exactly as in game ("Thrain"), or "Name-Realm" to bind a
    profile to one realm. Keys beginning with "_Template" are never matched.

    SINGLE-FILE SCHEMA (this file):
      Dialect          wordSwaps / phonetics / oaths layered over race and persona
      GuildGreetings   greeting pools (Standard, plus optional rank-specific pools)
      FriendGreetings  greetings for players marked with /mono friend: Default, plus optional
                       raceFile pools (e.g. NightElf) and pools keyed by a friend's note;
                       lookup is note, then race, then Default. {target} = the friend
      RaceGreetings    greeting pools keyed by the target's raceFile, e.g. { NightElf = { ... } };
                       spoken when targeting a friendly player of that race
      BattleCry        lines for /mono cry and the Battle Cry button (falls back to the
                       class's Tier1_MajorCD pool)
      RivalOpeners     call-outs when you cast at an enemy player already in your rival
                       ledger (Vendetta, SwornFoe, Nemesis, Default; falls back to
                       PvPLines[tier]). Spoken with SAY/YELL because the cast is a player
                       action; {target} is the rival's full name
      DuelWin /        optional pools spoken when a duel ends; {target} is the opponent when
      DuelLoss         targeted. Duels are tracked apart from rivals (/mono duels)
      PvPLines         FirstClash, DejaVu, Rematch, Vendetta, Dominance, Nemesis
      SpellReactions   Tier1_MajorCD, Tier2_Routine, Tier3_LowHP
      GrowthStages     Stage1_Early (1-19), Stage2_Mid (20-49), Stage3_Late (50-60)
      BossFeats        merged in once the matching boss has been defeated

    MULTIFILE SUB-FOLDER STRUCTURE (OPTIONAL):
    For complex characters, profiles can be split across profiles/CharacterName/ sub-files:
      profiles/CharacterName/_Core.lua   -- Dialect & basic character info
      profiles/CharacterName/_Combat.lua -- Spell & combat reactions
      profiles/CharacterName/_PvP.lua    -- Rivalry & PvP speech pools
      profiles/CharacterName/_Growth.lua -- GrowthArc & BossFeats progression
    Use: MonologueEngine.Data.Profiles["CharacterName"] = MonologueEngine.Data.Profiles["CharacterName"] or {}
    in each sub-file to extend the profile table safely across multiple files.
    A working example lives in profiles/_Template_Character/ (key "_Template_Character_Split").
    List every sub-file in the .toc; use one style or the other per character, not both.

    BossFeats keys must be WoW Forever raid bosses (e.g. RAGNAROS, ONYXIA); see
    MonologueEngine.BossRegistry. Canon guardrail: Classic Azeroth plus WoW Forever
    additions only, with no later-expansion lore and no spells that do not exist.
--]]

MonologueEngine.Data.Profiles["_Template_Character"] = MonologueEngine.Data.Profiles["_Template_Character"] or {
    -- DIALECT. Every key is optional. Layering: class dialect < race dialect < persona < this
    -- profile. Swap tables merge key by key; lists (oaths, ...) replace the lower
    -- layer's list. Full format notes are at the top of Monologue_Translator.lua.
    Dialect = {
        wordSwaps = {
            ["gold"] = "shinies",                          -- one fixed swap
            ["friend"] = { "kin", "fellow traveler", "ally" },  -- variants: one at random, the last 3 avoided
        },
        phraseSwaps = {                                     -- whole expressions, applied first, longest first
            ["thank you"] = { "much obliged", "my thanks" },
            ["watch out"] = "mind yourself",
        },
        contractions = { ["do not"] = "don't" },            -- used only part of the time (cadence)
        oaths = { Fight = { "By my honor!" }, Hurt = { "Not yet!" } },  -- replaces the race's
        -- Older single-string swaps keep working.
    },
    GuildGreetings = {
        Standard = {
            "{opener} Well met, {rank}.",
        },
    },
    FriendGreetings = {
        Default = {
            "{opener} Well met, {target}!",
            "{target}! A welcome sight, as always.",
        },
    },
    DuelWin = {
        "Well fought, {target}! A fine duel.",
    },
    DuelLoss = {
        "You have bested me, {target}. Well fought!",
    },
    RivalOpeners = {
        Vendetta = {
            "{target}! I owe you from {lastzone}!",
            "Not this time, {target}!",
        },
        SwornFoe = { -- repeat opponents (Rematch / Dominance tiers)
            "{target}, again? Let's finish this!",
            "Here we go again, {target}!",
        },
        Nemesis = {
            "{target}! This ends today!",
            "I've waited for this, {target}!",
        },
        Default = {
            "{target}! Let's see what you've got!",
            "Coming for you, {target}!",
        },
    },
    GrowthStages = {
        Stage1_Early = { -- Levels 1-19: Idealistic novice
            SpellReactions = {
                Tier1_MajorCD = { "I hope this works!" },
            },
        },
        Stage2_Mid = { -- Levels 20-49: Battle-tested adventurer
            SpellReactions = {
                Tier1_MajorCD = { "Stand behind me!" },
            },
        },
        Stage3_Late = { -- Levels 50-60: Veteran hero
            SpellReactions = {
                Tier1_MajorCD = { "By my honor, you fall today!" },
            },
        },
    },
    BossFeats = {
        RAGNAROS = { -- Unlocked after defeating Ragnaros in Molten Core
            PvPLines = {
                Nemesis = { "{opener} I have faced the Firelord himself, {target}! You cannot burn me!" },
            },
        },
        ONYXIA = { -- Unlocked after defeating Onyxia
            PvPLines = {
                Dominance = { "I've slain dragons in their lair, {target}! You are nothing!" },
            },
        },
    },
    PvPLines = {
        FirstClash = { "{opener} I don't know you, {target}, but {zone} is no place to linger." },
        DejaVu = { "{zone} again. Blood keeps getting spilled here." },
        Rematch = { "Back for more, {target}?" },
        Nemesis = { "{opener} You again? I'll make sure you stay down, {target}!" },
        Vendetta = { "I haven't forgotten our duel in {lastzone}, {target}!" },
        Dominance = { "You've fallen to me before, {target}. Walk away." },
    }
}
