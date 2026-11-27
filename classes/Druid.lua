--[[
    Monologue Data Module: Druid Class
    PURE DATA TABLE.

    Lines suit any race of Druid, Skyborne included, and speak of nature, the wild and
    the balance in general terms. SpellTriggers use Classic-era rank-specific IDs, verified
    in-game with /mono triggers. No later-expansion abilities. Signature moves cover every
    shape: caster (Moonfire, Wrath, Starfire, Entangling Roots, Faerie Fire), cat (Rake,
    Pounce, Ravage) and bear (Maul, Growl, Demoralizing Roar, Bash, Feral Charge, Faerie
    Fire (Feral)); context lines for players, elites, rares and groups are at the end.
--]]

MonologueEngine.Data.Classes["DRUID"] = {
    -- Class dialect: sits UNDERNEATH the race dialect. Where a race (or persona or profile)
    -- defines the same swap or list, theirs wins; this fills in everything they leave open,
    -- so a Druid of any race has some nature flavor in speech.
    Dialect = {
        -- Druid-specific vocabulary, chosen so it doesn't collide with a race's own words
        -- (where a race defines the same key, the race wins and the class swap never shows)
        wordSwaps = {
            ["animal"] = { "beast", "critter", "wild-kin" },
            ["animals"] = { "beasts", "critters", "wild-kin" },
            ["heal"] = { "mend", "tend", "soothe" },
            ["healing"] = { "mending", "tending", "soothing" },
            ["tree"] = { "elder oak", "ancient tree", "great tree" },
            ["seed"] = { "seedling", "sprout", "acorn" },
        },
        phraseSwaps = {
            ["shift forms"] = { "change shape", "take another form" },
            ["bear form"] = { "the bear's shape", "bear-shape" },
            ["cat form"] = { "the cat's shape", "cat-shape" },
            ["calm down"] = { "ease, friend", "settle, the wild is patient" },
            ["nature calls"] = { "the wild calls", "the grove calls" },
        },
    },
    SpellReactions = {
        Tier1_MajorCD = {
            "The wild answers.",
            "Let the forest remember this.",
            "Tooth and claw, as the wild intended.",
            "The old roots wake up.",
            "Now the grove fights with me!",
            "Every leaf in this place is listening.",
            "Moonglade, lend me your strength.",
            "Hold on. The wild's coming.",
            "Deep breath. Deeper roots.",
            "Not yet. The forest isn't done with me!",
        },
        Tier2_Routine = {
            "The wild takes what it's owed.",
            "Patience is for trees. Not me.",
            "Be still, little one.",
            "Roots and thorns.",
            "The wild bites.",
            "Back to the earth.",
            "Nature takes its course.",
            "Hold there a while.",
            "Easy. Nobody needs to rush.",
            "That's the forest's answer.",
        },
        Tier3_LowHP = {
            "The wild doesn't forsake its own.",
            "Even oaks bend in a storm.",
            "I need to mend before I break.",
            "Bark, hold together.",
            "Too many cuts. Need a moment.",
            "The grove will have to wait for me!",
            "Breathe. Grow back.",
            "Not falling here. Not in {zone}.",
            "Need to heal. Now!",
            "Bleeding sap and blood both.",
        }
    },
    SpellTriggers = {
        [29166] = "Tier1_MajorCD",  -- Innervate
        [22812] = "Tier1_MajorCD",  -- Barkskin
        [17116] = "Tier1_MajorCD",  -- Nature's Swiftness
        [740] = "Tier1_MajorCD",    -- Tranquility (rank 1)
        [8918] = "Tier1_MajorCD",   -- Tranquility (rank 2)
        [9862] = "Tier1_MajorCD",   -- Tranquility (rank 3)
        [9863] = "Tier1_MajorCD",   -- Tranquility (rank 4)
        [20484] = "Tier1_MajorCD",  -- Rebirth (rank 1)
        [20739] = "Tier1_MajorCD",  -- Rebirth (rank 2)
        [20742] = "Tier1_MajorCD",  -- Rebirth (rank 3)
        [20747] = "Tier1_MajorCD",  -- Rebirth (rank 4)
        [20748] = "Tier1_MajorCD",  -- Rebirth (rank 5)
        [22842] = "Tier1_MajorCD",  -- Frenzied Regeneration (rank 1)
        [22895] = "Tier1_MajorCD",  -- Frenzied Regeneration (rank 2)
        [22896] = "Tier1_MajorCD",  -- Frenzied Regeneration (rank 3)
        [5211] = "Tier2_Routine",   -- Bash (rank 1)
        [6798] = "Tier2_Routine",   -- Bash (rank 2)
        [8983] = "Tier2_Routine",   -- Bash (rank 3)
        [2637] = "Tier2_Routine",   -- Hibernate (rank 1)
        [18657] = "Tier2_Routine",  -- Hibernate (rank 2)
        [18658] = "Tier2_Routine",  -- Hibernate (rank 3)
        [339] = "Tier2_Routine",    -- Entangling Roots (rank 1)
        [1062] = "Tier2_Routine",   -- Entangling Roots (rank 2)
        [5195] = "Tier2_Routine",   -- Entangling Roots (rank 3)
        [5196] = "Tier2_Routine",   -- Entangling Roots (rank 4)
        [9852] = "Tier2_Routine",   -- Entangling Roots (rank 5)
        [9853] = "Tier2_Routine",   -- Entangling Roots (rank 6)
        [16979] = "Tier2_Routine",  -- Feral Charge
        [18562] = "Tier2_Routine",  -- Swiftmend
    },
    SpellNames = {
        [29166] = "Innervate", [22812] = "Barkskin", [17116] = "Nature's Swiftness",
        [740] = "Tranquility", [8918] = "Tranquility", [9862] = "Tranquility", [9863] = "Tranquility",
        [20484] = "Rebirth", [20739] = "Rebirth", [20742] = "Rebirth", [20747] = "Rebirth", [20748] = "Rebirth",
        [22842] = "Frenzied Regeneration", [22895] = "Frenzied Regeneration", [22896] = "Frenzied Regeneration",
        [5211] = "Bash", [6798] = "Bash", [8983] = "Bash",
        [2637] = "Hibernate", [18657] = "Hibernate", [18658] = "Hibernate",
        [339] = "Entangling Roots", [1062] = "Entangling Roots", [5195] = "Entangling Roots",
        [5196] = "Entangling Roots", [9852] = "Entangling Roots", [9853] = "Entangling Roots",
        [16979] = "Feral Charge", [18562] = "Swiftmend",
    },
    -- Pull lines (see Engine:ResolvePullPool): SpellLines[<spell name>] is used when you pull
    -- or open with that spell; CombatOpeners otherwise. Each pool is drawn as a shuffled deck,
    -- so every line comes up once before any repeats. Keys are English spell names.
    CombatOpeners = {
        "The wild stirs against you.",
        "You've wandered too deep into the woods.",
        "Root and claw, then.",
        "The grove sends its regards.",
        "Balance has to be kept. Today, by me.",
        "You've trespassed long enough.",
        "The forest is watching. So am I.",
        "Thorn and fang, at your service.",
        "Let the wild decide.",
        "The seasons turn. So does your luck.",
        "The trees remember everything you've broken.",
        "You should have stayed on the road.",
        "Even the moss is against you.",
        "Bark, bite or moonlight. Pick one.",
        "I'd hoped it wouldn't come to this. It has.",
    },
    SpellLines = {
        ["Moonfire"] = {
            "The moon's found you.",
            "Silver light. Hold still in it.",
            "The moon sees you plainly.",
            "Burn a little. Then come closer.",
            "A mark from the night sky.",
            "There. Glowing like a lantern.",
            "Night falls on you early.",
            "The moon never misses its mark.",
            "Pale fire, from very far away.",
            "That sting? Moonlight.",
            "Starlight's cousin. Just as cold.",
            "Moon's out early tonight!",
        },
        ["Wrath"] = {
            "The grove is angry. So am I.",
            "Green fire from the old woods.",
            "The forest bites back.",
            "Nature doesn't forgive cut trees.",
            "Storm and leaf, both at once.",
            "This is what balance looks like.",
            "Felt that? The wild did.",
            "For every stump you left behind.",
            "The earth has a temper. Here it is.",
            "Thunder in the leaves!",
            "Sap and lightning.",
            "Mind the branches. They bite back!",
        },
        ["Rake"] = {
            "Claws out.",
            "Fresh scratches.",
            "From the long grass.",
            "Bleed a little. It slows you down.",
            "Quick, quiet, done.",
            "I play rough.",
            "Mind your ankles.",
            "Hunt's on!",
            "One swipe. Plenty more where that came from.",
            "Easy prey. Mostly.",
            "Too slow to see it coming.",
            "There. Now you'll remember me.",
        },
        ["Entangling Roots"] = {
            "Stay put.",
            "Roots, hold.",
            "The earth has you now.",
            "Going somewhere? No.",
            "The ground wants a word.",
            "Struggle all you like.",
            "Wait there. The forest insists.",
            "Tangled up, are we?",
            "Pull harder. It only tightens.",
            "Your feet belong to the forest now!",
            "The vines remember every trespasser.",
            "Grow where you stand.",
        },
        ["Starfire"] = {
            "The stars fall on you.",
            "Light from a long way up.",
            "A falling star, just for you.",
            "Look up. Too late.",
            "The sky has a long reach.",
            "The heaviest stone the sky owns.",
            "Starlight burns hotter than you'd think.",
            "That took a while to arrive. Worth it.",
            "The night sky sends its answer!",
            "Brace. It's coming down.",
            "Every star I've ever counted.",
            "Bright enough for you?",
        },
        ["Faerie Fire"] = {
            "No hiding now.",
            "Glowing, are we?",
            "The faeries have marked you.",
            "Lit up like a festival lantern.",
            "Can't slip into the shadows now.",
            "Marked by the fae.",
            "Easy to see you now.",
            "Glowing nicely!",
            "Go on, run. I'll see you anywhere.",
            "The wisps will keep an eye on you.",
            "Shine a while.",
            "Your hiding ends here.",
        },
        -- Bear form: the moves that open or steer a fight (Swipe stays filler, like Heroic
        -- Strike). Maul is the usual walk-up pull, so it carries the bear's pull lines.
        ["Maul"] = {
            "Fur, teeth and a bad temper.",
            "You shouldn't have woken me.",
            "Wrong den.",
            "Easy now. This will hurt.",
            "Big paws. Short patience.",
            "I don't knock.",
            "Stay under my paws.",
            "Should have kept walking.",
            "Heavy, isn't it?",
            "Teeth first. Talking after.",
            "Sorry. Hungry.",
        },
        ["Growl"] = {
            "Eyes on me.",
            "Over here. The big one.",
            "Leave them be. Deal with me.",
            "Me. Not them.",
            "Hear that? It's for you.",
            "I'm the one you want.",
            "Turn around.",
            "Pick on me instead.",
            "Never mind the healer. Mind me.",
            "Come here.",
            "Hear that? Come closer.",
        },
        ["Demoralizing Roar"] = {
            "Weak knees already?",
            "Hear the den speak.",
            "Lose your nerve. Go on.",
            "The whole forest heard that.",
            "Steady your hands. You can't.",
            "That's the wild saying no.",
            "Shaking? Good.",
            "Back, all of you!",
            "Feel smaller yet?",
            "Ears ringing? It gets worse.",
            "Every wolf in Ashenvale heard that.",
        },
        ["Bash"] = {
            "Down.",
            "Sit.",
            "Stay down a moment.",
            "That'll ring for a while.",
            "That spell can wait.",
            "No spells today.",
            "Mind the paw.",
            "Enough of that!",
            "Seeing stars?",
            "Quiet.",
            "Easy. Stay there.",
        },
        ["Feral Charge"] = {
            "Out of the way!",
            "Don't bother running.",
            "Make room.",
            "Brace yourself.",
            "All four paws. All at once.",
            "Clear the path!",
            "Hold there.",
            "No hiding behind the others.",
            "Too slow.",
            "Right in front of you now.",
            "Faster than I look.",
        },
        ["Faerie Fire (Feral)"] = {
            "Found you in the dark.",
            "Lit up. Easy to find.",
            "Come to me, then.",
            "Glow a while.",
            "No slipping off into the dark.",
            "Moonglade sends its light.",
            "The wisps found you.",
            "Marked. Now come here.",
            "I see you.",
            "You'll want to come closer.",
            "Shine. Then run, if you like.",
        },
        -- Cat form: the stealth openers (Rake above covers the open pull)
        ["Pounce"] = {
            "Surprise.",
            "From the grass.",
            "Never heard me, did you?",
            "Pinned.",
            "Hello from the long grass.",
            "Quiet as moss.",
            "Never heard my paws.",
            "Pinned.",
            "Hold still. Claws are busy.",
            "The tall grass had teeth.",
            "Patience pays.",
        },
        ["Ravage"] = {
            "Should have watched the shadows.",
            "Out of nowhere.",
            "Too late to turn.",
            "I waited. Then I didn't.",
            "Behind you, low and quiet.",
            "Not a sound, until now.",
            "Short hunt.",
            "Saw you a mile back.",
            "Teeth in the dark.",
            "Behind you. Always behind you.",
            "Hunting since dawn. You're the first catch.",
        },
    },
    pvpStyle = "Shapeshifting Skirmisher"
}

