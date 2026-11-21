MONOLOGUE  -  version 0.1.0 (alpha)
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


QUICK START
-----------
- Just play. Every few pulls, a signature move says a line in /s. Ordinary attacks (Heroic
  Strike, Fireball spam...) stay quiet.
- /mono opens the settings. It has three tabs:
    General      accent strength, Strict Safe-Mode, debug mode
    Voice Lines  where and how often you speak (sliders), the Battle Cry and Greet buttons
    My Voice     your character: personality, clan, hometown, allegiance, upbringing,
                 traits, oath / nemesis / catchphrase, your own lines and word swaps
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
  /mono cry          battle cry
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
