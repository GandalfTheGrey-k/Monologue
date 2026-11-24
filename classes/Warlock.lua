--[[
    Monologue Data Module: Warlock Class
    PURE DATA TABLE.

    Lines suit any race of Warlock and speak of shadow, pacts and demons in general terms.
    SpellTriggers use Classic-era rank-specific IDs, verified in-game with /mono triggers.
    No later-expansion abilities.
--]]

MonologueEngine.Data.Classes["WARLOCK"] = {
    -- Class dialect: sits UNDERNEATH the race dialect, so a race (or persona or profile) that
    -- defines the same swap or list wins. The words and phrases here are Warlock-specific
    -- (demons, pacts, curses) so they rarely collide with a race's own vocabulary.
    Dialect = {
        wordSwaps = {
            ["demon"] = { "fiend", "servant", "minion" },
            ["demons"] = { "fiends", "servants", "minions" },
            ["pain"] = { "agony", "suffering", "torment" },
            ["soul"] = { "essence", "spirit", "immortal spark" },
            ["curse"] = { "hex", "malediction", "blight" },
            ["pact"] = { "bargain", "contract", "covenant" },
        },
        phraseSwaps = {
            ["summon a demon"] = { "call forth a servant", "bind a fiend to the task" },
            ["it's a deal"] = { "the pact is sealed", "consider it bargained" },
            ["you owe me"] = { "you are in my debt", "I will collect" },
            ["make a pact"] = { "strike a bargain", "sign in blood" },
            ["feel the pain"] = { "taste the agony", "suffer for it" },
            ["as you wish"] = { "your will, my command", "it shall be so" },
        },
    },
    SpellReactions = {
        Tier1_MajorCD = {
            "Darkness answers my pact!",
            "Tremble. I have powers you cannot imagine!",
            "My servants hunger, and so do I!",
            "Bow before the shadow!",
            "The Nether answers!",
            "Feel true darkness!",
            "My power has no limit!",
            "Demons, devour them!",
        },
        Tier2_Routine = {
            "Suffer.",
            "Burn, and know why.",
            "Everything has a price. Yours is due.",
            "Your fear is delicious.",
            "Writhe.",
            "Darkness takes you.",
            "How delicious.",
            "Rot.",
            "The shadows feed.",
        },
        Tier3_LowHP = {
            "A pact is a two-edged blade!",
            "I've paid dearly to stand here. I will not fall!",
            "Protect me, my servant!",
            "Spare me the sympathy. Hold them off!",
            "My soul is not yours to take!",
            "Servant! Protect me!",
            "I need a soulstone!",
            "Not yet, not yet!",
        }
    },
    SpellTriggers = {
        [6789] = "Tier1_MajorCD",   -- Death Coil (rank 1)
        [17925] = "Tier1_MajorCD",  -- Death Coil (rank 2)
        [17926] = "Tier1_MajorCD",  -- Death Coil (rank 3)
        [5484] = "Tier1_MajorCD",   -- Howl of Terror (rank 1)
        [17928] = "Tier1_MajorCD",  -- Howl of Terror (rank 2)
        [18288] = "Tier1_MajorCD",  -- Amplify Curse
        [18708] = "Tier1_MajorCD",  -- Fel Domination
        [5782] = "Tier2_Routine",   -- Fear (rank 1)
        [6213] = "Tier2_Routine",   -- Fear (rank 2)
        [6215] = "Tier2_Routine",   -- Fear (rank 3)
        [710] = "Tier2_Routine",    -- Banish (rank 1)
        [18647] = "Tier2_Routine",  -- Banish (rank 2)
        [6358] = "Tier2_Routine",   -- Seduction
        [6353] = "Tier2_Routine",   -- Soul Fire (rank 1)
        [17924] = "Tier2_Routine",  -- Soul Fire (rank 2)
    },
    SpellNames = {
        [6789] = "Death Coil", [17925] = "Death Coil", [17926] = "Death Coil",
        [5484] = "Howl of Terror", [17928] = "Howl of Terror",
        [18288] = "Amplify Curse", [18708] = "Fel Domination",
        [5782] = "Fear", [6213] = "Fear", [6215] = "Fear",
        [710] = "Banish", [18647] = "Banish", [6358] = "Seduction",
        [6353] = "Soul Fire", [17924] = "Soul Fire",
    },
    -- Pull lines (see Engine:ResolvePullPool): SpellLines[<spell name>] is used when you pull
    -- or open with that spell; CombatOpeners otherwise. Each pool is drawn as a shuffled deck,
    -- so every line comes up once before any repeats. Keys are English spell names.
    CombatOpeners = {
        "Your soul will do nicely.",
        "Pain is the price. You'll pay it.",
        "My servant hungers.",
        "Shadows, to me!",
        "Fear me.",
        "I've bargained for power. Let's spend it.",
        "Darkness falls.",
        "You should not have come.",
        "The pact demands blood.",
        "Tremble.",
        "Everything burns eventually.",
        "Let's see how much you can suffer.",
        "Your doom approaches.",
        "Curses first, questions never.",
        "The Twisting Nether calls for you.",
    },
    SpellLines = {
        ["Shadow Bolt"] = {
            "Shadow Bolt!",
            "Darkness strikes!",
            "Feel the void!",
            "From the shadows!",
            "Taste the dark!",
            "Shadows consume!",
            "Bolt of night!",
            "Into darkness!",
            "Embrace the shadow!",
            "The void bites!",
            "Black fire!",
            "Here comes the dark!",
        },
        ["Corruption"] = {
            "Rot from within.",
            "Corruption takes root.",
            "Wither.",
            "Decay is patient.",
            "Feel it spread.",
            "Your flesh betrays you.",
            "Slowly, slowly.",
            "The rot begins.",
            "Fester.",
            "Corrupted.",
            "Spoiled to the core.",
            "Nothing pure survives this.",
        },
        Immolate = {
            "Burn!",
            "Immolate!",
            "Fel fire!",
            "Feel the flames of the Nether!",
            "Ignite!",
            "Burn slowly.",
            "The fire spreads.",
            "Smoldering nicely.",
            "Fire and shadow!",
            "Scorched soul!",
            "Burn, and know my name!",
            "Hellfire, just for you!",
        },
        Fear = {
            "Run!",
            "Fear me!",
            "Flee, little one!",
            "Terror!",
            "Run, and keep running!",
            "Your nightmares are real!",
            "Scream!",
            "Panic!",
            "Fear grips you!",
            "Go on, run!",
            "Afraid yet?",
            "Tremble!",
        },
    },
    -- Your demon (situations/Moments.lua explains the keys): {target} is its name. Family
    -- pools win over the general PetSummon one.
    Moments = {
        PetSummon = {
            "Serve, and be quick.",
            "You're bound to me. Remember it.",
            "Come. There's work.",
            "Answer the summons.",
            "Obey.",
            "Don't make me bind you twice.",
            "Stay where I can see you.",
            "Your leash is short today.",
        },
        PetSummon_Imp = {
            "Stop sulking and get to work.",
            "Yes, you again.",
            "Quiet. Just throw fire.",
            "No, you can't have a raise.",
            "Keep the complaining down.",
            "Try not to burn me this time.",
            "Less talking, {target}. More fire.",
            "I heard that.",
        },
        PetSummon_Voidwalker = {
            "Stand in front. That's all.",
            "Take the hits. Don't complain.",
            "Silent as ever. Good.",
            "Into the front, servant.",
            "Your purpose is simple. Endure.",
            "Guard me.",
            "Between me and them. Always.",
            "Hold the line, {target}.",
        },
        PetSummon_Succubus = {
            "Behave yourself.",
            "Keep your eyes on the enemy.",
            "Charm them. Not me.",
            "Work first. Games later.",
            "Don't get distracted.",
            "Do as you're told.",
            "No wandering off, {target}.",
            "Save the whip for them.",
        },
        PetSummon_Felhunter = {
            "Hunt the magic out of them.",
            "Good. Sniff out the casters.",
            "Heel, hound.",
            "Hungry for spells, are we?",
            "Stay. Wait for my word.",
            "The mages won't like you.",
            "Easy, {target}. Not yet.",
            "Smell that? Mana. Go on.",
        },
        PetDown = {
            "Useless.",
            "I'll summon another.",
            "A waste of a good soul shard.",
            "Bound, broken, banished. Typical.",
            "Back to the Nether with you.",
            "Hm. Replaceable.",
            "You were supposed to hold them.",
            "I'll call you back. Do better.",
        },
    },
    pvpStyle = "Attrition Caster"
}
