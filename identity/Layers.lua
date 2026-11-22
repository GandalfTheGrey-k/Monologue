--[[
    Monologue Data Module: Layer pools for the Variety Engine
    Loaded after Identity.lua and Builder.lua. Adds the trigger kinds the cross-layer mixer
    draws from, so every identity layer can speak in every moment:
        Combat  pull lines           LowHP  dropping low in a fight
        Kill    a kill (after combat) Loot   opening loot          Idle  out-of-combat chatter
    plus Flavor (word swaps) for allegiances, upbringings and traits, the
    hometown "roots" lines and the Character Anchor lines ({oath}, {nemesis}, {catchphrase}).

    Flavor = { wordSwaps = { ["word"] = "swap" or {variants} } }
        Applied to about 30% of lines (one layer per line) at Full Dialect or Light Flavor.

    Follow VOICE_GUIDE.md: specific, in-world, mostly calm.
--]]

local Data = MonologueEngine.Data
local function Extend(target, pools)
    if type(target) ~= "table" then return end
    for kind, lines in pairs(pools) do target[kind] = lines end
end

---------------------------------------------------------------------------
-- Traits: Combat, LowHP, Kill, Loot, Idle + Flavor
---------------------------------------------------------------------------

local T = Data.Traits
Extend(T.TavernWarm, {
    Combat = { "Come on then, let's have it.", "Right, who's first?", "I'll be telling this one tonight.", "Mind you don't spill anything." },
    LowHP = { "Ow. That'll cost someone a round.", "Still standing. Barely.", "Someone pour me a drink after this." },
    Kill = { "And down they go. Cheers.", "That's one for the tavern tale.", "Easy now. Rest." },
    Loot = { "Ooh, a little something for the tab.", "Drinks money!" },
    Idle = { "I could go for a song right about now.", "Wonder who's at the inn tonight.", "Good company makes a long road shorter." },
    Flavor = { wordSwaps = { ["drink"] = { "pint", "round" }, ["friends"] = "pals" } },
})
Extend(T.OathBound, {
    Combat = { "By my oath, you'll not pass.", "I stand where I swore to stand.", "Duty calls. I answer.", "Steel and honor." },
    LowHP = { "An oath doesn't break with bones.", "Still sworn. Still standing.", "Not yet. I've a promise to keep." },
    Kill = { "Duty done.", "As sworn.", "It's finished. Rest." },
    Loot = { "For the cause, not for me.", "Spoils go where they're needed." },
    Idle = { "A promise is a weight worth carrying.", "I renew my vow every morning.", "Keep your word. Even when it's hard." },
    Flavor = { wordSwaps = { ["promise"] = "vow", ["job"] = "duty" } },
})
Extend(T.Cynical, {
    Combat = { "Oh good. Another one.", "This'll end well, I'm sure.", "Fine. Let's get it over with.", "Nobody's paying me enough for this." },
    LowHP = { "Well, this is going splendidly.", "Lovely. Bleeding again.", "If I die, someone write something rude on my grave." },
    Kill = { "Yes, yes, very heroic.", "One down. Infinity to go.", "Thrilling." },
    Loot = { "Junk. As expected.", "At least it's not nothing. Barely." },
    Idle = { "Heroes. Always someone else's job.", "Another day, another errand.", "Ever notice the reward never covers repairs?" },
    Flavor = { wordSwaps = { ["great"] = "fine", ["hero"] = "errand-runner", ["heroes"] = "errand-runners" } },
})
Extend(T.PlagueHardened, {
    Combat = { "Quick and clean. No time for mercy.", "I've seen worse. Much worse.", "Let's get this over with before it spreads.", "Breathe through your mouth." },
    LowHP = { "Not dying here. Not like this.", "Hurts. Doesn't matter.", "Patch it later. Fight now." },
    Kill = { "Make sure it stays down.", "Done. Check the body.", "Burn it if you can." },
    Loot = { "Wash your hands after touching that.", "Check it for rot first." },
    Idle = { "Every quiet day is a gift.", "I count the living. It's a short list.", "Don't drink from wells you don't know." },
    Flavor = { wordSwaps = { ["sick"] = "plagued", ["dead"] = "fallen" } },
})
Extend(T.Stoic, {
    Combat = { "Begin.", "Steady.", "Now.", "So be it." },
    LowHP = { "It's nothing.", "Hold.", "Pain passes." },
    Kill = { "Done.", "Enough.", "Rest." },
    Loot = { "Useful.", "Take it." },
    Idle = { "Quiet is good.", "Breathe. Wait.", "Patience." },
    Flavor = { wordSwaps = { ["really"] = "truly", ["very"] = "quite" } },
})
Extend(T.HotBlooded, {
    Combat = { "Come here and say that to my face!", "I've been waiting all day for this!", "You picked a bad day.", "Let's go! Now!" },
    LowHP = { "That all you've got?", "Now I'm angry.", "You'll pay for that!" },
    Kill = { "HA! Stay down!", "Who's next?", "Again!" },
    Loot = { "Mine now!", "Ha! Spoils!" },
    Idle = { "I'm bored. Someone pick a fight.", "My blood's up and nothing to hit.", "Waiting makes me itch." },
    Flavor = { wordSwaps = { ["angry"] = "furious", ["fight"] = "brawl" } },
})

