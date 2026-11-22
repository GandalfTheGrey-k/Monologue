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
    SpellReactions = {
        Tier1_MajorCD = {
            "Loose the hounds of war!",
            "Every arrow finds its mark!",
            "Unleash the beast within!",
            "The hunt begins in earnest!",
            "Rapid fire! Duck!",
            "Together, my friend! Attack!",
            "The wild hunt begins!",
            "Release the beast!",
            "Volley! Cover me!",
        },
        Tier2_Routine = {
            "Straight and true!",
            "You're in my sights.",
            "Nowhere to run, quarry.",
            "Hold still!",
            "Got you.",
            "Steady aim.",
            "Another one for the trophy wall.",
            "Down range!",
        },
        Tier3_LowHP = {
            "A wounded hunter is still a hunter!",
            "Cover me, I need to fall back!",
            "I've been hunted before. I survive!",
            "My companion, to me!",
            "Fall back, regroup!",
            "Watch my back, boy!",
            "Need some distance!",
            "Not like this!",
        }
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
    -- Pull lines (see Engine:ResolvePullPool): SpellLines[<spell name>] is used when you pull
    -- or open with that spell; CombatOpeners otherwise. Each pool is drawn as a shuffled deck,
    -- so every line comes up once before any repeats. Keys are English spell names.
    CombatOpeners = {
        "Got you in my sights.",
        "The hunt begins!",
        "Steady... and loose!",
        "You won't outrun my arrows.",
        "Good boy, sic 'em!",
        "I've tracked you long enough.",
        "Hold still. It's kinder.",
        "Prey spotted!",
        "Bow's strung, quarry's marked.",
        "From range, with love.",
        "You're not the hunter here.",
        "Let's see how fast you are.",
        "Wind's right. Fire!",
        "My pet's been hungry all day.",
        "One shot, clean kill.",
    },
    SpellLines = {
        ["Arcane Shot"] = {
            "Arcane Shot!",
            "Right between the eyes!",
            "A shot of pure magic!",
            "Bullseye!",
            "Didn't see that one coming!",
            "Glowing arrow, heading your way!",
            "Fast and true!",
            "Aim, release, regret!",
            "Too quick to dodge!",
            "Sting of the arcane!",
            "Got you!",
            "Another one in the quiver for you!",
        },
        ["Serpent Sting"] = {
            "The serpent bites!",
            "Venom in the veins!",
            "Feel the sting!",
            "Poisoned!",
            "Slow and deadly!",
            "Here's a little venom!",
            "The snake's kiss!",
            "Let the poison work.",
            "Burning from the inside!",
            "A sting to remember!",
            "Not long now.",
            "Coiled and striking!",
        },
        ["Concussive Shot"] = {
            "Slow down!",
            "Not so fast!",
            "Stay right there!",
            "Going somewhere?",
            "Easy target now.",
            "That'll slow you.",
            "Steady, steady...",
            "Feet feel heavy?",
            "No running!",
            "Hold still for me.",
            "Pinned!",
            "Running is pointless.",
        },
        ["Aimed Shot"] = {
            "Steady... got it.",
            "Right on target.",
            "Perfect shot!",
            "One breath, one arrow.",
            "Bullseye!",
            "Patience pays.",
            "Lined up nicely.",
            "Aim true!",
            "Dead center!",
            "The wind is right.",
            "Clean shot!",
            "Couldn't miss that one.",
        },
    },
    pvpStyle = "Patient Marksman"
}
