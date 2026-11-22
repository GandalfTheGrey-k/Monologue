--[[
    Monologue Dialect Translator (Version .1)
    Hooks outgoing chat submissions to apply phonetic dialect transformations.
    Enforces OOC protection, emote protection, and channel stepdown rules.

    Dialect schema (supplied by race / class / persona / profile data modules). Every key is
    optional, and every list or table can be mixed freely with the older single-string forms:
      Dialect = {
          wordSwaps = {
              ["friend"] = "lad",                          -- one replacement
              ["beer"]   = { "ale", "stout", "brew" },     -- several variants: one is picked at
                                                           -- random, avoiding the last 3 used
          },
          phraseSwaps = {                                  -- multi-word idioms, applied before
              ["thank you"] = { "much obliged", "thank ye kindly" },   -- the single words, longest
              ["watch out"] = "mind yerself",                          -- phrase first. Strings or lists.
          },
          phonetics = { ["ing%f[%A]"] = "in'" },
              -- Lua patterns applied per word to the lower-cased word, then re-cased. Rules run in
              -- sorted key order; the array form { { pattern, replacement }, ... } runs in listed
              -- order. Words already replaced by a swap are left untouched.
          contractions = { ["do not"] = "dinnae" },
              -- Like phraseSwaps, but each match is only applied some of the time (Standard and up),
              -- so cadence varies from line to line.
          oaths = {
              Greet = { "Ho there!", "Well met!" },          -- before a greeting
              Fight = { "By Magni's beard!", "Gol'kosh!" },  -- before a kill line or battle cry
              Hurt  = { "Blast it!", "Me beard!" },          -- before a low-health line
              Any   = { ... },                               -- any of the above (My Voice oaths)
          },
              -- Short exclamations that stand as their own sentence. One is now and then put in
              -- front of a line, but only in a moment it fits (the engine sets
              -- MonologueEngine.State.OathMoment: Greet, Kill, LowHP or Cry). Typed chat never
              -- gets one. A flat list is the same as Any. The last 4 used are avoided.
      }

    Case and punctuation: a swap keeps the case of what it replaces ("Friend" -> "Kin",
    "RUN" -> "FLEE"), and never doubles punctuation ("Watch out!" + "mind yerself!" -> "Mind yerself!").

    Intensity: 0 Off, 1 Light (swaps, plus a light sprinkle of phonetics and contractions),
    2 Standard (full phonetics, more contractions, the odd oath), 3 Unhinged (more oaths).
    Oath chances are also scaled by the chattiness setting.
    A fixed swap (a single replacement string) fires most of the time, not every time
    (70% Light, 85% Standard, 95% Unhinged), so the accent varies from line to line.
--]]

MonologueTranslator = {
    DefaultSwaps = {},
    DefaultPhonetics = {},
}

local Translator = MonologueTranslator

local MAX_CHAT_BYTES = 255

-- How many recently used choices are avoided
local VARIANT_HISTORY_AVOID = 3   -- word and phrase swap variants
local FRAGMENT_HISTORY_AVOID = 4  -- oaths
local HISTORY_LIMIT = 12

-- Base chance per intensity (1 = Light, 2 = Standard, 3 = Unhinged); missing = never
-- Oaths: the chance per line for each moment, the oath group it draws from, and a scale per
-- intensity (Light Flavor counts as Light)
local OATH_CHANCE = { Greet = 0.25, Kill = 0.20, LowHP = 0.20, Cry = 0.15 }
local OATH_GROUP = { Greet = "Greet", Kill = "Fight", LowHP = "Hurt", Cry = "Fight" }
local OATH_GROUPS = { "Greet", "Fight", "Hurt" }
local OATH_INTENSITY_SCALE = { [1] = 0.5, [2] = 1.0, [3] = 1.6 }
local CONTRACTION_CHANCE = { [1] = 0.30, [2] = 0.60, [3] = 0.90 }

