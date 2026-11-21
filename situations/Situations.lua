--[[
    Monologue Data Module: Situation Lines
    PURE DATA TABLE.

    Lines that react to the moment. When a pull or signature line is about to be said, the
    engine may use one of these instead (Voice Lines tab, "React to the world" slider). See
    the Situations section of Monologue_Core.lua for how each key is detected.

    Shared by every race and class, so keep them faction- and class-neutral. A race, class,
    persona or character profile can replace any pool with
        Situations = { Undead = { ... } }

    Tokens: {mob} the creature, {count} grind streak number, {killer} what last killed you,
    {subzone}, {daytime} ("tonight", "this morning"...), {target} an enemy player's name.
    Follow VOICE_GUIDE.md: specific, in-world, mostly calm.
--]]

local S = MonologueEngine.Data.Situations

---------------------------------------------------------------------------
-- Memory: what just happened
---------------------------------------------------------------------------

-- Pulling the same kind of creature that last killed you (within 30 min)
S.Revenge = {
    "{killer}. We have unfinished business.",
    "Remember me? You should. You put me in the dirt.",
    "Last time you got lucky.",
    "I walked back from the graveyard for this.",
    "Same face, same claws. Different ending.",
    "That's the one. Easy now. Not twice.",
    "The spirit healer sends her regards.",
    "Round two. I've been thinking about it the whole way back.",
}

-- The 5th, 10th, 15th... pull of the same creature in this zone
S.GrindStreak = {
    "{mob} number {count}. They don't run out.",
    "That's {count} of the {mob} lot. I've stopped feeling bad.",
    "{mob} number {count}. They breed fast around here.",
    "Their mothers must be busy.",
    "I know this one's whole family by now.",
    "Same fight, again. My arm knows the way.",
    "Another one. Where do they keep coming from?",
    "{mob} number {count}. Somebody had better be paying for this.",
}

-- The first fight within 10 min of dying
S.AfterDeath = {
    "Let's try that again. Carefully.",
    "Still tastes like graveyard.",
    "Slower this time. I'm out of luck to spend.",
    "That walk back was long enough to think.",
    "My gear's still sore from last time.",
    "Back on my feet. Mostly.",
    "No more dying today. That's the plan.",
}

-- The first fight within 5 min of levelling up
S.AfterLevelUp = {
    "Let's see what's changed.",
    "Feeling stronger. Let's test it.",
    "A bit more to give than yesterday.",
    "New strength. Old habits.",
    "That last fight taught me something. Watch.",
    "Something's different. Better.",
    "Fresh legs. Let's use them.",
}

---------------------------------------------------------------------------
-- What you're fighting: rank and level
---------------------------------------------------------------------------

S.WorldBoss = {
    "That's not a fight. That's weather.",
    "Everyone stay calm and stay behind me.",
    "Big. Very big. Fine.",
    "Somebody write down that I was here.",
    "We're going to need more bandages.",
    "If I fall, tell them I swung first.",
}

S.RareElite = {
    "Haven't seen one like you in years.",
    "That one's special. Careful.",
    "Rare, and angry about it.",
    "Folk talk about this one in the taverns.",
    "Mind the hits. This one's earned its name.",
    "Worth the trouble, I'd wager.",
}

S.Rare = {
    "Well, look at you. Not many like you left.",
    "Heard rumours of this one.",
    "You're a long way from the bestiary, {mob}.",
    "That's a trophy if ever I saw one.",
    "Somebody's been looking for you.",
    "Rare sight. Shame about what comes next.",
    "Finally. I've walked this road three times for you.",
}

S.Elite = {
    "This one's tougher. Mind yourself.",
    "Thick hide on this one.",
    "Big for its kind. Slow and steady.",
    "Not a fight to rush.",
    "Hits like a cart. Stay sharp.",
    "Let's be smart about this.",
}

-- Creature 3+ levels above you
S.Outlevelled = {
    "This might be a mistake.",
    "Bigger than me. Not the first time.",
    "If this goes badly, I was never here.",
    "Bad odds. I've had worse.",
    "Stay calm. Don't let it see you sweat.",
    "Bit above my station, this one.",
    "Mother always said I'd die stubborn.",
}