---------------------------------------------------------------------------
-- Allegiances: LowHP, Kill, Loot, Idle + Flavor
---------------------------------------------------------------------------

local A = Data.Allegiances
Extend(A.ScarletCrusade, {
    LowHP = { "The Light sustains me.", "Wounds are tests of faith." },
    Kill = { "Purged.", "Another stain cleansed." },
    Loot = { "Tithe for the Crusade." },
    Idle = { "Hearthglen's bells should be ringing now.", "Pray, then sharpen your blade." },
    Flavor = { wordSwaps = { ["undead"] = "unclean", ["sin"] = "heresy" } },
})
Extend(A.Defias, {
    LowHP = { "Westfall bled worse.", "Not going down for Stormwind." },
    Kill = { "Another debt collected.", "Put it on the crown's tab." },
    Loot = { "Wages, finally." },
    Idle = { "The nobles still haven't paid.", "Moonbrook was home once. It will be again." },
    Flavor = { wordSwaps = { ["guard"] = "watch-dog", ["guards"] = "watch-dogs", ["noble"] = "silk-coat", ["nobles"] = "silk-coats" } },
})
Extend(A.ArgentDawn, {
    LowHP = { "Hope holds me up.", "Not yet. The Dawn needs me." },
    Kill = { "Rest now. Truly rest.", "One less horror." },
    Loot = { "Light's Hope could use this." },
    Idle = { "Light's Hope Chapel feels far away tonight.", "Every soul saved matters." },
    Flavor = { wordSwaps = { ["undead"] = "lost", ["hope"] = "dawn" } },
})
Extend(A.SI7, {
    LowHP = { "Compromised. Still operational.", "Note to self: duck." },
    Kill = { "Target neutralized.", "Clean. Nobody saw a thing." },
    Loot = { "Evidence. Bagged." },
    Idle = { "Report's due to Shaw by nightfall.", "Everyone's a suspect. Even you." },
    Flavor = { wordSwaps = { ["enemy"] = "target", ["enemies"] = "targets", ["plan"] = "operation" } },
})
Extend(A.ExplorersLeague, {
    LowHP = { "Must survive. Must publish.", "Not dying before the paper's done." },
    Kill = { "Write that down.", "Fascinating specimen. Was." },
    Loot = { "Ooh. Is that Titan-forged?" },
    Idle = { "The Hall of Explorers needs new exhibits.", "Every rock has a story." },
    Flavor = { wordSwaps = { ["old"] = "ancient", ["thing"] = "artifact" } },
})
Extend(A.CenarionCircle, {
    LowHP = { "The land will heal me.", "Roots hold. So do I." },
    Kill = { "Return to the earth.", "Balance, restored." },
    Loot = { "Nature provides." },
    Idle = { "Listen. The trees are talking.", "Moonglade calls me home soon." },
    Flavor = { wordSwaps = { ["forest"] = "grove", ["world"] = "land" } },
})
Extend(A.Steamwheedle, {
    LowHP = { "This is costing me money.", "Bad investment, this fight." },
    Kill = { "Profitable.", "That's a write-off." },
    Loot = { "Inventory acquired." },
    Idle = { "Time is money, and I'm wasting both.", "Prices in Booty Bay are a crime." },
    Flavor = { wordSwaps = { ["gold"] = "profit", ["friend"] = "customer", ["friends"] = "customers" } },
})
Extend(A.Bloodsail, {
    LowHP = { "Just a scratch, matey.", "Not sinking yet." },
    Kill = { "Feed 'em to the sharks.", "Another for the plank." },
    Loot = { "Plunder!" },
    Idle = { "Miss the sway of a deck.", "Land's too still." },
    Flavor = { wordSwaps = { ["gold"] = "doubloons", ["money"] = "plunder", ["friend"] = "matey" } },
})
Extend(A.ThoriumBrotherhood, {
    LowHP = { "Cracked, not broken.", "Thorium holds." },
    Kill = { "Hammered flat.", "Good forging." },
    Loot = { "Ore for the forge." },
    Idle = { "The forge at Thorium Point burns day and night.", "Free hands make better steel." },
    Flavor = { wordSwaps = { ["work"] = "smithing", ["strong"] = "tempered" } },
})
Extend(A.HordeWarCouncil, {
    LowHP = { "Blood for the Horde. Not all of it mine.", "I fall only when the Warchief says." },
    Kill = { "For the Horde.", "Victory. As ordered." },
    Loot = { "Supplies for the war." },
    Idle = { "Orgrimmar's walls need more guards.", "The War-Council expects reports." },
    Flavor = { wordSwaps = { ["fight"] = "battle", ["win"] = "conquer" } },
})

