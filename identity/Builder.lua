--[[
    Monologue Data Module: Character Builder (upbringing, trait, party banter, world moments)
    PURE DATA TABLE. Chosen on the My Voice tab and saved per character in
    CustomVoice.upbringing / .trait.

    Upbringings[key] = {
        name, blurb,
        Combat  = { lines },  -- join pull lines now and then (with race/clan/allegiance openers)
        Idle    = { lines },  -- idle chatter on an out-of-combat ability press
        Hostile = { [situationKey] = { lines } },  -- reactions to a specific foe (Situations keys)
    }
    Traits[key] = {
        name, blurb,
        Rescue  = { lines },  -- a party member with Monologue drops below 25% health; {target} = them
        Victory = { lines },  -- first voice after an elite or boss kill in a group
        Reply   = { lines },  -- answering a party member's victory line; {target} = them
    }
    Friction = { { mine = { field = value }, theirs = { field = value }, lines = { ... } } }
        Post-combat side-eye toward a party member. Fields: allegiance, clan, upbringing, trait
        (theirs: only known when they run Monologue), class (classFile), race (raceFile).
        {target} = the party member.
    WorldMoments = { DungeonEnter, BattlegroundEnter, Inn, DurabilityLow, DurabilityBroken }

    Follow VOICE_GUIDE.md: specific, in-world, mostly calm. Classic canon.
--]]

local Data = MonologueEngine.Data

---------------------------------------------------------------------------
-- Upbringing / Defining Moment
---------------------------------------------------------------------------

Data.UpbringingOrder = { "Scourge", "Tavern", "Forge", "Watch", "Road", "Magic" }

Data.Upbringings = {
    Scourge = {
        name = "Survived the Scourge / Third War",
        blurb = "Haunted by the Plaguelands. Grim around the dead.",
        Combat = {
            "I've buried better than you.",
            "Saw a whole village rise once. You don't scare me.",
            "Quick and clean. The plague taught me that.",
            "Don't let it bite. Never let them bite.",
            "I stopped counting the dead in Andorhal.",
        },
        Idle = {
            "Still check my grain for plague. Every time.",
            "The smell of burning barns never leaves you.",
            "Some nights I still hear the bells of Stratholme.",
            "Can't sleep without a weapon in reach.",
        },
        Hostile = {
            Undead = {
                "I know your kind. I know how to finish it.",
                "Burn the body after. Always burn the body.",
                "You were someone once. Sorry.",
                "Not again. Never again.",
            },
        },
    },
    Tavern = {
        name = "Raised in the Tavern / Docks",
        blurb = "Street-smart, heavy slang, loves a brawl or a wager.",
        Combat = {
            "Two silver says you drop first.",
            "Bar fight rules. Anything goes.",
            "I've had rougher nights at closing time.",
            "Come on then, I'll buy the first round of bruises.",
            "Mind the glassware, love.",
        },
        Idle = {
            "Could murder a pint.",
            "Anyone fancy a game of dice?",
            "Dock rats taught me more than any tutor.",
            "I know a barkeep in every port. Most owe me.",
        },
        Hostile = {
            Bloodsail = {
                "Seen your lot in every dockside tavern. Never paid their tab.",
                "Pirates. Drink like fish, fight like it too.",
            },
            Ogre = {
                "Bigger than the bouncer at the Pig and Whistle.",
                "Seen ogres thrown out of better places than this.",
            },
        },
    },
    Forge = {
        name = "Apprenticed in a Forge / Workshop",
        blurb = "Pragmatic. Judges everything by its craftsmanship.",
        Combat = {
            "Shoddy armor. This won't take long.",
            "Good steel never lies.",
            "Hit it where the rivets are weak.",
            "Measure twice. Strike once.",
            "I've hammered harder metal than you.",
        },
        Idle = {
            "That blade's balance is off. Drives me mad.",
            "Bad weld on that gate back there.",
            "Hands miss the hammer when they're idle.",
            "Everything's built badly these days.",
        },
        Hostile = {
            Mechanical = {
                "Lovely work. Shame to scrap it.",
                "Whoever riveted you was rushing.",
            },
            DarkIron = {
                "Dark Iron forging. Grudgingly impressive.",
                "Good metal, bad masters.",
            },
        },
    },
    Watch = {
        name = "Trained by the Watch / Militia",
        blurb = "Disciplined. Tactical callouts. Watches the flanks.",
        Combat = {
            "Contact front. Engaging.",
            "Watch the flanks.",
            "Hold formation. Steady.",
            "On my mark. Now.",
            "Eyes up. More could be coming.",
        },
        Idle = {
            "Check your corners. Always.",
            "Patrol routes don't walk themselves.",
            "Sergeant would have my hide for this posture.",
            "Keep your gear ready. Trouble doesn't knock.",
        },
        Hostile = {
            Defias = {
                "Defias. Westfall's in a state because of you.",
                "Wanted posters had your face, I'd wager.",
            },
            Elite = {
                "Big one. Spread out, hit from the sides.",
                "Don't take it head on. Work it down.",
            },
        },
    },
    Road = {
        name = "Grew Up on the Open Road / Caravan",
        blurb = "Restless, well-travelled, skeptical of city folk.",
        Combat = {
            "Caravan raiders were tougher than you.",
            "Road's long. Let's not waste daylight.",
            "Fought off worse on the Gold Road.",
            "Keep moving. That's how you live.",
            "Out here, nobody comes to help.",
        },
        Idle = {
            "Too many walls around here. Can't breathe.",
            "City folk don't know what real dust tastes like.",
            "Wagon wheels sing better than any bard.",
            "Never stay in one place long. Bad luck.",
        },
        Hostile = {
            Centaur = {
                "Centaur raiders. Hit the caravans every season.",
                "Know your tricks. Seen them all on the road.",
            },
            Gnoll = {
                "Gnolls. Road pests.",
                "Riverpaw tried this on our wagons once.",
            },
        },
    },
    Magic = {
        name = "Touched by Magic / Ley-Lines",
        blurb = "Notices arcane wards, demons and strange omens.",
        Combat = {
            "The air's humming. Something's wrong here.",
            "I can feel the ley-lines shifting.",
            "Strange omen. Let's end this quickly.",
            "Magic pulls at me. I pull back.",
            "Wards here. Old ones.",
        },
        Idle = {
            "The ley-lines are restless today.",
            "Saw a strange light in the sky last night.",
            "There's a ward on that stone. Faded, but there.",
            "My fingertips tingle near old ruins.",
        },
        Hostile = {
            Demon = {
                "The Legion's stink. I can taste it.",
                "Fel magic. Twisted and sour.",
            },
            Elemental = {
                "Raw magic, given form. Careful.",
                "Bound spirit. Somebody summoned you badly.",
            },
        },
    },
}

