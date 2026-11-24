--[[
    Monologue Data Module: Taunts for the other faction, and race nicknames
    PURE DATA TABLE.

    How mean your character is to the other faction is chosen per character on My Voice >
    Enemy Faction (also /mono taunts): Off (default), Civil, Rough or Savage. Taunts are said
    when you target an enemy player you have no grudge with yet, and now and then when you
    open a fight with one. Grudge tiers (Vendetta, Nemesis...) keep their own lines.

    Pools, by level:
      [Level].Horde / .Alliance   said to any enemy player of that faction
      [Level].<raceFile>          said only to that race (Orc, Troll, Tauren, Scourge, Human,
                                  Dwarf, Gnome, NightElf, Skyborne)
    A Savage pool is the faction lines plus the race's own lines.

    Tokens (Savage): {nick} / {nicks} become the target race's nickname, one or many
    ("grass muncher" / "grass munchers"); {Nick} / {Nicks} are the same with a capital letter.
    {target} is the enemy's name, as everywhere else.

    Nicknames: also used by the translator when "Race nicknames" is on (My Voice, or
    /mono nicknames), so "the orcs are coming" becomes "the green skins are coming".
      faction   whose race it is (nil: the race can join either side)
      words     what the translator swaps: "one" (singular), "many" (plural) or "either"
                (same word for both, like tauren: singular after "a", "one", "this"... or
                before a class name, plural otherwise)

    Write lines in plain English; the race accent is added on top. Keep them calm and
    specific, like every other pool (VOICE_GUIDE.md): no more than a third ending in "!".
--]]

local T = {}
MonologueEngine.Data.Taunts = T

T.Nicknames = {
    Tauren = { faction = "Horde", one = "grass muncher", many = "grass munchers",
        words = { tauren = "either", taurens = "many" } },
    Scourge = { faction = "Horde", one = "bone back", many = "bone backs",
        words = { undead = "either", forsaken = "either" } },
    Orc = { faction = "Horde", one = "green skin", many = "green skins",
        words = { orc = "one", orcs = "many" } },
    Troll = { faction = "Horde", one = "tusk sucker", many = "tusk suckers",
        words = { troll = "one", trolls = "many" } },
    NightElf = { faction = "Alliance", one = "pointy", many = "pointies",
        words = { ["night elf"] = "one", ["night elves"] = "many", elf = "one", elves = "many",
            kaldorei = "either" } },
    Human = { faction = "Alliance", one = "pinkskin", many = "pinkskins",
        words = { human = "one", humans = "many" } },
    Dwarf = { faction = "Alliance", one = "stumpy", many = "stumpies",
        words = { dwarf = "one", dwarves = "many", dwarfs = "many" } },
    Gnome = { faction = "Alliance", one = "ankle biter", many = "ankle biters",
        words = { gnome = "one", gnomes = "many" } },
    Skyborne = { one = "feather duster", many = "feather dusters",
        words = { skyborne = "either" } },
}

---------------------------------------------------------------------------
-- Civil: an honest rivalry. No insults.
---------------------------------------------------------------------------
T.Civil = {
    Horde = {
        "Nothing personal, Horde. You're just on the wrong side of the line.",
        "Fair fight, then.",
        "Long way from Orgrimmar, aren't you?",
        "I'd share a fire with you some other night. Not this one.",
        "Raise your guard. I'll wait.",
        "Let's keep it clean.",
        "One of us walks back from the graveyard. Let's find out who.",
        "The war didn't ask either of us.",
        "Steady. You can have the first swing.",
        "Your banner, my banner. That's all this is.",
        "Fight well, {target}.",
        "For the Alliance, and no hard feelings!",
    },
    Alliance = {
        "Nothing personal. Your king sent you, my Warchief sent me.",
        "Fight well. I'd want the same.",
        "Long way from Stormwind, aren't you?",
        "Strength and honor. Then we fight.",
        "Lift your shield. I won't strike an open guard.",
        "Our fathers fought. Now it's us.",
        "No hard words. Just steel.",
        "One of us walks to the spirit healer. Let's see who.",
        "You came a long way to bleed here.",
        "Show me what your trainers taught you, {target}.",
        "Easy. We do this properly.",
        "For the Horde, and no hard feelings!",
    },
}