-- Context lines for the signature moves (used on a rare, an elite, an enemy player or in a
-- group; see Data.SpellContextLines in situations/Details.lua for the shared ones)
do
    local lines = MonologueEngine.Data.Classes["DRUID"].SpellLines
    -- Openers at range
    lines["Moonfire"].Player = {
        "The moon remembers your face, {target}.",
        "Moonlight for you, {target}. Don't waste it.",
        "This grove isn't yours to cross.",
        "Nowhere to hide from the sky, {target}.",
        "I'd turn back, if I were you.",
        "Silver suits you, {target}.",
    }
    lines["Moonfire"].Elite = {
        "Big {mob}. Steady, everyone.",
        "The moon will need help with this one.",
        "Careful. That {mob} hits back hard.",
        "Starting slow. It's a long fight.",
        "Keep it out of the trees.",
        "Pull it gently. It's in no hurry.",
    }
    lines["Moonfire"].Rare = {
        "Haven't seen a {mob} like you in years.",
        "A rare thing, under a rare moon.",
        "The grove will want to hear about this.",
        "Easy. Don't let this one slip away.",
        "Quiet now. Don't let it see us first.",
        "Moonlight on a {mob}. Doesn't happen often.",
    }
    lines["Moonfire"].Party = {
        "Marked it, {party}. Go when you're ready.",
        "Moon's on the {mob}. Your turn.",
        "My pull. Keep near, {party}.",
        "Lit it up. Keep it off the healer.",
        "Coming your way, {party}. Be ready.",
        "One moon on it. More if it runs.",
    }
    lines["Wrath"].Player = {
        "You've been cutting down my forest, {target}.",
        "The woods have a grudge with you.",
        "Go home, {target}. While you can.",
        "The grove sends a message, {target}.",
        "Wrong woods to start a fight in.",
        "The forest keeps score, {target}.",
    }
    lines["Wrath"].Elite = {
        "Big one. I'll whittle it down.",
        "That's a lot of bark to burn through.",
        "Keep it busy. I'll keep it hurting.",
        "Slow and steady with this {mob}.",
        "The forest's been waiting for something this size.",
        "Heavy {mob}. Keep your heads down.",
    }
    lines["Wrath"].Rare = {
        "Something old walks here.",
        "The wild's been hiding you a while, {mob}.",
        "Careful, everyone. This one's special.",
        "I'll tell the grove we met.",
        "A {mob} like this deserves a proper send-off.",
        "Easy. The rare ones bolt.",
    }
    lines["Wrath"].Party = {
        "Opening on the {mob}, {party}.",
        "Wait for it to come to us.",
        "Hit what I hit, {party}.",
        "Casting. Somebody catch it when it runs.",
        "Bringing it in. Mind the casters.",
        "Stay out of its reach, {party}. I'll keep it coming.",
    }
    -- Cat
    lines["Rake"].Player = {
        "Mind the claws, {target}.",
        "You never heard the grass move.",
        "Claws don't fight fair, {target}.",
        "Should have watched your back.",
        "I've followed you since the river.",
        "Didn't see me coming, did you?",
    }
    lines["Rake"].Elite = {
        "Bite and back off. Bite and back off.",
        "Big prey. Be patient.",
        "Never stand in front of a {mob}.",
        "Bleed it slow.",
        "This one's tougher than it looks.",
        "Patience. A {mob} tires eventually.",
    }
    lines["Rake"].Rare = {
        "Oh, you're a rare one.",
        "The hunt of the season.",
        "Quiet. Don't spook the {mob}.",
        "I've tracked you for days.",
        "Soft paws. Don't scare it off.",
        "A {mob}. I'll take the hide home.",
    }
    lines["Rake"].Party = {
        "I'll take its back, {party}.",
        "Keep it facing you. I'm behind it.",
        "Claws in. Somebody hold it still.",
        "Flanking, {party}.",
        "Behind it. Don't mind me.",
        "On its flank, {party}. Keep its eyes on you.",
    }
    -- Bear
    lines["Maul"].Player = {
        "You woke me, {target}. Bad idea.",
        "Hope you brought a healer.",
        "Big paws, {target}. Bigger temper.",
        "Stand still. This won't take long.",
        "That's the last door you kick in.",
        "Hibernation's over, {target}.",
    }
    lines["Maul"].Elite = {
        "I've got it. Stay behind me.",
        "Hit it from behind. I'll hold the front.",
        "Heavy {mob}. Good.",
        "Let it chew on me a while.",
        "Mine. Everyone else, behind.",
        "Big {mob}. I'm bigger.",
    }
    lines["Maul"].Rare = {
        "Something rare. And angry.",
        "Easy, old one. Easy.",
        "Stay back. This one's mine.",
        "Haven't fought a {mob} like you since spring.",
        "Old one. Let's see who's tougher.",
        "A {mob}. Hold still and let me look at you.",
    }
    lines["Maul"].Party = {
        "On me, {party}. I've got it.",
        "Let it hit me. That's what fur is for.",
        "Give me a moment to hold it, {party}.",
        "I'm in front. Hit it from behind.",
        "Holding it, {party}. Do your worst.",
        "Fur's thick. Take your time.",
    }
    -- Against enemy players
    lines["Feral Charge"].Player = {
        "Four legs beat two, {target}.",
        "I'm faster on four legs, {target}.",
        "Hold there. I'm almost on you.",
        "Closer, {target}. Much closer.",
        "Four paws, one direction, {target}.",
        "Thought you were safe back there?",
    }
    lines["Entangling Roots"].Player = {
        "Stay a while, {target}.",
        "The ground likes you, {target}.",
        "Pull all you like. The roots don't care.",
        "Rooted. Now talk.",
        "Stay. Good.",
        "The forest wants you to wait, {target}.",
    }
    lines["Bash"].Player = {
        "Flat on your back, {target}.",
        "No spells for you.",
        "Seeing stars, {target}?",
        "Hush, {target}.",
        "Stay on the ground, {target}.",
        "Quiet now, {target}.",
    }
end
