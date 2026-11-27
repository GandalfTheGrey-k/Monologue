--[[
    Monologue Data Module: more lines for the identity layers
    PURE DATA (plus two small helpers). Loaded after Layers.lua. Adds lines to every clan,
    upbringing, profession, trait, allegiance, Character Anchor and hometown pool so none has
    fewer than 6: small pools made the same line come back again and again.
    More(target, { Kind = { lines } }) appends to target[Kind]. Follow VOICE_GUIDE.md.
--]]

local Data = MonologueEngine.Data

local function More(target, pools)
    if type(target) ~= "table" then return end
    for kind, lines in pairs(pools) do
        if type(target[kind]) ~= "table" then target[kind] = {} end
        for _, line in ipairs(lines) do table.insert(target[kind], line) end
    end
end

local function Clan(race, key)
    local pack = Data.Races[race]
    if type(pack) ~= "table" or type(pack.Clans) ~= "table" then return nil end
    for _, clan in ipairs(pack.Clans) do
        if clan.key == key then return clan end
    end
    return nil
end

---------------------------------------------------------------------------
-- Clans
---------------------------------------------------------------------------
More(Clan("Dwarf", "Bronzebeard"), {
    Kill = {
        "That's one for the Great Forge.",
        "Down, and staying down.",
        "Magni would raise a mug to that.",
        "Ironforge steel, proven again.",
        "Clean work. Back to the road.",
    },
    Loot = {
        "That'll fetch a fair price in the Commons.",
        "Into the pack. Ironforge can sort it.",
        "Not Bronzebeard work, but not bad.",
        "A bit of coin for the Stonefire Tavern.",
        "Mine now. Into the pack it goes.",
    },
    LowHP = {
        "Bronzebeard blood runs thick.",
        "I've had worse falls in the Deeprun Tram.",
        "Not yet. The forge isn't done with me.",
        "Patch me up. I've a clan to make proud.",
        "Just a scratch. A big one.",
    },
    Greet = {
        "The forge fires burn for friends, {target}.",
        "Mind your step by the Great Forge, {target}. It's slick.",
        "Good to see you above ground, {target}.",
    },
    Idle = {
        "Hope the Commons kept my stool warm.",
        "The Great Forge hums in my bones even out here.",
        "Wonder what Magni's brooding over today.",
    },
    Combat = {
        "Shoulder to shoulder, like the old Bronzebeard line.",
        "The mountain's patient. I'm not.",
    },
})
More(Clan("Dwarf", "Wildhammer"), {
    Kill = {
        "Down like a gryphon on a hare.",
        "That's one for Aerie Peak.",
        "The sky saw that. Good.",
        "Hinterlands justice.",
        "Kurdran would laugh at that.",
    },
    Loot = {
        "A bit of shine for my gryphon's harness.",
        "That'll trade well in Aerie Peak.",
        "Feathers and coin. Can't complain.",
        "Into the saddlebag.",
        "Light enough to fly with. Good.",
    },
    LowHP = {
        "Fell off a gryphon once. This is nothing.",
        "Wind's out of me. Not the fight.",
        "Need a breath. Just one.",
        "The sky's not calling me yet.",
        "Bleeding like a Hinterlands storm.",
    },
    Greet = {
        "Come up to the Aerie sometime, {target}. Best view in Azeroth.",
        "You smell of open air, {target}. Good.",
        "Well met, {target}. Watch for gryphon droppings.",
    },
    Idle = {
        "My gryphon will be sulking without me.",
        "Too many walls around here. I miss the sky.",
        "Storm's coming over the peaks. I can feel it.",
    },
    Combat = {
        "Wildhammer fury. Have some.",
        "Hit hard, fly fast.",
    },
})
More(Clan("Dwarf", "DarkIron"), {
    Kill = {
        "Shadowforge fire takes another.",
        "Burnt out.",
        "That's how we did it in Blackrock.",
        "Slag. Nothing but slag.",
        "Thaurissan's lot couldn't do it better.",
    },
    Loot = {
        "Good ore in this. I can smell it.",
        "Dark Iron hands, honest coin.",
        "Heavy. I like heavy.",
        "That'll melt down nicely.",
        "Something for the anvil.",
    },
    LowHP = {
        "The fire's low. Not out.",
        "I've walked through the Searing Gorge. This is a breeze.",
        "Hot blood. Still flowing. Too much of it.",
        "Iron bends before it breaks.",
        "Not done. Not nearly.",
    },
    Greet = {
        "Don't stare, {target}. Aye, Dark Iron. Still a friend.",
        "Well met, {target}. The coals are warm.",
        "Good to see a face that doesn't flinch, {target}.",
    },
    Idle = {
        "People still whisper when I walk into Ironforge.",
        "Blackrock Mountain still smokes in my dreams.",
        "Not every Dark Iron served the Firelord.",
    },
    Combat = {
        "Fire and iron. Let's go.",
        "Shadowforge taught me to hit hard.",
    },
})
More(Clan("Dwarf", "Clanless"), {
    Kill = {
        "My grudge. My kill.",
        "No clan needed for that.",
        "Done. On my own, as always.",
        "That's the road's justice.",
        "Quiet now. Good.",
    },
    Loot = {
        "Mine. Nobody else's.",
        "Every coin counts when you've no hall.",
        "Coin for the next camp.",
        "Small, but mine.",
        "Pocket it and move on.",
    },
    LowHP = {
        "Nobody to carry me. So I'll walk.",
        "Been alone longer than this hurts.",
        "I'll stitch it myself. Always do.",
        "Not falling where nobody'd find me.",
        "Keep breathing. Just keep breathing.",
    },
    Greet = {
        "A friendly face. Rare on my road, {target}.",
        "Sit if you like, {target}. I don't mind company.",
        "Well met, {target}. No clan, but good manners.",
    },
    Idle = {
        "No hall to go home to. The road's fine.",
        "I don't miss the clan. Most days.",
        "Funny how a campfire becomes home.",
    },
    Combat = {
        "No clan behind me. Doesn't matter.",
        "I fight for myself. That's enough.",
    },
})
More(Clan("Orc", "Frostwolf"), {
    Kill = {
        "The wolves will eat well.",
        "Durotan's way. Clean.",
        "Cold steel, quick end.",
        "Alterac remembers.",
        "Honor kept.",
    },
    Loot = {
        "The clan's share comes first.",
        "Furs for the winter.",
        "Something for Frostwolf Keep.",
        "Useful. The pack will use it.",
        "Taken with honor.",
    },
    LowHP = {
        "Alterac winters bit harder than you.",
        "The wolf in me isn't done.",
        "Bleeding. Like snow on a red hill.",
        "Stand. Frostwolves stand.",
        "Not here. Not like this.",
    },
    Greet = {
        "Warm yourself by our fire, {target}.",
        "The wolves know you, {target}. So do I.",
        "Lok'tar, {target}. Snow is on the wind.",
    },
    Idle = {
        "I miss the snow of Alterac.",
        "Drek'Thar would have words for this place.",
        "My wolf hates the heat here.",
    },
    Combat = {
        "For Durotan's line.",
        "Howl with me, and fight.",
    },
})
More(Clan("Orc", "Warsong"), {
    Kill = {
        "Grom would want more.",
        "The war song rises.",
        "Another for the drums.",
        "Hellscream's blood, proven.",
        "Loud and fast. The Warsong way.",
    },
    Loot = {
        "Spoils for the warriors.",
        "Grom never cared for gold. I do.",
        "Trophies first, gold after.",
        "Good. Arm the band.",
        "Into the war chest.",
    },
    LowHP = {
        "Grom took worse and kept roaring.",
        "Pain? Just the war song getting louder.",
        "I'll stand till the drums stop.",
        "Not yet. The song's not over.",
        "Bleeding. Still singing.",
    },
    Greet = {
        "Lok'tar, {target}! The drums are beating.",
        "Ready for war, {target}? Always.",
        "Good. Another strong arm, {target}.",
    },
    Idle = {
        "Ashenvale's trees still need felling.",
        "I can still hear Grom's roar.",
        "Too quiet. The Warsong hates quiet.",
    },
    Combat = {
        "Warsong. Into them.",
        "Let them hear the drums.",
    },
})
More(Clan("Orc", "ShatteredHand"), {
    Kill = {
        "Quick hands, short life.",
        "Cut once. Done.",
        "Pain makes the lesson stick.",
        "Silent, like the old ways.",
        "One less blade to worry about.",
    },
    Loot = {
        "Every blade has its use.",
        "Coin, quietly taken.",
        "Mine now. Don't ask.",
        "Light. Useful. Good.",
        "Pocket it. Move.",
    },
    LowHP = {
        "Pain is a teacher I know well.",
        "Cut deep. Still moving.",
        "This hand's been broken before.",
        "Quiet. Breathe. Fight.",
        "Bleed slow. Hit fast.",
    },
    Greet = {
        "You walk quiet, {target}. I like that.",
        "Hm. Well met, {target}.",
        "Show me your hands, {target}. Good. Welcome.",
    },
    Idle = {
        "Old scars itch in the rain.",
        "Silence teaches more than talk.",
        "Keep your blades sharp and your mouth shut.",
    },
    Combat = {
        "Hands ready.",
        "Quick and quiet.",
    },
})
More(Clan("Orc", "Blackrock"), {
    Kill = {
        "Blackrock iron finishes it.",
        "The old fury, sated.",
        "Smashed, like the old days.",
        "That's how the Blackrock fought.",
        "Down in one.",
    },
    Loot = {
        "The forge-clan takes its tithe.",
        "Good iron. Heavy.",
        "Something to melt down.",
        "For the clan's hoard.",
        "Mine, by right of the axe.",
    },
    LowHP = {
        "Blackrock skin is thick.",
        "Still burning inside.",
        "The mountain made me harder.",
        "I've bled on hotter stone.",
        "Not down. Never down.",
    },
    Greet = {
        "Blackrock greets you, {target}.",
        "Strong arms, {target}. Good.",
        "Well met, {target}. The forges are lit.",
    },
    Idle = {
        "The mountain still calls to some of us.",
        "Old shame. New honor. I'm working on it.",
        "Smoke and iron. I miss the smell.",
    },
    Combat = {
        "Break them like rock.",
        "Iron fists, iron will.",
    },
})
More(Clan("Orc", "Dragonmaw"), {
    Kill = {
        "Burned and broken.",
        "Like a dragon in chains.",
        "Grim Batol remembers that strength.",
        "Nothing left but ash.",
        "No mercy. The Dragonmaw way.",
    },
    Loot = {
        "Fuel for the fires.",
        "Bright and shiny. Like dragon scale.",
        "Take it. Burn the rest.",
        "The clan wants its share.",
        "Good haul.",
    },
    LowHP = {
        "Scorched. Not finished.",
        "I've stood in dragonfire.",
        "Smoke in my lungs, steel in my hands.",
        "Burn me again. I'll stand.",
        "Not yet. Not to you.",
    },
    Greet = {
        "Welcome to the fire, {target}.",
        "The Dragonmaw remember their friends, {target}.",
        "Well met, {target}. Watch for embers.",
    },
    Idle = {
        "I dream of wings and fire.",
        "Grim Batol. Some say it still burns.",
        "The red dragons never forgave us. Fair.",
    },
    Combat = {
        "Fire and fury.",
        "Down like a chained wyrm.",
    },
})
More(Clan("Troll", "Darkspear"), {
    Kill = {
        "Da Darkspear send dem down.",
        "Sen'jin smile on dat one.",
        "Echo Isles proud tonight.",
        "Easy, mon. Too easy.",
        "Dat one for Vol'jin.",
    },
    Loot = {
        "Shiny for da shrine.",
        "Dis go back ta da Isles.",
        "Good stuff, mon.",
        "Da spirits say keep it.",
        "Pocket it, quick.",
    },
    LowHP = {
        "Da spirits not ready for me yet.",
        "Ow, mon. Dat hurt.",
        "Just a scratch. A big scratch.",
        "Stay loose. Stay alive.",
        "Bleedin', but da loa watchin'.",
    },
    Greet = {
        "Hey, {target}! Da Darkspear welcome ya.",
        "Come by da Echo Isles, {target}. Good fishin'.",
        "Ya look well, {target}. Da spirits agree.",
    },
    Idle = {
        "I miss da Echo Isles sand.",
        "Vol'jin say we stay strong. We stay strong.",
        "Da sea sound different here.",
    },
    Combat = {
        "Darkspear blood. Up, mon.",
        "Spears up, mon.",
    },
})
More(Clan("Troll", "Revantusk"), {
    Kill = {
        "Revantusk hunt well.",
        "Da Wildhammer not get dat one.",
        "Clean kill, mon.",
        "Back ta da earth.",
        "Da Hinterlands quieter now.",
    },
    Loot = {
        "Trade dis at Revantusk Village.",
        "Shiny shells an' coin.",
        "Good for da village.",
        "Light ta carry. Good.",
        "Dis worth somethin'.",
    },
    LowHP = {
        "Da Hinterlands tougher dan you.",
        "I swim through worse tides.",
        "Steady, mon. Steady.",
        "Not today, spirits.",
        "Hurtin', but still huntin'.",
    },
    Greet = {
        "Welcome, {target}. Revantusk remember friends.",
        "Ya come far, {target}. Rest.",
        "Da village glad ta see ya, {target}.",
    },
    Idle = {
        "Wonder if da Wildhammer still flyin' over da village.",
        "Smell da sea, mon? Me neither. Miss it.",
        "Da Hinterlands quiet dis time a year.",
    },
    Combat = {
        "Revantusk hunt now.",
        "Da tide come for ya.",
    },
})
More(Clan("Troll", "Zandalari"), {
    Kill = {
        "Old blood win again.",
        "Bow before da Zandalari. Too late.",
        "Dat one for da priests.",
        "Gone ta Bwonsamdi.",
        "Da old ways still work.",
    },
    Loot = {
        "Gold, as is proper.",
        "Dis worthy of da old empire.",
        "Keep dis. I study it later.",
        "Da loa approve.",
        "Treasure for da temple steps.",
    },
    LowHP = {
        "Da priests taught me pain.",
        "I outlive dis, like da empire.",
        "Stand tall. Zandalari stand tall.",
        "Not ta you. Never ta you.",
        "Old bones, strong spirit.",
    },
    Greet = {
        "Da Zandalari greet ya, {target}.",
        "Welcome, {target}. Speak, I listen.",
        "Ya show respect, {target}. Good.",
    },
    Idle = {
        "Zuldazar far away, but never forgotten.",
        "Gurubashi fools wake Hakkar. Fools.",
        "Da old temples still whisper.",
    },
    Combat = {
        "Da empire remember dis day.",
        "Kneel ta da old blood.",
    },
})
More(Clan("Tauren", "Bloodhoof"), {
    Kill = {
        "The herd is safe.",
        "Rest now, beast.",
        "Cairne would be satisfied.",
        "Back to the Earth Mother.",
        "Done, and done well.",
    },
    Loot = {
        "For Bloodhoof Village.",
        "The herd can use this.",
        "A fair gift from the hunt.",
        "Useful. I'll carry it.",
        "Good. Waste nothing.",
    },
    LowHP = {
        "I've been gored worse.",
        "The Earth Mother keeps me standing.",
        "Not yet. Mulgore waits for me.",
        "Breathe. Like the plains wind.",
        "The plains made me sturdy.",
    },
    Greet = {
        "Come sit by the longhouse, {target}.",
        "Bloodhoof welcomes you, {target}.",
        "Peace and grass, {target}.",
    },
    Idle = {
        "Mulgore's grass would be tall now.",
        "The herd will be moving soon.",
        "I miss the drums of Bloodhoof Village.",
    },
    Combat = {
        "For the herd and the village.",
        "Stand like Cairne.",
    },
})
More(Clan("Tauren", "Runetotem"), {
    Kill = {
        "Return to the earth, spirit.",
        "Hamuul would understand.",
        "The cycle turns.",
        "The grass will grow here again.",
        "The circle closes.",
    },
    Loot = {
        "The earth gives. I take gently.",
        "A gift. I'll use it well.",
        "Herbs and coin. Fair.",
        "Useful, not greedy.",
        "Moonglade would put this to use.",
    },
    LowHP = {
        "Roots hold me up.",
        "Even the oak bends.",
        "Healing comes. Wait.",
        "Not finished. The balance needs me.",
        "The earth is patient. So am I.",
    },
    Greet = {
        "The Cenarion paths led you here, {target}.",
        "Be welcome, {target}. Balance in all things.",
        "Peace, {target}. The moon rises soon.",
    },
    Idle = {
        "Moonglade is beautiful this time of year.",
        "Every root has a story.",
        "Listen. The wind has an opinion.",
    },
    Combat = {
        "Nature's balance, restored.",
        "Roots and horns, then.",
    },
})
More(Clan("Tauren", "Grimtotem"), {
    Kill = {
        "Exiles don't forgive.",
        "Grimtotem strength.",
        "That's for the stolen lands.",
        "Down. Stay there.",
        "Stonetalon justice.",
    },
    Loot = {
        "Mine. Exiles share nothing.",
        "Spoils of a hard road.",
        "Take it before anyone sees.",
        "Exiles can't be picky.",
        "Good. It'll keep me fed.",
    },
    LowHP = {
        "Bloodied. Still standing.",
        "Alone, and still breathing.",
        "Pain is home.",
        "Grimtotem don't kneel.",
        "I'll endure this too.",
    },
    Greet = {
        "You don't fear the Grimtotem, {target}? Good.",
        "Sit, {target}. Exiles don't get many guests.",
        "Well met, {target}. Watch your back.",
    },
    Idle = {
        "Thunder Bluff doesn't welcome me anymore.",
        "The Stonetalon peaks are home enough.",
        "Magatha's shadow is long.",
    },
    Combat = {
        "Grimtotem fury.",
        "The exile bites back.",
    },
})
More(Clan("NightElf", "Darnassian"), {
    Kill = {
        "Elune guides my blade.",
        "Rest beneath the moon.",
        "The temple will hear of this.",
        "Clean, as Darnassus teaches.",
        "Peace, now.",
    },
    Loot = {
        "A worthy find.",
        "Elune provides.",
        "This will serve the Cenarion Enclave.",
        "Fine craft. Not ours, but fine.",
        "Into the pack, carefully.",
    },
    LowHP = {
        "The moon still shines on me.",
        "Wounded, but not lost.",
        "Teldrassil is far, but I will see it again.",
        "Not here. Not now.",
        "Starlight, steady me.",
    },
    Greet = {
        "Elune light your path, {target}. Teldrassil sends greetings.",
        "Well met, {target}. The Temple of the Moon remembers you.",
        "Rest a while, {target}. Darnassus is never in a hurry.",
    },
    Idle = {
        "The Temple gardens must be in bloom.",
        "Teldrassil looks smaller from far away.",
        "Ten thousand years and still I miss home.",
    },
    Combat = {
        "For Darnassus and the moon.",
        "Starlight, guide my hand.",
    },
})
More(Clan("NightElf", "Sentinel"), {
    Kill = {
        "One fewer in Ashenvale.",
        "Shandris will want to know.",
        "Clear. Move on.",
        "Flank's clear. Good.",
        "The border is safer.",
    },
    Loot = {
        "Marked for the quartermaster.",
        "Useful for the watch.",
        "Arrows. Always need arrows.",
        "Into the supply pack.",
        "The outpost will thank me.",
    },
    LowHP = {
        "Still on post.",
        "Bloodied. Holding.",
        "A Sentinel doesn't fall easily.",
        "Cover me. A moment.",
        "I've bled in Ashenvale before.",
    },
    Greet = {
        "The watch is glad of you, {target}.",
        "Well met, {target}. Keep your eyes sharp.",
        "All quiet on the border, {target}.",
    },
    Idle = {
        "Ashenvale never sleeps. Neither do I.",
        "Shandris will want a report.",
        "Quiet nights make me nervous.",
    },
    Combat = {
        "Sentinel steel. Engaging.",
        "Hold the treeline.",
    },
})
More(Clan("NightElf", "Highborne"), {
    Kill = {
        "Arcane, unmatched.",
        "Ten thousand years of practice.",
        "Elegant. As it should be.",
        "Gone, like Zin-Azshari.",
        "That was barely an effort.",
    },
    Loot = {
        "A faint enchantment. I'll study it.",
        "Crude, but salvageable.",
        "This may hold a ward.",
        "The Shen'dralar would want this.",
        "Older than it looks.",
    },
    LowHP = {
        "The arcane fails me. Briefly.",
        "Pain is so... mortal.",
        "I survived the Sundering. I'll survive this.",
        "Steady. The weave holds.",
        "A moment. I need to focus.",
    },
    Greet = {
        "Ah, {target}. A cultured face, at last.",
        "Greetings, {target}. Eldre'Thalas sends its regards.",
        "Well met, {target}. Do mind the arcane residue.",
    },
    Idle = {
        "The libraries of Eldre'Thalas still call to me.",
        "Mortal magic is so... rushed.",
        "I remember Zin-Azshari. Few do.",
    },
    Combat = {
        "The old magic answers.",
        "Arcane, sharpened by ages.",
    },
})
More(Clan("Human", "Stormwind"), {
    Kill = {
        "One for the Stormwind Guard's ledger.",
        "That's one for the Stockade.",
        "Justice, the Stormwind way.",
        "Down. Elwynn's safer now.",
        "Well done. Back to it.",
    },
    Loot = {
        "That'll fetch a fair price in the Trade District.",
        "Light be praised, coin.",
        "Good. To the bank with it later.",
        "Better than Goldshire prices.",
        "Worth the trip.",
    },
    LowHP = {
        "The Cathedral would light a candle for me.",
        "Hold on. Just hold on.",
        "Not today. Not this far from home.",
        "Bleeding, but standing.",
        "Heal me, someone. Please.",
    },
    Greet = {
        "Good to see you, {target}. How's Stormwind treating you?",
        "Well met, {target}. The Lion stands proud today.",
        "Hello, {target}. Fancy a pint at the Pig and Whistle?",
    },
    Idle = {
        "The canals smell worse than I remember.",
        "Wonder how the Mage Quarter is these days.",
        "I'd kill for a Goldshire pie.",
    },
    Combat = {
        "For the Lion's pride.",
        "Stormwind steel, step forward.",
    },
})
More(Clan("Human", "Lordaeron"), {
    Kill = {
        "Lordaeron remembers.",
        "One less monster in the north.",
        "For Terenas.",
        "Rest. Unlike my home.",
        "Justice for Lordaeron.",
    },
    Loot = {
        "Salvage from a dying world.",
        "Everything has value now.",
        "For the refugees.",
        "Keep it safe.",
        "Not much. Still useful.",
    },
    LowHP = {
        "I've lost more than blood.",
        "The plague couldn't take me. Neither will you.",
        "Keep fighting. That's all I know.",
        "Not like my home. Not like this.",
        "Breathe. Endure.",
    },
    Greet = {
        "Another survivor. Good to see you, {target}.",
        "Well met, {target}. We few remain.",
        "Hello, {target}. Lordaeron lives in us.",
    },
    Idle = {
        "I still dream of Capital City's towers.",
        "Tirisfal was green once. Truly.",
        "Every refugee camp looks the same.",
    },
    Combat = {
        "For what's left of Lordaeron.",
        "We've already lost everything. Come on.",
    },
})
More(Clan("Human", "KulTiran"), {
    Kill = {
        "To the bottom with you.",
        "Another for the Admiral.",
        "Weigh anchor. Done.",
        "Over the rail.",
        "Down with the tide.",
    },
    Loot = {
        "Pirate's luck.",
        "Into the ship's hold.",
        "Good haul, lads.",
        "That'll buy a round in Theramore.",
        "Treasure. Small, but mine.",
    },
    LowHP = {
        "Taking on water.",
        "I've been through worse storms.",
        "Man the pumps. That's me.",
        "Hold fast. Hold fast.",
        "Not sinking. Not today.",
    },
    Greet = {
        "Ahoy, {target}. Good winds?",
        "Welcome aboard, {target}. So to speak.",
        "Fair seas, {target}. How's the tide?",
    },
    Idle = {
        "I miss the smell of salt.",
        "Proudmoore blood is sea blood.",
        "Theramore's docks are the closest I get to home.",
    },
    Combat = {
        "All hands on deck.",
        "Boarding party. With me.",
    },
})
More(Clan("Human", "Stromgarde"), {
    Kill = {
        "Stromgarde stands.",
        "One less for the Highlands.",
        "That's how Thoras taught us.",
        "Down, like a Syndicate cur.",
        "Arathi steel.",
    },
    Loot = {
        "The Highlands need every coin.",
        "Good. Stromgarde will rebuild.",
        "Arm the militia.",
        "Into the keep's stores.",
        "Small, but useful.",
    },
    LowHP = {
        "The Highlands made me tough.",
        "Bloodied, Arathi-proud.",
        "Not falling. Not here.",
        "Hold the wall.",
        "Old kingdom, stubborn blood.",
    },
    Greet = {
        "Well met, {target}. Stromgarde remembers allies.",
        "Good to see you, {target}. The Highlands are rough.",
        "Hello, {target}. Arathi welcomes you.",
    },
    Idle = {
        "Stromgarde Keep needs rebuilding.",
        "The Syndicate still haunts the Highlands.",
        "Arathor was the first kingdom. We forget that.",
    },
    Combat = {
        "Stromgarde's stubborn. So am I.",
        "Arathi steel, hold.",
    },
})
More(Clan("Human", "Dalaran"), {
    Kill = {
        "For the violet city.",
        "The Kirin Tor would note that.",
        "Arcane precision.",
        "Dalaran's exile, proven.",
        "Done. Tidily.",
    },
    Loot = {
        "Reagents! Lovely.",
        "This might be enchanted.",
        "For the rebuilding fund.",
        "Curious. I'll examine it.",
        "Useful for a ritual.",
    },
    LowHP = {
        "Shield's fading.",
        "Need a moment to recover.",
        "Not the death I planned.",
        "The violet light still guides me.",
        "Hold. Concentrate.",
    },
    Greet = {
        "Greetings, {target}. Dalaran sends its regards, wherever it is.",
        "Well met, {target}. Have you seen the violet dome?",
        "Hello, {target}. Mind my books.",
    },
    Idle = {
        "Dalaran's dome still shimmers over Alterac.",
        "The Kirin Tor never write back.",
        "Exile is a long study.",
    },
    Combat = {
        "For the Kirin Tor, then.",
        "Violet fire, answer.",
    },
})
More(Clan("Gnome", "Gnomeregan"), {
    Kill = {
        "Problem solved!",
        "Calculated. Correct.",
        "Another success for science.",
        "That went better than the last test.",
        "Efficient.",
    },
    Loot = {
        "Ooh, copper wiring.",
        "This could be useful in a gadget.",
        "Sprockets! Lovely.",
        "I'll take that apart later.",
        "For the rebuilding of Gnomeregan.",
    },
    LowHP = {
        "Ow. Recalibrating.",
        "Systems failing. Mine.",
        "Need repairs. On me.",
        "Not the right moment to explode.",
        "Bandages! Anyone?",
    },
    Greet = {
        "Hello, {target}! Tinker Town welcomes you.",
        "Hi, {target}! Mind the steam vents.",
        "Greetings, {target}. Gnomeregan will rise again.",
    },
    Idle = {
        "One day we'll take Gnomeregan back.",
        "I wonder what Mekkatorque's building.",
        "Tinker Town's too cramped. Too cozy.",
    },
    Combat = {
        "Gnomeregan forever. Mostly.",
        "Science, engage.",
    },
})
More(Clan("Gnome", "Leper"), {
    Kill = {
        "Glowing results.",
        "That's what radiation does.",
        "Down. Ouch, my arm.",
        "Experiment successful.",
        "Hah. Another one.",
    },
    Loot = {
        "I'll scrub it first.",
        "Every bit counts.",
        "Hm. Glowing slightly.",
        "Good, good.",
        "Mine, mine.",
    },
    LowHP = {
        "Hurts. Glows. Normal.",
        "I've had worse days in Gnomeregan.",
        "Falling apart. Literally.",
        "Ouch. Glow. Ouch.",
        "Still ticking.",
    },
    Greet = {
        "Don't mind the glow, {target}.",
        "Hello, {target}. I'm not contagious. Probably.",
        "Hi, {target}. Stand back a little.",
    },
    Idle = {
        "My skin tingles all the time now.",
        "I still remember the gas.",
        "Some days I glow in the dark.",
    },
    Combat = {
        "Glowing and angry.",
        "Hot hands.",
    },
})
More(Clan("Scourge", "Fallen"), {
    Kill = {
        "Join me, why don't you.",
        "Rest. I don't get to.",
        "Dead. Again.",
        "The Dark Lady thanks you.",
        "Sylvanas would approve of that one.",
    },
    Loot = {
        "Mine now. You won't miss it.",
        "Spoils of the grave.",
        "Useful. Unlike me.",
        "Shiny. I don't care.",
        "For the Undercity.",
    },
    LowHP = {
        "Falling apart. Again.",
        "Stitch me later.",
        "Pain is a memory.",
        "Not finished. Never finished.",
        "Barely hanging on. Literally.",
    },
    Greet = {
        "Hello, {target}. Don't stare at the jaw.",
        "Ah, {target}. Still breathing, I see.",
        "Well met, {target}. The Undercity says hello.",
    },
    Idle = {
        "I used to love sunlight.",
        "My old house is still standing in Brill.",
        "The Dark Lady has plans. We wait.",
    },
    Combat = {
        "For the Banshee Queen.",
        "Death comes. I'm it.",
    },
})
More(Clan("Scourge", "Apothecary"), {
    Kill = {
        "Data collected.",
        "Fascinating reaction.",
        "Note the time of death.",
        "Specimen acquired.",
        "Results as predicted.",
    },
    Loot = {
        "Into a vial.",
        "This will make a lovely tincture.",
        "Reagent. Perfect.",
        "For the Royal Apothecary Society.",
        "Bag it. Label it.",
    },
    LowHP = {
        "My formulas never fail. Today they might.",
        "Structural integrity failing.",
        "Pass me that vial.",
        "Interesting. I'm dying.",
        "Recalculate. Survive.",
    },
    Greet = {
        "Good day, {target}. Don't touch anything.",
        "Ah, {target}. Bring any samples?",
        "Welcome, {target}. Mind the fumes.",
    },
    Idle = {
        "Putress has plans. Big plans.",
        "I need more ingredients.",
        "The new plague needs work.",
    },
    Combat = {
        "Test subject acquired.",
        "Observe the results.",
    },
})
More(Clan("Skyborne", "Cloudreach"), {
    Kill = {
        "The Sky-Guard holds.",
        "Down from the heights.",
        "Clean strike.",
        "Zephras watches.",
        "Done, like a falcon.",
    },
    Loot = {
        "Light enough to fly with.",
        "Shiny, even from up high.",
        "Good. Pack it.",
        "For the Order.",
        "Small treasure.",
    },
    LowHP = {
        "Wings hurt.",
        "The sky waits for me.",
        "Not grounded yet.",
        "Steady. Breathe the high air.",
        "I've fallen farther.",
    },
    Greet = {
        "Well met, {target}. The view is better up here.",
        "Hello, {target}. Fly with the Sky-Guard sometime.",
        "Fair heights, {target}.",
    },
    Idle = {
        "I miss the high cliffs of Zephras.",
        "The air is thick down here.",
        "My wings need stretching.",
    },
    Combat = {
        "Sky-Guard, strike.",
        "Down from the heights we come.",
    },
})
More(Clan("Skyborne", "Lowland"), {
    Kill = {
        "Grounded for good.",
        "Simple work.",
        "Feet first, always.",
        "Done. Easy.",
        "The ground welcomes you.",
    },
    Loot = {
        "Useful, practical.",
        "Pack it up.",
        "Good for the farm.",
        "Simple, solid.",
        "Earned it, fair and square.",
    },
    LowHP = {
        "Ground's solid. So am I.",
        "Not falling.",
        "Hold on, hold on.",
        "Feet down. Steady.",
        "Still standing. Somehow.",
    },
    Greet = {
        "Hello, {target}. Down here, with the rest of us.",
        "Well met, {target}. Good soil today.",
        "Nice to see you, {target}.",
    },
    Idle = {
        "Never cared for the high cliffs.",
        "Earth under my feet. That's home.",
        "The sky folk think too much.",
    },
    Combat = {
        "Plant your feet.",
        "Ground and pound.",
    },
})
More(Clan("Skyborne", "StormKindred"), {
    Kill = {
        "Lightning finds them.",
        "Storm's done.",
        "Crackle and fall.",
        "The storm took that one.",
        "Down, like rain.",
    },
    Loot = {
        "Crackling a bit, this one.",
        "The storm provides.",
        "Ooh, tingly.",
        "Static in this one.",
        "Useful. Charged, even.",
    },
    LowHP = {
        "Lightning dims. Not out.",
        "Thunder fading.",
        "Still crackling.",
        "Rumbling.",
        "The storm's not over.",
    },
    Greet = {
        "Well met, {target}. Feel the storm?",
        "Hello, {target}. Thunder's close.",
        "Good to see you, {target}. Rain's coming.",
    },
    Idle = {
        "The air tastes like a storm coming.",
        "Thunderheads are the best views.",
        "The air's too calm here.",
    },
    Combat = {
        "Storm, strike.",
        "Thunder and wind, with me.",
    },
})

