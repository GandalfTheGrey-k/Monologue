--[[
    Monologue Data Module: Warrior Class
    PURE DATA TABLE.

    UnitClass("player") returns all-caps classFile keys (e.g. "WARRIOR", "PALADIN", "SHAMAN").
    Lines suit every race that can be a Warrior. SpellTriggers lists Classic-era spell IDs
    (rank-specific); SpellNames names each one so /mono triggers can verify the IDs against
    the client. Only signature moves (SpellLines) speak; every other cast is silent.
--]]

MonologueEngine.Data.Classes["WARRIOR"] = {
    -- Class dialect: sits UNDERNEATH the race dialect. Where a race (or persona or profile)
    -- defines the same swap or list, theirs wins; this adds terse, martial phrasing for
    -- everything they leave open.
    Dialect = {
        wordSwaps = {
            ["battle"] = { "the fray", "the field", "the melee" },
            ["attack"] = { "strike", "charge", "press the attack" },
            ["defend"] = { "hold the line", "stand fast", "guard" },
            ["weapon"] = { "steel", "blade", "arms" },
            ["weapons"] = { "arms", "blades", "steel" },
            ["armor"] = { "plate", "mail", "steel" },
        },
        phraseSwaps = {
            ["stay behind me"] = { "get behind me", "stand behind my shield", "I'll take the front" },
            ["cover me"] = { "watch my flank", "guard my back" },
            ["hold the line"] = { "stand fast", "do not break" },
            ["charge in"] = { "press the attack", "into the fray" },
            ["all together"] = { "as one", "shoulder to shoulder" },
            ["take cover"] = { "shields up", "down behind the line" },
            ["follow me"] = { "on me", "to me, steel up" },
        },
    },
    -- Tier1_MajorCD: the Battle Cry fallback (when a character has no BattleCry pool).
    -- Tier3_LowHP: said when your health drops low. Casts never use these pools.
    SpellReactions = {
        Tier1_MajorCD = {
            "For everyone who isn't here.",
            "On me. Now!",
            "We hold here.",
            "Steel up!",
            "Nobody breaks.",
            "Forward. Together.",
            "Make them remember this field.",
            "Straight backs, sharp edges.",
        },
        Tier3_LowHP = {
            "Still standing. Barely.",
            "Need a heal. Soon would be nice.",
            "That one went through.",
            "Not yet. Not here.",
            "Bleeding. Keep fighting.",
            "Healer! Anyone!",
            "Fine. I'm fine. Mostly.",
            "Hold. Just hold.",
        },
    },
    SpellTriggers = {
        -- IDs checked by /mono triggers. Speech comes from SpellLines (signature moves only).
        [1719] = "Tier1_MajorCD",  -- Recklessness
        [871] = "Tier1_MajorCD",   -- Shield Wall
        [12975] = "Tier1_MajorCD", -- Last Stand
        [20230] = "Tier1_MajorCD", -- Retaliation
        [12292] = "Tier1_MajorCD", -- Sweeping Strikes
        [12328] = "Tier1_MajorCD", -- Death Wish
        [100] = "Signature",   -- Charge
        [6178] = "Signature",  -- Charge
        [11578] = "Signature", -- Charge
        [20252] = "Signature", -- Intercept
        [20616] = "Signature", -- Intercept
        [20617] = "Signature", -- Intercept
        [5308] = "Signature",  -- Execute
        [20658] = "Signature", -- Execute
        [20660] = "Signature", -- Execute
        [20661] = "Signature", -- Execute
        [20662] = "Signature", -- Execute
        [5246] = "Signature",  -- Intimidating Shout
    },
    -- English names by spell ID: used to find a cast's SpellLines on any client language
    SpellNames = {
        [100] = "Charge",
        [871] = "Shield Wall",
        [1719] = "Recklessness",
        [5246] = "Intimidating Shout",
        [5308] = "Execute",
        [6178] = "Charge",
        [11578] = "Charge",
        [12292] = "Sweeping Strikes",
        [12328] = "Death Wish",
        [12975] = "Last Stand",
        [20230] = "Retaliation",
        [20252] = "Intercept",
        [20616] = "Intercept",
        [20617] = "Intercept",
        [20658] = "Execute",
        [20660] = "Execute",
        [20661] = "Execute",
        [20662] = "Execute",
    },
    -- Signature moves: the only casts that speak (filler like Heroic Strike or Rend stays
    -- silent). Each spell has Default lines plus one pool per persona; the active persona's
    -- pool is used when set. big = true lets a cooldown speak mid-fight. See VOICE_GUIDE.md.
    SpellLines = {
        ["Charge"] = {
            Default = {
                "Coming through.",
                "Stay right there.",
                "Mind your footing.",
                "Shield up. Going in.",
                "That's far enough for you.",
                "Don't run. It only makes it worse.",
                "On you.",
                "Close the gap, the sergeant always said. So.",
                "You're mine, then.",
                "Brace.",
                "Make way!",
                "Hold still a moment.",
            },
            EagerRookie = {
                "Okay. Going in. Going in now!",
                "Just like the drill. Just like the drill.",
                "I really hope this works.",
                "Charging! Was that the right one?",
                "Ha! Faster than I thought!",
                "Don't look at my feet, look at my sword.",
            },
            CynicalMercenary = {
                "Paid in advance, I hope.",
                "This part's extra.",
                "Fine. I'll go first. I always go first.",
                "Nothing personal. Strictly hourly.",
                "Somebody's paying for these boots.",
                "Let's get this over with.",
            },
            GrizzledVeteran = {
                "Same as always. Head down, shield up.",
                "Knees aren't what they were. Still faster than you.",
                "Seen a hundred like you.",
                "Keep your feet. I'm coming.",
                "One more. Then supper.",
                "Don't flinch. It's worse if you flinch.",
            },
            ZealousCrusader = {
                "Stand and be judged.",
                "The Light goes before me.",
                "Kneel, or be carried.",
                "There is no hiding from the righteous.",
                "I come with the dawn!",
                "Your reckoning walks on two feet.",
            },
        },
        ["Intercept"] = {
            Default = {
                "Not so fast.",
                "Where do you think you're going?",
                "Back here.",
                "Running doesn't help.",
                "I wasn't finished.",
                "Sit down.",
                "We're not done.",
                "Get back in the fight!",
                "No you don't.",
                "Thought you'd slip off?",
            },
            EagerRookie = {
                "Got you! I actually got you!",
                "Don't run, please, I'm new at this.",
                "That was so fast. Wow.",
                "Hey. Come back here.",
                "I caught one!",
                "My legs can do that? Good to know.",
            },
            CynicalMercenary = {
                "Running costs extra.",
                "Contract says you stay put.",
                "I chase. You pay.",
                "Don't make me earn it.",
                "Ugh. Cardio.",
                "Sit. Good.",
            },
            GrizzledVeteran = {
                "Old trick. Still works.",
                "Everyone runs. Nobody gets far.",
                "You stop when I say.",
                "Should've run sooner.",
                "Back to the line, you.",
                "I was faster at your age. Still am.",
            },
            ZealousCrusader = {
                "The guilty always flee.",
                "You cannot outrun judgment.",
                "The Light has long legs.",
                "Turn and face it!",
                "Where would you hide from heaven?",
                "Stand. Answer for it.",
            },
        },
        ["Execute"] = {
            Default = {
                "That's done.",
                "Stay down this time.",
                "Finish it.",
                "Last one.",
                "You almost had me. Almost.",
                "No getting up from that.",
                "Rest now.",
                "Clean.",
                "That one's for the long walk here.",
                "And that's the end of that.",
            },
            EagerRookie = {
                "I did it! I really did it!",
                "Is it... is it dead? It's dead.",
                "Oh no. Oh good. Good.",
                "Wait till I tell the others.",
                "That's my first real one. I think.",
                "Sorry! I mean, ha!",
            },
            CynicalMercenary = {
                "And that's the invoice.",
                "Payment received.",
                "Next.",
                "Don't take it personal.",
                "Bag it.",
                "That's the job done.",
            },
            GrizzledVeteran = {
                "Quick and clean. Like they taught us.",
                "Don't make it pretty. Make it end.",
                "Close your eyes. Easier.",
                "Another name I won't remember.",
                "Done. Check your gear.",
                "There. Stay down.",
            },
            ZealousCrusader = {
                "Judgment is rendered.",
                "The ledger is closed.",
                "Go to your reckoning.",
                "Mercy was offered. Once.",
                "It is finished.",
                "The Light has no further use for you.",
            },
        },
        ["Intimidating Shout"] = {
            Default = {
                "Back off!",
                "Scatter.",
                "Run. Go on.",
                "Get away from them!",
                "Everybody out.",
                "Run home.",
                "That's right, run.",
                "Shoo.",
                "Off with you, the lot of you.",
                "Give me some room.",
            },
            EagerRookie = {
                "Was that me? That was loud.",
                "Go away! Please!",
                "Boo! Ha, it worked!",
                "Run! Not you guys. Them.",
                "I've been practicing that.",
                "Wow. They actually ran.",
            },
            CynicalMercenary = {
                "Saves me the trouble.",
                "Run. I'm not paid to chase.",
                "Go on, scatter. Less paperwork.",
                "Fewer of you, fewer problems.",
                "A few seconds of peace. Worth it.",
                "Keep running. Further.",
            },
            GrizzledVeteran = {
                "Lungs still work.",
                "Give me some room to breathe.",
                "Old voice, same effect.",
                "Run. It's the smart choice.",
                "Scared them off. Use the time.",
                "Bark's worse than the bite. Barely.",
            },
            ZealousCrusader = {
                "Flee from the righteous!",
                "Your fear is your confession.",
                "Tremble, and be scattered.",
                "The wicked run where none pursue.",
                "Run. It changes nothing.",
                "Your hearts know what you are.",
            },
        },
        ["Recklessness"] = {
            big = true,
            Default = {
                "No holding back now.",
                "Forget the shield.",
                "All of it. Right now.",
                "Careful? No.",
                "Everything I've got!",
                "Stand clear of me.",
                "This is going to cost me.",
                "Don't stand behind me. Or in front.",
                "Fine. Gloves off.",
                "Hit hard, think later.",
            },
            EagerRookie = {
                "So this is how it feels!",
                "I don't know what I'm doing and I love it!",
                "Nobody tell my mother.",
                "Going all in, I guess.",
                "My blood's on fire. Is that normal?",
                "Watch this. Actually, don't.",
            },
            CynicalMercenary = {
                "Overtime rates apply.",
                "This is the expensive part.",
                "Fine. Full price.",
                "Stand back. Liability.",
                "Burning everything. Bill's coming.",
                "No refunds after this.",
            },
            GrizzledVeteran = {
                "Haven't done this since the war.",
                "Short window. Make it count.",
                "Old blood still runs hot.",
                "Last time I did this, I woke up three days later.",
                "Don't try this at my age.",
                "All in. No second plan.",
            },
            ZealousCrusader = {
                "Let zeal be my armor!",
                "I hold nothing back from the Light.",
                "Holy fury, to the last breath.",
                "No restraint in the face of evil.",
                "My soul is the whetstone.",
                "Burn bright. Burn out if I must.",
            },
        },
        ["Shield Wall"] = {
            big = true,
            Default = {
                "Shields up. Get behind me.",
                "Let them come.",
                "I'll hold. Get to work.",
                "Behind me. Now!",
                "Go on, hit the wall.",
                "They don't get past this.",
                "Take your time. I've got this.",
                "Not one step further.",
                "Hit me. Not them.",
                "I'm the door. You're outside.",
            },
            EagerRookie = {
                "I can hold! I think I can hold!",
                "Everyone behind me! Is everyone behind me?",
                "This shield's heavier than it looks.",
                "Solid. Very solid. I'm solid.",
                "Please hold, please hold.",
                "I'm a wall. I'm a wall!",
            },
            CynicalMercenary = {
                "Hazard pay starts now.",
                "You're welcome. Invoice later.",
                "Hide behind the expensive part.",
                "I don't break. I renegotiate.",
                "This is what you're paying for.",
                "Hurry up. My arms are on the clock.",
            },
            GrizzledVeteran = {
                "Seen better walls fall. Not this one.",
                "Dig in. It'll pass.",
                "Breathe. Let them tire.",
                "I've held passes with less.",
                "Get the healer. I'll keep the door.",
                "Plant your feet. Wait it out.",
            },
            ZealousCrusader = {
                "The Light is my bulwark.",
                "Behind me, faithful.",
                "No evil passes this shield.",
                "I stand. Heaven holds me up.",
                "Strike, and see what faith can bear.",
                "My wall was built in prayer.",
            },
        },
    },
    pvpStyle = "Frontline Brawler"
}