-- Grey creature: no challenge left
S.Trivial = {
    "Shoo.",
    "Little thing like you, and still you try.",
    "Not worth the sweat.",
    "Go home. Seriously.",
    "I've outgrown this road.",
    "This won't take long.",
    "Brave. Not smart, but brave.",
}

---------------------------------------------------------------------------
-- What you're fighting: creature type
---------------------------------------------------------------------------

S.Undead = {
    "Back to the ground with you.",
    "You should have stayed buried.",
    "Smells like an old crypt.",
    "Whatever you were once, rest.",
    "Dead things shouldn't walk.",
    "The Scourge leaves its rubbish everywhere.",
    "Bones and rot. Lovely.",
    "Lie still this time.",
}

S.Demon = {
    "Go back to whatever hole spat you out.",
    "This world isn't yours.",
    "Fel stink. Unmistakable.",
    "Burning Legion trash.",
    "Something summoned you. Bad idea.",
    "Your masters aren't coming.",
}

S.Dragonkin = {
    "Mind the breath.",
    "Scales. Of course it's scales.",
    "Dragonflights and their little errands.",
    "Watch the tail.",
    "One of Deathwing's brood, I'd wager.",
    "Old blood in that one. Respect it.",
}

S.Elemental = {
    "Nothing to bleed. Just keep hitting.",
    "Angry rock. Or water. Or both.",
    "Whoever summoned you is long gone.",
    "No eyes, no mercy.",
    "Someone broke a binding. Again.",
    "Back to the elements with you.",
}

S.Giant = {
    "Don't stand where it steps.",
    "Big. Slow. Hits like a landslide.",
    "Aim for the knees.",
    "The bigger they are, the louder the fall.",
    "I'll need a ladder.",
    "Older than the hills. Probably made some of them.",
}

S.Mechanical = {
    "Somebody's going to want this back.",
    "Gears and grease. Mind the sparks.",
    "Find the off switch.",
    "Whoever built this owes me a repair bill.",
    "Clanks a lot for a guard.",
    "Steam's leaking. Good sign.",
}

S.Beast = {
    "Easy, easy. Nothing personal.",
    "Just hungry, aren't you.",
    "Nice coat. I'll take it.",
    "Wrong path, friend.",
    "Teeth and temper.",
    "Nature's in a mood today.",
    "Fair fight. More or less.",
}

---------------------------------------------------------------------------
-- What you're fighting: beast families
---------------------------------------------------------------------------

S.Spider = {
    "Too many legs. Far too many.",
    "Don't get caught in the webs.",
    "Hate spiders. Always have.",
    "Mind the bite. They're never clean.",
    "Eight eyes and none of them friendly.",
    "Who keeps letting these grow so big?",
}

S.Raptor = {
    "Fast ones. Watch the claws.",
    "Never alone, raptors. Look for the others.",
    "Clever little monsters.",
    "Feathers and fury.",
    "There's always another in the grass.",
    "Mind the leap.",
}

S.Wolf = {
    "Where there's one, there's a pack.",
    "Hungry one. Thin winter.",
    "Easy, pup.",
    "Fur's worth something to a tanner.",
    "Mind the throat.",
    "Grey and hungry. Same as ever.",
}

S.Bear = {
    "Big lad. Sorry, big lad.",
    "Don't let it get its arms around you.",
    "Wrong cave, wrong day.",
    "That's a lot of bear.",
    "Mind the claws. They don't miss twice.",
    "Thick fur. Hit harder.",
}

S.Crocolisk = {
    "All teeth, no manners.",
    "Stay out of the water with it.",
    "Mind the jaws.",
    "Ugly as a boot. Tough as one too.",
    "Lazy until it isn't.",
    "Snap at me and see.",
}

---------------------------------------------------------------------------
-- What you're fighting: known creatures and gangs (by name)
---------------------------------------------------------------------------

S.Murloc = {
    "Not the gargling. Anything but the gargling.",
    "Where there's one murloc, there's eleven.",
    "Mrrgl yourself.",
    "Keep an eye on the water. More are coming.",
    "Fish-men. Always the fish-men.",
    "Why is it always the shoreline?",
}

S.Kobold = {
    "You no take candle. I know, I know.",
    "Back to your tunnels.",
    "They never stop digging.",
    "Mind the candle. Hot wax hurts.",
    "Small, loud, and everywhere.",
    "I'm not here for your candle.",
}