---------------------------------------------------------------------------
-- Upbringings
---------------------------------------------------------------------------
More(Data.Upbringings.Scourge, {
    Kill = {
        "Burn it to be sure.",
        "One fewer walking.",
        "I've buried better.",
        "Check it doesn't get up.",
        "That's for Andorhal.",
    },
    Loot = {
        "Wash it before you touch it.",
        "Grain from the north? Burn it.",
        "Useful. If it's clean.",
        "Scrub it twice.",
        "Clean enough.",
    },
    LowHP = {
        "I've watched worse die.",
        "Not like the villagers. Not me.",
        "Keep standing.",
        "Bleeding isn't rotting. Good.",
        "Hold on. You've survived worse.",
    },
    Idle = {
        "I never eat bread from the north.",
        "Every bell sounds like a warning now.",
    },
    Combat = {
        "I know how this ends. Badly for you.",
    },
})
More(Data.Upbringings.Tavern, {
    Kill = {
        "Closing time.",
        "That's you thrown out.",
        "Out the door with you.",
        "Round's on me.",
        "Bar's closed.",
    },
    Loot = {
        "Tips!",
        "That covers the tab.",
        "A round's worth, at least.",
        "Coin for the dice.",
        "Ha, lucky night.",
    },
    LowHP = {
        "Felt worse after a long night.",
        "Somebody get me a stool.",
        "Hurts like a hangover.",
        "Just a bruise. A big one.",
        "Not my first brawl.",
    },
    Idle = {
        "Bet the inn's lively tonight.",
        "I could use a game of dice.",
    },
    Combat = {
        "Bar rules: no rules.",
    },
})
More(Data.Upbringings.Forge, {
    Kill = {
        "Flattened on the anvil.",
        "Struck true.",
        "Tempered. Done.",
        "Anvil-clean.",
        "That's how steel is tested.",
    },
    Loot = {
        "Ore. Good ore.",
        "This'll smelt nicely.",
        "Poor craftsmanship. I'll fix it.",
        "Into the scrap pile.",
        "Good iron.",
    },
    LowHP = {
        "Cracked, but holding.",
        "Need reheating.",
        "I've been hammered harder.",
        "Steel cools. Not me.",
        "Still sharp.",
    },
    Idle = {
        "I'd give a lot for a good anvil right now.",
        "The smell of coal. I miss it.",
    },
    Combat = {
        "Strike while it's hot.",
    },
})
More(Data.Upbringings.Watch, {
    Kill = {
        "Threat neutralized.",
        "Suspect apprehended. Permanently.",
        "Area secure.",
        "Case closed.",
        "Logged and done.",
    },
    Loot = {
        "Evidence.",
        "Bagged and tagged.",
        "Property of the Watch.",
        "Seized.",
        "Noted in the ledger.",
    },
    LowHP = {
        "Officer down. Not quite.",
        "Need backup.",
        "Holding the line.",
        "Hurt. Still watching.",
        "Report: bleeding.",
    },
    Idle = {
        "Quiet shift.",
        "Someone always breaks the law eventually.",
    },
    Combat = {
        "Halt, in the name of the law.",
    },
})
More(Data.Upbringings.Road, {
    Kill = {
        "Another bandit off the road.",
        "Safe travels now.",
        "Road's clear.",
        "That's how you keep a road safe.",
        "Done. Keep moving.",
    },
    Loot = {
        "Coin for the next inn.",
        "Supplies. Good.",
        "Trade goods.",
        "Keep it light.",
        "Every bit helps on the road.",
    },
    LowHP = {
        "Blisters hurt more.",
        "Keep walking.",
        "Not stopping here.",
        "Bleeding. Still moving.",
        "The road goes on. So do I.",
    },
    Idle = {
        "Next town, a hot bath.",
        "My boots have seen more than most.",
    },
    Combat = {
        "This road's not yours.",
    },
})
More(Data.Upbringings.Magic, {
    Kill = {
        "As the signs foretold.",
        "The weave holds.",
        "Destiny.",
        "Foreseen.",
        "Fate, settled.",
    },
    Loot = {
        "A faint aura.",
        "Enchanted? Perhaps.",
        "I'll study this.",
        "Reagents.",
        "Curious.",
    },
    LowHP = {
        "The signs didn't mention this.",
        "Shields failing.",
        "Need focus.",
        "The omens are bad.",
        "Hold the weave.",
    },
    Idle = {
        "The stars look strange tonight.",
        "Something in the air. Uncanny.",
    },
    Combat = {
        "The signs point to you.",
    },
})

