--[[
    Monologue Data Module: Zone Lines
    PURE DATA TABLE.

    Lines written for a specific zone, used for world PvP when you clash with an enemy player
    there (first clashes and repeat-zone fights pick one of these half the time). Keys are
    the zone names GetRealZoneText() returns on an English client. Every race shares these,
    so keep them faction-neutral; a race pack or character profile can add its own with
    ZoneLines = { ["Stranglethorn Vale"] = { ... } }, which replaces the list for that zone.

    Follow VOICE_GUIDE.md: specific, in-world, mostly calm. {target} = the enemy player.
--]]

local Z = MonologueEngine.Data.Zones

Z["Stranglethorn Vale"] = {
    "Even the raptors here have better manners.",
    "Too hot for this. Let's be quick about it.",
    "The jungle eats the slow ones, {target}.",
    "Nesingwary would want your head for his wall.",
    "Every vine in this place hides a fight.",
    "Booty Bay pays for ears. Just saying.",
    "I came for the tigers. You'll do.",
    "Somewhere a goblin is taking bets on this.",
}

Z["Hillsbrad Foothills"] = {
    "Southshore and Tarren Mill. Some feuds never cool.",
    "Same hills, same fight, every season.",
    "The road between the towns is soaked through.",
    "Smell that? Farmland and old grudges.",
    "Hillsbrad never forgets a face. Neither do I.",
    "I only came for the peaches.",
}

Z["Alterac Mountains"] = {
    "Cold enough to crack teeth. Let's make it quick.",
    "Ogres in the ruins, and now you.",
    "Watch your footing. These slopes take the careless.",
    "Snow's going to cover whichever of us loses.",
    "Nobody comes up here by accident.",
    "Old Alterac's ghosts are watching. Give them a show.",
}

Z["Arathi Highlands"] = {
    "Stromgarde's walls have seen worse than us.",
    "Raptors, ogres, trolls. And you.",
    "The highlands are wide. You still found me.",
    "The farms fell long ago. We're just more noise.",
    "Wind's coming off the bay. Smells like rain.",
    "Arathor was born on ground like this. Mind it.",
}

Z["Ashenvale"] = {
    "Mind the trees. They hold grudges here.",
    "The forest is listening, {target}.",
    "Every clearing in Ashenvale has a body in it.",
    "Even the moonwells look nervous.",
    "Quiet woods. Not for long.",
    "The furbolgs will have whatever's left of you.",
}

Z["The Barrens"] = {
    "Hot, flat, and full of zhevra. And you.",
    "Long road to the Crossroads. Longer if you're dead.",
    "Dust in my teeth again.",
    "The Barrens chat is louder than this fight.",
    "Not even the plainstriders stop here.",
    "Kolkar watching from the ridge. Give them a show.",
}

Z["Duskwood"] = {
    "Darkshire's watch would want a word with you.",
    "Wolves, worgen stories, and now you.",
    "It's always night here. Suits the work.",
    "Raven Hill's got room for one more.",
    "Mind the graves. They don't stay still in Duskwood.",
    "Even the spiders are watching this one.",
}

Z["Redridge Mountains"] = {
    "Lakeshire's been through enough. Let's keep it short.",
    "Gnolls on the hills and you on the road.",
    "Pretty lake. Shame about the company.",
    "The bridge has seen worse. Barely.",
    "Redridge burns easy. So do people.",
    "Blackrock orcs in the hills. They'll enjoy this.",
}

Z["Thousand Needles"] = {
    "Long way down from up here.",
    "The centaur ride past this every day. Never stop.",
    "Dust and salt and heat.",
    "Every spire here has a fall worth remembering.",
    "Not much shade. Not much mercy either.",
    "The Shimmering Flats racers would charge to watch.",
}

Z["Desolace"] = {
    "Nothing grows here. Fitting.",
    "The centaur clans fight over less.",
    "Bones everywhere. Kodo, mostly.",
    "Gray sky, gray dirt, gray mood.",
    "Even the vultures look bored.",
    "Desolace is well named. You'll see.",
}

Z["Stonetalon Mountains"] = {
    "The goblins logged half this place. Let's not burn the rest.",
    "Long climb for a fight.",
    "Windshear smoke in the air again.",
    "Harpies on the peaks. They'll pick over the loser.",
    "Good view up here. Last one you'll see, maybe.",
    "Mind the logging chains.",
}

Z["Feralas"] = {
    "Everything here is too big. Except you.",
    "The rain never stops in Feralas.",
    "Ogres in the ruins and yetis in the caves.",
    "Old elven stone everywhere. Watch your head.",
    "The jungle's loud. This won't be.",
    "Giants walk these woods. Mind them.",
}

