--[[
    Monologue Data Module: Hunter Class
    PURE DATA TABLE.

    Lines suit any race of Hunter and speak of the hunt, the quarry and the animal
    companion. SpellTriggers use Classic-era rank-specific IDs, verified in-game with
    /mono triggers. No Readiness or other later-expansion abilities.
--]]

MonologueEngine.Data.Classes["HUNTER"] = {
    -- Class dialect: sits UNDERNEATH the race dialect, so a race (or persona or profile) that
    -- defines the same swap or list wins. The words and phrases here are Hunter-specific
    -- (tracking, quarry, companions) so they rarely collide with a race's own vocabulary.
    Dialect = {
        wordSwaps = {
            ["track"] = { "scout", "trail", "stalk" },
            ["beast"] = { "quarry", "game", "prey" },
            ["pet"] = { "companion", "partner", "hunting partner" },
            ["pets"] = { "companions", "partners", "hunting partners" },
            ["arrow"] = { "shaft", "feathered shaft", "arrow" },
            ["shoot"] = { "loose", "fire", "let fly" },
            ["wilderness"] = { "the wild", "the wilds", "open country" },
        },
        phraseSwaps = {
            ["good shot"] = { "true aim", "a clean shot", "well loosed" },
            ["i see it"] = { "I have it in my sights", "quarry spotted" },
            ["stay close"] = { "keep to my trail", "stay on my heels" },
            ["be quiet"] = { "hush, you'll spook the game", "soft steps now" },
            ["call your pet"] = { "whistle for your companion", "send in your partner" },
            ["i'm tracking"] = { "I'm on the trail", "I've found the spoor" },
            ["aim for"] = { "mark the target", "take your aim at" },
        },
    },
    -- Tier1_MajorCD: the Battle Cry fallback (when a character has no BattleCry pool).
    -- Tier3_LowHP: said when your health drops low.
    SpellReactions = {
        Tier1_MajorCD = {
            "Loose everything!",
            "Every arrow, now.",
            "The hunt's on. All of it.",
            "Quiver's full. Not for long.",
            "Together, beast. Now!",
            "No more stalking. Finish it.",
            "Open season!",
            "Fast and true.",
        },
        Tier3_LowHP = {
            "Back off. I need room to shoot.",
            "Too close. Far too close.",
            "I can't shoot what's in my face!",
            "Bleeding. Keep it off me a moment.",
            "Need a heal. My beast can't tie bandages.",
            "Breathe. Draw. Breathe.",
            "Hold them, friend. Just a moment.",
            "Getting cut up out here.",
            "Should have set a trap first.",
            "Not like this. Not in the open.",
        },
    },
    SpellTriggers = {
        [3045] = "Tier1_MajorCD",   -- Rapid Fire
        [19574] = "Tier1_MajorCD",  -- Bestial Wrath
        [19263] = "Tier1_MajorCD",  -- Deterrence
        [5384] = "Tier1_MajorCD",   -- Feign Death
        [19577] = "Tier1_MajorCD",  -- Intimidation
        [1499] = "Tier2_Routine",   -- Freezing Trap (rank 1)
        [14310] = "Tier2_Routine",  -- Freezing Trap (rank 2)
        [14311] = "Tier2_Routine",  -- Freezing Trap (rank 3)
        [19503] = "Tier2_Routine",  -- Scatter Shot
        [5116] = "Tier2_Routine",   -- Concussive Shot
        [19386] = "Tier2_Routine",  -- Wyvern Sting (rank 1)
        [24132] = "Tier2_Routine",  -- Wyvern Sting (rank 2)
        [24133] = "Tier2_Routine",  -- Wyvern Sting (rank 3)
        [781] = "Tier2_Routine",    -- Disengage (rank 1)
        [14272] = "Tier2_Routine",  -- Disengage (rank 2)
        [14273] = "Tier2_Routine",  -- Disengage (rank 3)
    },
    SpellNames = {
        [3045] = "Rapid Fire", [19574] = "Bestial Wrath", [19263] = "Deterrence",
        [5384] = "Feign Death", [19577] = "Intimidation",
        [1499] = "Freezing Trap", [14310] = "Freezing Trap", [14311] = "Freezing Trap",
        [19503] = "Scatter Shot", [5116] = "Concussive Shot",
        [19386] = "Wyvern Sting", [24132] = "Wyvern Sting", [24133] = "Wyvern Sting",
        [781] = "Disengage", [14272] = "Disengage", [14273] = "Disengage",
    },
    CombatOpeners = {
        "Downwind. Good.",
        "Been tracking you since the river.",
        "Easy now. Don't spook it.",
        "Wind's right. Light's right.",
        "Sights on you.",
        "Fresh tracks, fresh quarry.",
        "Steady. Let it come.",
        "Range is my friend. Stay out there.",
        "One more for the skinning knife.",
        "You left a trail a blind man could follow.",
        "Patience first. Then the arrow.",
        "Quiet, beast. Wait for it.",
        "Right where the tracks said you'd be.",
        "Mind the trap line.",
        "Good hunting today!",
    },
    -- Signature moves: a spell's own lines. Pull lines when you open a fight with it;
    -- big = true lets a cooldown speak mid-fight, midChance lets crowd control, interrupts
    -- and heals speak mid-fight now and then. .Player lines are for enemy players.
    SpellLines = {
        ["Aimed Shot"] = {
            "Hold your breath. There.",
            "Took my time with that one.",
            "Not a twitch. Good.",
            "Right through the gap.",
            "Long way off. Not far enough.",
            "Exhale. Loose.",
            "Worth the wait.",
            "Feathers in, quarry down.",
            "I had you before you saw me.",
            "Steady hands, clear eyes.",
            "Best part of the hunt, that.",
            "Now that's a shot!",
            Player = {
                "I had you lined up for a while, {target}.",
                "You should have kept to cover.",
                "The wind's on my side today, {target}.",
                "Out of range? Not quite.",
                "Keep running. It helps my aim.",
                "That one had your name on it, {target}.",
            },
        },
        ["Concussive Shot"] = {
            "No running off.",
            "Slow down. We're not done.",
            "That'll take the spring out of your legs.",
            "Heavy feet now.",
            "You're not going anywhere quickly.",
            "Easy. Let it limp.",
            "My beast will catch you now.",
            "Hobbled. Good.",
            "Stay in range.",
            "Bit sluggish, are we?",
            "Can't outrun the second shot.",
            "Not today, quick feet!",
            Player = {
                "Limp home, {target}.",
                "No running from me, {target}.",
                "Heavy legs, {target}? That was me.",
                "My beast is faster than you now.",
                "Easy pace. I've got time.",
                "Not getting away that easily.",
            },
        },
        ["Serpent Sting"] = {
            "A little venom for the road.",
            "That'll sour your blood.",
            "Scorpid venom. Works every time.",
            "Let it work.",
            "Slow and sure.",
            "You'll feel that tomorrow. If there is one.",
            "Fangs aren't just for the beast.",
            "Ticks away nicely.",
            "Poisoned. Now we wait.",
            "Should've stayed in the brush.",
            "The sting does the walking.",
            "Burns, doesn't it?",
        },
        ["Arcane Shot"] = {
            "Quick one.",
            "Snap shot.",
            "Didn't even draw fully.",
            "Fast enough.",
            "A spark off the string.",
            "Light on the string.",
            "Had to be quick.",
            "Just to get your attention.",
            "Look up.",
            "Look this way.",
            "That's for staring.",
            "Fast, not fancy!",
        },
        ["Scatter Shot"] = {
            midChance = 0.3,
            "Sit tight a moment.",
            "Dazed? Good. Stay that way.",
            "Back you go. Keep your distance.",
            "Spin around a bit.",
            "That buys me some room.",
            "Stagger. I'll wait.",
            "Too close. Fixing that.",
            "Shake your head all you like.",
            "Pause there.",
            "Some space, finally!",
            Player = {
                "You came too close, {target}.",
                "Room to work. Thanks, {target}.",
                "Dizzy, {target}? Stay that way.",
                "Back off. I like you at range.",
                "Thought you had me cornered?",
                "Count to four, {target}.",
            },
        },
        ["Freezing Trap"] = {
            midChance = 0.3,
            "Trap's set.",
            "Step on it. Go on.",
            "Cold steel in the grass.",
            "Mind your feet.",
            "Waiting under the leaves.",
            "One step too many.",
            "Iced and waiting.",
            "That's for whoever comes first.",
            "Laid it where you'll walk.",
            "The trap line's ready.",
        },
        ["Wyvern Sting"] = {
            midChance = 0.3,
            "Down for a nap.",
            "Goodnight, for a little while.",
            "Wyvern venom. Heavy stuff.",
            "Drowsy? Lie down.",
            "Nap time. I'll be right here.",
            "Eyes getting heavy?",
            "Rest. You'll need it.",
            "Dream of something nice.",
        },
        ["Rapid Fire"] = {
            big = true,
            "Quiver, don't fail me now.",
            "Fast as I can draw.",
            "Every arrow I've got.",
            "The string's singing now.",
            "Faster. Faster.",
            "Hands, keep up.",
            "Empty the quiver!",
            "No breaks. Keep loosing.",
        },
        ["Bestial Wrath"] = {
            big = true,
            "Let it out, beast.",
            "Off the leash!",
            "Go. Don't stop for anything.",
            "Show them your teeth.",
            "Nothing holds you now.",
            "Run them down, partner.",
            "Wild and angry. Good.",
            "Go on. I'll keep up.",
        },
    },
    -- Your pet (situations/Moments.lua explains the keys): {target} is its name
    Moments = {
        PetSummon = {
            "Here, {target}. Good to see you.",
            "Come on, {target}. There's hunting to do.",
            "Who's ready? You are.",
            "Nose to the ground.",
            "Stay close. Watch my back.",
            "Hungry? Me too.",
            "There's my good beast.",
            "We hunt together. Always.",
            "Did you miss me, {target}?",
            "Ears up. Something's out there.",
        },
        PetDown = {
            "No. {target}, stay with me.",
            "Easy, {target}. I'll get you back on your feet.",
            "They hurt my companion. Mistake.",
            "Not my beast. Not today.",
            "Hold on. I'm coming.",
            "I'll make them pay for that, {target}.",
            "Rest. I'll finish this.",
            "You fought well, {target}.",
            "That was my partner you just killed.",
            "Don't go far. I'll bring you back.",
        },
    },
    pvpStyle = "Patient Marksman"
}