-- A fixed swap (one replacement, e.g. Dwarf "to" -> "tae") fires this often per word, so the
-- accent drifts naturally instead of rewriting every single "to" in every line
local FIXED_SWAP_CHANCE = { [1] = 0.70, [2] = 0.85, [3] = 0.95 }
-- Phonetic shifts (e.g. -ing -> -in') per word; Light gets a lighter sprinkle
local PHONETIC_CHANCE = { [1] = 0.40, [2] = 1.0, [3] = 1.0 }

local MARK_OPEN = "\001"
local MARK_CLOSE = "\002"
local MARK_SWAPPED = "\003"
local MARKER_PATTERN = "\001(%d+)\002"

-- Chat channels the hook may translate. Everything else (whispers, guild,
-- officer, custom channels, Battle.net, emotes) is always passed through.
-- chatType -> MonologueDB.translateChannels key (General tab, "Translate In"). Anything not
-- listed (numbered channels, Battle.net, emotes, ...) is never translated.
local CHANNEL_KEYS = {
    SAY = "SAY",
    YELL = "YELL",
    PARTY = "PARTY",
    PARTY_LEADER = "PARTY",
    RAID = "RAID",
    RAID_LEADER = "RAID",
    RAID_WARNING = "RAID",
    INSTANCE_CHAT = "INSTANCE",
    INSTANCE_CHAT_LEADER = "INSTANCE",
    GUILD = "GUILD",
    OFFICER = "OFFICER",
    WHISPER = "WHISPER",
}
-- Group channels where "Lighter accent in group chat" steps the accent down to Light
local GROUP_KEYS = { PARTY = true, RAID = true, INSTANCE = true }

-- Default when the saved table is missing (before the DB loads)
local DEFAULT_TRANSLATE_CHANNELS = { SAY = true, YELL = true, PARTY = true }

function Translator:IsChannelTranslated(chatType)
    local key = chatType and CHANNEL_KEYS[chatType]
    if not key then return false end
    local channels = MonologueDB and MonologueDB.translateChannels
    if type(channels) ~= "table" then return DEFAULT_TRANSLATE_CHANNELS[key] == true end
    return channels[key] == true
end

-- Blocks masked before any dialect rule runs and restored intact afterwards.
-- Order matters: hyperlinks and escapes first so OOC/emote blocks can contain them.
local PRESERVE_PATTERNS = {
    "|c%x%x%x%x%x%x%x%x|H.-|h.-|h|r", -- coloured hyperlinks (items, spells, quests)
    "|H.-|h.-|h",                     -- bare hyperlinks
    "|T.-|t",                         -- texture escapes
    "|A.-|a",                         -- atlas escapes
    "|K.-|k",                         -- protected Battle.net names
    "|c%x%x%x%x%x%x%x%x",             -- stray colour openers
    "|r",                             -- stray colour closers
    "%a[%w+.-]*://%S+",               -- URLs
    "www%.%S+",                       -- bare web addresses
    "%(%b()%)",                       -- ((OOC))
    "%*.-%*",                         -- *emotes*
    "%b<>",                           -- <emotes>
    "%b{}",                           -- {raid target icons} and unresolved tokens
}

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function CapitalizeFirst(s)
    return (s:gsub("^(%A*)(%a)", function(lead, first) return lead .. first:upper() end, 1))
end

-- Applies the capitalisation of `source` onto `replacement`:
-- ALL CAPS -> ALL CAPS, Title Case -> Title Case, otherwise unchanged
local function MatchCase(source, replacement)
    local letters = source:gsub("%A", "")
    if #letters >= 2 and letters == letters:upper() then
        return replacement:upper()
    end
    if letters:sub(1, 1):match("%u") then
        return CapitalizeFirst(replacement)
    end
    return replacement
end

local MAGIC_CHARS = {
    ["^"] = true, ["$"] = true, ["("] = true, [")"] = true, ["%"] = true, ["."] = true,
    ["["] = true, ["]"] = true, ["*"] = true, ["+"] = true, ["-"] = true, ["?"] = true,
}

-- Case-insensitive literal pattern for a multi-word swap key
local function BuildPhrasePattern(key)
    local parts = {}
    for i = 1, #key do
        local c = key:sub(i, i)
        if c:match("%a") then
            parts[#parts + 1] = "[" .. c:lower() .. c:upper() .. "]"
        elseif c:match("%s") then
            if parts[#parts] ~= "%s+" then parts[#parts + 1] = "%s+" end
        elseif MAGIC_CHARS[c] then
            parts[#parts + 1] = "%" .. c
        else
            parts[#parts + 1] = c
        end
    end
    local pattern = table.concat(parts)
    if key:sub(1, 1):match("%a") then pattern = "%f[%a]" .. pattern end
    if key:sub(-1):match("%a") then pattern = pattern .. "%f[%A]" end
    return pattern
end

local function IsValidRule(pattern, replacement)
    return pcall(string.gsub, "the quick brown fox thinking", pattern, replacement)
end

-- Recently used choices per history key, newest last
local history = {}

-- Picks one of pool at random while avoiding the last `avoidCount` choices made under
-- historyKey (fewer if the pool is small), then records the choice.
local function PickAvoiding(historyKey, pool, avoidCount)
    if type(pool) ~= "table" or #pool == 0 then return nil end
    if #pool == 1 then return pool[1] end

    local recent = history[historyKey]
    if not recent then
        recent = {}
        history[historyKey] = recent
    end

    avoidCount = math.min(avoidCount or VARIANT_HISTORY_AVOID, #pool - 1)
    local blocked = {}
    for i = math.max(1, #recent - avoidCount + 1), #recent do
        blocked[recent[i]] = true
    end

    local candidates = {}
    for _, choice in ipairs(pool) do
        if not blocked[choice] then candidates[#candidates + 1] = choice end
    end
    local pick = candidates[math.random(#candidates > 0 and #candidates or 1)] or pool[math.random(#pool)]

    recent[#recent + 1] = pick
    if #recent > HISTORY_LIMIT then table.remove(recent, 1) end
    return pick
end

-- Also used by the RP bridge for {opener} (an oath), so the same oath is never picked twice
-- in a row whichever route it comes from
Translator.PickAvoiding = PickAvoiding

-- A replacement value may be one string or a list of strings; returns a list or nil
local function NormalizeVariants(value)
    if type(value) == "string" then return { value } end
    if type(value) == "table" then
        local list = {}
        for _, variant in ipairs(value) do
            if type(variant) == "string" then list[#list + 1] = variant end
        end
        if #list > 0 then return list end
    end
    return nil
end

local function PickVariant(entry)
    return PickAvoiding("swap:" .. entry.key, entry.variants, VARIANT_HISTORY_AVOID)
end

-- Compiled dialect cache, keyed weakly by the dialect table (ActiveProfile
-- rebuilds create new tables, so stale entries are collected automatically)
local compiledCache = setmetatable({}, { __mode = "k" })

local function SortPhrases(list)
    table.sort(list, function(a, b)
        if #a.key ~= #b.key then return #a.key > #b.key end
        return a.key < b.key
    end)
end

local function CompileStringList(...)
    local list, seen = {}, {}
    for i = 1, select("#", ...) do
        local source = select(i, ...)
        if type(source) == "table" then
            for _, value in ipairs(source) do
                if type(value) == "string" and value ~= "" and not seen[value] then
                    seen[value] = true
                    list[#list + 1] = value
                end
            end
        end
    end
    return list
end

local function CompileDialect(dialect)
    local compiled = compiledCache[dialect]
    if compiled then return compiled end

    compiled = {
        words = {}, phrases = {}, contractions = {}, phonetics = {},
        oaths = {}, oathCount = 0,
    }

    -- A key with anything but letters and apostrophes (a space, say) is a phrase wherever it
    -- is listed; phraseSwaps keys are phrases even when they are a single word
    local function AddSwap(key, value, forcePhrase)
        if type(key) ~= "string" or key == "" then return end
        local variants = NormalizeVariants(value)
        if not variants then return end
        local lowered = key:lower()
        if forcePhrase or lowered:find("[^%a']") then
            compiled.phrases[#compiled.phrases + 1] = {
                key = lowered, pattern = BuildPhrasePattern(lowered), variants = variants,
            }
        else
            compiled.words[lowered] = { key = lowered, variants = variants }
        end
    end

    if type(dialect.wordSwaps) == "table" then
        for key, value in pairs(dialect.wordSwaps) do AddSwap(key, value, false) end
    end
    if type(dialect.phraseSwaps) == "table" then
        for key, value in pairs(dialect.phraseSwaps) do AddSwap(key, value, true) end
    end
    SortPhrases(compiled.phrases)

    if type(dialect.contractions) == "table" then
        for key, value in pairs(dialect.contractions) do
            local variants = type(key) == "string" and key ~= "" and NormalizeVariants(value) or nil
            if variants then
                local lowered = key:lower()
                compiled.contractions[#compiled.contractions + 1] = {
                    key = lowered, pattern = BuildPhrasePattern(lowered), variants = variants,
                }
            end
        end
        SortPhrases(compiled.contractions)
    end

    if type(dialect.phonetics) == "table" then
        if #dialect.phonetics > 0 then
            for _, rule in ipairs(dialect.phonetics) do
                if type(rule) == "table" and type(rule[1]) == "string" and type(rule[2]) == "string"
                    and IsValidRule(rule[1], rule[2]) then
                    compiled.phonetics[#compiled.phonetics + 1] = { pattern = rule[1], replacement = rule[2] }
                end
            end
        else
            local keys = {}
            for pattern, replacement in pairs(dialect.phonetics) do
                if type(pattern) == "string" and type(replacement) == "string" and IsValidRule(pattern, replacement) then
                    keys[#keys + 1] = pattern
                end
            end
            table.sort(keys)
            for _, pattern in ipairs(keys) do
                compiled.phonetics[#compiled.phonetics + 1] = { pattern = pattern, replacement = dialect.phonetics[pattern] }
            end
        end
    end

    -- Oaths per group; "Any" (or a flat list) goes into every group
    local oaths = type(dialect.oaths) == "table" and dialect.oaths or {}
    local any = #oaths > 0 and oaths or oaths.Any
    for _, group in ipairs(OATH_GROUPS) do
        compiled.oaths[group] = CompileStringList(oaths[group], any)
        compiled.oathCount = compiled.oathCount + #compiled.oaths[group]
    end

    compiledCache[dialect] = compiled
    return compiled
end

local function RestoreBlocks(text, preserved)
    for _ = 1, 8 do
        if not text:find(MARK_OPEN, 1, true) then break end
        text = text:gsub(MARKER_PATTERN, function(index)
            return preserved[tonumber(index)] or ""
        end)
    end
    return text
end

-- Flourish chance for an intensity, scaled by the chattiness setting (0 to 2)
local function FlourishChance(chances, intensity)
    local base = chances[math.min(intensity, 3)]
    if not base then return 0 end
    local scale = MonologueDB and tonumber(MonologueDB.chattiness) or 1
    scale = math.max(0, math.min(scale, 2))
    return math.min(1, base * scale)
end

-- Replaces every match of a phrase entry in the masked text. Each replacement is masked so
-- later passes can't touch it. If chance is given, each match is only replaced that often.
-- A replacement ending in . ! or ? drops it when the text already has punctuation next.
local function ReplacePhrase(text, entry, Preserve, chance)
    local out, pos = {}, 1
    while true do
        local s, e = text:find(entry.pattern, pos)
        if not s or e < s then break end
        out[#out + 1] = text:sub(pos, s - 1)
        local matched = text:sub(s, e)
        if chance and math.random() >= chance then
            out[#out + 1] = matched
        else
            local replacement = MatchCase(matched, PickVariant(entry))
            if text:sub(e + 1, e + 1):match("[%.!%?]") then
                replacement = replacement:gsub("[%.!%?]+$", "")
            end
            out[#out + 1] = Preserve(replacement)
        end
        pos = e + 1
    end
    out[#out + 1] = text:sub(pos)
    return table.concat(out)
end

-- Puts an oath in front of the line, as its own sentence, when the engine says the moment
-- fits (State.OathMoment). Skipped when the line starts with a masked block (an emote, OOC
-- text, a {token}) or already opens with an exclamation ("Ha! ...", "Oi! ...").
local function ApplyOath(text, compiled, moment, intensity)
    local chance = OATH_CHANCE[moment]
    local pool = compiled.oaths[OATH_GROUP[moment] or ""]
    if not chance or not pool or #pool == 0 then return text end
    local tier = math.min(intensity, 3)
    if math.random() >= FlourishChance({ [tier] = chance * (OATH_INTENSITY_SCALE[tier] or 1) }, tier) then
        return text
    end
    if text:find("^%s*" .. MARK_OPEN) or text:find("^%s*[%a']+[!%?]") then return text end

    local oath = PickAvoiding("oath", pool, FRAGMENT_HISTORY_AVOID)
    if not oath then return text end
    oath = oath:gsub("^%s+", ""):gsub("%s+$", "")
    if not oath:find("[%.!%?]$") then oath = oath .. "!" end
    -- Don't say the same thing twice ("By Magni's beard! By Magni's beard, ...")
    local core = oath:gsub("[%.!%?]+$", ""):lower()
    if text:lower():find(core, 1, true) then return text end
    -- A shout (battle cry) gets a shouted oath
    local plain = text:gsub(MARK_OPEN .. "%d+" .. MARK_CLOSE, "")
    if plain:find("%u%u") and not plain:find("%l") then oath = oath:upper() end
    return oath .. " " .. text:gsub("^%s+", "")
end

---------------------------------------------------------------------------
-- Core Translation Engine
---------------------------------------------------------------------------

function Translator:GetDialect()
    local profile = MonologueEngine and MonologueEngine.ActiveProfile
    local dialect = profile and profile.Dialect
    if type(dialect) ~= "table" then return nil end
    return dialect
end

function Translator:HasDialect()
    local dialect = self:GetDialect()
    if not dialect then return false end
    local compiled = CompileDialect(dialect)
    return next(compiled.words) ~= nil or #compiled.phrases > 0 or #compiled.contractions > 0
        or #compiled.phonetics > 0 or compiled.oathCount > 0
end

-- Noun / verb guard for word swaps. Swaps don't know grammar, so a few ambiguous words only
-- swap where their replacement fits:
--   NOUN_ONLY: replaced by nouns ("fight" -> "scrap", "drink" -> "pint"), so only swapped
--              after a noun cue ("a fight", "the fight", "good drink"), never as a verb
--              ("to fight back the Horde" stays "fight").
--   VERB_ONLY: replaced by verbs ("hurry" -> "walk with purpose", "kill" -> "slay"), so never
--              swapped right after a determiner ("in a hurry", "the kill").
local NOUN_ONLY_SWAPS = {
    fight = true, drink = true, work = true, fear = true, hope = true, plan = true, promise = true,
    guard = true, storm = true, curse = true, fire = true, reward = true, balance = true, word = true,
    quest = true, power = true, favor = true, spell = true,
}
local VERB_ONLY_SWAPS = {
    attack = true, burn = true, track = true, win = true, heal = true, fix = true, fly = true,
    freeze = true, shoot = true, sneak = true, steal = true, kill = true, pray = true, protect = true,
    defend = true, hurry = true,
}
local DETERMINERS = {
    a = true, an = true, the = true, this = true, that = true, these = true, those = true,
    my = true, your = true, his = true, her = true, its = true, our = true, their = true,
    ye = true, yer = true, me = false, no = true, every = true, each = true, another = true,
    any = true, some = true, one = true,
}
local NOUN_CUES = {
    good = true, great = true, big = true, bad = true, last = true, next = true, first = true,
    real = true, fair = true, proper = true, little = true, long = true, hard = true, fine = true,
    strong = true, cold = true, stiff = true, quick = true, honest = true, old = true, new = true,
}

-- May this word be swapped, given the word before it?
local function SwapFitsGrammar(word, previous)
    if NOUN_ONLY_SWAPS[word] then
        return previous ~= nil and (DETERMINERS[previous] == true or NOUN_CUES[previous] == true)
    end
    if VERB_ONLY_SWAPS[word] then
        return not (previous ~= nil and DETERMINERS[previous] == true)
    end
    return true
end

-- Your guild's name ("Clan BattleHammer"), matched in any letter case, is masked so no swap
-- or accent rule touches it, even at the start of a line
local function PreserveGuildName(text, preserve)
    local name = GetGuildInfo and GetGuildInfo("player")
    if MonologueEngine and MonologueEngine.Clean then name = MonologueEngine.Clean(name) end
    if type(name) ~= "string" or #name < 3 then return text end
    local pattern = name:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")
        :gsub("%a", function(c) return "[" .. c:lower() .. c:upper() .. "]" end)
    return (text:gsub(pattern, preserve))
end

-- A capitalised word in the middle of a sentence is a name (a player, a guild, a place, a
-- boss) and stays as written. The first word of a sentence, "I" / "I'm" and ALL-CAPS words
-- (shouts) are still translated.
local function PreserveProperNouns(text, preserve)
    return (text:gsub("()%f[%a](%u[%a']*)", function(position, word)
        if not word:find("%l") then return nil end              -- ALL CAPS or a single capital
        if word == "I" or word:find("^I'") then return nil end
        local before = text:sub(1, position - 1):match("(%S?)%s*$")
        -- Start of the line or of a sentence (also after a masked block, e.g. an emote)
        if before == "" or before:find("[%.!%?:\"\002]") then return nil end
        return preserve(word)
    end))
end

-- A title in front of a name stays with it ("Lady Jaina", "Captain Grayson"), even at the
-- start of a sentence
local TITLES = {}
for word in ("lord lady king queen prince princess sir captain commander general marshal warchief "
    .. "archmage magistrate baron baroness high elder"):gmatch("%S+") do
    TITLES[word] = true
end
local function PreserveTitles(text, preserve)
    return (text:gsub("%f[%a](%u%l+)(%s+)(%u[%a']*)", function(title, space, name)
        if not TITLES[title:lower()] then return nil end
        return preserve(title .. space .. name)
    end))
end

-- Words Never Translated (My Voice tab, /mono keep): matched in any letter case, whole words
-- only (multi-word entries allowed)
local function PreserveKeepWords(text, preserve)
    local list = MonologueDB and MonologueDB.keepWords
    if type(list) ~= "table" then return text end
    for _, entry in ipairs(list) do
        if type(entry) == "string" and entry:find("%w") then
            local pattern = entry:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")
                :gsub("%a", function(c) return "[" .. c:lower() .. c:upper() .. "]" end)
            text = text:gsub("%f[%w']" .. pattern .. "%f[^%w']", preserve)
        end
    end
    return text
end

-- Gender-aware swaps. Only words used to address someone ("friend" -> "lad") take a gender,
-- and only the one the line itself gives (see PronounGender); the pairs map the male form to
-- the female form.
local ADDRESS_WORDS = {
    friend = true, friends = true, buddy = true, pal = true, mate = true, man = true,
    dude = true, guy = true, bro = true, sir = true,
}
local GENDER_PAIRS = {
    lad = "lass", laddie = "lassie", lads = "lasses", boyo = "lass", brother = "sister",
    brothers = "sisters", sir = "madam", fella = "lass", ["my man"] = "my lady",
    ["old boy"] = "old girl",
}
-- Female -> male, fixed (several male forms share "lass", so the reverse can't be derived)
local GENDER_REVERSE = {
    lass = "lad", lassie = "laddie", lasses = "lads", sister = "brother", sisters = "brothers",
    madam = "sir", ["my lady"] = "my man", ["old girl"] = "old boy",
}

-- The gender the line itself gives, from the words the player used: 3 = female ("she",
-- "her", "lady"...), 2 = male ("he", "him", "sir"...), nil = none or both. Who you're
-- targeting is never used: you may not be talking about them.
local FEMALE_CUES, MALE_CUES = {}, {}
for word in ("she her hers herself woman women girl girls lady ladies lass lassie lasses sister "
    .. "sisters madam ma'am"):gmatch("%S+") do FEMALE_CUES[word] = true end
for word in ("he him his himself man men boy boys lad laddie lads brother brothers sir fella "
    .. "guy dude bro"):gmatch("%S+") do MALE_CUES[word] = true end
local function PronounGender(text)
    local female, male = false, false
    for word in text:lower():gmatch("[%a']+") do
        if FEMALE_CUES[word] then female = true end
        if MALE_CUES[word] then male = true end
    end
    if female and not male then return 3 end
    if male and not female then return 2 end
    return nil
end

-- The variants of an address word that fit the addressee: mapped to her or his form, or,
-- when unknown, only the ungendered ones (if there are any)
local function GenderedVariants(entry, gender, extraPairs)
    local toFemale, toMale = {}, {}
    for male, female in pairs(GENDER_PAIRS) do toFemale[male] = female end
    for female, male in pairs(GENDER_REVERSE) do toMale[female] = male end
    if type(extraPairs) == "table" then
        for male, female in pairs(extraPairs) do
            if type(male) == "string" and type(female) == "string" then
                toFemale[male:lower()] = female:lower()
                toMale[female:lower()] = toMale[female:lower()] or male:lower()
            end
        end
    end
    local out, seen = {}, {}
    local function add(v) if not seen[v] then seen[v] = true; out[#out + 1] = v end end
    if gender == 3 or gender == 2 then
        local map = (gender == 3) and toFemale or toMale
        for _, v in ipairs(entry.variants) do add(map[v:lower()] or v) end
    else
        for _, v in ipairs(entry.variants) do
            if not toFemale[v:lower()] and not toMale[v:lower()] then add(v) end
        end
        if #out == 0 then return entry.variants end
    end
    return out
end

-- Speech effects from your state (General tab): slurred when drunk (level 1-3), shaky when
-- badly hurt. Runs on the masked text, so names, links and OOC parts are never touched.
local VOWEL_STRETCH = { a = "aa", e = "ee", o = "oo", u = "uu" }
local function ApplySpeechEffects(text)
    local engine = MonologueEngine
    if not (engine and engine.GetSpeechState) then return text end
    local ok, state = pcall(engine.GetSpeechState, engine)
    if not ok or type(state) ~= "table" then return text end

    local drunk = tonumber(state.drunk) or 0
    if drunk > 0 then
        local slur = ({ 0.25, 0.5, 0.8 })[math.min(drunk, 3)]
        local stretched = false
        text = text:gsub("%a[%a']*", function(word)
            if math.random() >= slur then return nil end
            -- "s" inside or at the end of a word slurs to "sh" ("this" -> "thish")
            local tail = word:sub(2):gsub("ss", "s"):gsub("s([^hH])", "sh%1"):gsub("s$", "sh")
            local out = word:sub(1, 1) .. tail
            if not stretched and drunk >= 2 and #out >= 3 and math.random() < 0.25 then
                local vowel = out:match("[aeou]")
                if vowel then
                    out = out:gsub(vowel, VOWEL_STRETCH[vowel], 1)
                    stretched = true
                end
            end
            return out
        end)
        if drunk >= 2 and math.random() < 0.15 * drunk then
            text = text:gsub("%s*$", "") .. " *hic*"
        end
    end

    if state.hurt and math.random() < 0.4 then
        -- A stammer on the first word: "I-I", "W-we"
        text = text:gsub("^(%s*)(%a)(%a*)", function(space, first, rest)
            if rest == "" then return space .. first .. "-" .. first end
            -- A shout stays a shout ("F-FOR IRONFORGE!"), a normal word goes "W-we"
            local repeated = (rest:find("%l") or not first:find("%u")) and first:lower() or first
            return space .. first .. "-" .. repeated .. rest
        end, 1)
        if math.random() < 0.5 and not text:find("%.%.%s*$") then text = text:gsub("%.%s*$", "...") end
    end
    return text
end

function Translator:Translate(text, intensity, dialectOverride)
    if type(text) ~= "string" or text == "" then return text end
    intensity = math.floor(tonumber(intensity) or 0)
    if intensity <= 0 then return text end

    -- Command & Slash Bypass
    if text:sub(1, 1) == "/" then return text end

    local dialect = dialectOverride or self:GetDialect()
    if type(dialect) ~= "table" then return text end
    local compiled = CompileDialect(dialect)

    local original = text
    text = text:gsub("[\001-\003]", "")

    -- Preserve Emotes, OOC, links and escapes via marker tokens
    local preserved = {}
    local function Preserve(block)
        preserved[#preserved + 1] = block
        return MARK_OPEN .. #preserved .. MARK_CLOSE
    end
    for _, pattern in ipairs(PRESERVE_PATTERNS) do
        text = text:gsub(pattern, Preserve)
    end

    -- Names stay as written: your guild's name anywhere in the line, and any capitalised word
    -- in the middle of a sentence ("Clan BattleHammer", "Ironforge", "Magni")
    text = PreserveGuildName(text, Preserve)
    text = PreserveKeepWords(text, Preserve)
    text = PreserveTitles(text, Preserve)
    text = PreserveProperNouns(text, Preserve)

    -- Nothing in-character left to translate
    if not text:find("%a") then return original end

    -- Pass 1: multi-word phrase swaps, longest first (each replacement is masked from later passes)
    for _, phrase in ipairs(compiled.phrases) do
        text = ReplacePhrase(text, phrase, Preserve, nil)
    end

    -- Light Flavor (Dialect Strength): vocabulary only (and fewer oaths)
    local lightFlavor = self:GetDialectStrength() == "LIGHT"

    -- Layer flavor (Variety Engine): about 30% of lines carry the cadence and vocabulary of
    -- one of your layers (allegiance, upbringing, trait). Its word swaps run first and are
    -- masked, so the race dialect never re-swaps them.
    local flavor
    if MonologueEngine and MonologueEngine.PickLayerFlavor then
        local okFlavor, picked = pcall(MonologueEngine.PickLayerFlavor, MonologueEngine)
        if okFlavor and type(picked) == "table" then flavor = picked end
    end
    if flavor and type(flavor.wordSwaps) == "table" then
        local previousWord
        text = text:gsub("%a[%a']*", function(word)
            local lowered = word:lower()
            local previous = previousWord
            previousWord = lowered
            if not SwapFitsGrammar(lowered, previous) then return nil end
            local swap = flavor.wordSwaps[lowered]
            if type(swap) == "table" then swap = swap[math.random(#swap)] end
            if type(swap) == "string" then return Preserve(MatchCase(word, swap)) end
            return nil
        end)
    end

    -- Pass 2: contractions, applied only part of the time so cadence varies (Standard and up)
    local contractionChance = not lightFlavor and CONTRACTION_CHANCE[math.min(intensity, 3)] or nil
    if contractionChance and #compiled.contractions > 0 then
        for _, contraction in ipairs(compiled.contractions) do
            text = ReplacePhrase(text, contraction, Preserve, contractionChance)
        end
    end

    -- Pass 3: single-word swaps + phonetics, one pass per word. Fixed swaps and phonetics
    -- fire most (not all) of the time, so lines don't all read the same.
    local tier = math.min(intensity, 3)
    local fixedChance = FIXED_SWAP_CHANCE[tier] or 1
    local phoneticChance = PHONETIC_CHANCE[tier] or 1
    local useSwaps = next(compiled.words) ~= nil
    local usePhonetics = #compiled.phonetics > 0 and not lightFlavor

    local addresseeGender = PronounGender(original)

    if useSwaps or usePhonetics then
        local source = text
        local previousWord
        text = text:gsub("(%a[%a']*)()", function(word, nextPos)
            local lowered = word:lower()
            local following = source:sub(nextPos, nextPos)
            local previous = previousWord
            previousWord = lowered

            local function Swapped(entry, original_word)
                local choice
                if ADDRESS_WORDS[entry.key] then
                    local list = GenderedVariants(entry, addresseeGender, dialect.genderPairs)
                    choice = PickAvoiding("swap:" .. entry.key .. ":" .. tostring(addresseeGender), list, VARIANT_HISTORY_AVOID)
                end
                local replacement = MatchCase(original_word, choice or PickVariant(entry))
                -- No doubled punctuation: "run!" -> "flee." + "!" keeps just the "!"
                if following:match("[%.!%?]") then
                    replacement = replacement:gsub("[%.!%?]+$", "")
                end
                return replacement
            end

            -- A fixed (single-variant) swap sometimes lets the plain word through
            local function Fires(entry)
                return #entry.variants > 1 or math.random() < fixedChance
            end

            if useSwaps then
                local entry = compiled.words[lowered]
                if entry and SwapFitsGrammar(lowered, previous) and Fires(entry) then
                    return MARK_SWAPPED .. Swapped(entry, word)
                end
                -- Contractions and possessives: "you're" -> "ye're", "friend's" -> "lad's"
                local base, rest = lowered:match("^(%a+)('.*)$")
                if base and compiled.words[base] and SwapFitsGrammar(base, previous) and Fires(compiled.words[base]) then
                    return MARK_SWAPPED .. Swapped(compiled.words[base], word:sub(1, #base)) .. rest
                end
            end

            if usePhonetics and math.random() < phoneticChance then
                local shifted = lowered
                for _, rule in ipairs(compiled.phonetics) do
                    shifted = shifted:gsub(rule.pattern, rule.replacement)
                end
                if shifted ~= lowered then
                    return MatchCase(word, shifted)
                end
            end

            return word
        end)

        -- Article agreement in front of swapped words only ("a beer" -> "an ale")
        text = text:gsub("%f[%a]([Aa])(%s+)" .. MARK_SWAPPED .. "([AEIOUaeiou])", "%1n%2" .. MARK_SWAPPED .. "%3")
        text = text:gsub("%f[%a]([Aa])[Nn](%s+)" .. MARK_SWAPPED .. "([B-DF-HJ-NP-TV-Zb-df-hj-np-tv-z])", "%1%2" .. MARK_SWAPPED .. "%3")
        text = text:gsub(MARK_SWAPPED, "")
    end

    if MonologueDB and MonologueDB.speechEffects ~= false then
        text = ApplySpeechEffects(text)
    end

    local translated = RestoreBlocks(text, preserved)

    -- Oath: only in a moment the engine marked (greeting, kill, low health, battle cry), never
    -- on typed chat. An oath is its own sentence, so it is safe on bare reaction lines too.
    local moment = MonologueEngine and MonologueEngine.State and MonologueEngine.State.OathMoment
    local decorated = text
    if moment then
        decorated = ApplyOath(text, compiled, moment, lightFlavor and 1 or intensity)
        if decorated ~= text and MonologueEngine.Debug then
            MonologueEngine:Debug("flourish: oath added (" .. tostring(moment) .. ")")
        end
    end
    if decorated ~= text then
        local withFlourish = RestoreBlocks(decorated, preserved)
        if #withFlourish <= MAX_CHAT_BYTES then
            return withFlourish
        end
    end

    -- Never truncate player chat (it could split a link); fall back to the original
    if #translated > MAX_CHAT_BYTES then
        return original
    end

    return translated
end

-- Effective intensity for a chat channel, honouring auto-stepdown rules
-- Per-character Dialect Strength (My Voice tab, CustomVoice.dialectStrength):
--   "FULL"  (default) follows the General tab intensity,
--   "LIGHT" keeps vocabulary swaps (and fewer oaths), skips phonetic respelling and
--           contractions,
--   "CLEAN" no translation at all (clans, allegiances, upbringing and the rest still apply).
function Translator:GetDialectStrength()
    local cv = MonologueCharDB and MonologueCharDB.CustomVoice
    local strength = type(cv) == "table" and cv.dialectStrength
    if strength == "LIGHT" or strength == "CLEAN" then return strength end
    return "FULL"
end

function Translator:GetChannelIntensity(chatType)
    if not MonologueDB then return 0 end
    local base = tonumber(MonologueDB.translationIntensity) or 0
    local strength = self:GetDialectStrength()
    if strength == "CLEAN" then return 0 end
    if strength == "LIGHT" and base > 0 then base = 1 end
    -- A racial temperament preset can nudge the tier up or down by one (never turns Off on or off)
    local profile = MonologueEngine and MonologueEngine.ActiveProfile
    local shift = profile and tonumber(profile.DialectIntensity) or 0
    if base > 0 and shift ~= 0 and strength == "FULL" then
        base = math.max(1, math.min(3, base + math.floor(shift + (shift > 0 and 0.5 or -0.5))))
    end
    if base <= 0 or not self:IsChannelTranslated(chatType) then return 0 end

    -- Group chat stays readable: step down to Light (1)
    if MonologueDB.channelStepdown and GROUP_KEYS[CHANNEL_KEYS[chatType]] then
        return math.min(base, 1)
    end

    return base
end

function Translator:TranslateForChannel(text, chatType)
    return self:Translate(text, self:GetChannelIntensity(chatType))
end

---------------------------------------------------------------------------
-- Outgoing Chat Hook
-- Typing "/s Hello" or "/y Hello" is parsed by Blizzard's ParseText step into
-- chatType = "SAY"/"YELL" plus the bare message, and only then is the edit box
-- text read and sent. A secure post-hook (hooksecurefunc) on that parse step,
-- fired with send == 1, rewrites the text in between. Blizzard's own send code
-- is never replaced, so it stays untainted and secure slash commands typed into
-- chat keep working.
--
-- Different client builds reach the parse step through different entry points
-- (the global ChatEdit_ParseText, ChatFrameUtil.ParseText, or the edit box's own
-- ParseText method), and a hook on an entry point that is never called does
-- nothing. Every entry point that exists is therefore hooked; ProcessEditBox is
-- idempotent, so a send that passes through several of them is translated once.
---------------------------------------------------------------------------

local MAX_HOOKED_WINDOWS = 50

-- Per-edit-box bookkeeping lives in Monologue's own weak-keyed table, never as fields on
-- Blizzard's chat edit boxes (so no Blizzard frame table is ever written to)
local EditBoxState = setmetatable({}, { __mode = "k" })
local function BoxState(editBox)
    local state = EditBoxState[editBox]
    if not state then
        state = {}
        EditBoxState[editBox] = state
    end
    return state
end

Translator.Hooks = {
    global = false,   -- ChatEdit_ParseText
    util = false,     -- ChatFrameUtil.ParseText
    editBoxes = 0,    -- per-edit-box ParseText methods
    temporary = false,
}

Translator.Stats = {
    sendPasses = 0,      -- parse calls with send == 1 seen by any hook
    translated = 0,      -- messages actually rewritten
    lastResult = "no message sent yet",
    lastChatType = nil,
}

local function IsSendPass(send)
    return send == 1 or send == true
end

local function Result(reason, chatType)
    Translator.Stats.lastResult = reason
    Translator.Stats.lastChatType = chatType
    return reason
end

-- Rewrites the edit box text for the channel it was just parsed into.
-- Returns a short reason string: "translated" or why the line was left alone.
function Translator:ProcessEditBox(editBox)
    if not editBox or not MonologueDB then return Result("no edit box") end
    if not MonologueDB.enabled then return Result("engine disabled") end

    local text = editBox:GetText()
    if type(text) ~= "string" or text == "" then return Result("empty text") end

    -- Slash commands that remain after parsing (/cast, /emote, ...) are never translated
    if text:sub(1, 1) == "/" then return Result("slash command") end

    -- Several hooks may fire for one send: translate each submission once
    local now = GetTime()
    local boxState = BoxState(editBox)
    if boxState.seenTime == now
        and (boxState.seenText == text or boxState.lastOutput == text) then
        return "duplicate"
    end
    boxState.seenTime = now
    boxState.seenText = text

    local chatType = editBox:GetAttribute("chatType")
    local intensity = self:GetChannelIntensity(chatType)
    -- The preview (if any) belongs to this text only
    local preview = boxState.preview
    boxState.preview = nil
    if intensity <= 0 then
        return Result(MonologueDB.translationIntensity > 0 and "channel bypassed or untranslated" or "intensity Off", chatType)
    end

    if self:IsOutOfCharacter() then return Result("out of character", chatType) end

    -- What you saw in the preview is what is sent (translation has random variants)
    local ok, translated
    if preview and preview.source == text and preview.chatType == chatType and preview.intensity == intensity then
        ok, translated = true, preview.output
    else
        ok, translated = pcall(self.Translate, self, text, intensity)
    end
    if not ok then return Result("translator error", chatType) end
    if type(translated) ~= "string" or translated == text then
        return Result(self:HasDialect() and "nothing to translate" or "no dialect loaded", chatType)
    end
    if #translated > MAX_CHAT_BYTES then return Result("over 255 characters", chatType) end

    editBox:SetText(translated)
    boxState.lastOutput = translated
    self.Stats.translated = self.Stats.translated + 1
    return Result("translated", chatType)
end

-- Out of character: the Monologue keybind or /mono ooc, or Total RP 3 set to OOC
function Translator:IsOutOfCharacter()
    if MonologueDB and MonologueDB.outOfCharacter then return true end
    if MonologueRPBridge and MonologueRPBridge.IsPlayerIC then
        local ok, isIC = pcall(MonologueRPBridge.IsPlayerIC, MonologueRPBridge)
        if ok and isIC == false then return true end
    end
    return false
end

---------------------------------------------------------------------------
-- Live preview: while you type, a line just above the chat box shows how your message will
-- come out. The preview is kept, and sent as shown if you send that exact text.
---------------------------------------------------------------------------

local PREVIEW_DELAY = 0.15
local previewFrame, previewText, previewOwner

local function HidePreview(editBox)
    if previewFrame and (editBox == nil or previewOwner == editBox) then
        previewFrame:Hide()
        previewOwner = nil
    end
end

local function EnsurePreviewFrame()
    if previewFrame then return end
    previewFrame = CreateFrame("Frame", "MonologueChatPreview", UIParent)
    previewFrame:SetFrameStrata("DIALOG")
    previewFrame:Hide()
    local bg = previewFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.65)
    previewText = previewFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    previewText:SetPoint("TOPLEFT", 6, -3)
    previewText:SetPoint("TOPRIGHT", -6, -3)
    previewText:SetJustifyH("LEFT")
    previewText:SetWordWrap(true)
end

function Translator:UpdatePreview(editBox)
    local boxState = BoxState(editBox)
    local function off()
        boxState.preview = nil
        HidePreview(editBox)
    end
    if not MonologueDB or not MonologueDB.enabled or MonologueDB.chatPreview == false then return off() end
    if not (editBox:IsShown() and editBox:HasFocus()) then return off() end

    local text = editBox:GetText()
    if type(text) ~= "string" or text == "" or text:sub(1, 1) == "/" then return off() end
    local chatType = editBox:GetAttribute("chatType")
    local intensity = self:GetChannelIntensity(chatType)
    if intensity <= 0 or self:IsOutOfCharacter() then return off() end

    local ok, translated = pcall(self.Translate, self, text, intensity)
    if not ok or type(translated) ~= "string" or translated == text or #translated > MAX_CHAT_BYTES then
        return off()
    end
    boxState.preview = { source = text, chatType = chatType, intensity = intensity, output = translated }

    EnsurePreviewFrame()
    previewOwner = editBox
    previewFrame:ClearAllPoints()
    previewFrame:SetPoint("BOTTOMLEFT", editBox, "TOPLEFT", 0, 2)
    previewFrame:SetPoint("BOTTOMRIGHT", editBox, "TOPRIGHT", 0, 2)
    previewText:SetText("|cff00ccff>|r |cffd8d8d8" .. translated .. "|r")
    previewFrame:SetHeight(math.max(14, (previewText:GetStringHeight() or 12) + 6))
    previewFrame:Show()
end

local function OnPreviewTextChanged(editBox)
    local boxState = BoxState(editBox)
    if boxState.previewPending then return end
    boxState.previewPending = true
    C_Timer.After(PREVIEW_DELAY, function()
        boxState.previewPending = nil
        pcall(Translator.UpdatePreview, Translator, editBox)
    end)
end

local function OnPreviewHide(editBox)
    BoxState(editBox).preview = nil
    HidePreview(editBox)
end

local function OnParseText(editBox, send)
    if not IsSendPass(send) then return end
    Translator.Stats.sendPasses = Translator.Stats.sendPasses + 1
    Translator:ProcessEditBox(editBox)
end

-- hooksecurefunc on a table field, tolerating missing functions and API changes
local function TryHook(owner, key)
    if type(owner) ~= "table" or type(owner[key]) ~= "function" then return false end
    return (pcall(hooksecurefunc, owner, key, OnParseText))
end

local function HookEditBox(editBox)
    if not editBox then return end
    local state = BoxState(editBox)
    if not state.hooked and TryHook(editBox, "ParseText") then
        state.hooked = true
        Translator.Hooks.editBoxes = Translator.Hooks.editBoxes + 1
    end
    -- Live preview (HookScript adds to the box's scripts; nothing on the box is replaced)
    if not state.previewHooked and editBox.HookScript then
        state.previewHooked = pcall(editBox.HookScript, editBox, "OnTextChanged", OnPreviewTextChanged)
            and pcall(editBox.HookScript, editBox, "OnHide", OnPreviewHide)
            and pcall(editBox.HookScript, editBox, "OnEditFocusLost", OnPreviewHide)
    end
end

local function HookAllEditBoxes()
    local windows = math.min(NUM_CHAT_WINDOWS or 10, MAX_HOOKED_WINDOWS)
    for i = 1, windows do
        HookEditBox(_G["ChatFrame" .. i .. "EditBox"])
    end
    for _, frameName in ipairs(CHAT_FRAMES or {}) do
        HookEditBox(_G[frameName .. "EditBox"])
    end
end

local hooksInstalled = false

local function HookChatEditBoxes()
    if hooksInstalled then return end
    hooksInstalled = true

    -- Global parse function: used by the classic send path for every edit box
    Translator.Hooks.global = TryHook(_G, "ChatEdit_ParseText")

    -- Namespaced form used by newer clients
    Translator.Hooks.util = TryHook(_G.ChatFrameUtil, "ParseText")

    -- Edit box method form (covers builds that call editBox:ParseText directly)
    HookAllEditBoxes()

    -- Whisper and other temporary windows create edit boxes later
    if type(FCF_OpenTemporaryWindow) == "function" then
        Translator.Hooks.temporary = (pcall(hooksecurefunc, "FCF_OpenTemporaryWindow", HookAllEditBoxes))
    end
    if type(FCF_OpenNewWindow) == "function" then
        pcall(hooksecurefunc, "FCF_OpenNewWindow", HookAllEditBoxes)
    end

    if not (Translator.Hooks.global or Translator.Hooks.util or Translator.Hooks.editBoxes > 0) then
        if MonologueEngine and MonologueEngine.Print then
            MonologueEngine.Print("Chat translation could not hook the chat edit box on this client. "
                .. "The test bench still works; run /mono hooks for details.")
        end
    end
end

-- Human-readable hook status for /mono hooks
function Translator:GetHookReport()
    local hooks, stats = self.Hooks, self.Stats
    return {
        string.format("Parse hooks: ChatEdit_ParseText=%s, ChatFrameUtil.ParseText=%s, edit boxes=%d, temp windows=%s",
            hooks.global and "yes" or "no", hooks.util and "yes" or "no",
            hooks.editBoxes, hooks.temporary and "yes" or "no"),
        string.format("Sends seen: %d | Messages translated: %d", stats.sendPasses, stats.translated),
        string.format("Last send: %s%s", stats.lastResult, stats.lastChatType and (" [" .. stats.lastChatType .. "]") or ""),
    }
end

local hookFrame = CreateFrame("Frame")
hookFrame:RegisterEvent("PLAYER_LOGIN")
hookFrame:SetScript("OnEvent", function(self)
    HookChatEditBoxes()
    self:UnregisterEvent("PLAYER_LOGIN")
end)
