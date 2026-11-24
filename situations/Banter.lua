--[[
    Monologue Data Module: Party Banter
    PURE DATA TABLE.

    When a party member who also runs Monologue says one of their lines aloud, one other
    Monologue user nearby may answer them now and then (Voice Lines tab, "Party banter").
    {target} is the party member who just spoke.

      Kill      they just said something after a kill
      Idle      idle chatter
      EatDrink  they sat down to eat or drink
      Rest      they walked into an inn or a city
      Mount     they mounted up

    Shared by every race and class: keep them faction- and class-neutral.
    Follow VOICE_GUIDE.md: specific, in-world, calm.
--]]

MonologueEngine.Data.BanterLines = {
    Kill = {
        "Nicely done, {target}.",
        "Not bad, {target}. Not bad at all.",
        "I had it, {target}. But fine.",
        "Good work, {target}. Next one's mine.",
        "{target}, you missed a bit. Oh, no, it's dead.",
        "Show-off, {target}.",
        "I'll write that one down, {target}.",
        "That's one for you, {target}. I'm still ahead.",
    },
    Idle = {
        "You say that every time, {target}.",
        "Hm. Fair point, {target}.",
        "{target}, you think too much.",
        "Can't argue with that, {target}.",
        "I was just thinking the same, {target}.",
        "Tell me about it, {target}.",
        "Aye. Well said, {target}.",
        "If you say so, {target}.",
    },
    EatDrink = {
        "Save me some, {target}.",
        "That smells better than mine, {target}.",
        "Don't eat it all, {target}.",
        "{target}, you're always eating.",
        "Good idea, {target}. I'll join you.",
        "Pass it here when you're done, {target}.",
        "Eat up, {target}. Long road yet.",
        "Is that cheese, {target}? Share.",
    },
    Rest = {
        "First round's on you, {target}.",
        "Finally, {target}. My feet were done an hour ago.",
        "Grab us a table, {target}.",
        "I'll take the seat by the fire, {target}.",
        "Don't get comfortable, {target}. We leave at dawn.",
        "Ah, {target}. Somewhere with walls.",
        "Find the innkeeper, {target}. I'll find the stew.",
        "Rest well, {target}. You've earned it.",
    },
    Mount = {
        "Lead the way, {target}.",
        "Right behind you, {target}.",
        "Race you, {target}.",
        "Don't leave me in the dust, {target}.",
        "Slow down, {target}. Some of us have short legs.",
        "Where to, {target}?",
        "After you, {target}.",
        "Try to keep up, {target}.",
    },
}
