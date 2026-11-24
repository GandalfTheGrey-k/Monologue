# Monologue Voice Guide

The standard every voice line in `races/`, `classes/`, `personas/` and `profiles/` is written to.
This file is not loaded by the game (it is not in the `.toc`).

## What a good line sounds like

A line is something a real person in Azeroth would actually say mid-fight or in passing:
short, specific, and in their own voice. Most people don't make speeches while swinging an axe.

- **Specific beats grand.** "That's for Thelsamar." beats "Feel the wrath of the Alliance!"
  Name real Classic places, kin, gear, food, weather, old fights, aches and habits.
- **Mostly calm.** Shout when it matters. No more than about a third of a pool may end in `!`.
- **Mixed shapes.** Mix 2-word grunts, half sentences, asides, orders and the odd longer thought
  (up to about 14 words). Not every line is a complete sentence.
- **Talk to someone.** Lines are said to the enemy, to an ally, to yourself, or to nobody.
  Vary who.
- **Character first.** It should be clear who is speaking (race, class, persona) without the line
  saying so outright. Never "As a warrior, I..." or "Dwarves never...".
- **Tokens sparingly.** At most about one line in eight starts with `{target}`. A name in the
  middle or at the end reads more naturally.

## Banned

Stock phrases and devices that make lines sound generic or machine-written:

- "unleashed", "feel the (wrath / fury / power / might) of", "taste my / taste the", "prepare to
  (die / meet)", "witness", "behold", "you'll regret", "here we go", "bring it", "time to",
  "let's dance", "lights out", "game over", "say hello to", "you picked the wrong", "is that all
  you've got", "now you've done it", "nowhere to run", "end of the line".
- Puns ("Ice to meet you", "Chill out", "Leaf it to me").
- The same opening words across a pool ("Feel the...", "By the..." five times).
- Spell names shouted as a line ("Fireball!"). The game already shows the cast.
- Describing what the spell does ("I charge at you!").
- Exclamation stacks ("!!", "?!") and ALL CAPS, except battle cries.

## Filler moves are silent

Only **signature moves** have lines: gap-closers and openers, crowd control, big cooldowns and
finishers. Rotation spells (Heroic Strike, Rend, Sinister Strike, Fireball, Frostbolt, Smite,
Wrath, Shadow Bolt, Lightning Bolt...) have no lines and never trigger speech.

## Personality

Combat and spell lines are written once per **persona** (set on My Voice or Personality by Level).
The race accent is added on top by the translator, so write persona lines in plain English.

| Persona | Attitude | Sounds like |
|---|---|---|
| Default (none) | The class's own working voice: competent, unshowy | "Hold them there." |
| Eager Rookie | Nervous, keen, narrates themself, half-surprised it worked | "Okay. Okay! That actually worked." |
| Cynical Mercenary | Transactional, dry, bored, thinks about pay | "This is billed by the hour." |
| Grizzled Veteran | Economical, tired, practical, has seen worse | "Seen this one before. Keep your feet." |
| Zealous Crusader | Devout, absolute, sees the fight as judgment | "The Light keeps the ledger. You're overdue." |

Greetings and battle cries are shaped by the **Racial Temperament** preset
(three per race, set on My Voice). Write each temperament's pools so that two characters of the
same race with different temperaments are easy to tell apart.

## Pool sizes

| Pool | Minimum |
|---|---|
| Signature spell, Default | 10 |
| Signature spell, each persona | 6 |
| Friend / guild greetings, duel win / loss | 8 |
| Signature spell context (`.Player`, `.Elite`, `.Rare`, `.Party`) | 4 (aim for 6) |
| Each PvP tier, rival tier, emote reply kind, stance | 4 |

## Before you commit lines

Run the linter in the scratchpad (`voice_lint.py <addon folder>`). It flags banned phrases,
exclamation and `{target}`-first ratios, puns, repeated openings and lines that shout the spell name.
