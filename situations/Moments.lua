--[[
    Monologue Data Module: Everyday Moments
    PURE DATA TABLE.

    Short lines for ordinary moments, said now and then (Voice Lines tab, "Everyday moments"):
      EatDrink  sitting down to eat or drink (out of combat)
      Mount     mounting up (outside instances)
      Rest      walking into an inn or a city (you start resting)
      AllyDown  a party member dies nearby: {target} is their name

    Shared by every race and class, so keep them faction- and class-neutral. A race, persona
    or character profile can replace any pool with
        Moments = { EatDrink = { ... } }
    Follow VOICE_GUIDE.md: specific, in-world, calm.
--]]

MonologueEngine.Data.MomentLines = {
    EatDrink = {
        "Hold on. Eating.",
        "Five minutes. My stomach's louder than the wolves.",
        "The bread's stale, but I've had worse.",
        "Can't fight on an empty stomach.",
        "A quick bite, then back to it.",
        "Nothing tastes better than food after a long fight.",
        "If anything shows up, it can wait till I'm done.",
        "Sit. Eat. Breathe.",
        "Not the finest meal in {zone}, but it'll do.",
        "Topping up before the next one.",
        "Someone pass the salt. No? Fine.",
    },
    Mount = {
        "Right. Let's move.",
        "Off we go.",
        "Steady now. Long road ahead.",
        "Saddle up.",
        "{zone} isn't getting any smaller.",
        "Faster than walking, at least.",
        "Easy, easy. Good mount.",
        "Time to cover some ground.",
        "Next stop, wherever the road ends.",
        "My feet thank you.",
    },
    Rest = {
        "Ah. Somewhere warm.",
        "A roof, a fire, a chair. That's all I ask.",
        "Finally, a place to sit.",
        "I could sleep for a week.",
        "Smells like stew. Good sign.",
        "Boots off. Just for a moment.",
        "Safe walls. I'll take them.",
        "Quiet in here. I like it.",
        "Time to rest these bones.",
        "Let's see who's about.",
    },
    AllyDown = {
        "{target}! No!",
        "{target}'s down!",
        "Get up, {target}. Get up!",
        "They got {target}! Watch yourselves!",
        "{target}! Someone get them up!",
        "No. Not {target}.",
        "{target} fell! Close ranks!",
        "Hold on, {target}. We'll get you back.",
        "{target}'s down. Make it count.",
        "Avenge {target}!",
    },
}