-- Context lines for the signature moves (used on a rare, an elite, an enemy player or in a
-- group; see Data.SpellContextLines in situations/Details.lua for the shared ones)
do
    local lines = MonologueEngine.Data.Classes["WARRIOR"].SpellLines
    lines["Charge"].Player = {
        "Right at you, {target}.",
        "You won't outrun a charge, {target}.",
        "Brace, {target}. Here I come.",
        "Running won't help, {target}.",
        "{target}! Over here.",
    }
    lines["Charge"].Elite = {
        "Big {mob}. Bigger charge.",
        "Straight at the {mob}. No hesitating.",
        "Always charge the big one.",
        "Shield up. That {mob} hits hard.",
    }
    lines["Charge"].Rare = {
        "{mob}! Don't you dare run.",
        "Finally found you, {mob}.",
        "Charging before it vanishes.",
        "{mob}. Stay right there.",
    }
    lines["Charge"].Party = {
        "Charging in, {party}. Follow.",
        "I'll grab it, {party}. Hit what I hit.",
        "Watch my back, {party}. Going in.",
        "Pull's on me. Stay close.",
    }
    lines["Intercept"].Player = {
        "You're not getting away, {target}.",
        "Back here, {target}.",
        "Running? Not from me, {target}.",
        "Thought you were clear, {target}?",
        "Not so fast, {target}.",
    }
    lines["Execute"].Player = {
        "Done, {target}.",
        "Should've run, {target}.",
        "That's the end of you, {target}.",
        "Good fight, {target}. Over now.",
    }
    lines["Execute"].Elite = {
        "Down you go, big {mob}.",
        "Finish the {mob}. Now.",
        "Tough {mob}. Not tough enough.",
        "That's the last swing, {mob}.",
    }
    lines["Execute"].Rare = {
        "Trophy time, {mob}.",
        "{mob}, you'll make a fine story.",
        "That's the end of the legend, {mob}.",
        "Rare kill. Remember this one.",
    }
end
