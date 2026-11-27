--[[
    Monologue Engine Core (Version .1)
    Handles 4-layer profile merging, centralized Voice Box output routing,
    cooldown management, event registration, and the persistent Nemesis Ledger.

    This file contains ZERO race, class, persona, or character speech data.
    All lines are supplied by the pure-data modules under races/, classes/,
    personas/, guilds/, groups/ and profiles/.
--]]

local ADDON_NAME = (...) or "Monologue_v.1"  -- the folder name, as the client passes it
local CHAT_PREFIX = "|cff00ccffMonologue:|r "

---------------------------------------------------------------------------
-- Engine Namespace
---------------------------------------------------------------------------

MonologueEngine = {
    Version = ".1",
    AddonName = ADDON_NAME,
    Data = {
        Races = {},
        Classes = {},
        Personas = {},
        Guilds = {},
        Groups = {},
        Profiles = {},
        Zones = {},  -- [zone name] = { lines } (zones/Zones.lua): zone-specific PvP lines
        Situations = {}, -- [situation key] = { lines } (situations/Situations.lua): world reactions
        DetailLines = {}, -- { Combat, Kill, LowHP, Idle } (situations/Details.lua): live-detail lines
        SpellContextLines = {}, -- { Player, Rare, Elite, Hurt, Party } (situations/Details.lua): shared spell context lines
        MomentLines = {}, -- { EatDrink, Mount, Rest, AllyDown } (situations/Moments.lua): everyday moments
        Allegiances = {}, -- Azeroth Identity (identity/Identity.lua): allegiances / orders
        Professions = {}, -- Azeroth Identity: trade lines
        Hometowns = {},   -- Azeroth Identity: region-grouped hometown list
        Upbringings = {}, -- Character Builder (identity/Builder.lua): upbringing / defining moment
        Traits = {},      -- Character Builder: defining trait (party banter)
        Friction = {},    -- Character Builder: party side-eye rules
        WorldMoments = {}, -- Character Builder: dungeon/battleground entry, inn, durability
        Bosses = {}, -- Optional data extension: [encounterID] = "FEAT_KEY"
    },
    ActiveProfile = {},
    ActiveContext = {},
    ShuffledPools = {},
    LastDrawn = {},
    Cooldowns = {
        GlobalBreath = 0,
        Categories = {},
    },
    State = {
        InRestrictedEncounter = false,
        InEncounter = false,
        Restrictions = {},       -- restriction types that block chat (encounters, M+, PvP matches)
        OtherRestrictions = {},  -- informational: Combat, Map and other types that don't block chat
        Recent = {},             -- recently engaged enemy players: [guid] = { fullName, key, guid, zone, time, alive }
        Memory = nil,            -- situation memory (see Engine:GetRecent): killer, diedAt, levelAt, drunkAt, streakSaid
        RecentKillNames = {},    -- [normalizedName] = time of the last credited kill, for dedupe by name
        EngagementCasts = {},    -- [guid] = true once you have cast at that player this fight
        LastKillCredit = 0,
        Pending = nil,           -- one automatic line waiting to be sent (see QueueSpeech)
        SendProblem = nil,       -- last reason a send failed, shown once in /mono status
        SendBlockedBy = nil,
        LastSpeechTime = 0,
        Engaged = nil,
        LowHealthArmed = true,
        RecentKills = {},
        GreetedAt = {},
        EmoteRepliedAt = {},     -- [guid or name key] = time your character last answered their emote
        RollMissLog = {},        -- [categoryKey] = last time a missed chance roll was logged
        RivalSkipLog = {},       -- [spell name] = last time "not an opener" was logged
        -- Pull-based combat pacing against mobs (session only; survives combat ending)
        PullCount = 0,           -- pulls since the last pull line
        NextSpeechPull = nil,    -- pull number that earns the next line (rolled from chattiness)
        PullSpeechArmed = false, -- this pull has earned a line; the next offensive cast says it
        SpokeThisPull = false,   -- a pull line was already said this fight
        PrePullSpokeAt = nil,    -- time a line was said by an opening cast, before combat began
    },
}

local Engine = MonologueEngine

-- Tuning constants for the newer systems (identity, party, situations, alpha tools). Kept in
-- one table: Lua 5.1 allows at most 200 locals in a file's main chunk.
local Tune = {}

-- Key Bindings > AddOns > Monologue (bindings are defined in Bindings.xml)
BINDING_HEADER_MONOLOGUE = "Monologue"
BINDING_NAME_MONOLOGUE_GREET = "Greet target (or say the waiting greeting)"
BINDING_NAME_MONOLOGUE_TOGGLE_IC = "Toggle in character / out of character"
BINDING_NAME_MONOLOGUE_BATTLECRY = "Battle cry"
BINDING_NAME_MONOLOGUE_TAUNT = "Taunt your enemy player target"

local frame = CreateFrame("Frame", "MonologueCoreFrame")
Engine.Frame = frame

local unitFrame = CreateFrame("Frame", "MonologueCoreUnitFrame")
Engine.UnitFrame = unitFrame

---------------------------------------------------------------------------
-- Engine Tuning Constants (mechanics only, no speech content)
---------------------------------------------------------------------------

-- Category cooldown (seconds) per trigger tier
local TIER_COOLDOWNS = {
    [1] = 60,  -- Major cooldown reactions
    [2] = 90,  -- Routine spell reactions
    [3] = 60,  -- PvP rivalry callouts
    [4] = 180, -- Low health / dramatic moments
    [5] = 120, -- Guildmate greetings
    [6] = 20,  -- Duel win / loss lines
    [7] = 90,  -- Rival opener callouts (per rival)
}

-- SpellReactions pool key -> trigger tier
local REACTION_TIERS = {
    Tier1_MajorCD = 1,
    Tier2_Routine = 2,
    Tier3_LowHP = 4,
}

-- SpellReactions pool key -> base proc chance (scaled by MonologueDB.chattiness)
local REACTION_CHANCE = {
    Tier1_MajorCD = 0.6,
    Tier2_Routine = 0.05,
    Tier3_LowHP = 0.75,
}

-- Growth arc brackets, evaluated top-down
local GROWTH_BRACKETS = {
    { minLevel = 50, arc = "stage3", stageKey = "Stage3_Late" },
    { minLevel = 20, arc = "stage2", stageKey = "Stage2_Mid" },
    { minLevel = 1,  arc = "stage1", stageKey = "Stage1_Early" },
}

-- Profile keys consumed by the merger itself and never copied into ActiveProfile
local META_KEYS = {
    GrowthStages = true,
    BossFeats = true,
    FactionSubtypes = true,
    Presets = true,          -- race temperament presets are applied selectively, never copied wholesale
}

local PVP_CHANCE = 0.4
local GUILD_GREET_CHANCE = 0.4     -- proc chance when targeting a guildmate (scaled by chattiness)
local RACE_GREET_CHANCE = 0.4      -- proc chance for a RaceGreetings line (scaled by chattiness)
local CRY_THROTTLE = 3             -- seconds between battle cries, to avoid chat flood
local DUEL_BANTER_SHARE = 0.35     -- greetings to a marked friend you've duelled that use duel banter
local FRIEND_GREET_CHANCE = 0.6    -- proc chance for a marked friend's greeting (scaled by chattiness)
local DUEL_LINE_CHANCE = 0.9       -- proc chance for a duel win/loss line (scaled by chattiness)
local MAX_DUELS = 200              -- cap on duel opponents kept per character
local DUEL_RESULT_DEDUPE = 5       -- seconds in which an identical duel result counts once
local DUEL_STATE_MAX_AGE = 600     -- seconds before an unfinished duel request is forgotten
local MAX_FRIENDS = 200            -- cap on marked friends per character
local MAX_NOTE_LENGTH = 100        -- longest friend note, in bytes
local GUILD_GREET_COOLDOWN = 600   -- seconds before the same guildmate is greeted again
local GUILD_MOTTO_CHANCE = 0.25    -- share of greetings drawn from the guild pack's mottos
local PVP_EMOTE_TOKEN = "THREATEN"
local NEMESIS_THRESHOLD = 5
local DOMINANCE_KILLS = 3
local ENGAGEMENT_WINDOW = 20      -- seconds an enemy player counts as "engaged"
local RECENT_KILL_WINDOW = 60     -- seconds before the same GUID can count as a kill again
local LOW_HP_THRESHOLD = 0.25
local LOW_HP_REARM = 0.50
local MAX_RIVALS = 100
local MAX_SKIRMISH_ZONES = 40
local SKIRMISH_TTL_DAYS = 30
local DEJAVU_MIN_SKIRMISHES = 3
local DEJAVU_WINDOW_DAYS = 14
local DAY_SECONDS = 86400
local MAX_CHAT_BYTES = 255
local MAX_PLAYER_LEVEL_CAP = 60

-- Open-world SAY/YELL from addon code requires a hardware event on the modern client.
-- Automated lines outside instances are rerouted as an emote in this format.
local OPEN_WORLD_EMOTE_FORMAT = "says, \"%s\""

-- WoW Forever raid encounter -> feat key registry (Classic Azeroth raids).
-- Encounter IDs follow the Classic encounter ID table. Custom WoW Forever
-- encounters (or corrected IDs) can be supplied via MonologueEngine.Data.Bosses.
Engine.BossRegistry = {
    -- Molten Core
    [663] = "LUCIFRON",
    [664] = "MAGMADAR",
    [665] = "GEHENNAS",
    [666] = "GARR",
    [667] = "SHAZZRAH",
    [668] = "BARON_GEDDON",
    [669] = "SULFURON",
    [670] = "GOLEMAGG",
    [671] = "MAJORDOMO_EXECUTUS",
    [672] = "RAGNAROS",
    -- Onyxia's Lair
    [1084] = "ONYXIA",
    -- Blackwing Lair
    [610] = "RAZORGORE",
    [616] = "CHROMAGGUS",
    [617] = "NEFARIAN",
    -- Zul'Gurub
    [793] = "HAKKAR",
    -- Ruins of Ahn'Qiraj
    [723] = "OSSIRIAN",
    -- Temple of Ahn'Qiraj
    [717] = "CTHUN",
    -- Naxxramas
    [1114] = "KELTHUZAD",
}

-- Ability-press voice (MonologueDB.pressVoice): /s lines said from inside your own ability
-- press, which the client treats as a key press. Each kind of place can be switched on/off.
local PRESS_VOICE_DEFAULTS = {
    enabled = true,       -- master switch
    world = true,         -- open world, fighting mobs
    worldpvp = true,      -- open world, fighting enemy players
    dungeon = true,       -- 5-man dungeons (and scenarios)
    raid = true,          -- raids
    boss = false,         -- boss fights (any instance); the client may still block chat here
    battleground = true,  -- battlegrounds (WoW Forever has no arenas)
    gap = 120,            -- seconds at least between ability-press /s lines
}

-- Persistent DB defaults
local DEFAULT_CONFIG = {
    enabled = true,
    translationIntensity = 2, -- 0: Off, 1: Light, 2: Standard, 3: Unhinged
    channelStepdown = true,
    chattiness = 1.0,         -- Multiplier for proc chances (greetings, duels, PvP, spell reactions)
    pullEvery = 3,            -- Pull lines: about one every N mob pulls (Voice Lines tab slider)
    situationChance = 40,     -- % of pull/signature lines that react to the moment when a situation applies
    globalBreath = 45,        -- Seconds of silence enforced after any line
    openWorldSpeech = "EMOTE", -- legacy, no longer used (background speech never calls SendChatMessage)
    backgroundSpeech = "QUEUE", -- background events (greetings, duel/PvP lines): "QUEUE" says the line aloud on your next ability press or click; "LOCAL" prints it in your chat only
    battleCryChannel = "YELL", -- channel for /mono cry and the Battle Cry button: "YELL" or "SAY"
    buttonShown = false,       -- Battle Cry HUD button: opt-in (My Voice tab checkbox, or /mono button)
    debugMode = false,         -- Unified [Monologue Debug] output (/mono debug)
    strictSafeMode = false,    -- Strict Safe-Mode: automated speech only prints in your own chat (General tab, /mono safemode)
    minimapShown = true,       -- Minimap button visibility (/mono minimap)
    minimapAngle = 215,        -- Minimap button position, in degrees around the minimap
    chatPreview = true,        -- Preview of the translation just above the chat box while typing (General tab)
    speechEffects = true,      -- Slurred when drunk, shaky when badly hurt (General tab)
    momentLines = true,        -- Everyday moments: eating, mounting, resting, an ally falling (Voice Lines tab)
    outOfCharacter = false,    -- In-character toggle (keybind, /mono ic, /mono ooc): true = no translation, no automatic lines
    queueBubble = true,        -- A bubble shows the line waiting for your next key press; click it to say it (Voice Lines tab)
    npcYells = true,           -- Now and then answer a creature or NPC yelling close by (Voice Lines tab)
    partyBanter = true,        -- Monologue users in your group may answer your lines, and you theirs (Voice Lines tab)
    fixTypos = false,          -- Fix common typos in typed chat ("teh" -> "the") (General tab)
    abilityAuto = true,        -- Spells without their own lines speak from a shared pool for their kind (Abilities tab)
    dungeonQuiet = false,      -- Automatic lines a quarter as often in dungeons, none in raids (Abilities tab)
    tauntButtonShown = false,  -- Taunt HUD button: opt-in (Voice Lines tab)
    translateKey = "ENTER",    -- Typed chat is translated on: "ENTER" (always), "SHIFT" or "CTRL" + Enter only (General tab)
    -- keepWords = { "word", ... } is written by the Words Never Translated list (My Voice tab, /mono keep)
    -- buttonPos = { point, relPoint, x, y } is written when the button is moved
}

-- Per-character progression (MonologueCharDB, SavedVariablesPerCharacter)
local CHAR_DB_KEYS = {
    "Rivals",          -- Nemesis ledger: [name] = { kills, deaths, lastSeen, lastZone, pinned }
    "SkirmishHistory", -- Zone-compressed skirmish counters: [zone] = { count, firstSeen, lastSeen }
    "GrowthArc",       -- { stage1 = "PersonaKey", stage2 = "PersonaKey", stage3 = "PersonaKey" }
    "Feats",           -- [FEAT_KEY] = true
    "Friends",         -- Marked friends: [normalizedName] = { name, race, note, addedAt }
    "Duels",           -- Duel records (separate from Rivals): [normalizedName] = { name, wins, losses, lastZone, lastTime }
    "CustomVoice",     -- My Voice: { persona, oaths, wordSwaps, phraseSwaps, battleCries, guildGreeting }
    "AbilityMap",      -- Abilities tab: [spell name] = Attack | Burst | Defend | Interrupt | Heal | None
    "RecentLines",     -- The last lines drawn, kept across logins so they aren't said again soon: { { k, t }, ... }
    "AbilityEvery",    -- Abilities tab: [spell name] = N (speaks on every Nth cast only)
    "SeenSpells",      -- Abilities tab: [spell name] = { id, at } for spells you have cast
}

---------------------------------------------------------------------------
-- Utilities
---------------------------------------------------------------------------

local issecretvalue = issecretvalue

-- Strips 12.0 secret values so they are never compared or used in arithmetic
local function Clean(value)
    if issecretvalue and issecretvalue(value) then return nil end
    return value
end
Engine.Clean = Clean

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(CHAT_PREFIX .. tostring(msg))
end
Engine.Print = Print

-- Lets an open Rivals & Friends roster window redraw when the data behind it changes
local function NotifyRosterChanged()
    if MonologueUI and MonologueUI.OnRosterDataChanged then
        MonologueUI:OnRosterDataChanged()
    end
end

---------------------------------------------------------------------------
-- Alpha diagnostics: a rolling log of the last Tune.DIAG_MAX debug events (always recorded, even
-- with debug mode off) and the last few Lua errors that mention Monologue. Both go into the
-- /mono bug report.
---------------------------------------------------------------------------

Engine.VERSION = "0.1.5.1"
Tune.DIAG_MAX = 20
Tune.MAX_ERRORS = 3
Engine.DiagnosticLog = {}
Engine.RecentErrors = {}

local function Stamp()
    return (type(date) == "function" and date("%H:%M:%S")) or ""
end

function Engine:Diag(message)
    local log = self.DiagnosticLog
    log[#log + 1] = Stamp() .. " " .. tostring(message)
    if #log > Tune.DIAG_MAX then table.remove(log, 1) end
end

local function CaptureError(message)
    local text = tostring(message)
    local stack = (type(debugstack) == "function" and debugstack(4, 6, 0)) or ""
    if not (text:find("Monologue", 1, true) or stack:find("Monologue", 1, true)) then return end
    local errors = Engine.RecentErrors
    local firstFrame = stack:match("[^\n]*Monologue[^\n]*") or ""
    errors[#errors + 1] = Stamp() .. " " .. text:sub(1, 300) .. (firstFrame ~= "" and ("\n    at " .. firstFrame:sub(1, 200)) or "")
    if #errors > Tune.MAX_ERRORS then table.remove(errors, 1) end
end
Engine.CaptureError = CaptureError

-- Wraps the current error handler (Blizzard's or BugGrabber's) and always hands the error on,
-- so nothing about normal error display changes
if type(geterrorhandler) == "function" and type(seterrorhandler) == "function" then
    pcall(function()
        local previous = geterrorhandler()
        seterrorhandler(function(message, ...)
            pcall(CaptureError, message)
            if type(previous) == "function" then return previous(message, ...) end
        end)
    end)
end

-- Debug output: concise "[Monologue Debug]" lines, printed only while MonologueDB.debugMode
-- is on (/mono debug, or the Debug Mode checkbox in the config window). Every message also
-- goes into the rolling diagnostic log.
function Engine:Debug(message)
    self:Diag(message)
    if MonologueDB and MonologueDB.debugMode then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffa500[Monologue Debug]|r " .. tostring(message))
    end
end

function Engine:SetDebugMode(enabled)
    if not MonologueDB then return end
    MonologueDB.debugMode = enabled and true or false
    Print("Debug mode " .. (MonologueDB.debugMode and "|cff00ff00ON|r" or "|cffff8800OFF|r"))
    if MonologueUI and MonologueUI.RefreshDebugControl then
        MonologueUI:RefreshDebugControl()
    end
end

local function DeepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = DeepCopy(v)
    end
    return copy
end
Engine.DeepCopy = DeepCopy

-- Speech pools are sequences; a higher layer replaces a pool wholesale rather
-- than overwriting it index-by-index. Keyed tables merge recursively.
local function IsSequence(t)
    return type(t) == "table" and #t > 0
end

-- Deep Merge Utility for 4-Layer Profile Composition (never mutates source data)
local function DeepMerge(target, source, skipKeys)
    if type(target) ~= "table" then target = {} end
    if type(source) ~= "table" then return target end

    for k, v in pairs(source) do
        if not (skipKeys and skipKeys[k]) then
            if type(v) == "table" then
                if IsSequence(v) then
                    target[k] = DeepCopy(v)
                elseif type(target[k]) ~= "table" then
                    target[k] = DeepMerge({}, v)
                else
                    target[k] = DeepMerge(target[k], v)
                end
            else
                target[k] = v
            end
        end
    end
    return target
end
Engine.DeepMerge = DeepMerge

local function UsablePool(pool)
    return type(pool) == "table" and #pool > 0
end

local function Clamp(value, low, high)
    if type(value) ~= "number" then return low end
    if value < low then return low end
    if value > high then return high end
    return value
end

-- Truncates to the client chat byte limit without splitting a UTF-8 character
local function TruncateChat(text)
    if #text <= MAX_CHAT_BYTES then return text end
    local cut = text:sub(1, MAX_CHAT_BYTES - 3)
    cut = cut:gsub("[\192-\255][\128-\191]*$", "")
    return cut .. "..."
end

local function SanitizeLine(text)
    text = text:gsub("[\r\n]+", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    text = text:gsub("%s%s+", " ")
    return text
end

local function SafeRegisterEvent(f, event)
    local ok = pcall(f.RegisterEvent, f, event)
    return ok
end

local function IsInPvPInstance()
    if not C_PvP then return false end
    local inBG = C_PvP.IsBattleground and C_PvP.IsBattleground()
    local inArena = C_PvP.IsArena and C_PvP.IsArena()
    return (inBG or inArena) and true or false
end

-- True only for real player GUIDs ("Player-<server>-<id>"). Creature-, Pet-, Vehicle-,
-- GameObject- and every other GUID type is rejected.
local function IsPlayerGUID(guid)
    return type(guid) == "string" and guid:find("^Player%-") ~= nil
end
Engine.IsPlayerGUID = IsPlayerGUID

-- Duel opponents are fellow faction members, so only a player of the OPPOSING faction counts
-- as an enemy for rival tracking and kill credit. If either faction can't be read, the unit
-- is not excluded.
local IsDuelOpponentUnit -- assigned below, once the name helpers exist
local function IsOpposingFaction(unit)
    local mine = Clean(UnitFactionGroup("player"))
    local theirs = Clean(UnitFactionGroup(unit))
    if mine and theirs and mine == theirs then return false end
    -- The current duel opponent is never an enemy, whatever their faction reads as
    if IsDuelOpponentUnit and IsDuelOpponentUnit(unit) then return false end
    return true
end

-- An enemy that is a real player: UnitIsPlayer must be true, and when the unit's GUID is
-- readable it must be a Player GUID. (If the GUID is hidden as a secret value, UnitIsPlayer
-- alone decides.) NPCs, mobs, pets and guards never pass.
local function IsHostilePlayer(unit)
    if not (UnitExists(unit) and UnitIsPlayer(unit) and UnitIsEnemy("player", unit)) then
        return false
    end
    -- A same-faction "enemy" is a duel opponent, not a rival
    if not IsOpposingFaction(unit) then return false end
    local guid = Clean(UnitGUID(unit))
    if guid ~= nil and not IsPlayerGUID(guid) then return false end
    return true
end

-- Character names on WoW Forever can contain spaces ("Carl Nage"). Only a hyphen
-- separates a realm, so "Carl Nage-SomeRealm" becomes "Carl Nage". Lookup keys are the
-- lower-case name with spaces, hyphens and apostrophes removed ("carlnage"); the display
-- name keeps its spaces.
local function StripRealm(rawName)
    if type(rawName) ~= "string" then return nil end
    return rawName:match("^([^-]+)")
end

local function NormalizeNameKey(name)
    return (tostring(name):lower():gsub("[%s%-_']", ""))
end

local function FirstWord(name)
    if type(name) ~= "string" then return nil end
    return name:match("^(%S+)")
end

-- The full multi-word name from the unit tooltip's first line, when the tooltip is showing
-- this unit and that line starts with firstName (e.g. "Tara" -> "Tara Page"). Colour codes,
-- a trailing <Guild> and a -Realm suffix are removed. Only for "target" and "mouseover".
local function NameFromTooltip(unit, firstName)
    if unit ~= "target" and unit ~= "mouseover" then return nil end
    if not GameTooltip or not GameTooltipTextLeft1 then return nil end

    local ok, _, tooltipUnit = pcall(GameTooltip.GetUnit, GameTooltip)
    if not ok or type(tooltipUnit) ~= "string" or not UnitIsUnit(tooltipUnit, unit) then return nil end

    local text = Clean(GameTooltipTextLeft1:GetText())
    if type(text) ~= "string" then return nil end
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    text = text:gsub("%s*<.->%s*$", "")
    text = StripRealm(text) or text
    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")

    if text:sub(1, #firstName):lower() ~= firstName:lower() then return nil end
    local following = text:sub(#firstName + 1, #firstName + 1)
    if following ~= "" and following ~= " " then return nil end
    if not text:find(" ", 1, true) then return nil end
    return text
end

-- A player unit's full display name and realm. Character names on WoW Forever can have
-- several words ("Tara Page"), and only the -Realm suffix is removed. Tried in order:
--   a) GetUnitName(unit, true),
--   b) UnitFullName(unit),
--   c) UnitName(unit), upgraded from the tooltip when unit is "target" or "mouseover".
-- The first candidate containing a space wins; otherwise the best single-word name.
-- Returns name, realm (realm may be nil), or nil.
local function GetFullPlayerName(unit)
    if not unit or not UnitExists(unit) then return nil end

    local candidates = {}
    local realm

    if GetUnitName then
        local raw = Clean(GetUnitName(unit, true))
        if type(raw) == "string" and raw ~= "" then
            local name = StripRealm(raw)
            if name then
                candidates[#candidates + 1] = name
                realm = raw:match("%-(.+)$")
            end
        end
    end

    local fullName, fullRealm = UnitFullName(unit)
    fullName, fullRealm = Clean(fullName), Clean(fullRealm)
    if type(fullName) == "string" and fullName ~= "" then
        candidates[#candidates + 1] = StripRealm(fullName) or fullName
        if not realm then
            if type(fullRealm) == "string" and fullRealm ~= "" then
                realm = fullRealm
            else
                realm = fullName:match("%-(.+)$")
            end
        end
    end

    for _, candidate in ipairs(candidates) do
        if candidate:find(" ", 1, true) then
            return candidate, (type(realm) == "string" and realm ~= "") and realm or nil
        end
    end

    local baseName = Clean(UnitName(unit))
    if type(baseName) == "string" and baseName ~= "" then
        baseName = StripRealm(baseName) or baseName
    else
        baseName = candidates[1]
    end
    if not baseName then return nil end

    local tooltipName = NameFromTooltip(unit, baseName)
    return tooltipName or baseName, (type(realm) == "string" and realm ~= "") and realm or nil
end

-- Every place that captures a player's name goes through this one helper
local UnitNameAndRealm = GetFullPlayerName

Engine.StripRealm = StripRealm
Engine.NormalizeNameKey = NormalizeNameKey
Engine.GetFullPlayerName = GetFullPlayerName

-- True for the opponent of the duel in progress (State.Duel, see the Duels section)
IsDuelOpponentUnit = function(unit)
    local duel = Engine.State.Duel
    if not duel then return false end
    if GetTime() - (duel.since or 0) > DUEL_STATE_MAX_AGE then
        Engine.State.Duel = nil
        return false
    end
    local name = UnitNameAndRealm(unit)
    return name ~= nil and NormalizeNameKey(name) == duel.key
end

---------------------------------------------------------------------------
-- Saved Variables
---------------------------------------------------------------------------

function Engine:InitializeDB()
    -- A first-time player (no saved settings yet) starts on the simple menu; everyone who has
    -- played before keeps the full tabs they know
    local firstTime = type(MonologueDB) ~= "table" or next(MonologueDB) == nil
    if type(MonologueDB) ~= "table" then MonologueDB = {} end
    if MonologueDB.menuMode ~= "SIMPLE" and MonologueDB.menuMode ~= "FULL" then
        MonologueDB.menuMode = firstTime and "SIMPLE" or "FULL"
    end
    if type(MonologueCharDB) ~= "table" then MonologueCharDB = {} end

    -- Progression data saved account-wide by earlier builds moves to the first
    -- character that loads, then leaves the global table.
    for _, key in ipairs(CHAR_DB_KEYS) do
        local stale = MonologueDB[key]
        if stale ~= nil then
            local current = MonologueCharDB[key]
            if type(stale) == "table" and next(stale) ~= nil
                and (type(current) ~= "table" or next(current) == nil) then
                MonologueCharDB[key] = stale
            end
            MonologueDB[key] = nil
        end
    end

    for k, v in pairs(DEFAULT_CONFIG) do
        if MonologueDB[k] == nil then
            MonologueDB[k] = DeepCopy(v)
        end
    end

    MonologueDB.translationIntensity = Clamp(math.floor(tonumber(MonologueDB.translationIntensity) or 2), 0, 3)
    MonologueDB.chattiness = Clamp(tonumber(MonologueDB.chattiness) or 1.0, 0, 3)
    MonologueDB.pullEvery = Clamp(math.floor(tonumber(MonologueDB.pullEvery) or 3), 1, 10)
    MonologueDB.situationChance = Clamp(math.floor(tonumber(MonologueDB.situationChance) or 40), 0, 100)
    MonologueDB.globalBreath = Clamp(tonumber(MonologueDB.globalBreath) or 45, 5, 600)
    if MonologueDB.openWorldSpeech ~= "SAY" and MonologueDB.openWorldSpeech ~= "EMOTE" then
        MonologueDB.openWorldSpeech = "EMOTE"
    end
    if MonologueDB.battleCryChannel ~= "SAY" and MonologueDB.battleCryChannel ~= "YELL" then
        MonologueDB.battleCryChannel = "YELL"
    end
    if MonologueDB.backgroundSpeech ~= "LOCAL" and MonologueDB.backgroundSpeech ~= "QUEUE" then
        MonologueDB.backgroundSpeech = "LOCAL"
    end
    MonologueDB.debugMode = MonologueDB.debugMode == true
    MonologueDB.strictSafeMode = MonologueDB.strictSafeMode == true
    MonologueDB.castSendBlocked = nil   -- retired: cast events never send any more
    MonologueDB.keypressBlocked = nil   -- retired (the jump route was removed)
    MonologueDB.greetButtonShown = MonologueDB.greetButtonShown == true
    MonologueDB.tauntButtonShown = MonologueDB.tauntButtonShown == true
    MonologueDB.emoteReplies = MonologueDB.emoteReplies ~= false
    -- Ability-press voice: where /s lines may be said (menu: My Voice tab)
    if type(MonologueDB.pressVoice) ~= "table" then MonologueDB.pressVoice = {} end
    for key, default in pairs(PRESS_VOICE_DEFAULTS) do
        if type(MonologueDB.pressVoice[key]) ~= type(default) then MonologueDB.pressVoice[key] = default end
    end
    MonologueDB.pressVoice.gap = Clamp(MonologueDB.pressVoice.gap, 30, 900)
    if type(MonologueDB.pressVoiceBlocked) ~= "table" then MonologueDB.pressVoiceBlocked = {} end
    MonologueDB.enabled = MonologueDB.enabled ~= false
    MonologueDB.channelStepdown = MonologueDB.channelStepdown ~= false
    -- Which chat channels the translator works in (General tab, "Translate In"). New installs
    -- get Say, Yell and Party; an existing install that had the group step-down switched off
    -- (so raid chat was translated) keeps Raid and Instance on.
    if type(MonologueDB.translateChannels) ~= "table" then
        local groupOn = MonologueDB.channelStepdown == false
        MonologueDB.translateChannels = {
            SAY = true, YELL = true, PARTY = true, RAID = groupOn, INSTANCE = groupOn,
            GUILD = false, OFFICER = false, WHISPER = false,
        }
    end
    for _, key in ipairs({ "SAY", "YELL", "PARTY", "RAID", "INSTANCE", "GUILD", "OFFICER", "WHISPER" }) do
        MonologueDB.translateChannels[key] = MonologueDB.translateChannels[key] == true
    end
    -- The Battle Cry button became opt-in: hide it once for existing installs, after which
    -- the player's own choice (checkbox or /mono button) is kept
    if not MonologueDB.cryButtonOptIn then
        MonologueDB.cryButtonOptIn = true
        MonologueDB.buttonShown = false
    end
    MonologueDB.buttonShown = MonologueDB.buttonShown == true
    MonologueDB.pressVoice = type(MonologueDB.pressVoice) == "table" and MonologueDB.pressVoice or nil
    if MonologueDB.pressVoice then MonologueDB.pressVoice.arena = nil end
    if type(MonologueDB.pressVoiceBlocked) == "table" then MonologueDB.pressVoiceBlocked.arena = nil end
    MonologueDB.minimapShown = MonologueDB.minimapShown ~= false
    MonologueDB.minimapAngle = tonumber(MonologueDB.minimapAngle) or 215
    if type(MonologueDB.buttonPos) ~= "table" then MonologueDB.buttonPos = nil end
    for _, key in ipairs(CHAR_DB_KEYS) do
        if type(MonologueCharDB[key]) ~= "table" then MonologueCharDB[key] = {} end
    end
end

---------------------------------------------------------------------------
-- Bloat Prevention & Long-Term Ledger Hygiene Engine
---------------------------------------------------------------------------

local function IsProtectedRival(rival)
    return ((rival.kills or 0) + (rival.deaths or 0)) >= NEMESIS_THRESHOLD or rival.pinned
end

function Engine:PruneRivals(maxEntries)
    if not MonologueCharDB or not MonologueCharDB.Rivals then return end

    maxEntries = maxEntries or MAX_RIVALS
    local now = GetServerTime()

    -- Pass 1: Evict stale single-clash and non-Nemesis entries
    for name, rival in pairs(MonologueCharDB.Rivals) do
        if type(rival) ~= "table" then
            MonologueCharDB.Rivals[name] = nil
        elseif not rival.pinned then
            local totalClashes = (rival.kills or 0) + (rival.deaths or 0)
            local ageInDays = (now - (rival.lastSeen or 0)) / DAY_SECONDS

            if totalClashes <= 1 and ageInDays > 30 then
                MonologueCharDB.Rivals[name] = nil
            elseif totalClashes < NEMESIS_THRESHOLD and ageInDays > 90 then
                MonologueCharDB.Rivals[name] = nil
            end
        end
    end

    -- Pass 2: Enforce strict LRU cap protecting Nemesis and pinned rivals
    local rivalList = {}
    for name, rival in pairs(MonologueCharDB.Rivals) do
        rivalList[#rivalList + 1] = { name = name, rival = rival }
    end

    if #rivalList > maxEntries then
        table.sort(rivalList, function(a, b)
            local aProtected = IsProtectedRival(a.rival) and true or false
            local bProtected = IsProtectedRival(b.rival) and true or false
            if aProtected ~= bProtected then
                return aProtected
            end
            return (a.rival.lastSeen or 0) > (b.rival.lastSeen or 0)
        end)

        for i = maxEntries + 1, #rivalList do
            MonologueCharDB.Rivals[rivalList[i].name] = nil
        end
    end
end

-- SkirmishHistory stores one aggregated counter per zone instead of per-fight
-- logs (zone compression). Stale zones expire and the table is LRU-capped.
function Engine:PruneSkirmishHistory(maxZones)
    if not MonologueCharDB or not MonologueCharDB.SkirmishHistory then return end

    maxZones = maxZones or MAX_SKIRMISH_ZONES
    local now = GetServerTime()
    local history = MonologueCharDB.SkirmishHistory

    local zoneList = {}
    for zone, entry in pairs(history) do
        if type(entry) ~= "table" or (now - (entry.lastSeen or 0)) / DAY_SECONDS > SKIRMISH_TTL_DAYS then
            history[zone] = nil
        else
            zoneList[#zoneList + 1] = { zone = zone, lastSeen = entry.lastSeen or 0 }
        end
    end

    if #zoneList > maxZones then
        table.sort(zoneList, function(a, b) return a.lastSeen > b.lastSeen end)
        for i = maxZones + 1, #zoneList do
            history[zoneList[i].zone] = nil
        end
    end
end

function Engine:RecordSkirmish(zone)
    if not MonologueCharDB or not zone or zone == "" then return end
    local now = GetServerTime()
    local entry = MonologueCharDB.SkirmishHistory[zone] or { count = 0, firstSeen = now, lastSeen = now }
    entry.count = (entry.count or 0) + 1
    entry.lastSeen = now
    MonologueCharDB.SkirmishHistory[zone] = entry
    self:PruneSkirmishHistory(MAX_SKIRMISH_ZONES)
end

function Engine:IsDejaVuZone(zone)
    local history = MonologueCharDB and MonologueCharDB.SkirmishHistory
    local entry = history and zone and history[zone]
    if not entry then return false end
    local ageInDays = (GetServerTime() - (entry.lastSeen or 0)) / DAY_SECONDS
    return (entry.count or 0) >= DEJAVU_MIN_SKIRMISHES and ageInDays <= DEJAVU_WINDOW_DAYS
end

---------------------------------------------------------------------------
-- Deck-Shuffle Pool Retrieval (Prevents raw math.random repetition)
---------------------------------------------------------------------------

-- A pool's identity for deck purposes: its size plus its first and last lines. Profile
-- rebuilds create new tables with the same lines, and the deck must survive those.
local function PoolSignature(lines)
    return #lines .. "" .. tostring(lines[1]) .. "" .. tostring(lines[#lines])
end

-- Draws from a shuffled deck per category: every line comes up once before any repeats.
-- The last few lines said are remembered across reshuffles (and profile rebuilds), so a
-- fresh deck never opens with something you just heard.
function Engine:GetShuffledLine(categoryKey, linesTable)
    if type(linesTable) ~= "table" or #linesTable == 0 then return nil end
    categoryKey = categoryKey or "default"

    local deck = self.ShuffledPools[categoryKey]
    local signature = PoolSignature(linesTable)

    -- Rebuild when exhausted or when the pool's contents changed
    if not deck or #deck == 0 or deck.signature ~= signature then
        local recent = self.LastDrawn[categoryKey]
        local avoid = {}
        if type(recent) == "table" then
            local keep = math.min(#recent, #linesTable - 1)
            for i = #recent - keep + 1, #recent do
                if recent[i] then avoid[recent[i]] = true end
            end
        end

        local fresh, held = {}, {}
        for i = 1, #linesTable do
            local line = linesTable[i]
            if avoid[line] then held[#held + 1] = line else fresh[#fresh + 1] = line end
        end
        -- Fisher-Yates shuffle of the fresh lines
        for i = #fresh, 2, -1 do
            local j = math.random(i)
            fresh[i], fresh[j] = fresh[j], fresh[i]
        end
        -- Lines are drawn from the end, so recently said ones go to the front (drawn last)
        deck = { signature = signature }
        for _, line in ipairs(held) do deck[#deck + 1] = line end
        for _, line in ipairs(fresh) do deck[#deck + 1] = line end
        self.ShuffledPools[categoryKey] = deck
    end

    local line = table.remove(deck)
    -- Cross-party echo suppression: skip a line a party member just said (draw the next card;
    -- the skipped one goes to the bottom of the deck)
    if self.IsPartyEcho and #deck > 0 and self:IsPartyEcho(line) then
        for _ = 1, #deck do
            table.insert(deck, 1, line)
            line = table.remove(deck)
            if not self:IsPartyEcho(line) then break end
        end
        self:Debug("echo suppressed: a party member just said that line")
    end
    -- Said recently (in any pool, this session or the last): draw another if there is one
    if self.IsRecentlySaid and #deck > 0 and self:IsRecentlySaid(line) then
        for _ = 1, #deck do
            table.insert(deck, 1, line)
            line = table.remove(deck)
            if not self:IsRecentlySaid(line) then break end
        end
    end
    -- Requires rule: a line whose detail tokens ({weapon}, {party}, ...) can't be filled
    -- right now goes to the bottom of the deck and the next card is drawn
    if self.LineDetailsAvailable and not self:LineDetailsAvailable(line) then
        local found = false
        for _ = 1, #deck do
            table.insert(deck, 1, line)
            line = table.remove(deck)
            if self:LineDetailsAvailable(line) then found = true; break end
        end
        if not found then
            table.insert(deck, 1, line)
            self:Debug("no line in " .. categoryKey .. " can be filled right now (missing details)")
            return nil
        end
    end
    local recent = self.LastDrawn[categoryKey]
    if type(recent) ~= "table" then
        recent = {}
        self.LastDrawn[categoryKey] = recent
    end
    recent[#recent + 1] = line
    if #recent > 3 then table.remove(recent, 1) end
    if self.NoteRecentLine then pcall(self.NoteRecentLine, self, line) end
    return line
end

---------------------------------------------------------------------------
-- Boss Feats
---------------------------------------------------------------------------

function Engine:IsValidFeat(featKey)
    for _, key in pairs(self.BossRegistry) do
        if key == featKey then return true end
    end
    for _, key in pairs(self.Data.Bosses) do
        if key == featKey then return true end
    end
    return false
end

function Engine:GetFeatForEncounter(encounterID)
    return self.Data.Bosses[encounterID] or self.BossRegistry[encounterID]
end

-- Boss Feat Unlock Helper
function Engine:UnlockFeat(featKey)
    if type(featKey) ~= "string" or featKey == "" or not MonologueCharDB then return false end
    featKey = featKey:upper()

    if not self:IsValidFeat(featKey) then
        Print("Unknown boss feat '" .. featKey .. "'. Feats are limited to registered WoW Forever encounters.")
        return false
    end

    MonologueCharDB.Feats = MonologueCharDB.Feats or {}
    if MonologueCharDB.Feats[featKey] then return false end

    MonologueCharDB.Feats[featKey] = true
    self:BuildActiveProfile()
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffMonologue Feat Unlocked:|r " .. featKey)
    return true
end

---------------------------------------------------------------------------
-- Profile Assembly Engine
---------------------------------------------------------------------------

function Engine:GetGrowthStage(level)
    level = tonumber(level) or 1
    for _, bracket in ipairs(GROWTH_BRACKETS) do
        if level >= bracket.minLevel then
            return bracket.arc, bracket.stageKey
        end
    end
    return "stage1", "Stage1_Early"
end

-- Bracket descriptors (lowest level first) for configuration front-ends
function Engine:GetGrowthBrackets()
    local list = {}
    for i = #GROWTH_BRACKETS, 1, -1 do
        local bracket = GROWTH_BRACKETS[i]
        local nextBracket = GROWTH_BRACKETS[i - 1]
        local upper = nextBracket and (nextBracket.minLevel - 1) or MAX_PLAYER_LEVEL_CAP
        list[#list + 1] = { arc = bracket.arc, stageKey = bracket.stageKey, minLevel = bracket.minLevel, maxLevel = upper }
    end
    return list
end

-- Installed persona keys, excluding schema templates
function Engine:GetPersonaKeys()
    local keys = {}
    for key in pairs(self.Data.Personas) do
        if type(key) == "string" and not key:find("^_Template") then
            keys[#keys + 1] = key
        end
    end
    table.sort(keys)
    return keys
end

function Engine:GetPersonaDisplayName(personaKey)
    local persona = personaKey and self.Data.Personas[personaKey]
    if type(persona) == "table" and type(persona.displayName) == "string" then
        return persona.displayName
    end
    return personaKey
end

-- Assigns a persona to a growth stage for the current character (nil clears it)
function Engine:SetGrowthArcPersona(arc, personaKey)
    if not MonologueCharDB then return false end

    local validArc = false
    for _, bracket in ipairs(GROWTH_BRACKETS) do
        if bracket.arc == arc then validArc = true end
    end
    if not validArc then return false end
    if personaKey ~= nil and not self.Data.Personas[personaKey] then return false end

    MonologueCharDB.GrowthArc[arc] = personaKey
    self:BuildActiveProfile()
    return true
end

-- Profile keys are matched to the logged-in character by exact name first
-- ("Name-Realm", then "Name"), then by a normalized form that ignores case, spaces,
-- hyphens and apostrophes, so a profile keyed "CarlNage" matches a character shown as
-- "Carl Nage", "Carl-Nage" or "Carl" on a realm named "Nage".
local NormalizeProfileKey = NormalizeNameKey

function Engine:GetCharacterProfileKey()
    local name, realm = GetFullPlayerName("player")
    realm = realm or GetNormalizedRealmName()
    if not name then return nil end

    if realm and self.Data.Profiles[name .. "-" .. realm] then
        return name .. "-" .. realm
    end
    if self.Data.Profiles[name] then
        return name
    end

    local wanted = { [NormalizeProfileKey(name)] = true }
    if realm and realm ~= "" then
        wanted[NormalizeProfileKey(name .. realm)] = true
    end
    for key in pairs(self.Data.Profiles) do
        if type(key) == "string" and not key:find("^_Template") and wanted[NormalizeProfileKey(key)] then
            return key
        end
    end
    return nil
end

-- Finds the guild pack in Data.Guilds whose guildName matches the player's guild,
-- ignoring case, spaces and punctuation. A pack may also list alternative names in
-- guildNames = { "Name", ... }. Returns the pack's key, or nil.
function Engine:FindGuildPackKey(guildName)
    if type(guildName) ~= "string" or guildName == "" then return nil end
    local wanted = NormalizeProfileKey(guildName)

    local keys = {}
    for key in pairs(self.Data.Guilds) do
        if type(key) == "string" and not key:find("^_Template") then keys[#keys + 1] = key end
    end
    table.sort(keys)

    for _, key in ipairs(keys) do
        local pack = self.Data.Guilds[key]
        if type(pack) == "table" then
            if type(pack.guildName) == "string" and NormalizeProfileKey(pack.guildName) == wanted then
                return key
            end
            if type(pack.guildNames) == "table" then
                for _, alias in ipairs(pack.guildNames) do
                    if NormalizeProfileKey(alias) == wanted then return key end
                end
            end
        end
    end
    return nil
end

---------------------------------------------------------------------------
-- Custom Voice (MonologueCharDB.CustomVoice): in-game, per-character voice settings
-- layered on top of everything else. Never mutates the static pack tables.
---------------------------------------------------------------------------

local CV_MAX_ITEMS = 30        -- per list (oaths, battle cries, swaps)
local CV_MAX_TEXT = 120        -- bytes per line / swap value
local CV_MAX_KEY = 40          -- bytes per swap trigger
local CV_HEADER = "MONO1:"

local function CVCleanText(text, limit)
    if type(text) ~= "string" then return nil end
    text = strtrim((text:gsub("[%c|]", " ")))   -- no control chars or color/escape pipes
    if text == "" then return nil end
    if #text > limit then text = text:sub(1, limit) end
    return text
end

-- "a, b, c" -> { "a", "b", "c" }, one entry -> "a"
local function CVParseVariants(value)
    if type(value) ~= "string" then return nil end
    local variants = {}
    for piece in value:gmatch("[^,]+") do
        piece = strtrim(piece)
        if piece ~= "" then variants[#variants + 1] = piece end
    end
    if #variants == 0 then return nil end
    if #variants == 1 then return variants[1] end
    return variants
end

-- Azeroth Identity fields (My Voice tab): clan key, custom clan name, hometown, allegiance key,
-- profession key (nil = auto-detect)
local CV_IDENTITY_FIELDS = { "clan", "clanName", "hometown", "allegiance", "profession",
    "upbringing", "trait", "trait2", "dialectStrength", "oath", "nemesis", "catchphrase", "companion", "taunts", "nicknames" }
-- Enemy Faction (My Voice): how mean taunts are (nil = Off), and race nicknames in your chat
-- (nil = Off; ENEMY = the other faction's races, ALL = every race). Lines: situations/Taunts.lua
Tune.TAUNT_LEVELS = { CIVIL = "Civil", ROUGH = "Rough", SAVAGE = "Savage" }
Tune.NICKNAME_MODES = { ENEMY = true, ALL = true }
Tune.TAUNT_SHARE = 0.5     -- a target-change line at an enemy player that is a taunt, when one fits
Tune.TAUNT_BUTTON_GAP = 6  -- seconds between taunts from the button, keybind or /mono taunt
-- Character Anchors (free text): longer than names
local CV_MAX_ANCHOR = 80
local CV_ANCHOR_FIELDS = { oath = true, nemesis = true, catchphrase = true, companion = true }
-- Dialect Strength (My Voice): nil = Full (follows the General tab), LIGHT, CLEAN
local CV_DIALECT_STRENGTHS = { LIGHT = true, CLEAN = true }
local CV_MAX_NAME = 40

local function CVNewTable()
    return { oaths = {}, wordSwaps = {}, phraseSwaps = {}, battleCries = {}, raceStances = {}, extraLines = {}, quirks = {} }
end

-- Quirks (Abilities tab): "when <trigger> matching <text> [only if <condition>], say one of
-- these lines". Each: { trigger, match, cond, chance, lines }. Run by Monologue_Quirks.lua.
--   trigger  ITEM (equip or loot an item), PLACE (enter a zone or subzone), TARGET (target a
--            creature or player), CHAT (someone near you or in your group says a word)
--   match    text matched in the item's name, type or quality / the place / the target's name,
--            type, family, race or class / a whole word in the message ("" = anything; CHAT
--            needs a word)
--   cond     ALWAYS, COMBAT, PEACE, DUNGEON, RESTING, HAS:<profession>, NOT:<profession>,
--            MOOD:<mood>
--   chance   100, 60, 30 or 10 (percent)
Tune.QUIRK_TRIGGERS = { ITEM = true, PLACE = true, TARGET = true, CHAT = true }
Tune.QUIRK_CHANCES = { [100] = true, [60] = true, [30] = true, [10] = true }
Tune.QUIRK_MAX = 20
Tune.QUIRK_MAX_LINES = 12
Tune.QUIRK_MAX_MATCH = 40

function Engine:QuirkConditionValid(cond)
    if cond == "ALWAYS" or cond == "COMBAT" or cond == "PEACE" or cond == "DUNGEON" or cond == "RESTING" then return true end
    local kind, value = tostring(cond):match("^(%u+):(%a+)$")
    if kind == "HAS" or kind == "NOT" then return self.Data.Professions[value] ~= nil end
    if kind == "MOOD" then return type(Tune.MOODS) == "table" and Tune.MOODS[value] ~= nil end
    return false
end

-- Cross-race stances, from friendliest to coldest (labels live in Monologue_UI.lua)
local CV_STANCES = {
    WARM = true,        -- warm, respectful
    ADMIRING = true,    -- looks up to them
    PLAYFUL = true,     -- teasing, good-natured ribbing
    WARY = true,        -- distrustful, keeps an eye on them
    GRUFF = true,       -- rivalry, stubborn pride
    DISDAINFUL = true,  -- looks down on them
}

-- Returns this character's CustomVoice table, creating or repairing it as needed
function Engine:GetCustomVoice()
    if not MonologueCharDB then return nil end
    local cv = MonologueCharDB.CustomVoice
    if type(cv) ~= "table" then
        cv = CVNewTable()
        MonologueCharDB.CustomVoice = cv
    end
    for _, key in ipairs({ "oaths", "wordSwaps", "phraseSwaps", "battleCries", "raceStances", "extraLines" }) do
        if type(cv[key]) ~= "table" then cv[key] = {} end
    end
    -- Your lines for single spells and moments: string keys, lists of non-empty strings
    for poolKey, list in pairs(cv.extraLines) do
        local clean = {}
        if type(poolKey) == "string" and type(list) == "table" then
            for _, line in ipairs(list) do
                if type(line) == "string" and line ~= "" then clean[#clean + 1] = line end
            end
        end
        cv.extraLines[poolKey] = #clean > 0 and clean or nil
    end
    -- Quirks: known triggers, a short match text, a valid condition and chance, clean lines
    local quirks = {}
    for _, q in ipairs(type(cv.quirks) == "table" and cv.quirks or {}) do
        if type(q) == "table" and Tune.QUIRK_TRIGGERS[q.trigger] and #quirks < Tune.QUIRK_MAX then
            q.match = type(q.match) == "string" and CVCleanText(q.match, Tune.QUIRK_MAX_MATCH) or ""
            if not Engine:QuirkConditionValid(q.cond) then q.cond = "ALWAYS" end
            q.chance = Tune.QUIRK_CHANCES[tonumber(q.chance)] and tonumber(q.chance) or 60
            local lines = {}
            for _, line in ipairs(type(q.lines) == "table" and q.lines or {}) do
                local text = type(line) == "string" and CVCleanText(line, CV_MAX_TEXT) or nil
                if text and #lines < Tune.QUIRK_MAX_LINES then lines[#lines + 1] = text end
            end
            q.lines = lines
            if #lines > 0 and not (q.trigger == "CHAT" and q.match == "") then quirks[#quirks + 1] = q end
        end
    end
    cv.quirks = quirks
    -- Old openers and closers (before 0.1.3) become oaths: "By Magni's beard," and
    -- ", by Magni's beard!" both turn into "By Magni's beard!"
    for _, oldKey in ipairs({ "openers", "closers", "suffixes" }) do
        if type(cv[oldKey]) == "table" then
            for _, line in ipairs(cv[oldKey]) do
                if type(line) == "string" then
                    line = strtrim((line:gsub("^[%s,;:]+", ""):gsub("[%s,;:]+$", "")))
                    if line:find("%a") and #cv.oaths < CV_MAX_ITEMS then
                        line = line:sub(1, 1):upper() .. line:sub(2)
                        if not line:find("[%.!%?]$") then line = line .. "!" end
                        local duplicate = false
                        for _, existing in ipairs(cv.oaths) do
                            if type(existing) == "string" and existing:lower() == line:lower() then duplicate = true end
                        end
                        if not duplicate then cv.oaths[#cv.oaths + 1] = line end
                    end
                end
            end
        end
        cv[oldKey] = nil
    end
    -- Lists: keep only non-empty strings, in order (also closes any holes)
    for _, key in ipairs({ "oaths", "battleCries" }) do
        local clean = {}
        for _, line in ipairs(cv[key]) do
            if type(line) == "string" and line ~= "" then clean[#clean + 1] = line end
        end
        cv[key] = clean
    end
    -- Maps: string keys and string values only; stances must be WARM or GRUFF
    for _, key in ipairs({ "wordSwaps", "phraseSwaps", "raceStances" }) do
        local doomed = {}
        for k, val in pairs(cv[key]) do
            if type(k) ~= "string" or k == "" or type(val) ~= "string" or val == ""
                or (key == "raceStances" and not CV_STANCES[val]) then
                doomed[#doomed + 1] = k
            end
        end
        for _, k in ipairs(doomed) do cv[key][k] = nil end
    end
    if type(cv.persona) ~= "string" or cv.persona == "" then cv.persona = nil end
    if type(cv.guildGreeting) ~= "string" or cv.guildGreeting == "" then cv.guildGreeting = nil end
    if type(cv.racePreset) ~= "string" or cv.racePreset == "" or cv.racePreset == "Default" then cv.racePreset = nil end
    -- Azeroth Identity: plain strings or nothing (validated again where they are used)
    for _, key in ipairs(CV_IDENTITY_FIELDS) do
        if type(cv[key]) ~= "string" or cv[key] == "" then cv[key] = nil end
    end
    if cv.allegiance and not Engine.Data.Allegiances[cv.allegiance] then cv.allegiance = nil end
    if cv.profession and not Engine.Data.Professions[cv.profession] then cv.profession = nil end
    if cv.upbringing and not Engine.Data.Upbringings[cv.upbringing] then cv.upbringing = nil end
    if cv.trait and not Engine.Data.Traits[cv.trait] then cv.trait = nil end
    if cv.trait2 and (not Engine.Data.Traits[cv.trait2] or cv.trait2 == cv.trait) then cv.trait2 = nil end
    if cv.dialectStrength and not CV_DIALECT_STRENGTHS[cv.dialectStrength] then cv.dialectStrength = nil end
    if cv.taunts and not Tune.TAUNT_LEVELS[cv.taunts] then cv.taunts = nil end
    if cv.nicknames and not Tune.NICKNAME_MODES[cv.nicknames] then cv.nicknames = nil end
    return cv
end

function Engine:HasCustomVoice()
    local cv = MonologueCharDB and MonologueCharDB.CustomVoice
    if type(cv) ~= "table" then return false end
    for _, key in ipairs(CV_IDENTITY_FIELDS) do
        if cv[key] ~= nil then return true end
    end
    return cv.persona ~= nil or cv.guildGreeting ~= nil or cv.racePreset ~= nil
        or next(cv.raceStances or {}) ~= nil or #(cv.oaths or cv.openers or {}) > 0
        or #(cv.closers or {}) > 0 or #(cv.battleCries or {}) > 0
        or next(cv.wordSwaps or {}) ~= nil or next(cv.phraseSwaps or {}) ~= nil
        or next(cv.extraLines or {}) ~= nil or #(cv.quirks or {}) > 0
end

-- Adds a line to the quirk with this trigger, match, condition and chance (made if new).
-- Returns ok, message.
function Engine:QuirkAddLine(trigger, match, cond, chance, text)
    local cv = self:GetCustomVoice()
    if not cv then return false end
    if not Tune.QUIRK_TRIGGERS[trigger] then return false, "Pick what sets the quirk off first." end
    match = CVCleanText(match or "", Tune.QUIRK_MAX_MATCH) or ""
    if trigger == "CHAT" and match == "" then return false, "A chat quirk needs a word to listen for." end
    if not self:QuirkConditionValid(cond) then cond = "ALWAYS" end
    chance = Tune.QUIRK_CHANCES[tonumber(chance)] and tonumber(chance) or 60
    local line = CVCleanText(text, CV_MAX_TEXT)
    if not line then return false, "Type a line first." end
    for _, q in ipairs(cv.quirks) do
        if q.trigger == trigger and q.match:lower() == match:lower() and q.cond == cond and q.chance == chance then
            for _, existing in ipairs(q.lines) do
                if existing:lower() == line:lower() then return false, "That quirk already has that line." end
            end
            if #q.lines >= Tune.QUIRK_MAX_LINES then return false, "That quirk is full (" .. Tune.QUIRK_MAX_LINES .. " lines)." end
            q.lines[#q.lines + 1] = line
            return true
        end
    end
    if #cv.quirks >= Tune.QUIRK_MAX then return false, "You have the most quirks allowed (" .. Tune.QUIRK_MAX .. ")." end
    cv.quirks[#cv.quirks + 1] = { trigger = trigger, match = match, cond = cond, chance = chance, lines = { line } }
    return true
end

-- Removes one line (lineIndex) or, without one, the whole quirk at index
function Engine:QuirkRemove(index, lineIndex)
    local cv = self:GetCustomVoice()
    local q = cv and cv.quirks[index]
    if not q then return false end
    if lineIndex then
        table.remove(q.lines, lineIndex)
        if #q.lines > 0 then return true end
    end
    table.remove(cv.quirks, index)
    return true
end

local function CVAppendList(base, extra)
    local out = {}
    if type(base) == "table" then
        for _, line in ipairs(base) do out[#out + 1] = line end
    end
    for _, line in ipairs(extra) do out[#out + 1] = line end
    return out
end

-- Layers the custom voice over an already merged profile (merged is a private copy)
local function ApplyCustomVoice(merged, cv)
    if type(cv) ~= "table" then return false end
    local used = false

    local dialect = type(merged.Dialect) == "table" and merged.Dialect or {}
    -- My Oaths: usable in every moment (the "Any" group)
    if type(cv.oaths) == "table" and #cv.oaths > 0 then
        local base = type(dialect.oaths) == "table" and dialect.oaths or {}
        local oaths = { Greet = base.Greet, Fight = base.Fight, Hurt = base.Hurt }
        oaths.Any = CVAppendList(#base > 0 and base or base.Any, cv.oaths)
        dialect.oaths = oaths
        used = true
    end
    for _, swapKey in ipairs({ "wordSwaps", "phraseSwaps" }) do
        for from, to in pairs(cv[swapKey]) do
            local parsed = CVParseVariants(to)
            if type(from) == "string" and parsed then
                if type(dialect[swapKey]) ~= "table" then dialect[swapKey] = {} end
                dialect[swapKey][from:lower()] = parsed
                used = true
            end
        end
    end
    if used then merged.Dialect = dialect end

    if #cv.battleCries > 0 then
        local base = merged.BattleCry
        if not (type(base) == "table" and #base > 0) then
            local reactions = type(merged.SpellReactions) == "table" and merged.SpellReactions or nil
            base = reactions and reactions.Tier1_MajorCD
        end
        merged.BattleCry = CVAppendList(base, cv.battleCries)
        used = true
    end

    if cv.guildGreeting then
        local greetings = type(merged.GuildGreetings) == "table" and merged.GuildGreetings or {}
        greetings.Standard = CVAppendList(greetings.Standard, { cv.guildGreeting })
        merged.GuildGreetings = greetings
        used = true
    end

    -- Your own lines for single spells, moments and ability kinds (Abilities tab). The
    -- merged profile is a private copy, so its pools may be replaced or extended in place.
    if type(cv.extraLines) == "table" then
        local contextKeys = { Rare = true, Elite = true, Player = true, Hurt = true, Party = true }
        local data = Engine.Data
        for poolKey, lines in pairs(cv.extraLines) do
            local kind, key
            if type(poolKey) == "string" then kind, key = poolKey:match("^(%a+):(.+)$") end
            if kind and type(lines) == "table" and #lines > 0 then
                if kind == "Spell" then
                    if type(merged.SpellLines) ~= "table" then merged.SpellLines = {} end
                    local entry = merged.SpellLines[key]
                    if type(entry) ~= "table" then
                        merged.SpellLines[key] = CVAppendList(nil, lines)
                    elseif #entry > 0 then
                        local copy = CVAppendList(entry, lines)
                        for k, val in pairs(entry) do
                            if type(k) ~= "number" then copy[k] = val end
                        end
                        merged.SpellLines[key] = copy
                    else
                        -- Lines split by persona: yours join the default pool and every persona's
                        entry.Default = CVAppendList(entry.Default, lines)
                        for k, val in pairs(entry) do
                            if k ~= "Default" and not contextKeys[k] and type(val) == "table" and #val > 0 then
                                entry[k] = CVAppendList(val, lines)
                            end
                        end
                    end
                elseif kind == "Moment" then
                    if type(merged.Moments) ~= "table" then merged.Moments = {} end
                    local base = merged.Moments[key]
                    if not (type(base) == "table" and #base > 0) then base = data.MomentLines and data.MomentLines[key] end
                    merged.Moments[key] = CVAppendList(base, lines)
                elseif kind == "Ability" then
                    if type(merged.AbilityLines) ~= "table" then merged.AbilityLines = {} end
                    local base = merged.AbilityLines[key]
                    if not (type(base) == "table" and #base > 0) then
                        base = (type(merged.Moments) == "table" and merged.Moments[key])
                            or (data.AbilityLines and data.AbilityLines[key])
                            or (data.MomentLines and data.MomentLines[key])
                    end
                    merged.AbilityLines[key] = CVAppendList(base, lines)
                end
                used = true
            end
        end
    end
    return used
end

-- Mutators used by the My Voice tab. Each returns ok, message and rebuilds the profile.
function Engine:CustomVoiceAddLine(listKey, text)
    local cv = self:GetCustomVoice()
    if not cv or (listKey ~= "oaths" and listKey ~= "battleCries") then
        return false, "bad list"
    end
    text = CVCleanText(text, CV_MAX_TEXT)
    if not text then return false, "Type a line first." end
    local list = cv[listKey]
    if #list >= CV_MAX_ITEMS then return false, "That list is full (" .. CV_MAX_ITEMS .. ")." end
    for _, existing in ipairs(list) do
        if existing:lower() == text:lower() then return false, "Already in the list." end
    end
    list[#list + 1] = text
    self:BuildActiveProfile()
    return true
end

-- expectedText (optional) guards against a stale index, e.g. a double-click on [x]
function Engine:CustomVoiceRemoveLine(listKey, index, expectedText)
    local cv = self:GetCustomVoice()
    local list = cv and cv[listKey]
    if type(list) ~= "table" or not list[index] then return false end
    if expectedText ~= nil and list[index] ~= expectedText then return false end
    table.remove(list, index)
    self:BuildActiveProfile()
    return true
end

-- Your own lines for one spell, moment or ability kind (Abilities tab). poolKey is
-- "Spell:<name>", "Moment:<moment>" or "Ability:<kind>". Returns the list (may be empty).
function Engine:GetPoolLines(poolKey)
    local cv = self:GetCustomVoice()
    local list = cv and type(poolKey) == "string" and cv.extraLines[poolKey]
    return type(list) == "table" and list or {}
end

function Engine:CustomVoiceAddPoolLine(poolKey, text)
    local cv = self:GetCustomVoice()
    if not cv then return false, "bad list" end
    if not self:ValidPoolKey(poolKey) then return false, "Pick a spell or moment first." end
    text = CVCleanText(text, CV_MAX_TEXT)
    if not text then return false, "Type a line first." end
    local list = cv.extraLines[poolKey]
    if type(list) ~= "table" then
        local pools = 0
        for _ in pairs(cv.extraLines) do pools = pools + 1 end
        if pools >= Tune.POOL_KEYS_MAX then
            return false, "You already have lines for " .. pools .. " spells and moments (the most there can be)."
        end
        list = {}
        cv.extraLines[poolKey] = list
    end
    if #list >= CV_MAX_ITEMS then return false, "That list is full (" .. CV_MAX_ITEMS .. ")." end
    for _, existing in ipairs(list) do
        if existing:lower() == text:lower() then return false, "Already in the list." end
    end
    list[#list + 1] = text
    self:BuildActiveProfile()
    return true
end

-- expectedText (optional) guards against a stale index, e.g. a double-click on [x]
function Engine:CustomVoiceRemovePoolLine(poolKey, index, expectedText)
    local cv = self:GetCustomVoice()
    local list = cv and type(poolKey) == "string" and cv.extraLines[poolKey]
    if type(list) ~= "table" or type(list[index]) ~= "string" then return false end
    if expectedText and list[index] ~= expectedText then return false end
    table.remove(list, index)
    if #list == 0 then cv.extraLines[poolKey] = nil end
    self:BuildActiveProfile()
    return true
end

function Engine:CustomVoiceAddSwap(swapKey, from, to)
    local cv = self:GetCustomVoice()
    if not cv or (swapKey ~= "wordSwaps" and swapKey ~= "phraseSwaps") then return false, "bad swap type" end
    from = CVCleanText(from, CV_MAX_KEY)
    to = CVCleanText(to, CV_MAX_TEXT)
    if not from or not to then return false, "Fill in both From and To." end
    from = from:lower()
    if not CVParseVariants(to) then return false, "Fill in both From and To." end
    local count = 0
    for _ in pairs(cv[swapKey]) do count = count + 1 end
    if cv[swapKey][from] == nil and count >= CV_MAX_ITEMS then
        return false, "That swap list is full (" .. CV_MAX_ITEMS .. ")."
    end
    cv[swapKey][from] = to
    self:BuildActiveProfile()
    return true
end

function Engine:CustomVoiceRemoveSwap(swapKey, from)
    local cv = self:GetCustomVoice()
    if not cv or not cv[swapKey] or cv[swapKey][from] == nil then return false end
    cv[swapKey][from] = nil
    self:BuildActiveProfile()
    return true
end

local function IsSelectablePersona(key)
    return type(key) == "string" and Engine.Data.Personas[key] ~= nil and not key:find("^_Template")
end

function Engine:CustomVoiceSetPersona(personaKey)
    local cv = self:GetCustomVoice()
    if not cv then return false end
    if personaKey and personaKey ~= "" and not IsSelectablePersona(personaKey) then return false end
    cv.persona = (personaKey and personaKey ~= "") and personaKey or nil
    self:BuildActiveProfile()
    return true
end

function Engine:CustomVoiceSetGuildGreeting(text)
    local cv = self:GetCustomVoice()
    if not cv then return false end
    cv.guildGreeting = CVCleanText(text, CV_MAX_TEXT)
    self:BuildActiveProfile()
    return true
end

-- Clans of the player's race (race pack Clans), in pack order: { { key, name }, ... }
function Engine:GetClanOptions()
    local raceFile = self.ActiveContext and self.ActiveContext.race
    local raceData = raceFile and self.Data.Races[raceFile]
    local clans = type(raceData) == "table" and raceData.Clans or nil
    local options = {}
    if type(clans) == "table" then
        for _, clan in ipairs(clans) do
            if type(clan) == "table" and type(clan.key) == "string" then
                options[#options + 1] = { key = clan.key, name = clan.name or clan.key, data = clan }
            end
        end
    end
    return options
end

-- Sets one Azeroth Identity field. value nil or "" clears it. Returns ok, message.
function Engine:CustomVoiceSetIdentity(field, value)
    local cv = self:GetCustomVoice()
    if not cv then return false end
    if value == "" then value = nil end
    if field == "clan" then
        if value ~= nil then
            local valid = false
            for _, option in ipairs(self:GetClanOptions()) do
                if option.key == value then valid = true end
            end
            if not valid then return false, "That clan isn't one of your race's." end
        end
        cv.clan = value
    elseif field == "clanName" or field == "hometown" then
        cv[field] = value and CVCleanText(value, CV_MAX_NAME) or nil
    elseif field == "allegiance" then
        if value ~= nil and not self.Data.Allegiances[value] then return false, "Unknown allegiance." end
        cv.allegiance = value
    elseif field == "profession" then
        if value ~= nil and not self.Data.Professions[value] then return false, "Unknown profession." end
        cv.profession = value
    elseif field == "upbringing" then
        if value ~= nil and not self.Data.Upbringings[value] then return false, "Unknown upbringing." end
        cv.upbringing = value
    elseif field == "trait" or field == "trait2" then
        if value ~= nil and not self.Data.Traits[value] then return false, "Unknown trait." end
        local other = field == "trait" and "trait2" or "trait"
        if value ~= nil and cv[other] == value then return false, "That trait is already your other one." end
        cv[field] = value
    elseif CV_ANCHOR_FIELDS[field] then
        cv[field] = value and CVCleanText(value, CV_MAX_ANCHOR) or nil
    elseif field == "dialectStrength" then
        if value == "FULL" then value = nil end
        if value ~= nil and not CV_DIALECT_STRENGTHS[value] then return false, "Unknown dialect strength." end
        cv.dialectStrength = value
    elseif field == "taunts" or field == "nicknames" then
        if value == "OFF" then value = nil end
        local known = field == "taunts" and Tune.TAUNT_LEVELS or Tune.NICKNAME_MODES
        if value ~= nil and not known[value] then return false, "Unknown choice." end
        cv[field] = value
    else
        return false, "bad field"
    end
    self:BuildActiveProfile()
    return true
end

function Engine:ResetCustomVoice()
    if not MonologueCharDB then return end
    MonologueCharDB.CustomVoice = CVNewTable()
    self:BuildActiveProfile()
end

-- Share strings: "MONO1:" + records joined by ";", each "<tag>:<value>" with every value
-- percent-encoded (so ; : = and commas can never clash). Tags: p persona, g guild greeting,
-- o opener, c closer, b battle cry, w word swap, h phrase swap (w/h values are from=to).
local function CVEncode(s)
    return (s:gsub("[^%w _%.'%-!%?]", function(c) return string.format("%%%02X", c:byte()) end))
end

local function CVDecode(s)
    return (s:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

function Engine:ExportCustomVoice()
    local cv = self:GetCustomVoice()
    if not cv then return CV_HEADER end
    local records = {}
    if cv.persona then records[#records + 1] = "p:" .. CVEncode(cv.persona) end
    if cv.racePreset then records[#records + 1] = "r:" .. CVEncode(cv.racePreset) end
    for _, race in ipairs((function() local k = {} for r in pairs(cv.raceStances) do k[#k + 1] = r end table.sort(k) return k end)()) do
        records[#records + 1] = "s:" .. CVEncode(race) .. "=" .. CVEncode(cv.raceStances[race])
    end
    if cv.guildGreeting then records[#records + 1] = "g:" .. CVEncode(cv.guildGreeting) end
    for _, line in ipairs(cv.oaths) do records[#records + 1] = "v:" .. CVEncode(line) end
    for _, line in ipairs(cv.battleCries) do records[#records + 1] = "b:" .. CVEncode(line) end
    local function addSwaps(tag, swaps)
        local keys = {}
        for from in pairs(swaps) do keys[#keys + 1] = from end
        table.sort(keys)
        for _, from in ipairs(keys) do
            records[#records + 1] = tag .. ":" .. CVEncode(from) .. "=" .. CVEncode(swaps[from])
        end
    end
    addSwaps("w", cv.wordSwaps)
    addSwaps("h", cv.phraseSwaps)
    -- e = your lines for one spell, moment or ability kind
    local poolKeys = {}
    for poolKey in pairs(cv.extraLines or {}) do poolKeys[#poolKeys + 1] = poolKey end
    table.sort(poolKeys)
    for _, poolKey in ipairs(poolKeys) do
        for _, line in ipairs(cv.extraLines[poolKey]) do
            records[#records + 1] = "e:" .. CVEncode(poolKey) .. "=" .. CVEncode(line)
        end
    end
    -- Q = one quirk line: trigger=match=condition=chance=line
    for _, q in ipairs(cv.quirks or {}) do
        for _, line in ipairs(q.lines) do
            records[#records + 1] = "Q:" .. CVEncode(q.trigger) .. "=" .. CVEncode(q.match) .. "=" .. CVEncode(q.cond)
                .. "=" .. tostring(q.chance) .. "=" .. CVEncode(line)
        end
    end
    -- Identity: l clan, n clan name, t hometown, a allegiance, f profession, u upbringing,
    -- x trait, d dialect strength
    for _, pair in ipairs({ { "l", "clan" }, { "n", "clanName" }, { "t", "hometown" }, { "a", "allegiance" },
        { "f", "profession" }, { "u", "upbringing" }, { "x", "trait" }, { "d", "dialectStrength" },
        { "y", "trait2" }, { "k", "oath" }, { "m", "nemesis" }, { "q", "catchphrase" },
        { "j", "taunts" }, { "z", "nicknames" }, { "i", "companion" } }) do
        if cv[pair[2]] then records[#records + 1] = pair[1] .. ":" .. CVEncode(cv[pair[2]]) end
    end
    return CV_HEADER .. table.concat(records, ";")
end

local CV_IDENTITY_TAGS = { l = "clan", n = "clanName", t = "hometown", a = "allegiance", f = "profession",
    u = "upbringing", x = "trait", d = "dialectStrength", y = "trait2", k = "oath", m = "nemesis", q = "catchphrase",
    j = "taunts", z = "nicknames", i = "companion" }

-- Parses a share string into a fresh table; returns nil, reason when it is not valid
local function CVParseString(str)
    if type(str) ~= "string" then return nil, "Nothing to import." end
    str = strtrim(str)
    if str:sub(1, #CV_HEADER) ~= CV_HEADER then
        return nil, "That is not a Monologue voice string (it must start with MONO1:)."
    end
    local body = str:sub(#CV_HEADER + 1)
    if #body > 100000 then return nil, "That string is too long." end
    if not body:find("%a:") then return nil, "That voice string is empty: there is nothing to import." end

    local cv = CVNewTable()
    -- v = oaths; o / c are openers and closers from older strings, turned into oaths later
    cv.openers = {}
    local lists = { v = cv.oaths, o = cv.openers, c = cv.openers, b = cv.battleCries }
    for record in (body .. ";"):gmatch("([^;]*);") do
        if record ~= "" then
            local tag, value = record:match("^(%a):(.*)$")
            if not tag then return nil, "Unreadable record in the string." end
            if tag == "Q" then
                local trigger, match, cond, chance, line = value:match("^([^=]*)=([^=]*)=([^=]*)=([^=]*)=(.*)$")
                if trigger then
                    trigger, match, cond, line = CVDecode(trigger), CVDecode(match), CVDecode(cond), CVDecode(line)
                    local into
                    for _, q in ipairs(cv.quirks) do
                        if q.trigger == trigger and q.match == match and q.cond == cond and tostring(q.chance) == chance then into = q end
                    end
                    if into then
                        into.lines[#into.lines + 1] = line
                    else
                        cv.quirks[#cv.quirks + 1] = { trigger = trigger, match = match, cond = cond, chance = tonumber(chance), lines = { line } }
                    end
                end
            elseif tag == "p" then
                cv.persona = CVCleanText(CVDecode(value), CV_MAX_KEY)
            elseif tag == "r" then
                cv.racePreset = CVCleanText(CVDecode(value), CV_MAX_KEY)
            elseif tag == "s" then
                local race, stance = value:match("^([^=]*)=(.*)$")
                race = race and CVCleanText(CVDecode(race), CV_MAX_KEY)
                stance = stance and CVDecode(stance):upper()
                if race and stance and CV_STANCES[stance] then cv.raceStances[race] = stance end
            elseif tag == "g" then
                cv.guildGreeting = CVCleanText(CVDecode(value), CV_MAX_TEXT)
            elseif lists[tag] then
                local text = CVCleanText(CVDecode(value), CV_MAX_TEXT)
                if text and #lists[tag] < CV_MAX_ITEMS then lists[tag][#lists[tag] + 1] = text end
            elseif CV_IDENTITY_TAGS[tag] then
                local field = CV_IDENTITY_TAGS[tag]
                cv[field] = CVCleanText(CVDecode(value), CV_ANCHOR_FIELDS[field] and CV_MAX_ANCHOR or CV_MAX_NAME)
            elseif tag == "e" then
                local poolKey, line = value:match("^([^=]*)=(.*)$")
                poolKey = poolKey and CVCleanText(CVDecode(poolKey), CV_MAX_TEXT)
                line = line and CVCleanText(CVDecode(line), CV_MAX_TEXT)
                if poolKey and line and Engine:ValidPoolKey(poolKey) then
                    local list = cv.extraLines[poolKey]
                    if not list then
                        local pools = 0
                        for _ in pairs(cv.extraLines) do pools = pools + 1 end
                        if pools < Tune.POOL_KEYS_MAX then
                            list = {}
                            cv.extraLines[poolKey] = list
                        end
                    end
                    if list and #list < CV_MAX_ITEMS then list[#list + 1] = line end
                end
            elseif tag == "w" or tag == "h" then
                local from, to = value:match("^([^=]*)=(.*)$")
                from = from and CVCleanText(CVDecode(from), CV_MAX_KEY)
                to = to and CVCleanText(CVDecode(to), CV_MAX_TEXT)
                local target = tag == "w" and cv.wordSwaps or cv.phraseSwaps
                if from and to and CVParseVariants(to) then target[from:lower()] = to end
            end
        end
    end
    return cv
end

-- Replaces this character's custom voice with the imported one
function Engine:ImportCustomVoice(str)
    local ok, parsed, reason = pcall(CVParseString, str)
    if not ok then return false, "That string could not be read." end
    if not parsed then return false, reason end
    local notes = {}
    if parsed.persona and not IsSelectablePersona(parsed.persona) then
        notes[#notes + 1] = "persona '" .. parsed.persona .. "' (not installed)"
        parsed.persona = nil
    end
    local known = {}
    for _, option in ipairs(self:GetRacePresetOptions()) do known[option.key] = true end
    if parsed.racePreset and not known[parsed.racePreset] then
        notes[#notes + 1] = "racial temperament '" .. parsed.racePreset .. "' (not a preset of your race)"
        parsed.racePreset = nil
    end
    -- A clan must belong to the importing character's race (its custom name goes with it)
    if parsed.clan then
        local valid = false
        for _, option in ipairs(self:GetClanOptions()) do
            if option.key == parsed.clan then valid = true end
        end
        if not valid then
            notes[#notes + 1] = "clan '" .. parsed.clan .. "' (not a clan of your race)"
            parsed.clan, parsed.clanName = nil, nil
        end
    end
    if parsed.allegiance and not self.Data.Allegiances[parsed.allegiance] then
        notes[#notes + 1] = "allegiance '" .. parsed.allegiance .. "' (unknown)"
        parsed.allegiance = nil
    end
    if parsed.profession and not self.Data.Professions[parsed.profession] then
        notes[#notes + 1] = "profession '" .. parsed.profession .. "' (unknown)"
        parsed.profession = nil
    end
    for _, check in ipairs({ { "upbringing", self.Data.Upbringings }, { "trait", self.Data.Traits },
        { "trait2", self.Data.Traits },
        { "dialectStrength", CV_DIALECT_STRENGTHS }, { "taunts", Tune.TAUNT_LEVELS },
        { "nicknames", Tune.NICKNAME_MODES } }) do
        local field, known = check[1], check[2]
        if parsed[field] and not known[parsed[field]] then
            notes[#notes + 1] = field .. " '" .. parsed[field] .. "' (unknown)"
            parsed[field] = nil
        end
    end
    MonologueCharDB.CustomVoice = parsed
    self:BuildActiveProfile()
    if #notes > 0 then
        return true, "Imported, but skipped: " .. table.concat(notes, "; ") .. "."
    end
    return true
end

---------------------------------------------------------------------------
-- Azeroth Identity (My Voice tab): clan / lineage, hometown, allegiance, profession.
-- Saved in CustomVoice (clan, clanName, hometown, allegiance, profession). The lines come
-- from the race pack's Clans and identity/Identity.lua:
--   * Combat lines (race CombatOpeners, clan, allegiance) join pull lines now and then,
--   * Greet lines (clan, allegiance) join friendly greetings now and then,
--   * Hostile lines (allegiance) react to specific foes through the Situations system,
--   * Idle lines (clan, profession) are muttered on an out-of-combat ability press,
--   * hometown and profession moments (homecoming, a fallen home, homesick, city visits,
--     loot, repairs) are background lines: said on your next ability press or Greet click.
---------------------------------------------------------------------------

Tune.IDENTITY_OPENER_CHANCE = 0.30  -- share of pull lines taken from race/clan/allegiance openers
Tune.IDENTITY_GREET_SHARE = 0.25    -- share of friendly greetings taken from clan/allegiance lines
Tune.MY_GUILD_GREET_SHARE = 0.75    -- guildmate greetings that use your own (My Voice) guild greeting when a guild pack also has lines
Tune.ALLEGIANCE_HOSTILE_SHARE = 0.6 -- when both exist, allegiance foe lines win this often
Tune.IDLE_CHANCE = 0.12             -- per out-of-combat ability press (x chattiness)
Tune.IDLE_COOLDOWN = 900            -- at least 15 min between idle lines
Tune.IDENTITY_MOMENT_TIER = 8       -- category cooldown tier for hometown/profession moments
Tune.HOMETOWN_COOLDOWN = 1800
Tune.HOMESICK_COOLDOWN = 3600
Tune.HOMESICK_CHANCE = 0.25
Tune.CITY_COOLDOWN = 1200
Tune.CITY_CHANCE = 0.5
Tune.LOOT_COOLDOWN = 900
Tune.LOOT_CHANCE = 0.08
Tune.REPAIR_COOLDOWN = 1200
Tune.REPAIR_CHANCE = 0.6

-- Profession skill line IDs -> Data.Professions keys (auto-detection)
local PROFESSION_BY_SKILL_LINE = {
    [164] = "Blacksmithing", [186] = "Mining", [171] = "Alchemy", [182] = "Herbalism",
    [202] = "Engineering", [165] = "Leatherworking", [393] = "Skinning", [197] = "Tailoring",
    [333] = "Enchanting", [185] = "Cooking", [356] = "Fishing", [129] = "FirstAid",
}
local PROFESSION_BY_NAME = {
    blacksmithing = "Blacksmithing", mining = "Mining", alchemy = "Alchemy", herbalism = "Herbalism",
    engineering = "Engineering", leatherworking = "Leatherworking", skinning = "Skinning",
    tailoring = "Tailoring", enchanting = "Enchanting", cooking = "Cooking", fishing = "Fishing",
    ["first aid"] = "FirstAid",
}

-- The chosen clan's data table for the player's race, or nil
function Engine:GetClan()
    local cv = self:GetCustomVoice()
    if not (cv and cv.clan) then return nil end
    for _, option in ipairs(self:GetClanOptions()) do
        if option.key == cv.clan then return option.data end
    end
    return nil
end

-- "Bronzebeard Clan", a custom name, or nil
function Engine:GetClanDisplayName()
    local cv = self:GetCustomVoice()
    if cv and cv.clanName then return cv.clanName end
    local clan = self:GetClan()
    return clan and clan.name or nil
end

function Engine:GetAllegiance()
    local cv = self:GetCustomVoice()
    local key = cv and cv.allegiance
    local data = key and self.Data.Allegiances[key]
    if type(data) == "table" then return data, key end
    return nil
end

-- name, option (option is nil for a custom hometown)
function Engine:GetHometown()
    local cv = self:GetCustomVoice()
    local name = cv and cv.hometown
    if not name then return nil end
    local lowered = name:lower()
    for _, group in ipairs(self.Data.Hometowns or {}) do
        for _, option in ipairs(group.list or {}) do
            if option.name:lower() == lowered then return option.name, option end
        end
    end
    return name, nil
end

-- Learned professions (auto-detected), primary first; cached until the skills change
function Engine:DetectProfessions()
    local cache = self.State.ProfessionCache
    if cache and GetTime() - cache.at < 300 then return cache.list end
    local found, seen = {}, {}
    local function add(key)
        if key and not seen[key] and self.Data.Professions[key] then
            seen[key] = true
            found[#found + 1] = key
        end
    end
    if type(GetProfessions) == "function" and type(GetProfessionInfo) == "function" then
        local ok, p1, p2, arch, fish, cook, aid = pcall(GetProfessions)
        if ok then
            for _, index in ipairs({ p1 or false, p2 or false, cook or false, fish or false, aid or false }) do
                if index then
                    local okInfo, name, _, _, _, _, _, skillLine = pcall(GetProfessionInfo, index)
                    if okInfo then
                        add(PROFESSION_BY_SKILL_LINE[Clean(skillLine)]
                            or (type(Clean(name)) == "string" and PROFESSION_BY_NAME[name:lower()]))
                    end
                end
            end
        end
    end
    if #found == 0 and type(GetNumSkillLines) == "function" and type(GetSkillLineInfo) == "function" then
        local okCount, count = pcall(GetNumSkillLines)
        for i = 1, (okCount and tonumber(count) or 0) do
            local okInfo, name, isHeader = pcall(GetSkillLineInfo, i)
            if okInfo and not isHeader and type(Clean(name)) == "string" then
                add(PROFESSION_BY_NAME[name:lower()])
            end
        end
    end
    self.State.ProfessionCache = { at = GetTime(), list = found }
    return found
end

-- The professions whose lines are used: the manual override, else the detected ones
function Engine:GetProfessionKeys()
    local cv = self:GetCustomVoice()
    if cv and cv.profession then return { cv.profession } end
    return self:DetectProfessions()
end

function Engine:GetProfessionDisplayName()
    local key = self:GetProfessionKeys()[1]
    local data = key and self.Data.Professions[key]
    return data and data.name or nil
end

-- Candidates for one kind of identity line ("Combat", "Greet" or "Idle"). Returns a random
-- deckKey, pool, label (or nil).
-- Variety Engine: weighted cross-layer pool mixer. Every layer the character has set up
-- gets a share of the lines for a moment (kind = Combat, LowHP, Kill, Loot, Idle, Greet);
-- shares renormalize over the layers that have lines for it, and inside a layer the share
-- splits evenly (two traits, clan + upbringing, hometown + professions + anchors). Each
-- sub-pool keeps its own shuffle deck, so a character works through every combined line
-- before any one repeats.
local LAYER_WEIGHTS = {
    class = 25,       -- the spell's or class pool passed in by the caller
    trait = 20,       -- defining traits (1-2)
    lineage = 20,     -- clan + upbringing
    companion = 10,   -- your companion (My Voice), only when one is set
    allegiance = 15,  -- allegiance / order
    roots = 10,       -- hometown, professions, character anchors
    race = 10,        -- race pack (and temperament) pool
    detail = 10,      -- live-detail lines (situations/Details.lua): weapon, spell, party, ...
}

-- Returns deckKey, pool, label (or nil). classDeck/classPool/classLabel: the caller's own
-- pool (a spell's lines, the class low-health lines); raceDeck/racePool likewise.
-- A layer's weight shrinks when it has few lines (a 1-line layer is chosen 1/8 as often as a
-- full one), and all the pools of the chosen layer (clan + upbringing, hometown + professions
-- + anchors, ...) share one deck, so a tiny pool never repeats the same line over and over
Tune.LAYER_FULL_SIZE = 8
function Engine:PickLayeredPool(kind, classDeck, classPool, classLabel, raceDeck, racePool)
    local layers, total = {}, 0
    local function layer(name, subs)
        local usable, lines = {}, 0
        for _, sub in ipairs(subs) do
            if UsablePool(sub[2]) then
                usable[#usable + 1] = sub
                lines = lines + #sub[2]
            end
        end
        if #usable > 0 then
            local weight = LAYER_WEIGHTS[name] * math.min(1, lines / Tune.LAYER_FULL_SIZE)
            layers[#layers + 1] = { name = name, weight = weight, subs = usable }
            total = total + weight
        end
    end
    local cv = self:GetCustomVoice() or {}
    local raceFile = self.ActiveContext and self.ActiveContext.race

    layer("class", { { classDeck, classPool, classLabel } })

    local traits = {}
    for _, field in ipairs({ "trait", "trait2" }) do
        local key = cv[field]
        local data = key and self.Data.Traits[key]
        if data then traits[#traits + 1] = { "Trait_" .. key .. "_" .. kind, data[kind], "trait " .. data.name } end
    end
    layer("trait", traits)

    local lineage = {}
    local clan = self:GetClan()
    if clan and raceFile then
        lineage[#lineage + 1] = { "Clan_" .. raceFile .. "_" .. tostring(clan.key) .. "_" .. kind, clan[kind], "clan " .. tostring(clan.name) }
    end
    local upbringing, upbringingKey = self:GetUpbringing()
    if upbringing then
        lineage[#lineage + 1] = { "Upbringing_" .. upbringingKey .. "_" .. kind, upbringing[kind], "upbringing " .. tostring(upbringing.name) }
    end
    layer("lineage", lineage)

    local allegiance, allegianceKey = self:GetAllegiance()
    if allegiance then
        layer("allegiance", { { "Allegiance_" .. allegianceKey .. "_" .. kind, allegiance[kind], "allegiance " .. tostring(allegiance.name) } })
    end

    local roots = {}
    local hometownLines = self.Data.HometownKindLines
    if cv.hometown and type(hometownLines) == "table" then
        roots[#roots + 1] = { "Roots_Hometown_" .. kind, hometownLines[kind], "hometown" }
    end
    for _, key in ipairs(self:GetProfessionKeys()) do
        local data = self.Data.Professions[key]
        roots[#roots + 1] = { "Profession_" .. key .. "_" .. kind, data and data[kind], "profession " .. key }
    end
    local anchors = self.Data.AnchorLines or {}
    for field, anchorKey in pairs({ oath = "Oath", nemesis = "Nemesis", catchphrase = "Catchphrase" }) do
        if cv[field] and type(anchors[anchorKey]) == "table" then
            roots[#roots + 1] = { "Anchor_" .. anchorKey .. "_" .. kind, anchors[anchorKey][kind], "anchor " .. field }
        end
    end
    layer("roots", roots)

    -- Your companion (My Voice: a pet or animal friend): its own layer, so it comes up now
    -- and then. A profile's CompanionLines (Carl's macaw) win over the shared ones.
    if cv.companion then
        local own = type(self.ActiveProfile.CompanionLines) == "table" and self.ActiveProfile.CompanionLines[kind] or nil
        local shared = type(anchors.Companion) == "table" and anchors.Companion[kind] or nil
        if UsablePool(own) then
            layer("companion", { { "Companion_Own_" .. kind, own, "your companion (profile)" } })
        else
            layer("companion", { { "Anchor_Companion_" .. kind, shared, "your companion" } })
        end
    end

    local raceSubs = { { raceDeck, racePool, "race" } }
    if kind == "Combat" and raceFile then
        -- Read from the race pack itself, so a class pack's CombatOpeners can't hide it
        local raceData = self.Data.Races[raceFile]
        raceSubs[#raceSubs + 1] = { "RaceOpeners_" .. raceFile, type(raceData) == "table" and raceData.CombatOpeners, "racial opener" }
    end
    layer("race", raceSubs)

    -- Live-detail lines, only when at least one of them can be filled right now
    local details = self.Data.DetailLines and self.Data.DetailLines[kind]
    if UsablePool(details) and self:AnyLineAvailable(details) then
        layer("detail", { { "Detail_" .. kind, details, "detail line" } })
    end

    if total <= 0 then return nil end
    local roll = math.random() * total
    local chosen = layers[#layers]
    for _, entry in ipairs(layers) do
        roll = roll - entry.weight
        if roll <= 0 then chosen = entry; break end
    end
    if #chosen.subs == 1 then
        local sub = chosen.subs[1]
        return sub[1], sub[2], sub[3]
    end
    local combined, labels = {}, {}
    for _, sub in ipairs(chosen.subs) do
        for _, line in ipairs(sub[2]) do combined[#combined + 1] = line end
        labels[#labels + 1] = sub[3]
    end
    return "Layer_" .. chosen.name .. "_" .. kind, combined, table.concat(labels, " + ")
end

-- Identity-only lines for a moment (no class pool): Greet, Idle, Loot, Kill, ...
function Engine:PickIdentityPool(kind)
    local moodKey, moodPool = self:MoodPool(kind)
    if moodPool then return moodKey, moodPool, "mood" end
    if kind == "Idle" and IsResting and Clean(IsResting()) then
        -- At an inn or in a city: the inn lines take over half the time
        local inn = self.Data.WorldMoments.Inn
        if UsablePool(inn) and math.random() < 0.5 then return "World_Inn", inn, "resting at an inn" end
    end
    return self:PickLayeredPool(kind)
end

-- Layer flavor (word swaps) for the translator: about 30% of lines take
-- one from your allegiance, upbringing or traits
Tune.LAYER_FLAVOR_CHANCE = 0.3
function Engine:PickLayerFlavor()
    if math.random() >= Tune.LAYER_FLAVOR_CHANCE then return nil end
    local cv = MonologueCharDB and MonologueCharDB.CustomVoice
    if type(cv) ~= "table" then return nil end
    local options = {}
    local function add(data)
        if type(data) == "table" and type(data.Flavor) == "table" then options[#options + 1] = data.Flavor end
    end
    add(cv.allegiance and self.Data.Allegiances[cv.allegiance])
    add(cv.upbringing and self.Data.Upbringings[cv.upbringing])
    add(cv.trait and self.Data.Traits[cv.trait])
    add(cv.trait2 and self.Data.Traits[cv.trait2])
    if #options == 0 then return nil end
    return options[math.random(#options)]
end

-- Foe lines for a situation key from your allegiance and upbringing, or nil (one picked at
-- random when both have lines)
function Engine:GetAllegianceHostilePool(key)
    local options = {}
    local allegiance, allegianceKey = self:GetAllegiance()
    local hostile = allegiance and type(allegiance.Hostile) == "table" and allegiance.Hostile[key]
    if UsablePool(hostile) then options[#options + 1] = { hostile, "Allegiance_" .. allegianceKey .. "_" .. key } end
    local upbringing, upbringingKey = self:GetUpbringing()
    hostile = upbringing and type(upbringing.Hostile) == "table" and upbringing.Hostile[key]
    if UsablePool(hostile) then options[#options + 1] = { hostile, "Upbringing_" .. upbringingKey .. "_" .. key } end
    if #options == 0 then return nil end
    local pick = options[math.random(#options)]
    return pick[1], pick[2]
end

function Engine:GetUpbringing()
    local cv = self:GetCustomVoice()
    local key = cv and cv.upbringing
    local data = key and self.Data.Upbringings[key]
    if type(data) == "table" then return data, key end
    return nil
end

-- Party lines for your trait ("Rescue", "Victory", "Reply"); returns pool, deckKey
function Engine:GetTraitPool(kind)
    local cv = self:GetCustomVoice()
    local key = cv and cv.trait
    local data = key and self.Data.Traits[key]
    if type(data) == "table" and UsablePool(data[kind]) then return data[kind], "Trait_" .. key .. "_" .. kind end
    local default = self.Data.TraitDefault
    if type(default) == "table" and UsablePool(default[kind]) then return default[kind], "Trait_Default_" .. kind end
    return nil
end

-- Says a line straight from a pool (no chance roll): idle chatter on a key press
function Engine:SpeakIdentityLine(categoryKey, pool, cooldown, hardware, deckKey)
    local canSpeak, reason = self:CanSpeak(categoryKey)
    if not canSpeak then
        self:Debug("identity line skipped (" .. tostring(reason) .. ", " .. categoryKey .. ")")
        return false
    end
    local line = self:GetShuffledLine(deckKey or categoryKey, pool)
    if not line then return false end
    self.State.BareLine = true
    local ok, spoke = pcall(self.Speak, self, line, "SAY", nil, { key = categoryKey, duration = cooldown }, nil, hardware)
    self.State.BareLine = nil
    return ok and spoke
end

-- Idle chatter: an out-of-combat ability press now and then says a clan or profession line
function Engine:TryIdleLine(hardware)
    local now = GetTime()
    if now - (self.State.LastIdleAt or -math.huge) < Tune.IDLE_COOLDOWN then return false end
    local chance = Tune.IDLE_CHANCE * (MonologueDB.chattiness or 1)
    if math.random() >= chance then return false end
    local deckKey, pool, label = self:PickIdentityPool("Idle")
    if not pool then return false end
    self:Debug("idle line from " .. label)
    self.State.BanterTopic = "Idle"
    local ok = self:SpeakIdentityLine(deckKey, pool, Tune.IDLE_COOLDOWN, hardware)
    self.State.BanterTopic = nil
    if ok then self.State.LastIdleAt = now end
    return ok
end

-- A background identity moment (hometown, city, loot, repair): rolled, then queued or shown
-- locally like any background line
function Engine:SayIdentityMoment(categoryKey, pool, chance)
    if not UsablePool(pool) then return false end
    self.State.BareLine = true
    local ok, spoke = pcall(self.ProcessTrigger, self, Tune.IDENTITY_MOMENT_TIER, categoryKey, pool, chance or 1, nil)
    self.State.BareLine = nil
    return ok and spoke
end

-- A profession line for a moment ("City", "Loot", "Repair"), with its own cooldown
function Engine:TryProfessionMoment(moment, chance, cooldown)
    local state = self.State
    state.ProfessionMomentAt = state.ProfessionMomentAt or {}
    local now = GetTime()
    if now - (state.ProfessionMomentAt[moment] or -math.huge) < cooldown then return false end
    local keys = self:GetProfessionKeys()
    if #keys == 0 then return false end
    local key = keys[math.random(#keys)]
    local data = self.Data.Professions[key]
    local pool = data and data[moment]
    if not UsablePool(pool) then return false end
    local ok = self:SayIdentityMoment("Profession_" .. key .. "_" .. moment, pool, chance)
    if ok then state.ProfessionMomentAt[moment] = now end
    return ok
end

-- "EK", "Kalimdor", another continent name, or nil
function Engine:GetCurrentContinent()
    if not (C_Map and C_Map.GetBestMapForUnit and C_Map.GetMapInfo) then return nil end
    local okMap, mapID = pcall(C_Map.GetBestMapForUnit, "player")
    mapID = okMap and Clean(mapID) or nil
    local continentType = Enum and Enum.UIMapType and Enum.UIMapType.Continent or 2
    for _ = 1, 10 do
        if not mapID then return nil end
        local okInfo, info = pcall(C_Map.GetMapInfo, mapID)
        if not okInfo or type(info) ~= "table" then return nil end
        if info.mapType == continentType then
            local name = Clean(info.name)
            if name == "Eastern Kingdoms" then return "EK" end
            return name
        end
        mapID = info.parentMapID
        if mapID == 0 then return nil end
    end
    return nil
end

-- ZONE_CHANGED_NEW_AREA (newArea = true) and ZONE_CHANGED (a new subzone). silent = true at
-- login: only notes whether you're home, so logging in at home doesn't say a homecoming line.
function Engine:HandleZoneChange(newArea, silent)
    if not MonologueDB or not MonologueCharDB then return end
    local state, now = self.State, GetTime()
    local zone, sub = Clean(GetRealZoneText()), Clean(GetSubZoneText())
    zone = type(zone) == "string" and zone or ""
    sub = type(sub) == "string" and sub or ""

    -- Instance atmosphere: a line on entering a dungeon or a battleground
    local _, instanceType = IsInInstance()
    instanceType = Clean(instanceType) or "none"
    -- (the login pass only records where you are, so logging in inside a dungeon says nothing)
    if (newArea or silent) and instanceType ~= state.LastInstanceType then
        state.LastInstanceType = instanceType
        if not silent then
            local moment = (instanceType == "party" and "DungeonEnter") or (instanceType == "pvp" and "BattlegroundEnter")
            if moment then
                self:SayIdentityMoment("World_" .. moment, self.Data.WorldMoments[moment], 0.6)
                return
            end
        end
    end

    -- Hometown: homecoming, or reclamation for a fallen home
    local homeName, option = self:GetHometown()
    if homeName then
        local atHome
        if option then
            if option.sub then
                atHome = sub == option.sub or zone == option.sub
            else
                atHome = zone == option.zone
            end
        else
            local lowered = homeName:lower()
            atHome = zone:lower() == lowered or sub:lower() == lowered
            if atHome then
                -- Learn where a custom hometown lies, for homesick lines later
                MonologueCharDB.HometownContinent = { name = homeName, continent = self:GetCurrentContinent() }
            end
        end
        if atHome then
            if silent then state.AtHome = true; return end
            if not state.AtHome then
                state.AtHome = true
                if now - (state.HomeSaidAt or -math.huge) >= Tune.HOMETOWN_COOLDOWN then
                    local kind = option and option.fallen and "Reclaim" or "Homecoming"
                    self:Debug("hometown: " .. kind .. " (" .. homeName .. ")")
                    if self:SayIdentityMoment("Hometown_" .. kind, self.Data.HometownLines[kind], 1) then
                        state.HomeSaidAt = now
                    end
                end
            end
            return
        end
        state.AtHome = false
    end
    if silent then return end

    -- A city visit: a profession line now and then
    local cities = self.Data.CityZones or {}
    if cities[zone] or cities[sub] then
        if self:TryProfessionMoment("City", Tune.CITY_CHANCE, Tune.CITY_COOLDOWN) then return end
    end

    -- Far from home: another continent than the hometown's
    if newArea and homeName and now - (state.HomesickAt or -math.huge) >= Tune.HOMESICK_COOLDOWN then
        local homeContinent = option and option.continent
        local learned = MonologueCharDB.HometownContinent
        if not homeContinent and type(learned) == "table" and learned.name == homeName then
            homeContinent = learned.continent
        end
        local here = self:GetCurrentContinent()
        if homeContinent and here and here ~= homeContinent then
            if self:SayIdentityMoment("Hometown_Homesick", self.Data.HometownLines.Homesick, Tune.HOMESICK_CHANCE) then
                state.HomesickAt = now
            end
        end
    end
end

function Engine:HandleLootOpened()
    if UnitAffectingCombat("player") then return end
    local now = GetTime()
    if now - (self.State.LootLineAt or -math.huge) < Tune.LOOT_COOLDOWN then return end
    local deckKey, pool = self:PickIdentityPool("Loot")
    self.State.BanterTopic = "Loot"
    local ok, said = pcall(self.SayIdentityMoment, self, deckKey, pool, Tune.LOOT_CHANCE)
    self.State.BanterTopic = nil
    if pool and ok and said then self.State.LootLineAt = now end
end

-- A kill (combat ends with your enemy target dead): now and then a line from any layer.
-- Background speech with a short shelf life, so it never lands on the next pull.
Tune.KILL_CHANCE = 0.15
Tune.KILL_COOLDOWN = 180
function Engine:TryKillLine()
    if not (UnitExists("target") and UnitIsDead("target") and UnitCanAttack("player", "target")) then return end
    if UnitIsDeadOrGhost("player") then return end
    local now = GetTime()
    if now - (self.State.KillLineAt or -math.huge) < Tune.KILL_COOLDOWN then return end
    local deckKey, pool = self:PickIdentityPool("Kill")
    if not pool then return end
    self.State.SpeakKind = "party"
    self.State.BareLine = true
    self.State.OathMoment = "Kill"
    self.State.BanterTopic = "Kill"
    local ok, spoke = pcall(self.ProcessTrigger, self, Tune.IDENTITY_MOMENT_TIER, deckKey, pool, Tune.KILL_CHANCE, nil)
    self.State.SpeakKind = nil
    self.State.BareLine = nil
    self.State.OathMoment = nil
    self.State.BanterTopic = nil
    if ok and spoke then self.State.KillLineAt = now end
end

function Engine:HandleRepair()
    self:TryProfessionMoment("Repair", Tune.REPAIR_CHANCE, Tune.REPAIR_COOLDOWN)
end

-- RepairAllItems is only observed through a post-hook (addon-owned state only, pcall-guarded)
if type(RepairAllItems) == "function" then
    pcall(hooksecurefunc, "RepairAllItems", function()
        pcall(Engine.HandleRepair, Engine)
    end)
end

-- Gear turning yellow or red (UPDATE_INVENTORY_DURABILITY): one grumble per step down
Tune.DURABILITY_COOLDOWN = 600
function Engine:HandleDurability()
    if type(GetInventoryAlertStatus) ~= "function" then return end
    local worst = 0
    for slot = 1, 19 do
        local ok, status = pcall(GetInventoryAlertStatus, slot)
        status = ok and tonumber(Clean(status)) or 0
        if status > worst then worst = status end
    end
    local state = self.State
    local previous = state.DurabilityLevel or 0
    state.DurabilityLevel = worst
    if worst <= previous then return end
    local now = GetTime()
    if now - (state.DurabilityAt or -math.huge) < Tune.DURABILITY_COOLDOWN and worst < 2 then return end
    local moment = worst >= 2 and "DurabilityBroken" or "DurabilityLow"
    if self:SayIdentityMoment("World_" .. moment, self.Data.WorldMoments[moment], 0.7) then
        state.DurabilityAt = now
    end
end

---------------------------------------------------------------------------
-- Party call-and-response (addon channel "MONO_RP", PARTY / RAID / INSTANCE_CHAT)
-- Monologue users in a group share compact identity tags and two combat callouts:
--   I^1^allegiance^clan^trait^upbringing   who you are (sent on joining, on change, on request)
--   Q                                      "who's here?" (others answer with I)
--   L                                      "I'm below 25% health" (throttled)
--   W                                      "I just said a victory line" (elite or boss kill)
-- Reactions use the normal background routing (queued for your next key press, or local),
-- with a short shelf life, so nothing is ever sent from the addon message event itself.
---------------------------------------------------------------------------

local COMM_PREFIX = "MONO_RP"
local COMM_VERSION = "1"
Tune.COMM_ID_THROTTLE = 15
Tune.PARTY_LOW_HP = 0.25
Tune.PARTY_LOW_THROTTLE = 45
Tune.RESCUE_CHANCE = 0.5
Tune.RESCUE_COOLDOWN = 60
Tune.VICTORY_CHANCE = 0.5
Tune.VICTORY_REPLY_CHANCE = 0.3
Tune.FRICTION_CHANCE = 0.08
Tune.FRICTION_COOLDOWN = 1200
Tune.PARTY_MOMENT_TIER = 9

if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    pcall(C_ChatInfo.RegisterAddonMessagePrefix, COMM_PREFIX)
end

local function ShortName(name)
    name = Clean(name)
    if type(name) ~= "string" or name == "" then return nil end
    if Ambiguate then
        local ok, short = pcall(Ambiguate, name, "none")
        if ok and type(short) == "string" then name = short end
    end
    return (name:gsub("%-.*$", ""))
end

-- Addon messages go only to PARTY, RAID or GUILD (never instance, whisper or numbered
-- channels), at most one every Tune.ADDON_MIN_GAP seconds across both prefixes, payload under
-- Tune.ADDON_MAX_PAYLOAD characters. Faster messages wait in a short queue (newest of each kind
-- wins; anything older than Tune.ADDON_MAX_WAIT is dropped).
Tune.ADDON_MIN_GAP = 10
Tune.ADDON_MAX_PAYLOAD = 200
Tune.ADDON_MAX_QUEUE = 6
Tune.ADDON_MAX_WAIT = 60
local ADDON_CHANNELS = { PARTY = true, RAID = true, GUILD = true }

local function CommChannel()
    if IsInRaid and IsInRaid() then return "RAID" end
    if IsInGroup and IsInGroup() then return "PARTY" end
    return nil
end

function Engine:PumpAddonQueue()
    local queue = self.State.AddonQueue
    if type(queue) ~= "table" or #queue == 0 then return end
    local now = GetTime()
    while queue[1] and now - queue[1].at > Tune.ADDON_MAX_WAIT do table.remove(queue, 1) end
    if #queue == 0 then return end
    local wait = Tune.ADDON_MIN_GAP - (now - (self.State.LastAddonSendAt or -math.huge))
    if wait > 0 then
        if not self.State.AddonPumpScheduled then
            self.State.AddonPumpScheduled = true
            C_Timer.After(wait + 0.05, function()
                Engine.State.AddonPumpScheduled = false
                Engine:PumpAddonQueue()
            end)
        end
        return
    end
    local item = table.remove(queue, 1)
    self.State.LastAddonSendAt = now
    pcall(C_ChatInfo.SendAddonMessage, item.prefix, item.message, item.channel)
    if #queue > 0 then self:PumpAddonQueue() end
end

-- Returns true when the message was accepted (sent now or queued)
function Engine:QueueAddonMessage(prefix, message, channel)
    if not (C_ChatInfo and C_ChatInfo.SendAddonMessage) then return false end
    if not ADDON_CHANNELS[channel] or type(message) ~= "string" or #message >= Tune.ADDON_MAX_PAYLOAD then
        return false
    end
    local queue = self.State.AddonQueue or {}
    self.State.AddonQueue = queue
    local kind = prefix .. channel .. message:sub(1, 1)
    for i, item in ipairs(queue) do
        if item.kind == kind then table.remove(queue, i); break end
    end
    queue[#queue + 1] = { prefix = prefix, message = message, channel = channel, kind = kind, at = GetTime() }
    while #queue > Tune.ADDON_MAX_QUEUE do table.remove(queue, 1) end
    self:PumpAddonQueue()
    return true
end

local function CommField(value)
    if type(value) ~= "string" or value == "" then return "-" end
    return (value:gsub("[^%w]", ""))
end

function Engine:SendComm(message)
    local channel = CommChannel()
    if not channel then return false end
    return self:QueueAddonMessage(COMM_PREFIX, message, channel)
end

function Engine:BroadcastIdentity(force)
    local now = GetTime()
    if not force and now - (self.State.CommIdAt or -math.huge) < Tune.COMM_ID_THROTTLE then return end
    self.State.CommIdAt = now
    local cv = self:GetCustomVoice() or {}
    -- Last field: "b" = answers party banter, "q" = banter switched off
    self:SendComm(table.concat({ "I", COMM_VERSION, CommField(cv.allegiance), CommField(cv.clan),
        CommField(cv.trait), CommField(cv.upbringing), (MonologueDB and MonologueDB.partyBanter == false) and "q" or "b" }, "^"))
end

-- GROUP_ROSTER_UPDATE: announce yourself (debounced), ask who's here when you join a group,
-- forget players who left
function Engine:HandleRosterUpdate()
    local inGroup = IsInGroup and IsInGroup()
    local party = self.State.PartyIdentities or {}
    self.State.PartyIdentities = party
    if not inGroup then
        wipe(party)
        self.State.WasInGroup = false
        return
    end
    for name in pairs(party) do
        if not (UnitInParty(name) or UnitInRaid(name)) then party[name] = nil end
    end
    local joined = not self.State.WasInGroup
    self.State.WasInGroup = true
    if self.State.CommPending then return end
    self.State.CommPending = true
    C_Timer.After(3, function()
        Engine.State.CommPending = false
        pcall(Engine.AnnounceVersion, Engine)
        Engine:BroadcastIdentity()
        if joined then Engine:SendComm("Q") end
    end)
end

function Engine:HandleAddonMessage(prefix, text, channel, sender)
    if prefix ~= COMM_PREFIX or type(text) ~= "string" then return end
    local name = ShortName(sender)
    if not name or name == ShortName(UnitName("player")) then return end
    local kind = text:sub(1, 1)
    -- Greetings, thanks and duels may come over the guild channel; everything else is group-only
    if channel == "GUILD" then
        if kind ~= "G" and kind ~= "T" and kind ~= "D" then return end
    elseif not (UnitInParty(name) or UnitInRaid(name)) then
        return
    end
    if kind == "G" or kind == "T" then
        local target = text:match("^%a%^([^%^]+)$")
        if target and self:IsMyName(target) then
            if kind == "G" then pcall(self.HandleGreetedBy, self, name) else pcall(self.HandleThanked, self, name) end
        end
    elseif kind == "R" then
        local target, topic = text:match("^R%^([^%^]+)%^(%a+)$")
        if target and self:IsMyName(target) then pcall(self.HandleBanterReply, self, name, topic) end
    elseif kind == "D" then
        local target, phase = text:match("^D%^([^%^]+)%^(%a)$")
        if target and self:IsMyName(target) then pcall(self.HandleDuelComm, self, name, phase) end
    elseif kind == "I" then
        local _, version, allegiance, clan, trait, upbringing, flags = strsplit("^", text)
        local function field(v) return (v and v ~= "-" and v ~= "") and v or nil end
        self.State.PartyIdentities = self.State.PartyIdentities or {}
        self.State.PartyIdentities[name] = {
            version = version, allegiance = field(allegiance), clan = field(clan),
            trait = field(trait), upbringing = field(upbringing), at = GetTime(),
            banter = flags ~= "q",   -- older versions send no flag: assume banter is on
        }
        self:Debug("party: " .. name .. " runs Monologue (" .. text .. ")")
    elseif kind == "Q" then
        self:BroadcastIdentity()
    elseif kind == "L" then
        self:HandleAllyLowHealth(name)
    elseif kind == "W" then
        self:HandleAllyVictory(name)
    elseif kind == "S" then
        local hash = text:match("^S%^(%x+)$")
        if hash then self:AddPartyLine(hash, nil) end
    elseif kind == "N" then
        self:HandleNemesisSpotted(name, text:match("^N%^(.+)$"))
    elseif kind == "B" then
        local topic = text:match("^B%^(%a+)$")
        if topic then pcall(self.HandleBanter, self, topic, name) end
    end
end

-- Says a background party line about `name` ({target} = them), short shelf life
function Engine:SayPartyLine(categoryKey, pool, chance, name, kind)
    if not UsablePool(pool) then return false end
    self.State.SpeakKind = kind or "party"
    self.State.TokenTargetName = name and self:PartyDisplayName(name) or nil
    self.State.BareLine = true
    local ok, spoke = pcall(self.ProcessTrigger, self, Tune.PARTY_MOMENT_TIER, categoryKey, pool, chance, nil)
    self.State.SpeakKind = nil
    self.State.TokenTargetName = nil
    self.State.BareLine = nil
    return ok and spoke
end

-- Your own health: tell the party when you drop below 25% in a fight
function Engine:CheckPartyLowHealth(ratio)
    if not (IsInGroup and IsInGroup()) or not UnitAffectingCombat("player") then return end
    if ratio > Tune.PARTY_LOW_HP or ratio <= 0 then return end
    local now = GetTime()
    if now - (self.State.CommLowAt or -math.huge) < Tune.PARTY_LOW_THROTTLE then return end
    self.State.CommLowAt = now
    self:SendComm("L")
end

function Engine:HandleAllyLowHealth(name)
    local now = GetTime()
    if now - (self.State.RescueAt or -math.huge) < Tune.RESCUE_COOLDOWN then return end
    local pool, deckKey = self:GetTraitPool("Rescue")
    self:Debug("party: " .. name .. " is below 25% health")
    if self:SayPartyLine(deckKey, pool, Tune.RESCUE_CHANCE, name) then self.State.RescueAt = now end
end

-- After an elite or boss kill in a group: the first Monologue user by name speaks and tells
-- the others, who may answer 2-3 seconds later
function Engine:HandleGroupVictory(kind)
    if not (IsInGroup and IsInGroup()) or UnitIsDeadOrGhost("player") then return end
    local me = ShortName(UnitName("player"))
    local first = me
    -- Every client must pick the same speaker: everyone in the group known to run Monologue
    -- (players who leave are dropped on the roster update), however long ago they said so
    for name in pairs(self.State.PartyIdentities or {}) do
        if name < first and (UnitInParty(name) or UnitInRaid(name)) then first = name end
    end
    if first ~= me then return end
    local pool, deckKey = self:GetTraitPool("Victory")
    self:Debug("party: " .. kind .. " down, victory line")
    if self:SayPartyLine(deckKey, pool, Tune.VICTORY_CHANCE, nil) then self:SendComm("W") end
end

function Engine:HandleAllyVictory(name)
    if math.random() >= Tune.VICTORY_REPLY_CHANCE then return end
    local delay = 2 + math.random()
    C_Timer.After(delay, function()
        local pool, deckKey = Engine:GetTraitPool("Reply")
        Engine:SayPartyLine(deckKey, pool, 1, name)
    end)
end

local function MatchesFriction(rule, values)
    for field, wanted in pairs(rule) do
        if values[field] ~= wanted then return false end
    end
    return true
end

-- After a fight in a group: now and then a side-eye at a party member whose identity clashes
-- with yours (Scarlet Crusade beside a warlock, Bronzebeard beside a Dark Iron, ...)
function Engine:TryPartyFriction()
    if not (IsInGroup and IsInGroup()) then return end
    local now = GetTime()
    if now - (self.State.FrictionAt or -math.huge) < Tune.FRICTION_COOLDOWN then return end
    if math.random() >= Tune.FRICTION_CHANCE then return end
    local cv = self:GetCustomVoice() or {}
    local mine = { allegiance = cv.allegiance, clan = cv.clan, upbringing = cv.upbringing, trait = cv.trait }
    local prefix, count = "party", 4
    if IsInRaid and IsInRaid() then prefix, count = "raid", 40 end
    local matches = {}
    for i = 1, count do
        local unit = prefix .. i
        if UnitExists(unit) and not UnitIsUnit(unit, "player") then
            local name = ShortName(UnitName(unit))
            local info = name and (self.State.PartyIdentities or {})[name] or {}
            local _, classFile = UnitClass(unit)
            local _, raceFile = UnitRace(unit)
            local theirs = {
                allegiance = info.allegiance, clan = info.clan, upbringing = info.upbringing, trait = info.trait,
                class = Clean(classFile), race = Clean(raceFile),
            }
            for ruleIndex, rule in ipairs(self.Data.Friction or {}) do
                if MatchesFriction(rule.mine, mine) and MatchesFriction(rule.theirs, theirs) then
                    matches[#matches + 1] = { name = name, lines = rule.lines, rule = ruleIndex }
                end
            end
        end
    end
    if #matches == 0 then return end
    local pick = matches[math.random(#matches)]
    if self:SayPartyLine("Friction_" .. pick.rule, pick.lines, 1, pick.name) then
        self.State.FrictionAt = now
    end
end

-- PLAYER_REGEN_ENABLED: elite fights end in a victory line; any fight may end in a side-eye
function Engine:OnCombatEndParty()
    local rank = self.State.PullRank
    self.State.PullRank = nil
    local grouped = IsInGroup and IsInGroup()
    local bigFight = rank == "elite" or rank == "rareelite" or rank == "worldboss"
    if not grouped or not bigFight then self:TryKillLine() end
    if not grouped then return end
    if self.State.BossVictorySaid then
        self.State.BossVictorySaid = nil
    elseif bigFight then
        self:HandleGroupVictory("elite")
    end
    self:TryPartyFriction()
end

function Engine:DescribeParty()
    local list = {}
    for name, info in pairs(self.State.PartyIdentities or {}) do
        local trait = info.trait and self.Data.Traits[info.trait]
        list[#list + 1] = name .. (trait and (" (" .. trait.name .. ")") or "")
    end
    table.sort(list)
    if #list == 0 then return "No party members with Monologue seen yet." end
    return "Party members with Monologue: " .. table.concat(list, ", ")
end

---------------------------------------------------------------------------
-- Cross-party echo suppression
-- RecentPartyLines remembers (max 12, 90 s) what party members with Monologue just said:
-- the template hash they broadcast (S^hash on MONO_RP) and the plain text of their /s, /y
-- and emotes. GetShuffledLine skips a candidate that matches either.
---------------------------------------------------------------------------

Tune.ECHO_MAX = 12
Tune.ECHO_TTL = 90

local function NormalizeLine(text)
    if type(text) ~= "string" then return nil end
    text = text:lower():gsub("{[^}]*}", ""):gsub("[^%a ]", ""):gsub("%s+", " ")
    text = strtrim(text)
    return text ~= "" and text or nil
end

-- 32-bit string hash (djb2), as 8 hex digits
local function LineHash(text)
    local normalized = NormalizeLine(text)
    if not normalized then return nil end
    local h = 5381
    for i = 1, #normalized do
        h = (h * 33 + normalized:byte(i)) % 4294967296
    end
    return string.format("%08x", h)
end

function Engine:AddPartyLine(hash, text)
    local cache = self.State.RecentPartyLines or {}
    self.State.RecentPartyLines = cache
    cache[#cache + 1] = { hash = hash, text = text, at = GetTime() }
    while #cache > Tune.ECHO_MAX do table.remove(cache, 1) end
end

-- Recent-lines memory (MonologueCharDB.RecentLines): the last Tune.RECENT_MAX lines drawn,
-- by wall-clock time so it survives a relog. GetShuffledLine skips them when it can.
Tune.RECENT_MAX = 40
Tune.RECENT_TTL = 6 * 3600
function Engine:RecentLineList()
    local char = MonologueCharDB
    if type(char) ~= "table" then return nil end
    if type(char.RecentLines) ~= "table" then char.RecentLines = {} end
    return char.RecentLines
end

local function WallClock()
    return (GetServerTime and GetServerTime()) or time()
end

function Engine:IsRecentlySaid(line)
    local list, key = self:RecentLineList(), NormalizeLine(line)
    if not list or not key then return false end
    local now = WallClock()
    for _, entry in ipairs(list) do
        if type(entry) == "table" and entry.k == key and now - (tonumber(entry.t) or 0) < Tune.RECENT_TTL then return true end
    end
    return false
end

function Engine:NoteRecentLine(line)
    local list, key = self:RecentLineList(), NormalizeLine(line)
    if not list or not key then return end
    list[#list + 1] = { k = key, t = WallClock() }
    while #list > Tune.RECENT_MAX do table.remove(list, 1) end
end

function Engine:IsPartyEcho(line)
    local cache = self.State.RecentPartyLines
    if type(cache) ~= "table" or #cache == 0 then return false end
    local now = GetTime()
    while cache[1] and now - cache[1].at > Tune.ECHO_TTL do table.remove(cache, 1) end
    if #cache == 0 then return false end
    local hash, normalized = LineHash(line), NormalizeLine(line)
    for _, entry in ipairs(cache) do
        if (hash and entry.hash == hash) or (normalized and entry.text == normalized) then return true end
    end
    return false
end

-- Speak: tell party members with Monologue which template was just used
function Engine:NoteSpokenLine(template)
    if not (IsInGroup and IsInGroup()) then return end
    local hash = LineHash(template)
    if hash then self:SendComm("S^" .. hash) end
end

-- CHAT_MSG_SAY / _YELL / _EMOTE from a group member
function Engine:HandleGroupChat(text, sender)
    if not (IsInGroup and IsInGroup()) then return end
    local name = ShortName(sender)
    if not name or name == ShortName(UnitName("player")) then return end
    if not (UnitInParty(name) or UnitInRaid(name)) then return end
    local normalized = NormalizeLine(Clean(text))
    if normalized then self:AddPartyLine(nil, normalized) end
end

---------------------------------------------------------------------------
-- Alpha testing: /mono bug report text, and the MONO_VER version check
---------------------------------------------------------------------------

function Engine:BuildBugReport(note)
    local lines = {}
    local function add(text) lines[#lines + 1] = text end
    local function str(value) return value == nil and "nil" or tostring(value) end
    note = type(note) == "string" and strtrim(note) or ""
    if note ~= "" then
        add("What happened: " .. note)
        add("")
    end
    local clientVersion, build, _, toc = GetBuildInfo()
    add(string.format("Monologue %s (folder %s) | client %s build %s (toc %s)",
        self.VERSION, ADDON_NAME, str(clientVersion), str(build), str(toc)))
    add("Zone: " .. str(Clean(GetRealZoneText())) .. " / " .. str(Clean(GetSubZoneText())))

    local _, raceFile = UnitRace("player")
    local _, classFile = UnitClass("player")
    local ctx = self.ActiveContext or {}
    local cv = (MonologueCharDB and MonologueCharDB.CustomVoice) or {}
    add(string.format("Character: %s %s level %s | profile %s | temperament %s | persona %s",
        str(Clean(raceFile)), str(Clean(classFile)), str(Clean(UnitLevel("player"))),
        str(ctx.profile), str(cv.racePreset or "Default"), str(ctx.persona)))
    add(string.format("Identity: clan %s | hometown %s | allegiance %s | upbringing %s | traits %s/%s | dialect %s",
        str(cv.clan), str(cv.hometown), str(cv.allegiance), str(cv.upbringing), str(cv.trait), str(cv.trait2),
        str(cv.dialectStrength or "FULL")))

    local db = MonologueDB or {}
    add(string.format("Settings: enabled=%s chattiness=%s background=%s accent=%s pullEvery=%s situations=%s%% breath=%ss debug=%s strictSafeMode=%s",
        str(db.enabled), str(db.chattiness), str(db.backgroundSpeech), str(db.translationIntensity),
        str(db.pullEvery), str(db.situationChance), str(db.globalBreath), str(db.debugMode), str(db.strictSafeMode)))
    -- Switches and choices added in 0.1.4 (Voice Lines, General, My Voice and Abilities tabs)
    local function Count(t)
        local n = 0
        for _ in pairs(type(t) == "table" and t or {}) do n = n + 1 end
        return n
    end
    local char = MonologueCharDB or {}
    add(string.format("More: moments=%s bubble=%s npcYells=%s banter=%s typos=%s abilityAuto=%s dungeonQuiet=%s ooc=%s mood=%s | spells seen %d, kinds chosen %d, every-Nth %d, own-line pools %d",
        str(db.momentLines ~= false), str(db.queueBubble ~= false), str(db.npcYells ~= false), str(db.partyBanter ~= false),
        str(db.fixTypos == true), str(db.abilityAuto ~= false), str(db.dungeonQuiet == true), str(db.outOfCharacter == true),
        str(self:GetMood() or "normal"), Count(char.SeenSpells), Count(char.AbilityMap), Count(char.AbilityEvery),
        Count(cv.extraLines)))
    add(string.format("Chat: taunts=%s nicknames=%s translateKey=%s preview=%s tauntButton=%s quirks=%d companion=%s",
        str(cv.taunts or "off"), str(cv.nicknames or "off"), str(db.translateKey or "ENTER"), str(db.chatPreview ~= false),
        str(db.tauntButtonShown == true), #(cv.quirks or {}), str(cv.companion ~= nil)))
    local press = db.pressVoice or {}
    local places, blocked = {}, {}
    for _, place in ipairs({ "world", "worldpvp", "dungeon", "raid", "battleground", "boss" }) do
        places[#places + 1] = place .. "=" .. (press[place] and "on" or "off")
    end
    for place, isBlocked in pairs(db.pressVoiceBlocked or {}) do
        if isBlocked then blocked[#blocked + 1] = place end
    end
    table.sort(blocked)
    add(string.format("Ability-press voice: %s gap=%ss | %s | client blocked in: %s | castSendBlocked=%s",
        press.enabled and "on" or "off", str(press.gap), table.concat(places, " "),
        #blocked > 0 and table.concat(blocked, ", ") or "none", str(db.castSendBlocked)))
    local state = self.State
    add(string.format("Pulls: pullCount=%s nextSpeechPull=%s armed=%s | safe mode: %s | last block: %s",
        str(state.PullCount), str(state.NextSpeechPull), str(state.PullSpeechArmed),
        str(state.SafeModeReason), str(state.SendBlockedBy)))

    add("")
    add("Recent log:")
    local log = self.DiagnosticLog
    local first = math.max(1, #log - 14)
    if #log == 0 then add("  (empty)") end
    for i = first, #log do add("  " .. log[i]) end
    add("")
    add("Recent errors:")
    if #self.RecentErrors == 0 then add("  none") end
    for _, err in ipairs(self.RecentErrors) do add("  " .. err) end
    return table.concat(lines, "\n")
end

local VERSION_PREFIX = "MONO_VER"
Tune.VERSION_THROTTLE = 60
if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    pcall(C_ChatInfo.RegisterAddonMessagePrefix, VERSION_PREFIX)
end

-- "0.1.0-alpha" -> { 0, 1, 0, 0, 1 }, "0.1.4.1" -> { 0, 1, 4, 1, 4 }: an optional fourth
-- number for small follow-up releases; release rank: alpha 1, beta 2, rc 3, none 4
local PRERELEASE_RANK = { alpha = 1, beta = 2, rc = 3 }
local function VersionKey(version)
    if type(version) ~= "string" then return nil end
    local major, minor, patch, rest = version:match("^(%d+)%.(%d+)%.(%d+)(.*)$")
    if not major then return nil end
    local hotfix = rest:match("^%.(%d+)") or "0"
    local pre = rest:match("^[%.%d]*%-?(%a*)") or ""
    return { tonumber(major), tonumber(minor), tonumber(patch), tonumber(hotfix), PRERELEASE_RANK[pre:lower()] or 4 }
end

local function IsNewerVersion(theirs, mine)
    local a, b = VersionKey(theirs), VersionKey(mine)
    if not a or not b then return false end
    for i = 1, 5 do
        if a[i] ~= b[i] then return a[i] > b[i] end
    end
    return false
end

function Engine:BroadcastVersion(channel)
    if not channel or not (C_ChatInfo and C_ChatInfo.SendAddonMessage) then return end
    self.State.VersionSentAt = self.State.VersionSentAt or {}
    local now = GetTime()
    if now - (self.State.VersionSentAt[channel] or -math.huge) < Tune.VERSION_THROTTLE then return end
    self.State.VersionSentAt[channel] = now
    self:QueueAddonMessage(VERSION_PREFIX, "V^" .. self.VERSION, channel)
end

-- Login and roster changes: tell the guild and the group which version you run
function Engine:AnnounceVersion()
    if IsInGuild and IsInGuild() then self:BroadcastVersion("GUILD") end
    self:BroadcastVersion(CommChannel())
end

function Engine:HandleVersionMessage(text, channel, sender)
    local version = type(text) == "string" and text:match("^V%^(.+)$")
    if not version then return end
    local name = ShortName(sender)
    if not name or name == ShortName(UnitName("player")) then return end
    if IsNewerVersion(version, self.VERSION) then
        self:Diag("version: " .. name .. " runs newer " .. version)
        if not self.State.NewerVersionAlerted then
            self.State.NewerVersionAlerted = true
            Print("A newer Monologue is out: " .. version .. " (you have " .. self.VERSION .. "). "
                .. name .. " is running it.")
        end
    elseif IsNewerVersion(self.VERSION, version) then
        -- They're behind: answer (throttled) so their client can tell them
        self:BroadcastVersion(channel)
    end
end

-- One-line summary for /mono identity
function Engine:DescribeIdentity()
    local cv = self:GetCustomVoice() or {}
    local allegiance = self:GetAllegiance()
    local detected = {}
    for _, key in ipairs(self:DetectProfessions()) do
        detected[#detected + 1] = self.Data.Professions[key].name
    end
    local profession = cv.profession and self.Data.Professions[cv.profession].name
        or ("Auto-Detect (" .. (#detected > 0 and table.concat(detected, ", ") or "none found") .. ")")
    local upbringing = self:GetUpbringing()
    local trait = cv.trait and self.Data.Traits[cv.trait]
    local strength = (cv.dialectStrength == "LIGHT" and "Light Flavor") or (cv.dialectStrength == "CLEAN" and "Clean") or "Full Dialect"
    return string.format("Clan: %s   Hometown: %s   Allegiance: %s   Profession: %s\nUpbringing: %s   Trait: %s   Dialect: %s",
        self:GetClanDisplayName() or "none", cv.hometown or "none",
        allegiance and allegiance.name or "none", profession,
        upbringing and upbringing.name or "none", trait and trait.name or "none", strength)
end

-- Applies one race Presets entry onto the merged profile (a private copy). A preset may
-- define: name, dialectIntensity (-1..+1 shift of the intensity tier), oaths (replace the
-- race's), FriendGreetings and BattleCry (added in front of the race's own, per pool, so the
-- temperament colours the lines without shrinking them).
local function ApplyRacePreset(merged, raceData, presetKey)
    local presets = type(raceData.Presets) == "table" and raceData.Presets or nil
    local preset = presets and presetKey and presets[presetKey]
    if type(preset) ~= "table" or presetKey == "Default" then return nil end

    if type(merged.Dialect) ~= "table" then merged.Dialect = {} end
    if type(preset.oaths) == "table" and next(preset.oaths) ~= nil then merged.Dialect.oaths = DeepCopy(preset.oaths) end
    local function Combined(lines, base)
        local out = DeepCopy(lines)
        if type(base) == "table" then
            for _, line in ipairs(base) do out[#out + 1] = line end
        end
        return out
    end
    if type(preset.FriendGreetings) == "table" then
        local greetings = type(merged.FriendGreetings) == "table" and merged.FriendGreetings or {}
        for poolKey, lines in pairs(preset.FriendGreetings) do
            if type(lines) == "table" and #lines > 0 then greetings[poolKey] = Combined(lines, greetings[poolKey]) end
        end
        merged.FriendGreetings = greetings
    end
    if type(preset.BattleCry) == "table" and #preset.BattleCry > 0 then
        merged.BattleCry = Combined(preset.BattleCry, merged.BattleCry)
    end
    if type(preset.dialectIntensity) == "number" then merged.DialectIntensity = Clamp(preset.dialectIntensity, -1, 1) end
    return presetKey
end

-- { { key, name }, ... } for the player's race: Default first, then each preset by key
function Engine:GetRacePresetOptions()
    local options = { { key = "Default", name = "Default" } }
    local _, raceFile = UnitRace("player")
    local raceData = raceFile and self.Data.Races[raceFile]
    local presets = raceData and type(raceData.Presets) == "table" and raceData.Presets
    if presets then
        local keys = {}
        for key, preset in pairs(presets) do
            if key ~= "Default" and type(preset) == "table" then keys[#keys + 1] = key end
        end
        table.sort(keys)
        for _, key in ipairs(keys) do
            options[#options + 1] = { key = key, name = presets[key].name or key, blurb = presets[key].blurb }
        end
    end
    return options
end

function Engine:CustomVoiceSetRacePreset(key)
    local cv = self:GetCustomVoice()
    if not cv then return false end
    cv.racePreset = (key and key ~= "" and key ~= "Default") and key or nil
    self:BuildActiveProfile()
    return true
end

-- Race keys (raceFile) that can be a stance target: every installed race pack
function Engine:GetStanceRaceKeys()
    local keys = {}
    for key in pairs(self.Data.Races) do
        if type(key) == "string" and key:sub(1, 1) ~= "_" then keys[#keys + 1] = key end
    end
    table.sort(keys)
    return keys
end

-- stance: a CV_STANCES key (WARM, ADMIRING, PLAYFUL, WARY, GRUFF, DISDAINFUL), or
-- nil/"NEUTRAL"/"DEFAULT" to clear
function Engine:CustomVoiceSetStance(race, stance)
    local cv = self:GetCustomVoice()
    if not cv or type(race) ~= "string" or race == "" then return false end
    stance = type(stance) == "string" and stance:upper() or nil
    cv.raceStances[race] = CV_STANCES[stance] and stance or nil
    self:BuildActiveProfile()
    return true
end

-- Starter examples so new players aren't facing empty boxes (adds only what is missing)
function Engine:FillStarterExamples()
    local cv = self:GetCustomVoice()
    if not cv then return 0 end
    local starters = {
        oaths = { "Mark my words!", "By my honor!" },
        battleCries = { "For my friends, and for my honor!" },
    }
    local added = 0
    for listKey, lines in pairs(starters) do
        local list = cv[listKey]
        for _, line in ipairs(lines) do
            local exists = false
            for _, existing in ipairs(list) do
                if existing:lower() == line:lower() then exists = true end
            end
            if not exists and #list < CV_MAX_ITEMS then
                list[#list + 1] = line
                added = added + 1
            end
        end
    end
    if added > 0 then self:BuildActiveProfile() end
    return added
end

---------------------------------------------------------------------------
-- Cross-race stances: greeting pools chosen by the target's race
---------------------------------------------------------------------------

-- Global fallbacks, used when no race pack defines StanceGreetings for the pair.
-- Tokens: {target} (name) and {targetrace} (their race).
local STANCE_FALLBACK = {
    WARM = {
        "Well met, {target}! Always glad to see one of the {targetrace} folk.",
        "{target}! Your people have always had my respect. Be welcome.",
        "Good to see you, {target}. I think highly of your kind.",
        "Hail, {target}! An honor to cross paths with you.",
        "{target}, friend of the road! May your way be easy.",
    },
    ADMIRING = {
        "{target}! I've long admired the {targetrace}. It's an honor.",
        "Well met, {target}. Your people have much to teach mine.",
        "{target}. I'd count myself lucky to fight beside one of your kind.",
        "Hail, {target}! The stories about your people don't do them justice.",
        "{target}, it's a privilege. Truly.",
    },
    PLAYFUL = {
        "Oh look, it's {target}! Try not to trip over anything this time.",
        "{target}! Still letting your people talk you into things, I see.",
        "Well, if it isn't {target}. Wondered when you'd turn up.",
        "{target}! I'd say you look well, but I'd be lying. Ha! Good to see you.",
        "Ah, {target}. Come to show me how the {targetrace} do it? This I have to see.",
    },
    WARY = {
        "{target}. I'll be keeping an eye on you.",
        "Hm. {target}. Your kind and mine have a history. Mind your step.",
        "Easy, {target}. Hands where I can see them.",
        "{target}. Don't take it personally. I don't trust anyone right away.",
        "Well met, {target}. Maybe. We'll see.",
    },
    GRUFF = {
        "Hmph. {target}. Keep to your side of the road.",
        "{target}. I'll be watching you. Your kind has a way of causing trouble.",
        "Don't expect a warm welcome from me, {target}.",
        "One of the {targetrace}. Of course. What do you want, {target}?",
        "Mind yourself around me, {target}, and we'll get along fine.",
    },
    DISDAINFUL = {
        "{target}. How... quaint.",
        "Oh. {target}. I suppose your people can't help it.",
        "{target}. Do try to keep up.",
        "Ah, the {targetrace}. Charming, in a simple sort of way.",
        "{target}. I'd say well met, but let's not exaggerate.",
    },
}

-- Kin versions of the fallback pools, used when the target is of your own race
local STANCE_KIN_FALLBACK = {
    WARM = {
        "{target}! Good to see one of our own. Well met, kin.",
        "Well met, {target}! Kin is always welcome at my side.",
        "{target}! It does me good to see a familiar face out here.",
        "Hail, {target}! Our people stand together.",
    },
    ADMIRING = {
        "{target}! You do our people proud.",
        "Well met, {target}. I've heard good things about you, kin.",
        "{target}. The best of us, they say. I believe it.",
    },
    PLAYFUL = {
        "{target}! You're giving our people a bad name. Ha! Good to see you.",
        "Oh, it's {target}. I was hoping for someone better-looking. Kidding, kin!",
        "{target}! Still the second-finest of our kind, after me.",
    },
    WARY = {
        "{target}. Kin or not, I'm watching you.",
        "Hm. {target}. Being one of us doesn't make you a friend.",
        "{target}. We'll see what sort of kin you turn out to be.",
    },
    GRUFF = {
        "Hmph. {target}. You're an embarrassment to our people.",
        "{target}. Same blood, different stock. Keep your distance.",
        "Don't call me kin, {target}. You haven't earned it.",
    },
    DISDAINFUL = {
        "{target}. One of us? Hard to believe.",
        "Oh. {target}. Our people have truly lowered their standards.",
        "{target}. Try not to remind anyone we're related.",
    },
}

-- Returns categoryKey, pool for the target's race stance, or nil if none is set
function Engine:GetStanceGreetingPool(unit)
    local cv = MonologueCharDB and MonologueCharDB.CustomVoice
    local stances = type(cv) == "table" and cv.raceStances
    if type(stances) ~= "table" or next(stances) == nil then return nil end

    local _, raceFile = UnitRace(unit)
    raceFile = Clean(raceFile)
    if type(raceFile) ~= "string" then return nil end
    local stance = stances[raceFile]
    if not CV_STANCES[stance] then return nil end

    local sg = self.ActiveProfile.StanceGreetings
    if type(sg) == "table" then
        local byRace = sg[raceFile]
        if type(byRace) == "table" and UsablePool(byRace[stance]) then
            return "Stance_" .. raceFile .. "_" .. stance, byRace[stance]
        end
    end
    -- Your own race: the race packs' general stance lines talk about "your people", so use the
    -- kin versions (a pack can still write its own lines for its own race, checked above)
    local _, ownRace = UnitRace("player")
    if Clean(ownRace) == raceFile and UsablePool(STANCE_KIN_FALLBACK[stance]) then
        return "StanceKin_" .. stance, STANCE_KIN_FALLBACK[stance]
    end
    if type(sg) == "table" and UsablePool(sg[stance]) then
        return "Stance_" .. stance, sg[stance]
    end
    return "StanceFallback_" .. stance, STANCE_FALLBACK[stance]
end

function Engine:BuildActiveProfile(levelOverride)
    if not MonologueDB or not MonologueCharDB then return end

    -- Drop any non-player rows an earlier version may have recorded in the rival ledger
    local purged = self:PurgeNonPlayerRivals()
    if purged > 0 then
        Print(string.format("Removed %d non-player %s from the rival ledger.", purged, purged == 1 and "entry" or "entries"))
    end
    -- Re-key older entries to the normalized name key, keeping multi-word display names
    self:NormalizeRivalKeys()

    local _, raceFile = UnitRace("player")
    local _, classFile = UnitClass("player")
    local level = tonumber(levelOverride) or UnitLevel("player") or 1
    if level < 1 then level = 1 end

    local merged = {}
    local context = {
        race = nil,
        class = nil,
        persona = nil,
        profile = nil,
        level = level,
        arc = nil,
        stageKey = nil,
        feats = {},
    }

    local customVoice = self:GetCustomVoice()

    -- Layer 1: Base Race
    if raceFile and self.Data.Races[raceFile] then
        local raceData = self.Data.Races[raceFile]
        merged = DeepMerge(merged, raceData, META_KEYS)
        context.race = raceFile

        -- Faction-choice races (Skyborne) carry per-faction flavor, keyed by the
        -- englishFaction string from UnitFactionGroup ("Alliance" / "Horde").
        local faction = UnitFactionGroup("player")
        local subtypes = type(raceData.FactionSubtypes) == "table" and raceData.FactionSubtypes
        if faction and subtypes and type(subtypes[faction]) == "table" then
            merged = DeepMerge(merged, subtypes[faction], META_KEYS)
            context.subtype = subtypes[faction].subtypeName or faction
        end

        -- Racial temperament preset (My Voice): overrides/extends the race pack, so it sits
        -- right after the race and underneath class, persona and everything else
        context.racePreset = ApplyRacePreset(merged, raceData, customVoice and customVoice.racePreset)
    end

    -- Layer 2: Base Class
    if classFile and self.Data.Classes[classFile] then
        local classData = self.Data.Classes[classFile]
        -- The class dialect sits UNDERNEATH the race dialect: where both define the same swap
        -- (or the same list, such as openers), the race wins. Persona and profile still sit
        -- above both. Everything else in the class pack merges over the race as before.
        local raceDialect = type(merged.Dialect) == "table" and DeepCopy(merged.Dialect) or nil
        merged = DeepMerge(merged, classData, META_KEYS)
        if type(classData.Dialect) == "table" then
            merged.Dialect = DeepMerge(DeepCopy(classData.Dialect), raceDialect)
        end
        context.class = classFile
    end

    -- Layer 3: Dynamic Growth Arc & Persona Overrides
    local arcStage, stageKey = self:GetGrowthStage(level)
    context.arc = arcStage
    context.stageKey = stageKey

    local selectedPersona = (MonologueCharDB.GrowthArc and MonologueCharDB.GrowthArc[arcStage]) or MonologueDB.selectedPersona
    if customVoice and IsSelectablePersona(customVoice.persona) then
        selectedPersona = customVoice.persona   -- My Voice persona overrides the Growth Arc pick
    end
    if selectedPersona and self.Data.Personas[selectedPersona] then
        merged = DeepMerge(merged, self.Data.Personas[selectedPersona], META_KEYS)
        context.persona = selectedPersona
    end

    -- Guild pack: matched on the guild name from GetGuildInfo("player"). It sits above the
    -- persona and below the character profile, and lands in ActiveProfile.Guild
    -- (guildName, rankGreetings, mottos) for the greeting trigger.
    local guildName = Clean(GetGuildInfo("player"))
    context.guildName = guildName
    local guildKey = self:FindGuildPackKey(guildName)
    if guildKey then
        merged = DeepMerge(merged, { Guild = self.Data.Guilds[guildKey] }, META_KEYS)
        context.guild = guildKey
    end

    -- Layer 4: Specific Character Profile, GrowthStages & Unlocked BossFeats
    local profileKey = self:GetCharacterProfileKey()
    if profileKey then
        local charProfile = self.Data.Profiles[profileKey]
        merged = DeepMerge(merged, charProfile, META_KEYS)
        context.profile = profileKey

        if type(charProfile.GrowthStages) == "table" and charProfile.GrowthStages[stageKey] then
            merged = DeepMerge(merged, charProfile.GrowthStages[stageKey], META_KEYS)
        end

        if type(charProfile.BossFeats) == "table" and MonologueCharDB.Feats then
            -- Sorted so overlapping feat overrides resolve deterministically
            local featKeys = {}
            for featKey in pairs(charProfile.BossFeats) do
                if MonologueCharDB.Feats[featKey] then
                    featKeys[#featKeys + 1] = featKey
                end
            end
            table.sort(featKeys)
            for _, featKey in ipairs(featKeys) do
                merged = DeepMerge(merged, charProfile.BossFeats[featKey], META_KEYS)
                context.feats[#context.feats + 1] = featKey
            end
        end
    end

    -- Layer 5: My Voice (in-game custom voice), on top of everything
    context.customVoice = ApplyCustomVoice(merged, customVoice)

    self.ActiveProfile = merged
    self.ActiveContext = context
    -- Shuffle decks are kept: GetShuffledLine notices when a pool's contents change
    if MonologueUI and MonologueUI.OnVoiceChanged then MonologueUI:OnVoiceChanged() end
end

---------------------------------------------------------------------------
-- Central Voice Box Router
---------------------------------------------------------------------------

function Engine:UpdateRestrictionState()
    local restricted = self.State.InEncounter
    for _, active in pairs(self.State.Restrictions) do
        if active then restricted = true end
    end
    self.State.InRestrictedEncounter = restricted and true or false
end

-- Returns true when a line in the given cooldown category may be spoken now
function Engine:CanSpeak(categoryKey)
    if not MonologueDB or not MonologueDB.enabled then return false, "disabled" end
    -- Out of character (keybind, /mono ooc): only a deliberate Greet still speaks
    if MonologueDB.outOfCharacter and not self.State.ExplicitLine then return false, "ooc" end

    if MonologueRPBridge and MonologueRPBridge.IsPlayerIC then
        local ok, isIC = pcall(MonologueRPBridge.IsPlayerIC, MonologueRPBridge)
        if ok and isIC == false then return false, "ooc" end
    end

    if IsStealthed() then return false, "stealth" end
    if UnitIsAFK("player") then return false, "afk" end
    if UnitIsDeadOrGhost("player") then return false, "dead" end

    local now = GetTime()
    if now < self.Cooldowns.GlobalBreath then return false, "breath" end

    if categoryKey then
        local readyAt = self.Cooldowns.Categories[categoryKey]
        if readyAt and now < readyAt then return false, "category" end
    end

    return true
end

---------------------------------------------------------------------------
-- Chat gate, send wrapper and background-speech handling
--
-- The 12.x client blocks SendChatMessage (SAY, YELL and EMOTE alike) when it is called from a
-- background event (PLAYER_TARGET_CHANGED, PLAYER_REGEN_ENABLED, UNIT_HEALTH,
-- CHAT_MSG_SYSTEM, ...), raising ADDON_ACTION_BLOCKED ("Interface action failed because of
-- an AddOn"). So:
--   * SendChatMessage is called ONLY for speech tied to a hardware event (a spell cast seen
--     on UNIT_SPELLCAST_SENT, the Battle Cry button or minimap click, a /mono command), or
--     never for any channel from a background event (group channels included).
--   * Background speech (target greetings, duel and PvP reactions, low-health lines) never
--     calls it. Per MonologueDB.backgroundSpeech it is either printed locally in your own
--     chat frame ("LOCAL", the default) or held as one queued line that is said publicly
--     with your next hardware action ("QUEUE").
--   * Nothing is sent from PLAYER_REGEN_ENABLED: that is a background event too.
-- Two more cases are handled in Speak():
--   "safemode"  an encounter-style restriction (boss fight, Mythic+, PvP match): the line is
--               printed locally. Combat on its own is NOT such a restriction.
--   "lockdown"  the client reports chat messaging lockdown (InChatMessagingLockdown), or a
--               hardware-event send is refused: the line is queued for the next action.
---------------------------------------------------------------------------

local PENDING_MAX_AGE = 15      -- seconds a queued line stays worth saying
local GREETING_MAX_AGE = 10     -- seconds a queued greeting waits for your next key press
local PARTY_MAX_AGE = 8         -- seconds a queued party reaction (rescue, victory) stays worth saying
local HARDWARE_RETRY_LIMIT = 3  -- send attempts per queued line
local GROUP_CHANNELS = { PARTY = true, RAID = true, INSTANCE_CHAT = true }

-- Returns kind ("safemode" | "lockdown"), reason, or nil when chat is open
function Engine:GetChatBlock()
    if self.State.InRestrictedEncounter then
        return "safemode", "encounter-style restriction (boss fight, Mythic+ or PvP match)"
    end
    if C_ChatInfo and C_ChatInfo.InChatMessagingLockdown then
        local ok, locked = pcall(C_ChatInfo.InChatMessagingLockdown)
        if ok and locked then
            return "lockdown", "chat messaging lockdown (InChatMessagingLockdown is true)"
        end
    end
    return nil
end

function Engine:RecordSendProblem(reason)
    self.State.SendProblem = { reason = tostring(reason), time = GetTime(), shown = false }
end

function Engine:ClearSendProblem()
    self.State.SendProblem = nil
end

-- The only place SendChatMessage is called. It refuses to send unless isHardwareEvent is true
-- (or the channel is a group channel), so a background event can never trigger
-- ADDON_ACTION_BLOCKED. Returns true, or false plus the reason.
-- isHardwareEvent must be true: a real key press or click (ability-press hook, /mono command,
-- button, keybind). The UNIT_SPELLCAST_SENT event is not a key press on WoW Forever, so cast
-- events never send; their lines are background speech (local print or queued).
-- Server-safety guardrails (alpha audit):
--   * only these channels can ever be sent to; never numbered/global channels or whispers
--   * at most one public /s, /y or /e line every Tune.SEND_MIN_GAP seconds; a faster one is shown
--     in your own chat frame instead (and reported as sent, so nothing retries it)
Tune.SEND_MIN_GAP = 6
local ALLOWED_SEND_CHANNELS = { SAY = true, YELL = true, EMOTE = true, PARTY = true, RAID = true, GUILD = true }
local RATE_LIMITED_CHANNELS = { SAY = true, YELL = true, EMOTE = true }

function Engine:TrySend(text, chatType, isHardwareEvent)
    local state = self.State
    -- Strict: only a real key press or click (an ability press, a /mono command, a button,
    -- a keybind) may send. Anything else is background speech and never reaches here.
    if isHardwareEvent ~= true then
        self:Debug("send refused: " .. tostring(chatType) .. " needs a key press")
        return false, "no key press for " .. tostring(chatType)
    end
    if not ALLOWED_SEND_CHANNELS[chatType] then
        self:Debug("send refused: channel " .. tostring(chatType) .. " is not allowed")
        return false, "channel " .. tostring(chatType) .. " not allowed"
    end
    if not (C_ChatInfo and C_ChatInfo.SendChatMessage) then return false, "no chat API" end
    if RATE_LIMITED_CHANNELS[chatType] and GetTime() - (state.LastPublicSendAt or -math.huge) < Tune.SEND_MIN_GAP then
        self:Debug("send rate-limited (" .. chatType .. ", one line per " .. Tune.SEND_MIN_GAP .. "s): shown in your chat only")
        self:PrintLocalSpeech(text, chatType)
        return true, "ratelimited"
    end

    state.SendBlockedBy = nil
    -- An ability-press line records which kind of place it was said in ("press:raid", ...)
    state.LastSendSource, state.LastSendAt = state.PressSource or isHardwareEvent, GetTime()
    state.Sending = true
    local ok, err = pcall(C_ChatInfo.SendChatMessage, text, chatType)
    state.Sending = false
    if not ok then
        self:Debug("send failed (" .. chatType .. "): " .. tostring(err))
        return false, "SendChatMessage error: " .. tostring(err)
    end
    if state.SendBlockedBy then
        self:Debug("send blocked (" .. chatType .. "): " .. state.SendBlockedBy)
        return false, "client blocked " .. state.SendBlockedBy
    end
    if RATE_LIMITED_CHANNELS[chatType] then state.LastPublicSendAt = GetTime() end
    return true
end

local function PairEmote(targetUnit, emoteToken)
    if targetUnit and emoteToken and UnitExists(targetUnit) and UnitIsEnemy("player", targetUnit) then
        DoEmote(emoteToken, targetUnit)
    end
end

-- Prints a line in your own chat frame, in a subtle RP style. Nothing is sent to the server.
function Engine:PrintLocalSpeech(text, chatType)
    local name = GetFullPlayerName("player") or "You"
    local spoken
    if chatType == "EMOTE" then
        spoken = name .. " " .. text
    else
        spoken = name .. (chatType == "YELL" and " yells" or " says") .. ': "' .. text .. '"'
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cff6f8f7f[RP]|r |cffa9bfa9" .. spoken .. "|r")
end

-- Holds the newest unsent line (older queued lines are replaced). The line is already in
-- its final EMOTE form and is sent only by FlushPendingSpeech, from a hardware event.
-- sayText/sayType (optional): the line in its real /s form, said instead of the emote when
-- the flush comes from a true key press (a jump, an ability press, a /mono command or a
-- button click). kind "greeting" lines expire after GREETING_MAX_AGE seconds.
function Engine:QueueSpeech(text, chatType, targetUnit, emoteToken, reason, sayText, sayType, kind)
    self.State.Pending = {
        text = text, chatType = chatType, targetUnit = targetUnit, emoteToken = emoteToken,
        sayText = sayText, sayType = sayType, kind = kind,
        maxAge = (kind == "greeting" and GREETING_MAX_AGE) or (kind == "party" and PARTY_MAX_AGE) or PENDING_MAX_AGE,
        queuedAt = GetTime(), attempts = 0, topic = self.State.BanterTopic,
        comm = self.State.CommOnSay, tag = self.State.PendingTag,
        -- The moment it belongs to: a line is dropped once you've changed zone or gone into or
        -- out of combat, so it never comes out somewhere it doesn't fit
        zone = Clean(GetRealZoneText()), inCombat = UnitAffectingCombat("player") and true or false,
    }
    self:Debug("speech queued (" .. tostring(reason or "waiting") .. "): " .. text)
end

-- True while a greeting is waiting for your next key press
function Engine:HasPendingGreeting()
    local pending = self.State.Pending
    return pending ~= nil and pending.kind == "greeting" and GetTime() - pending.queuedAt <= pending.maxAge
end

-- Any line waiting to be said (greeting, emote reply, duel or PvP reaction); returns its kind
-- ("greeting" or nil for other lines) as the second value. Lights up the Greet button.
function Engine:HasPendingLine()
    local pending = self.State.Pending
    if pending and GetTime() - pending.queuedAt <= (pending.maxAge or PENDING_MAX_AGE) then
        return true, pending.kind
    end
    return false
end

-- The waiting line for the queue bubble: text, channel, seconds waited, max age (or nil)
function Engine:GetPendingLine()
    local pending = self.State.Pending
    if not pending then return nil end
    local age = GetTime() - pending.queuedAt
    local maxAge = pending.maxAge or PENDING_MAX_AGE
    if age > maxAge then return nil end
    if pending.sayText then return pending.sayText, pending.sayType or "SAY", age, maxAge end
    return pending.text, pending.chatType, age, maxAge
end

function Engine:DropPendingLine()
    if self.State.Pending then self:Debug("queued line dismissed") end
    self.State.Pending = nil
end

-- Sends the queued line. Call it ONLY from a hardware-event context: a /mono command
-- (source "slash") or a spell cast seen on UNIT_SPELLCAST_SENT (source "cast"). Returns true
-- if the line went out.
function Engine:FlushPendingSpeech(source)
    local pending = self.State.Pending
    if not pending then return false end

    local now = GetTime()
    local maxAge = pending.maxAge or PENDING_MAX_AGE
    if now - pending.queuedAt > maxAge then
        self.State.Pending = nil
        self:Debug("queued line dropped: older than " .. maxAge .. "s")
        return false
    end
    if pending.attempts >= HARDWARE_RETRY_LIMIT then return false end
    local zoneNow = Clean(GetRealZoneText())
    if (pending.zone and zoneNow and pending.zone ~= zoneNow)
        or (pending.inCombat ~= nil and pending.inCombat ~= (UnitAffectingCombat("player") and true or false)) then
        self.State.Pending = nil
        self:Debug("queued line dropped: the moment has passed (zone or combat changed)")
        return false
    end

    -- Strict Safe-Mode: an ability press never says a held line aloud; show it locally
    if MonologueDB.strictSafeMode and self.State.PressSource then
        self.State.Pending = nil
        self:Debug("speech route: Strict Safe-Mode -> held line shown locally")
        self:PrintLocalSpeech(pending.sayText or pending.text, pending.sayText and (pending.sayType or "SAY") or pending.chatType)
        return true
    end

    -- Still locked down: keep waiting for a later action
    local blockKind, blockReason = self:GetChatBlock()
    if blockKind then
        self:Debug("flush (" .. tostring(source) .. ") skipped: " .. tostring(blockReason))
        return false
    end

    local hardware = (source == "cast") and "cast" or true
    if hardware == "cast" and MonologueDB.castSendBlocked then return false end

    pending.attempts = pending.attempts + 1
    -- A true key press may say the line aloud in its real /s form; the old cast-event path
    -- keeps the emote form
    local text, chatType = pending.text, pending.chatType
    if hardware == true and pending.sayText then
        text, chatType = pending.sayText, pending.sayType or "SAY"
    end
    local sent, problem = self:TrySend(text, chatType, hardware)
    local clientBlocked = type(problem) == "string" and problem:find("^client blocked") ~= nil
    if not sent and chatType ~= pending.chatType and not clientBlocked then
        -- /s refused (but not blocked by the client): fall back to the emote form
        text, chatType = pending.text, pending.chatType
        sent, problem = self:TrySend(text, chatType, hardware)
    end
    if not sent then
        self:RecordSendProblem(problem)
        return false
    end

    self.State.Pending = nil
    self:ClearSendProblem()
    if problem == "ratelimited" then return true end
    self:Debug("speech route: queued line said on your " .. ((source == "slash") and "ability press / click"
        or tostring(source)) .. " -> " .. chatType)
    if pending.topic then pcall(self.SendBanterTopic, self, pending.topic) end
    if pending.comm then pcall(self.SendCommOnSay, self, pending.comm) end
    PairEmote(pending.targetUnit, pending.emoteToken)
    return true
end

-- Speech from a background event: SendChatMessage is never called. Prints locally, or queues
-- one line for the next hardware action, per MonologueDB.backgroundSpeech.
function Engine:HandleBackgroundSpeech(text, chatType, targetUnit, emoteToken)
    if MonologueDB.backgroundSpeech == "QUEUE" then
        local outText = (chatType == "EMOTE") and text or OPEN_WORLD_EMOTE_FORMAT:format(text)
        local kind = self.State.SpeakKind
        self:Debug("speech route: background event -> waiting for your next ability press or click"
            .. (kind == "greeting" and (" (" .. GREETING_MAX_AGE .. "s)") or ""))
        self:QueueSpeech(TruncateChat(outText), "EMOTE", targetUnit, emoteToken,
            "background event, said on your next action",
            (chatType == "SAY" or chatType == "YELL") and TruncateChat(text) or nil, chatType, kind)
        return true, "queued"
    end

    self:Debug("speech route: background event -> local print (SendChatMessage not called)")
    self:PrintLocalSpeech(text, chatType)
    return true, "local"
end

-- isHardwareEvent = true marks speech triggered directly by a player action (a spell cast on
-- UNIT_SPELLCAST_SENT, the Battle Cry button, a minimap click, a /mono command). Only that
-- speech may call SendChatMessage (SAY, YELL or EMOTE). Group-channel speech (PARTY, RAID,
-- INSTANCE_CHAT) may also be sent. Everything else is background speech and is handled by
-- HandleBackgroundSpeech.
function Engine:Speak(text, chatType, targetUnit, categoryCooldown, emoteToken, isHardwareEvent)
    if type(text) ~= "string" or text == "" then return false, "empty" end
    chatType = chatType or "SAY"

    local catKey = categoryCooldown and (categoryCooldown.key or "default") or nil
    local allowed, reason = self:CanSpeak(catKey)
    if not allowed then
        self:Debug("speech skipped (" .. tostring(reason) .. (catKey and (", " .. catKey) or "") .. ")")
        return false, reason
    end

    local now = GetTime()
    if catKey then
        self.Cooldowns.Categories[catKey] = now + (categoryCooldown.duration or 30)
    end

    -- Enforce Global Breath Lock
    self.Cooldowns.GlobalBreath = now + (MonologueDB.globalBreath or 45)
    self.State.LastSpeechTime = now

    -- Party members with Monologue skip this line for a while (echo suppression)
    pcall(self.NoteSpokenLine, self, text)

    -- Dialect Translation Pass (party lines respect channel stepdown).
    -- Runs BEFORE token replacement: the translator masks {tokens}, so zone and
    -- player names substituted afterwards are never run through accent rules
    -- (a Troll's th->d rule must not turn "Thrall" into "Drall").
    if MonologueTranslator and MonologueTranslator.Translate and chatType ~= "EMOTE" then
        -- Channel rules, the temperament shift and My Voice Dialect Strength all apply
        local intensity
        if MonologueTranslator.GetChannelIntensity then
            intensity = MonologueTranslator:GetChannelIntensity(chatType)
        else
            intensity = MonologueDB.translationIntensity or 2
            if chatType == "PARTY" and MonologueDB.channelStepdown then
                intensity = math.min(intensity, 1)
            end
        end
        local ok, translated = pcall(MonologueTranslator.Translate, MonologueTranslator, text, intensity)
        if ok and type(translated) == "string" then text = translated end
    end

    -- Process Dynamic RP Tokens
    if MonologueRPBridge and MonologueRPBridge.ProcessTokens then
        local ok, processed = pcall(MonologueRPBridge.ProcessTokens, MonologueRPBridge, text, targetUnit)
        if ok and type(processed) == "string" then text = processed end
    end

    text = SanitizeLine(text)
    if text == "" then
        self:Debug("speech skipped: the line was empty after translation and tokens")
        return false, "empty"
    end

    -- Validate the requested channel
    if GROUP_CHANNELS[chatType] then
        if not IsInGroup() then return false, "nogroup" end
    elseif chatType ~= "SAY" and chatType ~= "YELL" and chatType ~= "EMOTE" then
        return false, "channel"
    end

    -- Strict Safe-Mode (General tab, /mono safemode): automated speech (ability presses and
    -- background events) only prints in your own chat. Explicit clicks and commands (Battle
    -- Cry, Greet, /mono cry) still speak, and typed chat is still translated.
    if MonologueDB.strictSafeMode and (not isHardwareEvent or self.State.PressSource) then
        self:Debug("speech route: Strict Safe-Mode -> local print, not sent")
        self:PrintLocalSpeech(text, chatType)
        return true, "local"
    end

    -- Restriction guardrail: an encounter-style restriction prints locally
    local blockKind, blockReason = self:GetChatBlock()
    -- An ability-press line in a boss fight, with "Boss fights" switched on in the menu, tries
    -- to send anyway (the client's own chat lockdown is still honoured below)
    if blockKind == "safemode" and self.State.PressAllowBoss and isHardwareEvent == true then
        self:Debug("speech route: boss fight allowed by the menu -> trying /s")
        blockKind = nil
    end
    if blockKind == "safemode" then
        self.State.SafeModeReason = blockReason
        self:Debug("speech route: Safe-Mode -> local print, not sent (" .. tostring(blockReason) .. ")")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff[Monologue Safe-Mode]:|r " .. TruncateChat(text))
        return true, "safemode"
    end

    -- Background speech never calls SendChatMessage. That includes group channels: only a
    -- hardware event (or a spell cast, until the client has refused one) may send.
    local isGroup = GROUP_CHANNELS[chatType] == true
    if isHardwareEvent == "cast" and MonologueDB.castSendBlocked then
        self:Debug("speech route: spell-cast chat is blocked on this client (/mono castchat retry to test again) -> background "
            .. tostring(MonologueDB.backgroundSpeech))
        isHardwareEvent = nil
    end
    if not isHardwareEvent then
        return self:HandleBackgroundSpeech(text, chatType, targetUnit, emoteToken)
    end

    -- From here on the speech is tied to a hardware event (or is a group channel)
    local outType, outText = chatType, TruncateChat(text)
    self:Debug("speech route: " .. (isGroup and "group channel" or "hardware event") .. " -> " .. outType)

    if blockKind == "lockdown" then
        -- Chat is locked right now: hold the line as an emote for a later hardware action
        if not isGroup then
            outType = "EMOTE"
            outText = TruncateChat(OPEN_WORLD_EMOTE_FORMAT:format(text))
        end
        self:RecordSendProblem(blockReason)
        self:QueueSpeech(outText, outType, targetUnit, emoteToken, blockReason)
        return true, "queued"
    end

    local sent, problem = self:TrySend(outText, outType, isHardwareEvent)
    if not sent and isHardwareEvent == "cast" and MonologueDB.castSendBlocked then
        -- The client just refused a cast-time send: no retry (it would be blocked again)
        return self:HandleBackgroundSpeech(text, chatType, targetUnit, emoteToken)
    end
    local clientBlocked = type(problem) == "string" and problem:find("^client blocked") ~= nil
    if not sent and isHardwareEvent and not clientBlocked and (outType == "SAY" or outType == "YELL") then
        -- The hardware-event SAY/YELL was refused: fall back to an emote right away
        self:Debug("hardware " .. outType .. " refused (" .. tostring(problem) .. "); falling back to EMOTE")
        outType = "EMOTE"
        outText = TruncateChat(OPEN_WORLD_EMOTE_FORMAT:format(text))
        sent, problem = self:TrySend(outText, outType, isHardwareEvent)
    end
    if not sent then
        -- Refused even so: keep the line for a later hardware action rather than lose it
        self:RecordSendProblem(problem)
        self:QueueSpeech(outText, outType, targetUnit, emoteToken, problem)
        self:Debug("speech route: send refused (" .. tostring(problem) .. ") -> queued for a later action")
        return true, "queued"
    end
    self:ClearSendProblem()
    if problem == "ratelimited" then return true, "local" end
    self:Debug("speech sent via " .. outType .. " (asked for " .. chatType .. "): " .. outText)
    if self.State.BanterTopic then pcall(self.SendBanterTopic, self, self.State.BanterTopic) end
    if self.State.CommOnSay then pcall(self.SendCommOnSay, self, self.State.CommOnSay) end

    -- Cross-Faction Native Emote Pairing
    PairEmote(targetUnit, emoteToken)

    return true, "sent"
end

---------------------------------------------------------------------------
-- Trigger Processing Engine
---------------------------------------------------------------------------

function Engine:ProcessTrigger(tier, categoryKey, pool, chance, targetUnit, emoteToken, chatType, hardware)
    if type(pool) ~= "table" or #pool == 0 or not MonologueDB then return false end

    local effectiveChance = math.min(1, (chance or 1.0) * (MonologueDB.chattiness or 1.0) * self:MoodChattiness()
        * self:PlaceChattiness())
    if math.random() > effectiveChance then
        -- Logged at most once per 10s per category, so routine misses don't flood the log
        local misses = self.State.RollMissLog
        local now = GetTime()
        if now - (misses[categoryKey] or -math.huge) >= 10 then
            misses[categoryKey] = now
            self:Debug(string.format("%s: chance roll missed (%.0f%% = %.0f%% x chattiness %.2f)",
                tostring(categoryKey), effectiveChance * 100, (chance or 1) * 100, MonologueDB.chattiness or 1))
        end
        return false
    end

    -- Gate before drawing so suppressed procs never burn a line from the deck
    local canSpeak, skipReason = self:CanSpeak(categoryKey)
    if not canSpeak then
        self:Debug("speech skipped (" .. tostring(skipReason) .. ", " .. tostring(categoryKey) .. ")")
        return false
    end

    local line = self:GetShuffledLine(categoryKey, pool)
    if not line then return false end

    local cooldownDuration = TIER_COOLDOWNS[tier] or 60
    return self:Speak(line, chatType or "SAY", targetUnit, { key = categoryKey, duration = cooldownDuration },
        emoteToken, hardware)
end

-- hardware = true when the reaction comes straight from the player's own cast
function Engine:TriggerSpellReaction(reactionKey, targetUnit, hardware)
    local reactions = self.ActiveProfile.SpellReactions
    local pool = type(reactions) == "table" and reactions[reactionKey]
    if not pool then return false end
    return self:ProcessTrigger(REACTION_TIERS[reactionKey] or 2, "Spell_" .. reactionKey, pool,
        REACTION_CHANCE[reactionKey] or 0.1, targetUnit, nil, nil, hardware)
end

---------------------------------------------------------------------------
-- Nemesis Ledger Engine
---------------------------------------------------------------------------

-- Rivals are stored under the normalized name key with the display name (spaces kept) in
-- the entry:
--   MonologueCharDB.Rivals["carlnage"] = { name = "Carl Nage", guid, kills, deaths,
--                                          lastSeen, lastZone, pinned }

-- Removes ledger entries that cannot be real players: malformed rows and rows tagged with
-- a non-Player GUID. Names are NOT judged by spaces: WoW Forever names contain them.
-- Older entries saved without a GUID can't be classified and are kept. Returns the count
-- removed.
function Engine:PurgeNonPlayerRivals()
    local rivals = MonologueCharDB and MonologueCharDB.Rivals
    if type(rivals) ~= "table" then return 0 end

    local doomed = {}
    for key, rival in pairs(rivals) do
        if type(key) ~= "string" or key == "" or type(rival) ~= "table"
            or (rival.guid ~= nil and not IsPlayerGUID(rival.guid)) then
            doomed[#doomed + 1] = key
        end
    end
    for _, key in ipairs(doomed) do
        rivals[key] = nil
    end
    return #doomed
end

-- Converts older entries (keyed by the display name, no name field) to the normalized
-- key plus entry.name, merging entries that collapse to the same key. Returns how many
-- entries were rewritten.
function Engine:NormalizeRivalKeys()
    local rivals = MonologueCharDB and MonologueCharDB.Rivals
    if type(rivals) ~= "table" then return 0 end

    local changes = {}
    for key, rival in pairs(rivals) do
        local display = (type(rival.name) == "string" and rival.name ~= "") and rival.name or key
        display = StripRealm(display) or display
        local fixedKey = NormalizeNameKey(display)
        if fixedKey ~= "" and (fixedKey ~= key or rival.name ~= display) then
            changes[#changes + 1] = { key = key, rival = rival, display = display, fixedKey = fixedKey }
        end
    end

    for _, change in ipairs(changes) do
        local rival = change.rival
        rivals[change.key] = nil
        local existing = rivals[change.fixedKey]
        if existing then
            existing.kills = (existing.kills or 0) + (rival.kills or 0)
            existing.deaths = (existing.deaths or 0) + (rival.deaths or 0)
            if (rival.lastSeen or 0) > (existing.lastSeen or 0) then
                existing.lastSeen = rival.lastSeen
                existing.lastZone = rival.lastZone
            end
            existing.pinned = (existing.pinned or rival.pinned) and true or nil
            existing.guid = existing.guid or rival.guid
            existing.name = existing.name or change.display
        else
            rival.name = change.display
            rivals[change.fixedKey] = rival
        end
    end
    return #changes
end

-- Looks a rival up by name (display name, with or without realm, any case or spacing).
-- Returns rival, key.
function Engine:GetRival(name)
    local rivals = MonologueCharDB and MonologueCharDB.Rivals
    if not rivals or type(name) ~= "string" then return nil end
    local key = NormalizeNameKey(StripRealm(name) or name)
    return rivals[key], key
end

-- Records a clash with another PLAYER. The guid must be a Player GUID: creatures, pets,
-- vehicles and guards are ignored, so they can never enter the ledger or any rival tier.
-- trusted = true lets a caller whose source only ever concerns real players (the honor-gain
-- chat message) record a clash when no GUID is known; a GUID, when given, must always be a
-- Player GUID.
function Engine:RecordPvPInteraction(targetName, isKill, guid, trusted)
    if not MonologueCharDB or type(targetName) ~= "string" then return end
    if guid ~= nil then
        if not IsPlayerGUID(guid) then return end
    elseif not trusted then
        return
    end

    local displayName = StripRealm(targetName)
    if not displayName then return end
    local key = NormalizeNameKey(displayName)
    if key == "" then return end

    MonologueCharDB.Rivals = MonologueCharDB.Rivals or {}
    -- An older first-name-only entry for this player is upgraded rather than duplicated
    local rival = self:AdoptRival(displayName, guid) or { kills = 0, deaths = 0, lastSeen = 0, lastZone = "the wild" }
    rival.name = displayName
    rival.guid = guid or rival.guid

    if isKill then
        rival.kills = (rival.kills or 0) + 1
    else
        rival.deaths = (rival.deaths or 0) + 1
    end

    local zone = GetRealZoneText()
    if not zone or zone == "" then zone = "the wild" end

    rival.lastSeen = GetServerTime()
    rival.lastZone = zone

    MonologueCharDB.Rivals[key] = rival
    self:RecordSkirmish(zone)
    self:PruneRivals(MAX_RIVALS)
    NotifyRosterChanged()
end

-- Tier earned by a rival's kill/death record alone, or nil if the record doesn't reach
-- Rematch (the zone-based DejaVu tier and FirstClash are decided by GetRivalTier).
function Engine:GetRivalRecordTier(rival)
    if type(rival) ~= "table" then return nil end
    local kills, deaths = rival.kills or 0, rival.deaths or 0
    local total = kills + deaths
    if total >= NEMESIS_THRESHOLD then return "Nemesis"
    elseif kills >= DOMINANCE_KILLS then return "Dominance"
    elseif deaths > kills then return "Vendetta"
    elseif total > 1 then return "Rematch" end
    return nil
end

function Engine:GetRivalTier(targetName)
    local rival = self:GetRival(targetName)

    local recordTier = self:GetRivalRecordTier(rival)
    if recordTier then return recordTier end

    -- Unfamiliar foe on a battlefield we keep returning to
    if self:IsDejaVuZone(GetRealZoneText()) then return "DejaVu" end

    return "FirstClash"
end

-- targetName may be a stored key or any spelling of the player's name
function Engine:SetRivalPinned(targetName, pinned)
    local rival = self:GetRival(targetName)
    if not rival then return false end
    rival.pinned = pinned and true or nil
    NotifyRosterChanged()
    return true
end

function Engine:RemoveRival(targetName)
    local rival, key = self:GetRival(targetName)
    if not rival then return false end
    MonologueCharDB.Rivals[key] = nil
    NotifyRosterChanged()
    return true
end

-- Returns the stored key for a typed name, or nil
function Engine:FindRivalKey(name)
    local rival, key = self:GetRival(name)
    if rival then return key end
    return nil
end

---------------------------------------------------------------------------
-- PvP Engagement Tracking
-- Kill/death attribution without the combat log: an enemy player counts as
-- "engaged" while targeted during combat; their death or ours inside the
-- engagement window is credited to the ledger.
---------------------------------------------------------------------------

-- Kills are credited without the combat log (COMBAT_LOG_EVENT_UNFILTERED and PARTY_KILL
-- are restricted on this client). Every enemy player you fight is remembered for
-- ENGAGEMENT_WINDOW seconds in State.Recent as
--   [guid] = { fullName, key, guid, zone, time, alive }
-- (fullName keeps spaces and has the realm removed; key is the normalized lookup key).
-- A kill is credited, once per corpse, by whichever of these fires first:
--   a) a tracked enemy player on "target" or "mouseover" goes from alive to dead,
--   b) PLAYER_PVP_KILLS_CHANGED while a recently engaged enemy player is dead or targeted,
--   c) CHAT_MSG_COMBAT_HONOR_GAIN, which names the slain player before " dies".
-- Only real players qualify: UnitIsPlayer plus a "Player-" GUID.

local function IsDeadPlayerUnit(unit)
    if not UnitIsDeadOrGhost(unit) then return false end
    return not (UnitIsFeignDeath and UnitIsFeignDeath(unit))
end

-- PvP kill-tracking trace. Now part of the unified debug mode (/mono debug; /mono pvpdebug
-- remains as an alias that toggles the same switch).
function Engine:PvPTrace(message)
    self:Debug("pvp: " .. message)
end

-- Remembers an enemy player on a unit token ("target" or "mouseover") while you are in
-- combat. Returns the tracking entry (existing or new), or nil if the unit doesn't qualify.
function Engine:TrackHostile(unit)
    if not UnitExists(unit) or not UnitIsPlayer(unit) or not UnitCanAttack("player", unit)
        or not IsOpposingFaction(unit) then
        return nil
    end
    local guid = Clean(UnitGUID(unit))
    if not IsPlayerGUID(guid) then return nil end
    local name = UnitNameAndRealm(unit)
    if not name then return nil end

    local now = GetTime()
    local recent = self.State.Recent
    for knownGUID, known in pairs(recent) do
        if now - known.time > ENGAGEMENT_WINDOW then recent[knownGUID] = nil end
    end

    local entry = recent[guid]
    -- A corpse, or a fight you are not part of, never refreshes the engagement
    if IsDeadPlayerUnit(unit) then return entry end
    if not (UnitAffectingCombat("player") or UnitAffectingCombat(unit)) then return entry end

    if not entry then
        entry = { guid = guid }
        recent[guid] = entry
        self:PvPTrace("now tracking " .. name .. " (" .. unit .. ")")
    end
    entry.fullName = name
    entry.key = NormalizeNameKey(name)
    entry.zone = GetRealZoneText()
    entry.time = now
    entry.alive = true
    return entry
end

-- Credits a kill for a tracked entry, once per corpse. Returns true if it was recorded.
function Engine:CreditKill(entry)
    if type(entry) ~= "table" or not IsPlayerGUID(entry.guid) then return false end

    local now = GetTime()
    if now - entry.time > ENGAGEMENT_WINDOW then
        self:PvPTrace("kill of " .. tostring(entry.fullName) .. " not credited: engagement older than " .. ENGAGEMENT_WINDOW .. "s")
        return false
    end

    local kills = self.State.RecentKills
    for killedGUID, killedAt in pairs(kills) do
        if now - killedAt > RECENT_KILL_WINDOW then kills[killedGUID] = nil end
    end
    if kills[entry.guid] then
        self:PvPTrace("kill of " .. tostring(entry.fullName) .. " already credited (duplicate ignored)")
        return false
    end

    kills[entry.guid] = now
    if entry.key then self.State.RecentKillNames[entry.key] = now end
    self.State.LastKillCredit = now
    entry.alive = false
    self:PvPTrace("KILL credited: " .. tostring(entry.fullName))

    local engaged = self.State.Engaged
    if engaged and engaged.guid == entry.guid then self.State.Engaged = nil end

    self:RecordPvPInteraction(entry.fullName, true, entry.guid)
    return true
end

-- Trigger (a): called when a tracked unit's health changes. A tracked enemy player seen
-- alive that is now dead is a kill.
function Engine:CheckUnitKill(unit)
    if not UnitExists(unit) or not UnitIsPlayer(unit) or not UnitCanAttack("player", unit)
        or not IsOpposingFaction(unit) then
        return
    end
    local guid = Clean(UnitGUID(unit))
    if not IsPlayerGUID(guid) then return end
    local entry = self.State.Recent[guid]
    if not entry then
        if IsDeadPlayerUnit(unit) then
            self:PvPTrace(unit .. " is a dead enemy player but was never tracked (not engaged in combat first)")
        end
        return
    end

    if IsDeadPlayerUnit(unit) then
        if entry.alive then
            self:PvPTrace(unit .. " " .. tostring(entry.fullName) .. " went from alive to dead")
            self:CreditKill(entry)
        else
            self:PvPTrace(unit .. " " .. tostring(entry.fullName) .. " is dead but was not seen alive since the last kill")
        end
    else
        entry.alive = true -- alive again (resurrected, or feigning) and ready to be credited later
    end
end

-- Health events on "target" and "mouseover": detect deaths, then keep engagements fresh
function Engine:HandleUnitHealth(unit)
    self:CheckUnitKill(unit)
    if unit == "target" then
        if UnitAffectingCombat("player") then self:MarkEngaged() end
    elseif unit == "mouseover" then
        self:TrackHostile("mouseover")
    end
end

-- The tracked entry for a unit token whose GUID is on record, or nil
local function RecentEntryForUnit(self, unit, requireDead)
    if not UnitExists(unit) or not UnitIsPlayer(unit) or not UnitCanAttack("player", unit)
        or not IsOpposingFaction(unit) then
        return nil
    end
    local guid = Clean(UnitGUID(unit))
    local entry = IsPlayerGUID(guid) and self.State.Recent[guid] or nil
    if entry and requireDead and not IsDeadPlayerUnit(unit) then return nil end
    return entry
end

-- Trigger (b): PLAYER_PVP_KILLS_CHANGED. Prefer a dead engaged player on target or
-- mouseover, then an engaged player you have targeted, then the most recently engaged one.
-- Ignored when a kill was just credited by another trigger.
function Engine:HandlePvPKillsChanged()
    local now = GetTime()
    if now - (self.State.LastKillCredit or 0) < 3 then
        self:PvPTrace("PLAYER_PVP_KILLS_CHANGED ignored: a kill was just credited")
        return
    end
    self:PvPTrace("PLAYER_PVP_KILLS_CHANGED fired")

    local entry = RecentEntryForUnit(self, "target", true) or RecentEntryForUnit(self, "mouseover", true)
        or RecentEntryForUnit(self, "target", false)

    if not entry then
        for _, candidate in pairs(self.State.Recent) do
            if now - candidate.time <= ENGAGEMENT_WINDOW and not self.State.RecentKills[candidate.guid]
                and (not entry or candidate.time > entry.time) then
                entry = candidate
            end
        end
    end
    if entry then
        self:CreditKill(entry)
    else
        self:PvPTrace("no recently engaged enemy player on record to credit")
    end
end

-- Trigger (c): CHAT_MSG_COMBAT_HONOR_GAIN, e.g. "Sota Stark dies, honorable kill Rank: ..."
-- Everything before " dies" is the slain player's full name (spaces kept).
function Engine:HandleHonorGain(message)
    message = Clean(message)
    if type(message) ~= "string" then return end

    local rawName = message:match("^(.-) dies")
    local slain = StripRealm(rawName)
    self:PvPTrace("honor message parsed, slain player: " .. tostring(slain))
    if not slain or slain == "" then return end

    local key = NormalizeNameKey(slain)
    local now = GetTime()
    for _, entry in pairs(self.State.Recent) do
        if entry.key == key and now - entry.time <= ENGAGEMENT_WINDOW then
            self:CreditKill(entry)
            return
        end
    end
    -- No engagement on record. Honor is only awarded for killing real enemy-faction players,
    -- so the message itself is proof: credit the kill from the name alone, taking the GUID
    -- from target or mouseover if one of them is that player.
    local killedNames = self.State.RecentKillNames
    for knownKey, killedAt in pairs(killedNames) do
        if now - killedAt > RECENT_KILL_WINDOW then killedNames[knownKey] = nil end
    end
    if killedNames[key] then
        self:PvPTrace("honor message for " .. slain .. " ignored: that kill was already credited")
        return
    end

    local guid
    for _, unit in ipairs({ "target", "mouseover" }) do
        if UnitExists(unit) and UnitIsPlayer(unit) then
            local unitName = UnitNameAndRealm(unit)
            local unitGUID = Clean(UnitGUID(unit))
            if unitName and NormalizeNameKey(unitName) == key and IsPlayerGUID(unitGUID) then
                guid = unitGUID
                break
            end
        end
    end
    if guid and self.State.RecentKills[guid] then
        self:PvPTrace("honor message for " .. slain .. " ignored: that kill was already credited")
        return
    end

    killedNames[key] = now
    if guid then self.State.RecentKills[guid] = now end
    self.State.LastKillCredit = now
    self:PvPTrace("KILL credited from honor message alone: " .. slain .. (guid and " (GUID found)" or " (no GUID)"))
    self:RecordPvPInteraction(slain, true, guid, true)
end

function Engine:MarkEngaged()
    -- Now fighting a creature, pet or guard: whatever happens next must not be credited
    -- to an earlier player foe as the killer of YOU, so drop that engagement.
    if UnitExists("target") and not UnitIsPlayer("target") and UnitCanAttack("player", "target") then
        self.State.Engaged = nil
        return
    end

    local entry = self:TrackHostile("target")
    if entry and entry.alive then
        self.State.Engaged = { name = entry.fullName, guid = entry.guid, time = entry.time }
    end
end

function Engine:HandlePlayerDeath()
    -- Remember what killed you (a creature) for the Revenge / AfterDeath situations
    local recent = self:GetRecent()
    recent.diedAt, recent.deathUsed = GetTime(), nil
    local killer
    if UnitExists("target") and UnitCanAttack("player", "target") then
        -- Killed by an enemy player: that's rival business, not a creature to settle up with
        if UnitIsPlayer("target") then killer = false else killer = Clean(UnitName("target")) end
    end
    if killer == false then
        recent.killer = nil
    else
        recent.killer = (type(killer) == "string" and killer ~= "") and killer or self.State.LastMobName
    end

    local engaged = self.State.Engaged
    self.State.Engaged = nil
    if not engaged or not IsPlayerGUID(engaged.guid) then return end
    if GetTime() - engaged.time > ENGAGEMENT_WINDOW then return end
    self:RecordPvPInteraction(engaged.name, false, engaged.guid)
end

---------------------------------------------------------------------------
-- Duels (MonologueCharDB.Duels)
-- Friendly bouts, kept strictly apart from open-world PvP Rivals. Each opponent has
--   Duels["carlnage"] = { name = "Carl Nage", wins, losses, lastZone, lastTime }
-- The opponent in progress is State.Duel = { name, key, since, active }: set when a duel
-- is requested or you challenge someone, confirmed on DUEL_INBOUNDS, cleared on
-- DUEL_FINISHED. The result comes from the system message
--   "<Winner> has defeated <Loser> in a duel"   (names may contain spaces)
-- which names both fighters, so it works even if the duel state was already cleared.
-- A win or loss then records the result and speaks a DuelWin / DuelLoss line.
---------------------------------------------------------------------------

function Engine:SetDuelOpponent(name, active)
    local display = type(name) == "string" and StripRealm(name) or nil
    if not display or display == "" then return end

    local key = NormalizeNameKey(display)
    local duel = self.State.Duel
    if not duel or duel.key ~= key then
        duel = { name = display, key = key }
        self.State.Duel = duel
    end
    duel.since = GetTime()
    if active then duel.active = true end
end

-- Called when you challenge a unit with StartDuel
function Engine:NoteDuelChallenge(unit)
    self.State.LastDuelActivity = GetTime()
    if type(unit) == "string" and UnitExists(unit) and UnitIsPlayer(unit) then
        self:SetDuelOpponent(UnitNameAndRealm(unit), false)
        pcall(self.DuelStarting, self, UnitNameAndRealm(unit), unit, "Challenge")
    end
end

-- StartDuel is only observed through a post-hook: the callback reads the unit and writes
-- addon-owned state (State.Duel). It never touches secure frames or Blizzard variables, and
-- any error in it is contained by pcall.
if type(StartDuel) == "function" then
    pcall(hooksecurefunc, "StartDuel", function(unit)
        pcall(Engine.NoteDuelChallenge, Engine, unit)
    end)
end

function Engine:HandleDuelEvent(event, ...)
    self.State.LastDuelActivity = GetTime()
    local who = (...)
    self:Debug("duel event " .. tostring(event) .. (who and (" (" .. tostring(who) .. ")") or ""))
    if event == "DUEL_REQUESTED" then
        self:SetDuelOpponent((...), false)
        pcall(self.DuelStarting, self, (...), nil, "Accept")
    elseif event == "DUEL_INBOUNDS" then
        if not self.State.Duel and UnitExists("target") and UnitIsPlayer("target") then
            self:SetDuelOpponent(UnitNameAndRealm("target"), true)
        elseif self.State.Duel then
            self.State.Duel.active = true
            self.State.Duel.since = GetTime()
        end
    elseif event == "DUEL_FINISHED" then
        self.State.Duel = nil
        -- A challenge or acceptance line not yet said belongs to a duel that never happened
        local pending = self.State.Pending
        if pending and pending.tag == "duelopen" then self.State.Pending = nil end
    end
end

function Engine:RemoveDuel(key)
    local duels = MonologueCharDB and MonologueCharDB.Duels
    if not duels or not key or not duels[key] then return false end
    duels[key] = nil
    NotifyRosterChanged()
    return true
end

function Engine:RecordDuel(opponentName, won)
    if not MonologueCharDB or type(opponentName) ~= "string" then return end
    local displayName = StripRealm(opponentName)
    if not displayName then return end
    local key = NormalizeNameKey(displayName)
    if key == "" then return end

    local duels = MonologueCharDB.Duels
    local duel = self:AdoptDuel(displayName) or { wins = 0, losses = 0 }
    duel.name = (#displayName >= #(duel.name or "")) and displayName or duel.name
    if won then
        duel.wins = (duel.wins or 0) + 1
    else
        duel.losses = (duel.losses or 0) + 1
    end

    local zone = GetRealZoneText()
    if not zone or zone == "" then zone = "the wild" end
    duel.lastZone = zone
    duel.lastTime = GetServerTime()
    duels[key] = duel

    -- Keep the list bounded: drop the opponent fought longest ago
    local count, oldestKey, oldestTime = 0, nil, nil
    for duelKey, entry in pairs(duels) do
        count = count + 1
        local at = type(entry) == "table" and entry.lastTime or 0
        if not oldestTime or at < oldestTime then oldestKey, oldestTime = duelKey, at end
    end
    if count > MAX_DUELS and oldestKey then duels[oldestKey] = nil end

    NotifyRosterChanged()
end

-- Speaks a DuelWin / DuelLoss line from the active profile, if one exists
function Engine:SpeakDuelLine(opponentName, won)
    local pool = self.ActiveProfile[won and "DuelWin" or "DuelLoss"]
    if not UsablePool(pool) then return end

    -- {target} names the opponent only if they are your current target
    local targetUnit
    if UnitExists("target") and UnitIsPlayer("target") then
        local targetName = UnitNameAndRealm("target")
        if targetName and NormalizeNameKey(targetName) == NormalizeNameKey(opponentName) then
            targetUnit = "target"
        end
    end
    self:ProcessTrigger(6, won and "Duel_Win" or "Duel_Loss", pool, DUEL_LINE_CHANCE, targetUnit)
end

-- Records the outcome of a duel you took part in; other people's duels are ignored
function Engine:HandleDuelResult(winnerRaw, loserRaw)
    local winner, loser = StripRealm(winnerRaw), StripRealm(loserRaw)
    if not winner or not loser then return end
    local myName = UnitNameAndRealm("player")
    if not myName then return end
    self:Debug("duel result parsed: winner '" .. winner .. "', loser '" .. loser .. "', me '" .. myName .. "'")

    local myKey = NormalizeNameKey(myName)
    local duelRecently = GetTime() - (self.State.LastDuelActivity or 0) < 60

    -- Exact name match. If the client only gave us a first name for ourselves, a
    -- "<first name> <last name>" in the message also counts, but only right after duel events.
    local function IsMe(name)
        if NormalizeNameKey(name) == myKey then return true end
        return duelRecently and not myName:find("%s") and name:find("%s") ~= nil
            and NormalizeNameKey(FirstWord(name) or name) == myKey
    end

    local opponent, won
    if IsMe(winner) then
        opponent, won = loser, true
    elseif IsMe(loser) then
        opponent, won = winner, false
    else
        self:Debug("duel result ignored: I am neither '" .. winner .. "' nor '" .. loser .. "'")
        return
    end

    local now = GetTime()
    local signature = (won and "w:" or "l:") .. NormalizeNameKey(opponent)
    if self.State.LastDuelSignature == signature and now - (self.State.LastDuelTime or 0) < DUEL_RESULT_DEDUPE then
        self:Debug("duel result ignored: duplicate of the one just recorded")
        return
    end
    self.State.LastDuelSignature, self.State.LastDuelTime = signature, now

    self.State.Duel = nil
    self:Debug("duel recorded: " .. (won and "WIN" or "LOSS") .. " vs " .. opponent)
    self:RecordDuel(opponent, won)
    self:DuelResultTalk(opponent, won)
end

-- CHAT_MSG_SYSTEM: "<Winner> has defeated <Loser> in a duel" (or "<Loser> has fled from
-- <Winner> in a duel"). The non-greedy captures keep names with spaces intact.
function Engine:HandleSystemMessage(message)
    message = Clean(message)
    if type(message) ~= "string" then return end
    if self:NoteDrunkMessage(message) then return end
    if not message:find(" in a duel", 1, true) then return end

    -- Remove colour codes and player links so only the names remain
    message = message:gsub("|H.-|h%[?(.-)%]?|h", "%1"):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    self:Debug("duel system message: " .. message)

    local winner, loser = message:match("^(.-) has defeated (.-) in a duel")
    if not winner then
        loser, winner = message:match("^(.-) has fled from (.-) in a duel")
    end
    if winner and loser then
        self:HandleDuelResult(winner, loser)
    else
        self:Debug("duel message matched neither known pattern")
    end
end

---------------------------------------------------------------------------
-- Stored-name refresh
-- Entries saved while only a first name was available ("Tara") are upgraded to the full
-- name ("Tara Page") and re-keyed the next time that player is seen. An older entry is
-- matched to the player by GUID when it has one; otherwise a single-word stored name equal
-- to the first word of the full name (and, for friends, the same race when both are known).
-- Entries without a GUID can't be proven to be the same player, so that match is a best
-- guess; once matched, the GUID is stored and the match is exact from then on.
---------------------------------------------------------------------------

local function FindLegacyEntry(store, newKey, fullName, guid, race)
    if not fullName:find("%s") then return nil end
    local wantedFirst = NormalizeNameKey(FirstWord(fullName) or fullName)

    for oldKey, entry in pairs(store) do
        if oldKey ~= newKey and type(entry) == "table" then
            if guid and entry.guid == guid then return oldKey, entry end

            local stored = type(entry.name) == "string" and entry.name or tostring(oldKey)
            if entry.guid == nil and not stored:find("%s") and NormalizeNameKey(stored) == wantedFirst
                and (race == nil or entry.race == nil or entry.race == race) then
                return oldKey, entry
            end
        end
    end
    return nil
end

local function MoveEntry(store, oldKey, newKey, entry, fullName, label)
    Engine:Debug(tostring(label) .. " name upgrade: '" .. tostring(entry.name or oldKey) .. "' -> '" .. fullName
        .. "' (re-keyed " .. tostring(oldKey) .. " -> " .. tostring(newKey) .. ")")
    store[oldKey] = nil
    entry.name = fullName
    store[newKey] = entry
end

-- Returns the rival for fullName (upgrading an older entry for the same player), or nil.
-- Never creates an entry.
function Engine:AdoptRival(fullName, guid)
    local rivals = MonologueCharDB and MonologueCharDB.Rivals
    if not rivals or type(fullName) ~= "string" or fullName == "" then return nil end
    if guid ~= nil and not IsPlayerGUID(guid) then guid = nil end

    local key = NormalizeNameKey(fullName)
    local rival = rivals[key]
    if not rival then
        local oldKey, old = FindLegacyEntry(rivals, key, fullName, guid, nil)
        if old then
            MoveEntry(rivals, oldKey, key, old, fullName, "rival")
            rival = old
        end
    end
    if rival then
        if #fullName > #(rival.name or "") then
            Engine:Debug("rival name updated: '" .. tostring(rival.name) .. "' -> '" .. fullName .. "'")
            rival.name = fullName
        end
        if guid and not rival.guid then rival.guid = guid end
    end
    return rival, key
end

-- Returns the friend record and key for a player (upgrading an older entry), or nil
function Engine:AdoptFriend(fullName, realm, guid, race)
    local friends = MonologueCharDB and MonologueCharDB.Friends
    if not friends or next(friends) == nil or type(fullName) ~= "string" then return nil end

    local key = self:FriendKeyFor(fullName, realm)
    if not key then return nil end
    local record = friends[key]
    if not record then
        local plainKey = self:FriendKeyFor(fullName)
        if plainKey and friends[plainKey] then key, record = plainKey, friends[plainKey] end
    end
    if not record then
        local oldKey, old = FindLegacyEntry(friends, key, fullName, guid, race)
        if old then
            MoveEntry(friends, oldKey, key, old, fullName, "friend")
            old.realm = realm or old.realm
            record = old
        end
    end
    if record then
        if #fullName > #(record.name or "") then
            Engine:Debug("friend name updated: '" .. tostring(record.name) .. "' -> '" .. fullName .. "'")
            record.name = fullName
        end
        if guid and not record.guid then record.guid = guid end
        if type(race) == "string" and not record.race then record.race = race end
    end
    return record, key
end

-- Returns the duel record for an opponent (upgrading an older entry), or nil
function Engine:AdoptDuel(fullName)
    local duels = MonologueCharDB and MonologueCharDB.Duels
    if not duels or type(fullName) ~= "string" or fullName == "" then return nil end

    local key = NormalizeNameKey(fullName)
    local duel = duels[key]
    if not duel then
        local oldKey, old = FindLegacyEntry(duels, key, fullName, nil, nil)
        if old then
            MoveEntry(duels, oldKey, key, old, fullName, "duel")
            duel = old
        end
    end
    if duel and #fullName > #(duel.name or "") then
        Engine:Debug("duel name updated: '" .. tostring(duel.name) .. "' -> '" .. fullName .. "'")
        duel.name = fullName
    end
    return duel, key
end

-- Called when a unit is targeted or moused over: upgrades any stored entry for that player
function Engine:RefreshStoredNames(unit)
    local db = MonologueCharDB
    if not db or (next(db.Friends) == nil and next(db.Rivals) == nil and next(db.Duels) == nil) then return end
    if not UnitExists(unit) or not UnitIsPlayer(unit) or UnitIsUnit(unit, "player") then return end

    local fullName, realm = GetFullPlayerName(unit)
    if not fullName then return end
    local guid = Clean(UnitGUID(unit))
    if not IsPlayerGUID(guid) then guid = nil end
    local _, race = UnitRace(unit)

    if UnitCanAttack("player", unit) and IsOpposingFaction(unit) then
        self:AdoptRival(fullName, guid)
    end
    if UnitIsFriend("player", unit) then
        self:AdoptFriend(fullName, realm, guid, Clean(race))
    end
    if IsDuelOpponentUnit(unit) then
        self:AdoptDuel(fullName)
    end
    NotifyRosterChanged()
end

-- Greeting pool for a guildmate: a rank-specific pool from the guild pack, or one of the
-- pack's mottos (both "specific", third return true), falling back to the active
-- profile's GuildGreetings.Standard (third return false).
function Engine:GetGuildGreetingPool(unit)
    local profile = self.ActiveProfile
    -- No guild pack: still allow GuildGreetings.Standard (e.g. a My Voice guild greeting)
    local guild = type(profile.Guild) == "table" and profile.Guild or {}

    -- Your own guild greeting (My Voice tab) comes first, most of the time; with no guild
    -- pack, every time
    local cv = MonologueCharDB and MonologueCharDB.CustomVoice
    local own = type(cv) == "table" and type(cv.guildGreeting) == "string" and cv.guildGreeting ~= "" and cv.guildGreeting
    if own and (not (UsablePool(guild.mottos) or type(guild.rankGreetings) == "table")
        or math.random() < Tune.MY_GUILD_GREET_SHARE) then
        return "Guild_MyVoice", { own }, true
    end

    if UsablePool(guild.mottos) and math.random() < GUILD_MOTTO_CHANCE then
        return "Guild_Motto", guild.mottos, true
    end

    local _, _, rankIndex = GetGuildInfo(unit)
    rankIndex = Clean(rankIndex)
    if rankIndex ~= nil and type(guild.rankGreetings) == "table" and UsablePool(guild.rankGreetings[rankIndex]) then
        return "Guild_Rank" .. rankIndex, guild.rankGreetings[rankIndex], true
    end

    local standard = type(profile.GuildGreetings) == "table" and profile.GuildGreetings.Standard
    if UsablePool(standard) then
        return "Guild_Standard", standard, false
    end
    return nil
end

-- Greeting pool for a friendly player's race, from ActiveProfile.RaceGreetings keyed by
-- the target's raceFile (e.g. "NightElf"). A localized race name with spaces and
-- apostrophes removed is used if no raceFile is available.
function Engine:GetRaceGreetingPool(unit)
    local greetings = self.ActiveProfile.RaceGreetings
    if type(greetings) ~= "table" then return nil end

    local raceName, raceFile = UnitRace(unit)
    local raceKey = Clean(raceFile) or Clean(raceName)
    if type(raceKey) ~= "string" then return nil end
    raceKey = raceKey:gsub("[%s']", "")

    if UsablePool(greetings[raceKey]) then
        return "Race_" .. raceKey, greetings[raceKey]
    end
    local lowered = raceKey:lower()
    for key, pool in pairs(greetings) do
        if type(key) == "string" and key:lower() == lowered and UsablePool(pool) then
            return "Race_" .. key, pool
        end
    end
    return nil
end

---------------------------------------------------------------------------
-- Marked Friends (per character, MonologueCharDB.Friends)
-- Keyed by the normalized player name (lower case, no spaces, hyphens or apostrophes;
-- the realm is appended for cross-realm players). Each entry is
--   { name = "Display-Name", race = raceFile, note = "free text", addedAt = serverTime }
---------------------------------------------------------------------------

local function FriendKey(name, realm)
    name, realm = Clean(name), Clean(realm)
    if type(name) ~= "string" or name == "" then return nil end
    if type(realm) == "string" and realm ~= "" then name = name .. realm end
    return NormalizeProfileKey(name)
end

-- Strips control characters and escape pipes, collapses whitespace and caps the length
local function CleanNote(note)
    if type(note) ~= "string" then return nil end
    note = note:gsub("[%c|]", ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s%s+", " ")
    if #note > MAX_NOTE_LENGTH then
        note = note:sub(1, MAX_NOTE_LENGTH):gsub("[\192-\255][\128-\191]*$", "")
    end
    if note == "" then return nil end
    return note
end

function Engine:FriendKeyFor(name, realm)
    return FriendKey(name, realm)
end

function Engine:CountFriends()
    local count = 0
    for _ in pairs(MonologueCharDB and MonologueCharDB.Friends or {}) do count = count + 1 end
    return count
end

-- Looks up the marked friend for a unit token. Returns record, key (or nil).
function Engine:GetFriendForUnit(unit)
    local friends = MonologueCharDB and MonologueCharDB.Friends
    if not friends or next(friends) == nil then return nil end

    local name, realm = UnitNameAndRealm(unit)
    if not name then return nil end

    local guid = Clean(UnitGUID(unit))
    if not IsPlayerGUID(guid) then guid = nil end
    local _, race = UnitRace(unit)

    -- Finds the friend by name, upgrading an older first-name-only entry on the way
    return self:AdoptFriend(name, realm, guid, Clean(race))
end

-- Finds a friend's key from typed text: a stored key, or a name (case, spaces and
-- punctuation ignored, with or without the realm).
function Engine:FindFriendKey(input)
    local friends = MonologueCharDB and MonologueCharDB.Friends
    if not friends or type(input) ~= "string" or input == "" then return nil end

    local wanted = NormalizeProfileKey(input)
    if friends[wanted] then return wanted end
    for key, record in pairs(friends) do
        if type(record) == "table" and type(record.name) == "string" then
            if NormalizeProfileKey(record.name) == wanted
                or NormalizeProfileKey(StripRealm(record.name) or record.name) == wanted then
                return key
            end
        end
    end
    return nil
end

-- Validates a unit for marking and returns name, realm, raceFile, or nil, reason
function Engine:UnitFriendInfo(unit)
    if not unit or not UnitExists(unit) or not UnitIsPlayer(unit) then
        return nil, "Target a friendly player first."
    end
    if UnitIsUnit(unit, "player") then
        return nil, "You can't mark yourself as a friend."
    end
    if not UnitIsFriend("player", unit) then
        return nil, "Only friendly players can be marked as friends."
    end
    local name, realm = UnitNameAndRealm(unit)
    if not name then
        return nil, "That player's name isn't available right now."
    end
    local _, raceFile = UnitRace(unit)
    local guid = Clean(UnitGUID(unit))
    if not IsPlayerGUID(guid) then guid = nil end
    return name, realm, Clean(raceFile), guid
end

-- Adds a friend, or updates an existing one (a nil note keeps the current note). guid is
-- optional but lets later name upgrades match this friend exactly.
-- Returns "added" | "updated" | "full", record, key.
function Engine:AddFriend(name, realm, raceFile, note, guid)
    if not MonologueCharDB then return nil end
    local key = FriendKey(name, realm)
    if not key then return nil end

    local friends = MonologueCharDB.Friends
    note = CleanNote(note)

    -- An older first-name-only entry for this player becomes the full-name entry
    local record, adoptedKey = self:AdoptFriend(Clean(name), realm, guid, raceFile)
    if record then
        key = adoptedKey or key
        if note then record.note = note end
        if type(raceFile) == "string" then record.race = raceFile end
        if guid then record.guid = guid end
        NotifyRosterChanged()
        return "updated", record, key
    end

    if self:CountFriends() >= MAX_FRIENDS then return "full" end

    -- name keeps its spaces ("Carl Nage") with any realm removed; the realm is stored apart
    local cleanName = Clean(name)
    local displayName = StripRealm(cleanName) or cleanName
    local realmName = Clean(realm)
    record = {
        name = displayName,
        realm = (type(realmName) == "string" and realmName ~= "") and realmName or nil,
        race = type(raceFile) == "string" and raceFile or nil,
        guid = guid,
        note = note or "",
        addedAt = GetServerTime(),
    }
    friends[key] = record
    NotifyRosterChanged()
    return "added", record, key
end

function Engine:RemoveFriend(key)
    local friends = MonologueCharDB and MonologueCharDB.Friends
    if not friends or not key or not friends[key] then return nil end
    local record = friends[key]
    friends[key] = nil
    NotifyRosterChanged()
    return record
end

-- Sets (or, with nil/empty text, clears) a friend's note
function Engine:SetFriendNote(key, note)
    local friends = MonologueCharDB and MonologueCharDB.Friends
    local record = friends and key and friends[key]
    if not record then return false end
    record.note = CleanNote(note) or ""
    NotifyRosterChanged()
    return true
end

-- Greeting pool for a marked friend, most specific first:
--   1. FriendGreetings[<key matching the friend's note>] (case, spaces, punctuation ignored),
--   2. FriendGreetings[<the friend's raceFile>], e.g. FriendGreetings.NightElf,
--   3. FriendGreetings.Default.
function Engine:GetFriendGreetingPool(unit, friend)
    local greetings = self.ActiveProfile.FriendGreetings
    if type(greetings) ~= "table" then return nil end

    local note = type(friend.note) == "string" and NormalizeProfileKey(friend.note) or ""
    if note ~= "" then
        local keys = {}
        for key, pool in pairs(greetings) do
            if type(key) == "string" and key ~= "Default" and UsablePool(pool) then keys[#keys + 1] = key end
        end
        table.sort(keys)
        for _, key in ipairs(keys) do
            if NormalizeProfileKey(key) == note then
                return "Friend_Note_" .. key, greetings[key]
            end
        end
    end

    local _, liveRace = UnitRace(unit)
    local raceKey = Clean(liveRace) or friend.race
    if type(raceKey) == "string" and raceKey ~= "" then
        raceKey = raceKey:gsub("[%s']", "")
        if UsablePool(greetings[raceKey]) then
            return "Friend_" .. raceKey, greetings[raceKey]
        end
        local lowered = raceKey:lower()
        for key, pool in pairs(greetings) do
            if type(key) == "string" and key ~= "Default" and key:lower() == lowered and UsablePool(pool) then
                return "Friend_" .. key, pool
            end
        end
    end

    if UsablePool(greetings.Default) then
        return "Friend_Default", greetings.Default
    end
    return nil
end

-- Greets a friendly player when you target them, out of combat. Priority:
--   1. a marked friend's greeting (/mono friend), from ActiveProfile.FriendGreetings,
--   2. a guild-rank greeting or motto from the active guild pack (guildmates only),
--   3. a RaceGreetings line for the target's race,
--   4. the profile's GuildGreetings.Standard fallback (guildmates with a guild pack).
-- The usual speech rules apply (global breath lock, category cooldown, chattiness), and
-- each player is greeted at most once per GUILD_GREET_COOLDOWN seconds.
function Engine:HandleFriendlyTarget()
    if not UnitExists("target") or not UnitIsPlayer("target") then return end
    if UnitIsUnit("target", "player") or UnitIsDeadOrGhost("target") then return end
    if not UnitIsFriend("player", "target") or UnitAffectingCombat("player") then return end

    local who = Clean(UnitGUID("target")) or UnitNameAndRealm("target")
    if not who then return end

    local now = GetTime()
    local greeted = self.State.GreetedAt
    for key, at in pairs(greeted) do
        if now - at > GUILD_GREET_COOLDOWN then greeted[key] = nil end
    end
    if greeted[who] then return end
    if self:GreetBlocked("target") then return end

    local categoryKey, pool, chance = self:PickGreeting("target")
    if not pool then return end

    local targetName = ShortName(UnitName("target"))
    self.State.SpeakKind = "greeting"
    self.State.OathMoment = "Greet"
    self.State.CommOnSay = self:CommFor("G", targetName, "target")
    local okTrigger, spoke = pcall(self.ProcessTrigger, self, 5, categoryKey, pool, chance, "target")
    self.State.SpeakKind = nil
    self.State.OathMoment = nil
    self.State.CommOnSay = nil
    spoke = okTrigger and spoke
    if spoke then
        greeted[who] = now
        self:NoteGreeted(targetName)
    end
end

-- Chooses the greeting pool for a friendly player, most specific first. Returns
-- categoryKey, pool, chance (or nil).
function Engine:PickGreeting(unit)
    local categoryKey, pool, chance
    local fallbackKey, fallbackPool

    local friend = self:GetFriendForUnit(unit)
    if friend then
        local key, friendPool = self:GetFriendGreetingPool(unit, friend)
        if friendPool then
            categoryKey, pool, chance = key, friendPool, FRIEND_GREET_CHANCE
        end
    end

    -- Guildmates: your own guild greeting (My Voice), a rank greeting or a guild motto. These
    -- work with or without a guild pack, and beat race and stance greetings; only a marked
    -- friend's greeting comes first.
    local guildSpecific = false
    if not pool and IsInGuild() then
        local myGuild = Clean(GetGuildInfo("player"))
        local theirGuild = Clean(GetGuildInfo(unit))
        if myGuild and myGuild == theirGuild then
            local key, guildPool, specific = self:GetGuildGreetingPool(unit)
            if guildPool and specific then
                categoryKey, pool, chance = key, guildPool,
                    (key == "Guild_MyVoice") and FRIEND_GREET_CHANCE or GUILD_GREET_CHANCE
                guildSpecific = true
            elseif guildPool then
                fallbackKey, fallbackPool = key, guildPool
            end
        end
    end

    -- A dedicated friend note (Duo, TaraPage, ...) or a guildmate greeting wins; otherwise a
    -- cross-race stance for the target's race beats the friend's race/Default greeting and
    -- the race pools
    if not guildSpecific and not (pool and categoryKey and categoryKey:find("^Friend_Note_")) then
        local stanceKey, stancePool = self:GetStanceGreetingPool(unit)
        if stancePool then
            categoryKey, pool, chance = stanceKey, stancePool, FRIEND_GREET_CHANCE
        end
    end

    if not pool then
        local key, racePool = self:GetRaceGreetingPool(unit)
        if racePool then
            categoryKey, pool, chance = key, racePool, RACE_GREET_CHANCE
        end
    end

    if not pool and fallbackPool then
        categoryKey, pool, chance = fallbackKey, fallbackPool, GUILD_GREET_CHANCE
    end

    -- A marked friend you've duelled: now and then the greeting is about the duel score
    if friend then
        local duel = self:GetDuelRecord(GetFullPlayerName(unit) or friend.name)
        local duelPool, duelDeck = self:GetDuelBanterPool(duel)
        if duelPool and math.random() < DUEL_BANTER_SHARE then
            return duelDeck, duelPool, chance or FRIEND_GREET_CHANCE
        end
    end

    -- Your mood now and then (never over a dedicated friend note or your own guild greeting)
    if pool and not categoryKey:find("^Friend_Note_") and categoryKey ~= "Guild_MyVoice" then
        local moodKey, moodPool = self:MoodPool("Greet")
        if moodPool then return moodKey, moodPool, chance end
    end
    -- Now and then a clan or allegiance greeting instead (never over a dedicated friend note)
    if pool and not categoryKey:find("^Friend_Note_") and categoryKey ~= "Guild_MyVoice"
        and math.random() < Tune.IDENTITY_GREET_SHARE then
        local idKey, idPool = self:PickIdentityPool("Greet")
        if idPool then categoryKey, pool = idKey, idPool end
    end
    return categoryKey, pool, chance
end

-- In character / out of character (keybind, /mono ic, /mono ooc). Out of character: typed chat
-- is not translated and automatic lines stay quiet; Greet and Battle Cry still work.
function Engine:SetInCharacter(inCharacter)
    if not MonologueDB then return end
    MonologueDB.outOfCharacter = not inCharacter
    if not inCharacter then self.State.Pending = nil end
    Print(inCharacter and "|cff00ff00In character.|r Translation and lines are on."
        or "|cffaaaaaaOut of character.|r No translation, no automatic lines (Greet and Battle Cry still work).")
    if MonologueUI and MonologueUI.UpdateMinimapState then pcall(MonologueUI.UpdateMinimapState, MonologueUI) end
end

function Engine:ToggleInCharacter()
    if not MonologueDB then return end
    self:SetInCharacter(MonologueDB.outOfCharacter == true)
end

-- Words Never Translated (account-wide, My Voice tab and /mono keep)
local KEEP_MAX_WORDS, KEEP_MAX_BYTES = 50, 40
function Engine:AddKeepWord(word)
    if not MonologueDB then return false end
    word = type(word) == "string" and strtrim((word:gsub("[%c|]", " "))) or ""
    if word == "" or not word:find("%w") then return false, "Type a word or name first." end
    if #word > KEEP_MAX_BYTES then return false, "That is too long (" .. KEEP_MAX_BYTES .. " letters at most)." end
    if type(MonologueDB.keepWords) ~= "table" then MonologueDB.keepWords = {} end
    local list = MonologueDB.keepWords
    for _, existing in ipairs(list) do
        if type(existing) == "string" and existing:lower() == word:lower() then return false, "Already on the list." end
    end
    if #list >= KEEP_MAX_WORDS then return false, "The list is full (" .. KEEP_MAX_WORDS .. ")." end
    list[#list + 1] = word
    if MonologueUI and MonologueUI.OnVoiceChanged then pcall(MonologueUI.OnVoiceChanged, MonologueUI) end
    return true
end

function Engine:RemoveKeepWord(word)
    local list = MonologueDB and MonologueDB.keepWords
    if type(list) ~= "table" or type(word) ~= "string" then return false end
    for i, existing in ipairs(list) do
        if type(existing) == "string" and existing:lower() == word:lower() then
            table.remove(list, i)
            if MonologueUI and MonologueUI.OnVoiceChanged then pcall(MonologueUI.OnVoiceChanged, MonologueUI) end
            return true
        end
    end
    return false
end

-- Greet button, keybind and /mono greet (all real key presses or clicks). Says a waiting
-- greeting now, or greets your friendly player target on demand (no chance roll; the
-- 10-minute per-player greeting cooldown still applies).
function Engine:GreetNow()
    if not MonologueDB or not MonologueCharDB then return false end
    -- Any waiting line goes first: a greeting, an emote reply, or a duel/PvP reaction
    if self:HasPendingLine() then
        return self:FlushPendingSpeech("slash")
    end
    if not UnitExists("target") or not UnitIsPlayer("target") or UnitIsUnit("target", "player")
        or not UnitIsFriend("player", "target") then
        Print("Target a friendly player to greet them.")
        return false
    end
    local who = Clean(UnitGUID("target")) or UnitNameAndRealm("target")
    local name = GetFullPlayerName("target") or "them"
    local greeted = self.State.GreetedAt
    if who and greeted[who] and GetTime() - greeted[who] < GUILD_GREET_COOLDOWN then
        Print("You greeted " .. name .. " a moment ago.")
        return false
    end
    local categoryKey, pool = self:PickGreeting("target")
    if not pool then
        Print("No greeting lines fit " .. name .. " (add a friend note, a stance or race greetings).")
        return false
    end
    local line = self:GetShuffledLine(categoryKey, pool)
    if not line then return false end
    -- A deliberate greeting: don't make the player wait out the automatic breath lock
    self.Cooldowns.GlobalBreath = 0
    self.State.OathMoment = "Greet"
    self.State.ExplicitLine = true
    local targetName = ShortName(UnitName("target"))
    self.State.CommOnSay = self:CommFor("G", targetName, "target")
    local okSpeak, ok = pcall(self.Speak, self, line, "SAY", "target", { key = "Greet_Manual", duration = 2 }, nil, true)
    self.State.CommOnSay = nil
    self.State.OathMoment = nil
    self.State.ExplicitLine = nil
    ok = okSpeak and ok
    if ok and who then greeted[who] = GetTime() end
    if ok then self:NoteGreeted(targetName) end
    return ok
end

---------------------------------------------------------------------------
-- Emote replies: someone waves, bows, cheers, ... at you, and your character answers.
-- The emote arrives as a chat event (not a key press), so the reply waits like a greeting:
-- said on your next ability press or Greet click, dropped after GREETING_MAX_AGE seconds.
-- Lines: ActiveProfile.EmoteReplies[<kind>] (race pack or profile), else the defaults below.
-- Tokens: {target} is the player who emoted at you.
---------------------------------------------------------------------------

local EMOTE_REPLY_CHANCE = 0.75     -- scaled by chattiness
local EMOTE_REPLY_COOLDOWN = 180    -- seconds before replying to the same player again

-- Phrases from the English emote text aimed at you -> reply kind
local EMOTE_REPLY_PATTERNS = {
    { kind = "Wave", phrases = { "waves at you", "waves to you", "greets you", "hails you",
                                  "says hello to you", "welcomes you" } },
    { kind = "Bow", phrases = { "bows before you", "bows to you", "kneels before you", "curtsies before you" } },
    { kind = "Cheer", phrases = { "cheers at you", "cheers for you", "applauds you", "claps for you" } },
    { kind = "Salute", phrases = { "salutes you" } },
    { kind = "Thank", phrases = { "thanks you" } },
    { kind = "Hug", phrases = { "hugs you" } },
    { kind = "Toast", phrases = { "toast to you", "toasts you", "raises a drink to you" } },
    { kind = "Laugh", phrases = { "laughs at you" } },
    { kind = "Challenge", phrases = { "flexes at you", "roars at you", "challenges you" } },
    { kind = "Rude", phrases = { "rude gesture at you", "spits on you", "insults you", "taunts you",
                                  "threatens you", "points at you and laughs" } },
}

local EMOTE_REPLY_DEFAULTS = {
    Wave = { "Hail, {target}!", "{target}! Well met!", "Ho there, {target}!", "And good day to you, {target}!" },
    Bow = { "Rise, {target}. No need for that.", "Ha! A bow, {target}? I'm flattered.", "And to you, {target}." },
    Cheer = { "Ha! Aye, {target}!", "That's the spirit, {target}!", "Huzzah, {target}!" },
    Salute = { "And a salute to you, {target}!", "At ease, {target}.", "Honored, {target}." },
    Thank = { "Think nothing of it, {target}.", "Anytime, {target}!", "My pleasure, {target}." },
    Hug = { "Ha! Easy on the ribs, {target}!", "Good to see you too, {target}!", "Alright, alright, {target}. I missed you too." },
    Toast = { "To your health, {target}!", "Cheers, {target}!", "Bottoms up, {target}!" },
    Laugh = { "Something funny, {target}?", "Laugh it up, {target}.", "Glad I amuse you, {target}." },
    Challenge = { "Is that a challenge, {target}?", "Careful, {target}. I bite back.", "Ha! You'll need more than that, {target}." },
    Rude = { "Watch yourself, {target}.", "Mind your manners, {target}.", "Say that to my face, {target}." },
}

function Engine:HandleTextEmote(text, sender, guid)
    text, sender, guid = Clean(text), Clean(sender), Clean(guid)
    if type(text) ~= "string" or type(sender) ~= "string" then return end
    if not MonologueDB.emoteReplies then return end
    if guid and not IsPlayerGUID(guid) then return end
    if UnitAffectingCombat("player") then return end

    local name = StripRealm(sender)
    if not name or name == "" or name == Clean(UnitName("player")) then return end

    local lowered = text:lower()
    local kind
    for _, entry in ipairs(EMOTE_REPLY_PATTERNS) do
        for _, phrase in ipairs(entry.phrases) do
            if lowered:find(phrase, 1, true) then kind = entry.kind break end
        end
        if kind then break end
    end
    if not kind then return end

    local who = guid or NormalizeNameKey(name)
    local now = GetTime()
    local replied = self.State.EmoteRepliedAt
    for key, at in pairs(replied) do
        if now - at > EMOTE_REPLY_COOLDOWN then replied[key] = nil end
    end
    if replied[who] and now - replied[who] < EMOTE_REPLY_COOLDOWN then
        self:Debug("emote reply skipped: answered " .. name .. " a moment ago")
        return
    end

    local replies = self.ActiveProfile.EmoteReplies
    local pool = type(replies) == "table" and UsablePool(replies[kind]) and replies[kind] or EMOTE_REPLY_DEFAULTS[kind]
    self:Debug("emote at you: " .. name .. " (" .. kind .. ")")

    self.State.SpeakKind = "greeting"
    self.State.TokenTargetName = name
    local spoke = self:ProcessTrigger(5, "EmoteReply_" .. kind, pool, EMOTE_REPLY_CHANCE, nil)
    self.State.SpeakKind = nil
    self.State.TokenTargetName = nil
    if spoke then
        replied[who] = now
        -- Counts as greeting them: targeting them right after won't add a second hello
        if guid then self.State.GreetedAt[guid] = now end
    end
end

-- Battle cry: a manual, player-triggered line (/mono cry or the HUD button). Because it
-- runs from a slash command or a button click it is a hardware event, so it may use
-- SAY/YELL directly in the open world instead of the automated EMOTE reroute.
-- Draws from ActiveProfile.BattleCry, else SpellReactions.Tier1_MajorCD. It deliberately
-- skips the cooldowns, stealth and AFK gates that govern automatic speech, but still
-- translates the line, resolves tokens, honours encounter safe-mode (printed locally),
-- throttles repeats, and starts the global breath lock so automatic lines don't pile on.
function Engine:BattleCry(channelOverride)
    if not MonologueDB or not MonologueCharDB then return false, "not ready" end

    local now = GetTime()
    if now - (self.State.LastCryTime or 0) < CRY_THROTTLE then return false, "throttled" end

    local profile = self.ActiveProfile
    local poolKey, pool = "BattleCry", profile.BattleCry
    if not UsablePool(pool) then
        local reactions = type(profile.SpellReactions) == "table" and profile.SpellReactions or nil
        poolKey, pool = "BattleCry_Tier1", reactions and reactions.Tier1_MajorCD
    end
    if not UsablePool(pool) then
        Print("No battle cry lines available: add a BattleCry pool or Tier1_MajorCD lines.")
        return false, "no lines"
    end

    local chatType = channelOverride or MonologueDB.battleCryChannel
    if chatType ~= "SAY" and chatType ~= "YELL" then chatType = "YELL" end

    local text = self:GetShuffledLine(poolKey, pool)
    if not text then return false, "no lines" end

    if MonologueTranslator and MonologueTranslator.Translate then
        local intensity = MonologueTranslator.GetChannelIntensity
            and MonologueTranslator:GetChannelIntensity(chatType) or (MonologueDB.translationIntensity or 0)
        self.State.OathMoment = "Cry"
        local ok, translated = pcall(MonologueTranslator.Translate, MonologueTranslator, text, intensity)
        self.State.OathMoment = nil
        if ok and type(translated) == "string" then text = translated end
    end

    if MonologueRPBridge and MonologueRPBridge.ProcessTokens then
        local targetUnit = UnitExists("target") and UnitCanAttack("player", "target") and "target" or nil
        local ok, processed = pcall(MonologueRPBridge.ProcessTokens, MonologueRPBridge, text, targetUnit)
        if ok and type(processed) == "string" then text = processed end
    end

    text = SanitizeLine(text)
    if text == "" then return false, "empty" end

    self.State.LastCryTime = now
    self.Cooldowns.GlobalBreath = math.max(self.Cooldowns.GlobalBreath, now + (MonologueDB.globalBreath or 45))
    self.State.LastSpeechTime = now

    if self:GetChatBlock() == "safemode" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff[Monologue Safe-Mode]:|r " .. TruncateChat(text))
        return true, "safemode"
    end

    -- Manual cries are hardware events, so they are attempted even during a chat lockdown
    local sent, problem = self:TrySend(TruncateChat(text), chatType, true)
    if not sent then
        Print("The client refused the battle cry (" .. tostring(problem) .. ").")
        return false, "send failed"
    end
    return true
end

---------------------------------------------------------------------------
-- Situations: lines that react to the moment
-- When a pull or signature line is about to be said, it may instead use a line written for
-- what is happening right now: what you're fighting (undead, a rare elite, murlocs, the
-- Defias), your own state (low mana, hurt, drunk, swimming, night, in a dungeon) or what
-- just happened (the mob that killed you, the first fight after dying or levelling, the
-- tenth kobold in a row). Lines live in Data.Situations[key] (situations/Situations.lua);
-- a race, class, persona or profile may add its own with Situations = { Undead = {...} }.
-- MonologueDB.situationChance (Voice Lines tab slider, 0-100) sets how often this happens.
-- Memory situations (Revenge, AfterDeath, AfterLevelUp, GrindStreak) are rarer, so they
-- get twice that chance and win over everything else.
---------------------------------------------------------------------------

Tune.SITUATION_DEATH_WINDOW = 600    -- AfterDeath: first lines within 10 min of dying
Tune.SITUATION_REVENGE_WINDOW = 1800 -- Revenge: the creature that killed you, within 30 min
Tune.SITUATION_LEVEL_WINDOW = 300    -- AfterLevelUp: within 5 min of the ding
-- Everyday moments (situations/Moments.lua): chance per moment and seconds before it repeats
Tune.MOMENTS = {
    EatDrink = { chance = 0.25, cooldown = 600 },
    Mount = { chance = 0.15, cooldown = 900 },
    Rest = { chance = 0.40, cooldown = 1800 },
    AllyDown = { chance = 0.50, cooldown = 120 },
    NpcYell = { chance = 0.35, cooldown = 300 },
    FlightMaster = { chance = 0.30, cooldown = 1200 },
    Mailbox = { chance = 0.15, cooldown = 1800 },
    Trainer = { chance = 0.40, cooldown = 1800 },
    QuestDone = { chance = 0.12, cooldown = 600 },
}
Tune.MAX_COMBAT_LINES = 2           -- repeat guard: fight lines (pull, signature, big cooldown) per fight
Tune.SAME_TARGET_GAP = 600           -- repeat guard: seconds before the same creature/player gets another pull line
Tune.SPEECH_HURT_FRACTION = 0.35    -- speech effects: shaky below this much health in a fight
Tune.SITUATION_DRUNK_WINDOW = 900    -- Drunk: 15 min after the last "You feel drunk" (or until sober)
Tune.GRIND_STREAK_START = 5          -- GrindStreak: the 5th pull of one creature in this zone...
Tune.GRIND_STREAK_STEP = 5           -- ...then every 5 more

local MEMORY_SITUATIONS = { Revenge = true, AfterDeath = true, AfterLevelUp = true, GrindStreak = true }

-- Creature groups recognised by name (English client). First match wins.
local SITUATION_NAME_KEYS = {
    { "%f[%a]murloc", "Murloc" }, { "%f[%a]kobold", "Kobold" }, { "%f[%a]gnoll", "Gnoll" },
    { "%f[%a]trogg", "Trogg" }, { "%f[%a]ogre", "Ogre" }, { "%f[%a]harp[yi]", "Harpy" },
    { "%f[%a]centaur", "Centaur" }, { "%f[%a]quilboar", "Quilboar" }, { "%f[%a]razorfen", "Quilboar" },
    { "%f[%a]naga%f[%A]", "Naga" }, { "%f[%a]satyr", "Satyr" },
    { "%f[%a]defias", "Defias" }, { "%f[%a]scarlet", "Scarlet" }, { "%f[%a]syndicate", "Syndicate" },
    { "%f[%a]dark iron", "DarkIron" }, { "%f[%a]bloodsail", "Bloodsail" }, { "%f[%a]venture co", "Venture" },
    -- Used by allegiance foe lines (Azeroth Identity); no shared pools
    { "%f[%a]stormwind", "Stormwind" }, { "%f[%a]booty bay", "BootyBay" }, { "%f[%a]kul tiras", "KulTiras" },
}
local SITUATION_FAMILIES = { Spider = true, Raptor = true, Wolf = true, Bear = true, Crocolisk = true }
local SITUATION_TYPES = {
    Undead = true, Demon = true, Dragonkin = true, Elemental = true, Giant = true, Mechanical = true, Beast = true,
}

-- Specificity weights: a rare or a murloc is more worth remarking on than "it's a beast"
local W_RARE, W_NAMED, W_TYPE, W_STATE, W_PLACE = 4, 3, 2, 1.5, 1

-- Situation memory (killer, deaths, level-ups, drunk, grind streaks). Kept in State.Memory,
-- NOT State.Recent: that table belongs to PvP engagement tracking ([guid] = entry).
function Engine:GetRecent()
    local memory = self.State.Memory
    if type(memory) ~= "table" then
        memory = {}
        self.State.Memory = memory
    end
    if type(memory.streakSaid) ~= "table" then memory.streakSaid = {} end
    return memory
end

function Engine:GetSituationChance()
    return (tonumber(MonologueDB and MonologueDB.situationChance) or 40) / 100
end

-- Usable pool for a situation key: the active profile's own first, then the shared one
-- Returns pool, deckKey. An allegiance's foe lines (Azeroth Identity) win most of the time.
function Engine:GetSituationPool(key)
    local tauntRace, tauntFaction = tostring(key):match("^Taunt_(%a+)_(%a+)$")
    if tauntRace then return self:GetTauntPool(tauntRace, tauntFaction) end
    local own = self.ActiveProfile.Situations
    local pool = type(own) == "table" and own[key] or nil
    if not UsablePool(pool) then pool = self.Data.Situations[key] end
    if not UsablePool(pool) then pool = nil end
    local hostile, hostileDeck = self:GetAllegianceHostilePool(key)
    if hostile and (not pool or math.random() < Tune.ALLEGIANCE_HOSTILE_SHARE) then
        return hostile, hostileDeck
    end
    if pool then return pool, "Sit_" .. key end
    return nil
end

-- "Vs_Rogue" for an enemy player of that class
local function VsClassKey(unit)
    if not (unit and UnitExists(unit) and UnitIsPlayer(unit)) then return nil end
    local _, classFile = UnitClass(unit)
    classFile = Clean(classFile)
    if type(classFile) ~= "string" or classFile == "" then return nil end
    return "Vs_" .. classFile:sub(1, 1) .. classFile:sub(2):lower()
end

-- "VsRace_Scourge", "VsAlliance" for an enemy player (allegiance foe lines)
local function PlayerFoeKeys(unit)
    local keys = {}
    local _, raceFile = UnitRace(unit)
    raceFile = Clean(raceFile)
    if type(raceFile) == "string" and raceFile ~= "" then keys[#keys + 1] = "VsRace_" .. raceFile end
    local faction = Clean(UnitFactionGroup(unit))
    if faction == "Alliance" or faction == "Horde" then keys[#keys + 1] = "Vs" .. faction end
    return keys
end

-- A hostile creature's name, or nil
local function MobName(unit)
    if not (unit and UnitExists(unit)) or UnitIsPlayer(unit) or not UnitCanAttack("player", unit) then return nil end
    local name = Clean(UnitName(unit))
    if type(name) ~= "string" or name == "" then return nil end
    return name
end

---------------------------------------------------------------------------
-- Live-detail tokens: Engine.DetailTokens[name](unit) returns the value or nil when it isn't
-- known right now. The RP bridge fills {name} with it, and GetShuffledLine skips a line whose
-- detail tokens can't be filled (no {weapon} lines while unarmed, no {party} lines solo).
-- unit is the line's target unit ("target" by default). /mono tokens shows them all.
---------------------------------------------------------------------------

local function ItemName(slot)
    if type(GetInventoryItemLink) ~= "function" then return nil end
    local link = Clean(GetInventoryItemLink("player", slot))
    local name = type(link) == "string" and link:match("%[(.-)%]") or nil
    if name and name ~= "" then return name end
    return nil
end

local CREATURE_TYPE_SKIP = { humanoid = true, ["not specified"] = true, critter = true }
local function MobType(unit)
    if not MobName(unit) then return nil end
    local creatureType = Clean(UnitCreatureType(unit))
    if type(creatureType) ~= "string" then return nil end
    creatureType = creatureType:lower()
    if CREATURE_TYPE_SKIP[creatureType] then return nil end
    return creatureType
end

local GROUP_WORDS = { [2] = "the two of us", [3] = "the three of us", [4] = "the four of us", [5] = "the five of us" }

Engine.DetailTokens = {
    mobtype = function(unit) return MobType(unit) end,
    amobtype = function(unit)
        local creatureType = MobType(unit)
        if not creatureType then return nil end
        return (creatureType:find("^[aeiou]") and "an " or "a ") .. creatureType
    end,
    family = function(unit)
        if not MobName(unit) then return nil end
        local family = Clean(UnitCreatureFamily(unit))
        return type(family) == "string" and family ~= "" and family:lower() or nil
    end,
    targetclass = function(unit)
        if not (unit and UnitExists(unit) and UnitIsPlayer(unit) and UnitCanAttack("player", unit)) then return nil end
        local className = Clean(UnitClass(unit))
        return type(className) == "string" and className:lower() or nil
    end,
    levelgap = function(unit)
        if not (unit and UnitExists(unit) and UnitCanAttack("player", unit)) then return nil end
        local theirs, mine = Clean(UnitLevel(unit)), Clean(UnitLevel("player"))
        if type(theirs) ~= "number" or type(mine) ~= "number" then return nil end
        if theirs == -1 then return "far above my level" end
        local gap = theirs - mine
        if gap >= 5 then return "far above my level" end
        if gap >= 2 then return "a few levels above me" end
        if gap <= -10 then return "well below my level" end
        return nil
    end,
    weapon = function() return ItemName(16) end,
    offhand = function() return ItemName(17) end,
    spell = function() return Engine.State.CurrentSpell end,
    resource = function()
        local powerType = Clean(UnitPowerType("player"))
        return (powerType == 0 and "mana") or (powerType == 1 and "rage") or (powerType == 3 and "energy") or nil
    end,
    myhp = function()
        local hp, maxHp = Clean(UnitHealth("player")), Clean(UnitHealthMax("player"))
        if type(hp) ~= "number" or type(maxHp) ~= "number" or maxHp <= 0 then return nil end
        local ratio = hp / maxHp
        if ratio < 0.25 then return "barely standing" end
        if ratio < 0.5 then return "bleeding" end
        if ratio < 0.8 then return "a bit scratched" end
        return nil
    end,
    party = function()
        if not (IsInGroup and IsInGroup()) then return nil end
        local names = {}
        local prefix, count = "party", 4
        if IsInRaid and IsInRaid() then prefix, count = "raid", 40 end
        for i = 1, count do
            local unit = prefix .. i
            if UnitExists(unit) and not UnitIsUnit(unit, "player") then
                local name = GetFullPlayerName(unit)
                if name then names[#names + 1] = name end
            end
        end
        if #names == 0 then return nil end
        -- The same name for a few seconds, so one line never names two different people
        local pick = Engine.State.PartyTokenPick
        if not (pick and GetTime() - pick.at < 5 and tContains and tContains(names, pick.name)) then
            pick = { name = names[math.random(#names)], at = GetTime() }
            Engine.State.PartyTokenPick = pick
        end
        return pick.name
    end,
    groupsize = function()
        if not (IsInGroup and IsInGroup()) then return nil end
        local count = Clean(GetNumGroupMembers and GetNumGroupMembers())
        if type(count) ~= "number" or count < 2 then return nil end
        return GROUP_WORDS[count] or string.format("all %d of us", count)
    end,
}

-- Every detail token in the line can be filled right now (other tokens always can)
function Engine:LineDetailsAvailable(line, unit)
    if type(line) ~= "string" or not line:find("{", 1, true) then return true end
    unit = unit or "target"
    for name in line:gmatch("{(%w+)}") do
        local resolver = self.DetailTokens[name]
        if resolver then
            local ok, value = pcall(resolver, unit)
            if not ok or value == nil then return false end
        end
    end
    return true
end

function Engine:AnyLineAvailable(pool)
    for _, line in ipairs(pool) do
        if self:LineDetailsAvailable(line) then return true end
    end
    return false
end

function Engine:DescribeDetailTokens()
    local names = {}
    for name in pairs(self.DetailTokens) do names[#names + 1] = name end
    table.sort(names)
    local parts = {}
    for _, name in ipairs(names) do
        local ok, value = pcall(self.DetailTokens[name], "target")
        parts[#parts + 1] = "{" .. name .. "} = " .. ((ok and value) and ("|cff00ff00" .. tostring(value) .. "|r") or "|cff888888unavailable|r")
    end
    return table.concat(parts, "  ")
end

-- Counts pulls of each creature by name for GrindStreak (reset when you change zone)
function Engine:CountMobPull()
    local name = MobName("target")
    if not name then return end
    self.State.LastMobName = name
    local zone = Clean(GetRealZoneText()) or ""
    local counts = self.State.MobCounts
    if type(counts) ~= "table" or counts.zone ~= zone then
        counts = { zone = zone, names = {} }
        self.State.MobCounts = counts
        wipe(self:GetRecent().streakSaid)
    end
    counts.names[name] = (counts.names[name] or 0) + 1
end

-- How many of this creature you've pulled here, counting the pull now starting
function Engine:GetMobStreak(name)
    local counts = self.State.MobCounts
    local zone = Clean(GetRealZoneText()) or ""
    local n = (type(counts) == "table" and counts.zone == zone and counts.names[name]) or 0
    -- An opening cast speaks just before PLAYER_REGEN_DISABLED counts the pull
    if not UnitAffectingCombat("player") then n = n + 1 end
    return n
end

-- "You feel tipsy/drunk/completely smashed" and "You feel sober again" (system messages)
local DRUNK_FALLBACKS = { "You feel tipsy.", "You feel drunk.", "You feel completely smashed." }
function Engine:NoteDrunkMessage(message)
    local sober = Clean(DRUNK_MESSAGE_SELF1) or "You feel sober again."
    if message == sober then
        self:GetRecent().drunkAt = nil
        self:GetRecent().drunkLevel = nil
        return true
    end
    for i = 2, 4 do
        local text = Clean(_G["DRUNK_MESSAGE_SELF" .. i]) or DRUNK_FALLBACKS[i - 1]
        if message == text then
            self:GetRecent().drunkAt = GetTime()
            self:GetRecent().drunkLevel = i - 1   -- 1 tipsy, 2 drunk, 3 completely smashed
            return true
        end
    end
    return false
end

-- Rough grey-level cutoff (Classic): creatures at or below this give no experience
local function GreyLevel(playerLevel)
    if playerLevel <= 5 then return 0 end
    if playerLevel <= 39 then return playerLevel - math.floor(playerLevel / 10) - 5 end
    return playerLevel - math.floor(playerLevel / 5) - 1
end

local function Fraction(current, maximum)
    current, maximum = Clean(current), Clean(maximum)
    if type(current) ~= "number" or type(maximum) ~= "number" or maximum <= 0 then return nil end
    return current / maximum
end

-- For the translator's speech effects: drunk = 0 (sober) to 3 (completely smashed), hurt =
-- below Tune.SPEECH_HURT_FRACTION health in a fight
function Engine:GetSpeechState()
    local state = { drunk = 0, hurt = false }
    local recent = self:GetRecent()
    if recent.drunkAt and GetTime() - recent.drunkAt <= Tune.SITUATION_DRUNK_WINDOW then
        state.drunk = recent.drunkLevel or 1
    end
    if UnitAffectingCombat("player") then
        local fraction = Fraction(UnitHealth("player"), UnitHealthMax("player"))
        state.hurt = fraction ~= nil and fraction > 0 and fraction < Tune.SPEECH_HURT_FRACTION
    end
    return state
end

-- Every situation that applies right now, most specific first:
--   list = { { key = "Undead", weight = 2 }, ... }, tokens = { mob, count, killer }
-- Anything the client hides (12.x secret values) is simply skipped.
function Engine:GetSituations(unit)
    local list, tokens = {}, {}
    local function add(key, weight) list[#list + 1] = { key = key, weight = weight } end
    local now, recent = GetTime(), self:GetRecent()
    local mob = MobName(unit)
    tokens.mob = mob

    -- Memory of recent events
    if mob and recent.killer == mob and recent.diedAt and now - recent.diedAt <= Tune.SITUATION_REVENGE_WINDOW then
        add("Revenge", 0)
    end
    if mob then
        local streak = self:GetMobStreak(mob)
        if streak >= Tune.GRIND_STREAK_START and streak - (recent.streakSaid[mob] or 0) >= Tune.GRIND_STREAK_STEP then
            add("GrindStreak", 0)
            tokens.count = tostring(streak)
        end
    end
    if recent.diedAt and not recent.deathUsed and now - recent.diedAt <= Tune.SITUATION_DEATH_WINDOW then
        add("AfterDeath", 0)
    end
    if recent.levelAt and not recent.levelUsed and now - recent.levelAt <= Tune.SITUATION_LEVEL_WINDOW then
        add("AfterLevelUp", 0)
    end
    if type(recent.killer) == "string" then tokens.killer = recent.killer end

    -- What you're fighting
    if mob then
        local rank = Clean(UnitClassification(unit))
        local level = Clean(UnitLevel(unit))
        local myLevel = Clean(UnitLevel("player"))
        if rank == "worldboss" or level == -1 then
            add("WorldBoss", W_RARE)
        elseif rank == "rareelite" then
            add("RareElite", W_RARE)
        elseif rank == "rare" then
            add("Rare", W_RARE)
        end

        local lower = mob:lower()
        for _, entry in ipairs(SITUATION_NAME_KEYS) do
            if lower:find(entry[1]) then
                add(entry[2], W_NAMED)
                break
            end
        end
        local family = Clean(UnitCreatureFamily(unit))
        if type(family) == "string" and SITUATION_FAMILIES[family] then add(family, W_NAMED) end
        if rank == "elite" then add("Elite", W_TYPE) end
        local creatureType = Clean(UnitCreatureType(unit))
        if type(creatureType) == "string" and SITUATION_TYPES[creatureType] then add(creatureType, W_TYPE) end

        if type(level) == "number" and type(myLevel) == "number" and level > 0 then
            if level - myLevel >= 3 then
                add("Outlevelled", W_TYPE)
            elseif level <= GreyLevel(myLevel) then
                add("Trivial", W_TYPE)
            end
        end
    end

    -- Your own state
    local hp = Fraction(UnitHealth("player"), UnitHealthMax("player"))
    if hp and hp < 0.35 then add("Hurt", W_STATE) end
    if Clean(UnitPowerType("player")) == 0 then
        local mana = Fraction(UnitPower("player", 0), UnitPowerMax("player", 0))
        if mana and mana < 0.15 then add("LowMana", W_STATE) end
    end
    if recent.drunkAt and now - recent.drunkAt <= Tune.SITUATION_DRUNK_WINDOW then add("Drunk", W_STATE) end
    if IsSwimming and Clean(IsSwimming()) then add("Swimming", W_STATE) end

    -- Where and when
    local _, instanceType = IsInInstance()
    if Clean(instanceType) == "party" then add("Dungeon", W_PLACE) end
    local hour = Clean((GetGameTime()))
    if type(hour) == "number" and (hour >= 21 or hour < 5) then add("Night", W_PLACE) end

    -- Enemy players: their class, race and faction (the last two for allegiance foe lines)
    local classKey = VsClassKey(unit)
    if classKey and UnitCanAttack("player", unit) then
        add(classKey, W_NAMED)
        for _, key in ipairs(PlayerFoeKeys(unit)) do add(key, W_NAMED) end
        local tauntKey = self:TauntKey(unit)
        if tauntKey then add(tauntKey, W_NAMED) end
    end

    return list, tokens
end

-- Rolls the "react to the world" chance and picks a situation with lines.
-- Returns key, pool, tokens, deckKey or nil.
-- memoryOnly: consider only the memory situations (revenge, grind streak, after death or
-- level-up), which may interrupt even a pull that leads with the spell's own line
function Engine:PickSituation(unit, memoryOnly)
    local chance = self:GetSituationChance()
    if chance <= 0 then return nil end
    local roll = math.random()
    if roll >= math.min(1, chance * 2) then return nil end

    local list, tokens = self:GetSituations(unit)
    local candidates, total = {}, 0
    for _, s in ipairs(list) do
        local pool, deck = self:GetSituationPool(s.key)
        if pool then
            if MEMORY_SITUATIONS[s.key] then return s.key, pool, tokens, deck end
            if not memoryOnly and roll < chance then
                candidates[#candidates + 1] = { key = s.key, pool = pool, weight = s.weight, deck = deck }
                total = total + s.weight
            end
        end
    end
    if #candidates == 0 then return nil end

    -- Don't remark on the same thing twice in a row when there's anything else to say
    if #candidates > 1 then
        for i, c in ipairs(candidates) do
            if c.key == self.State.LastSituationKey then
                total = total - c.weight
                table.remove(candidates, i)
                break
            end
        end
    end
    local pick = math.random() * total
    for _, c in ipairs(candidates) do
        pick = pick - c.weight
        if pick <= 0 then return c.key, c.pool, tokens, c.deck end
    end
    local last = candidates[#candidates]
    return last.key, last.pool, tokens, last.deck
end

-- A memory situation is used up once it has been said
function Engine:MarkSituationUsed(key, tokens)
    self.State.LastSituationKey = key
    local recent = self:GetRecent()
    if key == "Revenge" then
        recent.killer = nil
        recent.deathUsed = true
    elseif key == "AfterDeath" then
        recent.deathUsed = true
    elseif key == "AfterLevelUp" then
        recent.levelUsed = true
    elseif key == "GrindStreak" and tokens and tokens.mob then
        recent.streakSaid[tokens.mob] = tonumber(tokens.count) or 0
    end
end

-- "Night, Undead, LowMana" (for /mono situations and the Right Now panel). withMissing marks
-- situations that have no lines yet.
function Engine:DescribeSituations(unit, withMissing)
    local list = self:GetSituations(unit)
    if #list == 0 then return "none" end
    local parts = {}
    for _, s in ipairs(list) do
        local text = s.key
        if withMissing and not self:GetSituationPool(s.key) then text = text .. " |cff888888(no lines)|r" end
        parts[#parts + 1] = text
    end
    return table.concat(parts, ", ")
end

---------------------------------------------------------------------------
-- Score-aware rivalry, duel banter and party nemesis warnings (identity/Rivalry.lua)
-- Built on the existing ledgers: Rivals (kills = you killed them, deaths = they killed you,
-- lastZone) and Duels (wins, losses, lastZone). Tokens for these lines come from the
-- targeted player's record, or from State.ScoreTokens while a line about someone who isn't
-- your target is spoken (a spotted nemesis, a party member's warning).
---------------------------------------------------------------------------

Tune.RIVAL_SCORE_SHARE = 0.5      -- rival target lines and call-outs that use the score pools
Tune.NEMESIS_SPOT_COOLDOWN = 300  -- per enemy: one warning every 5 minutes
Tune.NEMESIS_BACKUP_CHANCE = 0.4
Tune.NEMESIS_BACKUP_COOLDOWN = 60
local NEMESIS_SPOT_TIERS = { Nemesis = true, Vendetta = true, Dominance = true }

-- A real recorded zone, or nil ("the wild" is the ledger's placeholder)
local function RecordedZone(zone)
    if type(zone) ~= "string" or zone == "" or zone == "the wild" then return nil end
    return zone
end
Engine.RecordedZone = RecordedZone

-- The pool without lines that use {lastzone} when no zone is known; returns pool, deckSuffix
local function ZoneSafePool(pool, hasZone)
    if hasZone or not UsablePool(pool) then return pool, "" end
    local out = {}
    for _, line in ipairs(pool) do
        if not line:lower():find("{lastzone}", 1, true) then out[#out + 1] = line end
    end
    return out, "_NoZone"
end

local function ScoreTier(mine, theirs)
    if mine > theirs then return "Ahead" end
    if theirs > mine then return "Behind" end
    return "Tied"
end

-- pool, deckKey, tier for a rival with at least one recorded fight (else nil)
function Engine:GetRivalScorePool(rival)
    if type(rival) ~= "table" then return nil end
    local kills, deaths = rival.kills or 0, rival.deaths or 0
    if kills + deaths == 0 then return nil end
    local tier = ScoreTier(kills, deaths)
    local pools = self.Data.RivalScore
    local pool, suffix = ZoneSafePool(type(pools) == "table" and pools[tier], RecordedZone(rival.lastZone) ~= nil)
    if not UsablePool(pool) then return nil end
    return pool, "RivalScore_" .. tier .. suffix, tier
end

-- The duel record for a player name, when you have duelled them at least once
function Engine:GetDuelRecord(name)
    local duels = MonologueCharDB and MonologueCharDB.Duels
    if type(duels) ~= "table" or type(name) ~= "string" then return nil end
    local duel = duels[NormalizeNameKey(StripRealm(name) or name)]
    if type(duel) == "table" and ((duel.wins or 0) + (duel.losses or 0)) > 0 then return duel end
    return nil
end

function Engine:GetDuelBanterPool(duel)
    if type(duel) ~= "table" then return nil end
    local tier = ScoreTier(duel.wins or 0, duel.losses or 0)
    local pools = self.Data.DuelBanter
    local pool, suffix = ZoneSafePool(type(pools) == "table" and pools[tier], RecordedZone(duel.lastZone) ~= nil)
    if not UsablePool(pool) then return nil end
    return pool, "DuelBanter_" .. tier .. suffix, tier
end

-- A sworn enemy targeted or moused over while you're grouped: warn the party (once per enemy
-- every 5 minutes) and tell party members with Monologue (N^name on MONO_RP)
function Engine:CheckNemesisSpot(unit)
    if not (IsInGroup and IsInGroup()) then return end
    if not IsHostilePlayer(unit) or UnitIsDeadOrGhost(unit) then return end
    local name = GetFullPlayerName(unit) or UnitNameAndRealm(unit)
    local rival = name and self:GetRival(name)
    if not rival or not NEMESIS_SPOT_TIERS[self:GetRivalRecordTier(rival) or ""] then return end
    local key = NormalizeNameKey(StripRealm(name) or name)
    self.State.NemesisSpotAt = self.State.NemesisSpotAt or {}
    local now = GetTime()
    if now - (self.State.NemesisSpotAt[key] or -math.huge) < Tune.NEMESIS_SPOT_COOLDOWN then return end
    self.State.NemesisSpotAt[key] = now

    local display = rival.name or name
    self:SendComm("N^" .. (display:gsub("%^", "")))
    local zone = RecordedZone(rival.lastZone)
    local pool, suffix = ZoneSafePool(self.Data.NemesisSpot, zone ~= nil)
    self:Debug("party: nemesis spotted, " .. display)
    self.State.ScoreTokens = { lastzone = zone, kills = rival.kills, deaths = rival.deaths }
    self:SayPartyLine("NemesisSpot" .. suffix, pool, 1, display)
    self.State.ScoreTokens = nil
end

-- A party member with Monologue spotted their nemesis: maybe back them up
function Engine:HandleNemesisSpotted(ally, rivalName)
    if type(rivalName) ~= "string" or rivalName == "" then return end
    local now = GetTime()
    if now - (self.State.NemesisBackupAt or -math.huge) < Tune.NEMESIS_BACKUP_COOLDOWN then return end
    self:Debug("party: " .. ally .. " spotted their nemesis " .. rivalName)
    self.State.ScoreTokens = { rival = rivalName }
    local spoke = self:SayPartyLine("NemesisBackup", self.Data.NemesisBackup, Tune.NEMESIS_BACKUP_CHANCE, ally)
    self.State.ScoreTokens = nil
    if spoke then self.State.NemesisBackupAt = now end
end

local ZONE_LINE_CHANCE = 0.5

-- Lines written for the zone you're in: a profile's or race pack's ZoneLines[zone] first,
-- then the shared zones/Zones.lua. Returns categoryKey, pool or nil.
function Engine:GetZonePool()
    local zone = Clean(GetRealZoneText())
    if type(zone) ~= "string" or zone == "" then return nil end
    local own = self.ActiveProfile.ZoneLines
    local pool = type(own) == "table" and own[zone] or nil
    if not UsablePool(pool) then pool = self.Data.Zones[zone] end
    if UsablePool(pool) then return "Zone_" .. zone, pool end
    return nil
end

---------------------------------------------------------------------------
-- Taunts and race nicknames (My Voice > Enemy Faction; lines in situations/Taunts.lua)
---------------------------------------------------------------------------

-- "CIVIL", "ROUGH", "SAVAGE" or nil (Off) for this character
function Engine:GetTauntLevel()
    local cv = MonologueCharDB and MonologueCharDB.CustomVoice
    local level = type(cv) == "table" and cv.taunts or nil
    return Tune.TAUNT_LEVELS[level] and level or nil
end

-- "Taunt_<raceFile>_<faction>" for an enemy player of the other faction, when taunts are on
function Engine:TauntKey(unit)
    if not self:GetTauntLevel() or not IsHostilePlayer(unit) then return nil end
    local _, race = UnitRace(unit)
    race = Clean(race)
    local faction = Clean(UnitFactionGroup(unit))
    if type(race) ~= "string" or not race:match("^%a+$") then return nil end
    if faction ~= "Alliance" and faction ~= "Horde" then return nil end
    return "Taunt_" .. race .. "_" .. faction
end

-- The taunt pool for a race and faction at this character's level: the faction's lines plus
-- the race's own, with {nick} / {nicks} filled in. Returns pool, deckKey or nil.
function Engine:GetTauntPool(race, faction, levelOverride)
    local level = levelOverride or self:GetTauntLevel()
    local data = self.Data.Taunts
    if not level or type(data) ~= "table" then return nil end
    local cacheKey = level .. "_" .. race .. "_" .. faction
    local cache = self.State.TauntPools
    if type(cache) ~= "table" then
        cache = {}
        self.State.TauntPools = cache
    end
    if cache[cacheKey] == nil then
        local section = data[Tune.TAUNT_LEVELS[level]] or {}
        local nick = type(data.Nicknames) == "table" and data.Nicknames[race] or nil
        local function Cap(word) return (word:gsub("^%l", string.upper)) end
        local pool = {}
        for _, lines in ipairs({ section[faction], section[race] }) do
            for _, line in ipairs(type(lines) == "table" and lines or {}) do
                if nick then
                    line = line:gsub("{Nicks}", Cap(nick.many)):gsub("{Nick}", Cap(nick.one))
                    line = line:gsub("{nicks}", nick.many):gsub("{nick}", nick.one)
                end
                if not line:find("{[Nn]ick") then pool[#pool + 1] = line end
            end
        end
        cache[cacheKey] = #pool > 0 and pool or false
    end
    if not cache[cacheKey] then return nil end
    return cache[cacheKey], "Taunt_" .. cacheKey
end

-- Race words the translator swaps for nicknames ("orcs" -> "green skins"), longest first:
-- { key = "night elves", nick = "pointies" } or, for a word that is the same in singular and
-- plural, { key = "tauren", one = "grass muncher", many = "grass munchers" }. nil when off.
function Engine:GetNicknameSwaps()
    local cv = MonologueCharDB and MonologueCharDB.CustomVoice
    local mode = type(cv) == "table" and cv.nicknames or nil
    if not Tune.NICKNAME_MODES[mode] then return nil end
    local mine = Clean(UnitFactionGroup("player"))
    if mode == "ENEMY" and mine ~= "Alliance" and mine ~= "Horde" then return nil end
    local cacheKey = mode .. "_" .. tostring(mine)
    local cache = self.State.NicknameSwaps
    if type(cache) == "table" and cache.key == cacheKey then return cache.list end
    local list = {}
    local nicknames = type(self.Data.Taunts) == "table" and self.Data.Taunts.Nicknames or {}
    for _, nick in pairs(nicknames) do
        if mode == "ALL" or (nick.faction and nick.faction ~= mine) then
            for word, form in pairs(nick.words or {}) do
                list[#list + 1] = { key = word, one = nick.one, many = nick.many,
                    nick = (form == "one" and nick.one) or (form == "many" and nick.many) or nil }
            end
        end
    end
    table.sort(list, function(a, b)
        if #a.key ~= #b.key then return #a.key > #b.key end
        return a.key < b.key
    end)
    self.State.NicknameSwaps = { key = cacheKey, list = list }
    return list
end

-- Taunt button, keybind and /mono taunt (real clicks or key presses, so /s is allowed):
-- taunts your enemy player target now, at your chosen level (Civil when taunts are Off).
function Engine:TauntNow()
    if not MonologueDB or not MonologueCharDB then return false end
    if not IsHostilePlayer("target") then
        Print("Target an enemy player of the other faction to taunt them.")
        return false
    end
    local now = GetTime()
    if now - (self.State.TauntedAt or -math.huge) < Tune.TAUNT_BUTTON_GAP then return false end
    local _, race = UnitRace("target")
    race = Clean(race)
    local faction = Clean(UnitFactionGroup("target"))
    local pool, deckKey
    if type(race) == "string" and (faction == "Alliance" or faction == "Horde") then
        pool, deckKey = self:GetTauntPool(race, faction, self:GetTauntLevel() or "CIVIL")
    end
    if not pool then
        Print("No taunts fit that target.")
        return false
    end
    local line = self:GetShuffledLine(deckKey, pool)
    if not line then return false end
    self.Cooldowns.GlobalBreath = 0
    self.State.ExplicitLine = true
    local okSpeak, ok = pcall(self.Speak, self, line, "SAY", "target", { key = "Taunt_Manual", duration = 2 }, nil, true)
    self.State.ExplicitLine = nil
    ok = okSpeak and ok
    if ok then self.State.TauntedAt = now end
    return ok
end

function Engine:HandleTargetChanged()
    -- Upgrade any first-name-only friend, rival or duel entry for this player first
    self:RefreshStoredNames("target")

    self:HandleFriendlyTarget()

    -- In combat, keep the engagement record current. This also discards it when the new
    -- target is a creature, pet or guard, so only real players can become rivals.
    if UnitAffectingCombat("player") then
        self:MarkEngaged()
    end

    -- Rival tier lines are for enemy players only
    if not IsHostilePlayer("target") or UnitIsDeadOrGhost("target") then return end

    -- A sworn enemy while grouped: warn the party (once per enemy every 5 minutes)
    pcall(self.CheckNemesisSpot, self, "target")

    if IsInPvPInstance() then return end

    local tName = UnitNameAndRealm("target") -- full name, spaces kept, realm removed
    if not tName then return end

    local tier = self:GetRivalTier(tName)
    local pvpLines = self.ActiveProfile.PvPLines
    if type(pvpLines) ~= "table" then return end

    local pool, categoryKey = pvpLines[tier], "PvP_" .. tier
    if not pool and tier == "DejaVu" then
        pool = pvpLines.FirstClash
    end
    -- First clashes and repeat-zone fights sometimes use a line written for this zone
    if tier == "FirstClash" or tier == "DejaVu" then
        local zoneKey, zonePool = self:GetZonePool()
        if zonePool and (not pool or math.random() < ZONE_LINE_CHANCE) then
            pool, categoryKey = zonePool, zoneKey
        end
    end
    -- Below the grudge tiers, the line may react to the enemy's class instead
    -- (or to their race or faction, with an allegiance that cares)
    if tier == "FirstClash" or tier == "DejaVu" or tier == "Rematch" then
        local options = {}
        local keys = PlayerFoeKeys("target")
        keys[#keys + 1] = VsClassKey("target")
        for _, key in ipairs(keys) do
            local foePool, foeDeck = self:GetSituationPool(key)
            if foePool then options[#options + 1] = { foePool, foeDeck } end
        end
        if #options > 0 and math.random() < self:GetSituationChance() then
            local pick = options[math.random(#options)]
            pool, categoryKey = pick[1], pick[2]
        end
        -- Taunts (My Voice > Enemy Faction), at the meanness you picked
        local tauntKey = self:TauntKey("target")
        if tauntKey and math.random() < Tune.TAUNT_SHARE then
            local tauntPool, tauntDeck = self:GetSituationPool(tauntKey)
            if tauntPool then pool, categoryKey = tauntPool, tauntDeck end
        end
    end
    -- Someone you have a record with: half the time the line reflects the score
    -- (ahead: cocky; behind: bitter; tied: let's settle it)
    local rival = self:GetRival(tName)
    if rival and math.random() < Tune.RIVAL_SCORE_SHARE then
        local scorePool, scoreDeck = self:GetRivalScorePool(rival)
        if scorePool then pool, categoryKey = scorePool, scoreDeck end
    end
    if pool then
        self:ProcessTrigger(3, categoryKey, pool, PVP_CHANCE, "target", PVP_EMOTE_TOKEN)
    end
end

---------------------------------------------------------------------------
-- Combat Reactions
---------------------------------------------------------------------------

function Engine:HandlePlayerHealth()
    local hp = Clean(UnitHealth("player"))
    local maxHp = Clean(UnitHealthMax("player"))
    if not hp or not maxHp or maxHp <= 0 then return end

    local ratio = hp / maxHp
    self:CheckPartyLowHealth(ratio)
    if self.State.LowHealthArmed then
        if ratio > 0 and ratio <= LOW_HP_THRESHOLD and UnitAffectingCombat("player") then
            self.State.LowHealthArmed = false
            local reactions = self.ActiveProfile.SpellReactions
            local classPool = type(reactions) == "table" and reactions.Tier3_LowHP or nil
            local deckKey, pool = self:MoodPool("LowHP")
            if not pool then
                deckKey, pool = self:PickLayeredPool("LowHP", "Spell_Tier3_LowHP", classPool, "low health")
            end
            if pool then
                self.State.OathMoment = "LowHP"
                pcall(self.ProcessTrigger, self, REACTION_TIERS.Tier3_LowHP, deckKey, pool, REACTION_CHANCE.Tier3_LowHP, nil)
                self.State.OathMoment = nil
            end
        end
    elseif ratio >= LOW_HP_REARM then
        self.State.LowHealthArmed = true
    end
end

local function GetSpellNameSafe(spellID)
    if C_Spell and C_Spell.GetSpellName then
        return C_Spell.GetSpellName(spellID)
    end
    return nil
end

-- Checks every SpellTriggers entry of the active profile against the game client.
-- Data may carry an optional SpellNames = { [spellID] = "Spell Name" } table naming
-- the spell each ID is meant to be. Status per entry:
--   "ok"        the client knows the spell (and its name matches SpellNames, if given)
--   "mismatch"  the client's name for that ID differs from SpellNames (wrong ID)
--   "unknown"   the client has no spell with that ID
function Engine:ValidateSpellTriggers()
    local triggers = self.ActiveProfile.SpellTriggers
    local names = self.ActiveProfile.SpellNames
    local report = { total = 0, ok = 0, problems = {} }
    if type(triggers) ~= "table" then return report end

    local ids = {}
    for spellID in pairs(triggers) do ids[#ids + 1] = spellID end
    table.sort(ids)

    for _, spellID in ipairs(ids) do
        report.total = report.total + 1
        local actual = GetSpellNameSafe(spellID)
        local expected = type(names) == "table" and names[spellID] or nil
        if not actual then
            report.problems[#report.problems + 1] = { id = spellID, status = "unknown", expected = expected }
        elseif expected and actual:lower() ~= expected:lower() then
            report.problems[#report.problems + 1] = { id = spellID, status = "mismatch", expected = expected, actual = actual }
        else
            report.ok = report.ok + 1
        end
    end
    return report
end

---------------------------------------------------------------------------
-- Rival openers
-- When you cast at an enemy player already in your rival ledger, the character calls them
-- out by name as they charge in. Lines come from ActiveProfile.RivalOpeners:
--   RivalOpeners[tier]  (tier: Vendetta, Nemesis, ...; Rematch and Dominance use the
--                        "SwornFoe" pool, and "BloodFeud" is accepted as a Nemesis pool),
--   RivalOpeners.Default,
--   then PvPLines[tier].
-- The cast arrives on UNIT_SPELLCAST_SENT, a player action, so the call-out uses the
-- hardware-event SAY (YELL for Nemesis). Each rival is called out at most once per 90s
-- (tier 7 cooldown, keyed per rival), and background speech rules like the 45s breath lock
-- still apply.
---------------------------------------------------------------------------

-- True when the spell is harmful (an attack or a pull); unknown counts as harmful
local function IsOffensiveSpell(spellID)
    local isHarmful = C_Spell and C_Spell.IsSpellHarmful
    if type(isHarmful) ~= "function" then return true end
    local ok, harmful = pcall(isHarmful, spellID)
    if not ok or harmful == nil then return true end
    return Clean(harmful) ~= false
end

local RIVAL_OPENER_TIERS = { BloodFeud = true, Vendetta = true, SwornFoe = true, Nemesis = true }
local RIVAL_OPENER_TIER_POOLS = { Rematch = "SwornFoe", Dominance = "SwornFoe", Nemesis = "BloodFeud" }
local RIVAL_OPENER_MIN_ENCOUNTERS = 2
local RIVAL_OPENER_SPELL_CHANCE = 0.85   -- gap-closer / opener spells
local RIVAL_OPENER_FIRST_CHANCE = 0.50   -- the first spell of the engagement, whatever it is
-- Classic gap-closers and openers, matched by spell name so every rank counts
local RIVAL_OPENER_SPELLS = {
    ["charge"] = true, ["intercept"] = true, ["feral charge"] = true,
    ["cheap shot"] = true, ["ambush"] = true, ["pyroblast"] = true, ["aimed shot"] = true,
}

-- Returns true if a call-out line was spoken
function Engine:TryRivalOpener(spellID, hardware, sigName)
    if not IsHostilePlayer("target") or UnitIsDeadOrGhost("target") or IsInPvPInstance() then return false end
    local guid = Clean(UnitGUID("target"))
    if not IsPlayerGUID(guid) then return false end

    -- Is this the first attack you've made on this player since combat last ended? Buffs,
    -- stances and shouts (Battle Stance, Battle Shout, ...) don't use up the first cast.
    local casts = self.State.EngagementCasts
    local offensive = IsOffensiveSpell(spellID)
    local isFirstCast = offensive and not casts[guid]
    if offensive then casts[guid] = true end

    local fullName = GetFullPlayerName("target")
    local rival, key = self:GetRival(fullName)
    if not rival then return false end

    local tier = self:GetRivalRecordTier(rival) or "FirstClash"
    local encounters = (rival.kills or 0) + (rival.deaths or 0)
    if not (RIVAL_OPENER_TIERS[tier] or RIVAL_OPENER_TIER_POOLS[tier] == "SwornFoe"
        or encounters >= RIVAL_OPENER_MIN_ENCOUNTERS) then
        self:Debug("rival opener skipped: " .. tostring(fullName) .. " is only tier " .. tier)
        return false
    end

    -- Gap-closers call a rival out most of the time; any other signature move only as your
    -- first attack. Filler moves never do.
    local spellName = sigName or self:GetSignatureName(spellID)
    local isOpenerSpell = spellName ~= nil and RIVAL_OPENER_SPELLS[spellName:lower()] == true
    local chance = isOpenerSpell and RIVAL_OPENER_SPELL_CHANCE
        or ((sigName and isFirstCast) and RIVAL_OPENER_FIRST_CHANCE or nil)
    if not chance then
        local skips, now = self.State.RivalSkipLog, GetTime()
        local skipKey = tostring(spellName)
        if now - (skips[skipKey] or -math.huge) >= 30 then
            skips[skipKey] = now
            self:Debug("rival opener skipped: " .. skipKey .. " is not a gap-closer or a signature first attack")
        end
        return false
    end

    -- Pick the pool: RivalOpeners[tier] > its alias > Default > PvPLines[tier]
    local pool, source
    local openers = self.ActiveProfile.RivalOpeners
    if type(openers) == "table" then
        local alias = RIVAL_OPENER_TIER_POOLS[tier]
        if UsablePool(openers[tier]) then
            pool, source = openers[tier], "RivalOpeners." .. tier
        elseif alias and UsablePool(openers[alias]) then
            pool, source = openers[alias], "RivalOpeners." .. alias
        elseif UsablePool(openers.Default) then
            pool, source = openers.Default, "RivalOpeners.Default"
        end
    end
    if not pool then
        local pvpLines = self.ActiveProfile.PvPLines
        if type(pvpLines) == "table" and UsablePool(pvpLines[tier]) then
            pool, source = pvpLines[tier], "PvPLines." .. tier
        end
    end
    if not pool then
        self:Debug("rival opener skipped: no line pool for tier " .. tier)
        return false
    end

    local openerDeck = "RivalOpener_" .. key
    if math.random() < Tune.RIVAL_SCORE_SHARE then
        local scorePool, scoreDeck = self:GetRivalScorePool(rival)
        if scorePool then pool, source, openerDeck = scorePool, scoreDeck, scoreDeck end
    end

    local chatType = (tier == "Nemesis" or tier == "BloodFeud") and "YELL" or "SAY"
    self:Debug(string.format("rival opener: %s (tier %s, %d encounters) cast %s [opener=%s, first=%s] chance %.2f, pool %s, %s",
        tostring(fullName), tier, encounters, tostring(spellName), tostring(isOpenerSpell), tostring(isFirstCast),
        chance, source, chatType))
    return self:ProcessTrigger(7, openerDeck, pool, chance, "target", nil, chatType, hardware) and true or false
end

---------------------------------------------------------------------------
-- Pull-based combat pacing (mobs)
-- Each combat start against mobs counts as a pull. After a rolled number of pulls the
-- next offensive cast says one pull line in /s, then the count resets. The rolled range
-- comes from MonologueDB.pullEvery (the "about every N pulls" slider), N-1 to N+1.
-- Routine (Tier2) reactions against mobs come ONLY from this; Tier1_MajorCD reactions,
-- battle cries, rival call-outs and queued-line flushes are unaffected.
---------------------------------------------------------------------------

local PULL_SPEECH_COOLDOWN = 15   -- seconds; the pull line's own category cooldown
Tune.OPENING_SPELL_SHARE = 0.70   -- pull lines that use the spell's own lines
Tune.OPENING_SITUATION_SHARE = 0.20 -- pull lines that react to the moment (the last 10%: clan, traits, race...)
local BIG_SPELL_CHANCE = 0.5      -- a big cooldown (SpellLines[...].big) speaking mid-fight
local PVP_SPELL_CHANCE = 0.3      -- a signature move used on an enemy player
local PREPULL_WINDOW = 3          -- seconds in which combat starting belongs to an opening cast

-- min, max, label for the pull pacing. MonologueDB.pullEvery (Voice Lines tab slider,
-- 1-10) is the average; each target is rolled one pull either side of it for variety.
function Engine:GetPullPacing()
    local every = math.floor(tonumber(MonologueDB and MonologueDB.pullEvery) or 3)
    if every < 1 then every = 1 end
    if every == 1 then return 1, 1, "every pull" end
    return every - 1, every + 1, "about every " .. every .. " pulls"
end

-- Rolls a target if there is none, or if chattiness changed so it is out of range
function Engine:EnsurePullTarget()
    local low, high = self:GetPullPacing()
    local target = self.State.NextSpeechPull
    if target == nil or (low == nil) ~= (target == math.huge)
        or (low and (target < low or target > high)) then
        self:RollNextSpeechPull()
    end
end

-- e.g. "pull 1/3" or "pull 3/3, armed"
function Engine:DescribePullProgress()
    self:EnsurePullTarget()
    local state = self.State
    local target = state.NextSpeechPull
    if target == math.huge then return "pull lines off" end
    if state.PullSpeechArmed and not state.SpokeThisPull then
        return "line ready for your next attack on a mob"
    end
    return "pull " .. (state.PullCount or 0) .. "/" .. (target and tostring(target) or "?")
end

function Engine:RollNextSpeechPull()
    local low, high = self:GetPullPacing()
    self.State.NextSpeechPull = low and math.random(low, high) or math.huge
    return self.State.NextSpeechPull
end

local function PullTarget()
    return "/" .. (Engine.State.NextSpeechPull == math.huge and "never" or tostring(Engine.State.NextSpeechPull))
end

-- Keeps the Settings tab's pacing readout current while it is open
local function RefreshPacingReadout()
    local ui = MonologueUI
    if ui and ui.RefreshLines then ui:RefreshLines() end
end

-- PLAYER_REGEN_DISABLED: counts the pull, unless an opening cast already said its line
function Engine:OnPullStart()
    local state = self.State
    self:EnsurePullTarget()
    self:CountMobPull()
    if UnitExists("target") and not UnitIsPlayer("target") and UnitCanAttack("player", "target") then
        state.PullRank = Clean(UnitClassification("target"))
    end

    if state.PrePullSpokeAt and GetTime() - state.PrePullSpokeAt <= PREPULL_WINDOW then
        -- The opening cast already counted this pull and spoke for it
        state.PrePullSpokeAt = nil
        state.SpokeThisPull = true
        state.PullSpeechArmed = false
        self:Debug("combat pull opened with a pull line (count reset, next line at pull " .. PullTarget():sub(2) .. ")")
        RefreshPacingReadout()
        return
    end
    state.PrePullSpokeAt = nil
    state.SpokeThisPull = false
    -- Fights that start on an enemy player aren't mob pulls: don't spend the mob counter
    if UnitExists("target") and UnitIsPlayer("target") and UnitCanAttack("player", "target") then
        self:Debug("combat started on a player: not counted as a mob pull")
        return
    end
    state.PullCount = math.min((state.PullCount or 0) + 1, state.NextSpeechPull)
    state.PullSpeechArmed = state.PullCount >= state.NextSpeechPull
    self:Debug("combat pull " .. state.PullCount .. PullTarget() .. (state.PullSpeechArmed and " -> armed" or ""))
    RefreshPacingReadout()
end

---------------------------------------------------------------------------
-- Signature moves. Only spells with a SpellLines pool can lead to speech; every other
-- cast (Heroic Strike, Rend, Fireball spam, ...) is filler and stays silent.
--   SpellLines["Charge"] = { Default = {...}, EagerRookie = {...}, CynicalMercenary = {...},
--                            GrizzledVeteran = {...}, ZealousCrusader = {...}, big = true|nil }
-- The active persona's pool is used when it has one, else Default. A plain list is read as
-- Default. big = true marks a major cooldown that may also speak mid-fight.
---------------------------------------------------------------------------

-- English name used for SpellLines lookups: the class pack's SpellNames[spellID] first (so
-- non-English clients still match), then the client's own spell name
function Engine:GetSignatureName(spellID)
    local names = self.ActiveProfile.SpellNames
    local name = type(names) == "table" and names[spellID] or nil
    if type(name) ~= "string" then name = Clean(GetSpellNameSafe(spellID)) end
    return type(name) == "string" and name or nil
end

-- Returns name, entry, category, fromKind for a signature spell, or nil for filler. A spell with its
-- own SpellLines keeps them (category is your Abilities-tab choice, if any); any other spell
-- speaks from its kind's pool (see the Ability Mapper). "None" silences a spell.
function Engine:GetSignatureEntry(spellID)
    local name = self:GetSignatureName(spellID)
    if not name then return nil end
    local category, how = self:GetAbilityCategory(name, spellID)
    if category == "None" then return nil end
    local spellLines = self.ActiveProfile.SpellLines
    local entry = type(spellLines) == "table" and spellLines[name] or nil
    if type(entry) == "table" then
        return name, entry, (how == "chosen") and category or nil
    end
    if not category then return nil end
    local pool = self:AbilityPool(category)
    if not pool then return nil end
    return name, pool, category, true
end

-- Returns deckKey, pool, label for a signature entry (nil if it has no usable lines)
-- What the signature move is being used on, most specific first: a rare, an elite, an enemy
-- player, while you're hurt, or in a group. Returns contextKey, share (how often a context
-- line is used when one applies), or nil.
local SPELL_CONTEXT_SHARE = { Rare = 0.75, Elite = 0.6, Player = 0.6, Hurt = 0.5, Party = 0.3 }
function Engine:GetSpellContext(unit)
    unit = unit or "target"
    if UnitExists(unit) and UnitCanAttack("player", unit) and not UnitIsDeadOrGhost(unit) then
        if UnitIsPlayer(unit) then return "Player", SPELL_CONTEXT_SHARE.Player end
        local rank = Clean(UnitClassification(unit))
        if rank == "rare" or rank == "rareelite" or rank == "worldboss" then return "Rare", SPELL_CONTEXT_SHARE.Rare end
        if rank == "elite" then return "Elite", SPELL_CONTEXT_SHARE.Elite end
    end
    local hp, maxHp = Clean(UnitHealth("player")), Clean(UnitHealthMax("player"))
    if type(hp) == "number" and type(maxHp) == "number" and maxHp > 0 and hp / maxHp < 0.35 then
        return "Hurt", SPELL_CONTEXT_SHARE.Hurt
    end
    if IsInGroup and IsInGroup() then return "Party", SPELL_CONTEXT_SHARE.Party end
    return nil
end

-- Returns deckKey, pool, label for a signature move. When the move is used on something that
-- matters (see GetSpellContext), the line usually comes from the spell's own context pool
-- (SpellLines["Charge"].Elite) or the shared one (Data.SpellContextLines.Elite).
function Engine:ResolveSpellPool(name, entry, unit)
    local context, share = self:GetSpellContext(unit)
    if context and type(entry) == "table" and math.random() < share then
        local own = entry[context]
        if UsablePool(own) and self:AnyLineAvailable(own) then
            return "SpellLines_" .. name .. "_" .. context, own, name .. " [" .. context .. "]"
        end
        local shared = self.Data.SpellContextLines and self.Data.SpellContextLines[context]
        if UsablePool(shared) and self:AnyLineAvailable(shared) then
            return "SpellContext_" .. context, shared, name .. " [shared " .. context .. "]"
        end
    end
    if UsablePool(entry) then
        return "SpellLines_" .. name, entry, name
    end
    local persona = self.ActiveContext and self.ActiveContext.persona
    if persona and UsablePool(entry[persona]) then
        return "SpellLines_" .. name .. "_" .. persona, entry[persona], name .. " [" .. persona .. "]"
    end
    if UsablePool(entry.Default) then
        return "SpellLines_" .. name .. "_Default", entry.Default, name .. " [Default]"
    end
    return nil
end

-- Repeat guards for fight lines (pull, signature and big-cooldown lines): at most
-- Tune.MAX_COMBAT_LINES per fight, each move once per fight, and a pull line for the same
-- creature or player at most once per Tune.SAME_TARGET_GAP seconds. Low-health and kill
-- lines are not counted. Returns true, or false and the reason.
function Engine:FightLineAllowed(spellName, targetUnit, isPull)
    local state = self.State
    if (state.CombatLines or 0) >= Tune.MAX_COMBAT_LINES then
        return false, (state.CombatLines or 0) .. " lines already this fight"
    end
    if spellName and state.SpellsSaid and state.SpellsSaid[spellName] then
        return false, spellName .. " already spoke this fight"
    end
    if isPull and targetUnit then
        local guid = Clean(UnitGUID(targetUnit))
        local at = guid and state.SpokeToGUID and state.SpokeToGUID[guid]
        if at and GetTime() - at < Tune.SAME_TARGET_GAP then return false, "already spoke to this target" end
    end
    return true
end

function Engine:NoteFightLine(spellName, targetUnit)
    local state = self.State
    state.CombatLines = (state.CombatLines or 0) + 1
    state.SpellsSaid = state.SpellsSaid or {}
    if spellName then state.SpellsSaid[spellName] = true end
    local guid = targetUnit and Clean(UnitGUID(targetUnit))
    if guid then
        local now = GetTime()
        state.SpokeToGUID = state.SpokeToGUID or {}
        for key, at in pairs(state.SpokeToGUID) do
            if now - at >= Tune.SAME_TARGET_GAP then state.SpokeToGUID[key] = nil end
        end
        state.SpokeToGUID[guid] = now
    end
end

function Engine:SayPullLine(targetUnit, spellID, hardware)
    local state = self.State
    local categoryKey = "Pull_Speech"
    local canSpeak, reason = self:CanSpeak(categoryKey)
    if not canSpeak then
        -- Stay armed: the next offensive cast tries again. Logged once per 10s, not per press.
        local now = GetTime()
        if now - (state.PullHeldLoggedAt or -math.huge) >= 10 then
            state.PullHeldLoggedAt = now
            local wait = (reason == "breath") and string.format(", %.0fs left", self.Cooldowns.GlobalBreath - now) or ""
            self:Debug("pull line held (" .. tostring(reason) .. wait .. "), still armed")
        end
        return false
    end
    local name, entry = self:GetSignatureEntry(spellID)
    local allowed, why = self:FightLineAllowed(name, targetUnit, true)
    if not allowed then
        self:Debug("pull line skipped: " .. why)
        return false
    end
    local deckKey, pool, source
    if name then deckKey, pool, source = self:ResolveSpellPool(name, entry, targetUnit) end
    if not pool then return false end
    -- {spell} names the move for every line drawn and spoken below
    self.State.CurrentSpell = name
    local spoke = self:SayPullLineFrom(targetUnit, hardware, categoryKey, deckKey, pool, source)
    self.State.CurrentSpell = nil
    if spoke then self:NoteFightLine(name, targetUnit) end
    return spoke
end

-- The rest of SayPullLine: picks the layer and situation, then speaks
function Engine:SayPullLineFrom(targetUnit, hardware, categoryKey, deckKey, pool, source)
    local state = self.State

    -- Variety Engine: the spell's pool is one layer (25%) among everything this character
    -- has set up (traits, clan, upbringing, allegiance, hometown, anchors, race)
    -- Openings: the move you're using leads. Most pulls (Tune.OPENING_SPELL_SHARE) use the
    -- spell's own lines; the rest react to the moment (a situation: undead, a rare, low
    -- mana...) or come from your identity layers (clan, traits, allegiance, details...).
    -- Rare memory moments (revenge, a grind streak, the first fight after dying or levelling)
    -- can still take any pull.
    local fromLayer = false
    local sitKey, sitPool, sitTokens, sitDeck
    local roll = math.random()
    if roll < Tune.OPENING_SPELL_SHARE then
        -- The spell's own line (which already reacts to rares, elites, players, ...)
        sitKey, sitPool, sitTokens, sitDeck = self:PickSituation(targetUnit, true)
    elseif roll < Tune.OPENING_SPELL_SHARE + Tune.OPENING_SITUATION_SHARE then
        -- A reaction to the moment; if nothing applies, the spell's line after all
        sitKey, sitPool, sitTokens, sitDeck = self:PickSituation(targetUnit)
    else
        -- Now and then: clan, traits, allegiance, race, details
        sitKey, sitPool, sitTokens, sitDeck = self:PickSituation(targetUnit, true)
        if not sitKey then
            local mixKey, mixPool, mixLabel = self:PickLayeredPool("Combat")
            if mixPool then
                fromLayer = true
                deckKey, pool, source = mixKey, mixPool, mixLabel .. " (instead of " .. source .. ")"
            end
        end
    end
    if sitKey then
        deckKey, pool, source = sitDeck, sitPool, "situation [" .. sitKey .. "] (instead of " .. source .. ")"
    end

    local line = self:GetShuffledLine(deckKey, pool)
    if not line then return false end
    self:Debug("spell line from " .. source .. ": " .. line)

    -- Always /s; Speak() logs the exact "speech route:" it takes. A line that isn't the
    -- spell's own (a situation or identity reaction) is said bare: no opener or closer.
    self.State.SituationTokens = sitTokens
    self.State.BareLine = (sitKey ~= nil or fromLayer) or nil
    local ok, route = self:Speak(line, "SAY", targetUnit, { key = categoryKey, duration = PULL_SPEECH_COOLDOWN }, nil, hardware)
    self.State.SituationTokens = nil
    self.State.BareLine = nil
    if ok and sitKey then self:MarkSituationUsed(sitKey, sitTokens) end
    if not ok then
        self:Debug("pull line not spoken (" .. tostring(route) .. "), still armed")
        return false
    end

    state.PullSpeechArmed = false
    state.SpokeThisPull = true
    state.PullCount = 0
    self:RollNextSpeechPull()
    local where = (route == "sent" and "sent to /s")
        or (route == "local" and "shown in your chat frame only (not sent)")
        or (route == "queued" and "queued, not sent yet")
        or (route == "safemode" and "Safe-Mode local print (not sent)")
        or tostring(route)
    self:Debug("pull line " .. where .. "; next line at pull " .. PullTarget():sub(2))
    RefreshPacingReadout()
    return true
end

-- Spell mapping is data-driven: profiles may supply
--   SpellTriggers = { [spellID] = "Tier1_MajorCD" | "Tier2_Routine" }
-- Unmapped casts in combat against a hostile target roll for Tier2_Routine.
-- Spell IDs are rank-specific: list every rank of a ranked spell.
---------------------------------------------------------------------------
-- Everyday moments: eating or drinking, mounting up, walking into an inn or city, a party
-- member falling. Lines from ActiveProfile.Moments, else Data.MomentLines. Said as bare
-- lines (no oath), on the cast press when there is one, else as background speech.
---------------------------------------------------------------------------

local EAT_DRINK_SPELLS = { food = true, drink = true, refreshment = true, ["food & drink"] = true }

-- force: said even with Everyday moments switched off (party banter answers)
function Engine:SayMoment(moment, hardware, name, force)
    if not MonologueDB or (MonologueDB.momentLines == false and not force) then return false end
    local own = type(self.ActiveProfile.Moments) == "table" and self.ActiveProfile.Moments[moment] or nil
    local pool = UsablePool(own) and own or (self.Data.MomentLines and self.Data.MomentLines[moment])
    local banterTopic = moment:match("^Banter_(.+)$")
    if banterTopic and not UsablePool(own) then
        pool = self.Data.BanterLines and self.Data.BanterLines[banterTopic]
    end
    -- Family pools (PetSummon_Imp) share their moment's chance and cooldown
    local baseMoment = moment:match("^(Pet%a+)_%a+$") or moment
    local settings = Tune.MOMENTS[baseMoment] or (banterTopic and Tune.BANTER_MOMENT)
    if not UsablePool(pool) or not settings then return false end
    local categoryKey = "Moment_" .. baseMoment
    self.State.BareLine = true
    self.State.TokenTargetName = name
    self.State.BanterTopic = (not banterTopic and Tune.BANTER_TOPICS[moment]) and moment or nil
    local ok, spoke = pcall(self.ProcessTrigger, self, Tune.IDENTITY_MOMENT_TIER, categoryKey, pool,
        settings.chance, nil, nil, nil, hardware)
    self.State.BareLine = nil
    self.State.TokenTargetName = nil
    self.State.BanterTopic = nil
    if ok and spoke then
        self.Cooldowns.Categories[categoryKey] = GetTime() + settings.cooldown
        return true
    end
    return false
end

-- A cast that is an everyday moment (food, drink, a mount). Returns true when it spoke.
function Engine:TryEverydayMoment(spellID, hardware)
    if not MonologueDB or MonologueDB.momentLines == false then return false end
    local name = GetSpellNameSafe(spellID)
    if type(name) ~= "string" then return false end
    if EAT_DRINK_SPELLS[name:lower()] then
        return self:SayMoment("EatDrink", hardware)
    end
    local gather = Tune.GATHER_SPELLS[name:lower()]
    if gather then return self:SayMoment(gather, hardware) end
    if C_MountJournal and C_MountJournal.GetMountFromSpell then
        local ok, mountID = pcall(C_MountJournal.GetMountFromSpell, spellID)
        local inInstance = Clean((IsInInstance()))
        if ok and Clean(mountID) and not inInstance then
            return self:SayMoment("Mount", hardware)
        end
    end
    return false
end

-- NPC visits (flight master, mailbox, trainer, quest hand-in): background lines, out of combat
function Engine:HandleNpcVisit(moment)
    if not MonologueDB or not MonologueCharDB then return end
    if UnitAffectingCombat("player") or UnitIsDeadOrGhost("player") then return end
    local name = UnitExists("npc") and ShortName(Clean(UnitName("npc"))) or nil
    -- Lines naming {target} need a name; without one only lines without it are used
    self:SayMoment(moment, nil, name)
end

-- True when a unit with this name is your target, mouseover or focus, or has a nameplate
-- (so it is close by, not shouting from across the zone)
function Engine:IsNameNearby(name)
    for _, unit in ipairs({ "target", "mouseover", "focus" }) do
        if UnitExists(unit) and Clean(UnitName(unit)) == name then return true end
    end
    if C_NamePlate and C_NamePlate.GetNamePlates then
        local ok, plates = pcall(C_NamePlate.GetNamePlates)
        if ok and type(plates) == "table" then
            for _, plate in ipairs(plates) do
                local unit = plate.namePlateUnitToken or (plate.UnitFrame and plate.UnitFrame.unit)
                if unit and Clean(UnitName(unit)) == name then return true end
            end
        end
    end
    return false
end

-- CHAT_MSG_MONSTER_YELL: now and then answer a creature or NPC yelling close by
Tune.YELL_SAME_NPC_GAP = 1800
function Engine:HandleMonsterYell(npcName)
    if not MonologueDB or not MonologueCharDB or MonologueDB.npcYells == false then return end
    npcName = Clean(npcName)
    if type(npcName) ~= "string" or npcName == "" then return end
    if self.State.InRestrictedEncounter or UnitIsDeadOrGhost("player") then return end
    local now = GetTime()
    local answered = self.State.YellAnswered or {}
    self.State.YellAnswered = answered
    if now - (answered[npcName] or -math.huge) < Tune.YELL_SAME_NPC_GAP then return end
    if not self:IsNameNearby(npcName) then return end
    if self:SayMoment("NpcYell", nil, ShortName(npcName) or npcName) then answered[npcName] = now end
end

---------------------------------------------------------------------------
-- Moods (situations/Moods.lua): how your character feels today. Per character, set with
-- /mono mood or on the My Voice tab. A share of greetings, idle, kill and low-health lines
-- come from the mood's pool, and chattiness is nudged.
---------------------------------------------------------------------------
Tune.MOOD_SHARE = 0.4
Tune.MOODS = { Grim = 0.85, Weary = 0.75, Cheerful = 1.1, Fierce = 1.0 } -- chattiness multiplier
Tune.MOOD_ORDER = { "Grim", "Weary", "Cheerful", "Fierce" }

function Engine:GetMood()
    local mood = MonologueCharDB and MonologueCharDB.Mood
    if type(mood) == "string" and Tune.MOODS[mood] then return mood end
    return nil
end

-- name: a mood (any case), or nil / "off" / "normal" to clear. Returns the mood set, or false
function Engine:SetMood(name)
    if not MonologueCharDB then return false end
    local wanted = type(name) == "string" and name:lower() or ""
    if wanted == "" or wanted == "off" or wanted == "normal" or wanted == "none" then
        MonologueCharDB.Mood = nil
        return nil
    end
    for _, mood in ipairs(Tune.MOOD_ORDER) do
        if mood:lower() == wanted then
            MonologueCharDB.Mood = mood
            return mood
        end
    end
    return false
end

function Engine:MoodChattiness()
    local mood = self:GetMood()
    return mood and Tune.MOODS[mood] or 1
end

-- kind: Greet, Idle, Kill or LowHP. Returns deckKey, pool (a share of the time) or nil
function Engine:MoodPool(kind)
    local mood = self:GetMood()
    if not mood or math.random() >= Tune.MOOD_SHARE then return nil end
    local lines = self.Data.MoodLines and self.Data.MoodLines[mood]
    local pool = type(lines) == "table" and lines[kind] or nil
    if not UsablePool(pool) then return nil end
    return "Mood_" .. mood .. "_" .. kind, pool
end

---------------------------------------------------------------------------
-- Party banter: when you say a line aloud in a group, Monologue users nearby learn its topic
-- ("B^Kill"). One of them, the same pick on every client, may answer you a moment later.
---------------------------------------------------------------------------
Tune.BANTER_CHANCE = 0.35
Tune.BANTER_COOLDOWN = 180
Tune.BANTER_MOMENT = { chance = 1, cooldown = 60 }
Tune.BANTER_TOPICS = { Kill = true, Idle = true, EatDrink = true, Rest = true, Mount = true, Loot = true, Level = true }

function Engine:SendBanterTopic(topic)
    if not MonologueDB or MonologueDB.partyBanter == false then return end
    if not Tune.BANTER_TOPICS[topic] or not (IsInGroup and IsInGroup()) then return end
    self:SendComm("B^" .. topic)
end

function Engine:HandleBanter(topic, sender)
    if not MonologueDB or not MonologueCharDB or MonologueDB.partyBanter == false then return end
    if not Tune.BANTER_TOPICS[topic] or UnitAffectingCombat("player") or UnitIsDeadOrGhost("player") then return end
    local ok, visible = pcall(UnitIsVisible, sender)
    if not ok or not Clean(visible) then return end
    -- The answerer: Monologue users in the group other than the speaker, in name order,
    -- turning over every minute, so every client agrees and only one answers
    local me = ShortName(UnitName("player"))
    if not me or me == sender then return end
    local names = { me }
    for name, info in pairs(self.State.PartyIdentities or {}) do
        if name ~= sender and name ~= me and info.banter ~= false then names[#names + 1] = name end
    end
    table.sort(names)
    local pick = names[(math.floor((GetServerTime and GetServerTime() or time()) / 60) % #names) + 1]
    if pick ~= me then return end
    local now = GetTime()
    if now - (self.State.BanterAt or -math.huge) < Tune.BANTER_COOLDOWN then return end
    if math.random() >= Tune.BANTER_CHANCE then return end
    self:Debug("party banter: answering " .. sender .. " (" .. topic .. ")")
    C_Timer.After(1.5 + math.random() * 2, function()
        local deckKey, pool = Engine:BanterAnswerPool(topic, sender)
        -- Once said, tell them, so they can have the last word
        Engine.State.CommOnSay = Engine:CommFor("R", sender, nil, topic)
        local ok, said = pcall(Engine.SayPartyLine, Engine, deckKey, pool, 1, sender)
        Engine.State.CommOnSay = nil
        if ok and said then Engine.State.BanterAt = GetTime() end
    end)
end

---------------------------------------------------------------------------
-- Talking with other Monologue users. Directed messages on MONO_RP (party/raid, or guild for
-- greetings, thanks and duels), each sent only once its line is really said aloud
-- (State.CommOnSay rides along with the line, queued or not):
--   G^name          I just greeted <name>                -> they may greet back
--   R^name^topic    I just answered <name>'s banter      -> they may have the last word
--   T^name          I just thanked <name> for raising me -> they may answer
--   D^name^H        I'm about to duel <name> and run Monologue (sent straight away)
--   D^name^E        I lost to <name> and said so          -> the winner answers
---------------------------------------------------------------------------
Tune.GREET_REPLY_CHANCE = 0.8
Tune.GREET_REPLY_COOLDOWN = 600
Tune.GROUP_GREET_GAP = 1800       -- greeted someone: no automatic greeting again for 30 min,
                                  -- and none at all while you're still grouped with them
Tune.BANTER_CLOSE_CHANCE = 0.35
Tune.BANTER_CLOSE_COOLDOWN = 120
Tune.BANTER_RELATION_SHARE = 0.6
Tune.REZ_THANKS_CHANCE = 0.7
Tune.REZ_WINDOW = 120
Tune.THANKS_REPLY_CHANCE = 0.6
Tune.DUEL_OPEN_CHANCE = 0.7
Tune.DUEL_REPLY_WAIT = 8
Tune.DUEL_MONO_WINDOW = 300
Tune.COOL_STANCES = { WARY = true, GRUFF = true, DISDAINFUL = true }

function Engine:IsMyName(name)
    local me = ShortName(UnitName("player"))
    return type(name) == "string" and me ~= nil and NormalizeNameKey(name) == NormalizeNameKey(me)
end

-- A unit token for a short name: your target, mouseover or focus, or a group member
function Engine:UnitForName(name)
    if type(name) ~= "string" or name == "" then return nil end
    local key = NormalizeNameKey(name)
    local function Matches(unit)
        if not (UnitExists(unit) and UnitIsPlayer(unit)) then return false end
        local short = ShortName(UnitName(unit))
        return short ~= nil and NormalizeNameKey(short) == key
    end
    for _, unit in ipairs({ "target", "mouseover", "focus" }) do
        if Matches(unit) then return unit end
    end
    local prefix, count = "party", 4
    if IsInRaid and IsInRaid() then prefix, count = "raid", 40 end
    for i = 1, count do
        if Matches(prefix .. i) then return prefix .. i end
    end
    return nil
end

-- The name to use for {target} in a line about another player: their Total RP / MSP name
-- when they have one, else their character name
function Engine:PartyDisplayName(name)
    local unit = self:UnitForName(name)
    if unit and MonologueRPBridge and MonologueRPBridge.GetRPName then
        local ok, rp = pcall(MonologueRPBridge.GetRPName, MonologueRPBridge, unit)
        if ok and type(rp) == "string" and rp ~= "" then return rp end
    end
    return name
end

-- A directed message for <name>, on the channel that reaches them (your group, else your
-- guild), or nil when no channel does
function Engine:CommFor(kind, name, unit, tail)
    if type(name) ~= "string" or name == "" then return nil end
    unit = unit or self:UnitForName(name)
    local channel
    if (unit and (UnitInParty(unit) or UnitInRaid(unit))) or UnitInParty(name) or UnitInRaid(name) then
        channel = CommChannel()
    end
    if not channel and unit and IsInGuild and IsInGuild() then
        local mine = Clean(GetGuildInfo("player"))
        if mine and mine == Clean(GetGuildInfo(unit)) then channel = "GUILD" end
    end
    if not channel then return nil end
    local short = (ShortName(name) or name):gsub("%^", "")
    return { msg = kind .. "^" .. short .. (tail and ("^" .. tail) or ""), channel = channel }
end

function Engine:SendCommOnSay(comm)
    if type(comm) ~= "table" or not comm.channel or type(comm.msg) ~= "string" then return end
    self:QueueAddonMessage(COMM_PREFIX, comm.msg, comm.channel)
end

-- How you stand with another player: "Friend" (marked with /mono friend), "Cool" (your
-- cross-race stance toward their race is wary, gruff or disdainful), or nil
function Engine:RelationTo(name, unit)
    unit = unit or self:UnitForName(name)
    if not unit then return nil end
    if self:GetFriendForUnit(unit) then return "Friend" end
    local _, race = UnitRace(unit)
    local cv = self:GetCustomVoice()
    local stance = cv and type(cv.raceStances) == "table" and cv.raceStances[Clean(race) or ""] or nil
    if stance and Tune.COOL_STANCES[stance] then return "Cool" end
    return nil
end

-- Greeting the same people again and again makes no sense: after greeting someone (or being
-- greeted by them), no automatic greeting for Tune.GROUP_GREET_GAP, nor while you're grouped
function Engine:NoteGreeted(name)
    if type(name) ~= "string" then return end
    self.State.GroupGreeted = self.State.GroupGreeted or {}
    self.State.GroupGreeted[NormalizeNameKey(name)] = GetTime()
end

function Engine:GreetBlocked(unit)
    local name = ShortName(UnitName(unit))
    local met = self.State.GroupGreeted
    if not name or type(met) ~= "table" then return false end
    local key = NormalizeNameKey(name)
    local at = met[key]
    if not at then return false end
    if UnitInParty(unit) or UnitInRaid(unit) then
        met[key] = GetTime()   -- still together: keep the gap running from now
        return true
    end
    return GetTime() - at < Tune.GROUP_GREET_GAP
end

-- Another Monologue user greeted you aloud: greet them back (once; not if you greeted first)
function Engine:HandleGreetedBy(sender)
    if not MonologueDB or MonologueDB.partyBanter == false then return end
    if UnitAffectingCombat("player") or UnitIsDeadOrGhost("player") then return end
    local key, now = NormalizeNameKey(sender), GetTime()
    local met = self.State.GroupGreeted or {}
    self.State.GroupGreeted = met
    local greetedFirst = met[key] and now - met[key] < Tune.GREET_REPLY_COOLDOWN
    met[key] = now
    if greetedFirst then return end
    self.State.GreetReplyAt = self.State.GreetReplyAt or {}
    if now - (self.State.GreetReplyAt[key] or -math.huge) < Tune.GREET_REPLY_COOLDOWN then return end
    if math.random() >= Tune.GREET_REPLY_CHANCE then return end
    local unit = self:UnitForName(sender)
    if unit then
        local ok, visible = pcall(UnitIsVisible, unit)
        if ok and not Clean(visible) then return end
    end
    self.State.GreetReplyAt[key] = now
    self:Debug("greeted by " .. sender .. ": greeting back")
    C_Timer.After(1.5 + math.random() * 1.5, function()
        local deckKey, pool = Engine:GreetReplyPool(sender, unit)
        Engine:SayPartyLine(deckKey, pool, 1, sender, "greeting")
    end)
end

-- Half the time your usual greeting for them (friend, guildmate, stance, race), else a reply
function Engine:GreetReplyPool(sender, unit)
    if unit and UnitExists(unit) and math.random() < 0.5 then
        local key, pool = self:PickGreeting(unit)
        if UsablePool(pool) then return key, pool end
    end
    local lines = self.Data.BanterLines or {}
    local relation = self:RelationTo(sender, unit)
    local own = relation and type(lines[relation]) == "table" and lines[relation].Greet or nil
    if UsablePool(own) and math.random() < Tune.BANTER_RELATION_SHARE then
        return "Banter_" .. relation .. "_Greet", own
    end
    return "Banter_GreetBack", lines.GreetBack
end

-- The pool for answering <sender>'s banter: a friend, a cool stance or someone of your own
-- class (after a kill) get their own answers some of the time
function Engine:BanterAnswerPool(topic, sender)
    local lines = self.Data.BanterLines or {}
    if math.random() < Tune.BANTER_RELATION_SHARE then
        local unit = self:UnitForName(sender)
        local relation = self:RelationTo(sender, unit)
        local pool = relation and type(lines[relation]) == "table" and lines[relation][topic] or nil
        if UsablePool(pool) then return "Banter_" .. relation .. "_" .. topic, pool end
        if unit and topic == "Kill" and UsablePool(lines.SameClass) then
            local _, mine = UnitClass("player")
            local _, theirs = UnitClass(unit)
            if Clean(mine) and Clean(mine) == Clean(theirs) then return "Banter_SameClass", lines.SameClass end
        end
    end
    local own = type(self.ActiveProfile.Moments) == "table" and self.ActiveProfile.Moments["Banter_" .. topic] or nil
    if UsablePool(own) then return "Moment_Banter_" .. topic, own end
    return "Banter_" .. topic, lines[topic]
end

-- Someone answered your line: now and then you have the last word
function Engine:HandleBanterReply(answerer, topic)
    if not MonologueDB or MonologueDB.partyBanter == false then return end
    if UnitAffectingCombat("player") or UnitIsDeadOrGhost("player") then return end
    local now = GetTime()
    if now - (self.State.BanterCloseAt or -math.huge) < Tune.BANTER_CLOSE_COOLDOWN then return end
    if math.random() >= Tune.BANTER_CLOSE_CHANCE then return end
    self.State.BanterCloseAt = now
    C_Timer.After(2 + math.random() * 1.5, function()
        local close = Engine.Data.BanterLines and Engine.Data.BanterLines.Close or {}
        local pool, key = close[topic], "Banter_Close_" .. tostring(topic)
        if not UsablePool(pool) then pool, key = close.Any, "Banter_Close_Any" end
        Engine:SayPartyLine(key, pool, 1, answerer)
    end)
end

-- You were raised by another player: thank them (they may answer, if they run Monologue)
function Engine:ThankRezzer()
    local rez = self.State.RezBy
    if type(rez) ~= "table" or UnitIsDeadOrGhost("player") then return end
    self.State.RezBy = nil
    if not rez.name or GetTime() - rez.at > Tune.REZ_WINDOW then return end
    if not MonologueDB or MonologueDB.momentLines == false then return end
    local pool = self.Data.BanterLines and self.Data.BanterLines.Thanks
    self.State.CommOnSay = self:CommFor("T", rez.name)
    pcall(self.SayPartyLine, self, "Banter_Thanks", pool, Tune.REZ_THANKS_CHANCE, rez.name)
    self.State.CommOnSay = nil
end

function Engine:HandleThanked(sender)
    if not MonologueDB or MonologueDB.partyBanter == false or UnitAffectingCombat("player") then return end
    if math.random() >= Tune.THANKS_REPLY_CHANCE then return end
    C_Timer.After(1.5 + math.random(), function()
        local pool = Engine.Data.BanterLines and Engine.Data.BanterLines.ThanksReply
        Engine:SayPartyLine("Banter_ThanksReply", pool, 1, sender)
    end)
end

-- A duel is about to start (you challenged, or were challenged): say hello to their
-- Monologue, and a line of your own on your next key press (dropped if the duel never starts)
function Engine:DuelStarting(name, unit, kind)
    local short = type(name) == "string" and ShortName(StripRealm(name) or name) or nil
    if not short then return end
    local hello = self:CommFor("D", short, unit, "H")
    if hello then self:SendCommOnSay(hello) end
    if not MonologueDB or MonologueDB.momentLines == false or UnitAffectingCombat("player") then return end
    local pool = self.Data.DuelTalk and self.Data.DuelTalk[kind]
    self.State.PendingTag = "duelopen"
    pcall(self.SayPartyLine, self, "DuelTalk_" .. kind, pool, Tune.DUEL_OPEN_CHANCE, short, "duel")
    self.State.PendingTag = nil
end

function Engine:HandleDuelComm(sender, phase)
    local key = NormalizeNameKey(sender)
    if phase == "H" then
        self.State.DuelMono = self.State.DuelMono or {}
        self.State.DuelMono[key] = GetTime()
    elseif phase == "E" then
        local wait = self.State.DuelAwait
        if not wait or wait.key ~= key then return end
        self.State.DuelAwait = nil
        C_Timer.After(1.5 + math.random(), function()
            local pool = Engine.Data.DuelTalk and Engine.Data.DuelTalk.WinReply
            Engine:SayPartyLine("DuelTalk_WinReply", pool, 1, sender, "duel")
        end)
    end
end

-- After a duel. Against another Monologue user the loser speaks first and the winner answers
-- (or speaks anyway after Tune.DUEL_REPLY_WAIT seconds); otherwise as before
function Engine:DuelResultTalk(opponent, won)
    local key = NormalizeNameKey(ShortName(StripRealm(opponent) or opponent) or opponent)
    local seen = self.State.DuelMono and self.State.DuelMono[key]
    if not (seen and GetTime() - seen < Tune.DUEL_MONO_WINDOW) then
        return self:SpeakDuelLine(opponent, won)
    end
    if not won then
        self.State.CommOnSay = self:CommFor("D", ShortName(StripRealm(opponent) or opponent), nil, "E")
        pcall(self.SpeakDuelLine, self, opponent, false)
        self.State.CommOnSay = nil
        return
    end
    local wait = { key = key, at = GetTime() }
    self.State.DuelAwait = wait
    C_Timer.After(Tune.DUEL_REPLY_WAIT, function()
        if Engine.State.DuelAwait == wait then
            Engine.State.DuelAwait = nil
            Engine:SpeakDuelLine(opponent, true)
        end
    end)
end

---------------------------------------------------------------------------
-- /mono say <kind> [chance]: a line on demand, for your own macros (a slash command from a
-- macro is a key press, so it can be said aloud). Cooldowns and the breath lock still apply.
---------------------------------------------------------------------------
Tune.SAY_KINDS = { idle = "Idle", kill = "Kill", pull = "Combat", hurt = "LowHP",
    interrupt = "Interrupt", heal = "Heal", defend = "Defend" }
Tune.SAY_COOLDOWN = 30

function Engine:SayOnDemand(kind, chanceText)
    kind = type(kind) == "string" and kind:lower() or ""
    local chance = tonumber(chanceText or "") or 100
    if chance <= 0 or math.random() * 100 >= chance then return false end
    if kind == "cry" then return self:BattleCry() end
    if kind == "greet" then return self:GreetNow() end
    local layer = Tune.SAY_KINDS[kind]
    if not layer then
        Print("Usage: /mono say <idle|kill|pull|hurt|interrupt|heal|defend|greet|cry> [chance %]")
        return false
    end
    local inCombat = UnitAffectingCombat("player")
    if inCombat and kind ~= "kill" then
        local allowed, why = self:FightLineAllowed(nil, nil, false)
        if not allowed then
            self:Debug("/mono say " .. kind .. " skipped: " .. why)
            return false
        end
    end
    local deckKey, pool
    if layer == "Interrupt" or layer == "Heal" or layer == "Defend" then
        local own = type(self.ActiveProfile.Moments) == "table" and self.ActiveProfile.Moments[layer] or nil
        pool = UsablePool(own) and own or (self.Data.MomentLines and self.Data.MomentLines[layer])
        deckKey = "Moment_" .. layer
    elseif layer == "LowHP" then
        deckKey, pool = self:MoodPool("LowHP")
        if not pool then
            local reactions = self.ActiveProfile.SpellReactions
            local classPool = type(reactions) == "table" and reactions.Tier3_LowHP or nil
            deckKey, pool = self:PickLayeredPool("LowHP", "Spell_Tier3_LowHP", classPool, "low health")
        end
    else
        deckKey, pool = self:PickIdentityPool(layer)
    end
    if not UsablePool(pool) then return false end
    self.State.OathMoment = (layer == "Kill" and "Kill") or (layer == "LowHP" and "LowHP") or nil
    local ok, spoke = pcall(self.SpeakIdentityLine, self, "Say_" .. kind, pool, Tune.SAY_COOLDOWN, true, deckKey)
    self.State.OathMoment = nil
    spoke = ok and spoke
    if spoke and inCombat and kind ~= "kill" then self:NoteFightLine(nil, nil) end
    return spoke
end

---------------------------------------------------------------------------
-- Ability Mapper (Abilities tab, /mono map). Spells with their own SpellLines keep them; any
-- other spell you cast may speak from a shared pool for its kind (situations/Abilities.lua):
--   Attack                    a harmful spell: may open a fight, like a signature move
--   Burst                     a big cooldown (your choice only): may also speak mid-fight
--   Defend, Interrupt, Heal   may also speak mid-fight now and then
--   None                      never speaks, even a spell with its own lines
-- MonologueCharDB.AbilityMap[name] holds your choices, AbilityEvery[name] = N speaks on every
-- Nth cast only, and SeenSpells[name] = { id, at } lists the spells you have cast (the
-- tab's rows). The fight limits (2 lines a fight, each move once) still apply.
---------------------------------------------------------------------------
Tune.ABILITY_CATEGORIES = { "Attack", "Burst", "Defend", "Interrupt", "Heal" }
Tune.ABILITY_MID_CHANCE = { Burst = 0.5, Defend = 0.3, Interrupt = 0.3, Heal = 0.2 }
Tune.ABILITY_EVERY = { 1, 2, 3, 5, 10 }
Tune.SEEN_SPELLS_MAX = 120
Tune.INTERRUPT_SPELLS = { kick = true, pummel = true, ["shield bash"] = true, counterspell = true,
    ["earth shock"] = true }
Tune.HEAL_WORDS = { "heal", "mend", "renew", "regrowth", "rejuvenation", "holy light", "flash of light" }
Tune.ABILITY_SKIP = { attack = true, ["auto shot"] = true, shoot = true }
Tune.POOL_KEYS_MAX = 40

-- "harm", "help" or nil (unknown, or neither: food, mounts, gathering)
function Engine:SpellKind(spellID)
    if type(spellID) ~= "number" then return nil end
    if C_Spell and C_Spell.IsSpellHarmful then
        local ok, harmful = pcall(C_Spell.IsSpellHarmful, spellID)
        if ok and Clean(harmful) then return "harm" end
    end
    if C_Spell and C_Spell.IsSpellHelpful then
        local ok, helpful = pcall(C_Spell.IsSpellHelpful, spellID)
        if ok and Clean(helpful) then return "help" end
    end
    return nil
end

-- "attack" -> "Attack"; also "None" and "Auto". nil when it isn't one.
function Engine:NormalizeAbilityCategory(value)
    if type(value) ~= "string" then return nil end
    local lower = value:lower()
    if lower == "none" or lower == "off" or lower == "silent" then return "None" end
    if lower == "auto" then return "Auto" end
    if lower == "defensive" or lower == "defense" or lower == "defence" then return "Defend" end
    for _, category in ipairs(Tune.ABILITY_CATEGORIES) do
        if category:lower() == lower then return category end
    end
    return nil
end

-- The kind a spell gets without your choice: Interrupt (by name), Heal (a helpful spell
-- with a healing name) or Attack (a harmful spell). nil = silent.
function Engine:AutoAbilityCategory(name, spellID)
    if type(name) ~= "string" then return nil end
    local lower = name:lower()
    if Tune.ABILITY_SKIP[lower] then return nil end
    if Tune.INTERRUPT_SPELLS[lower] then return "Interrupt" end
    local kind = self:SpellKind(spellID)
    if kind == "harm" then return "Attack" end
    if kind == "help" then
        for _, word in ipairs(Tune.HEAL_WORDS) do
            if lower:find(word, 1, true) then return "Heal" end
        end
    end
    return nil
end

-- Returns category, how ("chosen" or "auto"), or nil
function Engine:GetAbilityCategory(name, spellID)
    local map = MonologueCharDB and MonologueCharDB.AbilityMap
    local chosen = type(map) == "table" and map[name] or nil
    if chosen == "None" or chosen == "Attack" or Tune.ABILITY_MID_CHANCE[chosen or ""] then
        return chosen, "chosen"
    end
    if MonologueDB and MonologueDB.abilityAuto == false then return nil end
    return self:AutoAbilityCategory(name, spellID), "auto"
end

-- The lines for a kind: the profile's own AbilityLines, then moment pools of the same name
-- (Defend, Interrupt, Heal), then the shared ones
function Engine:AbilityPool(category)
    local own = type(self.ActiveProfile.AbilityLines) == "table" and self.ActiveProfile.AbilityLines[category] or nil
    if UsablePool(own) then return own end
    local moments = self.ActiveProfile.Moments
    if type(moments) == "table" and UsablePool(moments[category]) then return moments[category] end
    local shared = self.Data.AbilityLines and self.Data.AbilityLines[category]
    if UsablePool(shared) then return shared end
    shared = self.Data.MomentLines and self.Data.MomentLines[category]
    return UsablePool(shared) and shared or nil
end

-- Every cast: counted (for "every Nth cast") and listed on the Abilities tab. The press
-- hook and the cast event both report a cast, so a repeat within half a second is the same one.
function Engine:NoteCast(spellID)
    spellID = Clean(spellID)
    if type(spellID) ~= "number" or not MonologueCharDB then return end
    local name = self:GetSignatureName(spellID)
    if not name then return end
    local state = self.State
    state.CastCounts = state.CastCounts or {}
    local count = state.CastCounts[name]
    local now = GetTime()
    if count and now - count.at < 0.5 then return end
    if not count then
        count = { n = 0 }
        state.CastCounts[name] = count
    end
    count.n, count.at = count.n + 1, now

    -- Only spells that could speak are listed
    local spellLines = self.ActiveProfile.SpellLines
    local own = type(spellLines) == "table" and type(spellLines[name]) == "table"
    if not own and not self:SpellKind(spellID) then return end
    local seen = MonologueCharDB.SeenSpells
    if type(seen) ~= "table" then
        seen = {}
        MonologueCharDB.SeenSpells = seen
    end
    local isNew = seen[name] == nil
    seen[name] = { id = spellID, at = GetServerTime and GetServerTime() or 0 }
    if isNew then
        local total, oldestName, oldestAt = 0, nil, math.huge
        for key, info in pairs(seen) do
            total = total + 1
            local at = type(info) == "table" and tonumber(info.at) or 0
            if at < oldestAt then oldestName, oldestAt = key, at end
        end
        if total > Tune.SEEN_SPELLS_MAX and oldestName then seen[oldestName] = nil end
        if MonologueUI and MonologueUI.OnAbilitiesChanged then pcall(MonologueUI.OnAbilitiesChanged, MonologueUI) end
    end
end

-- "Every Nth cast": true when this cast of the spell may speak
function Engine:CastTurnAllowed(name)
    local every = self:GetAbilityEvery(name)
    if every <= 1 then return true end
    local count = self.State.CastCounts and self.State.CastCounts[name]
    local n = count and count.n or 0
    if n % every == 0 then return true end
    self:Debug(name .. ": quiet this cast (speaks every " .. every .. " casts)")
    return false
end

function Engine:GetAbilityChoice(name)
    local map = MonologueCharDB and MonologueCharDB.AbilityMap
    return type(map) == "table" and map[name] or "Auto"
end

function Engine:SetAbilityCategory(name, category)
    category = self:NormalizeAbilityCategory(category)
    if type(name) ~= "string" or not category or not MonologueCharDB then return false end
    if type(MonologueCharDB.AbilityMap) ~= "table" then MonologueCharDB.AbilityMap = {} end
    MonologueCharDB.AbilityMap[name] = (category ~= "Auto") and category or nil
    return true
end

function Engine:GetAbilityEvery(name)
    local every = MonologueCharDB and type(MonologueCharDB.AbilityEvery) == "table"
        and tonumber(MonologueCharDB.AbilityEvery[name]) or 1
    return math.max(1, math.floor(every))
end

function Engine:SetAbilityEvery(name, every)
    if type(name) ~= "string" or not MonologueCharDB then return false end
    every = math.floor(tonumber(every) or 1)
    if type(MonologueCharDB.AbilityEvery) ~= "table" then MonologueCharDB.AbilityEvery = {} end
    MonologueCharDB.AbilityEvery[name] = every > 1 and every or nil
    return true
end

-- What a spell does without your choice: "own lines", a kind, or "silent"
function Engine:DescribeAbility(name)
    local spellLines = self.ActiveProfile.SpellLines
    if type(spellLines) == "table" and type(spellLines[name]) == "table" then return "own lines" end
    if MonologueDB and MonologueDB.abilityAuto == false then return "silent" end
    local seen = MonologueCharDB and MonologueCharDB.SeenSpells
    local info = type(seen) == "table" and seen[name]
    local id = type(info) == "table" and tonumber(info.id) or nil
    return self:AutoAbilityCategory(name, id) or "silent"
end

-- Sorted names of the spells you have cast
function Engine:GetSeenSpells()
    local names = {}
    local seen = MonologueCharDB and MonologueCharDB.SeenSpells
    for name in pairs(type(seen) == "table" and seen or {}) do
        if type(name) == "string" then names[#names + 1] = name end
    end
    table.sort(names)
    return names
end

-- A typed spell name ("swipe") as the name lines use ("Swipe"), or nil
function Engine:ResolveSpellName(text)
    if type(text) ~= "string" then return nil end
    text = strtrim(text)
    if text == "" then return nil end
    local lower = text:lower()
    for _, name in ipairs(self:GetSeenSpells()) do
        if name:lower() == lower then return name end
    end
    local spellLines = self.ActiveProfile.SpellLines
    if type(spellLines) == "table" then
        for name in pairs(spellLines) do
            if type(name) == "string" and name:lower() == lower then return name end
        end
    end
    if C_Spell and C_Spell.GetSpellInfo then
        local ok, info = pcall(C_Spell.GetSpellInfo, text)
        local name = ok and type(info) == "table" and Clean(info.name) or nil
        if type(name) == "string" then return name end
    end
    return nil
end

-- True for "Spell:<name>", "Moment:<known moment>" and "Ability:<kind>"
function Engine:ValidPoolKey(poolKey)
    if type(poolKey) ~= "string" then return false end
    local kind, key = poolKey:match("^(%a+):(.+)$")
    if kind == "Spell" then return #key <= 40 end
    if kind == "Moment" then
        return Tune.MOMENTS[key] ~= nil or (self.Data.MomentLines and self.Data.MomentLines[key] ~= nil) or false
    end
    if kind == "Ability" then
        local category = self:NormalizeAbilityCategory(key)
        return category == key and category ~= "None" and category ~= "Auto"
    end
    return false
end

-- Every everyday moment key, sorted (the Abilities tab's "My Lines" list)
function Engine:GetMomentKeys()
    local keys = {}
    for key in pairs(Tune.MOMENTS) do keys[#keys + 1] = key end
    table.sort(keys)
    return keys
end

-- Dungeon quiet (Abilities tab): automatic lines a quarter as often in dungeons, none in raids
Tune.DUNGEON_QUIET = 0.25
function Engine:PlaceChattiness()
    if not (MonologueDB and MonologueDB.dungeonQuiet) then return 1 end
    local _, instanceType = IsInInstance()
    instanceType = Clean(instanceType)
    if instanceType == "raid" then return 0 end
    if instanceType == "party" or instanceType == "scenario" then return Tune.DUNGEON_QUIET end
    return 1
end

---------------------------------------------------------------------------
-- Gathering, mishaps and pets (everyday moments, situations/Moments.lua)
---------------------------------------------------------------------------
Tune.MOMENTS.Mining = { chance = 0.12, cooldown = 900 }
Tune.MOMENTS.Herbalism = { chance = 0.12, cooldown = 900 }
Tune.MOMENTS.Skinning = { chance = 0.12, cooldown = 900 }
Tune.MOMENTS.Fishing = { chance = 0.12, cooldown = 900 }
Tune.MOMENTS.Crafting = { chance = 0.20, cooldown = 1800 }
Tune.MOMENTS.Merchant = { chance = 0.15, cooldown = 1800 }
Tune.MOMENTS.BagsFull = { chance = 0.50, cooldown = 900 }
Tune.MOMENTS.Drowning = { chance = 0.60, cooldown = 600 }
Tune.MOMENTS.Fall = { chance = 0.50, cooldown = 300 }
Tune.MOMENTS.PetSummon = { chance = 0.25, cooldown = 600 }
Tune.MOMENTS.PetDown = { chance = 0.60, cooldown = 300 }
-- Gathering casts by (lower-case) spell name
Tune.GATHER_SPELLS = { mining = "Mining", ["herb gathering"] = "Herbalism", skinning = "Skinning",
    fishing = "Fishing" }
Tune.FALL_MIN_TIME = 1.5       -- seconds in the air before a landing counts
Tune.FALL_MIN_LOSS = 0.10      -- share of your health the landing must cost
Tune.PET_RETURN_QUIET = 20     -- the same pet back within this many seconds (zoning) says nothing

-- UI_ERROR_MESSAGE: "Inventory is full" and the like
function Engine:HandleUiError(first, second)
    local message = Clean(type(second) == "string" and second or first)
    if type(message) ~= "string" then return end
    if message ~= _G.ERR_INV_FULL and message ~= _G.ERR_BAG_FULL then return end
    if UnitIsDeadOrGhost("player") then return end
    self:SayMoment("BagsFull", nil)
end

-- MIRROR_TIMER_START / _STOP for the breath bar: a line once half your air is gone
function Engine:HandleMirrorTimer(event, timerName, value, _, scale)
    if Clean(timerName) ~= "BREATH" then return end
    local state = self.State
    scale = tonumber(Clean(scale))
    -- Stopped, or filling up again (back at the surface)
    if event == "MIRROR_TIMER_STOP" or (scale and scale > 0) then
        state.BreathToken = nil
        return
    end
    local token = {}
    state.BreathToken = token
    local left = (tonumber(Clean(value)) or 60000) / 1000
    C_Timer.After(math.max(1, left * 0.5), function()
        if state.BreathToken ~= token then return end
        state.BreathToken = nil
        if UnitIsDeadOrGhost("player") then return end
        -- Back at the surface by now (in case the client didn't report it)
        if IsSwimming and not Clean(IsSwimming()) then return end
        Engine:SayMoment("Drowning", nil)
    end)
end

-- Falling (checked a few times a second): a long fall whose landing hurt
function Engine:CheckFalling()
    if type(IsFalling) ~= "function" then return end
    local state = self.State
    if Clean(IsFalling()) then
        if not state.FallStart then
            state.FallStart = GetTime()
            local hp = Clean(UnitHealth("player"))
            state.FallHealth = type(hp) == "number" and hp or nil
        end
        return
    end
    local started, before = state.FallStart, state.FallHealth
    if not started then return end
    state.FallStart, state.FallHealth = nil, nil
    if GetTime() - started < Tune.FALL_MIN_TIME or not before then return end
    -- The damage lands a moment after you do
    C_Timer.After(0.4, function()
        local hp, maxHp = Clean(UnitHealth("player")), Clean(UnitHealthMax("player"))
        if type(hp) ~= "number" or type(maxHp) ~= "number" or maxHp <= 0 or hp <= 0 then return end
        if UnitIsDeadOrGhost("player") then return end
        if (before - hp) / maxHp >= Tune.FALL_MIN_LOSS then Engine:SayMoment("Fall", nil) end
    end)
end

-- A family pool (PetSummon_Imp) when there is one, else the general moment
function Engine:SayPetMoment(moment, name)
    local family = UnitCreatureFamily and Clean(UnitCreatureFamily("pet"))
    if type(family) == "string" then
        local key = moment .. "_" .. family:gsub("%W", "")
        local own = type(self.ActiveProfile.Moments) == "table" and self.ActiveProfile.Moments[key]
        local shared = self.Data.MomentLines and self.Data.MomentLines[key]
        if UsablePool(own) or UsablePool(shared) then return self:SayMoment(key, nil, name) end
    end
    return self:SayMoment(moment, nil, name)
end

-- UNIT_PET (and PLAYER_ENTERING_WORLD, which resets PetReady): a pet summoned
function Engine:HandlePetChanged()
    local state = self.State
    local name = UnitExists("pet") and ShortName(Clean(UnitName("pet"))) or nil
    local previous = state.PetName
    if not state.PetReady then
        -- First reading after login or a loading screen: remember the pet, say nothing
        state.PetReady = true
        state.PetName = name
        state.PetDead = name ~= nil and Clean(UnitIsDead("pet")) and true or false
        return
    end
    if not name then
        if previous then state.PetGoneName, state.PetGoneAt = previous, GetTime() end
        state.PetName = nil
        return
    end
    if name == previous then return end
    state.PetName = name
    state.PetDead = Clean(UnitIsDead("pet")) and true or false
    if state.PetGoneName == name and GetTime() - (state.PetGoneAt or 0) < Tune.PET_RETURN_QUIET then return end
    if state.PetDead or UnitAffectingCombat("player") or UnitIsDeadOrGhost("player") then return end
    self:SayPetMoment("PetSummon", name)
end

-- UNIT_HEALTH for the pet: it just died
function Engine:HandlePetHealth()
    if not UnitExists("pet") then return end
    local state = self.State
    local dead = Clean(UnitIsDead("pet")) and true or false
    local was = state.PetDead
    state.PetDead = dead
    if dead and was == false then
        self:SayPetMoment("PetDown", ShortName(Clean(UnitName("pet"))))
    end
end

-- PLAYER_UPDATE_RESTING: walking into an inn or a city. The first reading after login is silent.
function Engine:HandleRestingChanged()
    local resting = Clean(IsResting()) and true or false
    local was = self.State.WasResting
    self.State.WasResting = resting
    if was == nil or not resting or was then return end
    if UnitAffectingCombat("player") or UnitIsDeadOrGhost("player") then return end
    self:SayMoment("Rest", nil)
end

-- UNIT_HEALTH for party1-4: a party member who just died (not feigning)
function Engine:CheckAllyDown(unit)
    if type(unit) ~= "string" or not unit:find("^party%d$") or not UnitExists(unit) then return end
    local guid = Clean(UnitGUID(unit))
    if not guid then return end
    self.State.AllyDead = self.State.AllyDead or {}
    local dead = UnitIsDeadOrGhost(unit) and not (UnitIsFeignDeath and UnitIsFeignDeath(unit))
    dead = Clean(dead) and true or false
    local was = self.State.AllyDead[guid]
    self.State.AllyDead[guid] = dead
    -- Only the change from alive to dead counts (the first reading of a member is silent)
    if was == nil or was or not dead then return end
    if UnitIsDeadOrGhost("player") then return end
    local name = ShortName(Clean(UnitName(unit)))
    if not name then return end
    self:Debug("party: " .. name .. " died")
    self:SayMoment("AllyDown", nil, name)
end

-- Called from UNIT_SPELLCAST_SENT, so everything here comes straight from a player action
-- (a hardware event) and may use SAY/YELL.
--
-- hardware: nil when called from UNIT_SPELLCAST_SENT (speech is background only), or true
-- when called from inside the player's ability press (see the Ability-Press Voice section),
-- where /s may be sent directly. A cast already handled by its press skips the speech part.
function Engine:HandleSpellcast(spellID, hardware)
    spellID = Clean(spellID)
    if not spellID then return end
    local pressMode = hardware == true

    if not pressMode then
        if self.State.LogSpells then
            Print(string.format("Cast: %s (ID %d)", GetSpellNameSafe(spellID) or "?", spellID))
        end
        if UnitAffectingCombat("player") then self:MarkEngaged() end
        pcall(self.NoteCast, self, spellID)

        -- The press already spoke (or chose silence) for this cast: no second pass
        local handled = self.State.PressHandled
        if handled and handled.spellID == spellID and GetTime() - handled.at < 1.5 then
            return
        end
    end
    -- Only the ability press itself may send to public chat. The UNIT_SPELLCAST_SENT pass
    -- (a press that was skipped, a cast from an action-bar addon, ...) is background speech:
    -- it never calls SendChatMessage, so it can never raise "Interface action failed".
    local castRoute = pressMode and true or nil

    -- Say any line held back from a background event (key presses only). If that line went
    -- out, this cast adds no second line.
    if pressMode and self:FlushPendingSpeech("slash") then return end

    local inCombat = UnitAffectingCombat("player")
    local hostileTarget = UnitExists("target") and UnitCanAttack("player", "target")
    local targetUnit = hostileTarget and "target" or nil

    -- Refreshes the engagement for an enemy player, or discards it if you are now
    -- fighting a creature (MarkEngaged does both)
    if inCombat and pressMode then
        self:MarkEngaged()
    end

    local sigName, sigEntry, sigCategory = self:GetSignatureEntry(spellID)

    -- Everyday moments: food, drink, a mount (out of combat)
    if not inCombat and not sigName and self:TryEverydayMoment(spellID, castRoute) then return end

    -- A known rival gets called out by name (signature moves only; see TryRivalOpener)
    if hostileTarget and self:TryRivalOpener(spellID, castRoute, sigName) then return end

    -- Filler moves never speak
    if not sigName then return end
    -- Every Nth cast (Abilities tab): quiet until this cast's turn comes round
    if not self:CastTurnAllowed(sigName) then return end

    -- Pull pacing against mobs (see GetPullPacing)
    local mobTarget = hostileTarget and not UnitIsPlayer("target")
    if mobTarget and (IsOffensiveSpell(spellID) or sigEntry.big or sigCategory == "Burst") then
        local state = self.State
        self:EnsurePullTarget()
        if not inCombat then
            -- An opening cast: if this pull will earn a line, say it now and let
            -- PLAYER_REGEN_DISABLED (a moment later) know the pull is already counted
            if (state.PullCount or 0) + 1 >= state.NextSpeechPull and self:SayPullLine(targetUnit, spellID, castRoute) then
                state.PrePullSpokeAt = GetTime()
                self:Debug("opening cast handled this pull's line")
                return
            end
        elseif state.PullSpeechArmed and not state.SpokeThisPull then
            if self:SayPullLine(targetUnit, spellID, castRoute) then return end
        end
    end

    -- Mid-fight: a big cooldown may speak on its own; against players any signature move may
    local deckKey, pool = self:ResolveSpellPool(sigName, sigEntry, targetUnit)
    if not pool or not inCombat then return end
    local isBig = sigEntry.big or sigCategory == "Burst"
    -- A class pack's own entry may set midChance (crowd control, interrupts, heals)
    local midChance = tonumber(sigEntry.midChance) or (sigCategory and Tune.ABILITY_MID_CHANCE[sigCategory])
    if not (isBig or midChance or (hostileTarget and not mobTarget)) then return end
    local allowed, why = self:FightLineAllowed(sigName, targetUnit, false)
    if not allowed then
        self:Debug("signature line skipped: " .. why)
        return
    end
    local spoke
    self.State.CurrentSpell = sigName
    if isBig then
        spoke = self:ProcessTrigger(1, deckKey, pool, BIG_SPELL_CHANCE, targetUnit, nil, "SAY", castRoute)
    elseif midChance and not (hostileTarget and not mobTarget) then
        spoke = self:ProcessTrigger(2, deckKey, pool, midChance, targetUnit, nil, "SAY", castRoute)
    else
        spoke = self:ProcessTrigger(2, deckKey, pool, PVP_SPELL_CHANCE, targetUnit, nil, "SAY", castRoute)
    end
    self.State.CurrentSpell = nil
    if spoke then self:NoteFightLine(sigName, targetUnit) end
end

---------------------------------------------------------------------------
-- Ability-Press Voice
-- A post-hook on the client's UseAction / CastSpellByName / CastSpellByID runs inside the
-- player's own key press or click, which the client accepts for /s (verified with
-- /mono probe). The press runs the normal cast logic (rival call-outs, pull lines, spell
-- reactions) with hardware = true, so lines go to /s instead of the chat frame.
-- Gates, all from MonologueDB.pressVoice (menu: My Voice tab):
--   * the master switch and the switch for the current kind of place,
--   * at least `gap` seconds between ability-press lines,
--   * the press must really cast (not on cooldown, out of range or unusable),
--   * a place where the client refused a line is switched off (pressVoiceBlocked).
-- When a gate says no, the cast falls through to the UNIT_SPELLCAST_SENT path as before.
---------------------------------------------------------------------------

local PRESS_PLACE_NAMES = {
    world = "open world", worldpvp = "world PvP", dungeon = "dungeons", raid = "raids",
    boss = "boss fights", battleground = "battlegrounds",
}

function Engine:DescribePressPlace(place)
    return PRESS_PLACE_NAMES[place] or tostring(place)
end

-- The kind of place you are in right now, as a pressVoice key
function Engine:GetPressPlace()
    if self.State.InEncounter then return "boss" end
    local _, instanceType = IsInInstance()
    instanceType = Clean(instanceType)
    if instanceType == "party" or instanceType == "scenario" then return "dungeon" end
    if instanceType == "raid" then return "raid" end
    if instanceType == "pvp" or instanceType == "arena" then return "battleground" end
    if UnitExists("target") and UnitIsPlayer("target") and UnitCanAttack("player", "target") then
        return "worldpvp"
    end
    return "world"
end

-- Returns true, place  or  false, reason
function Engine:PressVoiceAllowed()
    local settings = MonologueDB and MonologueDB.pressVoice
    if type(settings) ~= "table" or not settings.enabled then return false, "switched off in the menu" end
    local place = self:GetPressPlace()
    if not settings[place] then return false, self:DescribePressPlace(place) .. " switched off in the menu" end
    if MonologueDB.pressVoiceBlocked and MonologueDB.pressVoiceBlocked[place] then
        return false, "the client blocked /s in " .. self:DescribePressPlace(place)
    end
    return true, place
end

-- True when the press most likely started a cast: in range, and not on a cooldown that
-- began before this frame (a post-hook sees the cast's own cooldown start this frame).
-- No "usable" check: the hook runs after the cast, when its rage/mana is already spent,
-- so the spell reads as unusable even though it just went off.
local function PressLikelyCast(spellID)
    if C_Spell and C_Spell.IsSpellInRange and UnitExists("target") then
        local ok, inRange = pcall(C_Spell.IsSpellInRange, spellID, "target")
        if ok and Clean(inRange) == false then return false, "out of range" end
    end
    if C_Spell and C_Spell.GetSpellCooldown then
        local ok, info = pcall(C_Spell.GetSpellCooldown, spellID)
        if ok and type(info) == "table" then
            local start, duration = Clean(info.startTime), Clean(info.duration)
            if type(start) == "number" and type(duration) == "number" and start > 0 and duration > 0
                and start < GetTime() then
                return false, "on cooldown"
            end
        end
    end
    return true
end

function Engine:HandleAbilityPress(spellID, source)
    spellID = Clean(spellID)
    if not spellID or not MonologueDB or not MonologueCharDB then return end
    local state = self.State
    local now = GetTime()
    -- One press can pass through several hooks (a macro on a bar runs UseAction, then /cast)
    if state.LastPressAt == now then return end
    state.LastPressAt = now

    local allowed, placeOrReason = self:PressVoiceAllowed()
    if not allowed then
        self:Debug("ability press (" .. source .. "): no /s, " .. placeOrReason)
        return
    end
    local likely, why = PressLikelyCast(spellID)
    if not likely then
        -- Logged at most once per 10s per reason, so button-mashing doesn't flood the log
        state.PressSkipLog = state.PressSkipLog or {}
        if now - (state.PressSkipLog[why] or -math.huge) >= 10 then
            state.PressSkipLog[why] = now
            self:Debug("ability press (" .. source .. "): skipped, spell " .. why)
        end
        return
    end

    -- From here this press owns the cast: the UNIT_SPELLCAST_SENT pass won't speak for it
    state.PressHandled = { spellID = spellID, at = now }
    pcall(self.NoteCast, self, spellID)

    -- A waiting line (a greeting, a duel or PvP reaction) goes out on this press, spacing or not
    if state.Pending then
        state.PressSource = "press:" .. placeOrReason
        local okFlush, flushed = pcall(self.FlushPendingSpeech, self, "slash")
        state.PressSource = nil
        if okFlush and flushed then return end
    end

    -- Filler moves (Heroic Strike, Rend, ...) never speak in a fight. Out of combat with no
    -- enemy targeted, any press may carry idle chatter (clan, profession) now and then.
    local idleMoment = not UnitAffectingCombat("player")
        and not (UnitExists("target") and UnitCanAttack("player", "target"))
    -- A spell that speaks only for its kind (a heal, an attack) has nothing to say out of a
    -- fight, so out of combat it carries idle chatter like any other press
    local sigName, _, _, fromKind = self:GetSignatureEntry(spellID)
    local isSignature = sigName ~= nil and not (fromKind and idleMoment)
    if not isSignature and not idleMoment then return end
    local gap = MonologueDB.pressVoice.gap or 120
    local since = now - (state.LastPressLineAt or -math.huge)
    if not isSignature then
        if since < gap then return end
        state.PressSource = "press:" .. placeOrReason
        -- Everyday moments first: food, drink, a mount
        local okMoment, spokeMoment = pcall(self.TryEverydayMoment, self, spellID, true)
        if okMoment and spokeMoment then
            state.PressSource = nil
            state.LastPressLineAt = now
            state.PressQuietLogged = false
            return
        end
        local okIdle, spokeIdle = pcall(self.TryIdleLine, self, true)
        state.PressSource = nil
        if not okIdle then
            self:Debug("idle line error: " .. tostring(spokeIdle))
        elseif spokeIdle then
            -- An idle line counts toward the "wait at least" spacing like any other press line
            state.LastPressLineAt = now
            state.PressQuietLogged = false
        end
        return
    end
    if since < gap then
        -- Said once per quiet stretch, not on every press
        if not state.PressQuietLogged then
            state.PressQuietLogged = true
            self:Debug(string.format("ability press: quiet until the spacing is up (next /s line possible in %.0fs)", gap - since))
        end
        return
    end

    local before = state.LastSpeechTime
    state.PressSource = "press:" .. placeOrReason
    state.PressAllowBoss = placeOrReason == "boss"
    local ok, err = pcall(self.HandleSpellcast, self, spellID, true)
    state.PressSource, state.PressAllowBoss = nil, nil
    if not ok then
        self:Debug("ability press error: " .. tostring(err))
        return
    end
    if state.LastSpeechTime == before then
        -- Nothing was due this press (pull not armed yet, reaction roll missed, ...)
        state.PressSkipLog = state.PressSkipLog or {}
        if now - (state.PressSkipLog.nothingDue or -math.huge) >= 10 then
            state.PressSkipLog.nothingDue = now
            self:Debug("ability press: no line due yet (" .. self:DescribePullProgress() .. ")")
        end
    else
        state.LastPressLineAt = now
        state.PressQuietLogged = false
        self:Debug("ability press (" .. self:DescribePressPlace(placeOrReason) .. "): line said; next one in "
            .. gap .. "s or later")
    end
end

local pressHooksInstalled = false

local function SpellFromAction(slot)
    if type(slot) ~= "number" then return nil end
    local ok, actionType, id = pcall(GetActionInfo, slot)
    if not ok then return nil end
    actionType, id = Clean(actionType), Clean(id)
    if actionType == "spell" then return id end
    if actionType == "macro" and GetMacroSpell then
        local okMacro, spellID = pcall(GetMacroSpell, id)
        if okMacro then return Clean(spellID) end
    end
    return nil
end

local function SpellFromName(name)
    if type(name) ~= "string" or not (C_Spell and C_Spell.GetSpellInfo) then return nil end
    local ok, info = pcall(C_Spell.GetSpellInfo, name)
    return ok and type(info) == "table" and Clean(info.spellID) or nil
end

function Engine:InstallPressHooks()
    if pressHooksInstalled then return end
    pressHooksInstalled = true
    if type(UseAction) == "function" then
        pcall(hooksecurefunc, "UseAction", function(slot)
            Engine:HandleAbilityPress(SpellFromAction(slot), "UseAction")
        end)
    end
    if type(CastSpellByName) == "function" then
        pcall(hooksecurefunc, "CastSpellByName", function(name)
            Engine:HandleAbilityPress(SpellFromName(name), "CastSpellByName")
        end)
    end
    if type(CastSpellByID) == "function" then
        pcall(hooksecurefunc, "CastSpellByID", function(spellID)
            Engine:HandleAbilityPress(spellID, "CastSpellByID")
        end)
    end
    -- No jump or movement hooks: /mono probe showed the client doesn't treat those keys as
    -- key presses for chat on the ground. Waiting lines go out on ability presses and clicks.
end

---------------------------------------------------------------------------
-- Event Listeners
---------------------------------------------------------------------------

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("ENCOUNTER_START")
frame:RegisterEvent("ENCOUNTER_END")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
SafeRegisterEvent(frame, "ADDON_RESTRICTION_STATE_CHANGED")
SafeRegisterEvent(frame, "ADDON_ACTION_FORBIDDEN")
SafeRegisterEvent(frame, "ADDON_ACTION_BLOCKED")
SafeRegisterEvent(frame, "PLAYER_GUILD_UPDATE")
-- PvP kill credit (the combat log is restricted, so these stand in for it)
SafeRegisterEvent(frame, "UPDATE_MOUSEOVER_UNIT")
SafeRegisterEvent(frame, "PLAYER_PVP_KILLS_CHANGED")
SafeRegisterEvent(frame, "CHAT_MSG_COMBAT_HONOR_GAIN")
-- Duels (tracked separately from Rivals)
SafeRegisterEvent(frame, "DUEL_REQUESTED")
SafeRegisterEvent(frame, "RESURRECT_REQUEST")
SafeRegisterEvent(frame, "PLAYER_UNGHOST")
SafeRegisterEvent(frame, "PLAYER_ALIVE")
SafeRegisterEvent(frame, "DUEL_INBOUNDS")
SafeRegisterEvent(frame, "DUEL_FINISHED")
SafeRegisterEvent(frame, "CHAT_MSG_SYSTEM")
SafeRegisterEvent(frame, "CHAT_MSG_TEXT_EMOTE")
SafeRegisterEvent(frame, "ZONE_CHANGED_NEW_AREA")
SafeRegisterEvent(frame, "ZONE_CHANGED")
SafeRegisterEvent(frame, "LOOT_OPENED")
SafeRegisterEvent(frame, "TAXIMAP_OPENED")
SafeRegisterEvent(frame, "MAIL_SHOW")
SafeRegisterEvent(frame, "TRAINER_SHOW")
SafeRegisterEvent(frame, "QUEST_COMPLETE")
SafeRegisterEvent(frame, "MERCHANT_SHOW")
SafeRegisterEvent(frame, "TRADE_SKILL_SHOW")
SafeRegisterEvent(frame, "UI_ERROR_MESSAGE")
SafeRegisterEvent(frame, "MIRROR_TIMER_START")
SafeRegisterEvent(frame, "MIRROR_TIMER_STOP")
SafeRegisterEvent(frame, "CHAT_MSG_MONSTER_YELL")
SafeRegisterEvent(frame, "SKILL_LINES_CHANGED")
SafeRegisterEvent(frame, "UPDATE_INVENTORY_DURABILITY")
SafeRegisterEvent(frame, "GROUP_ROSTER_UPDATE")
SafeRegisterEvent(frame, "CHAT_MSG_ADDON")
SafeRegisterEvent(frame, "CHAT_MSG_SAY")
SafeRegisterEvent(frame, "CHAT_MSG_YELL")
SafeRegisterEvent(frame, "CHAT_MSG_EMOTE")
-- Everyday moments: resting (inn or city) and a party member falling
SafeRegisterEvent(frame, "PLAYER_UPDATE_RESTING")
do
    local allyFrame = CreateFrame("Frame")
    SafeRegisterEvent(allyFrame, "UNIT_HEALTH")
    allyFrame:SetScript("OnEvent", function(_, _, unit)
        if type(unit) ~= "string" or unit:sub(1, 5) ~= "party" or not MonologueDB then return end
        if unit:find("^party%d$") then pcall(Engine.CheckAllyDown, Engine, unit) end
    end)
end
-- Pets: summoned (UNIT_PET) or fallen (the pet's health). A loading screen resets the
-- watch so the pet coming back with you says nothing.
do
    local petFrame = CreateFrame("Frame")
    pcall(petFrame.RegisterUnitEvent, petFrame, "UNIT_PET", "player")
    pcall(petFrame.RegisterUnitEvent, petFrame, "UNIT_HEALTH", "pet")
    SafeRegisterEvent(petFrame, "PLAYER_ENTERING_WORLD")
    petFrame:SetScript("OnEvent", function(_, event)
        if not MonologueDB or not MonologueCharDB then return end
        if event == "PLAYER_ENTERING_WORLD" then Engine.State.PetReady = false end
        if event == "UNIT_HEALTH" then
            pcall(Engine.HandlePetHealth, Engine)
        else
            pcall(Engine.HandlePetChanged, Engine)
        end
    end)
end
-- A new shield: equipped in the off-hand slot, or looted / handed over as a reward. Says
-- something only when the profile (or race pack) has Moments.ShieldEquip lines, such as
-- Carl the engineer, who can't put a spike on it. The pool may name a profession it needs
-- (requiresProfession) and one it must not have (withoutProfession), checked against the
-- My Voice profession or the ones detected. A loading screen just remembers the shield.
Tune.MOMENTS.ShieldEquip = { chance = 0.6, cooldown = 300 }
function Engine:IsShieldItem(item)
    local getInfo = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
    if not item or type(getInfo) ~= "function" then return false end
    local ok, _, _, _, equipLoc = pcall(getInfo, item)
    return ok and Clean(equipLoc) == "INVTYPE_SHIELD"
end

function Engine:ShieldQuirkPool()
    local moments = self.ActiveProfile and self.ActiveProfile.Moments
    local pool = type(moments) == "table" and moments.ShieldEquip or nil
    if not UsablePool(pool) then return nil end
    local have = {}
    for _, key in ipairs(self:GetProfessionKeys()) do have[key] = true end
    if pool.requiresProfession and not have[pool.requiresProfession] then return nil end
    if pool.withoutProfession and have[pool.withoutProfession] then return nil end
    return pool
end

function Engine:HandleShieldEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self.State.ShieldID = Clean(GetInventoryItemID("player", 17))
        return
    end
    local shield
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        if (...) ~= 17 then return end
        local id = Clean(GetInventoryItemID("player", 17))
        if not id or id == self.State.ShieldID then return end
        self.State.ShieldID = id
        shield = self:IsShieldItem(id)
    elseif event == "CHAT_MSG_LOOT" then
        local message = Clean((...))
        if type(message) ~= "string" then return end
        local mine = false
        for _, format in ipairs({ LOOT_ITEM_SELF, LOOT_ITEM_PUSHED_SELF, LOOT_ITEM_SELF_MULTIPLE, LOOT_ITEM_PUSHED_SELF_MULTIPLE }) do
            local prefix = type(format) == "string" and format:match("^(.-)%%s") or nil
            if prefix and prefix ~= "" and message:sub(1, #prefix) == prefix then mine = true; break end
        end
        local id = mine and tonumber(message:match("|Hitem:(%d+)")) or nil
        shield = id and self:IsShieldItem(id)
    end
    if shield and self:ShieldQuirkPool() then self:SayMoment("ShieldEquip") end
end
do
    local shieldFrame = CreateFrame("Frame")
    SafeRegisterEvent(shieldFrame, "PLAYER_EQUIPMENT_CHANGED")
    SafeRegisterEvent(shieldFrame, "CHAT_MSG_LOOT")
    SafeRegisterEvent(shieldFrame, "PLAYER_ENTERING_WORLD")
    shieldFrame:SetScript("OnEvent", function(_, event, ...)
        if not MonologueDB or not MonologueCharDB then return end
        pcall(Engine.HandleShieldEvent, Engine, event, ...)
    end)
end
-- Falling has no event: checked a few times a second
do
    local fallFrame = CreateFrame("Frame")
    local elapsed = 0
    fallFrame:SetScript("OnUpdate", function(_, delta)
        elapsed = elapsed + delta
        if elapsed < 0.25 then return end
        elapsed = 0
        if MonologueDB and MonologueCharDB and MonologueDB.momentLines ~= false then
            pcall(Engine.CheckFalling, Engine)
        end
    end)
end

unitFrame:RegisterUnitEvent("UNIT_HEALTH", "player", "target", "mouseover")
-- UNIT_SPELLCAST_SENT fires as the player's cast is sent, i.e. during their own key press or
-- click, so speech triggered from it counts as a hardware-event action
unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_SENT", "player")

local RESTRICTION_INACTIVE = Enum and Enum.AddOnRestrictionState and Enum.AddOnRestrictionState.Inactive or 0

-- Restriction types that actually limit chat. Combat (active during ALL combat) and Map
-- restrict secret values, not chat, so they must not trigger Safe-Mode. Unknown types are
-- treated the same way; ENCOUNTER_START and InChatMessagingLockdown cover the rest.
local CHAT_RESTRICTING_TYPES = {}
do
    local restrictionTypes = Enum and Enum.AddOnRestrictionType
    if type(restrictionTypes) == "table" then
        for _, name in ipairs({ "Encounter", "ChallengeMode", "PvPMatch" }) do
            if restrictionTypes[name] ~= nil then
                CHAT_RESTRICTING_TYPES[restrictionTypes[name]] = true
            end
        end
    end
end

frame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == ADDON_NAME then
            Engine:InitializeDB()
            frame:UnregisterEvent("ADDON_LOADED")
        end

    elseif event == "PLAYER_LOGIN" then
        if not MonologueDB or not MonologueCharDB then Engine:InitializeDB() end
        Engine.State.WasResting = Clean(IsResting()) and true or false
        if MonologueDB and MonologueDB.outOfCharacter then
            C_Timer.After(8, function()
                Print("|cffaaaaaaYou're out of character|r (no translation, no automatic lines). /mono ic or the keybind turns it back on.")
            end)
        end
        Engine.State.InEncounter = (IsEncounterInProgress and IsEncounterInProgress()) and true or false
        Engine:UpdateRestrictionState()
        Engine:BuildActiveProfile()
        Engine:InstallPressHooks()
        pcall(Engine.HandleZoneChange, Engine, false, true)
        pcall(Engine.HandleRosterUpdate, Engine)
        C_Timer.After(10, function() pcall(Engine.AnnounceVersion, Engine) end)
        if not MonologueCharDB.welcomed then
            C_Timer.After(6, function()
                if MonologueUI and MonologueUI.ShowWelcome then MonologueUI:ShowWelcome() end
            end)
        elseif not MonologueDB.simpleIntroShown then
            -- Players from before the simple menu: one card (per account) to try it and say
            -- what they think. Brand-new players get the welcome card instead.
            C_Timer.After(6, function()
                if MonologueUI and MonologueUI.ShowSimpleIntro then MonologueUI:ShowSimpleIntro() end
            end)
        end
        -- BugGrabber users: also take its captures (it may own the error handler)
        if type(BugGrabber) == "table" and type(BugGrabber.RegisterCallback) == "function" then
            pcall(BugGrabber.RegisterCallback, Engine, "BugGrabber_BugGrabbed", function(_, err)
                pcall(CaptureError, type(err) == "table" and err.message or err)
            end)
        end
        Engine:PruneRivals(MAX_RIVALS)
        Engine:PruneSkirmishHistory(MAX_SKIRMISH_ZONES)
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffMonologue (v.1)|r core engine initialized.")

    elseif event == "PLAYER_LEVEL_UP" then
        local newLevel = ...
        Engine:BuildActiveProfile(newLevel)
        local recent = Engine:GetRecent()
        recent.levelAt, recent.levelUsed = GetTime(), nil
        if MonologueDB and IsInGroup and IsInGroup() then pcall(Engine.SendBanterTopic, Engine, "Level") end

    elseif event == "ADDON_RESTRICTION_STATE_CHANGED" then
        local restrictionType, restrictionState = ...
        if type(restrictionType) == "boolean" then
            -- Untyped form: it also fires for ordinary combat, so it can't tell us chat is
            -- blocked. Informational only; encounters come from ENCOUNTER_START and the
            -- client's own InChatMessagingLockdown answer.
            Engine.State.OtherRestrictions.default = restrictionType
        elseif restrictionState ~= nil then
            local active = (restrictionState ~= RESTRICTION_INACTIVE and restrictionState ~= false)
            if CHAT_RESTRICTING_TYPES[restrictionType] then
                Engine.State.Restrictions[restrictionType] = active
            else
                -- Combat, Map and other types: tracked for /mono status, never block chat
                Engine.State.OtherRestrictions[restrictionType or "default"] = active
            end
        else
            -- Single-value form: no type given, treated like the untyped boolean above
            Engine.State.OtherRestrictions.default = (restrictionType ~= nil and restrictionType ~= RESTRICTION_INACTIVE)
        end
        Engine:UpdateRestrictionState()

    elseif event == "ADDON_ACTION_FORBIDDEN" or event == "ADDON_ACTION_BLOCKED" then
        -- A send the client refused names this addon and the blocked function
        local blockedAddon, blockedFunction = ...
        if blockedAddon == ADDON_NAME then
            Engine:Diag(event .. ": " .. tostring(blockedFunction))
            Engine.State.SendBlockedBy = tostring(blockedFunction)
            local st = Engine.State
            -- Only a refused chat send counts (not, say, a blocked emote or frame action)
            -- Our chat send, even when the client names the blocked function UNKNOWN()
            local isChat = st.Sending or tostring(blockedFunction):find("SendChatMessage", 1, true)
            local recent = GetTime() - (st.LastSendAt or 0) < 2
            -- Ability-press voice refused in one place (e.g. raids): switch off just that place
            local pressPlace = type(st.LastSendSource) == "string" and st.LastSendSource:match("^press:(.+)$")
            if MonologueDB and pressPlace and isChat and recent and type(MonologueDB.pressVoiceBlocked) == "table"
                and not MonologueDB.pressVoiceBlocked[pressPlace] then
                MonologueDB.pressVoiceBlocked[pressPlace] = true
                Print("The client blocked a /s line here (" .. Engine:DescribePressPlace(pressPlace) .. "). Ability-press voice is now off "
                    .. "for this kind of place; lines show in your chat frame instead. /mono castchat retry to test again.")
            end
            -- Debug mode: show the blocked function and the call stack right now, so the
            -- exact trigger is caught live
            if MonologueDB and MonologueDB.debugMode then
                Engine:Debug(event .. ": " .. tostring(blockedFunction) .. " was blocked")
                local stack = debugstack(2, 4, 0)
                if type(stack) == "string" then
                    for line in stack:gmatch("[^\n]+") do
                        Engine:Debug("  " .. line)
                    end
                end
            end
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Combat ended: reset the per-fight cast tracking. Nothing is sent from here:
        -- PLAYER_REGEN_ENABLED is a background event, and SendChatMessage from a background
        -- event raises ADDON_ACTION_BLOCKED. A held line waits for the next hardware action.
        wipe(Engine.State.EngagementCasts)
        -- Repeat guards count per fight
        Engine.State.CombatLines = 0
        Engine.State.SpellsSaid = nil
        if MonologueDB and MonologueCharDB then pcall(Engine.OnCombatEndParty, Engine) end

    elseif event == "PLAYER_UPDATE_RESTING" then
        pcall(Engine.HandleRestingChanged, Engine)

    elseif event == "ENCOUNTER_START" then
        Engine.State.InEncounter = true
        Engine:UpdateRestrictionState()

    elseif event == "ENCOUNTER_END" then
        local encounterID, _, _, _, success = ...
        Engine.State.InEncounter = false
        Engine:UpdateRestrictionState()
        encounterID = Clean(encounterID)
        if Clean(success) == 1 and encounterID then
            local featKey = Engine:GetFeatForEncounter(encounterID)
            if featKey then Engine:UnlockFeat(featKey) end
            -- A boss down: the party's victory line (the combat-end check then skips it)
            if MonologueDB and MonologueCharDB and IsInGroup() then
                Engine.State.BossVictorySaid = true
                pcall(Engine.HandleGroupVictory, Engine, "boss")
            end
        end

    elseif event == "PLAYER_GUILD_UPDATE" then
        -- Guild info often isn't available at login and can change later (join, leave,
        -- rename); rebuild only when the player's guild actually differs from the build.
        local unit = ...
        if (unit == nil or unit == "player") and MonologueDB and MonologueCharDB then
            if Clean(GetGuildInfo("player")) ~= Engine.ActiveContext.guildName then
                Engine:BuildActiveProfile()
            end
        end

    elseif event == "PLAYER_TARGET_CHANGED" then
        Engine:HandleTargetChanged()

    elseif event == "PLAYER_REGEN_DISABLED" then
        Engine:MarkEngaged()
        Engine:OnPullStart()

    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        Engine:RefreshStoredNames("mouseover")
        Engine:TrackHostile("mouseover")
        if MonologueDB and MonologueCharDB then pcall(Engine.CheckNemesisSpot, Engine, "mouseover") end

    elseif event == "PLAYER_PVP_KILLS_CHANGED" then
        Engine:HandlePvPKillsChanged()

    elseif event == "CHAT_MSG_COMBAT_HONOR_GAIN" then
        Engine:HandleHonorGain((...))

    elseif event == "DUEL_REQUESTED" or event == "DUEL_INBOUNDS" or event == "DUEL_FINISHED" then
        Engine:HandleDuelEvent(event, ...)

    elseif event == "CHAT_MSG_TEXT_EMOTE" then
        -- text, sender, ..., guid is the 12th argument
        local text, sender = ...
        local guid = select(12, ...)
        Engine:HandleTextEmote(text, sender, guid)

    elseif event == "CHAT_MSG_SYSTEM" then
        Engine:HandleSystemMessage((...))

    elseif event == "PLAYER_DEAD" then
        Engine:HandlePlayerDeath()

    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" then
        Engine:HandleZoneChange(event == "ZONE_CHANGED_NEW_AREA")

    elseif event == "LOOT_OPENED" then
        if MonologueDB and MonologueCharDB then Engine:HandleLootOpened() end

    elseif event == "TAXIMAP_OPENED" or event == "MAIL_SHOW" or event == "TRAINER_SHOW" or event == "QUEST_COMPLETE"
        or event == "MERCHANT_SHOW" or event == "TRADE_SKILL_SHOW" then
        local moment = (event == "TAXIMAP_OPENED" and "FlightMaster") or (event == "MAIL_SHOW" and "Mailbox")
            or (event == "TRAINER_SHOW" and "Trainer") or (event == "MERCHANT_SHOW" and "Merchant")
            or (event == "TRADE_SKILL_SHOW" and "Crafting") or "QuestDone"
        pcall(Engine.HandleNpcVisit, Engine, moment)

    elseif event == "UI_ERROR_MESSAGE" then
        if MonologueDB and MonologueCharDB then pcall(Engine.HandleUiError, Engine, ...) end

    elseif event == "MIRROR_TIMER_START" or event == "MIRROR_TIMER_STOP" then
        if MonologueDB and MonologueCharDB then pcall(Engine.HandleMirrorTimer, Engine, event, ...) end

    elseif event == "CHAT_MSG_MONSTER_YELL" then
        local _, npcName = ...
        pcall(Engine.HandleMonsterYell, Engine, npcName)

    elseif event == "SKILL_LINES_CHANGED" then
        Engine.State.ProfessionCache = nil

    elseif event == "UPDATE_INVENTORY_DURABILITY" then
        if MonologueDB and MonologueCharDB then Engine:HandleDurability() end

    elseif event == "RESURRECT_REQUEST" then
        local inviter = ShortName((...))
        if inviter then Engine.State.RezBy = { name = inviter, at = GetTime() } end

    elseif event == "PLAYER_UNGHOST" or event == "PLAYER_ALIVE" then
        if MonologueDB and MonologueCharDB then pcall(Engine.ThankRezzer, Engine) end

    elseif event == "GROUP_ROSTER_UPDATE" then
        if MonologueDB and MonologueCharDB then Engine:HandleRosterUpdate() end

    elseif event == "CHAT_MSG_ADDON" then
        if MonologueDB and MonologueCharDB then
            local prefix, text, channel, sender = ...
            if prefix == "MONO_VER" then
                pcall(Engine.HandleVersionMessage, Engine, text, channel, sender)
            else
                Engine:HandleAddonMessage(...)
            end
        end

    elseif event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" or event == "CHAT_MSG_EMOTE" then
        if MonologueDB and MonologueCharDB then
            local text, sender = ...
            pcall(Engine.HandleGroupChat, Engine, text, sender)
        end
    end
end)

unitFrame:SetScript("OnEvent", function(_, event, unit, ...)
    if not MonologueDB or not MonologueCharDB then return end

    if event == "UNIT_HEALTH" then
        if unit == "player" then
            Engine:HandlePlayerHealth()
        elseif unit == "target" or unit == "mouseover" then
            Engine:HandleUnitHealth(unit)
        end

    elseif event == "UNIT_SPELLCAST_SENT" then
        -- args after the unit: target name, castGUID, spellID
        local _, _, spellID = ...
        Engine:HandleSpellcast(spellID)
    end
end)

---------------------------------------------------------------------------
-- Ability-press probe (/mono probe)
-- One-shot test: does code running inside the player's own ability press (a post-hook on
-- the client's "use action" / "cast spell" calls, or on an action button click) count as
-- a real key press, so /s may be sent from it? Arm it, press any ability, and it reports
-- SENT or BLOCKED. The hooks do nothing unless a probe is armed.
---------------------------------------------------------------------------

local PROBE_LINE = "Right then."
local PROBE_TIMEOUT = 60
local probeHooks = {}        -- names of the hooks that were installed
local probeHooksInstalled = false

local function ProbeFire(hookName)
    local probe = Engine.State.Probe
    if not probe then return end
    Engine.State.Probe = nil   -- one shot: disarm before anything else
    if GetTime() - probe.armedAt > PROBE_TIMEOUT then
        Print("Probe expired (no ability press within " .. PROBE_TIMEOUT .. "s). Type /mono probe again.")
        return
    end

    local sent, problem = Engine:TrySend(PROBE_LINE, "SAY", true)
    if problem == "ratelimited" then
        Print("Probe: a line went out less than 6 seconds ago. Wait a moment and type /mono probe again.")
        return
    end
    Engine.State.LastSendSource = "probe:" .. hookName
    -- ADDON_ACTION_BLOCKED may arrive a moment after the call, so report shortly after
    C_Timer.After(0.5, function()
        local blockedBy = Engine.State.SendBlockedBy
        if sent and not blockedBy then
            Print("|cff00ff00Probe: /s from " .. hookName .. " was SENT.|r This key counts as a key press for /s lines.")
        else
            Print("|cffff8800Probe: /s from " .. hookName .. " was BLOCKED|r ("
                .. tostring(blockedBy or problem or "unknown reason") .. "). This key can't be used for /s lines.")
        end
    end)
end

local function InstallProbeHooks()
    if probeHooksInstalled then return end
    probeHooksInstalled = true

    -- Ability presses, plus the movement and jump keys (to test whether a plain step or jump
    -- counts as a key press too, for saying greetings aloud on your next key press)
    for _, name in ipairs({ "UseAction", "CastSpellByName", "CastSpellByID", "ActionButtonDown", "ActionButtonUp",
                            "MoveForwardStart", "MoveBackwardStart", "StrafeLeftStart", "StrafeRightStart",
                            "TurnLeftStart", "TurnRightStart", "JumpOrAscendStart", "ToggleAutoRun",
                            "MoveAndSteerStart" }) do
        if type(_G[name]) == "function" then
            local ok = pcall(hooksecurefunc, name, function() ProbeFire(name) end)
            if ok then probeHooks[#probeHooks + 1] = name end
        end
    end

    local buttons = 0
    for _, prefix in ipairs({ "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton",
                              "MultiBarRightButton", "MultiBarLeftButton" }) do
        for i = 1, 12 do
            local button = _G[prefix .. i]
            if button and button.HookScript then
                local ok = pcall(button.HookScript, button, "OnClick", function() ProbeFire("button click (" .. prefix .. i .. ")") end)
                if ok then buttons = buttons + 1 end
            end
        end
    end
    if buttons > 0 then probeHooks[#probeHooks + 1] = buttons .. " action-bar button clicks" end
end

function Engine:ArmProbe()
    InstallProbeHooks()
    if #probeHooks == 0 then
        Print("Probe: no hooks could be installed on this client, so ability presses can't be tested.")
        return
    end
    self.State.Probe = { armedAt = GetTime() }
    Print("Probe armed. Press any ability within " .. PROBE_TIMEOUT .. "s; your character will try to /s \""
        .. PROBE_LINE .. "\" once. If the client refuses, you may see one \"Interface action failed\" warning; that's expected.")
    Print("Hooks installed: " .. table.concat(probeHooks, ", "))
end

---------------------------------------------------------------------------
-- Slash Command Handler
---------------------------------------------------------------------------

local function PrintStatus()
    local ctx = Engine.ActiveContext or {}
    local state = Engine.State
    Print("Engine " .. (MonologueDB.enabled and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r")
        .. " | Intensity " .. tostring(MonologueDB.translationIntensity)
        .. " | Chattiness " .. string.format("%.2f", MonologueDB.chattiness)
        .. " | Debug " .. (MonologueDB.debugMode and "|cff00ff00ON|r" or "off"))
    Print("Layers: race=" .. tostring(ctx.race) .. ", class=" .. tostring(ctx.class)
        .. ", persona=" .. tostring(ctx.persona) .. ", guild pack=" .. tostring(ctx.guild)
        .. " (guild: " .. tostring(ctx.guildName) .. "), profile=" .. tostring(ctx.profile)
        .. ", My Voice=" .. (ctx.customVoice and "|cff00ff00active|r" or "none"))
    if not Engine:HasCustomVoice() then
        Print("|cff00ccffNew here?|r Type /mono, then open the |cffffd100My Voice|r tab to set your own oaths, swaps and battle cries in-game.")
    end
    Print("Growth: level " .. tostring(ctx.level) .. " -> " .. tostring(ctx.arc) .. " (" .. tostring(ctx.stageKey) .. ")"
        .. " | Feats active: " .. ((ctx.feats and #ctx.feats > 0) and table.concat(ctx.feats, ", ") or "none"))
    local breathLeft = math.max(0, Engine.Cooldowns.GlobalBreath - GetTime())
    Print("Safe-Mode: " .. (state.InRestrictedEncounter and "|cffff8800ACTIVE|r" or "off")
        .. " | Breath lock: " .. string.format("%.0fs", breathLeft)
        .. " | Background speech: " .. tostring(MonologueDB.backgroundSpeech)
        .. " | Mood: " .. (Engine:GetMood() or "normal")
        )
    local _, _, pacing = Engine:GetPullPacing()
    Print("Combat pacing vs mobs: one /s line " .. pacing .. " | " .. Engine:DescribePullProgress())
    local pressOk, pressInfo = Engine:PressVoiceAllowed()
    local gapLeft = math.max(0, (MonologueDB.pressVoice.gap or 120) - (GetTime() - (state.LastPressLineAt or -math.huge)))
    Print("Ability-press /s here: " .. (pressOk and ("|cff00ff00on|r (" .. Engine:DescribePressPlace(pressInfo) .. ")")
        or ("|cffff8800off|r (" .. pressInfo .. ")"))
        .. (pressOk and gapLeft > 0 and string.format(" | next line possible in %.0fs", gapLeft) or ""))

    -- Chat gate: what the client says right now, and what is waiting to be sent
    local blockKind, blockReason = Engine:GetChatBlock()
    local otherActive = {}
    for restrictionType, active in pairs(state.OtherRestrictions) do
        if active then otherActive[#otherActive + 1] = tostring(restrictionType) end
    end
    table.sort(otherActive)
    Print("Chat: " .. (blockKind and ("|cffff8800blocked|r - " .. blockReason) or "|cff00ff00open|r")
        .. " | Non-chat restrictions active (type ids): "
        .. (#otherActive > 0 and table.concat(otherActive, ", ") or "none"))
    if state.Pending then
        Print("Queued line: waiting to be said on your next action (a spell cast or a /mono command).")
    end

    -- Shown once per problem so repeated /mono status calls stay quiet
    local problem = state.SendProblem
    if problem and not problem.shown then
        problem.shown = true
        Print("|cffff8800Last send problem:|r " .. problem.reason
            .. (state.Pending and " (the line is queued)" or ""))
    end
end

local function PrintRivals()
    local list = {}
    for key, rival in pairs(MonologueCharDB.Rivals or {}) do
        list[#list + 1] = {
            name = rival.name or key, rival = rival, total = (rival.kills or 0) + (rival.deaths or 0),
        }
    end
    if #list == 0 then
        Print("Nemesis ledger is empty.")
        return
    end
    table.sort(list, function(a, b) return a.total > b.total end)
    Print("Nemesis ledger (" .. #list .. " rivals, top 10):")
    for i = 1, math.min(10, #list) do
        local entry = list[i]
        DEFAULT_CHAT_FRAME:AddMessage(string.format("  %s%s - %d kills / %d deaths, last seen in %s [%s]",
            entry.name, entry.rival.pinned and " |cffffd100(pinned)|r" or "",
            entry.rival.kills or 0, entry.rival.deaths or 0,
            entry.rival.lastZone or "the wild", Engine:GetRivalTier(entry.name)))
    end
end

local function PrintHelp()
    Print("Commands:")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono ui - open the config panel")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono toggle - enable/disable the engine")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono reload - reassemble the active profile")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono status - show layers, growth stage and safe-mode")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono hooks - show chat-hook status and why the last message was or wasn't translated")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono triggers - verify the class pack's spell IDs against this client")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono spellid - toggle printing the ID of every spell you cast")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono chatty <0-3> - set proc chance multiplier")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono background <local|queue> - speech from background events (greetings, duel/PvP reactions): print in your chat frame, or say one line on your next action")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono cry [yell|say] - shout a battle cry now (works in the open world)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono crychannel <yell|say> - default channel for battle cries")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono button - show or hide the Battle Cry button")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono probe - test once whether /s can be sent from an ability press on this client")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono situations - list what your lines could react to right now (target, your state, memory)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono tokens - show the live details lines can use ({weapon}, {spell}, {party}, ...)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono identity - show your clan, hometown, allegiance and profession (set them on the My Voice tab)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono party - list party members who run Monologue (party banter)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono bug - make a bug report to copy into Discord (alpha testing)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono safemode - Strict Safe-Mode: automated lines only show in your own chat")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono welcome - show the welcome card again   /mono version - show your version")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono castchat [retry] - show (or reset) places where the client blocked ability-press /s lines")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono greet - say hello to your friendly player target now (or say a waiting greeting)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono ic | ooc - in character (translate, speak) or out of character (also a keybind)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono keep <word> | unkeep <word> - words that are never translated (/mono keep lists them)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono mood <grim|weary|cheerful|fierce|off> - how your character feels today")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono say <idle|kill|pull|hurt|interrupt|heal|defend|greet|cry> [chance %] - a line on demand, for macros")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono map <spell> <attack|burst|defend|interrupt|heal|none|auto> - what kind of move a spell is (/mono map lists yours)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono test <text> - show what a message would turn into, without sending it")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono taunt - taunt your enemy player target now (also a button and a keybind)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono taunts <off|civil|rough|savage> - how mean you are to the other faction")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono nicknames <off|enemy|all> - race nicknames in your chat (orcs -> green skins)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono sendkey <enter|shift|ctrl> - translate typed chat on Enter, or only on Shift+Enter / Ctrl+Enter")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono abilities - open the Abilities tab (spell kinds, your own lines, quirks, pacing)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono quirks - list your quirks (when something happens, say one of your lines)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono simple | full - open the simple one-page menu, or all the options")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono lines - open the Voice Lines tab (where and how often /s lines are said)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono voice - open the My Voice tab (custom oaths, swaps, battle cries, export/import)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono roster - open the Rivals & Friends roster window")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono minimap [reset] - show or hide the minimap button (reset: default spot, shown)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono friend [note] - mark your friendly target as a friend (or update their note)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono unfriend [name] - unmark your target, or the named friend | /mono friends - list")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono feat <KEY> - unlock a boss feat | /mono feats - list feats")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono rivals - show the Nemesis ledger")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono debug [on|off] - toggle [Monologue Debug] output (speech routing, PvP, duels, name upgrades, blocked actions); /mono pvpdebug is an alias")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono duels - list your duel records (kept separate from rivals)")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono namecheck - show what each name API returns for your target")
    DEFAULT_CHAT_FRAME:AddMessage("  /mono pin <name> | /mono unpin <name> - protect a rival from pruning")
end

SLASH_MONOLOGUE1 = "/mono"
SLASH_MONOLOGUE2 = "/monologue"
SlashCmdList["MONOLOGUE"] = function(msg)
    if not MonologueDB or not MonologueCharDB then return end
    local cmd, arg = strsplit(" ", strtrim(msg or ""), 2)
    cmd = string.lower(cmd or "")
    arg = arg and strtrim(arg) or nil

    -- Using a /mono command (or the HUD and minimap buttons that run one) is a hardware
    -- event: say a line that was held back from a background event
    local flushed = false
    if cmd ~= "greet" then flushed = Engine:FlushPendingSpeech("slash") end

    if cmd == "ui" or cmd == "config" or cmd == "" then
        if MonologueUI and MonologueUI.Toggle then
            MonologueUI:Toggle()
        else
            Print("Config panel module is not loaded.")
        end

    elseif cmd == "toggle" then
        MonologueDB.enabled = not MonologueDB.enabled
        Print("Engine is now " .. (MonologueDB.enabled and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"))

    elseif cmd == "reload" then
        Engine:BuildActiveProfile()
        Print("Profile reassembled.")

    elseif cmd == "status" then
        PrintStatus()

    elseif cmd == "triggers" then
        local report = Engine:ValidateSpellTriggers()
        if report.total == 0 then
            Print("The active profile has no SpellTriggers (no class pack, or the pack defines none).")
        else
            Print(string.format("SpellTriggers: %d entries, %d verified, %d need attention.",
                report.total, report.ok, #report.problems))
            for i, problem in ipairs(report.problems) do
                if i > 25 then
                    DEFAULT_CHAT_FRAME:AddMessage("  ... and " .. (#report.problems - 25) .. " more")
                    break
                end
                if problem.status == "unknown" then
                    DEFAULT_CHAT_FRAME:AddMessage(string.format("  |cffff8800ID %d is not a spell on this client|r (expected %s)",
                        problem.id, problem.expected or "?"))
                else
                    DEFAULT_CHAT_FRAME:AddMessage(string.format("  |cffff8800ID %d is %s, expected %s|r",
                        problem.id, problem.actual, problem.expected))
                end
            end
        end

    elseif cmd == "namecheck" then
        -- Shows what each name API returns for your target, to see which one has the last name
        local unit = UnitExists("target") and "target" or (UnitExists("mouseover") and "mouseover" or nil)
        if not unit then
            Print("Target (or mouse over) a player first, then run /mono namecheck.")
        else
            local fullName, fullRealm = UnitFullName(unit)
            local tooltipLine = GameTooltipTextLeft1 and GameTooltipTextLeft1:GetText() or nil
            local resolved, resolvedRealm = Engine.GetFullPlayerName(unit)
            Print("Name check for " .. unit .. ":")
            DEFAULT_CHAT_FRAME:AddMessage("  UnitName: " .. tostring(Clean(UnitName(unit))))
            DEFAULT_CHAT_FRAME:AddMessage("  GetUnitName(unit, true): " .. tostring(GetUnitName and Clean(GetUnitName(unit, true)) or "n/a"))
            DEFAULT_CHAT_FRAME:AddMessage("  UnitFullName: " .. tostring(Clean(fullName)) .. " / realm " .. tostring(Clean(fullRealm)))
            DEFAULT_CHAT_FRAME:AddMessage("  Tooltip line 1: " .. tostring(Clean(tooltipLine)))
            DEFAULT_CHAT_FRAME:AddMessage("  GetFullPlayerName: |cff00ff00" .. tostring(resolved) .. "|r / realm " .. tostring(resolvedRealm))
        end

    elseif cmd == "duels" then
        local list = {}
        for _, duel in pairs(MonologueCharDB.Duels) do
            if type(duel) == "table" then list[#list + 1] = duel end
        end
        table.sort(list, function(a, b) return (a.lastTime or 0) > (b.lastTime or 0) end)
        if #list == 0 then
            Print("No duels recorded yet.")
        else
            Print(#list .. " duel opponent" .. (#list == 1 and "" or "s") .. " (most recent first):")
            for _, duel in ipairs(list) do
                DEFAULT_CHAT_FRAME:AddMessage(string.format("  %s - |cff1eff00%d won|r / |cffff3030%d lost|r, last in %s",
                    tostring(duel.name), duel.wins or 0, duel.losses or 0, tostring(duel.lastZone or "?")))
            end
        end

    elseif cmd == "debug" then
        local mode = arg and arg:lower() or ""
        if mode == "on" then
            Engine:SetDebugMode(true)
        elseif mode == "off" then
            Engine:SetDebugMode(false)
        elseif mode == "" then
            Engine:SetDebugMode(not MonologueDB.debugMode)
        else
            Print("Usage: /mono debug [on|off] (currently " .. (MonologueDB.debugMode and "on" or "off") .. ")")
        end

    elseif cmd == "pvpdebug" then
        -- Alias: PvP tracing is part of the unified debug mode
        Engine:SetDebugMode(not MonologueDB.debugMode)

    elseif cmd == "spellid" then
        Engine.State.LogSpells = not Engine.State.LogSpells
        Print("Spell ID logging " .. (Engine.State.LogSpells and "|cff00ff00on|r: cast a spell to see its ID." or "off."))

    elseif cmd == "hooks" then
        if MonologueTranslator and MonologueTranslator.GetHookReport then
            for _, line in ipairs(MonologueTranslator:GetHookReport()) do Print(line) end
        else
            Print("Translator module is not loaded.")
        end

    elseif cmd == "chatty" then
        local value = tonumber(arg)
        if value then
            MonologueDB.chattiness = Clamp(value, 0, 3)
            Print("Chattiness set to " .. string.format("%.2f", MonologueDB.chattiness))
        else
            Print("Usage: /mono chatty <0-3>")
        end

    elseif cmd == "background" then
        local mode = arg and arg:upper()
        if mode == "LOCAL" or mode == "QUEUE" then
            MonologueDB.backgroundSpeech = mode
            Print("Background speech: " .. mode .. (mode == "LOCAL"
                and " (lines print in your own chat frame; nothing is sent)."
                or " (one line is held and said on your next spell cast or /mono command)."))
            if MonologueUI and MonologueUI.Refresh then MonologueUI:Refresh() end
        else
            Print("Usage: /mono background <local|queue> (currently " .. tostring(MonologueDB.backgroundSpeech) .. ")")
        end

    elseif cmd == "openworld" then
        Print("/mono openworld is retired: background speech never calls SendChatMessage now. See /mono background.")

    elseif cmd == "cry" then
        local channel = arg and arg:upper() or nil
        if channel ~= "SAY" and channel ~= "YELL" then channel = nil end
        Engine:BattleCry(channel)

    elseif cmd == "crychannel" then
        local mode = arg and arg:upper()
        if mode == "YELL" or mode == "SAY" then
            MonologueDB.battleCryChannel = mode
            Print("Battle cries now go out as " .. mode .. ".")
        else
            Print("Usage: /mono crychannel <yell|say> (currently " .. MonologueDB.battleCryChannel .. ")")
        end

    elseif cmd == "friend" then
        local name, realm, raceFile, guid = Engine:UnitFriendInfo("target")
        if not name then
            Print(realm) -- second return holds the reason when validation fails
        else
            local status, record = Engine:AddFriend(name, realm, raceFile, arg, guid)
            if status == "full" then
                Print("Your friends list is full (" .. MAX_FRIENDS .. "). Remove someone with /mono unfriend <name>.")
            elseif status then
                local note = record.note ~= "" and (" Note: " .. record.note) or ""
                Print(string.format("%s %s as a friend.%s",
                    record.name, status == "added" and "marked" or "updated", note))
            end
        end

    elseif cmd == "unfriend" then
        local key
        if arg and arg ~= "" then
            key = Engine:FindFriendKey(arg)
        elseif UnitExists("target") and UnitIsPlayer("target") then
            local _, targetKey = Engine:GetFriendForUnit("target")
            key = targetKey
        else
            Print("Target a friend or use /mono unfriend <name>.")
        end
        if key then
            local record = Engine:RemoveFriend(key)
            Print((record and record.name or "That player") .. " is no longer marked as a friend.")
        elseif (arg and arg ~= "") or (UnitExists("target") and UnitIsPlayer("target")) then
            Print("No marked friend matches that.")
        end

    elseif cmd == "friends" then
        local list = {}
        for _, record in pairs(MonologueCharDB.Friends) do
            if type(record) == "table" then list[#list + 1] = record end
        end
        table.sort(list, function(a, b) return tostring(a.name):lower() < tostring(b.name):lower() end)
        if #list == 0 then
            Print("No marked friends yet. Target a friendly player and type /mono friend [note].")
        else
            Print(#list .. " marked friend" .. (#list == 1 and "" or "s") .. ":")
            for _, record in ipairs(list) do
                DEFAULT_CHAT_FRAME:AddMessage(string.format("  %s - %s%s%s",
                    tostring(record.name), tostring(record.race or "unknown race"),
                    (record.note and record.note ~= "") and (" - " .. record.note) or "",
                    record.addedAt and (" |cff888888(" .. date("%Y-%m-%d", record.addedAt) .. ")|r") or ""))
            end
        end

    elseif cmd == "probe" then
        Engine:ArmProbe()

    elseif cmd == "identity" or cmd == "id" then
        Print(Engine:DescribeIdentity())

    elseif cmd == "party" then
        Print(Engine:DescribeParty())

    elseif cmd == "bug" or cmd == "report" then
        if MonologueUI and MonologueUI.ShowBugReport then
            MonologueUI:ShowBugReport()
        else
            Print(Engine:BuildBugReport(arg))
        end

    elseif cmd == "welcome" then
        if MonologueUI and MonologueUI.ShowWelcome then MonologueUI:ShowWelcome() end

    elseif cmd == "version" then
        Print("Monologue " .. Engine.VERSION)

    elseif cmd == "safemode" or cmd == "strict" then
        MonologueDB.strictSafeMode = not MonologueDB.strictSafeMode
        Print("Strict Safe-Mode " .. (MonologueDB.strictSafeMode
            and "|cff00ff00ON|r: automated lines only show in your own chat. Buttons, /mono cry and typed chat still work."
            or "|cffff8800OFF|r: automated lines are said in /s again."))
        if MonologueUI and MonologueUI.Refresh then MonologueUI:Refresh() end

    elseif cmd == "tokens" then
        Print("Live details right now (lines that need an unavailable one are skipped):")
        Print(Engine:DescribeDetailTokens())

    elseif cmd == "situations" or cmd == "sit" then
        local unit = UnitExists("target") and "target" or nil
        Print("Situations right now: " .. Engine:DescribeSituations(unit, true)
            .. string.format(" |cff888888(react chance %d%%)|r", MonologueDB.situationChance or 40))

    elseif cmd == "castchat" then
        if arg == "retry" then
            MonologueDB.castSendBlocked = false
            MonologueDB.pressVoiceBlocked = {}
            Print("Ability-press lines will try public chat again everywhere. If the client blocks one, that place switches off again automatically.")
        else
            local blocked = {}
            for place, isBlocked in pairs(MonologueDB.pressVoiceBlocked or {}) do
                if isBlocked then blocked[#blocked + 1] = Engine:DescribePressPlace(place) end
            end
            table.sort(blocked)
            Print("Ability-press chat blocked by the client in: " .. (#blocked > 0 and table.concat(blocked, ", ") or "nowhere")
                .. ". /mono castchat retry to test again.")
        end

    elseif cmd == "greet" then
        Engine:GreetNow()

    elseif cmd == "taunt" then
        Engine:TauntNow()

    elseif cmd == "say" then
        -- One line per key press: a waiting line just said takes this press
        if not flushed then
            local kind, chance = strsplit(" ", arg or "", 2)
            Engine:SayOnDemand(kind, chance)
        end

    elseif cmd == "map" then
        if not arg or arg == "" then
            local choices = {}
            for name, category in pairs(MonologueCharDB.AbilityMap or {}) do
                choices[#choices + 1] = tostring(name) .. " = " .. tostring(category)
            end
            table.sort(choices)
            Print(#choices > 0 and ("Your ability choices: " .. table.concat(choices, ", "))
                or "No ability choices yet. /mono map <spell name> <attack|burst|defend|interrupt|heal|none|auto>")
        else
            local spellText, categoryText = arg:match("^(.-)%s+(%S+)$")
            local category = Engine:NormalizeAbilityCategory(categoryText)
            local name = category and Engine:ResolveSpellName(spellText)
            if not category then
                Print("Usage: /mono map <spell name> <attack|burst|defend|interrupt|heal|none|auto>")
            elseif not name then
                Print("No spell called '" .. tostring(spellText) .. "'. Cast it once, or check the spelling.")
            else
                Engine:SetAbilityCategory(name, category)
                Print(name .. ": " .. (category == "Auto" and ("automatic (" .. Engine:DescribeAbility(name) .. ")") or category) .. ".")
                if MonologueUI and MonologueUI.OnAbilitiesChanged then pcall(MonologueUI.OnAbilitiesChanged, MonologueUI) end
            end
        end

    elseif cmd == "test" then
        local translator = MonologueTranslator
        if not arg or arg == "" then
            Print("Usage: /mono test <text> - shows what a message would turn into, without sending it")
        elseif not (translator and translator.Translate) then
            Print("The translator is not loaded.")
        else
            local intensity = translator.GetChannelIntensity and translator:GetChannelIntensity("SAY") or 0
            if intensity <= 0 then intensity = MonologueDB.translationIntensity or 2 end
            translator.TypedChat = true
            local ok, out = pcall(translator.Translate, translator, arg, intensity)
            translator.TypedChat = nil
            Print(ok and ("Would say: " .. tostring(out)) or "The translator could not read that.")
            if not MonologueDB.fixTypos then Print("|cff888888(Typo fixes are off: General tab.)|r") end
        end

    elseif cmd == "abilities" then
        if MonologueUI and MonologueUI.ShowTab then MonologueUI:ShowTab("abilities") end

    elseif cmd == "simple" or cmd == "full" or cmd == "all" then
        if MonologueUI then
            if cmd == "simple" then MonologueUI:ShowSimple() else MonologueUI:ShowFull("settings") end
        end

    elseif cmd == "quirks" then
        local cv = Engine:GetCustomVoice() or {}
        local quirks = cv.quirks or {}
        if #quirks == 0 then
            Print("No quirks yet. Set them up on the Abilities tab (when something happens, say one of your lines).")
        else
            Print("Your quirks:")
            for i, q in ipairs(quirks) do
                DEFAULT_CHAT_FRAME:AddMessage(string.format("  %d. %s '%s' (%s, %d%%): %d line%s", i, q.trigger,
                    q.match ~= "" and q.match or "anything", q.cond, q.chance, #q.lines, #q.lines == 1 and "" or "s"))
            end
        end
        if MonologueUI and MonologueUI.ShowTab then MonologueUI:ShowTab("abilities") end

    elseif cmd == "taunts" or cmd == "nicknames" then
        local field = cmd
        local choice = arg and arg:upper() or ""
        local cv = Engine:GetCustomVoice() or {}
        if choice == "" then
            Print((field == "taunts" and "Taunts: " or "Race nicknames: ") .. tostring(cv[field] or "off"):lower()
                .. (field == "taunts" and ". /mono taunts <off|civil|rough|savage>" or ". /mono nicknames <off|enemy|all>"))
        else
            local ok = Engine:CustomVoiceSetIdentity(field, choice)
            if not ok then
                Print(field == "taunts" and "Taunts: off, civil, rough or savage." or "Race nicknames: off, enemy or all.")
            else
                Print((field == "taunts" and "Taunts: " or "Race nicknames: ") .. choice:lower() .. ".")
                if MonologueUI and MonologueUI.OnVoiceChanged then pcall(MonologueUI.OnVoiceChanged, MonologueUI) end
            end
        end

    elseif cmd == "sendkey" then
        local choice = arg and arg:upper() or ""
        if choice == "CONTROL" then choice = "CTRL" end
        if choice == "ENTER" or choice == "SHIFT" or choice == "CTRL" then
            MonologueDB.translateKey = choice
            Print(choice == "ENTER" and "Typed chat is translated when you press Enter."
                or ("Typed chat is translated only on " .. (choice == "SHIFT" and "Shift" or "Ctrl") .. "+Enter; plain Enter sends it as typed."))
            if MonologueUI and MonologueUI.Refresh then pcall(MonologueUI.Refresh, MonologueUI) end
        else
            Print("Translate on: " .. tostring(MonologueDB.translateKey or "ENTER"):lower() .. ". /mono sendkey <enter|shift|ctrl>")
        end

    elseif cmd == "mood" then
        if not arg or arg == "" then
            Print("Mood: " .. (Engine:GetMood() or "normal") .. ". /mono mood <grim|weary|cheerful|fierce|off>")
        else
            local mood = Engine:SetMood(arg)
            if mood == false then
                Print("Moods: grim, weary, cheerful, fierce (or off).")
            else
                Print("Mood: " .. (mood or "normal") .. ".")
                if MonologueUI and MonologueUI.OnVoiceChanged then pcall(MonologueUI.OnVoiceChanged, MonologueUI) end
            end
        end

    elseif cmd == "ic" then
        Engine:SetInCharacter(true)

    elseif cmd == "ooc" then
        Engine:SetInCharacter(false)

    elseif cmd == "keep" then
        if arg and arg ~= "" then
            local ok, why = Engine:AddKeepWord(arg)
            Print(ok and ("'" .. arg .. "' will never be translated.") or why)
        else
            local list = type(MonologueDB.keepWords) == "table" and MonologueDB.keepWords or {}
            Print(#list > 0 and ("Never translated: " .. table.concat(list, ", ")) or "No words on the never-translate list. /mono keep <word> adds one.")
        end

    elseif cmd == "unkeep" then
        Print((arg and Engine:RemoveKeepWord(arg)) and ("'" .. arg .. "' removed from the never-translate list.")
            or "Usage: /mono unkeep <word> (it must be on the list: /mono keep shows it)")

    elseif cmd == "lines" or cmd == "voicelines" then
        if MonologueUI and MonologueUI.OpenLines then
            MonologueUI:OpenLines()
        else
            Print("UI module is not loaded.")
        end

    elseif cmd == "voice" or cmd == "myvoice" then
        if MonologueUI and MonologueUI.OpenVoice then
            MonologueUI:OpenVoice()
        else
            Print("UI module is not loaded.")
        end

    elseif cmd == "roster" then
        if MonologueUI and MonologueUI.ToggleRoster then
            MonologueUI:ToggleRoster()
        else
            Print("UI module is not loaded.")
        end

    elseif cmd == "minimap" then
        if arg and arg:lower() == "reset" and MonologueUI and MonologueUI.ResetMinimap then
            MonologueUI:ResetMinimap()
        elseif MonologueUI and MonologueUI.ToggleMinimap then
            MonologueUI:ToggleMinimap()
        else
            Print("UI module is not loaded.")
        end

    elseif cmd == "button" then
        if MonologueUI and MonologueUI.ToggleButton then
            MonologueUI:ToggleButton()
        else
            Print("UI module is not loaded.")
        end

    elseif cmd == "feat" then
        if arg and arg ~= "" then
            if not Engine:UnlockFeat(arg) and MonologueCharDB.Feats[arg:upper()] then
                Print("Feat " .. arg:upper() .. " is already unlocked.")
            end
        else
            Print("Usage: /mono feat <KEY>")
        end

    elseif cmd == "feats" then
        local unlocked = {}
        for featKey in pairs(MonologueCharDB.Feats) do unlocked[#unlocked + 1] = featKey end
        table.sort(unlocked)
        Print("Unlocked feats: " .. (#unlocked > 0 and table.concat(unlocked, ", ") or "none"))

    elseif cmd == "rivals" then
        PrintRivals()

    elseif cmd == "pin" or cmd == "unpin" then
        local key = Engine:FindRivalKey(arg)
        if key and Engine:SetRivalPinned(key, cmd == "pin") then
            local rival = Engine:GetRival(key)
            Print(((rival and rival.name) or key) .. (cmd == "pin" and " pinned to" or " unpinned from") .. " the Nemesis ledger.")
        else
            Print("No rival named '" .. tostring(arg) .. "' in the ledger.")
        end

    else
        PrintHelp()
    end
end
