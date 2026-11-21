--[[
    Monologue Data Module: Azeroth Identity
    PURE DATA TABLE. Chosen on the My Voice tab (Identity section) and saved per character in
    CustomVoice.allegiance / .hometown / .profession. Clans live in each race pack (Clans).

    Allegiances[key] = {
        name,
        Combat  = { lines },   -- join pull lines now and then (with racial and clan openers)
        Greet   = { lines },   -- join friendly greetings now and then
        Hostile = { [situationKey] = { lines } },
                               -- reactions to a specific foe; keys are situation keys from the
                               -- Situations system (Undead, Vs_Warlock, Defias, VsAlliance, ...)
    }
    Professions[key] = { name, skillLine, Idle, City, Loot, Repair }
        skillLine is the profession's skill line ID, used by auto-detection.
    Hometowns = { { region, list = { { name, zone, sub, fallen, continent } } } }
        Matched when you enter `sub` (a subzone, or an instance named like it) or, without
        `sub`, the zone. fallen = a lost or ruined home (reclamation lines instead of
        homecoming). A custom hometown matches a zone or subzone of the same name.
    HometownLines = { Homecoming, Reclaim, Homesick }

    Tokens: {target}, {hometown}, {clan}, {allegiance}, {profession}, {mob}.
    Classic canon. Follow VOICE_GUIDE.md: specific, in-world, mostly calm.
--]]

local Data = MonologueEngine.Data
Data.Allegiances = Data.Allegiances or {}
Data.Professions = Data.Professions or {}

local A = Data.Allegiances
local P = Data.Professions

---------------------------------------------------------------------------
-- Allegiances / Orders (display order)
---------------------------------------------------------------------------

Data.AllegianceOrder = {
    "Independent", "ScarletCrusade", "Defias", "ArgentDawn", "SI7", "ExplorersLeague",
    "CenarionCircle", "Steamwheedle", "Bloodsail", "ThoriumBrotherhood", "HordeWarCouncil",
}

A.Independent = { name = "Independent" }

A.ScarletCrusade = {
    name = "Scarlet Crusade",
    Combat = {
        "The Light purges all.",
        "For Lordaeron. For the Crusade.",
        "Mograine would expect nothing less.",
        "Every sinner falls the same way.",
        "Repent, then. Or don't.",
        "The Crusade does not negotiate.",
    },
    Greet = {
        "The Light keep you, {target}. Stay pure.",
        "Well met. Have you been tested for the plague?",
        "The Crusade remembers its friends.",
        "Walk in the Light, {target}. Always.",
        "Hearthglen sends its blessings.",
    },
    Hostile = {
        Undead = {
            "Abomination. Back to the grave.",
            "The plague ends with you.",
            "Every corpse I put down is a prayer answered.",
        },
        Vs_Warlock = {
            "Fel-tainted heretic.",
            "Your demons won't save you from the Light.",
        },
        VsRace_Scourge = {
            "A walking corpse that thinks it's free. Disgusting.",
        },
    },
}

A.Defias = {
    name = "Defias Brotherhood",
    Combat = {
        "For the Brotherhood.",
        "Westfall never forgets.",
        "Stormwind owes us. You'll do for a down payment.",
        "Mask on. Blade out.",
        "VanCleef sends his regards.",
        "No wages, no mercy.",
    },
    Greet = {
        "Keep your voice down, {target}. Walls have ears.",
        "Friend of the Brotherhood? Good. Don't say it too loud.",
        "Westfall says hello. Quietly.",
        "Seen any nobles about? Just asking.",
        "We look after our own, {target}.",
    },
    Hostile = {
        Stormwind = {
            "Stormwind's lackeys. Paid with our wages.",
            "The crown's dog. Heel.",
            "Tell the House of Nobles we said hello.",
        },
        Defias = {
            "Easy, brother. It's me.",
            "Wrong mask to swing at, friend.",
        },
    },
}

