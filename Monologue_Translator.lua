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
          interjections = { "aye", "mind ye" },
              -- Occasionally dropped in after the first comma of a longer line.
          openers = { "Aye,", "Listen up," },
              -- Standard (now and then) and Unhinged (often). Prepended; skipped when the line already opens with a greeting or
              -- exclamation. Never the same one twice in a row (last 4 are remembered).
          closers = { ", by Magni's beard!", ", aye." },
              -- Standard (now and then, never with an opener) and Unhinged. A closer starting with punctuation replaces the line's closing
              -- punctuation (a question keeps its question mark). Skipped when the line already
              -- ends in "..." or several marks. "suffixes" is an older name for the same list.
      }

    Case and punctuation: a swap keeps the case of what it replaces ("Friend" -> "Kin",
    "RUN" -> "FLEE"), and never doubles punctuation ("Watch out!" + "mind yerself!" -> "Mind yerself!").

    Intensity: 0 Off, 1 Light (swaps, plus a light sprinkle of phonetics and contractions),
    2 Standard (full phonetics, more contractions, rare interjections), 3 Unhinged (+ openers,
    closers, more interjections). Flourish chances are also scaled by the chattiness setting.
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
local FRAGMENT_HISTORY_AVOID = 4  -- openers, closers and interjections
local HISTORY_LIMIT = 12

-- Base chance per intensity (1 = Light, 2 = Standard, 3 = Unhinged); missing = never
local OPENER_CHANCE = { [2] = 0.10, [3] = 0.25 }
local CLOSER_CHANCE = { [2] = 0.12, [3] = 0.35 }
local INTERJECTION_CHANCE = { [2] = 0.05, [3] = 0.20 }
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
local CHANNEL_RULES = {
    SAY = "full",
    YELL = "full",
    PARTY = "party",
    PARTY_LEADER = "party",
    RAID = "group",
    RAID_LEADER = "group",
    RAID_WARNING = "group",
    INSTANCE_CHAT = "group",
    INSTANCE_CHAT_LEADER = "group",
}

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

-- Words that already open a line like a greeting; an auto opener is never added in front of them
local GREETING_WORDS = {}
for word in ("hello hi hey greetings hail welcome salutations well good goodbye farewell ahoy ho oh ah "
    .. "aye yes no nay lok'tar ishnu fair blessings behold hark listen mark"):gmatch("%S+") do
    GREETING_WORDS[word] = true
end

-- First words that read naturally in lower case after an opener ("Aye, the plan is...")
local DECAPITALIZE = {}
for word in ("the a an we you it this that there let's let do did can are is what where who how why when "
    .. "my your our they he she"):gmatch("%S+") do
    DECAPITALIZE[word] = true
end

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

-- Also used by the RP bridge for {opener} / {closer} fragments, so the same opener or closer
-- is never picked twice in a row whichever route it comes from
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
        openers = {}, closers = {}, interjections = {},
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

    compiled.openers = CompileStringList(dialect.openers)
    compiled.closers = CompileStringList(dialect.closers, dialect.suffixes) -- suffixes = older name
    compiled.interjections = CompileStringList(dialect.interjections)

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

local function StartsWithGreeting(text)
    local first = text:match("^%s*([%a']+)")
    if not first then return false end
    if GREETING_WORDS[first:lower()] then return true end
    -- A leading interjection: "Wow!", "Really?", "Well, ..."
    return text:match("^%s*[%a']+[!%?,]") ~= nil
end

-- Prepends an opener, unless the line already opens like a greeting or an exclamation, or
-- starts with a masked block (an emote, OOC text or an unresolved {token})
local function ApplyOpener(text, compiled, intensity, force)
    if #compiled.openers == 0 then return text end
    if not force and math.random() >= FlourishChance(OPENER_CHANCE, intensity) then return text end
    if text:find("^%s*" .. MARK_OPEN) or StartsWithGreeting(text) then return text end

    local opener = PickAvoiding("opener", compiled.openers, FRAGMENT_HISTORY_AVOID)
    if not opener then return text end
    opener = opener:gsub("%s+$", "")
    if opener:match("%w$") then opener = opener .. "," end

    text = text:gsub("^%s+", "")
    -- After a comma the line carries on, so a leading "The" or "You" reads better in lower case
    if opener:match("[,;:]$") then
        local first = text:match("^([%a']+)")
        if first and DECAPITALIZE[first:lower()] and first:sub(1, 1):match("%u") and not first:match("^%u%u") then
            text = first:sub(1, 1):lower() .. text:sub(2)
        end
    end
    return opener .. " " .. text
end

-- Appends a closer to the masked text; returns nil when the line should not take one
local function AppendCloser(text, closer)
    -- Never tack an in-character closer onto a trailing OOC/emote/link block
    if text:find(MARK_CLOSE .. "%s*$") then return nil end
    -- Or onto a line that already trails off or ends in several marks ("...", "?!", "!!")
    if text:find("%.%.%.%s*$") or text:find("[%.!%?][%.!%?]+%s*$") then return nil end

    local body, punctuation = text:match("^(.-)([%.!%?]*)%s*$")
    if not body or not body:find("%a") then return nil end

    local isQuestion = punctuation:find("?", 1, true) ~= nil

    if closer:match("^[,;:%.!%?]") then
        if isQuestion then
            closer = closer:gsub("[%.!%?]+$", "") .. "?"
        end
        return body .. closer
    end

    return body .. punctuation .. " " .. closer
end

local function ApplyCloser(text, compiled, intensity, force)
    if #compiled.closers == 0 then return text end
    if not force and math.random() >= FlourishChance(CLOSER_CHANCE, intensity) then return text end
    local closer = PickAvoiding("closer", compiled.closers, FRAGMENT_HISTORY_AVOID)
    return closer and AppendCloser(text, closer) or text
