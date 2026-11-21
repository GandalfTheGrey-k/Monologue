--[[
    Monologue Data Module: Persona - Zealous Crusader
    PURE DATA TABLE. Universal Growth Arc persona: works for any race and class.

    Voice: a driven believer with a sworn cause, earnest, fervent and unbending. It speaks
    of the Light, oaths and justice in general terms, so it suits any class and any stage
    and can be assigned in /mono ui.

    Pools here replace the lower layers' pools of the same name; word swaps merge into the
    race's (chosen to avoid the race packs' own keys). The race accent still runs over
    these lines when they are spoken, and the race's suffix flourishes are kept.
--]]

MonologueEngine.Data.Personas["ZealousCrusader"] = {
    displayName = "Zealous Crusader",
    Dialect = {
        wordSwaps = {
            ["justice"] = "holy justice",
            ["duty"] = "sacred duty",
            ["evil"] = "wicked",
            ["honor"] = "sacred honor",
        },
    },
    Fragments = {
        openers = {
            "By my oath,",
            "Hear me,",
            "In the Light's name,",
        },
        closers = {
            "so it is sworn.",
            "and justice will follow.",
            "let none doubt it.",
        },
    },
    GuildGreetings = {
        Standard = {
            "The Light be with you, friend.",
            "Honor and duty guide us.",
            "Stand firm. Righteousness is on our side.",
            "The Light bless this gathering!",
            "Faith and steel, brothers and sisters!",
            "Another day to serve the Light!",
            "Stand tall, faithful ones!",
            "Let righteousness guide us today!",
        },
    },
    SpellReactions = {
        Tier1_MajorCD = {
            "The Light is my shield and my sword!",
            "Let righteousness be done!",
            "By conviction I stand unbroken!",
            "Witness the faith that guides me!",
            "None shall pass while I draw breath!",
            "In the name of the Light!",
            "Righteous fury!",
            "None shall stand against the faithful!",
        },
        Tier2_Routine = {
            "Judgment is at hand!",
            "Repent!",
            "Justice finds all in time!",
            "I am merciful, but not endlessly.",
            "Stand down and be spared!",
            "Purge the wicked!",
            "For the Light!",
            "Cleansed!",
            "Faith strikes true!",
        },
        Tier3_LowHP = {
            "My faith is not so easily broken!",
            "I will not fall in a righteous cause!",
            "Hold fast, and the Light holds you!",
            "Pain is nothing against conviction!",
            "Lend me strength, if you can!",
            "My faith shields me!",
            "The Light will not let me fall!",
            "I endure for the righteous!",
        },
    },
    PvPLines = {
        FirstClash = {
            "{zone} will not be stained by wickedness, {target}. Stand down!",
            "I do not seek blood, {target}, but I will answer it.",
            "Repent, {target}, or be purged!",
            "The Light has judged you, {target}!",
        },
        DejaVu = {
            "{zone} again. May justice finally rest here.",
            "Another clash in {zone}. Let it be the last.",
            "{zone} must be cleansed again!",
            "Heresy festers in {zone}.",
        },
        Rematch = {
            "You return, {target}. The righteous do not tire.",
            "Again, {target}? The Light grants me patience.",
            "You return to your sins, {target}?",
            "Again, {target}? The Light is patient. I am not.",
        },
        Vendetta = {
            "I remember {lastzone}, {target}. Justice has a long memory.",
            "You wronged me in {lastzone}. I will answer, {target}.",
            "{lastzone} cries out for justice, {target}!",
            "For {lastzone}, {target}! Repent!",
        },
        Dominance = {
            "You have fallen to my conviction before, {target}. Spare yourself.",
            "Turn back, {target}. I would rather not strike twice.",
            "The Light has humbled you before, {target}!",
            "Kneel, {target}. Again.",
        },
        Nemesis = {
            "{target}! Our reckoning is sworn. It ends today!",
            "By my oath, {target}, I end this where it began: {lastzone}!",
            "{target}! The final judgment is here!",
            "By the Light, {target}, you are condemned!",
        },
    },
}