---------------------------------------------------------------------------
-- Upbringings: LowHP, Kill, Loot + Flavor
---------------------------------------------------------------------------

local U = Data.Upbringings
Extend(U.Scourge, {
    LowHP = { "Survived the plague. I'll survive this." }, Kill = { "Stay dead." }, Loot = { "Check it for plague first." },
    Flavor = { wordSwaps = { ["dead"] = "fallen" } },
})
Extend(U.Tavern, {
    LowHP = { "Took worse in the cellar brawls." }, Kill = { "Last orders, mate." }, Loot = { "Pocket money!" },
    Flavor = { wordSwaps = { ["money"] = "coin", ["friend"] = "mate" } },
})
Extend(U.Forge, {
    LowHP = { "Bent, not broken." }, Kill = { "Quenched." }, Loot = { "Hm. Decent metal." },
    Flavor = { wordSwaps = { ["strong"] = "tempered", ["weak"] = "brittle", ["plan"] = "blueprint" } },
})
Extend(U.Watch, {
    LowHP = { "Wounded. Still on post." }, Kill = { "Target down. Next." }, Loot = { "Confiscated." },
    Flavor = { wordSwaps = { ["attack"] = "engage", ["fight"] = "skirmish" } },
})
Extend(U.Road, {
    LowHP = { "Road's taken more from me than this." }, Kill = { "Clear road ahead." }, Loot = { "Something to trade at the next stop." },
    Flavor = { wordSwaps = { ["home"] = "camp", ["city"] = "walls" } },
})
Extend(U.Magic, {
    LowHP = { "My wards are fraying." }, Kill = { "The omen was right." }, Loot = { "This hums. Interesting." },
    Flavor = { wordSwaps = { ["feeling"] = "omen", ["strange"] = "uncanny" } },
})

---------------------------------------------------------------------------
-- Professions: Combat, LowHP, Kill
---------------------------------------------------------------------------

local P = Data.Professions
local professionExtra = {
    Blacksmithing = { Combat = { "Let's test this edge.", "Hit it like the anvil." }, LowHP = { "Dented. Need the forge." }, Kill = { "Clean strike. Good steel." } },
    Mining = { Combat = { "Swing like a pick. Steady.", "Harder than stone? Doubt it." }, LowHP = { "Cave-ins hurt worse." }, Kill = { "Struck rock bottom." } },
    Alchemy = { Combat = { "Potion's ready if I need it.", "Volatile. Like me." }, LowHP = { "Where's that healing draught?" }, Kill = { "Reaction complete." } },
    Herbalism = { Combat = { "Stay off my flowers.", "Thorns have nothing on me." }, LowHP = { "Need some peacebloom." }, Kill = { "Back to the soil." } },
    Engineering = { Combat = { "Let's see if this explodes.", "Calibrating. Done." }, LowHP = { "Something's sparking. Probably me." }, Kill = { "Malfunction: theirs." } },
    Leatherworking = { Combat = { "Good hide on this one.", "Tough skin. Tougher blade." }, LowHP = { "Armor's torn. So am I." }, Kill = { "That hide's mine." } },
    Skinning = { Combat = { "Knife's ready.", "Don't ruin the pelt." }, LowHP = { "I'm the one being skinned." }, Kill = { "Now for the skinning." } },
    Tailoring = { Combat = { "Mind the robes.", "I'll stitch you up. Badly." }, LowHP = { "Torn seams everywhere." }, Kill = { "Neatly done." } },
    Enchanting = { Combat = { "Feel that hum?", "Runes are glowing." }, LowHP = { "Enchantments failing." }, Kill = { "Disenchanted." } },
    Cooking = { Combat = { "Dinner, or a fight? Both.", "You'd go well with onions." }, LowHP = { "Need a hearty stew." }, Kill = { "Into the pot." } },
    Fishing = { Combat = { "Bigger than most of my catches.", "Hooked." }, LowHP = { "Should've stayed by the water." }, Kill = { "Landed one." } },
    FirstAid = { Combat = { "Bandages ready.", "Try not to need me." }, LowHP = { "Bandage. Now." }, Kill = { "No bandage for you." } },
    Scribe = { Combat = { "This goes in the journal.", "Noting your weak spots." }, LowHP = { "Ink and blood. Same color, near enough." }, Kill = { "Chapter closed." } },
    Sellsword = { Combat = { "Paid to do this. Mostly.", "Protecting the cargo." }, LowHP = { "Hazard pay. I'm owed." }, Kill = { "Job's done." } },
}
for key, pools in pairs(professionExtra) do Extend(P[key], pools) end

