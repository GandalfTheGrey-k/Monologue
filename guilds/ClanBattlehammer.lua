--[[
    Monologue Data Module: Guild Pack - Clan Battlehammer
    PURE DATA TABLE. An all-Dwarf guild; lines are written in a Dwarf's voice and the Dwarf
    accent still runs over them when spoken.

    Matching: the engine loads this pack when GetGuildInfo("player") reports a guild named
    "Clan Battlehammer" (case, spaces and punctuation are ignored). It is merged above the
    Growth Arc persona and below the character profile into ActiveProfile.Guild.

    Greetings: when you target a friendly guildmate, the engine greets them from
    rankGreetings, indexed by THEIR guild rank index (0 = Guild Leader), or occasionally
    from mottos. Ranks without an entry fall back to the active GuildGreetings.Standard.
    Lines may use {target} (the guildmate), {rank} (your own rank) and {zone}.
--]]

MonologueEngine.Data.Guilds["ClanBattlehammer"] = {
    guildName = "Clan Battlehammer",
    rankGreetings = {
        [0] = { -- Guild Leader
            "Hail, Clan Chief! Just point me at trouble!",
            "Chief on the field! Battlehammer stands taller fer it!",
        },
        [1] = { -- Officer
            "Salute, Captain! The clan's in good hands.",
            "Officer on deck! Keep the lads in line!",
        },
        [2] = { -- Veteran
            "Hail, Hammerguard! Still swingin', eh?",
            "Well met, veteran. Ye've earned yer seat at the table.",
        },
        [3] = { -- Member
            "Well met, clanmate! Hammer up!",
            "Aye, clanmate! Good ta see ye!",
        },
        [4] = { -- Initiate
            "Stand tall, lad! Ye'll make a fine hammer yet!",
            "Fresh from the forge, are ye? Welcome ta the clan!",
        },
    },
    mottos = {
        "Hammer down, hearts firm!",
        "Battlehammer stands!",
        "Strike true, stand tall!",
    },
}