A.ArgentDawn = {
    name = "Argent Dawn",
    Combat = {
        "For the Dawn.",
        "The Scourge took enough.",
        "Light's Hope stands. So do I.",
        "Steady. Mercy after, if there's time.",
        "The Argent Dawn holds this line.",
        "Hope is a weapon too.",
    },
    Greet = {
        "The Dawn greets you, {target}.",
        "Light's Hope is always open to you.",
        "Well met. We need every good soul we can find.",
        "Stay safe out there, {target}. The plague spreads.",
        "Good to see you whole.",
    },
    Hostile = {
        Undead = {
            "Rest now. You've suffered enough.",
            "Another Scourge soul to set free.",
            "The Dawn ends your torment.",
        },
        Scarlet = {
            "Zealots. You hurt more than you help.",
            "The Scarlets have lost their way.",
        },
        Demon = {
            "No place for you in this world.",
        },
    },
}

A.SI7 = {
    name = "Stormwind Crown / SI:7",
    Combat = {
        "For the Crown.",
        "SI:7 sends its regards.",
        "Quietly now.",
        "Shaw wants this done clean.",
        "You never saw me.",
        "Orders are orders.",
    },
    Greet = {
        "{target}. Good. I'll note you in my report.",
        "The Crown thanks you for your service.",
        "Nothing to see here. Just passing through.",
        "Well met. Keep your eyes open for Defias.",
        "Stormwind's watching. Kindly.",
    },
    Hostile = {
        Defias = {
            "Defias scum. The Crown wants you.",
            "VanCleef's lot. Not for long.",
            "Bandanas and bad decisions.",
        },
        Syndicate = {
            "Syndicate. Alterac's leftovers.",
            "You're on SI:7's list.",
        },
        Vs_Rogue = {
            "Amateur. I'll show you how it's done.",
        },
    },
}

A.ExplorersLeague = {
    name = "Explorers' League / Mountaineers",
    Combat = {
        "For the League!",
        "Mind the artifacts. They're priceless.",
        "Ironforge Mountaineers. Hold the pass.",
        "Brann would want this documented.",
        "Science and steel.",
        "Careful. There might be a relic underneath you.",
    },
    Greet = {
        "Ho, {target}! Found anything interesting lately?",
        "The League's always hiring.",
        "Well met. Seen any old ruins?",
        "Fancy an expedition, {target}?",
        "The Hall of Explorers sends its regards.",
    },
    Hostile = {
        DarkIron = {
            "Dark Irons. Diggin' up what isn't theirs.",
            "Thaurissan's lot. Hands off the relics.",
        },
        Trogg = {
            "Troggs. Uldaman's pests.",
            "Back to the dig site with you.",
        },
        Mechanical = {
            "Titan-forged. Fascinating. Pity.",
            "Careful. That's priceless engineering.",
        },
    },
}

A.CenarionCircle = {
    name = "Cenarion Circle / Earthen Ring",
    Combat = {
        "The balance must hold.",
        "For the land.",
        "Nature defends itself. Through me.",
        "Cenarius sees all.",
        "The elements stand with me.",
        "Root and storm.",
    },
    Greet = {
        "Peace upon you, {target}.",
        "The land welcomes you.",
        "Walk gently, {target}.",
        "Moonglade greets you, friend.",
        "The spirits speak well of you.",
    },
    Hostile = {
        Satyr = {
            "Corruption walks on hooves.",
            "The forest will be clean of you.",
        },
        Demon = {
            "Fel taint. Begone.",
        },
        Elemental = {
            "Rest, spirit. You've been twisted.",
            "The elements are upset. I'll calm this one.",
        },
        Venture = {
            "Stop cutting down my forest.",
        },
    },
}

A.Steamwheedle = {
    name = "Steamwheedle Cartel / Booty Bay Freebooter",
    Combat = {
        "Time is money, friend.",
        "Nothing personal. Just business.",
        "This one's on the house.",
        "The Cartel protects its interests.",
        "Bad for business, you are.",
        "Profit before peace. Usually.",
    },
    Greet = {
        "{target}! Good to see a paying customer.",
        "Booty Bay greets you. Mind your purse.",
        "Business good? Mine is.",
        "Well met. Need anything? Everything's for sale.",
        "Steamwheedle Cartel, at your service.",
    },
    Hostile = {
        Bloodsail = {
            "Bloodsail scum. Booty Bay's tired of you.",
            "Pirates. Bad for trade.",
            "The Baron's paying good coin for you.",
        },
        Venture = {
            "Venture Company. Undercutting everyone.",
            "Rival firm. Hostile takeover.",
        },
    },
}