---------------------------------------------------------------------------
-- Clans: LowHP, Kill, Loot
---------------------------------------------------------------------------

local clanExtra = {
    Dwarf = {
        Bronzebeard = { LowHP = { "Bronzebeards bend. They don't break." }, Kill = { "Another for Ironforge." }, Loot = { "Somethin' for the vault." } },
        Wildhammer = { LowHP = { "Me gryphon's seen me worse." }, Kill = { "Down like a stone from the Aerie." }, Loot = { "Gryphon feed money." } },
        DarkIron = { LowHP = { "Fire's still in me." }, Kill = { "Shadowforge taught me that." }, Loot = { "Good metal. Better than Thaurissan's." } },
        Clanless = { LowHP = { "No clan to carry me. I'll carry meself." }, Kill = { "Nobody's grudge but mine." }, Loot = { "Finders keepers." } },
    },
    Orc = {
        Frostwolf = { LowHP = { "The cold made me harder than this." }, Kill = { "For Durotan." }, Loot = { "For the clan's fires." } },
        Warsong = { LowHP = { "Grom bled more and kept fighting." }, Kill = { "The Warsong sings again." }, Loot = { "Spoils for the war-band." } },
        ShatteredHand = { LowHP = { "Pain is old friend." }, Kill = { "Cut clean." }, Loot = { "Take what you can use." } },
        Blackrock = { LowHP = { "Blackrock iron doesn't break." }, Kill = { "Old fury, fed." }, Loot = { "The clan takes its share." } },
        Dragonmaw = { LowHP = { "I've been burned by worse." }, Kill = { "Broken, like a dragon." }, Loot = { "Fuel for the fire." } },
    },
    Troll = {
        Darkspear = { LowHP = { "Da loa not done with me, mon." }, Kill = { "Darkspear win again." }, Loot = { "Somethin' for da shrine." } },
        Revantusk = { LowHP = { "Revantusk don't fall easy." }, Kill = { "One less for da Hinterlands." }, Loot = { "Trade dis back home." } },
        Zandalari = { LowHP = { "Old blood heal fast, mon." }, Kill = { "Da empire remember." }, Loot = { "Fit for a temple." } },
    },
    Tauren = {
        Bloodhoof = { LowHP = { "The herd stands. So do I." }, Kill = { "Rest in the Earth Mother's arms." }, Loot = { "For the village." } },
        Runetotem = { LowHP = { "The land lends me strength." }, Kill = { "The balance is kept." }, Loot = { "The spirits allow it." } },
        Grimtotem = { LowHP = { "Exiles endure." }, Kill = { "Magatha would have done worse." }, Loot = { "An exile takes what he finds." } },
    },
    NightElf = {
        Darnassian = { LowHP = { "Elune, give me strength." }, Kill = { "For Teldrassil." }, Loot = { "For the temple." } },
        Sentinel = { LowHP = { "The watch holds. Wounded or not." }, Kill = { "Threat removed." }, Loot = { "Supplies for the outposts." } },
        Highborne = { LowHP = { "My wards are thin today." }, Kill = { "The old magic wins again." }, Loot = { "Arcane residue. Promising." } },
    },
    Human = {
        Stormwind = { LowHP = { "For Stormwind. I'm still up." }, Kill = { "Long live the king." }, Loot = { "Something for the treasury." } },
        Lordaeron = { LowHP = { "I survived Lordaeron. I'll survive this." }, Kill = { "For the fallen kingdom." }, Loot = { "Lordaeron would have used this." } },
        KulTiran = { LowHP = { "Rough seas. Still afloat." }, Kill = { "Sunk." }, Loot = { "Salvage!" } },
        Stromgarde = { LowHP = { "Stromgarde stands. So do I." }, Kill = { "For Arathor." }, Loot = { "For the keep's coffers." } },
        Dalaran = { LowHP = { "Exiles learn to keep going." }, Kill = { "A small victory for the homeless." }, Loot = { "Every coin brings Dalaran closer." } },
    },
    Gnome = {
        Gnomeregan = { LowHP = { "Minor damage! Mostly!" }, Kill = { "For Gnomeregan!" }, Loot = { "Spare parts!" } },
        Leper = { LowHP = { "Glowing a bit brighter now." }, Kill = { "Irradiated." }, Loot = { "Shiny. Also mildly radioactive." } },
    },
    Scourge = {
        Fallen = { LowHP = { "I've been dead. This is nothing." }, Kill = { "Welcome to death." }, Loot = { "The dead don't need it." } },
        Apothecary = { LowHP = { "Need a tonic. Quickly." }, Kill = { "Experiment concluded." }, Loot = { "Samples, excellent." } },
    },
    Skyborne = {
        Cloudreach = { LowHP = { "Grounded, not beaten." }, Kill = { "Struck from above." }, Loot = { "For the Sky-Guard." } },
        Lowland = { LowHP = { "Feet planted. Still here." }, Kill = { "Back to the dirt." }, Loot = { "Good earthly things." } },
        StormKindred = { LowHP = { "The storm's still in me." }, Kill = { "Thunderstruck." }, Loot = { "Charged with static. Nice." } },
    },
}
for race, clans in pairs(clanExtra) do
    local pack = Data.Races[race]
    if type(pack) == "table" and type(pack.Clans) == "table" then
        for _, clan in ipairs(pack.Clans) do
            if clans[clan.key] then Extend(clan, clans[clan.key]) end
        end
    end
