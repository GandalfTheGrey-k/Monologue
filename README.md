# Monologue

[![Download Monologue_v.1.zip](https://img.shields.io/badge/Download-Monologue__v.1.zip-2ea44f?style=for-the-badge&logo=github)](https://github.com/GandalfTheGrey-k/Monologue/releases/latest/download/Monologue_v.1.zip)

A roleplay voice addon for **WoW Forever**. Your character talks on their own: a line when they pull with a big move, hellos for friends, call-outs for rivals, and reactions to the world around them, all in their race's accent. You decide who they are in the **My Voice** studio.

> **Alpha build.** Things will break. When they do, type **`/mono bug`** and paste the report into Discord.

---

## Contents
- [Install](#install)
- [Updating](#updating)
- [First steps](#first-steps)
- [The /mono window](#the-mono-window)
  - [General tab](#general-tab)
  - [Voice Lines tab](#voice-lines-tab)
  - [My Voice tab (character builder)](#my-voice-tab-character-builder)
  - [Rivals & Friends (roster)](#rivals--friends-roster)
- [Slash commands](#slash-commands)
- [FAQ & troubleshooting](#faq--troubleshooting)

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

Download the new zip from the same button and extract it over the old `Monologue_v.1` folder, replacing files when asked. Your settings and character data are kept; they live in WoW's saved variables, not in the addon folder. Then `/reload`.

If a group or guild member runs a newer version, Monologue tells you once in chat.

---

## First steps

- **Just play.** Every few pulls, a *signature move* (Charge, Execute, Pyroblast, Polymorph, Hammer of Justice…) says a line in `/s`. Ordinary attacks (Heroic Strike, Fireball spam…) stay quiet on purpose.
- **Why only on a key press?** The game only lets addons speak in `/s` during your own button press. Things that happen *without* a press (a friend waving at you, someone emoting, a party member's call-out) are said on your **next ability press**, or shown only in your chat, depending on the **Greetings & reactions** setting.
- **Open `/mono` → My Voice** to give your character a clan, hometown, allegiance, traits and more. That's what makes two characters of the same class sound different.

---

## The /mono window

`/mono` opens a window with three tabs (**General**, **Voice Lines**, **My Voice**) and a **Report Bug** button in the header.

### General tab

| Control | What it does |
|---|---|
| **Monologue is on** | Master switch for the whole addon. |
| **Lighter accent in party chat, none in raid chat** | Steps the accent down in group chat so raid calls stay readable. |
| **Accent strength** | How thick the accent is everywhere: **Off**, **Light** (vocabulary), **Standard** (+ accent, some openers/closers), **Unhinged** (+ frequent openers/closers). Applies to lines you *type* too. |
| **Greetings & reactions** | What happens to lines that don't come from a key press: said in `/s` on your **next ability press** (greetings wait 10 seconds, other lines up to a minute), or shown **only in your chat**. |
| **Personality by Level** | Optional: pick a persona (Eager Rookie, Cynical Mercenary, Grizzled Veteran, Zealous Crusader) for each level range, so your character grows up as you level. |
| **Try Your Accent** | Type any line and press **Translate** to hear it in your character's accent. Nothing is sent. |
| **Debug Mode** | Prints `[Monologue Debug]` lines showing why each line was or wasn't said. Off by default. |
| **Strict Safe-Mode (Manual & Local Only)** | For players who want **zero automated public chat**. Every automatic line (pulls, greetings, reactions, party banter) shows *only in your own chat window*. Typed chat is still translated, and the Battle Cry and Greet buttons still speak. Same as `/mono safemode`. |
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
| **Battle Cry button / Greet button** | Optional on-screen buttons. **Battle Cry** shouts a line. **Greet** says hello to your target, and glows when a greeting or reply is waiting to be said. Right-drag to move them. Keybinds: *Key Bindings → AddOns → Monologue*. |
| **Reply when players emote at me** | Answers `/wave`, `/bow`, `/cheer`, `/hug` and the like. |
| **Right Now** | Live status: is speech on here, when the next line is possible, pull progress, and what your lines could react to. |

The engine also keeps a fixed **45-second "breath"** between any two automatic lines, and never sends more than one automatic `/s`, `/y` or `/e` line every 6 seconds.

### My Voice tab (character builder)

Everything here is saved **per character** and sits on top of your race and class lines.

**Identity & Persona**
- **Persona preset:** the attitude of your combat lines (Eager Rookie, Cynical Mercenary, Grizzled Veteran, Zealous Crusader), or follow *Personality by Level*.
- **Racial Temperament:** three flavours per race (for example Dwarf: *Jovial Tavern-Keep*, *Grumpy Iron-Vet*, *Rune & Stone Scholar*). Each changes greetings, battle cries, openers and closers, and nudges the accent.
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
- **Dialect Strength:** **Full Dialect** (your General-tab accent), **Light Flavor** (key word swaps and openers/closers, no respelling), **Clean** (plain spelling; your clan, allegiance and traits still shape *what* you say).

**Cross-Race Stances**
Pick a race and a stance (warm, admiring, playful, wary, gruff, disdainful) to set how you greet friendly players of that race.

**Your own lines**
- **Custom Openers & Closers:** "By my blade," / ", or so I swore." Added to your pool.
- **Word & Phrase Swaps:** "friend → pal, mate, comrade" (separate variants with commas).
- **Signature Battle Cries:** added to your Battle Cry pool. Each has a **Preview**.
- **Guild Greeting:** said when you target a guildmate. Use `{target}` for their name.
- Live details work in your own lines too: `{weapon}`, `{spell}`, `{mob}`, `{party}`, `{myhp}` and more (`/mono tokens` lists them).

**Export / Import**
**Export** copies your whole voice as a `MONO1:` string; press Ctrl+C and send it to a friend. They paste it and press **Import**. Anything that doesn't fit their character (a clan from another race, say) is skipped with a note.

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
| `/mono lines` · `/mono voice` | Open the Voice Lines or My Voice tab |
| `/mono roster` | Open Rivals & Friends |
| `/mono toggle` | Turn Monologue on or off |
| `/mono safemode` | Strict Safe-Mode on/off |
| `/mono cry [yell\|say]` | Shout a battle cry now |
| `/mono greet` | Greet your friendly target (or say a waiting line) |
| `/mono friend [note]` · `/mono unfriend [name]` · `/mono friends` | Mark, unmark, list friends |
| `/mono rivals` · `/mono duels` | List your rivals or duel records |
| `/mono pin <name>` · `/mono unpin <name>` | Protect a rival from being cleared |
| `/mono button` · `/mono minimap [reset]` | Show/hide the Battle Cry button or minimap button |
| `/mono welcome` · `/mono version` | Show the welcome card or your version |

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
**General → Accent strength** sets it everywhere. For your character only, **My Voice → Dialect Strength → Light Flavor** (words and openers, no respelling) or **Clean** (plain spelling).

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
