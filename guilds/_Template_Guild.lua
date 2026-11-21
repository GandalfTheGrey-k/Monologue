--[[
    Monologue Data Module: Rank-Aware Guild Pack Template
    PURE DATA TABLE.

    Key: any unique pack id. guildName is the in-game guild this pack belongs to; the engine
    loads the pack whose guildName matches GetGuildInfo("player") (case, spaces and
    punctuation ignored). Optional guildNames = { "Other Name" } lists alternative names.
    rankGreetings is indexed by the greeted guildmate's guild rank index (0 = Guild Leader)
    and may use {rank} (your own rank), {rpname}, {zone} and {target} (the guildmate).
    Greetings are spoken when you target a friendly guildmate; mottos are used for a share
    of them. Ranks without an entry fall back to GuildGreetings.Standard.
--]]

MonologueEngine.Data.Guilds["_Template_Guild"] = {
    guildName = "Order of the Shield",
    rankGreetings = {
        [0] = { "Hail, High Commander!" },       -- Guild Leader
        [1] = { "Salute, Officer!" },             -- Officer
        [2] = { "Hail, Veteran." },              -- Veteran
        [3] = { "Welcome, Brother in arms." },   -- Member
        [4] = { "Stand tall, Recruit." },         -- Initiate
    },
    mottos = {
        "Shields up, hearts firm!",
    }
}