---------------------------------------------------------------------------
-- Professions
---------------------------------------------------------------------------
More(Data.Professions.Alchemy, {
    Kill = {
        "Distilled.",
        "Dissolved.",
        "Precipitated out.",
        "Another ingredient for the cauldron.",
        "Bottled.",
    },
    LowHP = {
        "Need a potion. Now.",
        "Wrong flask. Wrong flask!",
        "Mixing a remedy. Hold on.",
        "Volatile. And bleeding.",
        "Should've brewed more.",
    },
    Repair = {
        "Armor smells of sulfur again.",
        "Acid burns. Again.",
        "Fix it. Don't ask what spilled.",
        "Spilled a flask on it. Sorry.",
        "Corroded. Again.",
    },
    City = {
        "Need more phials.",
        "The alchemy trainer owes me a recipe.",
        "Herbs at the auction house cost a fortune.",
        "I'll stop by the reagent shop.",
    },
    Combat = {
        "Potions ready.",
        "Flask in hand.",
        "Mind the fumes.",
        "This'll burn.",
    },
    Loot = {
        "Herbs!",
        "Ooh, a vial.",
        "Reagents, finally.",
        "Good for a tincture.",
    },
    Idle = {
        "I should restock my potions.",
        "That last brew turned green. It shouldn't.",
    },
})
More(Data.Professions.Blacksmithing, {
    Kill = {
        "Hammered.",
        "Forged in battle.",
        "Tested the edge. Works.",
        "That blade earned its keep.",
        "Sharp enough.",
    },
    LowHP = {
        "Armor's cracked.",
        "Plate's holding. Barely.",
        "Need a whetstone and a nap.",
        "Bent my pauldron.",
        "Hold together, plate.",
    },
    Repair = {
        "Good work. Not mine, but good.",
        "I'd do this myself if I had my anvil.",
        "Mind the rivets.",
        "Tighten the straps too.",
        "Heavy bill. Heavy armor.",
    },
    City = {
        "Need more coal.",
        "The forge here runs too cool.",
        "Iron bars are cheap today.",
        "I'll check the smith's wares.",
    },
    Combat = {
        "Steel ready.",
        "Edge is sharp.",
        "Plate on.",
        "Let's dent something.",
    },
    Loot = {
        "Iron ore!",
        "Bars. Nice.",
        "Scrap metal. Useful.",
        "Good steel here.",
    },
    Idle = {
        "My arms ache from the anvil.",
        "Thinking of a new blade design.",
    },
})
More(Data.Professions.Enchanting, {
    Kill = {
        "Dispelled.",
        "Unraveled.",
        "The runes agreed.",
        "Disenchanted for good.",
        "Faded out.",
    },
    LowHP = {
        "Wards slipping.",
        "My enchantments are failing.",
        "Need to refocus.",
        "Shield rune's dim.",
        "The glow is fading. Mine.",
    },
    Repair = {
        "Mind the enchantments.",
        "Careful, it's enchanted.",
        "Don't scratch the runes.",
        "Rune etching costs extra.",
        "Fix it gently.",
    },
    City = {
        "Strange dust is pricey here.",
        "Rods and essences. Expensive.",
        "I should check the enchanting trainer.",
        "Who's selling shards?",
    },
    Combat = {
        "Runes active.",
        "Enchantment holding.",
        "Runes humming.",
        "Spark up.",
    },
    Loot = {
        "Something to disenchant.",
        "Ooh, a glowing trinket.",
        "Shards inside, I bet.",
        "Dust in waiting.",
    },
    Idle = {
        "Everything glows if you stare long enough.",
        "I should enchant my boots.",
    },
})
More(Data.Professions.Engineering, {
    Kill = {
        "Boom.",
        "Detonated.",
        "Gears beat claws.",
        "Exactly as designed.",
        "Engineering wins.",
    },
    LowHP = {
        "Sparks everywhere.",
        "Need a repair bot.",
        "Overheating.",
        "Nuts and bolts loose.",
        "Systems critical.",
    },
    Repair = {
        "Oil the joints too.",
        "That rattle's normal.",
        "Don't touch the wires.",
        "Patch it with copper.",
        "Repairs. My favorite.",
    },
    City = {
        "Need more bolts.",
        "Gyrocogs, anyone?",
        "The engineering shop's a mess.",
        "Blasting powder's sold out again.",
    },
    Combat = {
        "Fire the gadget!",
        "Testing.",
        "Here goes nothing.",
        "Calibrated.",
    },
    Loot = {
        "Gears!",
        "Copper bolts.",
        "Spare wiring.",
        "Mechanical bits.",
    },
    Idle = {
        "I could improve this belt with a few springs.",
        "Need a better scope.",
    },
})
More(Data.Professions.FirstAid, {
    Kill = {
        "No triage needed.",
        "Patient lost. Not mine.",
        "Done. Next patient.",
        "Clean, at least.",
        "Beyond help.",
    },
    LowHP = {
        "Apply pressure.",
        "Linen, quick.",
        "Stitch me up.",
        "Tourniquet!",
        "I need my own medic.",
    },
    Repair = {
        "Patch the armor like a wound.",
        "Stitching's my trade too.",
        "Mend it neat.",
        "Bandage the leather.",
        "Healing armor. Ha.",
    },
    City = {
        "Need more linen.",
        "Bandages sell fast.",
        "I should visit the first aid trainer.",
        "Wool for heavy bandages.",
    },
    Combat = {
        "Linen in hand.",
        "Stay healthy.",
        "Mind your wounds.",
        "Don't need me.",
    },
    Loot = {
        "Linen!",
        "Cloth for bandages.",
        "Wool. Perfect.",
        "Silk for the good bandages.",
    },
    Idle = {
        "Everyone always needs bandages.",
        "I've stitched worse.",
    },
})
More(Data.Professions.Fishing, {
    Kill = {
        "Gutted.",
        "Catch of the day.",
        "Reeled in.",
        "Hooked and landed.",
        "Into the bucket.",
    },
    LowHP = {
        "I'm the bait now.",
        "Line's snapping.",
        "Need a rest by the lake.",
        "Bleeding like a hooked fish.",
        "Bad catch.",
    },
    Repair = {
        "Mind the hooks in the pack.",
        "Smells of fish. Sorry.",
        "Water damage. Again.",
        "Fix it. Dry it.",
        "Rusty buckles.",
    },
    City = {
        "Need new lures.",
        "Bait's sold out.",
        "The fishing trainer's by the canal.",
        "Any good fishing spots nearby?",
    },
    Combat = {
        "Cast and reel.",
        "Bait taken.",
        "Big one.",
        "Patience, then the hook.",
    },
    Loot = {
        "Fish!",
        "Wet but useful.",
        "Bait.",
        "Something shiny from the water.",
    },
    Idle = {
        "Wonder if they're biting at the lake.",
        "Nat Pagle would laugh at me.",
    },
})
More(Data.Professions.Herbalism, {
    Kill = {
        "Compost.",
        "Rooted out.",
        "Plucked.",
        "Weeded.",
        "Fertilizer now.",
    },
    LowHP = {
        "Silverleaf, quick.",
        "Bleeding like crushed petals.",
        "Need a poultice.",
        "Thorns everywhere.",
        "Earthroot, anyone?",
    },
    Repair = {
        "Grass stains, sorry.",
        "Pollen everywhere.",
        "Thorns tore it.",
        "Fix it. Bloom later.",
        "Muddy again.",
    },
    City = {
        "Herbs sell well here.",
        "Nobody grows anything in a city.",
        "Need a better pouch.",
        "I'll sell the extra briarthorn.",
    },
    Combat = {
        "Mind the briars.",
        "Petal-soft, thorn-sharp.",
        "Bloom.",
        "Weed out.",
    },
    Loot = {
        "Peacebloom!",
        "Mageroyal.",
        "Seeds.",
        "Good petals.",
    },
    Idle = {
        "Smell that? Mageroyal.",
        "I should press these flowers.",
    },
})
More(Data.Professions.Leatherworking, {
    Kill = {
        "Good hide.",
        "Tanned.",
        "Skinned soon.",
        "Thick pelt.",
        "That leather's mine.",
    },
    LowHP = {
        "Leather torn.",
        "Need new straps.",
        "Hide's not holding.",
        "Cut through.",
        "Stitches popped.",
    },
    Repair = {
        "Saddle soap, please.",
        "Mind the stitching.",
        "Leather cracks.",
        "Oil it well.",
        "Patch it with hide.",
    },
    City = {
        "Need more salt.",
        "Thread's running low.",
        "Dyes are pricey.",
        "I'll sell some hides.",
    },
    Combat = {
        "Leather on.",
        "Tough hide.",
        "Supple, strong.",
        "Watch the stitching.",
    },
    Loot = {
        "Hide!",
        "Scraps.",
        "Pelt.",
        "Thread.",
    },
    Idle = {
        "This belt needs work.",
        "My boots need resoling.",
    },
})
More(Data.Professions.Mining, {
    Kill = {
        "Mined out.",
        "Crushed.",
        "Rock solid.",
        "Ore and done.",
        "Dug in.",
    },
    LowHP = {
        "Dust in my lungs.",
        "Pick's heavy now.",
        "Need fresh air, quick.",
        "Rubble.",
        "Rattled like a cave-in.",
    },
    Repair = {
        "Rock dust in everything.",
        "Pickaxe dented my armor.",
        "Fix it. Rocks are rough.",
        "Scratched on a vein.",
        "Ore stains.",
    },
    City = {
        "Ore's selling well.",
        "Need a new pick.",
        "Smelting here is cheap.",
        "The mining trainer's by the forge.",
    },
    Combat = {
        "Stone and steel.",
        "Strike the vein.",
        "Pick in hand.",
        "Swing steady.",
    },
    Loot = {
        "Ore!",
        "Stone.",
        "Gems.",
        "Copper.",
    },
    Idle = {
        "I can smell iron in the hills.",
        "My back aches from mining.",
    },
})
More(Data.Professions.Scribe, {
    Kill = {
        "Noted in the margins.",
        "Recorded.",
        "Footnote.",
        "Ink dries.",
        "Final entry.",
    },
    LowHP = {
        "My notes are bloody.",
        "Pages torn.",
        "Write my last words.",
        "Quill shaking.",
        "Ink running.",
    },
    Repair = {
        "Ink stains, sorry.",
        "Mind the pages.",
        "Scroll case cracked.",
        "Fix it. Neatly.",
        "Paper cuts.",
    },
    City = {
        "Need more ink.",
        "Parchment's cheap here.",
        "The library's open late.",
        "I should copy some scrolls.",
    },
    Combat = {
        "Taking notes.",
        "Recording.",
        "For the record.",
        "Ink ready.",
    },
    Loot = {
        "Scroll!",
        "Parchment.",
        "Ink.",
        "Notes.",
    },
    Idle = {
        "My journal's getting thick.",
        "I should write about today.",
    },
})
More(Data.Professions.Sellsword, {
    Kill = {
        "Paid.",
        "Contract fulfilled.",
        "Earned.",
        "Bonus.",
        "Another job.",
    },
    LowHP = {
        "Not paid enough.",
        "Hazard pay doubled.",
        "Medic's extra.",
        "Bleeding on my own coin.",
        "Contract didn't mention this.",
    },
    Repair = {
        "Business expense.",
        "Bill it to the client.",
        "Cost of the trade.",
        "Ouch, my wallet.",
        "Deduct it.",
    },
    City = {
        "Any work around here?",
        "Need a new contract.",
        "The mercenary board's empty.",
        "Who's hiring?",
    },
    Combat = {
        "Earning my pay.",
        "Business.",
        "Work.",
        "Just the job.",
    },
    Loot = {
        "Pay!",
        "Coin for the purse.",
        "Spoils.",
        "Extra.",
    },
    Idle = {
        "Slow day for work.",
        "Coin's running low.",
    },
})
More(Data.Professions.Skinning, {
    Kill = {
        "Hide's mine.",
        "Knife out.",
        "Pelt ready.",
        "Skin it.",
        "Good fur.",
    },
    LowHP = {
        "Cut myself.",
        "Knife slipped.",
        "Torn hide. Mine.",
        "Bleeding.",
        "Raw.",
    },
    Repair = {
        "Fur on everything.",
        "Blood stains.",
        "Smells of hides.",
        "Fix the knife sheath.",
        "Patch it.",
    },
    City = {
        "Hides sell here.",
        "Need a sharper knife.",
        "The skinning trainer's busy.",
        "Pelts, anyone?",
    },
    Combat = {
        "Mind the pelt.",
        "Clean cuts.",
        "Skin deep.",
        "Blade ready.",
    },
    Loot = {
        "Fur!",
        "Leather scraps.",
        "Fangs.",
        "Claws.",
    },
    Idle = {
        "My knife needs honing.",
        "Good hunting grounds nearby.",
    },
})
More(Data.Professions.Tailoring, {
    Kill = {
        "Stitched shut.",
        "Hemmed in.",
        "Cut to size.",
        "Sewn up.",
        "Tailored.",
    },
    LowHP = {
        "Ripped.",
        "Need a needle.",
        "Frayed.",
        "Unraveling.",
        "Holes everywhere.",
    },
    Repair = {
        "Mend the seams.",
        "Patch it neatly.",
        "Thread's loose.",
        "Careful with the silk.",
        "Needle and thread.",
    },
    City = {
        "Need more thread.",
        "Silk's pricey.",
        "The tailor shop's busy.",
        "New dye in stock.",
    },
    Combat = {
        "Sleeves up.",
        "Sharp needle.",
        "Cut cloth.",
        "Stitch time.",
    },
    Loot = {
        "Cloth!",
        "Silk.",
        "Runecloth.",
        "Mageweave.",
    },
    Idle = {
        "I should make a new cloak.",
        "This hem's uneven.",
    },
})
More(Data.Professions.Cooking, {
    Kill = {
        "Dinner.",
        "Good cut of meat there.",
        "Supper's on.",
        "Roasted.",
        "Well seasoned, that one.",
    },
    LowHP = {
        "Need food.",
        "Burnt.",
        "Overcooked.",
        "Need a bite.",
        "Hungry and hurt.",
    },
    Repair = {
        "Grease stains.",
        "Smells of onions.",
        "Fix it. Then dinner.",
        "Sauce spilled.",
        "Apron's torn.",
    },
    City = {
        "Need spices.",
        "The inn's cook is good.",
        "Fresh bread.",
        "The cooking trainer's busy.",
    },
    Combat = {
        "Fresh meat.",
        "Kitchen knife.",
        "Season to taste.",
        "Ready the spit.",
    },
    Loot = {
        "Meat!",
        "Spices.",
        "Eggs.",
        "Herbs for the pot.",
    },
    Idle = {
        "I could cook a feast.",
        "Thinking about dinner.",
    },
})

