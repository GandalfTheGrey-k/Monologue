--[[
    Monologue Data Module: Persona - Cynical Mercenary
    PURE DATA TABLE. Universal Growth Arc persona: works for any race and class.

    Voice: a battle-tested sellsword, dry, transactional and hard to impress. Fits the
    middle levels (20-49) best, but can be assigned to any stage in /mono ui.

    Pools here replace the lower layers' pools of the same name; word swaps merge into the
    race's (chosen to avoid the race packs' own keys). The race accent still runs over
    these lines when they are spoken, and the race's suffix flourishes are kept.
--]]

MonologueEngine.Data.Personas["CynicalMercenary"] = {
    displayName = "Cynical Mercenary",
    Dialect = {
        wordSwaps = {
            ["gold"] = "coin",
            ["quest"] = "contract",
            ["job"] = "contract",
            ["favor"] = "debt",
            ["reward"] = "payment",
        },
    },
    Fragments = {
        openers = {
            "Look,",
            "Listen,",
            "For the record,",
        },
        closers = {
            "Nothing personal.",
            "That's the price.",
            "Don't say I didn't warn you.",
        },
    },
    GuildGreetings = {
        Standard = {
            "Coin's good, company's tolerable. Well met.",
            "I'll stand with you. For a fair share.",
            "Another day, another contract. Let's go.",
            "Morning. Who's paying today?",
            "Any contracts worth taking?",
            "Let's get this over with, friends.",
            "Gold doesn't earn itself. Who's in?",
            "Same guild, same jobs. Fine by me.",
        },
    },
    SpellReactions = {
        Tier1_MajorCD = {
            "Don't pay me enough for this, but here goes.",
            "Now it's a proper fight.",
            "Consider it my signature.",
            "This part costs extra.",
            "Don't blink. You'll miss the good bit.",
            "Fine. I'll do the heavy lifting.",
            "This costs extra.",
            "Watch a professional work.",
        },
        Tier2_Routine = {
            "Business as usual.",
            "Nothing personal.",
            "Another day, another contract.",
            "Try not to bleed on the coin.",
            "Pay attention. Class is in session.",
            "Another day, another coin.",
            "Easy money.",
            "That's billable.",
            "Next.",
        },
        Tier3_LowHP = {
            "I've been paid for worse. Barely.",
            "That's coming out of someone's cut.",
            "Somebody earn their share and cover me!",
            "Dying wasn't in the contract.",
            "Fine. Now I'm annoyed.",
            "This isn't in the contract!",
            "Hazard pay. Now.",
            "I'm not paid enough for this.",
        },
    },
    PvPLines = {
        FirstClash = {
            "Nothing personal, {target}. {zone} is just where we happened to meet.",
            "Name your price, {target}, or draw.",
            "Nothing personal, {target}. Just business.",
            "Your head's worth something, {target}.",
        },
        DejaVu = {
            "{zone} again. The pay's the same and the scenery isn't improving.",
            "Another scrap in {zone}. Someone's got to profit.",
            "{zone} again. Same old work.",
            "{zone}. Steady income, at least.",
        },
        Rematch = {
            "Back again, {target}? Fine. I'm billing you.",
            "Same arena, same result, {target}.",
            "Back again, {target}? Your loss.",
            "You keep paying my bills, {target}.",
        },
        Vendetta = {
            "You cost me in {lastzone}, {target}. I keep accounts.",
            "I don't forgive debts, {target}. {lastzone} still stings.",
            "{lastzone} cost me, {target}. Now you pay.",
            "I don't forget a debt, {target}. {lastzone}.",
        },
        Dominance = {
            "You know how this ends, {target}. Walk away and save us both the trouble.",
            "I've beaten you enough times to quote a price, {target}.",
            "You're a bad investment, {target}.",
            "Same result every time, {target}.",
        },
        Nemesis = {
            "Every ledger closes sometime, {target}. Yours closes here.",
            "{target}. After {lastzone} and all the rest, this one's on the house.",
            "{target}. This one I'd do for free.",
            "Final payment, {target}.",
        },
    },
}
