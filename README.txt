MONOLOGUE  -  version 0.1.4.5 (alpha)
A roleplay voice addon for WoW Forever

Your character talks on their own. They say a line when they pull with a big move (Charge,
Pyroblast, Hammer of Justice), greet friends, call out rivals and react to the world, all in
their race's accent. You can shape who they are on the My Voice tab.

This is an ALPHA build for friends. Things will break. Please report them (see BUG REPORTS).


INSTALLING
----------
1. Close the game.
2. Put the folder "Monologue_v.1" in:
       World of Warcraft\_forever_\Interface\AddOns\
   The folder must be named exactly Monologue_v.1, and Monologue_v.1.toc must sit directly
   inside it (not in a second Monologue_v.1 folder inside the first).
3. Start the game. On the character screen, click AddOns and make sure Monologue is ticked.
   If it says "out of date", tick "Load out of date AddOns".
4. Log in. A welcome card appears after a few seconds. Type /mono to open the settings.


UPDATING
--------
1. Close the game.
2. Delete the old Monologue_v.1 folder from AddOns (your settings are kept: they live in
   the WTF folder, not in the addon folder).
3. Download the newest Monologue_v.1.zip:
       https://github.com/GandalfTheGrey-k/Monologue/releases/latest
4. Extract it into AddOns as in INSTALLING, start the game, and type /mono version.


NEW IN 0.1.4.5
--------------
- Taunts for the other faction (My Voice > Enemy Faction, /mono taunts): Off (default),
  Civil, Rough or Savage (race nicknames to their face).
- Taunt button (Voice Lines tab), keybind and /mono taunt: taunt your enemy target now.
- Race nicknames in your chat (/mono nicknames): orcs -> green skins, trolls -> tusk
  suckers, tauren -> grass munchers, undead -> bone backs, night elves -> pointies,
  humans -> pinkskins, dwarves -> stumpies, gnomes -> ankle biters, Skyborne -> feather
  dusters.
- Translate only on Shift+Enter or Ctrl+Enter if you like (General tab, /mono sendkey);
  plain Enter then sends your message as typed.


NEW IN 0.1.4.1
--------------
- Druid lines rewritten: calmer, more specific, fewer shouted lines.
- Druids get their own lines against enemy players, elites, rares and in groups
  (Moonfire, Wrath, Rake, Maul; Feral Charge, Entangling Roots and Bash against players).


NEW IN 0.1.4
------------
- New Abilities tab: spells without their own lines speak for their kind (Attack, Burst,
  Defend, Interrupt, Heal), sorted automatically. Change a spell's kind or make it Silent
  there or with /mono map. Every Nth cast, quiet in dungeons, and your own lines for any
  spell or everyday moment (they travel with Export).
- Druids: bear and cat lines (Maul, Growl, Demoralizing Roar, Bash, Feral Charge, Faerie
  Fire (Feral), Pounce, Ravage).
- More everyday moments: flight masters, trainers, merchants, mailboxes, quest hand-ins,
  profession windows, gathering, fishing, full bags, running out of air, a long fall,
  your pet (lines for each warlock demon).
- Answer NPCs who yell nearby. Party banter between Monologue users in a group.
- Mood today: Grim, Weary, Cheerful or Fierce (My Voice tab, /mono mood).
- A bubble shows the line waiting for your next key press; click it to say it.
- /mono say <kind> [chance] for your own macros. Start a message with !! to skip the accent.
- Typo fixes (General tab, off by default), including one-letter slips. /mono test <text>.


NEW IN 0.1.3
------------
- Oaths replace the old openers and closers: now and then a short oath ("Gol'kosh!") before a
  greeting, kill line, low-health line or battle cry. Never on chat you type. Your old
  custom openers and closers carry over as My Oaths.
- Preview above the chat box while you type (General tab). What you see is what is sent.
- Words Never Translated (My Voice tab, /mono keep <word>). Titles stay with names.
- In / out of character: keybind, /mono ic, /mono ooc. The minimap book goes grey when out.
- "lad / lass" follows the pronouns in your own line, never your target.
- In a fight: at most 2 lines, each move once, no repeat pull line for the same mob (10 min).
- Everyday moments: eating, mounting, walking into an inn or city, a party member falling.
- Speech effects: slurred when drunk, shaky when badly hurt (General tab).
- Guild greeting works in any guild. Real Dwarf battle cries.


QUICK START
-----------
- Just play. Every few pulls, a signature move says a line in /s. Ordinary attacks (Heroic
  Strike, Fireball spam...) stay quiet.
- /mono opens the settings. It has four tabs:
    General      accent strength, chat preview, send key, speech effects, typo fixes, Strict Safe-Mode,
                 debug
    Voice Lines  where and how often you speak (sliders), the Battle Cry, Greet and Taunt buttons,
                 everyday moments, the waiting-line bubble, NPC yells, party banter
    My Voice     your character: personality, clan, hometown, allegiance, upbringing,
                 traits, oath / nemesis / catchphrase, mood, taunts and race nicknames,
                 My Oaths, words never translated, your own lines and word swaps
    Abilities    what kind of move each spell is (Attack, Burst, Defend, Interrupt, Heal,
                 Silent; every Nth cast), quiet in dungeons, and your own lines for any
                 spell or everyday moment
