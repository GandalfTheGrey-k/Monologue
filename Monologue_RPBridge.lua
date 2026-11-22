--[[
    Monologue RP Bridge (Version .1)
    Provides soft-dependency resolution for TRP3_API and MSP (Mary Sue Protocol).
    Evaluates IC/OOC player flags and parses dynamic replacement tokens.

    Neither Total RP 3 nor an MSP addon is required. Every external call is
    feature-detected and wrapped in pcall, so a missing or changed RP addon
    falls back to plain character names and "in character" status.

    Tokens:
      {rpname}   Player's RP name (TRP3 > MSP > character name)
      {target}   Target's RP name (TRP3 > MSP > character name > "stranger")
      {zone}     Current zone
      {targetrace} The target's race (stance greetings)
      {mob}      The creature you're fighting (situation lines)
      {count}    Grind streak: how many of this creature you've pulled in this zone
      {killer}   The creature that last killed you
      {subzone}  Current subzone (falls back to the zone)
      {daytime}  "tonight" / "this morning" / "today" / "this evening" (server time)
      {clan}     Your clan / lineage (My Voice tab), or "my people"
      {hometown} Your hometown (My Voice tab), or "home"
      {allegiance} Your allegiance / order, or "my own banner"
      {profession} Your profession (chosen or auto-detected), or "my trade"
      {oath} {nemesis} {catchphrase}  Character Anchors (My Voice tab)
      Live details (/mono tokens shows the current values; built-in lines needing one that
      isn't available right now are skipped):
      {mobtype} {amobtype} {family}  "undead" / "an undead" / "spider"
      {targetclass} {levelgap}       "rogue" / "a few levels above me"
      {weapon} {offhand} {spell}     your gear by item name, the move being used
      {resource} {myhp}              "mana" / "bleeding"
      {party} {groupsize}            a party member's name / "the three of us"
      {lastzone} Zone of the last recorded clash with the target (Nemesis ledger), or of your
                 last duel with a friendly target ({lastZone} works too)
      {kills} {deaths}  Your record against the targeted enemy (kills = times you won)
      {wins} {losses}   Your duel record against the targeted friend
      {rival}    The enemy a party member just warned about
      {rank}     Player's guild rank name
      {opener}   A fighting oath from Dialect.oaths (Fight, plus My Oaths), never the same
                 twice in a row; written as its own sentence: "{opener} You again?"
      {closer}   Retired (openers and closers became oaths in 0.1.3): removed from the line

    Dialect translation (word and phrase swaps, variants, cadence) lives in
    Monologue_Translator.lua; this module only resolves tokens and RP-addon data.
--]]

MonologueRPBridge = {}

local Bridge = MonologueRPBridge

local TRP3_STATUS_OOC = 2 -- TRP3 character.RP: 1 = IC, 2 = OOC
local MSP_STATUS_OOC = "1" -- MSP FC field: "1" = OOC, "2" = IC, "3" = LFC, "4" = Storyteller
local MAX_NAME_BYTES = 48

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function Clean(value)
    if MonologueEngine and MonologueEngine.Clean then
        return MonologueEngine.Clean(value)
    end
    return value
end

-- Strips colour/escape codes and whitespace from externally supplied names
local function SanitizeName(name)
    if type(name) ~= "string" then return nil end
    name = name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):gsub("|A.-|a", "")
    name = name:gsub("[%c]", ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s%s+", " ")
    if name == "" then return nil end
    if #name > MAX_NAME_BYTES then
        name = name:sub(1, MAX_NAME_BYTES):gsub("[\192-\255][\128-\191]*$", "")
    end
    return name
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, result = pcall(fn, ...)
    if ok then return result end
    return nil
end

local function UnitFullNameSafe(unit)
    local name, realm = UnitFullName(unit)
    name, realm = Clean(name), Clean(realm)
    if not name then return nil end
    if not realm or realm == "" then
        realm = GetNormalizedRealmName()
    end
    if realm and realm ~= "" then
        return name .. "-" .. realm, name
    end
    return name, name
end

local function NameFromCharacteristics(characteristics)
    if type(characteristics) ~= "table" then return nil end
    local first = SanitizeName(characteristics.FN)
    local last = SanitizeName(characteristics.LN)
    if first and last then return SanitizeName(first .. " " .. last) end
    return first or last
end

---------------------------------------------------------------------------
-- Total RP 3 adapter
---------------------------------------------------------------------------

local function TRP3_IsPlayerIC()
    local player = AddOn_TotalRP3 and AddOn_TotalRP3.Player
    if player and type(player.GetCurrentUser) == "function" then
        local user = SafeCall(player.GetCurrentUser)
        if user and type(user.IsInCharacter) == "function" then
            local isIC = SafeCall(user.IsInCharacter, user)
            if isIC ~= nil then return isIC and true or false end
        end
    end

    if TRP3_API and TRP3_API.profile and type(TRP3_API.profile.getPlayerCurrentProfile) == "function" then
        local profile = SafeCall(TRP3_API.profile.getPlayerCurrentProfile)
        local character = type(profile) == "table" and profile.player and profile.player.character
        if type(character) == "table" and character.RP ~= nil then
            return character.RP ~= TRP3_STATUS_OOC
        end
    end

    return nil
end

local function TRP3_GetName(unit)
    if not TRP3_API then return nil end

    if unit == "player" then
        if TRP3_API.profile and type(TRP3_API.profile.getPlayerCurrentProfile) == "function" then
            local profile = SafeCall(TRP3_API.profile.getPlayerCurrentProfile)
            local name = type(profile) == "table" and profile.player
                and NameFromCharacteristics(profile.player.characteristics)
            if name then return name end
        end
        return nil
    end

    local register = TRP3_API.register
    if not register or type(register.getUnitIDCurrentProfile) ~= "function" then return nil end

    local unitID
    if TRP3_API.utils and TRP3_API.utils.str and type(TRP3_API.utils.str.getUnitID) == "function" then
        unitID = SafeCall(TRP3_API.utils.str.getUnitID, unit)
    end
    unitID = unitID or UnitFullNameSafe(unit)
    if not unitID then return nil end

    if type(register.isUnitIDKnown) == "function" and not SafeCall(register.isUnitIDKnown, unitID) then
        return nil
    end

    local profile = SafeCall(register.getUnitIDCurrentProfile, unitID)
    return type(profile) == "table" and NameFromCharacteristics(profile.characteristics) or nil
end

---------------------------------------------------------------------------
-- Mary Sue Protocol adapter (MyRolePlay, XRP and other MSP addons)
---------------------------------------------------------------------------

local function MSP_IsPlayerIC()
    if type(msp) ~= "table" or type(msp.my) ~= "table" then return nil end
    local status = msp.my.FC
    if status == nil or status == "" then return nil end
    return tostring(status) ~= MSP_STATUS_OOC
end

local function MSP_GetName(unit)
    if type(msp) ~= "table" then return nil end

    if unit == "player" then
        return type(msp.my) == "table" and SanitizeName(msp.my.NA) or nil
    end

    if type(msp.char) ~= "table" then return nil end
    local fullName = UnitFullNameSafe(unit)
    local entry = fullName and msp.char[fullName]
    local field = type(entry) == "table" and entry.field
    return type(field) == "table" and SanitizeName(field.NA) or nil
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

-- Safely checks IC status via TRP3 or MSP (defaults to IC with no RP addon)
function Bridge:IsPlayerIC()
    local isIC = TRP3_IsPlayerIC()
    if isIC ~= nil then return isIC end

    isIC = MSP_IsPlayerIC()
    if isIC ~= nil then return isIC end

    return true
end

-- Best available roleplay name for a unit
function Bridge:GetRPName(unit)
    if not unit or not UnitExists(unit) then return nil end

    local name = TRP3_GetName(unit) or MSP_GetName(unit)
    if name then return name end

    -- Full multi-word name (e.g. "Tara Page"), not just the first name
    local fullName = MonologueEngine and MonologueEngine.GetFullPlayerName and MonologueEngine.GetFullPlayerName(unit)
    return SanitizeName(fullName or Clean(UnitName(unit)))
end

function Bridge:GetRPAddonName()
    if TRP3_API then return "Total RP 3" end
    if type(msp) == "table" and type(msp.my) == "table" then return "MSP" end
    return nil
end

---------------------------------------------------------------------------
-- Dynamic Token Resolution Engine
---------------------------------------------------------------------------

-- Replaces every occurrence of a literal {token}, resolving lazily per occurrence
local function ReplaceToken(text, token, resolver)
    if not text:find(token, 1, true) then return text end
    local pattern = token:gsub("[%{%}]", "%%%0")
    return (text:gsub(pattern, function()
        local value = resolver()
        return type(value) == "string" and value or ""
    end))
end

-- A fighting oath for the {opener} token: Dialect.oaths.Fight plus Any (My Oaths)
local function DrawOath()
    local profile = MonologueEngine and MonologueEngine.ActiveProfile
    local dialect = profile and profile.Dialect
    local oaths = type(dialect) == "table" and type(dialect.oaths) == "table" and dialect.oaths or nil
    if not oaths then return "" end
    local pool = {}
    for _, list in ipairs({ oaths.Fight, #oaths > 0 and oaths or oaths.Any }) do
        if type(list) == "table" then
            for _, line in ipairs(list) do
                if type(line) == "string" and line ~= "" then pool[#pool + 1] = line end
            end
        end
    end
    if #pool == 0 then return "" end
    -- The translator's anti-repeat picker shares its history with the oaths it adds itself
    if MonologueTranslator and MonologueTranslator.PickAvoiding then
        return MonologueTranslator.PickAvoiding("oath", pool, 4) or ""
    end
    return pool[math.random(#pool)]
end

-- Neutral words for a live-detail token that can't be filled (custom lines only)
local DETAIL_FALLBACKS = {
    mobtype = "foe", amobtype = "a foe", family = "beast", targetclass = "fighter",
    levelgap = "a tough one", weapon = "my weapon", offhand = "my shield", spell = "this",
    resource = "strength", myhp = "still standing", party = "friend", groupsize = "all of us",
}

function Bridge:ProcessTokens(text, targetUnit)
    if type(text) ~= "string" or text == "" then return "" end
    if not text:find("{", 1, true) then return text end

    local hasTarget = targetUnit and UnitExists(targetUnit)

    -- Dynamic Replacement: {rpname}
    text = ReplaceToken(text, "{rpname}", function()
        return self:GetRPName("player") or SanitizeName(Clean(UnitName("player"))) or ""
    end)

    -- Dynamic Replacement: {target}
    text = ReplaceToken(text, "{target}", function()
        -- An emote reply names the player who emoted at you, who may not be your target
        local override = MonologueEngine and MonologueEngine.State and MonologueEngine.State.TokenTargetName
        if type(override) == "string" and override ~= "" then return override end
        return (hasTarget and self:GetRPName(targetUnit)) or "stranger"
    end)

    -- Dynamic Replacement: {targetrace} (the target's race, e.g. "Night Elf")
    text = ReplaceToken(text, "{targetrace}", function()
        if hasTarget then
            local raceName = Clean(UnitRace(targetUnit))
            if type(raceName) == "string" and raceName ~= "" then return raceName end
        end
        return "stranger"
    end)

    -- Situation tokens (set by the engine while a situation line is spoken)
    local sit = MonologueEngine and MonologueEngine.State and MonologueEngine.State.SituationTokens
    sit = type(sit) == "table" and sit or {}

    -- Dynamic Replacement: {mob} (the creature you're fighting)
    text = ReplaceToken(text, "{mob}", function()
        if type(sit.mob) == "string" then return sit.mob end
        if hasTarget and not UnitIsPlayer(targetUnit) then
            local mobName = SanitizeName(Clean(UnitName(targetUnit)))
            if mobName then return mobName end
        end
        return "that thing"
    end)

    -- Dynamic Replacement: {count} (grind streak: how many of these you've pulled here)
    text = ReplaceToken(text, "{count}", function()
        return type(sit.count) == "string" and sit.count or "another"
    end)

    -- Dynamic Replacement: {killer} (the creature that last killed you)
    text = ReplaceToken(text, "{killer}", function()
        return type(sit.killer) == "string" and sit.killer or "that thing"
    end)

    -- Dynamic Replacement: {subzone} (falls back to the zone)
    text = ReplaceToken(text, "{subzone}", function()
        local sub = Clean(GetSubZoneText())
        if type(sub) ~= "string" or sub == "" then sub = Clean(GetRealZoneText()) end
        if type(sub) ~= "string" or sub == "" then sub = "this place" end
        return sub
    end)

    -- Dynamic Replacement: {daytime} ("tonight", "this morning", "today", "this evening")
    text = ReplaceToken(text, "{daytime}", function()
        local hour = Clean((GetGameTime()))
        if type(hour) ~= "number" then return "today" end
        if hour >= 21 or hour < 5 then return "tonight" end
        if hour < 12 then return "this morning" end
        if hour < 17 then return "today" end
        return "this evening"
    end)

    -- Azeroth Identity tokens (My Voice tab), each with a neutral fallback
    local engine = MonologueEngine
    local function Identity(method, fallback)
        if engine and type(engine[method]) == "function" then
            local ok, value = pcall(engine[method], engine)
            if ok and type(value) == "string" and value ~= "" then return value end
        end
        return fallback
    end
    text = ReplaceToken(text, "{clan}", function() return Identity("GetClanDisplayName", "my people") end)
    text = ReplaceToken(text, "{hometown}", function() return Identity("GetHometown", "home") end)
    text = ReplaceToken(text, "{allegiance}", function()
        if engine and engine.GetAllegiance then
            local ok, data = pcall(engine.GetAllegiance, engine)
            if ok and type(data) == "table" and type(data.name) == "string" then return data.name end
        end
        return "my own banner"
    end)
    text = ReplaceToken(text, "{profession}", function() return Identity("GetProfessionDisplayName", "my trade") end)

    -- Character Anchors (My Voice tab): free text the player wrote
    local cv = MonologueCharDB and type(MonologueCharDB.CustomVoice) == "table" and MonologueCharDB.CustomVoice or {}
    local function Anchor(field, fallback)
        local value = cv[field]
        -- Already cleaned when saved (no pipes or control characters, at most 80 bytes)
        if type(value) == "string" and value ~= "" then return value end
        return fallback
    end
    text = ReplaceToken(text, "{oath}", function() return Anchor("oath", "to see this through") end)
    text = ReplaceToken(text, "{nemesis}", function() return Anchor("nemesis", "my old enemy") end)
    text = ReplaceToken(text, "{catchphrase}", function() return Anchor("catchphrase", "") end)

    -- Dynamic Replacement: {zone}
    text = ReplaceToken(text, "{zone}", function()
        local zoneName = GetRealZoneText()
        if not zoneName or zoneName == "" then zoneName = "the wild" end
        return zoneName
    end)

    -- Score tokens: the engine's override (a spotted nemesis, a party warning), else the
    -- targeted player's record: the rival ledger for an enemy, the duel record for a friend
    local score = MonologueEngine and MonologueEngine.State and MonologueEngine.State.ScoreTokens
    score = type(score) == "table" and score or nil
    local recordCache
    local function TargetRecords()
        if recordCache then return recordCache.rival, recordCache.duel end
        recordCache = {}
        if hasTarget and UnitIsPlayer(targetUnit) and MonologueEngine then
            local tName = (MonologueEngine.GetFullPlayerName and MonologueEngine.GetFullPlayerName(targetUnit))
                or Clean(UnitName(targetUnit))
            if tName then
                -- Rivals are keyed by normalized name; GetRival handles multi-word names
                if MonologueEngine.GetRival then recordCache.rival = MonologueEngine:GetRival(tName) end
                if UnitIsFriend("player", targetUnit) and MonologueEngine.GetDuelRecord then
                    recordCache.duel = MonologueEngine:GetDuelRecord(tName)
                end
            end
        end
        if type(recordCache.rival) ~= "table" then recordCache.rival = nil end
        return recordCache.rival, recordCache.duel
    end
    local function Recorded(zone)
        if type(zone) == "string" and zone ~= "" and zone ~= "the wild" then return zone end
        return nil
    end

    -- Dynamic Replacement: {lastzone} / {lastZone}
    local function LastZone()
        if score and score.lastzone then return score.lastzone end
        local rival, duel = TargetRecords()
        return (duel and Recorded(duel.lastZone)) or (rival and Recorded(rival.lastZone)) or "our last clash"
    end
    text = ReplaceToken(text, "{lastzone}", LastZone)
    text = ReplaceToken(text, "{lastZone}", LastZone)

    -- {kills} / {deaths}: your record against an enemy (kills = times you won)
    text = ReplaceToken(text, "{kills}", function()
        if score and score.kills then return tostring(score.kills) end
        local rival = TargetRecords()
        return tostring(rival and rival.kills or 0)
    end)
    text = ReplaceToken(text, "{deaths}", function()
        if score and score.deaths then return tostring(score.deaths) end
        local rival = TargetRecords()
        return tostring(rival and rival.deaths or 0)
    end)
    -- {wins} / {losses}: your duel record against a friend
    text = ReplaceToken(text, "{wins}", function()
        local _, duel = TargetRecords()
        return tostring(duel and duel.wins or 0)
    end)
    text = ReplaceToken(text, "{losses}", function()
        local _, duel = TargetRecords()
        return tostring(duel and duel.losses or 0)
    end)
    -- {rival}: the enemy a party member just spotted
    text = ReplaceToken(text, "{rival}", function()
        return (score and type(score.rival) == "string" and score.rival) or "them"
    end)

    -- Dynamic Replacement: {rank}
    text = ReplaceToken(text, "{rank}", function()
        local rankName = "Member"
        if IsInGuild() then
            local _, guildRankName = GetGuildInfo("player")
            if type(guildRankName) == "string" and guildRankName ~= "" then
                rankName = guildRankName
            end
        end
        return rankName
    end)

    -- Dynamic Replacement: {opener} (an oath; with none to draw, the token and its space go)
    if text:find("{opener}", 1, true) then
        local oath = DrawOath()
        if oath == "" then
            text = text:gsub("%s*{opener}%s*", " ")
        else
            text = ReplaceToken(text, "{opener}", function() return oath end)
        end
    end

    -- {closer} is retired: drop it and the space before it
    text = text:gsub("%s*{closer}", "")

    -- Live-detail tokens ({weapon}, {spell}, {party}, ...: Engine.DetailTokens). Built-in
    -- lines that need an unavailable detail are skipped before they get here; the fallback
    -- words only show in a custom line typed by the player.
    local details = MonologueEngine and MonologueEngine.DetailTokens
    if type(details) == "table" then
        for name, resolver in pairs(details) do
            local token = "{" .. name .. "}"
            text = ReplaceToken(text, token, function()
                local ok, value = pcall(resolver, targetUnit or "target")
                if ok and type(value) == "string" and value ~= "" then return value end
                return DETAIL_FALLBACKS[name] or ""
            end)
        end
    end

    -- A line that opens with a token ("{myhp}, and still...") still starts with a capital
    text = text:gsub("^(%s*)(%l)", function(space, letter) return space .. letter:upper() end)

    return text
end