A.Bloodsail = {
    name = "Bloodsail Buccaneers",
    Combat = {
        "For the Bloodsail!",
        "Revilgaz's lackeys can't save you.",
        "Every pirate takes what they want.",
        "Hoist the colors.",
        "Plunder first. Questions never.",
        "Fleet Master Firallon won't miss you.",
    },
    Greet = {
        "Arr, {target}. Keep your purse close.",
        "Friend of the Bloodsail? Aye, maybe.",
        "Need a ship? We've plenty. Stolen, mind.",
        "Well met, matey.",
        "Fair winds and full holds, {target}.",
    },
    Hostile = {
        BootyBay = {
            "Booty Bay's goons. Old business.",
            "Baron's bruisers. Come on.",
            "Revilgaz pays you too little.",
        },
        KulTiras = {
            "Proudmoore's sailors. Sink 'em.",
        },
        Bloodsail = {
            "Careful, mate. Same crew.",
        },
    },
}

A.ThoriumBrotherhood = {
    name = "Thorium Brotherhood",
    Combat = {
        "For the Brotherhood. And free dwarves.",
        "Thorium doesn't bend.",
        "Lokhtos sends his regards.",
        "Forged in the Searing Gorge.",
        "Hammer and anvil.",
        "No masters. Not anymore.",
    },
    Greet = {
        "{target}. The Brotherhood welcomes skilled hands.",
        "Well met. Need something forged?",
        "Thorium Point remembers its friends.",
        "Good to see you, {target}. Bring ore next time.",
        "The Brotherhood's forge is always hot.",
    },
    Hostile = {
        DarkIron = {
            "Thaurissan's slaves. We left that life.",
            "Dark Irons. The Brotherhood remembers.",
            "Back to your master, if he'll have you.",
        },
        Elemental = {
            "Fire spirit. Ragnaros' leftovers.",
            "Good ore in your heart, I'll wager.",
        },
    },
}

A.HordeWarCouncil = {
    name = "Horde War-Council / Kor'kron Vanguard",
    Combat = {
        "For the Horde!",
        "Kor'kron, with me.",
        "The Warchief's will.",
        "Orgrimmar stands behind me.",
        "Strength. Honor. Victory.",
        "The War-Council expects results.",
    },
    Greet = {
        "Throm-ka, {target}. The Horde is strong with you.",
        "Strength and honor, comrade.",
        "The Warchief knows your name.",
        "Well met. Report to Grommash Hold when you can.",
        "Lok'tar, {target}.",
    },
    Hostile = {
        VsAlliance = {
            "Alliance dog.",
            "The Warchief will hear of this victory.",
            "For every orc they chained.",
        },
        Centaur = {
            "Kolkar raiders. The War-Council wants them gone.",
            "Centaur. The Barrens will be cleaner.",
        },
        Quilboar = {
            "Razormane filth.",
        },
    },
}

---------------------------------------------------------------------------
-- Professions / trades (skillLine = profession skill line ID, for auto-detection)
---------------------------------------------------------------------------

Data.ProfessionOrder = {
    "Blacksmithing", "Mining", "Alchemy", "Herbalism", "Engineering", "Leatherworking", "Skinning",
    "Tailoring", "Enchanting", "Cooking", "Fishing", "FirstAid", "Scribe", "Sellsword",
}

P.Blacksmithing = {
    name = "Blacksmithing", skillLine = 164,
    Idle = { "My arms still ring from the anvil.", "Good steel takes patience.",
             "This blade needs a fresh edge.", "I could forge something better than this." },
    City = { "Any decent forge in this town?", "I can smell the smithy from here." },
    Loot = { "Hm. Poor quenching on this.", "Iron. Could use it." },
    Repair = { "Shoddy work. I'd have done it better myself." },
}

P.Mining = {
    name = "Mining", skillLine = 186,
    Idle = { "Copper's cheap these days.", "Rock dust in my lungs again.",
             "Saw a vein back there. Might go back.", "My pick needs a new handle." },
    City = { "Who's buying ore here?", "The smelter should be around here somewhere." },
    Loot = { "Ore. Good.", "That'll smelt nicely." },
    Repair = { "Picks break. Armour breaks. Everything breaks." },
}

