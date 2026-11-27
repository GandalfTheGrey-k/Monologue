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
    -- Tier1_MajorCD: the Battle Cry fallback (when a character has no BattleCry pool).
    -- Tier3_LowHP: said when your health drops low.
    SpellReactions = {
        Tier1_MajorCD = {
            "Burn, all of you!",
            "The shadow answers me.",
            "Shards, give me everything.",
            "Your souls are mine!",
            "Fel and fire.",
            "Feed, little ones.",
            "The dark is hungry.",
            "Every shard I carry. Now!",
        },
        Tier3_LowHP = {
            "My soul's worth more than this.",
            "Need a healthstone. Now.",
            "Blood for mana? Not now.",
            "Get it off me, demon!",
            "Fel won't stitch this.",
            "I'm not meant to be at the front.",
            "Shadow, a little help.",
            "Bleeding into the dark.",
            "Shards won't save me if I'm dead.",
            "Voidwalker. Do your one job.",
        },
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
    CombatOpeners = {
        "Your soul looks useful.",
        "Shards are low. You'll do.",
        "Don't mind the demon.",
        "Shadows, gather.",
        "Pain first. Talk later.",
        "The dark is patient. I'm not.",
        "I'll take what's left of you.",
        "Curses first.",
        "You'll make a fine shard.",
        "The fel's warm today.",
        "There's a demon behind me. Wave.",
        "I've studied worse than you.",
        "Something's whispering about you.",
        "Gul'dan's mistakes taught me plenty.",
        "Kneel, or burn!",
    },
    -- Signature moves: a spell's own lines. Pull lines when you open a fight with it;
    -- big = true lets a cooldown speak mid-fight, midChance lets crowd control, interrupts
    -- and heals speak mid-fight now and then. .Player lines are for enemy players.
    SpellLines = {
        ["Shadow Bolt"] = {
            "Shadow, sent.",
            "From the dark.",
            "A little piece of the void.",
            "Cold, black, quick.",
            "It's going to hurt.",
            "Darkness, delivered.",
            "Feel the empty.",
            "Straight from the shadow.",
            "A gift from the abyss.",
            "Mind the dark.",
            "There's more.",
            "The shadow takes!",
            Player = {
                "The shadow finds you, {target}.",
                "Your soul's showing, {target}.",
                "I'll be wanting that soul.",
                "Run, {target}. It'll find you anyway.",
                "Darkness, just for you.",
                "You're in my shadow now, {target}.",
            },
        },
        ["Corruption"] = {
            "Rot from the inside.",
            "It spreads.",
            "Corrupted. Give it time.",
            "Feel it crawl.",
            "No cure for this.",
            "Rotting nicely.",
            "Slow, sure, sick.",
            "It's in your blood now.",
            "Decay is patient.",
            "A little poison for the soul.",
            "Getting worse, isn't it?",
            "Rot!",
        },
        ["Immolate"] = {
            "Fel fire.",
            "Burn a while.",
            "Green flames suit you.",
            "Feel that heat?",
            "Fire that lingers.",
            "Smells like brimstone.",
            "Kindled.",
            "Burning slowly.",
            "The fire stays with you.",
            "Embers, all over.",
            "Crackle and burn.",
            "Into the fire!",
        },
        ["Fear"] = {
            midChance = 0.3,
            "Run.",
            "Afraid? You should be.",
            "Off you go.",
            "Fear does the work.",
            "Terror takes you.",
            "Nightmares, waking.",
            "Flee from me.",
            "Your heart's racing.",
            "Scared now?",
            "Don't look back.",
            "Fear is a leash.",
            "Run, little one!",
            Player = {
                "Run far, {target}.",
                "Trembling, {target}? Good.",
                "Heart racing, {target}?",
                "Look behind you, {target}. Then run.",
                "Fear is mine to give.",
                "Away you go, {target}.",
            },
        },
        ["Death Coil"] = {
            midChance = 0.3,
            "Horror, up close.",
            "Your life, my blood.",
            "Shudder.",
            "Take a step back.",
            "Your life tastes good.",
            "I'll take a bit of that.",
            "Freeze in fear.",
            "Coil and strike.",
        },
        ["Howl of Terror"] = {
            midChance = 0.3,
            "All of you. Scatter.",
            "Hear that? Flee.",
            "Everyone, run.",
            "The howl takes you all.",
            "Run, every one of you.",
            "Terror for the crowd.",
            "Off. All of you.",
            "Panic suits you.",
        },
        ["Banish"] = {
            midChance = 0.3,
            "Back where you came from.",
            "Not of this world.",
            "Go away. Stay away.",
            "Banished.",
            "Between worlds a while.",
            "Fade out.",
            "You don't belong here.",
            "Locked away.",
        },
        ["Drain Life"] = {
            midChance = 0.2,
            "I'll take that.",
            "Your life, my health.",
            "Drinking deep.",
            "That life is wasted on you.",
            "Every drop.",
            "You're feeding me.",
            "Life for life.",
            "Thank you. Truly.",
        },
        ["Shadowburn"] = {
            midChance = 0.3,
            "Burnt to the end.",
            "Last flame.",
            "That's the shard I wanted.",
            "Ash.",
            "End it.",
            "Burn out.",
            "Gone in shadow.",
            "Done with you.",
        },
        ["Soul Fire"] = {
            big = true,
            "A whole soul, burning.",
            "The shard's worth it.",
            "Soul-fire, for you.",
            "I spent a soul on you.",
            "Burn all of it.",
            "Fire from the soul.",
            "This will hurt.",
            "A soul's worth of fire.",
        },
        ["Life Tap"] = {
            midChance = 0.15,
            "Blood for mana.",
            "A little blood.",
            "Worth it.",
            "I'll heal later.",
            "Pain buys power.",
            "Tapped.",
            "Bleed a bit. Fine.",
            "The cost of doing business.",
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
