--[[
    Monologue: Quirks
    Your own "when this happens, say one of these" rules, set up on the Abilities tab and saved
    per character in the custom voice (MonologueCharDB.CustomVoice.quirks; see
    Engine:QuirkAddLine in Monologue_Core.lua for the format). Four triggers:

      ITEM    you equip a new item, or loot / are handed one. Matched against its name, type
              and sub-type ("Shields", "Staves"), slot ("shield", "two hand") and quality
              ("uncommon green", "epic purple"). {item} is the item's name.
      PLACE   you enter a zone or subzone ("Duskwood", "Goldshire").
      TARGET  you target something alive: matched against its name, creature type and family,
              and for players their race and class. {target} is your target.
      CHAT    someone near you (/say, /yell) or in your group says the word, as a whole word.
              {target} is who said it. Your own messages never count.

    Lines go out like every other background line (on your next key press, or only in your
    chat, per your settings), with the quirk's chance x your chattiness, and each quirk has a
    cooldown. Nothing happens at login or right after a loading screen.
--]]

local Engine = MonologueEngine
if not Engine then return end
local Clean = Engine.Clean or function(v) return v end

local QUIRK_COOLDOWN = { ITEM = 120, PLACE = 600, TARGET = 300, CHAT = 300 }
local QUALITY_WORDS = { [0] = "poor grey gray", [1] = "common white", [2] = "uncommon green",
    [3] = "rare blue", [4] = "epic purple", [5] = "legendary orange" }
local CHAT_EVENTS = { CHAT_MSG_SAY = true, CHAT_MSG_YELL = true, CHAT_MSG_PARTY = true,
    CHAT_MSG_PARTY_LEADER = true, CHAT_MSG_RAID = true, CHAT_MSG_RAID_LEADER = true }

-- True when the quirk's condition holds right now
function Engine:QuirkConditionMet(cond)
    if cond == nil or cond == "ALWAYS" then return true end
    local inCombat = Clean(UnitAffectingCombat("player")) and true or false
    if cond == "COMBAT" then return inCombat end
    if cond == "PEACE" then return not inCombat end
    if cond == "DUNGEON" then
        local _, instanceType = IsInInstance()
        instanceType = Clean(instanceType)
        return instanceType == "party" or instanceType == "raid"
    end
    if cond == "RESTING" then return IsResting ~= nil and Clean(IsResting()) and true or false end
    local kind, value = tostring(cond):match("^(%u+):(%a+)$")
    if kind == "HAS" or kind == "NOT" then
        local have = false
        for _, key in ipairs(self:GetProfessionKeys()) do
            if key == value then have = true end
        end
        return (kind == "HAS") == have
    end
    if kind == "MOOD" then return self:GetMood() == value end
    return false
end

local function QuirkMatches(quirk, candidates, wholeWord)
    local want = type(quirk.match) == "string" and quirk.match:lower() or ""
    if want == "" then return true end
    local pattern = "%f[%w]" .. want:gsub("%p", "%%%0") .. "%f[%W]"
    for _, candidate in ipairs(candidates) do
        if type(candidate) == "string" and candidate ~= "" then
            local text = candidate:lower()
            if wholeWord then
                if text:find(pattern) then return true end
            elseif text:find(want, 1, true) then
                return true
            end
        end
    end
    return false
end