- Start a chat message with !! to send it exactly as typed (no accent).
- Quick picks worth trying first (My Voice tab):
    Persona preset, Racial Temperament, Clan / Lineage, Hometown, Allegiance / Order,
    Upbringing, Defining Trait, Dialect Strength (Full / Light Flavor / Clean)
- Rivals & Friends (button on the General tab): mark friends and see your rival ledger.
  Right-click a player's portrait for "Monologue: Add Friend". The Ally and Duo quick-picks
  give them their own greetings.


SLASH COMMANDS
--------------
  /mono              open the settings
  /mono bug          make a bug report to copy into Discord
  /mono safemode     Strict Safe-Mode on/off (see below)
  /mono help         every command
  /mono identity     show your clan, hometown, allegiance, traits
  /mono situations   what your lines could react to right now (target, mana, night...)
  /mono party        party members who also run Monologue
  /mono greet        greet your target (or say a waiting line)
  /mono taunt        taunt your enemy player target
  /mono taunts <off|civil|rough|savage>   how mean you are to the other faction
  /mono nicknames <off|enemy|all>   race nicknames in your chat
  /mono sendkey <enter|shift|ctrl>  translate on Enter, or only on Shift/Ctrl+Enter
  /mono ic | ooc     in character / out of character (also a keybind)
  /mono keep <word>  a word that is never translated (/mono unkeep removes it)
  /mono mood <grim|weary|cheerful|fierce|off>   how your character feels today
  /mono say <kind> [chance]   a line on demand, for macros, e.g. "/mono say interrupt 30"
                     (idle, kill, pull, hurt, interrupt, heal, defend, greet, cry)
  /mono map <spell> <kind>   what kind of move a spell is (attack, burst, defend,
                     interrupt, heal, none, auto); /mono map lists your choices
  /mono test <text>  show what a message would turn into, without sending it
  /mono cry          battle cry
  No buttons? Greet, Battle Cry and Taunt are also keybinds: Key Bindings > AddOns > Monologue.
  /mono debug        show [Monologue Debug] lines in chat
  /mono version      your version


HOW IT STAYS SAFE
-----------------
- The game only allows /s from a real key press. Monologue only speaks inside your own ability
  presses and clicks, never from timers or background events.
- At most one automated /s, /y or /e line every 6 seconds. Faster lines only show in your chat.
- It never posts to trade, general, LFG or any numbered channel, and never whispers anyone.
- Party banter uses quiet addon messages (party, raid and guild only, at most one every
  10 seconds). Other players without Monologue never see them.
- It doesn't press, cast or move anything for you. It only listens.
- Strict Safe-Mode (General tab, or /mono safemode): every automated line shows ONLY in your
  own chat window. Typed chat is still translated into your accent, and the Battle Cry and
  Greet buttons still speak. Turn it on if you want to test with zero public chatter.


BUG REPORTS
-----------
1. Type /mono bug (or click "Report Bug" at the top of the /mono window).
2. Write one line in "What happened?", e.g. "Charged a mob, nothing was said".
3. Click "Select Report", press Ctrl+C, and paste it into our Discord.
The report includes your settings and the last few things Monologue did, so it helps even
if you weren't in debug mode. It contains no account info, only your character's race,
class, level and zone.


TROUBLESHOOTING
---------------
"Nothing is ever said"
  - Lines are spaced out on purpose. On the Voice Lines tab, set "about every N pulls" to 1
    and "wait at least" to 30 sec to test.
  - Only signature moves speak. Try Charge, Execute, Pyroblast, Polymorph, Hammer of Justice...
  - Check "Speak in /s when I use abilities" and the place switches on the Voice Lines tab.
  - Strict Safe-Mode on? Lines then only show in your own chat.
  - /mono debug, then pull: the debug lines say exactly why a line was or wasn't said.

"Lines show in my chat but nobody else sees them"
  - That's local mode, Strict Safe-Mode, or a place where the game blocks chat (some boss
    fights). The Voice Lines tab's "Right Now" box says which. /mono castchat retry re-tests
    a place that was blocked.

"Interface action failed because of an AddOn"
  - Please send a /mono bug report right after it happens. Monologue switches /s off for
    that kind of place by itself; /mono castchat retry tries again later.

"The accent is too much / too little"
  - General tab: Accent strength. My Voice tab: Dialect Strength (Light Flavor or Clean).

"The window or minimap button is gone"
  - /mono minimap reset brings the minimap button back. /mono always opens the window.

"Lua error popup"
  - Copy it into Discord along with /mono bug. Monologue keeps the last 3 of its own errors
    in the report.

Thanks for testing!