---------------------------------------------------------------------------
-- Traits
---------------------------------------------------------------------------
More(Data.Traits.TavernWarm, {
    Kill = {
        "Another for the tale.",
        "Drinks after this one.",
        "Cheers to that.",
    },
    LowHP = {
        "Somebody fetch me a healing draught.",
        "Ow. Put it on my tab.",
        "Still upright. More or less.",
    },
    Idle = {
        "A good song would help.",
        "The road's better with friends.",
        "Someone tell a joke.",
    },
    Reply = {
        "Ha! Cheers, {target}.",
        "Raise a glass to that, {target}.",
        "Couldn't agree more.",
    },
    Loot = {
        "Tab's paid!",
        "Coin for the next round.",
        "A treat for the table.",
        "Shiny. Drinks are on this.",
    },
    Combat = {
        "Let's make it quick, the inn's waiting.",
        "Last call, you lot.",
    },
    Rescue = {
        "Hang in there, {target}. Coming.",
        "I've got you, {target}. First round's yours after.",
    },
    Victory = {
        "A toast to all of us.",
        "Tonight, the drinks are mine to buy.",
    },
})
More(Data.Traits.OathBound, {
    Kill = {
        "My word, kept.",
        "As I promised.",
        "Justice, sworn.",
    },
    LowHP = {
        "I swore to stand.",
        "My vow holds me up.",
        "Not yet. My word's not done.",
    },
    Idle = {
        "Every vow is a weight.",
        "I keep my promises.",
        "Honor is quiet work.",
    },
    Reply = {
        "Well said, {target}.",
        "Agreed, on my honor.",
        "You have my word, {target}.",
    },
    Loot = {
        "For the cause.",
        "Not for me.",
        "It goes where it's needed.",
        "Shared fairly.",
    },
    Combat = {
        "I gave my word.",
        "Sworn to this.",
    },
    Rescue = {
        "I swore to protect you, {target}.",
        "Hold, {target}. I'm here.",
    },
    Victory = {
        "Oath fulfilled.",
        "We kept our word.",
    },
})
More(Data.Traits.Cynical, {
    Kill = {
        "Oh, joy.",
        "Wonderful. Next.",
        "How thrilling.",
    },
    LowHP = {
        "Of course I'm bleeding.",
        "Typical. Absolutely typical.",
        "Fantastic. Just fantastic.",
    },
    Idle = {
        "Nobody ever thanks the help.",
        "Same thing, different day.",
        "Heroes get statues. I get bruises.",
    },
    Reply = {
        "Sure, {target}.",
        "If you insist.",
        "Brilliant. Truly.",
    },
    Loot = {
        "Junk again.",
        "Barely worth the walk.",
        "Wow. Copper.",
        "Vendor trash.",
    },
    Combat = {
        "Fine. Again.",
        "Wonderful. More fighting.",
    },
    Rescue = {
        "Don't die on me, {target}. The paperwork.",
        "Fine, I'll save you, {target}.",
    },
    Victory = {
        "Hooray. We lived.",
        "Great. What's next?",
    },
})
More(Data.Traits.PlagueHardened, {
    Kill = {
        "Burn the body.",
        "Make sure.",
        "No rising this time.",
    },
    LowHP = {
        "Not the plague. Just steel.",
        "I've lived through worse.",
        "Keep moving. Don't stop.",
    },
    Idle = {
        "Boil the water first.",
        "Never trust a quiet village.",
        "Count the living.",
    },
    Reply = {
        "Fair point, {target}.",
        "Careful, {target}.",
        "True enough.",
    },
    Loot = {
        "Clean it first.",
        "Gloves on.",
        "Check for rot.",
        "Burn what's tainted.",
    },
    Combat = {
        "Don't let it touch you.",
        "Quick, before it spreads.",
    },
    Rescue = {
        "Stay with me, {target}. Breathe.",
        "Don't you die on me, {target}.",
    },
    Victory = {
        "We lived. Again.",
        "Burn the bodies, then rest.",
    },
})
More(Data.Traits.Stoic, {
    Kill = {
        "Ended, without fuss.",
        "Quietly done.",
        "No more.",
    },
    LowHP = {
        "Pain is nothing.",
        "Pain is passing weather.",
        "I endure.",
    },
    Idle = {
        "Silence suits me.",
        "Stillness teaches.",
        "Stillness.",
    },
    Reply = {
        "Then it is so.",
        "Mm. As you say, then.",
        "Mm. True.",
    },
    Loot = {
        "It will serve.",
        "Take what's needed.",
        "Leave the rest.",
        "Sufficient.",
    },
    Combat = {
        "Ready.",
        "Calm, then strike.",
    },
    Rescue = {
        "Stay behind me, {target}.",
        "Stay down, {target}. I'll handle it.",
    },
    Victory = {
        "It is over. Good.",
        "We stood. That is enough.",
    },
})
More(Data.Traits.HotBlooded, {
    Kill = {
        "Ha. Next.",
        "Barely warmed up.",
        "More of them, please.",
    },
    LowHP = {
        "That only makes me angry.",
        "Blood's up now.",
        "Hit me again. I dare you.",
    },
    Idle = {
        "I'm bored. Find me a fight.",
        "Too quiet.",
        "My blood's itching.",
    },
    Reply = {
        "Ha! Right, {target}.",
        "Now you're talking, {target}.",
        "That's the fire.",
    },
    Loot = {
        "Mine!",
        "Grab it.",
        "Ha, look at that.",
        "Take it all.",
    },
    Combat = {
        "Finally, a fight.",
        "Let's go.",
    },
    Rescue = {
        "Hang on, {target}! I'm coming.",
        "Back off from {target}.",
    },
    Victory = {
        "Ha! Who's next?",
        "That got the blood up.",
    },
})