P.Alchemy = {
    name = "Alchemy", skillLine = 171,
    Idle = { "I need more vials.", "Peacebloom and silverleaf. Always.",
             "That last batch smelled wrong.", "My fingers are stained green again." },
    City = { "There's a decent alchemy shop here, I hope.", "Need to restock on reagents." },
    Loot = { "Hm. Might brew something from this.", "Useful. Into the satchel." },
    Repair = { "A potion would have been cheaper than this repair." },
}

P.Herbalism = {
    name = "Herbalism", skillLine = 182,
    Idle = { "Smells like mageroyal out here.", "There's a briarthorn patch somewhere near.",
             "Fresh herbs, best herbs.", "My bags smell like a garden." },
    City = { "No herbs worth picking in a city.", "Who's buying flowers in this place?" },
    Loot = { "Herbs. Let me sort them.", "Good leaves on this one." },
    Repair = { "Herbalists don't need much armour. Still costs a fortune." },
}

P.Engineering = {
    name = "Engineering", skillLine = 202,
    Idle = { "I should recalibrate my goggles.", "Need more blasting powder.",
             "Something's rattling in my bag. Probably fine.", "Gnomish or goblin? Hard choice." },
    City = { "Any engineering supplies around here?", "This place could use some better gadgets." },
    Loot = { "Gears. Useful.", "Hm, scrap metal. Perfect." },
    Repair = { "I could fix this myself, given a spanner and an hour." },
}

P.Leatherworking = {
    name = "Leatherworking", skillLine = 165,
    Idle = { "These straps need oiling.", "Good leather keeps you alive.",
             "I could stitch a better jerkin than this.", "Smell of tanning never leaves you." },
    City = { "Who sells salt for curing hides here?", "There's a tanner in town, surely." },
    Loot = { "Decent hide.", "That'll tan nicely." },
    Repair = { "Leather doesn't break. It wears. Still pay for it." },
}

P.Skinning = {
    name = "Skinning", skillLine = 393,
    Idle = { "My knife's dull.", "I'll skin anything that stays still.",
             "Fur's worth good coin this season.", "Messy work, skinning." },
    City = { "Who's buying hides in this town?", "Need to sell off these pelts." },
    Loot = { "Nice pelt.", "Thick hide on this one." },
    Repair = { "Sharpen the knife. Mend the boots. Pay the smith." },
}

P.Tailoring = {
    name = "Tailoring", skillLine = 197,
    Idle = { "This seam's coming loose.", "Linen, wool, silk. Always need more.",
             "I could sew a better robe than this.", "Thread in my pockets again." },
    City = { "Who sells good thread here?", "I need more bolts of cloth." },
    Loot = { "Cloth. Always need cloth.", "Good weave on this." },
    Repair = { "Mending cloth would be cheaper than this." },
}

P.Enchanting = {
    name = "Enchanting", skillLine = 333,
    Idle = { "My rod's humming again.", "Need more dust.",
             "Everything glows a little if you look right.", "Magic in the seams of the world." },
    City = { "Any enchanting supplies here?", "I could use a new runed rod." },
    Loot = { "Hm. I could disenchant this.", "There's magic in this one." },
    Repair = { "An enchantment would have kept this from breaking." },
}

P.Cooking = {
    name = "Cooking", skillLine = 185,
    Idle = { "I'm hungry. I'm always hungry.", "Could go for a good stew.",
             "I know a recipe for this kind of weather.", "Need more spices." },
    City = { "Smells like someone's baking.", "Any good inns here?" },
    Loot = { "Meat. Dinner's sorted.", "Good for the pot." },
    Repair = { "Spent my food money on repairs again." },
}

P.Fishing = {
    name = "Fishing", skillLine = 356,
    Idle = { "Good day for fishing.", "Wonder what's biting today.",
             "Patience. Fish teach it best.", "My line needs replacing." },
    City = { "Any good fishing spots near here?", "Who buys fish in this town?" },
    Loot = { "Ha. Fish.", "Not bad. Not bad at all." },
    Repair = { "Shoulda stayed by the water." },
}

P.FirstAid = {
    name = "First Aid", skillLine = 129,
    Idle = { "Need more linen for bandages.", "Keep still and you'll heal faster.",
             "Seen worse cuts than that.", "I'll patch you up after." },
    City = { "I should restock bandages.", "Healers here, I hope." },
    Loot = { "Cloth. Bandages later.", "Useful for wraps." },
    Repair = { "Armour mends easier than flesh." },
}

