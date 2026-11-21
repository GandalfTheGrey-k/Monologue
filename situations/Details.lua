--[[
    Monologue Data Module: Detail lines (live game details swapped into the line)
    PURE DATA TABLE. Mixed into pull, kill, low-health and idle lines by the variety mixer
    (the "detail" layer). A line is only used when every detail token in it can be filled
    right now: no {weapon} lines while unarmed, no {party} lines while solo.

    Detail tokens (see Engine.DetailTokens in Monologue_Core.lua; /mono tokens shows them):
      {mobtype} {amobtype}  "undead" / "an undead" (humanoids don't count)
      {family}              beast family: "spider", "wolf"
      {targetclass}         an enemy player's class: "rogue"
      {levelgap}            "far above my level", "a few levels above me", "well below my level"
      {weapon} {offhand}    your main-hand / off-hand item name
      {spell}               the signature move being used: "Charge"
      {resource}            "mana", "rage" or "energy"
      {myhp}                "barely standing", "bleeding", "a bit scratched" (only when hurt)
      {party}               a party member's name (only when grouped)
      {groupsize}           "the three of us", "all twelve of us"
    Plus the usual {target} and {mob}. Follow VOICE_GUIDE.md: specific, mostly calm.
--]]

MonologueEngine.Data.DetailLines = {
    Combat = {
        "Meet {weapon}.",
        "{weapon} hasn't failed me yet.",
        "{spell} first. Questions never.",
        "Here comes the {spell}.",
        "Another {mobtype}. They never learn.",
        "Something about {amobtype} sets my teeth on edge.",
        "That's a big {family}. Fine.",
        "Of course it's a {targetclass}.",
        "You're {levelgap}. Doesn't matter.",
        "{weapon} and {offhand}. That's all I need.",
        "{party}, watch my back.",
        "Stay close, {party}. This one's mine.",
        "There's {groupsize}. You've got no chance.",
        "Low on {resource}. Still enough for you.",
    },
    Kill = {
        "{weapon} did its job.",
        "That {spell} did the talking.",
        "One less {mobtype}.",
        "Nice work, {party}.",
        "Clean {weapon}. Mostly.",
        "{groupsize} and not a scratch. Well, almost.",
        "That {family} won't bother anyone now.",
        "{offhand} took a dent for that one.",
    },
    LowHP = {
        "I'm {myhp} here.",
        "{party}, I need help. Now.",
        "{myhp}, and still swinging {weapon}.",
        "Out of {resource}, nearly out of blood.",
        "Hold on. I'm {myhp}.",
        "That {mobtype} hits harder than it looks.",
        "Keep that {targetclass} off me.",
        "{offhand} up. Breathe.",
    },
    Idle = {
        "Need to sharpen {weapon}.",
        "{weapon} could use a polish.",
        "{offhand}'s seen better days.",
        "Good to have you along, {party}.",
        "Where to next, {party}?",
        "{groupsize}. Good company.",
        "Plenty of {resource} left. Let's find a fight.",
        "{weapon}, a full belly, and a road. Good day.",
    },
}

-- A few detail lines for the broad situation pools (situations/Situations.lua)
local S = MonologueEngine.Data.Situations
local function Add(key, lines)
    if type(S[key]) ~= "table" then return end
    for _, line in ipairs(lines) do S[key][#S[key] + 1] = line end
end
Add("Beast", { "Easy, {family}. Nothing personal.", "Nice coat on that {family}." })
Add("Undead", { "{weapon} has buried your kind before.", "Back to the grave, {mob}." })
Add("Rare", { "{mob}. I've heard the stories.", "{weapon} wants a trophy." })
Add("Elite", { "Big one. {party}, stay sharp.", "Tough one. Good thing I brought {weapon}." })
Add("Outlevelled", { "You're {levelgap}. I've had worse odds.", "{levelgap}, and I'm still here." })
Add("Hurt", { "I'm {myhp}. Make this quick.", "{myhp}. Doesn't matter." })
Add("LowMana", { "Barely any {resource} left.", "Running dry on {resource}." })