end

---------------------------------------------------------------------------
-- Roots: hometown lines for every kind (only used when a hometown is set)
---------------------------------------------------------------------------

Data.HometownKindLines = {
    Combat = { "For {hometown}.", "{hometown} raised me tougher than you.", "This one's for the folk back in {hometown}.", "They'll hear about this in {hometown}." },
    LowHP = { "I'm getting back to {hometown}. Alive.", "Not dying this far from {hometown}." },
    Kill = { "{hometown} would be proud.", "One more tale for {hometown}.", "Back home, they'd buy me a drink for that." },
    Loot = { "Something to bring back to {hometown}." },
    Idle = { "Wonder what the weather's like in {hometown}.", "Folk in {hometown} would laugh at this place.", "I'll write home to {hometown} soon." },
}

---------------------------------------------------------------------------
-- Character Anchors: oath, nemesis, catchphrase (only used when set)
---------------------------------------------------------------------------

Data.AnchorLines = {
    Oath = {
        Combat = { "I swore {oath}. I keep my word.", "Remember my oath: {oath}.", "Every blow is for my oath." },
        LowHP = { "I swore {oath}. I can't fall here.", "Not before I fulfill my oath." },
        Kill = { "One step closer. I swore {oath}.", "For my oath." },
        Idle = { "I swore {oath}. I think about it every day.", "An oath like mine doesn't rest." },
    },
    Nemesis = {
        Combat = { "Pretend you're {nemesis}. It helps.", "Practice for when I find {nemesis}.", "{nemesis} fights better than you." },
        LowHP = { "I'm not dying before I see {nemesis} fall.", "{nemesis} would laugh. Not today." },
        Kill = { "Someday that'll be {nemesis}.", "One step closer to {nemesis}." },
        Idle = { "Somewhere, {nemesis} is still breathing. Not for long.", "I dreamed of {nemesis} again." },
    },
    Catchphrase = {
        Combat = { "{catchphrase}", "As I always say: {catchphrase}" },
        LowHP = { "{catchphrase} Even now." },
        Kill = { "{catchphrase}", "What did I say? {catchphrase}" },
        Idle = { "{catchphrase}" },
    },
}