P.Scribe = {
    name = "Scribe / Cartographer",
    Idle = { "I should map this place.", "Ink's running low.",
             "That landmark isn't on any chart.", "Need to note that down." },
    City = { "There's a library here, I hope.", "Who sells good parchment in this town?" },
    Loot = { "A scroll. Let's see.", "Old writing on this." },
    Repair = { "Worth noting the cost of repairs in my ledger." },
}

P.Sellsword = {
    name = "Sellsword / Caravan Guard",
    Idle = { "No pay today. Bad sign.", "Caravan's late again.",
             "Keep your eyes on the road.", "Good job. Bad employer." },
    City = { "Anyone hiring guards?", "Good place to find work." },
    Loot = { "Payment, of a sort.", "Spoils. Fair enough." },
    Repair = { "Business expense. Should bill the client." },
}

---------------------------------------------------------------------------
-- Hometowns, grouped by region. continent = "EK", "Kalimdor" or "Zephras".
---------------------------------------------------------------------------

Data.Hometowns = {
    { region = "Eastern Kingdoms", list = {
        { name = "Stormwind City", zone = "Elwynn Forest", sub = "Stormwind City", continent = "EK" },
        { name = "Goldshire", zone = "Elwynn Forest", sub = "Goldshire", continent = "EK" },
        { name = "Moonbrook", zone = "Westfall", sub = "Moonbrook", fallen = true, continent = "EK" },
        { name = "Lakeshire", zone = "Redridge Mountains", sub = "Lakeshire", continent = "EK" },
        { name = "Darkshire", zone = "Duskwood", sub = "Darkshire", continent = "EK" },
        { name = "Ironforge", zone = "Dun Morogh", sub = "Ironforge", continent = "EK" },
        { name = "Kharanos", zone = "Dun Morogh", sub = "Kharanos", continent = "EK" },
        { name = "Gnomeregan", zone = "Dun Morogh", sub = "Gnomeregan", fallen = true, continent = "EK" },
        { name = "Menethil Harbor", zone = "Wetlands", sub = "Menethil Harbor", continent = "EK" },
        { name = "Aerie Peak", zone = "The Hinterlands", sub = "Aerie Peak", continent = "EK" },
        { name = "Southshore", zone = "Hillsbrad Foothills", sub = "Southshore", continent = "EK" },
        { name = "Stromgarde", zone = "Arathi Highlands", sub = "Stromgarde Keep", fallen = true, continent = "EK" },
        { name = "Lordaeron", zone = "Tirisfal Glades", sub = "Ruins of Lordaeron", fallen = true, continent = "EK" },
        { name = "Andorhal", zone = "Western Plaguelands", sub = "Andorhal", fallen = true, continent = "EK" },
        { name = "Caer Darrow", zone = "Western Plaguelands", sub = "Caer Darrow", fallen = true, continent = "EK" },
        { name = "Tyr's Hand", zone = "Eastern Plaguelands", sub = "Tyr's Hand", continent = "EK" },
        { name = "Dalaran", zone = "Alterac Mountains", sub = "Dalaran", fallen = true, continent = "EK" },
        { name = "Alterac", zone = "Alterac Mountains", sub = "Ruins of Alterac", fallen = true, continent = "EK" },
    } },
    { region = "Kalimdor & Skies", list = {
        { name = "Darnassus", zone = "Teldrassil", sub = "Darnassus", continent = "Kalimdor" },
        { name = "Dolanaar", zone = "Teldrassil", sub = "Dolanaar", continent = "Kalimdor" },
        { name = "Auberdine", zone = "Darkshore", sub = "Auberdine", continent = "Kalimdor" },
        { name = "Astranaar", zone = "Ashenvale", sub = "Astranaar", continent = "Kalimdor" },
        { name = "Theramore", zone = "Dustwallow Marsh", sub = "Theramore Isle", continent = "Kalimdor" },
        { name = "Nighthaven", zone = "Moonglade", sub = "Nighthaven", continent = "Kalimdor" },
        { name = "Zephras Isle", zone = "Zephras Isle", continent = "Zephras" },
    } },
    { region = "Horde Homelands", list = {
        { name = "Orgrimmar", zone = "Durotar", sub = "Orgrimmar", continent = "Kalimdor" },
        { name = "Razor Hill", zone = "Durotar", sub = "Razor Hill", continent = "Kalimdor" },
        { name = "Sen'jin Village", zone = "Durotar", sub = "Sen'jin Village", continent = "Kalimdor" },
        { name = "Thunder Bluff", zone = "Mulgore", sub = "Thunder Bluff", continent = "Kalimdor" },
        { name = "Bloodhoof Village", zone = "Mulgore", sub = "Bloodhoof Village", continent = "Kalimdor" },
        { name = "Undercity", zone = "Tirisfal Glades", sub = "Undercity", continent = "EK" },
        { name = "Brill", zone = "Tirisfal Glades", sub = "Brill", continent = "EK" },
        { name = "The Crossroads", zone = "The Barrens", sub = "The Crossroads", continent = "Kalimdor" },
        { name = "Tarren Mill", zone = "Hillsbrad Foothills", sub = "Tarren Mill", continent = "EK" },
        { name = "Hammerfall", zone = "Arathi Highlands", sub = "Hammerfall", continent = "EK" },
        { name = "Revantusk Village", zone = "The Hinterlands", sub = "Revantusk Village", continent = "EK" },
    } },
    { region = "Neutral Ports", list = {
        { name = "Booty Bay", zone = "Stranglethorn Vale", sub = "Booty Bay", continent = "EK" },
        { name = "Ratchet", zone = "The Barrens", sub = "Ratchet", continent = "Kalimdor" },
        { name = "Gadgetzan", zone = "Tanaris", sub = "Gadgetzan", continent = "Kalimdor" },
        { name = "Everlook", zone = "Winterspring", sub = "Everlook", continent = "Kalimdor" },
        { name = "Light's Hope Chapel", zone = "Eastern Plaguelands", sub = "Light's Hope Chapel", continent = "EK" },
        { name = "Cenarion Hold", zone = "Silithus", sub = "Cenarion Hold", continent = "Kalimdor" },
        { name = "Thorium Point", zone = "Searing Gorge", sub = "Thorium Point", continent = "EK" },
    } },
}