---------------------------------------------------------------------------
-- Rough: real trash talk, but no names for the race.
---------------------------------------------------------------------------
T.Rough = {
    Horde = {
        "Back to Durotar. Take the dust with you.",
        "Smells like the Barrens over here.",
        "Go home, Horde. Nobody invited you.",
        "Your Warchief can collect you at the graveyard.",
        "I've seen kobolds with better footwork.",
        "Run back to the Crossroads, {target}.",
        "Another Horde tourist. Wonderful.",
        "Ugly and slow. Pick one, at least.",
        "Your wolf smells better than you do. Barely.",
        "Not in our hills.",
        "Stay down this time!",
        "Keep walking. Ashenvale isn't yours.",
    },
    Alliance = {
        "Back behind your walls.",
        "Run home to your boy-king.",
        "Smells like perfume and fear.",
        "Shiny armor. Soft inside.",
        "Another Alliance tourist. Wonderful.",
        "Nobody wants you in the Barrens.",
        "You fight like a Stormwind guard. Badly.",
        "Run back to Southshore, {target}.",
        "Too pretty to bleed? We'll see.",
        "Your paladins can't save you out here.",
        "Stay down this time!",
        "Keep walking. This road is ours.",
    },
    Orc = {
        "All tusk, no sense.",
        "Thrall let you out on your own?",
        "Go shout at a rock. It'll listen.",
    },
    Troll = {
        "Back to the Echo Isles. The crabs miss you.",
        "Stand up straight. You're embarrassing yourself.",
        "Your voodoo doesn't scare me.",
    },
    Tauren = {
        "Big target. Hard to miss.",
        "Mind the hooves. I just had these boots done.",
        "Big and slow. My favorite kind.",
    },
    Scourge = {
        "You smell like the Undercity sewers.",
        "Something just fell off you.",
        "Did Sylvanas send you, or did you wander off?",
    },
    Human = {
        "Short life, short temper.",
        "Back to farming. Westfall needs you.",
        "Did the guards let you out alone?",
    },
    Dwarf = {
        "Sober up and try again.",
        "Your beard's doing more work than you are.",
        "Stand on a rock so I can see you.",
    },
    Gnome = {
        "Wait, where'd it go? Oh. Down there.",
        "Go fix Gnomeregan.",
        "A wind-up toy with a temper.",
    },
    NightElf = {
        "Back to your tree.",
        "Ten thousand years and that's your best?",
        "Purple and proud of it, are we?",
    },
    Skyborne = {
        "Fly back to your island.",
        "Keep your feathers out of my face.",
        "Long fall from up there.",
    },
}

---------------------------------------------------------------------------
-- Savage: the race nicknames, said to their face.
---------------------------------------------------------------------------
T.Savage = {
    Horde = {
        "Back to your hole, {nick}.",
        "Another {nick}. They never stop coming.",
        "Hold still, {nick}. This won't take long.",
        "Every {nick} I put down is one less for the guards.",
        "Go crying to Orgrimmar, {nick}.",
        "Look at this {nick}. Thinks it's a soldier.",
        "Run, {nick}. I like it when they run!",
        "Filthy {nick}.",
        "{Nick}. Figures.",
        "They breed you {nicks} ugly and slow, don't they?",
        "Tell the other {nicks} where you fell.",
        "I'll hang your hide in Southshore, {nick}.",
    },
    Alliance = {
        "Back to your walls, {nick}.",
        "Another {nick}. They never learn.",
        "Kneel, {nick}. It's quicker.",
        "Every {nick} I drop is a gift to the Warchief.",
        "Go crying to Stormwind, {nick}.",
        "Look at this {nick}. Dressed for a parade.",
        "Run, {nick}. I like it when they run!",
        "Soft little {nick}.",
        "{Nick}. Figures.",
        "You {nicks} never learned to hold a line.",
        "Tell the other {nicks} where you fell.",
        "I'll wear your helm home, {nick}.",
    },
    Tauren = {
        "Put the cud down, grass muncher.",
        "Go back to Mulgore and chew something.",
        "Thunder Bluff's short one grass muncher tonight.",
        "Big grass muncher. Bigger hide for my wall.",
        "You've got grass in your teeth, muncher.",
        "Moo all you like. You're still going down.",
    },
    Scourge = {
        "Stand up straight, bone back. Oh, right. You can't.",
        "Back in the box, bone back.",
        "Tirisfal wants its corpse back.",
        "Your jaw's hanging off, bone back.",
        "I've seen better posture on a ghoul.",
        "One good swing and you're kindling, bone back.",
    },
    Orc = {
        "Back to the camps, green skin.",
        "Durotar dust and a bad attitude. Typical green skin.",
        "Your Warchief has plenty of green skins to waste.",
        "Grunt for me, green skin.",
        "Lordaeron kept your kind in pens. Should've kept you.",
        "Let's see if you bleed green too.",
    },
    Troll = {
        "Back to the Echo Isles, tusk sucker.",
        "Stop slouching, tusk sucker.",
        "Your loa can't hear you from here, tusk sucker.",
        "Another tusk sucker out of the jungle.",
        "Mind the tusks. You'll have your own eye out.",
        "Sen'jin must be empty if they sent you.",
    },
    Human = {
        "Back to Elwynn, pinkskin.",
        "Soft hands. A pinkskin through and through.",
        "Pinkskins bleed easy.",
        "Your boy-king will need another pinkskin by morning.",
        "Westfall's full of pinkskins who thought they were tough.",
        "Did the guards let you out alone, pinkskin?",
    },
    Dwarf = {
        "Stand on a crate, stumpy. I can't see you.",
        "Back to your tunnels, stumpy.",
        "All beard and no legs.",
        "Ironforge sends its stumpies out drunk, I see.",
        "Hop up, stumpy. I'll wait.",
        "Your beard's taller than you, stumpy.",
    },
    Gnome = {
        "Get off my boot, ankle biter.",
        "Gnomeregan's lost, ankle biter. So are you.",
        "I nearly stepped on you, ankle biter.",
        "An ankle biter with a wand. Adorable.",
        "Back to your toys, ankle biter.",
        "Speak up, ankle biter. I can't hear you from up here.",
    },
    NightElf = {
        "Back to your tree, pointy.",
        "Those ears make a fine target, pointy.",
        "Teldrassil's a long swim, pointy.",
        "Ten thousand years and still losing, pointy.",
        "Pointy ears, soft bones.",
        "Go hug a tree, pointy.",
    },
    Skyborne = {
        "Fly home, feather duster.",
        "Clip those wings, feather duster.",
        "Zephras Isle can keep its feather dusters.",
        "Pluck one and the rest fly off.",
        "Land, feather duster. Let's see you fight on the ground.",
        "Feathers everywhere. Hold still.",
    },
}
