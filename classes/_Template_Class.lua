--[[
    Monologue Data Module: Class Template
    PURE DATA TABLE. NO ENGINE LOGIC ALLOWED.

    Key: the exact all-caps classFile returned by UnitClass("player"):
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID".

    SpellReactions pools:
      Tier1_MajorCD  major cooldowns (60s category cooldown)
      Tier2_Routine  routine casts while fighting a hostile target (90s)
      Tier3_LowHP    player drops to 25% health in combat (180s)

    Optional SpellTriggers (add only for spells that exist in WoW Forever):
      SpellTriggers = { [spellID] = "Tier1_MajorCD" }
      SpellNames    = { [spellID] = "Recklessness" }
    Spell IDs are rank-specific: list every rank of a ranked spell. SpellNames is optional
    but lets /mono triggers flag an ID that the client resolves to a different spell.
    Use /mono spellid to print the ID of each spell you cast.
    Casts not listed there fall back to Tier2_Routine.

    Lines should suit any race of the class (Undead Paladins, Dwarf Shamans, Skyborne
    Druids/Mages/Shamans) and respect the WoW Forever canon guardrail.

    OPTIONAL pull lines (said in /s every few mob pulls, see Engine:ResolvePullPool):
      CombatOpeners = { 15+ lines }                       used when the pull spell has no pool
      SpellLines = { ["Charge"] = { 12-18 lines }, ... }  keyed by the English spell name
    Each pool is a shuffled deck: every line is used once before any repeats.

    Pool sizes: 8+ lines per SpellReactions tier, 15+ CombatOpeners, and 4 signature
    spells with 12+ SpellLines each.
--]]

MonologueEngine.Data.Classes["_Template_Class"] = {
    SpellReactions = {
        Tier1_MajorCD = {
            "Unleashing full power!",
        },
        Tier2_Routine = {
            "Striking target!",
        },
        Tier3_LowHP = {
            "I require assistance!",
        }
    },
    pvpStyle = "Aggressive"
}
