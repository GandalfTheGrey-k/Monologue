--[[
    Monologue Data Module: Crew Cross-Talk Template
    PURE DATA TABLE.

    Key: any unique pack id. crossTalk[speakerRole][listenerRole] holds the line a
    character in the first role says to a groupmate in the second (Tank, Healer, DPS).
    nemesisBackup lines are for a group fighting alongside a character's rival.
    Lines may use {target}, {zone} and {lastzone}.
--]]

MonologueEngine.Data.Groups["_Template_Group"] = {
    groupID = "StandardCrew",
    crossTalk = {
        Tank = {
            Healer = "Keep me standing, friend!",
            DPS = "Focus my mark!",
        },
        Healer = {
            Tank = "Don't jump in out of line-of-sight!",
        }
    },
    nemesisBackup = {
        "Hold on! I've got your back against that rival!",
    }
}