---------------------------------------------------------------------------
-- Defining Trait (party banter)
---------------------------------------------------------------------------

Data.TraitOrder = { "TavernWarm", "OathBound", "Cynical", "PlagueHardened", "Stoic", "HotBlooded" }

Data.Traits = {
    TavernWarm = {
        name = "Tavern-Warm",
        blurb = "Friendly and loud. Cheers allies on.",
        Rescue = {
            "{target}! Hang on, I've got you!",
            "Up you get, {target}. Drinks are on me after.",
            "Not yet, {target}. Stay with us.",
            "Easy, {target}. We're right here.",
        },
        Victory = {
            "Ha! Drinks all round!",
            "Good work, all of you. First round's mine.",
            "That's a story for the tavern.",
            "Well fought. Who's thirsty?",
        },
        Reply = {
            "Hear, hear, {target}!",
            "I'll drink to that.",
            "Ha! Well said, {target}.",
        },
    },
    OathBound = {
        name = "Oath-Bound",
        blurb = "Duty first. Rallies allies.",
        Rescue = {
            "Hold on, {target}! I'm with you.",
            "Stand firm, {target}. We don't leave anyone.",
            "On me, {target}! Fall back to me!",
            "Not while I stand, {target}.",
        },
        Victory = {
            "Well fought. Duty done.",
            "The line held. Good.",
            "Victory. As sworn.",
            "Check your wounds. Then onward.",
        },
        Reply = {
            "Aye, {target}. Well fought.",
            "Honor to all of us.",
            "As you say, {target}.",
        },
    },
    Cynical = {
        name = "Cynical",
        blurb = "Dry and unimpressed. Gallows humor.",
        Rescue = {
            "{target}, if you die, I'm taking your boots.",
            "Try not to bleed on the loot, {target}.",
            "Healer! Or a shovel. Whichever's closer.",
            "{target}'s looking a bit dead. Just saying.",
        },
        Victory = {
            "Well. Nobody died. Imagine that.",
            "Great. Now who's carrying the loot?",
            "That was almost competent.",
            "I'll take my share in gold, thanks.",
        },
        Reply = {
            "Sure, {target}. Very inspiring.",
            "Don't get sentimental, {target}.",
            "If you say so.",
        },
    },
    PlagueHardened = {
        name = "Plague-Hardened",
        blurb = "Seen too much death to flinch.",
        Rescue = {
            "{target}, don't you dare die. I'm not burying you.",
            "Seen people survive worse, {target}. Not many.",
            "Stay breathing, {target}. Corpses get up around here.",
            "Not today, {target}. Not today.",
        },
        Victory = {
            "Done. Burn the bodies.",
            "Still breathing. That's the victory.",
            "Another day survived.",
            "Count heads. All here? Good.",
        },
        Reply = {
            "Aye, {target}. We lived.",
            "Good. Let's keep it that way.",
            "Survived again, {target}.",
        },
    },
    Stoic = {
        name = "Stoic",
        blurb = "Few words. Steady hands.",
        Rescue = {
            "{target}. Hold.",
            "Steady, {target}.",
            "Breathe, {target}.",
            "Fall back, {target}. I'll cover.",
        },
        Victory = {
            "Done.",
            "It's over.",
            "Good.",
            "Rest now.",
        },
        Reply = {
            "Agreed.",
            "Yes, {target}.",
            "Mm.",
        },
    },
    HotBlooded = {
        name = "Hot-Blooded",
        blurb = "Fiery and loud. Takes it personally.",
        Rescue = {
            "Nobody touches {target}! Get away from them!",
            "{target}! Who did that? Point me at them!",
            "Get up, {target}! We're not done!",
            "That's MY friend you're hitting!",
        },
        Victory = {
            "HA! Did you see that?",
            "That's what you get!",
            "Again! Bring me another!",
            "We crushed them!",
        },
        Reply = {
            "Yes! Well said, {target}!",
            "HA! Too right!",
            "Again, {target}! Let's go again!",
        },
    },
}