S.Gnoll = {
    "Gnolls. Smell them before you see them.",
    "Back to Hogger with you.",
    "All bark and bad teeth.",
    "Pack animals in armour.",
    "Somebody's been raiding farms again.",
    "Mind the flails.",
}

S.Trogg = {
    "Troggs. Up from the deep again.",
    "Dumb, strong, and angry.",
    "Back underground.",
    "Smells like a cave floor.",
    "They come up from Uldaman like water.",
    "Not much in there behind the eyes.",
}

S.Ogre = {
    "One head or two, it's still an ogre.",
    "Big lad. Slow lad.",
    "Smash this, then.",
    "Mind the club.",
    "Ogres never learn. Lucky for me.",
    "Bigger target. Easier to hit.",
}

S.Harpy = {
    "That screeching cuts right through you.",
    "Feathers everywhere.",
    "Down from your rock, then.",
    "Mind the talons.",
    "Loud, aren't you.",
    "Harpies. Nothing but noise and claws.",
}

S.Centaur = {
    "Hooves and arrows. Stay close.",
    "Raiders. Always raiders.",
    "You won't outrun me here.",
    "Kolkar or Galak, it's all the same.",
    "Mind the charge.",
    "They fight like the plains: wide and mean.",
}

S.Quilboar = {
    "Mind the thorns.",
    "Smells like a sty.",
    "Razorfen rubbish.",
    "Tusks first, brains never.",
    "Back to your briars.",
    "Spiky lot, the quilboar.",
}

S.Naga = {
    "Something out of the deep.",
    "Scales and spite.",
    "Back to the sea with you.",
    "Old blood, older grudges.",
    "Mind the tail and the tide.",
    "Naga. Never a good sign.",
}

S.Satyr = {
    "Satyrs. The forest's worst mistake.",
    "Sold your soul for those horns.",
    "Fel on your breath.",
    "Hooves and lies.",
    "Back to whatever you sold out to.",
    "The woods would be cleaner without you.",
}

S.Defias = {
    "Red bandanas. Of course.",
    "The Brotherhood sends another.",
    "VanCleef can't pay you enough for this.",
    "Westfall's had enough of your lot.",
    "Masks don't make you brave.",
    "Thieves with a cause are still thieves.",
}

S.Scarlet = {
    "The Crusade. Zealots in red.",
    "Your Light won't save you here.",
    "Another true believer.",
    "They'd burn the world to purify it.",
    "Red tabard, empty head.",
    "Mind the sermon. They'll want to give one.",
}

S.Syndicate = {
    "Syndicate. Hired knives.",
    "Who's paying you this week?",
    "Thieves in Alterac colours.",
    "The Ravenholdt lot would love to see this.",
    "Cutthroats. Watch your purse.",
    "Old nobles, new crimes.",
}

S.DarkIron = {
    "Dark Iron. Thaurissan's lot.",
    "Smells of the forge and fel.",
    "Back to your mountain.",
    "Ragnaros won't help you here.",
    "Iron fists, black hearts.",
    "Your clan started this centuries ago.",
}

S.Bloodsail = {
    "Bloodsail. Booty Bay will pay for this.",
    "Pirates. Hide your coin.",
    "Back to the boat.",
    "Mind the cutlass.",
    "Your captain's not coming for you.",
    "Arr yourself.",
}

S.Venture = {
    "Venture Company. Here to strip the land again.",
    "Profit margins mean nothing to me.",
    "Goblins with a contract. Wonderful.",
    "Your shredders aren't welcome.",
    "Tell your foreman this one's on me.",
    "Put down the axe. The trees are fine.",
}

---------------------------------------------------------------------------
-- Your own state
---------------------------------------------------------------------------

-- Below 35% health when the fight starts
S.Hurt = {
    "Not my best moment for this.",
    "Still bleeding from the last one. Fine.",
    "I'll patch up after. If there is an after.",
    "Bad timing, {mob}. For both of us.",
    "Plenty left in me. Probably.",
    "Can't a body catch its breath?",
    "One more. Then the bandages.",
}