---------------------------------------------------------------------------
-- Allegiances
---------------------------------------------------------------------------
More(Data.Allegiances.ThoriumBrotherhood, {
    Kill = {
        "The Brotherhood thanks you.",
        "Ragnaros' minions burn too.",
        "Thorium's tougher than you.",
        "The Molten Core taught me worse.",
    },
    Idle = {
        "I owe Lokhtos a favor.",
        "Thorium Point never sleeps.",
        "Need more dark iron ore.",
        "The Searing Gorge is home enough.",
    },
    LowHP = {
        "Forged hard. Still holding.",
        "Dark iron in my blood.",
        "Not yet. The Brotherhood needs me.",
        "Hot, but holding.",
    },
    Loot = {
        "Dark iron ore. Excellent.",
        "For Thorium Point.",
        "Fiery cores, maybe.",
        "The Brotherhood will want this.",
        "Molten stuff. Careful.",
    },
    Greet = {
        "The Brotherhood greets you, {target}.",
    },
})
More(Data.Allegiances.CenarionCircle, {
    Kill = {
        "The balance is restored.",
        "Nature's justice.",
        "The Circle's balance, kept.",
        "For Moonglade.",
    },
    Idle = {
        "Silithus troubles me.",
        "The Emerald Dream calls.",
        "Moonglade is peaceful this season.",
        "Nature heals slowly.",
    },
    LowHP = {
        "Nature, heal me.",
        "The roots hold.",
        "Not yet. The balance needs me.",
        "Breathe, as the forest breathes.",
    },
    Loot = {
        "For the Circle.",
        "Herbs for Moonglade.",
        "A natural gift.",
        "The Circle will study this.",
        "Leave some for the forest.",
    },
    Greet = {
        "Balance be with you, {target}.",
    },
})
More(Data.Allegiances.ExplorersLeague, {
    Kill = {
        "One more for the field notes.",
        "Note it down: hostile, now harmless.",
        "Brann would want a sketch.",
        "Archaeology is dangerous work.",
    },
    Idle = {
        "Uldaman has more secrets.",
        "I should update my maps.",
        "The Titans left so much behind.",
        "Wonder where Brann is now.",
    },
    LowHP = {
        "The dig's getting rough.",
        "Not buried yet.",
        "Need a medic. And a map.",
        "Every explorer bleeds sometime.",
    },
    Loot = {
        "An artifact! Maybe.",
        "For the Hall of Explorers.",
        "Catalog it.",
        "Old. Very old.",
        "Brann would love this.",
    },
    Greet = {
        "The League welcomes you, {target}.",
    },
})
More(Data.Allegiances.ScarletCrusade, {
    Kill = {
        "Purged by the Light.",
        "The Light's judgment.",
        "Another sinner falls.",
        "One more cleansed.",
    },
    Idle = {
        "Hearthglen's bells ring true.",
        "Trust no one with a cough.",
        "The Crusade is watching.",
        "Mograine's will be done.",
    },
    LowHP = {
        "The Crusade does not bleed out. Not here.",
        "I bleed for the Crusade.",
        "Faith, not flesh.",
        "Not until the plague is gone.",
    },
    Loot = {
        "For the Crusade.",
        "Blessed coin.",
        "A tithe for the Cathedral.",
        "Purify it first.",
        "The Light provides, they say.",
    },
    Greet = {
        "The Crusade remembers you, {target}.",
    },
})
More(Data.Allegiances.Steamwheedle, {
    Kill = {
        "Bad for business. Yours.",
        "Write that one off.",
        "Contract terminated.",
        "Profit margins improving.",
    },
    Idle = {
        "Gadgetzan's market is up.",
        "Booty Bay rates are steep.",
        "Time is money.",
        "Always be selling.",
    },
    LowHP = {
        "This is costing me.",
        "Not good for business.",
        "Insurance won't cover this.",
        "Need a goblin medic. Expensive.",
    },
    Loot = {
        "Profit, profit.",
        "Sellable.",
        "That'll fetch a price in Gadgetzan.",
        "Inventory up.",
        "Ka-ching.",
    },
    Greet = {
        "Good business, {target}.",
    },
})
More(Data.Allegiances.HordeWarCouncil, {
    Kill = {
        "The Horde endures.",
        "Victory for the Council.",
        "Another for the War Council's tally.",
        "As the Warchief wills.",
    },
    Idle = {
        "Grommash Hold is loud today.",
        "The Council has new orders.",
        "The Horde is strong.",
        "Orgrimmar never rests.",
    },
    LowHP = {
        "The Horde does not fall.",
        "Blood for the Horde.",
        "Stand. For the Warchief.",
        "I will not yield.",
    },
    Loot = {
        "For the Horde's coffers.",
        "Spoils of war.",
        "The Council will use this.",
        "War supplies.",
        "Good. Arm the troops.",
    },
    Greet = {
        "The Council salutes you, {target}.",
    },
})
More(Data.Allegiances.SI7, {
    Kill = {
        "Clean. Nobody saw.",
        "Mathias will hear of it.",
        "Target eliminated.",
        "Quiet work.",
    },
    Idle = {
        "Shaw has a new assignment.",
        "Watch the shadows.",
        "Nobody notices the help.",
        "Stormwind's secrets are safe.",
    },
    LowHP = {
        "Compromised.",
        "Need extraction.",
        "Still operational.",
        "Mission continues.",
    },
    Loot = {
        "Intelligence.",
        "Evidence for Shaw.",
        "Classified.",
        "Pocketed.",
        "Useful to the Barons, maybe.",
    },
    Greet = {
        "We never met, {target}.",
    },
})
More(Data.Allegiances.Defias, {
    Kill = {
        "VanCleef's justice.",
        "Westfall remembers.",
        "Paid in blood.",
        "The Brotherhood sends regards.",
    },
    Idle = {
        "Stormwind still owes us.",
        "The Deadmines hold our hope.",
        "Westfall will rise.",
        "No more unpaid work.",
    },
    LowHP = {
        "We've been beaten before.",
        "The Brotherhood endures.",
        "Pain is nothing to a stonemason.",
        "Not done. Westfall's not done.",
    },
    Loot = {
        "Back pay.",
        "For the Brotherhood's chest.",
        "Westfall's share.",
        "What Stormwind owes.",
        "Mine by right.",
    },
    Greet = {
        "The Brotherhood sees you, {target}.",
    },
})
More(Data.Allegiances.Bloodsail, {
    Kill = {
        "Walk the plank.",
        "Overboard.",
        "Fish food.",
        "Yarr. Done.",
    },
    Idle = {
        "Booty Bay's full of goblins.",
        "Revilgaz will pay.",
        "Need a ship.",
        "Smell that sea air.",
    },
    LowHP = {
        "Scuttled, but floating.",
        "I've been keelhauled worse.",
        "Patch the hull.",
        "Not sinking today.",
    },
    Loot = {
        "Plunder for the hold.",
        "Booty.",
        "Treasure for the captain.",
        "Doubloons, by the look of it.",
        "Mine, by pirate law.",
    },
    Greet = {
        "Ahoy, {target}. The Bloodsail greets you.",
    },
})
More(Data.Allegiances.ArgentDawn, {
    Kill = {
        "The Dawn prevails.",
        "Rest, and stay at rest.",
        "One less for the Scourge.",
        "For Light's Hope.",
    },
    Idle = {
        "Light's Hope Chapel needs more hands.",
        "The Plaguelands won't heal themselves.",
        "Tirion's faith gives me hope.",
        "Every cleansed field matters.",
    },
    LowHP = {
        "Dawn's light, hold me up.",
        "Not until the plague is gone. Not yet.",
        "Dawn always comes.",
        "I bleed, but I stand.",
    },
    Loot = {
        "Something for the Dawn's quartermaster.",
        "Scourgestones, maybe.",
        "Supplies for Light's Hope.",
        "The quartermaster will want this.",
        "Blessed. Useful.",
    },
    Greet = {
        "The Dawn welcomes you, {target}.",
    },
})

