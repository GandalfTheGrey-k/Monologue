--[[
    Monologue Data Module: Paladin Class
    PURE DATA TABLE.

    Lines are written for every race that can walk the Paladin's path in WoW Forever,
    Undead Paladins included: they speak of the Light's answer and a sworn vow, never of
    a particular homeland. SpellTriggers use Classic-era rank-specific IDs, verified in-game
    with /mono triggers. No Avenging Wrath or other later-expansion abilities.
--]]

MonologueEngine.Data.Classes["PALADIN"] = {
    -- Class dialect: sits UNDERNEATH the race dialect, so a race (or persona or profile) that
    -- defines the same swap or list wins. The words and phrases here are Paladin-specific
    -- (faith, protection, justice) so they rarely collide with a race's own vocabulary.
    Dialect = {
        wordSwaps = {
            ["holy"] = { "sacred", "hallowed", "blessed" },
            ["evil"] = { "wicked", "unrighteous", "foul" },
            ["protect"] = { "shield", "guard", "ward" },
            ["justice"] = { "righteousness", "judgment", "what is right" },
            ["hope"] = { "faith", "a beacon", "promise" },
            ["blessing"] = { "grace", "benediction", "boon" },
        },
        phraseSwaps = {
            ["i'll protect you"] = { "my shield is yours", "none shall harm you" },
            ["heal me"] = { "mend my wounds", "I need the Light's touch" },
            ["have faith"] = { "trust in the Light", "keep the faith" },
            ["say a prayer"] = { "offer a prayer", "pray with me" },
            ["bless you"] = { "the Light bless you", "be blessed" },
            ["for justice"] = { "for righteousness", "for what is right" },
            ["stand with me"] = { "stand beside me", "walk with me in the Light" },
        },
    },
    -- Tier1_MajorCD: the Battle Cry fallback (when a character has no BattleCry pool).
    -- Tier3_LowHP: said when your health drops low.
    SpellReactions = {
        Tier1_MajorCD = {
            "The Light is with us!",
            "Stand with me. Stand firm.",
            "For the Silver Hand!",
            "By the Light, hold!",
            "We do not fall here.",
            "Lift your heads. The Light sees us.",
            "Steel and faith, together.",
            "Let them come. We are ready.",
        },
        Tier3_LowHP = {
            "The Light will see me through.",
            "Still standing. Light be thanked.",
            "Bloodied, not beaten.",
            "A little help. Faith's a slow healer.",
            "My armor's taken the worst of it.",
            "I can mend this. Give me a breath.",
            "Not done yet. Not by half.",
            "Hold, hold. I'm coming back.",
            "Uther took worse than this.",
            "Light, a little strength.",
        },
    },
    SpellTriggers = {
        [642] = "Tier1_MajorCD",    -- Divine Shield (rank 1)
        [1020] = "Tier1_MajorCD",   -- Divine Shield (rank 2)
        [498] = "Tier1_MajorCD",    -- Divine Protection (rank 1)
        [5573] = "Tier1_MajorCD",   -- Divine Protection (rank 2)
        [633] = "Tier1_MajorCD",    -- Lay on Hands (rank 1)
        [2800] = "Tier1_MajorCD",   -- Lay on Hands (rank 2)
        [10310] = "Tier1_MajorCD",  -- Lay on Hands (rank 3)
        [1022] = "Tier1_MajorCD",   -- Blessing of Protection (rank 1)
        [5599] = "Tier1_MajorCD",   -- Blessing of Protection (rank 2)
        [10278] = "Tier1_MajorCD",  -- Blessing of Protection (rank 3)
        [20216] = "Tier1_MajorCD",  -- Divine Favor
        [853] = "Tier2_Routine",    -- Hammer of Justice (rank 1)
        [5588] = "Tier2_Routine",   -- Hammer of Justice (rank 2)
        [5589] = "Tier2_Routine",   -- Hammer of Justice (rank 3)
        [10308] = "Tier2_Routine",  -- Hammer of Justice (rank 4)
        [20473] = "Tier2_Routine",  -- Holy Shock (rank 1)
        [20929] = "Tier2_Routine",  -- Holy Shock (rank 2)
        [20930] = "Tier2_Routine",  -- Holy Shock (rank 3)
        [20271] = "Tier2_Routine",  -- Judgement
        [20066] = "Tier2_Routine",  -- Repentance
    },
    SpellNames = {
        [642] = "Divine Shield", [1020] = "Divine Shield",
        [498] = "Divine Protection", [5573] = "Divine Protection",
        [633] = "Lay on Hands", [2800] = "Lay on Hands", [10310] = "Lay on Hands",
        [1022] = "Blessing of Protection", [5599] = "Blessing of Protection", [10278] = "Blessing of Protection",
        [20216] = "Divine Favor",
        [853] = "Hammer of Justice", [5588] = "Hammer of Justice",
        [5589] = "Hammer of Justice", [10308] = "Hammer of Justice",
        [20473] = "Holy Shock", [20929] = "Holy Shock", [20930] = "Holy Shock",
        [20271] = "Judgement", [20066] = "Repentance",
    },
    CombatOpeners = {
        "In the Light's name.",
        "Shield up. Faith steady.",
        "You'll get a fair fight. More than you deserve.",
        "The Light sees you.",
        "Let's be done with this, cleanly.",
        "I'll pray for you after.",
        "Plate's polished. Let's dirty it.",
        "Stand and answer for it.",
        "For those who can't fight for themselves.",
        "Uther would have offered you mercy. I'm offering it once.",
        "The Light is patient. I'm less so.",
        "No sermon. Just justice.",
        "Armor on, head clear.",
        "Hold the line with me.",
        "Justice comes walking!",
    },
    -- Signature moves: a spell's own lines. Pull lines when you open a fight with it;
    -- big = true lets a cooldown speak mid-fight, midChance lets crowd control, interrupts
    -- and heals speak mid-fight now and then. .Player lines are for enemy players.
    SpellLines = {
        ["Judgement"] = {
            "Judged.",
            "The Light's verdict.",
            "Sentence passed.",
            "Weighed and found wanting.",
            "There's no appeal.",
            "Your account is settled.",
            "Guilty, plainly.",
            "That's what you've earned.",
            "The seal breaks. Feel it.",
            "Plain justice.",
            "Answer for it.",
            "No court needed!",
            Player = {
                "You're judged, {target}.",
                "The Light keeps records, {target}.",
                "No appeal for you, {target}.",
                "Guilty as charged.",
                "I don't need a trial for you.",
                "Your verdict's in, {target}.",
            },
        },
        ["Exorcism"] = {
            "Out. Back where you came from.",
            "Begone, foul thing.",
            "The Light burns what you are.",
            "There's no place for you here.",
            "Unclean. Unwelcome.",
            "Rot has no home in the Light.",
            "Your master can't shield you.",
            "Be cleansed.",
            "Leave this world.",
            "This land is consecrated. Go.",
            "Holy fire, for a hollow thing.",
            "Back to the dark!",
        },
        ["Hammer of Justice"] = {
            midChance = 0.3,
            "Down. Stay down.",
            "Hammer first, questions later.",
            "Sit and think about it.",
            "That rang a bell.",
            "You'll stand when I allow it.",
            "Kneel.",
            "Stunned. Good.",
            "Mind the hammer.",
            "Struck still.",
            "Justice is heavy!",
            Player = {
                "On your knees, {target}.",
                "Think on it, {target}.",
                "Struck down, {target}. Stay there.",
                "That's the Light's weight.",
                "No spells. No running.",
                "Now we talk, {target}.",
            },
        },
        ["Holy Light"] = {
            midChance = 0.15,
            "Light, mend them.",
            "Hold still. This will help.",
            "Breathe easy.",
            "There. Better.",
            "Rest your weight on me.",
            "The Light provides.",
            "Back on your feet.",
            "Steady. Healed.",
            "Close the wound.",
            "You'll fight on.",
            "A moment of grace.",
            "Up you get!",
        },
        ["Divine Shield"] = {
            big = true,
            "The Light holds me.",
            "Not a scratch. Not now.",
            "Strike all you like.",
            "Untouchable, for a moment.",
            "The Light won't let me fall here.",
            "Shielded. Breathe.",
            "Faith is armor.",
            "Try again later.",
        },
        ["Lay on Hands"] = {
            big = true,
            "Everything I have. Take it.",
            "Light, give them back.",
            "Not today. Not on my watch.",
            "All of it. For you.",
            "Stay with us.",
            "The Light does not let go.",
            "Your fight isn't over.",
            "Rise.",
        },
        ["Blessing of Protection"] = {
            midChance = 0.3,
            "Stay safe a moment.",
            "Under my protection.",
            "Nothing touches you now.",
            "Hands off. They're blessed.",
            "Breathe. You're covered.",
            "The Light holds you.",
            "No harm, for a little while.",
            "Get clear. I've got you.",
        },
        ["Hammer of Wrath"] = {
            midChance = 0.3,
            "End of your road.",
            "Last rites.",
            "Your time's done.",
            "Fall.",
            "The Light finishes what it starts.",
            "You've run out of road.",
            "Finished.",
            "Last words? No time.",
        },
        ["Consecration"] = {
            midChance = 0.3,
            "Holy ground.",
            "Stand on it if you dare.",
            "This ground is sanctified.",
            "The floor's spoken for.",
            "The Light burns at your feet.",
            "Step in. I'll wait.",
            "Blessed earth, cursed guests.",
            "Burn where you stand.",
        },
        ["Turn Undead"] = {
            midChance = 0.3,
            "Back to your grave.",
            "The dead should stay dead.",
            "Turn. Flee. Go.",
            "The Light hates what you are.",
            "Run, corpse.",
            "Not one step closer.",
            "Lie back down.",
            "Back, abomination.",
        },
    },
    pvpStyle = "Zealous Bulwark"
}