-- Mana users below 15% mana
S.LowMana = {
    "Running on fumes here.",
    "Dry as a desert well.",
    "Not much left in the tank.",
    "Should have sat down and had a drink first.",
    "Make this quick. I've got nothing spare.",
    "Fumes and stubbornness. That's all I've got.",
}

-- After "You feel drunk" (15 min, or until sober)
S.Drunk = {
    "Which one of you is the real one?",
    "Stand still. Both of you.",
    "I've fought worse drunk. Probably.",
    "Hold my drink. Oh. I finished it.",
    "Room's spinning. Doesn't matter.",
    "This was a better idea at the bar.",
    "Hic. Pardon. Right.",
}

S.Swimming = {
    "Fighting wet. Brilliant.",
    "Can't get any footing in this.",
    "Water's cold, temper's hot.",
    "Mind the current.",
    "Not how I wanted to take a bath.",
    "Fine. We'll do this in the water.",
    "Plate armor and deep water. Brilliant combination.",
    "My robes weigh a ton when they're soaked.",
    "Powder's wet. Of course it is.",
}

---------------------------------------------------------------------------
-- Where and when
---------------------------------------------------------------------------

-- Inside a 5-man dungeon
S.Dungeon = {
    "Stay together. Nobody wanders off.",
    "Tight halls. Watch the corners.",
    "Deeper we go.",
    "Mind the patrols.",
    "Keep the healer breathing.",
    "One room at a time.",
    "Smells like the last place. Worse, maybe.",
}

-- Server time 21:00 to 05:00
S.Night = {
    "Late for this.",
    "Hard to see a thing out here {daytime}.",
    "Should be asleep. Instead, this.",
    "Night's when the bad things come out. Hello.",
    "Moonlight's enough for this.",
    "Quiet night. Was.",
    "Stars are out. So's my blade.",
}

---------------------------------------------------------------------------
-- Enemy players by class (world PvP, first clashes and repeat fights)
---------------------------------------------------------------------------

S.Vs_Warrior = {
    "Big armour, bigger temper.",
    "Let's see how hard you really hit, {target}.",
    "Plate and pride. I'll dent both.",
    "Don't let the shouting scare you.",
    "Steel on steel, then.",
    "Another one who thinks the answer is a bigger axe.",
}

S.Vs_Paladin = {
    "Here comes the bubble.",
    "The Light keeps you up, does it? Let's see.",
    "Pray quickly, {target}.",
    "Hammer and halo. Seen it.",
    "This'll take a while. Paladins never fall over.",
    "Save the sermon.",
}

S.Vs_Hunter = {
    "Mind the traps.",
    "Close the gap. Fast.",
    "Call off the pet or lose it.",
    "Arrows don't help at arm's length, {target}.",
    "Another one hiding behind a beast.",
    "I see the trap. I see you.",
}

S.Vs_Rogue = {
    "Of course it's a rogue.",
    "Back to the shadows with you.",
    "I felt that one coming.",
    "Knives in the back. How original.",
    "Stand still and fight, {target}.",
    "Should have checked behind me.",
}

S.Vs_Priest = {
    "Healer first. Always.",
    "Scream all you like.",
    "Your god's busy today, {target}.",
    "Mind the fear.",
    "Shadow or light, it bleeds the same.",
    "No shield lasts forever.",
}

S.Vs_Shaman = {
    "Kick the totems over first.",
    "Lightning and spirits. Seen it.",
    "The elements won't save you, {target}.",
    "Mind the shock.",
    "Another one talking to rocks.",
    "Purge me if you like. I'm still coming.",
}

S.Vs_Mage = {
    "Close the gap before it blinks.",
    "Frost and fire. Either way it hurts.",
    "Don't get turned into a sheep.",
    "Paper robes, {target}. Bad choice.",
    "Blink all you want.",
    "Mind the nova.",
}

S.Vs_Warlock = {
    "Kill the warlock, ignore the pet.",
    "Mind the fear. Mind the dots.",
    "Fel stink on this one.",
    "Your demon won't save you, {target}.",
    "Curses and cowardice.",
    "Soulstone or not, you're going down.",
}

S.Vs_Druid = {
    "Bear, cat, tree or bird. Pick one.",
    "Roots won't hold me long.",
    "Shapeshift all you like, {target}.",
    "Mind the heals. They never stop.",
    "Nature's on my side today.",
    "Stop changing and fight.",
}