-- No trait chosen: plain, friendly party lines
Data.TraitDefault = {
    Rescue = {
        "Hang on, {target}!",
        "{target}, get back to us!",
        "Watch out, {target}!",
        "Heal {target}, quickly!",
        "Don't you fall on me, {target}.",
        "On my way, {target}. Hold.",
    },
    Victory = {
        "Good fight, everyone.",
        "Well done.",
        "That went well.",
        "Nice work, all.",
        "We did it. Catch your breath.",
        "Solid work, everyone.",
    },
    Reply = {
        "Agreed, {target}.",
        "Well fought, {target}.",
        "Aye.",
        "Couldn't have said it better, {target}.",
        "Fair enough, {target}.",
        "True.",
    },
}

---------------------------------------------------------------------------
-- Party friction: a quiet side-eye after combat
---------------------------------------------------------------------------

Data.Friction = {
    { mine = { allegiance = "ScarletCrusade" }, theirs = { class = "WARLOCK" }, lines = {
        "I'm watching you, {target}. And your little demon.",
        "When this is done, {target}, we'll talk about your spells.",
        "Fel magic in our group. The Light weeps.",
        "Keep your shards to yourself, {target}.",
        "The Light sees what you summon, {target}.",
    } },
    { mine = { allegiance = "ScarletCrusade" }, theirs = { race = "Scourge" }, lines = {
        "Don't stand so close, {target}. You smell like a crypt.",
        "A walking corpse in my party. Wonderful.",
        "One wrong move, {target}.",
        "Keep your hands where I can see them, corpse.",
        "I'll burn you if you twitch wrong, {target}.",
    } },
    { mine = { allegiance = "ArgentDawn" }, theirs = { allegiance = "ScarletCrusade" }, lines = {
        "Easy with the zeal, {target}. Not everyone's a heretic.",
        "Your Crusade burns villages, {target}. Remember that.",
        "We want the same thing, {target}. Mostly.",
        "Put the torch down, {target}. We're on the same side today.",
        "The Dawn doesn't burn its friends, {target}.",
    } },
    { mine = { allegiance = "ScarletCrusade" }, theirs = { allegiance = "ArgentDawn" }, lines = {
        "The Dawn is soft, {target}. Too soft.",
        "Mercy for the dead? Really, {target}?",
        "Your Dawn lets the plague live, {target}.",
        "Soft hearts get people killed, {target}.",
        "The Dawn talks. The Crusade acts.",
    } },
    { mine = { clan = "Bronzebeard" }, theirs = { clan = "DarkIron" }, lines = {
        "I'll be keepin' an eye on ye, {target}. Dark Iron.",
        "Ye fight well, {target}. For a Shadowforge lad.",
        "Don't get any ideas about me beard, {target}.",
        "Mind your manners, {target}. Ironforge is watching.",
        "I'll grant you one thing, {target}. You hit hard.",
    } },
    { mine = { clan = "DarkIron" }, theirs = { clan = "Bronzebeard" }, lines = {
        "Go on, {target}, say something about me clan.",
        "Bronzebeards. Always lookin' down their noses.",
        "I can feel ye glarin', {target}.",
        "Polish your beard elsewhere, {target}.",
        "I don't need Magni's blessing, {target}.",
    } },
    { mine = { clan = "Wildhammer" }, theirs = { clan = "Bronzebeard" }, lines = {
        "Ye'd fight better with some sky over ye, {target}.",
        "Bronzebeards. All roof, no wind.",
        "Ye'd not last a day on a gryphon, {target}.",
        "Come fly with us sometime, {target}. If you dare.",
        "Too much stone in your head, {target}.",
    } },
    { mine = { allegiance = "ThoriumBrotherhood" }, theirs = { clan = "DarkIron" }, lines = {
        "Left the Shadowforge too, {target}? Or still loyal?",
        "Free or not, {target}?",
        "We'll see where yer loyalty sits, {target}.",
        "The Brotherhood's open to the free, {target}.",
        "You left Thaurissan, {target}? Prove it.",
    } },
    { mine = { allegiance = "Defias" }, theirs = { allegiance = "SI7" }, lines = {
        "Spy. I can smell it on you, {target}.",
        "Not a word to Shaw, {target}.",
        "Watching my back, or watching me, {target}?",
        "I know your kind, {target}. You keep notes.",
        "Tell Shaw I said nothing, {target}.",
    } },
    { mine = { allegiance = "SI7" }, theirs = { allegiance = "Defias" }, lines = {
        "Your face is familiar, {target}. From a poster, maybe.",
        "I'll be writing about you, {target}.",
        "Interesting company you keep, {target}.",
        "Westfall's still looking for its stonemasons, {target}.",
        "Keep your mask off, {target}. It suits you.",
    } },
    { mine = { allegiance = "Steamwheedle" }, theirs = { allegiance = "Bloodsail" }, lines = {
        "Keep your hands off my purse, {target}.",
        "Booty Bay has a bounty on your crew, {target}.",
        "Pirates in my party. Bad for business.",
        "Revilgaz has your portrait, {target}.",
        "Pay your docking fees, {target}.",
    } },
    { mine = { allegiance = "Bloodsail" }, theirs = { allegiance = "Steamwheedle" }, lines = {
        "Goblin money, {target}. Always counting.",
        "Revilgaz's pet, are you, {target}?",
        "Your Baron owes my captain, {target}.",
        "Count your coins twice, {target}.",
        "Your Baron's ships sink like any other, {target}.",
    } },
    { mine = { upbringing = "Scourge" }, theirs = { race = "Scourge" }, lines = {
        "I've seen your kind rise before, {target}. Forgive the stare.",
        "Hard to look at you, {target}. Not your fault.",
        "You remind me of things I'd rather forget, {target}.",
        "I know you're not one of them, {target}. Still.",
        "Sorry, {target}. Old habits.",
    } },
    { mine = { upbringing = "Magic" }, theirs = { class = "WARLOCK" }, lines = {
        "Your magic feels wrong, {target}. Sour.",
        "Careful what you summon, {target}.",
        "The ley-lines flinch around you, {target}.",
        "Your shadows leave a mark, {target}.",
        "I can feel the fel on you, {target}.",
    } },
}