---------------------------------------------------------------------------
-- Character Anchors
---------------------------------------------------------------------------
More(Data.AnchorLines.Oath, {
    Combat = {
        "My oath stands with me.",
        "I swore {oath}. You're in the way.",
        "For the oath.",
    },
    LowHP = {
        "My oath won't let me fall.",
        "Not before {oath}.",
        "I swore. I stand.",
        "An oath outlasts pain.",
    },
    Kill = {
        "That's for my oath.",
        "My oath, served.",
        "Closer to {oath}.",
        "Promise kept.",
    },
    Idle = {
        "I think about my oath often.",
        "{oath}. Every day.",
        "Some oaths keep you awake.",
        "My oath is heavy. Good.",
    },
})
More(Data.AnchorLines.Nemesis, {
    Combat = {
        "Every fight is practice for {nemesis}.",
        "You fight like {nemesis}'s lackey.",
        "I'll find {nemesis} after you.",
    },
    LowHP = {
        "{nemesis} won't see me fall.",
        "Not until {nemesis} falls.",
        "I owe {nemesis} a reckoning first.",
        "Get up. {nemesis} is still out there.",
    },
    Kill = {
        "Practice for {nemesis}.",
        "{nemesis} is next.",
        "That's how {nemesis} will fall.",
        "One step nearer to {nemesis}.",
    },
    Idle = {
        "I wonder where {nemesis} is tonight.",
        "{nemesis} owes me.",
        "One day, {nemesis}.",
        "I keep {nemesis}'s name close.",
    },
})
More(Data.AnchorLines.Catchphrase, {
    Combat = {
        "Keep this in mind: {catchphrase}",
        "A thought: {catchphrase}",
        "{catchphrase} Now move.",
        "Say it with me: {catchphrase}",
    },
    LowHP = {
        "Still standing. {catchphrase}",
        "{catchphrase} Hurts, though.",
        "Even bleeding: {catchphrase}",
        "{catchphrase} Mostly.",
        "Deep breath. {catchphrase}",
    },
    Kill = {
        "{catchphrase} See?",
        "Told you. {catchphrase}",
        "And that's why: {catchphrase}",
        "{catchphrase} Every time.",
    },
    Idle = {
        "You know what I always say. {catchphrase}",
        "{catchphrase} Words to live by.",
        "Someone asked me once. I said: {catchphrase}",
        "{catchphrase} Never fails.",
        "As my old friend said: {catchphrase}",
    },
})

---------------------------------------------------------------------------
-- Hometown (roots)
---------------------------------------------------------------------------
More(Data.HometownKindLines, {
    Combat = {
        "{hometown} didn't raise a coward.",
        "Back home, they'd cheer this.",
    },
    LowHP = {
        "Not dying before I see {hometown} again.",
        "Think of {hometown}. Keep standing.",
        "Someone in {hometown} is waiting for me.",
        "I promised {hometown} I'd come back.",
    },
    Kill = {
        "That's one for the folks in {hometown}.",
        "They'll toast this in {hometown}.",
        "A tale worth taking home.",
    },
    Loot = {
        "That'd sell well in {hometown}.",
        "A gift for someone back home.",
        "I'll send this to {hometown}.",
        "Folk in {hometown} would like this.",
        "Something to show off back home.",
    },
    Idle = {
        "I miss the bread in {hometown}.",
        "The road always leads back to {hometown}.",
        "Wonder who's tending the fires in {hometown}.",
    },
})