-- Says a line from a quirk for this trigger whose match and condition fit. opts: unit (for
-- {target}), name (overrides {target}), item ({item}). Returns true when a line was said.
function Engine:FireQuirk(trigger, candidates, opts)
    if not MonologueDB or not MonologueDB.enabled or MonologueDB.outOfCharacter then return false end
    local cv = self:GetCustomVoice()
    if not cv or type(cv.quirks) ~= "table" or #cv.quirks == 0 then return false end
    local fits = {}
    for _, quirk in ipairs(cv.quirks) do
        if quirk.trigger == trigger and type(quirk.lines) == "table" and #quirk.lines > 0
            and QuirkMatches(quirk, candidates, trigger == "CHAT") and self:QuirkConditionMet(quirk.cond) then
            fits[#fits + 1] = quirk
        end
    end
    if #fits == 0 then return false end
    local quirk = fits[math.random(#fits)]
    local key = "Quirk_" .. trigger .. "_" .. ((quirk.match ~= "" and quirk.match:lower()) or "any") .. "_" .. tostring(quirk.cond)
    local now = GetTime()
    if (self.Cooldowns.Categories[key] or 0) > now then return false end
    opts = opts or {}
    self.State.BareLine = true
    self.State.TokenTargetName = opts.name
    self.State.TokenItem = opts.item
    local ok, spoke = pcall(self.ProcessTrigger, self, 8, key, quirk.lines, (tonumber(quirk.chance) or 60) / 100, opts.unit)
    self.State.BareLine = nil
    self.State.TokenTargetName = nil
    self.State.TokenItem = nil
    if ok and spoke then
        self.Cooldowns.Categories[key] = now + (QUIRK_COOLDOWN[trigger] or 300)
        self:Debug("quirk: " .. key)
        return true
    end
    return false
end

-- Everything an item could be matched on
function Engine:QuirkItemCandidates(itemID, name)
    local candidates = {}
    local getInfo = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
    if type(getInfo) == "function" then
        local ok, _, itemType, subType, equipLoc = pcall(getInfo, itemID)
        if ok then
            candidates[#candidates + 1] = Clean(itemType)
            candidates[#candidates + 1] = Clean(subType)
            equipLoc = Clean(equipLoc)
            if type(equipLoc) == "string" and equipLoc ~= "" then
                candidates[#candidates + 1] = equipLoc:gsub("^INVTYPE_", ""):gsub("_", " "):lower()
                candidates[#candidates + 1] = rawget(_G, equipLoc)
            end
        end
    end
    local quality
    if type(GetItemInfo) == "function" then
        local ok, itemName, _, itemQuality = pcall(GetItemInfo, itemID)
        if ok then
            name = name or Clean(itemName)
            quality = Clean(itemQuality)
        end
    end
    candidates[#candidates + 1] = name
    candidates[#candidates + 1] = QUALITY_WORDS[tonumber(quality) or -1]
    return candidates, name
end

local function SnapshotEquipment(state)
    state.QuirkEquip = {}
    for slot = 1, 19 do state.QuirkEquip[slot] = Clean(GetInventoryItemID("player", slot)) end
end

local function CurrentPlaces()
    local places = {}
    for _, getter in ipairs({ GetRealZoneText, GetSubZoneText, GetMinimapZoneText }) do
        if type(getter) == "function" then
            local ok, place = pcall(getter)
            place = ok and Clean(place) or nil
            if type(place) == "string" and place ~= "" then places[place] = true end
        end
    end
    return places
end

local function SelfLootItem(message)
    if type(message) ~= "string" then return nil end
    for _, format in ipairs({ LOOT_ITEM_SELF, LOOT_ITEM_PUSHED_SELF, LOOT_ITEM_SELF_MULTIPLE, LOOT_ITEM_PUSHED_SELF_MULTIPLE }) do
        local prefix = type(format) == "string" and format:match("^(.-)%%s") or nil
        if prefix and prefix ~= "" and message:sub(1, #prefix) == prefix then
            return tonumber(message:match("|Hitem:(%d+)")), message:match("|h%[(.-)%]|h")
        end
    end
    return nil
end

function Engine:HandleQuirkEvent(event, ...)
    local state = self.State
    if event == "PLAYER_ENTERING_WORLD" then
        -- Equipment never "changes" across a loading screen; places do (a hearth, a portal),
        -- except at the very first login
        SnapshotEquipment(state)
        if state.QuirkPlaces == nil then state.QuirkPlaces = CurrentPlaces() end
        state.QuirkReady = true
        return
    end
    if not state.QuirkReady then return end
    local cv = self:GetCustomVoice()
    if not cv or type(cv.quirks) ~= "table" or #cv.quirks == 0 then
        if event == "PLAYER_EQUIPMENT_CHANGED" then SnapshotEquipment(state) end
        if event:find("^ZONE_CHANGED") then state.QuirkPlaces = CurrentPlaces() end
        return
    end

    if event == "PLAYER_EQUIPMENT_CHANGED" then
        local slot = tonumber((...))
        if not slot then return end
        local id = Clean(GetInventoryItemID("player", slot))
        local before = state.QuirkEquip and state.QuirkEquip[slot]
        if state.QuirkEquip then state.QuirkEquip[slot] = id end
        if not id or id == before then return end
        local candidates, name = self:QuirkItemCandidates(id)
        self:FireQuirk("ITEM", candidates, { item = name })
    elseif event == "CHAT_MSG_LOOT" then
        local id, name = SelfLootItem(Clean((...)))
        if not id then return end
        local candidates, itemName = self:QuirkItemCandidates(id, name)
        self:FireQuirk("ITEM", candidates, { item = itemName })
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
        local now, before = CurrentPlaces(), state.QuirkPlaces or {}
        state.QuirkPlaces = now
        local entered = {}
        for place in pairs(now) do
            if not before[place] then entered[#entered + 1] = place end
        end
        if #entered > 0 then self:FireQuirk("PLACE", entered) end
    elseif event == "PLAYER_TARGET_CHANGED" then
        if not UnitExists("target") or UnitIsUnit("target", "player") or UnitIsDeadOrGhost("target") then return end
        local candidates = { Clean(UnitName("target")), Clean(UnitCreatureType("target")), Clean(UnitCreatureFamily("target")) }
        if UnitIsPlayer("target") then
            local raceName, raceFile = UnitRace("target")
            local className = UnitClass("target")
            candidates[#candidates + 1] = Clean(raceName)
            candidates[#candidates + 1] = Clean(raceFile)
            candidates[#candidates + 1] = Clean(className)
            candidates[#candidates + 1] = "player"
        end
        self:FireQuirk("TARGET", candidates, { unit = "target" })
    elseif CHAT_EVENTS[event] then
        local message, sender = Clean((...)), Clean((select(2, ...)))
        if type(message) ~= "string" or type(sender) ~= "string" or sender == "" then return end
        local short = sender:gsub("%-.*$", "")
        if self.IsMyName and self:IsMyName(short) then return end
        self:FireQuirk("CHAT", { message }, { name = short })
    end
end

do
    local frame = CreateFrame("Frame")
    for _, event in ipairs({ "PLAYER_ENTERING_WORLD", "PLAYER_EQUIPMENT_CHANGED", "CHAT_MSG_LOOT",
        "ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "PLAYER_TARGET_CHANGED",
        "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER" }) do
        pcall(frame.RegisterEvent, frame, event)
    end
    frame:SetScript("OnEvent", function(_, event, ...)
        if not MonologueDB or not MonologueCharDB then return end
        pcall(Engine.HandleQuirkEvent, Engine, event, ...)
    end)
end