-- Capitals and ports that count as "a city visit" for profession lines
Data.CityZones = {
    ["Stormwind City"] = true, ["Ironforge"] = true, ["Darnassus"] = true, ["Orgrimmar"] = true,
    ["Thunder Bluff"] = true, ["Undercity"] = true, ["Booty Bay"] = true, ["Gadgetzan"] = true,
    ["Ratchet"] = true, ["Everlook"] = true, ["Theramore Isle"] = true,
}

Data.HometownLines = {
    -- Entering your hometown
    Homecoming = {
        "{hometown}. Good to be back.",
        "Home. Same as I left it.",
        "Smells like {hometown}. Smells right.",
        "Been too long since I walked these streets.",
        "I know every stone in this place.",
        "Back in {hometown}. Somebody put the kettle on.",
        "Feels smaller than I remember. Or I got bigger.",
        "Still standing. Good.",
        "There's the old road. I walked it as a child.",
        "{hometown} hasn't changed. Neither have I, much.",
    },
    -- Entering a fallen or lost hometown
    Reclaim = {
        "{hometown}. What's left of it.",
        "I'll take it back someday. All of it.",
        "This was home. Look at it now.",
        "Somebody will pay for what happened to {hometown}.",
        "I remember when these walls stood.",
        "Every ruin here has a name I knew.",
        "Not like this. It wasn't always like this.",
        "{hometown} deserves better. I'll see to it.",
        "Hard to look at. Harder to leave.",
        "One day {hometown} will be ours again.",
    },
    -- Far from home (another continent)
    Homesick = {
        "Long way from {hometown}.",
        "Wonder what they're eating in {hometown} tonight.",
        "Miss home some days. Today's one of them.",
        "Nothing here smells like {hometown}.",
        "Strange land. Strange stars.",
        "Someday I'll go back to {hometown}. Someday.",
        "The road keeps getting longer.",
        "Bet nobody in {hometown} has seen a place like this.",
        "I'd trade this view for {hometown} in a heartbeat.",
        "Far from home. Not lost, though.",
    },
}