Z["Tanaris"] = {
    "Sand in my boots, sand in my ears.",
    "Gadgetzan's guards are watching. Behave. Or don't.",
    "Too hot to run. Too hot to talk.",
    "The trolls in Zul'Farrak would love this.",
    "Water's worth more than gold out here.",
    "The dunes will bury one of us by morning.",
}

Z["Dustwallow Marsh"] = {
    "Mud to the knees, and still you came.",
    "The flies here are worse than you.",
    "Theramore's walls are close. So is Brackenwall.",
    "Black dragons nest out east. Keep it quiet.",
    "Everything in this swamp bites.",
    "Smells like rot and rain. Every day.",
}

Z["Swamp of Sorrows"] = {
    "Sorrows. Somebody named this place honestly.",
    "Mind the crocolisks.",
    "Damp, dark, and you.",
    "Nothing good comes out of this swamp.",
    "The temple out there drowned a god. We're nothing.",
    "Even the moss looks tired.",
}

Z["Badlands"] = {
    "Nothing out here but rocks and Dark Irons.",
    "Dry as a dwarf's throat.",
    "Ogres on the ridges. Stay low.",
    "Uldaman's buried things worse than us.",
    "Heat shimmer. Don't trust your eyes.",
    "The vultures circle every fight in the Badlands.",
}

Z["Searing Gorge"] = {
    "Ash in the lungs. Dark Irons in the tunnels.",
    "The ground here is hot enough to cook on.",
    "Thorium Point's watching. Make it clean.",
    "Slag pits everywhere. Mind your feet.",
    "Even the air's angry in this place.",
    "The mountain's rumbling. It agrees with me.",
}

Z["Burning Steppes"] = {
    "Blackrock Mountain's right there. Keep it down.",
    "Everything here's already on fire.",
    "Dragonkin overhead. Look busy.",
    "The Steppes burned long before us.",
    "Smoke, ash and orcs. And you.",
    "Morgan's Vigil can see us from here.",
}

Z["Felwood"] = {
    "Don't drink the water. Don't touch the trees.",
    "The whole forest is sick. You fit right in.",
    "Corrupted wolves, corrupted trees.",
    "Even the light looks green here.",
    "Jadefire satyrs in the hills. Stay sharp.",
    "Felwood rots everything it touches.",
}

Z["Winterspring"] = {
    "My breath freezes before my words land.",
    "Everlook's goblins won't care either way.",
    "Snow, yetis and frostsabers.",
    "Quiet up here. Too quiet for a fight.",
    "Long way from any warm fire.",
    "The cold up here outlasts everyone.",
}

Z["Western Plaguelands"] = {
    "The dead walk these fields. Let's not join them.",
    "Andorhal is ash. So is the patience here.",
    "Plague in the soil. Mind your boots.",
    "The Scarlets are watching from the ridge.",
    "Even the crows avoid this place.",
    "Lordaeron used to be green.",
}

Z["Eastern Plaguelands"] = {
    "Scourge on every road.",
    "Light's Hope is close. The dead are closer.",
    "Naxxramas hangs right over us. Don't look up.",
    "Every farm here is a grave now.",
    "The Argent Dawn would be ashamed of us both.",
    "The air tastes like rot.",
}

Z["Un'Goro Crater"] = {
    "Devilsaurs walk here. Keep your voice down.",
    "Hot, wet, and full of teeth.",
    "Mind the tar pits.",
    "Everything in this crater is older than both of us.",
    "Marshal's Refuge is watching. Loudly.",
    "Something big is moving in the trees.",
}

Z["Silithus"] = {
    "Bugs. Sand. Wind. You.",
    "The hives are listening. They always are.",
    "Cenarion Hold won't save either of us.",
    "Silithid under every dune.",
    "This desert hates everything alive.",
    "Ahn'Qiraj is right there. We're small.",
}

Z["The Hinterlands"] = {
    "Trolls in every ruin and gryphons overhead.",
    "Aerie Peak's lot will hear this.",
    "Long way from anywhere.",
    "The Wildhammers drink to fights like this.",
    "Jintha'Alor watches the whole valley.",
    "Green, quiet and dangerous. Like you.",
}

Z["Wetlands"] = {
    "Rain again. Of course.",
    "Menethil smells of fish and mildew.",
    "Raptors in the reeds. Mind them.",
    "Grim Batol's shadow is on everything here.",
    "Mud and murlocs. Lovely.",
    "The Thandol Span is close. Don't fall off.",
}