end

-- Drops a racial interjection in after the first comma of a longer line ("I think, aye, we go")
local function ApplyInterjection(text, compiled, intensity)
    if #compiled.interjections == 0 then return text end
    if math.random() >= FlourishChance(INTERJECTION_CHANCE, intensity) then return text end

    local words = 0
    for _ in text:gmatch("%a+") do words = words + 1 end
    if words < 6 then return text end

    local head, tail = text:match("^(.-%a),%s+(%a.*)$")
    if not head then return text end
    local interjection = PickAvoiding("interjection", compiled.interjections, FRAGMENT_HISTORY_AVOID)
    if not interjection then return text end
    return head .. ", " .. interjection .. ", " .. tail
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
        or #compiled.phonetics > 0 or #compiled.openers > 0 or #compiled.closers > 0
        or #compiled.interjections > 0
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

    -- Nothing in-character left to translate
    if not text:find("%a") then return original end

    -- Pass 1: multi-word phrase swaps, longest first (each replacement is masked from later passes)
    for _, phrase in ipairs(compiled.phrases) do
        text = ReplacePhrase(text, phrase, Preserve, nil)
    end

    -- Light Flavor (Dialect Strength): vocabulary and openers/closers only
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
        text = text:gsub("%a[%a']*", function(word)
            local swap = flavor.wordSwaps[word:lower()]
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

    if useSwaps or usePhonetics then
        local source = text
        text = text:gsub("(%a[%a']*)()", function(word, nextPos)
            local lowered = word:lower()
            local following = source:sub(nextPos, nextPos)

            local function Swapped(entry, original_word)
                local replacement = MatchCase(original_word, PickVariant(entry))
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
                if entry and Fires(entry) then
                    return MARK_SWAPPED .. Swapped(entry, word)
                end
                -- Contractions and possessives: "you're" -> "ye're", "friend's" -> "lad's"
                local base, rest = lowered:match("^(%a+)('.*)$")
                if base and compiled.words[base] and Fires(compiled.words[base]) then
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

    local translated = RestoreBlocks(text, preserved)

    -- Cadence and flourishes: interjection, opener and closer (Standard: now and then, at
    -- most one of opener/closer per line; Unhinged: often, both allowed). A shout in capitals
    -- (battle cries) never takes an opener or closer.
    -- Light Flavor keeps openers/closers at the Standard rate, but no interjections.
    -- A "bare" line (a short reaction: situation, identity, idle, party) takes no opener,
    -- closer or interjection: "Here's how it goes, the elementals..." reads wrong.
    local bare = MonologueEngine and MonologueEngine.State and MonologueEngine.State.BareLine
    local decorated = text
    local flourishLevel = lightFlavor and 2 or intensity
    if not lightFlavor and not bare then decorated = ApplyInterjection(decorated, compiled, intensity) end
    local plain = text:gsub(MARK_OPEN .. "%d+" .. MARK_CLOSE, "")
    local isShout = (plain:find("%u%u") and not plain:find("%l")) or bare
    -- A layer's own opener or closer replaces the race's for this line
    local flavorDone = false
    if flavor and not isShout then
        local lists = { openers = flavor.openers or {}, closers = flavor.closers or {} }
        local before = decorated
        if #lists.openers > 0 and (#lists.closers == 0 or math.random() < 0.5) then
            decorated = ApplyOpener(decorated, lists, flourishLevel, true)
        elseif #lists.closers > 0 then
            decorated = ApplyCloser(decorated, lists, flourishLevel, true)
        end
        flavorDone = decorated ~= before
        if flavorDone and MonologueEngine and MonologueEngine.Debug then
            MonologueEngine:Debug("flourish: layer flavor added")
        end
    end
    if not isShout and not flavorDone then
        local beforeOpener = decorated
        decorated = ApplyOpener(decorated, compiled, flourishLevel)
        local gotOpener = decorated ~= beforeOpener
        if not (gotOpener and flourishLevel < 3) then
            local beforeCloser = decorated
            decorated = ApplyCloser(decorated, compiled, flourishLevel)
            if decorated ~= beforeCloser and MonologueEngine and MonologueEngine.Debug then
                MonologueEngine:Debug("flourish: closer added")
            end
        end
        if gotOpener and MonologueEngine and MonologueEngine.Debug then
            MonologueEngine:Debug("flourish: opener added")
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
--   "LIGHT" keeps vocabulary swaps and the race's openers/closers, skips phonetic respelling,
--           contractions and interjections,
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
    local rule = chatType and CHANNEL_RULES[chatType]
    if not rule or base <= 0 then return 0 end

    if MonologueDB.channelStepdown then
        if rule == "group" then
            return 0 -- Completely bypass translation in competitive raid/instance channels
        elseif rule == "party" then
            return math.min(base, 1) -- Step down to Light (1)
        end
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
    if intensity <= 0 then
        return Result(MonologueDB.translationIntensity > 0 and "channel bypassed or untranslated" or "intensity Off", chatType)
    end

    if MonologueRPBridge and MonologueRPBridge.IsPlayerIC then
        local ok, isIC = pcall(MonologueRPBridge.IsPlayerIC, MonologueRPBridge)
        if ok and isIC == false then return Result("out of character", chatType) end
    end

    local ok, translated = pcall(self.Translate, self, text, intensity)
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
    if not editBox or BoxState(editBox).hooked then return end
    if TryHook(editBox, "ParseText") then
        BoxState(editBox).hooked = true
        Translator.Hooks.editBoxes = Translator.Hooks.editBoxes + 1
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