---------------------------------------------------------------------------
-- World moments (no per-zone files needed)
---------------------------------------------------------------------------

Data.WorldMoments = {
    -- Entering a 5-man dungeon
    DungeonEnter = {
        "Tight corridors. Watch for ambushes.",
        "Stay close. Down here, everything's an ambush.",
        "Smell that? Something lives down here.",
        "Torches up. Let's be careful.",
        "One room at a time.",
        "No running off alone in here.",
    },
    -- Entering a battleground
    BattlegroundEnter = {
        "Banners up. Let's take this field.",
        "Hold the flags. Watch the roads.",
        "Every banner counts.",
        "This ground's been fought over before.",
        "Stay with the group. Lone heroes die first.",
        "Here they come. Ready yourselves.",
    },
    -- Idle chatter while resting at an inn or in a city
    Inn = {
        "Warm fire, cold drink. Good.",
        "Bed's soft. I'll never leave.",
        "Who's buying the next round?",
        "Smells like stew. Good stew.",
        "Rest while you can.",
        "This innkeeper waters the ale. I can tell.",
    },
    -- Gear turning yellow
    DurabilityLow = {
        "My armor's starting to complain.",
        "Gear's wearing thin.",
        "Need a smith soon.",
        "This won't hold much longer.",
        "Rattling straps. Not a good sign.",
        "My armor's starting to look tired.",
    },
    -- Gear turning red (broken)
    DurabilityBroken = {
        "That's it. Something just broke.",
        "My gear's done. Need repairs now.",
        "Fighting in rags now. Lovely.",
        "Broken. Absolutely broken.",
        "Somebody find me a blacksmith.",
        "That's it. My gear's in pieces.",
    },
}
