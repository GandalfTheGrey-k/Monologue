--[[
    Monologue Data Module: Gnome Race
    PURE DATA TABLE. Key matches UnitRace("player") raceFile "Gnome".
    Lore: Gnomeregan, Tinker Town, High Tinker Mekkatorque, troggs, gizmos and gadgets.
    WoW Forever canon only.

    Dialect format: see the top of Monologue_Translator.lua. A string value is one fixed swap;
    a list of strings is a set of variants, one picked at random (the last 3 are avoided).
    Gnomes talk fast and technically, so the cadence is snappy (contractions) and full of
    workshop vocabulary.
--]]

MonologueEngine.Data.Races["Gnome"] = {
    Dialect = {
        wordSwaps = {
            ["hello"] = { "salutations", "greetings", "well hello" },
            ["hi"] = { "salutations", "greetings", "ahoy" },
            ["goodbye"] = { "farewell", "until the next experiment", "so long" },
            ["yes"] = { "affirmative", "correct", "precisely" },
            ["thanks"] = { "much obliged", "my thanks", "thank you kindly" },
            ["friend"] = { "colleague", "comrade", "fellow tinker", "assistant" },
            ["friends"] = { "colleagues", "comrades", "fellow tinkers" },
            ["broken"] = { "malfunctioning", "busted", "out of calibration", "jammed" },
            ["fix"] = { "recalibrate", "repair", "tinker with", "patch" },
            ["idea"] = { "hypothesis", "invention", "brainwave", "blueprint" },
            ["problem"] = { "engineering challenge", "design flaw", "complication" },
            ["fast"] = { "high-speed", "rapid", "accelerated" },
            ["machine"] = { "contraption", "apparatus", "gizmo" },
            ["explode"] = { "detonate", "go boom", "combust" },
        },
        phraseSwaps = {
            ["thank you"] = { "much obliged", "thank you kindly", "my sincerest gratitude" },
            ["watch out"] = { "mind the gears", "stand clear", "safety first" },
            ["be careful"] = { "handle with care", "mind the sprockets", "careful, it's delicate" },
            ["good job"] = { "splendid work", "well engineered", "excellent calibration" },
            ["let's go"] = { "let's get tinkering", "off we trundle", "to the workshop" },
            ["on my way"] = { "en route", "trundling over now", "arriving momentarily" },
            ["good luck"] = { "may your gears never jam", "fortune and good lubrication" },
            ["good morning"] = { "a bright start to the day", "good morning, esteemed colleague" },
            ["i don't know"] = { "data insufficient", "I have no hypothesis", "further study needed" },
            ["help me"] = { "lend a hand, colleague", "I require assistance" },
            ["what is that"] = { "what is that contraption", "fascinating, what is that" },
            ["come on"] = { "chop chop", "step on the gears" },
            ["it's broken"] = { "it's malfunctioning", "it's gone haywire" },
        },
        contractions = {
            -- Fast, snappy cadence: formal phrases get clipped now and then
            ["do not"] = "don't",
            ["cannot"] = "can't",
            ["let us"] = "let's",
            ["is not"] = "isn't",
        },
        phonetics = {
            ["^gonna$"] = "going to",
            ["^wanna$"] = "want to",
        },
        interjections = { "fascinating", "by my sprockets", "as expected", "in theory" },
        openers = {
            "Fascinating,",
            "Observe,",
            "Hypothetically,",
            "By my calculations,",
            "Aha,",
            "Listen,",
            "Excellent,",
            "Technically,",
        },
        closers = {
            ", by my sprockets!",
            ", in theory.",
            ", with minimal explosions.",
            ", according to my calculations.",
            ", probably.",
            ", for science!",
            ", assuming nothing catches fire.",
            ", as the blueprints say.",
        },
    },
    GuildGreetings = {
        Standard = {
            "Salutations! Care to test a prototype?",
            "Gnomeregan will be reclaimed, you know. It's just a matter of engineering.",
            "Mind the gears, and may your gizmos never jam!",
            "Good morning, brilliant minds! What are we inventing today?",
            "Gnomeregan will rise, and so will this guild!",
            "Remember, friends: if it explodes, it's still progress.",
            "Mind the gears, everyone. And the steam. And the sparks.",
            "Welcome back! The coffee machine is only slightly on fire.",
        }
    },
    FriendGreetings = {
        Ally = {
            "{target}! My favourite field partner.",
            "Ready for another round of applied violence?",
            "With you along, my odds improve by forty percent.",
            "Good. I was hoping for a reliable variable.",
            "Same plan as last time? The one that worked?",
        },
        Default = {
            "Salutations, {target}! Care to test a prototype?",
            "{target}! Perfect timing. I need an assistant, I mean, a friend!",
            "My favorite colleague, {target}! Mind the gears.",
            "{target}! I've built something. Please don't be alarmed.",
            "Ah, {target}! You're welcome in my workshop any time.",
            "{target}! Wonderful timing, I just finished calibrating!",
            "Ah, {target}! Hold this sprocket? Kidding! Hello!",
            "{target}! My favorite person this week. Possibly this month!",
            "Well met, {target}! Mind the wires.",
        },
    },
    DuelWin = {
        "Experiment concluded, {target}: I win! Great data, though!",
        "Fascinating duel, {target}! Excellent test conditions.",
        "A win for engineering, {target}! Care for a rematch?",
        "Well fought, {target}! The sprockets held.",
        "Hah! Calculated to the decimal, {target}!",
        "Size isn't everything, {target}! Good bout!",
        "Victory! For science! Well fought, {target}.",
        "Excellent data, {target}. I'll be writing this up!",
    },
    DuelLoss = {
        "Hm! Unexpected results, {target}. Back to the workshop!",
        "Well fought, {target}! I'll recalibrate for next time.",
        "You've disproven my hypothesis, {target}! Fascinating.",
        "Data noted, {target}. A rematch, perhaps?",
        "Ow. Recalibrating. Well done, {target}!",
        "You win this round, {target}! I'll build something.",
        "Fascinating technique, {target}. I must study it.",
        "Error noted, {target}. It won't happen twice!",
    },
    PvPLines = {
        FirstClash = {
            "Fascinating! A new test subject in {zone}. Hold still, {target}.",
            "Don't mind the whirring, {target}. It's perfectly safe. Mostly.",
            "You're about to meet my latest invention, {target}!",
            "Big doesn't mean smart, {target}!",
        },
        DejaVu = {
            "{zone} again! My calculations predicted another skirmish here.",
            "Another fight in {zone}. The data keeps repeating.",
            "{zone} again? I'm keeping a spreadsheet now.",
            "Statistically, {zone} is very bad for you.",
        },
        Rematch = {
            "Back for round two, {target}? I've made improvements.",
            "Recalibrated and ready, {target}!",
            "Ooh, {target}! Round two! I've made adjustments!",
            "Back again, {target}? I upgraded.",
        },
        Vendetta = {
            "Remember {lastzone}, {target}? I've been drawing up plans ever since.",
            "You wrecked my best gadget in {lastzone}, {target}. Unforgivable!",
            "My notes from {lastzone} say: you cheated, {target}!",
            "Remember {lastzone}, {target}? I do. I wrote it down.",
        },
        Dominance = {
            "The results are in, {target}: I win. Again.",
            "Statistically speaking, you should stop, {target}.",
            "The numbers don't lie, {target}. You lose.",
            "Again, {target}? My data predicted this.",
        },
        Nemesis = {
            "{target}! This experiment has run long enough. Time to conclude it, right where it started: {lastzone}!",
            "Every gizmo I own is calibrated for you, {target}!",
            "{target}! I built something JUST for you!",
            "Gnomeregan remembers, {target}! Engage!",
        },
    },
    -- Racial Temperament Presets (My Voice tab). A preset replaces openers/closers, merges
    -- FriendGreetings, replaces BattleCry and may shift intensity by -1..+1.
    Presets = {
        Tinkerer = {
            name = "Gadget Tinkerer",
            blurb = "Precise and distracted: always mid-repair, always certain the gear will hold.",
            dialectIntensity = 0,
            openers = {
                "Hold on, calibrating,",
                "Interesting,",
                "If my calculations hold,",
                "Hmm, a gear's loose,",
                "Mind the sprocket,",
                "Observe,",
            },
            closers = {
                ", probably.",
                ", by my calculations.",
                ", assuming no explosions.",
                ", the gears agree.",
                ", tolerance is acceptable.",
                ", it should hold.",
            },
            FriendGreetings = {
                Default = {
                    "{target}! Hold this wrench, would you? Oh, hello!",
                    "Well met, {target}. Careful, that's still ticking.",
                    "{target}! Perfect timing. I need a test subject, er, friend.",
                },
            },
            BattleCry = {
                "Engage!",
                "Gears and grit!",
                "Test run: begin!",
            },
        },
        EagerInventor = {
            name = "Eager Inventor",
            blurb = "Bubbly and breathless: every idea is the best one yet.",
            dialectIntensity = 1,
            openers = {
                "Oh oh oh,",
                "Wait wait wait,",
                "I just had an idea,",
                "Ooh,",
                "You'll love this,",
                "Listen listen,",
            },
            closers = {
                ", isn't that wonderful?",
                ", and then it goes boom!",
                ", I can't wait!",
                ", brilliant, right?",
                ", oh, the possibilities!",
                ", faster, faster!",
            },
            FriendGreetings = {
                Default = {
                    "{target}! You came! I have so many things to show you!",
                    "Oh, {target}! You must see my new gadget!",
                    "{target}! It's been ages! Well, a day, but still!",
                },
            },
            BattleCry = {
                "Time for science!",
                "It's going to be spectacular!",
                "Behold, my greatest invention!",
            },
        },
        DryWit = {
            name = "Deadpan Engineer",
            blurb = "Understated, sardonic and quietly unimpressed by anything not mechanical.",
            dialectIntensity = -1,
            openers = {
                "Fascinating,",
                "Sure,",
                "If you insist,",
                "Naturally,",
                "Oh, wonderful,",
                "As predicted,",
            },
            closers = {
                ", how thrilling.",
                ", I'm sure.",
                ", moving on.",
                ", noted.",
                ", fine.",
                ", or not.",
            },
            FriendGreetings = {
                Default = {
                    "{target}. Oh. You're here. Excellent.",
                    "Hm, {target}. I suppose a visit was bound to happen.",
                    "{target}. Try not to touch anything.",
                },
            },
            BattleCry = {
                "Well. Here we go.",
                "This'll be fun, I'm sure.",
                "Initiating regrettable decisions.",
            },
        },
    },
    EmoteReplies = {
        Wave = {
            "Hello hello, {target}!",
            "Oh! Hi, {target}!",
            "Greetings, {target}! Fine day for tinkering!",
            "Wave received, {target}! Waving back!",
        },
        Bow = {
            "Oh, stop it, {target}! I'm blushing.",
            "A bow? For me, {target}? How delightful!",
            "Rise, {target}! No ceremony in the workshop.",
            "Why thank you, {target}!",
        },
        Cheer = {
            "Woo! Yes, {target}!",
            "Huzzah, {target}! Science wins again!",
            "That's the spirit, {target}!",
            "Ha! Excellent, {target}!",
        },
        Toast = {
            "To progress, {target}!",
            "To Gnomeregan, {target}!",
            "Cheers, {target}! Don't spill on the blueprints!",
            "To explosions that go the right way, {target}!",
        },
        Hug = {
            "Eep! Hello, {target}!",
            "Careful, {target}! Delicate instruments!",
            "Aww, {target}. Hugs are very efficient.",
            "Ha! Missed you too, {target}!",
        },
        Rude = {
            "How very uncivilized, {target}.",
            "I've met smarter troggs, {target}.",
            "That's going in my notes, {target}.",
            "Rude AND wrong, {target}. Impressive.",
        },
        Challenge = {
            "A challenge? I accept, {target}! Let me grab my wrench.",
            "Careful, {target}. I have gadgets.",
            "Ha! Size isn't everything, {target}!",
            "Bring it, {target}! I've upgraded.",
        },
    },
    RivalOpeners = {
        Vendetta = {
            "{target}! I've studied {lastzone} all night!",
            "Remember {lastzone}, {target}? Version two is here!",
            "For {lastzone}, {target}! Engage!",
            "{target}! I calculated your weakness after {lastzone}!",
        },
        SwornFoe = {
            "Oh, it's {target} again! Excellent, more data!",
            "{target}! I made improvements!",
            "Round three, {target}? Ready!",
            "Back again, {target}? So am I!",
        },
        Nemesis = {
            "{target}! Initiating maximum overdrive!",
            "FOR GNOMEREGAN! {target}, prepare yourself!",
            "{target}! I built this one just for you!",
            "This is the big one, {target}!",
        },
        Default = {
            "Experiment begins, {target}!",
            "Hold still, {target}! Testing!",
            "Here comes science, {target}!",
            "Engage, {target}!",
        },
    },
    StanceGreetings = {
        WARM = {
            "{target}! Splendid to see one of the {targetrace} folk!",
            "Well met, {target}! Your people are marvelous.",
            "Hello, {target}! Always a pleasure.",
            "{target}! A friend indeed!",
        },
        ADMIRING = {
            "{target}! The {targetrace} are simply fascinating.",
            "Oh, {target}! I could learn so much from your people.",
            "{target}, your kind's work is truly inspiring!",
            "An honor, {target}! I've read all about your people.",
        },
        PLAYFUL = {
            "{target}! You're so tall. Is the weather nice up there?",
            "Ah, {target}. Try not to step on me this time!",
            "{target}! Still not tinkering? Shame.",
            "Ha! {target}! Mind your head, low ceilings ahead.",
        },
        WARY = {
            "{target}. Hmm. Logging this encounter.",
            "Careful, {target}. I have defensive measures.",
            "{target}. I'm keeping an eye on you. Well, a lens.",
            "Hm. {target}. Trust is earned. Like gears.",
        },
        GRUFF = {
            "{target}. Don't touch anything.",
            "Hmph. {target}. I'm busy.",
            "{target}. Go away, I'm calibrating.",
            "{target}. You're blocking my light.",
        },
        DISDAINFUL = {
            "{target}. How... primitive.",
            "Oh. One of the {targetrace}. Fascinatingly simple.",
            "{target}. Do you even know what a sprocket is?",
            "{target}. I'll use small words.",
        },
        Dwarf = {
            WARM = {
                "{target}! Ironforge took us in. We won't forget it!",
                "Well met, {target}! Your forges and my gears!",
                "{target}! Best neighbors a gnome could ask for!",
            },
            GRUFF = {
                "{target}. Your ale is not a lubricant. Stop putting it in my machines.",
                "Hmph. {target}. Less hammering, more thinking.",
                "{target}. Mind the beard near the gears.",
            },
        },
        NightElf = {
            WARM = {
                "{target}! Your forests are lovely. Very few explosions!",
                "Ishnu'alah, {target}! Did I say that right?",
                "{target}! Ten thousand years! Imagine the inventions!",
            },
            GRUFF = {
                "{target}. Trees are not a technology.",
                "Hmph. {target}. So old, and never built a single gear.",
                "{target}. Some of us have deadlines.",
            },
        },
        Human = {
            WARM = {
                "{target}! Stormwind's been very kind to us refugees!",
                "Well met, {target}! Good, sturdy people, humans.",
                "{target}! Your city has the best clockwork in the Alliance!",
            },
            GRUFF = {
                "{target}. Stop calling it a 'whatsit'.",
                "Hmph. {target}. Humans and their shouting.",
                "{target}. No, you can't borrow my wrench.",
            },
        },
    },
    -- Racial combat openers: mixed into signature-move pull lines now and then
    -- (homeland, kin and pride; the class and spell pools cover the rest)
    CombatOpeners = {
        "Calculating. Calculating. Right, go.",
        "For Gnomeregan. The old one and the next one.",
        "Statistically, this goes very well for me.",
        "Small target, big ideas.",
        "Tinker Town didn't teach me to back down.",
        "Mekkatorque would want this done efficiently.",
        "Hypothesis: you fall over. Testing now.",
        "Short, yes. Slow, no.",
        "Mind your knees. They're at my eye level.",
        "Another field trial. Hold still.",
        "I've fixed worse things than you with a wrench.",
    },
    -- Clans / lineages: chosen on the My Voice tab (only this race's appear). Combat lines
    -- join pull lines now and then, Greet lines friendly greetings, Idle lines idle chatter.
    Clans = {
        { key = "Gnomeregan", name = "Gnomeregan Survivor",
            Combat = {
                "For Gnomeregan! The real one, someday.",
                "Mekkatorque didn't raise quitters.",
                "Survived the fallout. You're easy.",
                "Sparks and science.",
            },
            Greet = {
                "{target}! Gnomeregan salutes you.",
                "Well met. Ask me about my ten-point reclamation plan.",
                "Hello, hello! Mind the sprockets.",
            },
            Idle = {
                "One day we'll take the city back.",
                "Tinker Town needs a bigger workshop.",
                "I left my best wrench in Gnomeregan.",
            },
        },
        { key = "Leper", name = "Leper / Radiation-Scarred Exile",
            Combat = {
                "The radiation made me tough. And green.",
                "I glow. You'll burn.",
                "Thermaplugg did this. You'll pay for him.",
                "Exile's no excuse to lose.",
            },
            Greet = {
                "{target}. Don't worry, it's not catching. Mostly.",
                "Most people step back. Thanks for not.",
                "Hello. Ignore the smell of ozone.",
            },
            Idle = {
                "My left ear still hums at night.",
                "They say the glow fades. They're lying.",
                "Overspark keeps trying new cures on me.",
            },
        },
    },
}
