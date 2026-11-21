--[[
    Monologue Data Module: Persona - Grizzled Veteran
    PURE DATA TABLE. Universal Growth Arc persona: works for any race and class.

    Voice: a weathered campaigner, steady, blunt and past being surprised. Fits the late
    levels (50-60) best, but can be assigned to any stage in /mono ui.

    Pools here replace the lower layers' pools of the same name; word swaps merge into the
    race's (chosen to avoid the race packs' own keys). The race accent still runs over
    these lines when they are spoken, and the race's suffix flourishes are kept.
--]]

MonologueEngine.Data.Personas["GrizzledVeteran"] = {
    displayName = "Grizzled Veteran",
    Dialect = {
        wordSwaps = {
            ["kid"] = "whelp",
            ["kids"] = "whelps",
            ["rookie"] = "greenhorn",
            ["young"] = "green",
            ["old"] = "seasoned",
        },
    },
    Fragments = {
        openers = {
            "Mark me,",
            "In all my years,",
            "Hear me out,",
        },
        closers = {
            "I've seen it before.",
            "And that's the truth of it.",
            "Mark my words.",
        },
    },
    GuildGreetings = {
        Standard = {
            "Well met. Good to see steady hands.",
            "Steel yourselves. We've work ahead.",
            "Stand tall. We've weathered worse.",
            "Morning, all. Keep your gear in order.",
            "Stay sharp out there.",
            "I've seen guilds come and go. This one's good.",
            "Watch each other's backs. That's the job.",
            "Another day. Let's make it count.",
        },
    },
    SpellReactions = {
        Tier1_MajorCD = {
            "I've done this a hundred times. Watch and learn.",
            "Stand behind me. I've got this.",
            "Old tricks are still the best ones.",
            "I've survived worse than you.",
            "Time to remind them who's been here longest.",
            "I've done this a thousand times.",
            "Watch and learn, young ones.",
            "Old dog, old tricks. Still work.",
        },
        Tier2_Routine = {
            "Steady now.",
            "Nothing I haven't seen.",
            "Experience beats youth, every time.",
            "Keep your guard up.",
            "Again, same as always.",
            "Seen it before.",
            "Routine.",
            "Old habits.",
            "Like clockwork.",
        },
        Tier3_LowHP = {
            "I've bled worse and kept walking.",
            "Not my first wound, won't be my last.",
            "Don't coddle me. Hold the line.",
            "Old bones, stubborn heart.",
            "Get the healer. I'll keep standing.",
            "Not my first scrape.",
            "Old scars, new ones. Same thing.",
            "Steady. Breathe. Fight.",
        },
    },
    PvPLines = {
        FirstClash = {
            "Seen your kind before, {target}. Make this quick.",
            "New in {zone}, {target}? Don't expect mercy.",
            "I've buried better than you, {target}.",
            "Turn back, {target}. I'm tired of graves.",
        },
        DejaVu = {
            "{zone} again. Same ground, same story.",
            "I know every stone of {zone} by now.",
            "{zone}. Always {zone}.",
            "I've fought in {zone} since before you were born.",
        },
        Rematch = {
            "We've met, {target}. I remember how it ended.",
            "Back again. Persistence is a virtue, but so is wisdom.",
            "Again, {target}. Some never learn.",
            "I remember you, {target}. You hesitate.",
        },
        Vendetta = {
            "I've fought many, {target}, but {lastzone} I remember.",
            "You bested me once in {lastzone}. Once.",
            "{lastzone}, {target}. I don't forget.",
            "The scar from {lastzone} still aches, {target}.",
        },
        Dominance = {
            "You've lost to me before, {target}. Learn from it.",
            "Go home, {target}. This old soldier isn't in the mood.",
            "Stay down, {target}. You've learned nothing.",
            "Go home, {target}. Live a while.",
        },
        Nemesis = {
            "{target}. Longest war I've fought, and we end it here.",
            "After everything, {target}, this one is personal.",
            "{target}. One of us retires today.",
            "Last war, {target}. Let's end it.",
        },
    },
}
