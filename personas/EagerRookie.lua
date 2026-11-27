--[[
    Monologue Data Module: Persona - Eager Rookie
    PURE DATA TABLE. Universal Growth Arc persona: works for any race and class.

    Voice: an idealistic newcomer, brave, a little overexcited and still learning. Fits the
    early levels (1-19) best, but can be assigned to any stage in /mono ui.

    A persona sits above race and class: its SpellReactions and PvPLines pools replace the
    lower layers' pools of the same name, while its Dialect word swaps merge into the race's
    (they are chosen so they never collide with a race's own swaps). The race accent still
    runs over these lines when they are spoken. The race's oaths are
    kept.
--]]

MonologueEngine.Data.Personas["EagerRookie"] = {
    displayName = "Eager Rookie",
    Dialect = {
        wordSwaps = {
            ["okay"] = "absolutely",
            ["ok"] = "absolutely",
            ["maybe"] = "surely",
            ["later"] = "soon",
        },
    },
    GuildGreetings = {
        Standard = {
            "Hello, hello! Can I help with anything?",
            "It's an honor to serve with you all!",
            "Ready for whatever comes next!",
            "Hi everyone! Ready for adventure?",
            "I learned a new move! Want to see?",
            "Is anyone going questing? Can I come?",
            "Good morning, guild! Let's do great things!",
            "I'm so glad I found you all!",
        },
    },
    SpellReactions = {
        Tier1_MajorCD = {
            "I hope this works!",
            "Here goes everything!",
            "Watch this, everyone!",
            "I've been practicing this one!",
            "For glory, and maybe a good story!",
            "Did you see that?! I did it!",
            "This is the best day ever!",
            "Watch this one!",
        },
        Tier2_Routine = {
            "Take that!",
            "Got you!",
            "Was that good? That felt good!",
            "Again, again!",
            "I'm getting the hang of this!",
            "I'm getting good at this!",
            "Ha! Got you!",
            "Easy! Kind of!",
        },
        Tier3_LowHP = {
            "Ow! Ow! I'm okay! Mostly okay!",
            "That hurt more than the training dummy!",
            "A little help, please?",
            "I'm not scared. I'm... strategically concerned!",
            "Don't worry, I've got this! ...I think!",
            "Uh oh. Uh oh!",
            "Help! Anyone?",
            "This wasn't in the training!",
        },
    },
    PvPLines = {
        FirstClash = {
            "Oh! A real opponent in {zone}! Good luck, {target}!",
            "Nothing personal, {target}, but I'm going to try my best!",
            "Oh! An enemy! A real one!",
            "Okay, {target}, here goes nothing!",
            "Okay. A real fight, {target}. Deep breath.",
            "Hi, {target}. Sorry about this.",
        },
        DejaVu = {
            "{zone} again? I'm learning this place by heart!",
            "Another scrap in {zone}. I'm getting good at these!",
            "{zone} again? I'm starting to know my way!",
            "Wow, {zone} is busy today!",
            "{zone} again. I know where the good spots are now.",
            "Back in {zone}. I've got this.",
        },
        Rematch = {
            "You again, {target}! I've been practicing!",
            "Round two, {target}! I'm ready this time!",
            "You again, {target}? I've been practicing!",
            "Round two, {target}! I'm ready!",
            "Round two. I learned a new move, {target}.",
            "You again, {target}. I'm ready this time.",
        },
        Vendetta = {
            "You beat me in {lastzone}, {target}! I've trained since!",
            "I remember {lastzone}, {target}. I won't lose again!",
            "I still remember {lastzone}, {target}! Not this time!",
            "You got me in {lastzone}, {target}. Not again!",
            "I've been practicing since {lastzone}, {target}.",
            "{lastzone} was a lesson. Now watch.",
        },
        Dominance = {
            "I've beaten you before, {target}! Want to try for luck?",
            "I'd rather not hurt you again, {target}. Please go?",
            "I beat you before, {target}! I can do it again!",
            "Ha! Still got it, {target}!",
            "I won last time, {target}. I think I can again.",
            "Please don't make me hurt you again, {target}.",
        },
        Nemesis = {
            "{target}! It's you again! I'll end this once and for all!",
            "You've become my greatest rival, {target}. Let's make it count!",
            "{target}! This is my big moment!",
            "I've been training for you, {target}!",
            "This is it, {target}. Our big fight.",
            "I've trained every day for you, {target}.",
        },
    },
}
