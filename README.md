# Monologue

[![Download Monologue_v.1.zip](https://img.shields.io/badge/Download-Monologue__v.1.zip-2ea44f?style=for-the-badge&logo=github)](https://github.com/GandalfTheGrey-k/Monologue/releases/latest/download/Monologue_v.1.zip)

A roleplay voice addon for **WoW Forever**. Your character talks on their own: a line when they pull with a big move, hellos for friends, call-outs for rivals, and reactions to the world around them, all in their race's accent. You decide who they are in the **My Voice** studio.

> **Alpha build.** Things will break. When they do, type **`/mono bug`** and paste the report into Discord.

---

## Contents
- [What's new in 0.1.5](#whats-new-in-015)
- [What's new in 0.1.4.5](#whats-new-in-0145)
- [What's new in 0.1.4.1](#whats-new-in-0141)
- [What's new in 0.1.4](#whats-new-in-014)
- [What's new in 0.1.3](#whats-new-in-013)
- [Install](#install)
- [Updating](#updating)
- [First steps](#first-steps)
- [The /mono window](#the-mono-window)
  - [General tab](#general-tab)
  - [Voice Lines tab](#voice-lines-tab)
  - [My Voice tab (character builder)](#my-voice-tab-character-builder)
  - [Abilities tab](#abilities-tab)
  - [Rivals & Friends (roster)](#rivals--friends-roster)
- [Slash commands](#slash-commands)
- [FAQ & troubleshooting](#faq--troubleshooting)

---

## What's new in 0.1.5

- **Every class sounds like itself.** Hunter, Mage, Paladin, Priest, Rogue, Shaman and Warlock lines are rewritten (140–165 lines each), and no line is shared between classes. Signature moves have their own lines: Polymorph, Counterspell, Ice Block, Hammer of Justice, Divine Shield, Psychic Scream, Mind Control, Sap, Kick, Vanish, Purge, Fear, Death Coil, Banish, Scatter Shot, Freezing Trap and more. Crowd control, interrupts and heals now speak mid-fight now and then.
- **No more talking about yourself in the third person.** "The bear doesn't knock" is now "I don't knock", and so on across druids, races and profiles.
- **Talking with other Monologue users** (Voice Lines tab, "Talk with other Monologue users"):
  - When another user greets you, your character greets them back. You won't greet the same group member over and over.
  - Banter becomes a short back-and-forth: the first speaker sometimes has the last word.
  - New moments: level-ups, loot, and thanking the player who raised you.
  - Answers change with who they are to you: friends get warmer ones, races you've set a cool stance toward get grudging ones, and someone of your own class gets ribbing.
  - Duels: a line when you challenge or accept. When both duelists run Monologue, the loser concedes and the winner answers.
  - Total RP names are used when people have them.
- **Far fewer repeated lines.** About 2,400 new lines: every clan, upbringing, profession, trait, allegiance, emote reply, PvP and stance pool now has at least 6. Small pools are picked less often, a temperament now adds to your race's battle cries and greetings instead of replacing them, and Monologue remembers your last 40 lines across logins so they don't come straight back.

## What's new in 0.1.4.5

- **Taunts for the other faction.** Choose how mean your character is on *My Voice → Enemy Faction* (or `/mono taunts`): **Off** (default), **Civil** (an honest rivalry), **Rough** (trash talk) or **Savage** (race nicknames to their face). Taunts come up when you target an enemy player you have no grudge with yet, and now and then as you open a fight.
- **Taunt button and keybind.** An optional **Taunt** button (Voice Lines tab) says a taunt at your enemy player target right away. Also a keybind (*Key Bindings → AddOns → Monologue*) and `/mono taunt` for macros.
- **Race nicknames in your chat** (My Voice → Enemy Faction, or `/mono nicknames`): swaps race names for nicknames in what you type and say, for the other faction's races or every race. "The orcs are coming" becomes "The green skins are coming".

  | Race | Nickname | Race | Nickname |
  |---|---|---|---|
  | Orc | green skin | Human | pinkskin |
  | Troll | tusk sucker | Dwarf | stumpy |
  | Tauren | grass muncher | Gnome | ankle biter |
  | Undead | bone back | Night Elf | pointy |
  | Skyborne | feather duster | | |

- **Translate on Shift+Enter or Ctrl+Enter** (General tab, or `/mono sendkey`): plain Enter sends your message exactly as typed, and holding Shift or Ctrl as you press Enter sends it in your accent. The preview shows which key to press.

## What's new in 0.1.4.1

- **Druid lines rewritten.** Moonfire, Wrath, Starfire, Rake, Entangling Roots, Faerie Fire, the combat openers and the big-cooldown, routine and low-health reactions are calmer and more specific, with fewer shouted lines.
- **More variety for druids.** Moonfire, Wrath, Rake and Maul now have their own lines for enemy players, elites, rares and groups; Feral Charge, Entangling Roots and Bash have their own lines for enemy players.

## What's new in 0.1.4

- **New Abilities tab: every spell can speak.** Spells without lines of their own now speak for their kind: **Attack** can open a fight, **Burst**, **Defend**, **Interrupt** and **Heal** may also speak mid-fight now and then. Harmful spells, heals and interrupts are sorted automatically; change any spell's kind, or make it **Silent**, on the Abilities tab or with `/mono map`. No class, form or spec is left quiet.
- **Every Nth cast.** A spell you use a lot can speak only on every 2nd, 3rd, 5th or 10th cast.
- **Your own lines for any spell or moment.** Pick a spell, an everyday moment or a kind of move on the Abilities tab and add lines. They join Monologue's own and travel with **Export**.
- **Bear and cat lines.** Maul, Growl, Demoralizing Roar, Bash, Feral Charge, Faerie Fire (Feral), Pounce and Ravage now have lines, so druids talk in bear form too.
- **More everyday moments.** Flight masters, trainers, merchants, mailboxes, quest hand-ins, profession windows, mining, herbalism, skinning, fishing, full bags, running out of air, a long fall, and your pet being summoned or falling (with lines for each warlock demon).
- **Answer NPCs who yell.** Now and then your character answers a creature yelling close by. Never in a boss fight.
- **Party banter.** When you say a line aloud in a group, another Monologue user may answer you a moment later. Only one answers each time.
- **Mood today.** Grim, Weary, Cheerful or Fierce (My Voice tab, `/mono mood`) colours some of your lines and how often you speak.
- **The waiting line, on screen.** A small bubble shows a line waiting for your next key press; click it to say it, right-click to skip.
- **Lines from your own macros.** `/mono say interrupt 30` after `/cast Kick` says something now and then.
- **Send as typed.** Start a message with `!!` to skip the accent.
- **Typo fixes** (General tab, off by default): common typos and one-letter slips ("wepaon" → "weapon", "ironforg" → "Ironforge"). Try it with `/mono test <text>`.
- **Quiet in dungeons** (Abilities tab): automatic lines a quarter as often in dungeons, none in raids.

## What's new in 0.1.3

- **Oaths replace openers and closers.** The old bits glued onto lines ("Pull up a stool, … pass the jug.") are gone. Now and then a short oath comes *before* a greeting, a kill line, a low-health line or a battle cry, as its own sentence ("Gol'kosh! FER IRONFORGE!"). Never on chat you type. Your old custom openers and closers carry over as **My Oaths**.
- **Preview above the chat box.** See how your message will come out while you type; what you see is what's sent.
- **Words Never Translated.** Your own list of names and words the accent never touches (`/mono keep <word>`). Titles stay with names ("Lady Jaina").
- **In / out of character.** A keybind (or `/mono ic` / `/mono ooc`) switches translation and automatic lines off and on. The minimap book goes grey while you're out of character.
- **Smarter "lad / lass".** Words you call someone ("friend" → lad, lass, mate) follow the pronouns in your own line, never your target.
- **Fewer repeats in a fight.** At most 2 lines per fight, each move speaks once per fight, and the same mob won't get a second pull line for 10 minutes.
- **Everyday moments.** An occasional line when you eat or drink, mount up, walk into an inn or city, or see a party member fall.
- **Speech effects.** Slurred when you're drunk, shaky when you're badly hurt (General tab).
- **Guild greeting fixed.** Your My Voice guild greeting now works in any guild and comes before race greetings.
- **Real Dwarf battle cries.** "KHAZ MODAN!", "GOL'KOSH!", "REMEMBER GRIM BATOL!"

---

## Install

1. **Download** `Monologue_v.1.zip` with the green **Download** button above.

   > ⚠️ **Do not use GitHub's green "Code → Download ZIP" button.** That gives you a folder called `Monologue-main`, and WoW won't load the addon from it.

2. **Extract** the zip into your AddOns folder:
   `World of Warcraft\_forever_\Interface\AddOns\`

3. **Check the path.** This file must exist:
   ```
   World of Warcraft\_forever_\Interface\AddOns\Monologue_v.1\Monologue_v.1.toc
   ```
   A common mistake is a folder inside a folder (`AddOns\Monologue_v.1\Monologue_v.1\...`). If you see that, move the inner `Monologue_v.1` up one level.

4. **Start the game**, or type **`/reload`** if you're already logged in. On the character screen, open **AddOns** and make sure **Monologue** is ticked. If it says "out of date", tick **Load out of date AddOns**.

5. Log in. A **welcome card** appears after a few seconds (once per character). Type **`/mono`** to open the settings.

## Updating

1. **Close the game** (or log out to the character screen).
2. **Delete** the old folder `World of Warcraft\_forever_\Interface\AddOns\Monologue_v.1`. This clears out any files the new version no longer uses.
3. **Download** the new `Monologue_v.1.zip` with the green **Download** button at the top; it always gives the latest release.
4. **Extract** it into `AddOns\` exactly as in [Install](#install), and check that `AddOns\Monologue_v.1\Monologue_v.1.toc` exists.
5. **Start the game** and type **`/mono version`** to confirm the new version number.

Your settings and character data are kept: they live in WoW's saved variables (`WTF` folder), not in the addon folder, so deleting the old folder is safe.

If a group or guild member runs a newer version, Monologue tells you once in chat. Every release and its notes are on the [Releases page](https://github.com/GandalfTheGrey-k/Monologue/releases).

---

## First steps

- **Just play.** Every few pulls, a *signature move* (Charge, Execute, Pyroblast, Polymorph, Hammer of Justice…) says a line in `/s`. Ordinary attacks (Heroic Strike, Fireball spam…) stay quiet on purpose.
- **Why only on a key press?** The game only lets addons speak in `/s` during your own button press. Things that happen *without* a press (a friend waving at you, someone emoting, a party member's call-out) are said on your **next ability press**, or shown only in your chat, depending on the **Greetings & reactions** setting.
- **Open `/mono` → My Voice** to give your character a clan, hometown, allegiance, traits and more. That's what makes two characters of the same class sound different.

---

## The /mono window

`/mono` opens a window with four tabs (**General**, **Voice Lines**, **My Voice**, **Abilities**) and a **Report Bug** button in the header.

### General tab

| Control | What it does |
|---|---|
| **Monologue is on** | Master switch for the whole addon. |
| **Lighter accent in group chat (party, raid, instance)** | Steps the accent down to Light in group chat so calls stay readable. |
| **Accent strength** | How thick the accent is everywhere: **Off**, **Light** (vocabulary), **Standard** (+ accent, the odd oath), **Unhinged** (+ more oaths). The accent applies to lines you *type* too; oaths never do. |
| **Greetings & reactions** | What happens to lines that don't come from a key press: said in `/s` on your **next ability press** (greetings wait 10 seconds, other lines up to a minute), or shown **only in your chat**. |
| **Personality by Level** | Optional: pick a persona (Eager Rookie, Cynical Mercenary, Grizzled Veteran, Zealous Crusader) for each level range, so your character grows up as you level. |
| **Try Your Accent** | Type any line and press **Translate** to hear it in your character's accent. Nothing is sent. |
| **Debug Mode** | Prints `[Monologue Debug]` lines showing why each line was or wasn't said. Off by default. |
| **Strict Safe-Mode (Manual & Local Only)** | For players who want **zero automated public chat**. Every automatic line (pulls, greetings, reactions, party banter) shows *only in your own chat window*. Typed chat is still translated, and the Battle Cry and Greet buttons still speak. Same as `/mono safemode`. |
| **Translate in** | Pick which chat channels get your accent: **Say, Yell, Party, Raid, Instance, Guild, Officer, Whisper**. Covers both what you type and Monologue's own lines. Default: Say, Yell and Party. Numbered channels (trade, general, LFG) are never translated. |
| **Preview above the chat box** | While you type, a line just above the chat box shows how your message will come out. What you see is exactly what is sent. On by default. |
| **Speech effects** | Your words slur when you're drunk (more the drunker you are: "Thish ish my lasht pint") and shake when you're badly hurt in a fight ("W-we need to fall back..."). On by default. |
| **Fix common typos** | Fixes words with one clear spelling in your typed chat ("teh" → "the", "dont" → "don't", "i" → "I"), and one-letter slips when only one real word fits ("wepaon" → "weapon", "ironforg" → "Ironforge"). Names, links, SHOUTING and Words Never Translated are left alone. Off by default. Try it with `/mono test <text>`. |

| **Translate on** | **Enter** (default): everything you type in a Translate-in channel gets your accent. **Shift+Enter only** or **Ctrl+Enter only**: plain Enter sends your message exactly as typed; hold Shift or Ctrl as you press Enter to send it translated. Same as `/mono sendkey`. |

**Send as typed:** start a message with `!!` to send it exactly as you wrote it, with no accent (the `!!` is dropped).
| **Rivals & Friends** | Opens the roster window (see below). |

### Voice Lines tab

Where and how often your character speaks in `/s`.

| Control | What it does |
|---|---|
| **Speak in /s when I use abilities** | Master switch for spoken lines. |
| **Place switches** | Turn speech on or off separately for **Open world (mobs)**, **World PvP (players)**, **Dungeons**, **Raids**, **Battlegrounds** and **Boss fights** (boss fights are off by default; the game may block chat there anyway). |
| **Against mobs, say a line about every… (1–10 pulls)** | Pull pacing: how many mob pulls between lines. |
| **Wait at least this long between lines… (30 sec – 10 min)** | Minimum spacing between ability-press lines. |
| **Chance of other reactions** | Scales how often greetings, duel lines, PvP lines and other reactions fire (off → double). |
| **React to the world** | How often a pull line reacts to the moment instead (an undead target, a rare, low mana, the mob that killed you…). Your spell's own lines still lead on most pulls. |
| **Battle Cry / Greet / Taunt buttons** | Optional on-screen buttons. **Battle Cry** shouts a line. **Greet** says hello to your target, and glows when a greeting or reply is waiting to be said. **Taunt** jeers at your enemy player target, at your Enemy Faction level (Civil when taunts are Off). Right-drag to move them. Rather not have buttons? Each one is also a keybind (*Key Bindings → AddOns → Monologue*) and a slash command for macros: `/mono cry`, `/mono greet`, `/mono taunt`. |
| **Reply when players emote at me** | Answers `/wave`, `/bow`, `/cheer`, `/hug` and the like. |
| **Everyday moments** | Now and then a short line when you sit down to eat or drink, mount up, walk into an inn or city, talk to a flight master, trainer or merchant, open a mailbox or your profession window, hand in a quest, mine, pick herbs, skin or fish, run out of bag space or air, take a long fall, summon your pet or lose it, or see a party member fall. |
| **Show the waiting line** | When a line is waiting for your next key press, a small bubble shows it. Left-click (or your Greet key) says it, right-click skips it, right-drag moves the bubble. |
| **Answer NPCs who yell** | Now and then your character answers a creature or NPC yelling close by ("Big words, Hogger. Come say them closer."). Never in a boss fight. |
| **Party banter** | When you say a line aloud in a group, another party member who runs Monologue may answer you a moment later, and you them. Only one answers each time. |
| **Right Now** | Live status: is speech on here, when the next line is possible, pull progress, and what your lines could react to. |

The engine also keeps a fixed **45-second "breath"** between any two automatic lines, and never sends more than one automatic `/s`, `/y` or `/e` line every 6 seconds. In a fight it says **at most 2 lines**, each move speaks **once per fight**, and the same mob or player won't get a second pull line for 10 minutes.

### My Voice tab (character builder)

Everything here is saved **per character** and sits on top of your race and class lines.

**Identity & Persona**
- **Persona preset:** the attitude of your combat lines (Eager Rookie, Cynical Mercenary, Grizzled Veteran, Zealous Crusader), or follow *Personality by Level*.
- **Racial Temperament:** three flavours per race (for example Dwarf: *Jovial Tavern-Keep*, *Grumpy Iron-Vet*, *Rune & Stone Scholar*). Each changes greetings and battle cries, and nudges the accent.
- **Reset Customizations**, **Fill Starter Examples**, **Preview My Voice** (prints a sample greeting, line and battle cry in your chat).

**Azeroth Identity**
- **Clan / Lineage:** only your race's clans are listed (for example Bronzebeard, Wildhammer, Dark Iron and Clanless for dwarves; Frostwolf, Warsong and others for orcs). An optional **Custom name** box overrides the display name.
- **Hometown / Origin:** grouped by region (Eastern Kingdoms, Kalimdor & Skies, Horde Homelands, Neutral Ports), or **type your own**. Coming home earns a homecoming line, a fallen home (Gnomeregan, Lordaeron, Stromgarde…) earns a "reclaim it" line, and being far away can make you homesick.
- **Allegiance / Order:** Independent, Scarlet Crusade, Defias Brotherhood, Argent Dawn, Stormwind Crown / SI:7, Explorers' League, Cenarion Circle / Earthen Ring, Steamwheedle Cartel, Bloodsail Buccaneers, Thorium Brotherhood, Horde War-Council. Each brings its own combat lines, greetings and reactions to its enemies (the Scarlet Crusade has opinions about undead).
- **Profession / Trade:** **Auto-Detect** reads your learned professions, or pick one yourself, including *Scribe / Cartographer* and *Sellsword / Caravan Guard*. Trade lines come out in cities, at the repair vendor and in quiet moments.

**Character Builder**
- **Upbringing:** six defining backgrounds (*Survived the Scourge*, *Raised in the Tavern*, *Apprenticed in a Forge*, *Trained by the Watch*, *Grew Up on the Open Road*, *Touched by Magic*).
- **Defining Trait + Secondary Trait:** Tavern-Warm, Oath-Bound, Cynical, Plague-Hardened, Stoic, Hot-Blooded. Both colour your lines. The primary trait sets how you react when a party member is in trouble or a big fight is won.
- **Character Anchors** (free text, all optional):
  - **Oath:** finish "I swore …". Used as `{oath}`.
  - **Nemesis:** a name. Used as `{nemesis}`.
  - **Catchphrase:** a sentence you always say. Used as `{catchphrase}`.
  - Your hometown works the same way as `{hometown}`.
- **Dialect Strength:** **Full Dialect** (your General-tab accent), **Light Flavor** (key word swaps and the odd oath, no respelling), **Clean** (plain spelling; your clan, allegiance and traits still shape *what* you say).

**Mood today**
Grim, Weary, Cheerful or Fierce (or Normal). A share of your greetings, idle chatter, kill lines and low-health lines take on the mood, and Weary or Grim characters speak a little less, Cheerful ones a little more. Same as `/mono mood`.

**Cross-Race Stances**
Pick a race and a stance (warm, admiring, playful, wary, gruff, disdainful) to set how you greet friendly players of that race.

**Enemy Faction**
- **Taunts:** Off (default), Civil, Rough or Savage. Said when you target an enemy player you have no grudge with yet, and now and then as you open a fight. Savage uses the race nicknames. The other faction sees /say as gibberish; your own side hears every word. Same as `/mono taunts`.
- **Race nicknames:** Off, the other faction's races, or every race. Swaps race names in what you type and say (orcs → green skins, night elves → pointies). Same as `/mono nicknames`.

**Your own lines**
- **My Oaths:** short exclamations like "By my blade!", added to your race's own. Now and then one is said before a greeting, a kill line, a low-health line or a battle cry ("By Magni's beard! Another one down."). Never on chat you type.
- **Words Never Translated:** names and words the accent never touches, in any letter case (shared by all your characters), e.g. `battlehammer`. Capitalised names mid-sentence and titles with names ("Lady Jaina") are kept automatically.
- **Word & Phrase Swaps:** "friend → pal, mate, comrade" (separate variants with commas). Words you use to *address* someone follow the pronouns in your own line: "Thanks, friend, she saved us" gives "lass", "he" or "him" gives "lad", and a line with neither gives "mate" or "pal". Who you are targeting is never used.
- **Signature Battle Cries:** added to your Battle Cry pool. Each has a **Preview**.
- **Guild Greeting:** said when you target a guildmate. Use `{target}` for their name.
- Live details work in your own lines too: `{weapon}`, `{spell}`, `{mob}`, `{party}`, `{myhp}` and more (`/mono tokens` lists them).

**Export / Import**
**Export** copies your whole voice as a `MONO1:` string; press Ctrl+C and send it to a friend. They paste it and press **Import**. Anything that doesn't fit their character (a clan from another race, say) is skipped with a note.

### Abilities tab

Saved **per character** (the two checkboxes are for all characters).

**What Kind of Move**
Every spell you cast shows up here. Spells with their own lines (Charge, Rake, Maul...) keep them. Any other spell speaks from a shared pool for its kind, so no class, form or spec is ever silent:

| Kind | When it speaks |
|---|---|
| **Attack** | Can open a fight, like a signature move. Harmful spells get this automatically. |
| **Burst** | A big cooldown: can open a fight and may also speak mid-fight. Your choice only. |
| **Defend · Interrupt · Heal** | May also speak mid-fight now and then. Interrupts and heals are spotted automatically. |
| **Silent** | Never speaks, even a spell that has its own lines. |

Next to each spell, **Every cast / 2nd / 3rd / 5th / 10th** lets a spell you use a lot speak only on every Nth cast. Untick **Spells without their own lines speak for their kind** to go back to signature moves only. The fight limits still apply: two lines a fight, each move once. `/mono map <spell> <kind>` does the same from chat.

**Pacing**
**Quiet in dungeons**: automatic lines a quarter as often in dungeons, and none in raids.

**My Lines for a Spell or Moment**
Pick a spell you've cast, an everyday moment (Mining, Merchant, Pet Summon...) or a kind of move, and add your own lines. They join the lines Monologue already has; a spell with none gets yours alone. Tokens like `{target}` and `{zone}` work, and **Export** on My Voice includes them.

### Rivals & Friends (roster)

Open it with the **Rivals & Friends** button on the General tab, `/mono roster`, or a **right-click on the minimap button**. It has three tabs:

- **Friends:** players you've marked (`/mono friend`, or right-click their portrait → **Monologue: Add Friend**). Each row shows name, race, note and date added. Click **Edit** to change the note. The **Duo** and **Ally** quick-picks give that friend their own dedicated greetings.
- **Rivals:** enemy players you've fought, with their **tier**, your **K – D** record against them, and where you **last saw** them. Tiers grow with your history: *First Clash → Déjà Vu → Rematch → Vendetta / Dominance → Nemesis*.
  - Lines change with the score: cocky when you're ahead, bitter when you're behind, "let's settle it" when tied.
  - **Pin** a rival to keep them from being cleared out.
  - When you're grouped and spot a sworn enemy, you warn your party ("Keep your guard up…"), at most once every 5 minutes. Party members running Monologue may back you up.
- **Duels:** your **W – L** record and **last zone** against each opponent, kept separate from rivals. Marked friends you've duelled sometimes get teased about the score when you greet them.

---

## Slash commands

All commands start with `/mono` (`/mono help` lists them in game).

**Everyday**

| Command | What it does |
|---|---|
| `/mono` | Open the settings window |
| `/mono lines` · `/mono voice` · `/mono abilities` | Open the Voice Lines, My Voice or Abilities tab |
| `/mono roster` | Open Rivals & Friends |
| `/mono toggle` | Turn Monologue on or off |
| `/mono safemode` | Strict Safe-Mode on/off |
| `/mono cry [yell\|say]` | Shout a battle cry now |
| `/mono greet` | Greet your friendly target (or say a waiting line) |
| `/mono taunt` | Taunt your enemy player target now |
| `/mono taunts <off\|civil\|rough\|savage>` | How mean you are to the other faction |
| `/mono nicknames <off\|enemy\|all>` | Race nicknames in your chat (orcs → green skins) |
| `/mono sendkey <enter\|shift\|ctrl>` | Translate typed chat on Enter, or only on Shift+Enter / Ctrl+Enter |
| `/mono ic` · `/mono ooc` | In character, or out of character (no translation, no automatic lines; the minimap book goes grey). Also a keybind: *Key Bindings → AddOns → Monologue* |
| `/mono keep <word>` · `/mono unkeep <word>` | Add or remove a word that is never translated (`/mono keep` lists them) |
| `/mono mood <grim\|weary\|cheerful\|fierce\|off>` | How your character feels today |
| `/mono map <spell> <attack\|burst\|defend\|interrupt\|heal\|none\|auto>` | What kind of move a spell is (`/mono map` lists your choices) |
| `/mono test <text>` | Show what a message would turn into (accent and typo fixes), without sending it |
| `/mono say <kind> [chance %]` | A line on demand, for your own macros. Kinds: `idle`, `kill`, `pull`, `hurt`, `interrupt`, `heal`, `defend`, `greet`, `cry`. See the example below. |
| `/mono friend [note]` · `/mono unfriend [name]` · `/mono friends` | Mark, unmark, list friends |
| `/mono rivals` · `/mono duels` | List your rivals or duel records |
| `/mono pin <name>` · `/mono unpin <name>` | Protect a rival from being cleared |
| `/mono button` · `/mono minimap [reset]` | Show/hide the Battle Cry button or minimap button |
| `/mono welcome` · `/mono version` | Show the welcome card or your version |

**Macros:** a `/mono` command in a macro counts as a key press, so the line is said aloud. For example, to say something now and then when you interrupt:

```
/cast Kick
/mono say interrupt 30
```

`30` means a 30% chance. Cooldowns, the 45-second breath and the 2-lines-per-fight limit still apply, so it never spams.

**Tuning**

| Command | What it does |
|---|---|
| `/mono chatty <0-3>` | Reaction chance multiplier |
| `/mono background <local\|queue>` | Background lines: chat only, or said on your next press |
| `/mono crychannel <yell\|say>` | Default battle-cry channel |
| `/mono reload` | Rebuild your voice from the data packs |

**Testing & troubleshooting**

| Command | What it does |
|---|---|
| `/mono bug` | **Bug report window:** copy and paste into Discord |
| `/mono status` | Active layers, growth stage, safe-mode state |
| `/mono debug [on\|off]` | Show why lines are or aren't said |
| `/mono identity` | Your clan, hometown, allegiance, traits, dialect |
| `/mono situations` | What your lines could react to right now |
| `/mono tokens` | Live details available right now (`{weapon}`, `{spell}`, …) |
| `/mono party` | Party members who also run Monologue |
| `/mono castchat [retry]` | Places where the game blocked `/s` (retry re-tests them) |
| `/mono probe` | One-time test: can an ability press send `/s` on this client? |
| `/mono hooks` | Typed-chat accent hook status |
| `/mono triggers` · `/mono spellid` | Check class spell IDs / print the ID of every spell you cast |
| `/mono namecheck` | What name each API returns for your target |
| `/mono feat <KEY>` · `/mono feats` | Unlock or list boss feats |

---

## FAQ & troubleshooting

**How do I share my character's voice with a friend?**
`/mono` → **My Voice** → **Export**, then Ctrl+C. Your friend pastes the `MONO1:` string into the same box and presses **Import**. It replaces their custom voice; anything that doesn't fit their character (a clan of another race, say) is skipped and listed.

**The accent is too strong (or too weak).**
**General → Accent strength** sets it everywhere. For your character only, **My Voice → Dialect Strength → Light Flavor** (words only, no respelling) or **Clean** (plain spelling).

**How does Strict Safe-Mode work?**
With it on, nothing automatic is ever said publicly for you. Pull lines, greetings, reactions and party banter appear only in *your* chat window. Your typed chat is still translated, and clicking **Battle Cry** or **Greet** (or `/mono cry`) still speaks, because those are your own explicit actions. Toggle it on the General tab or with `/mono safemode`.

**How do I send a bug report?**
Type **`/mono bug`** (or click **Report Bug** at the top of the `/mono` window), write one line in **What happened?**, click **Select Report**, press **Ctrl+C**, and paste it into Discord. The report includes your settings and the last 15 things Monologue did, even if debug mode was off. It contains no account info.

**Nothing is ever said.**
- Lines are spaced out on purpose. On **Voice Lines**, set *about every* to **1 pull** and *wait at least* to **30 sec** to test.
- Only signature moves speak; try Charge, Execute, Pyroblast, Polymorph…
- Check **Speak in /s when I use abilities** and the place switches.
- Is **Strict Safe-Mode** on? Then lines only show in your own chat.
- Turn on **Debug Mode** and pull: the debug lines say exactly why.

**Lines show in my chat but nobody else sees them.**
That's *Greetings & reactions → only in my chat*, Strict Safe-Mode, or a place where the game blocks chat (some boss fights). The **Right Now** box on Voice Lines tells you which. `/mono castchat retry` re-tests a blocked place.

**"Interface action failed because of an AddOn"**
Send a `/mono bug` report right after. Monologue switches `/s` off for that kind of place by itself; `/mono castchat retry` tries again later.

**The minimap button or window is gone.**
`/mono minimap reset` brings the button back; `/mono` always opens the window. If clicking the button says the core engine didn't load, there was a Lua error at login: type `/console scriptErrors 1`, `/reload`, and send us the error.

**Is this safe to use?**
Monologue only speaks inside your own button presses, never from timers. It never posts to trade, general, LFG or any numbered channel, and never whispers anyone. Party features use quiet addon messages (party, raid and guild only). It never presses, casts or moves anything for you.

More detail is in [README.txt](README.txt), which is also inside the download.
