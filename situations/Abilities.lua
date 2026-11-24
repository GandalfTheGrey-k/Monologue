--[[
    Monologue Data Module: Ability Kinds
    PURE DATA TABLE.

    Shared lines for spells that have no lines of their own (Abilities tab, /mono map).
    Each spell you cast gets a kind, automatically or by your choice:
      Attack     a harmful spell: may open a fight (a pull line), like a signature move
      Burst      a big cooldown you chose: may also speak mid-fight
    Defend, Interrupt and Heal use the pools of the same name in situations/Moments.lua.

    Shared by every race and class, so keep them neutral. A class pack, race, persona or
    character profile can replace any pool with
        AbilityLines = { Attack = { ... } }
    Follow VOICE_GUIDE.md: specific, in-world, calm.
--]]

MonologueEngine.Data.AbilityLines = {
    Attack = {
        "Right. You first.",
        "Hold still.",
        "This won't take long.",
        "Easy does it.",
        "Mind yourself.",
        "One of us is leaving. Not me.",
        "Let's be quick about it.",
        "You picked a poor day for it.",
        "Steady.",
        "Stand your ground, then.",
        "I've got this one.",
        "Wrong road, friend.",
        "Keep your guard up. It won't help.",
        "Again? Fine.",
    },
    Burst = {
        "Everything I've got.",
        "No holding back now.",
        "Now. While it counts.",
        "All of it, right now.",
        "Saved this one for you.",
        "This ends here!",
        "Finish it.",
        "Full strength.",
        "Don't blink.",
        "Here's the rest of it.",
        "Watch closely.",
        "I was waiting for this.",
        "Give it everything!",
        "Last reserves. Make them count.",
    },
}
