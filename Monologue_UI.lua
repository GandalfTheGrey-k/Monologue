--[[
    Monologue Canvas UI Config (Version .1)
    Lightweight, modern settings frame using Canvas layout standards.

    - Standalone movable panel (/mono ui) built on BackdropTemplate
    - Canvas category in the game's AddOns settings that opens the panel
    - Global settings write to MonologueDB
    - Growth Arc persona selectors write to MonologueCharDB (per character)
      through MonologueEngine:SetGrowthArcPersona
--]]

MonologueUI = {}

local UI = MonologueUI

local PANEL_WIDTH = 560
local PANEL_HEIGHT = 724
local LEFT = 22
local CONTROL_X = 210
local DROPDOWN_WIDTH = 220

local INTENSITY_OPTIONS = {
    { value = 0, text = "Off" },
    { value = 1, text = "Light (vocabulary)" },
    { value = 2, text = "Standard (+ accent, the odd oath)" },
    { value = 3, text = "Unhinged (+ more oaths)" },
}

-- The dialog-box background texture is see-through; a near-opaque dark layer underneath
-- keeps text readable over a busy game world
local SOLID_BG_ALPHA = 0.92
local function SolidBackground(frame)
    local bg = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    bg:SetPoint("TOPLEFT", 10, -10)
    bg:SetPoint("BOTTOMRIGHT", -10, 10)
    bg:SetColorTexture(0.04, 0.04, 0.06, SOLID_BG_ALPHA)
    return bg
end

-- Speech from background events (greetings, duel and PvP reactions) can't be sent to chat
-- without triggering blocked-action warnings, so it is shown locally or held for your next action
local BACKGROUND_OPTIONS = {
    { value = "QUEUE", text = "Say aloud on my next ability" },
    { value = "LOCAL", text = "Show only in my chat" },
}

local NO_PERSONA = ""

---------------------------------------------------------------------------
-- Widget Builders
---------------------------------------------------------------------------

local function CreateLabel(parent, text, template)
    local label = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlight")
    label:SetJustifyH("LEFT")
    label:SetText(text)
    return label
end

local function CreateSectionHeader(parent, text, y)
    local header = CreateLabel(parent, text, "GameFontNormal")
    header:SetPoint("TOPLEFT", LEFT, y)

    local rule = parent:CreateTexture(nil, "ARTWORK")
    rule:SetColorTexture(1, 0.82, 0, 0.25)
    rule:SetHeight(1)
    rule:SetPoint("LEFT", header, "RIGHT", 8, 0)
    rule:SetPoint("RIGHT", parent, "RIGHT", -LEFT, 0)
    return header
end

local function CreateCheckbox(parent, text, y, getter, setter)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", LEFT - 4, y)

    local label = cb.Text or cb.text
    if not label then
        label = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    end
    label:SetFontObject("GameFontHighlight")
    label:SetText(text)
    cb.label = label

    cb:SetScript("OnClick", function(self)
        setter(self:GetChecked() and true or false)
        UI:Refresh()
    end)
    cb.Refresh = function(self)
        self:SetChecked(getter() and true or false)
    end
    return cb
end

-- Modern menu-driven dropdown. `options` may be a table or a function returning one.
local function CreateDropdown(parent, width, options, getter, setter)
    local dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
    dropdown:SetWidth(width)

    dropdown:SetupMenu(function(_, rootDescription)
        local list = type(options) == "function" and options() or options
        for _, option in ipairs(list) do
            rootDescription:CreateRadio(option.text,
                function() return getter() == option.value end,
                function()
                    setter(option.value)
                    -- Rebuild menus after the click handler unwinds
                    C_Timer.After(0, function() UI:Refresh() end)
                end)
        end
    end)

    dropdown.Refresh = function(self)
        self:GenerateMenu()
    end
    return dropdown
end

-- Dropdown with submenus: groups() returns { { text, options = { { value, text } } } } or a
-- plain { value, text } entry for a top-level choice
local function CreateGroupedDropdown(parent, width, groups, getter, setter)
    local dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
    dropdown:SetWidth(width)
    local function Radio(description, option)
        description:CreateRadio(option.text,
            function() return getter() == option.value end,
            function()
                setter(option.value)
                C_Timer.After(0, function() UI:Refresh() end)
            end)
    end
    dropdown:SetupMenu(function(_, rootDescription)
        for _, group in ipairs(groups()) do
            if group.options then
                local submenu = rootDescription:CreateButton(group.text)
                for _, option in ipairs(group.options) do Radio(submenu, option) end
            else
                Radio(rootDescription, group)
            end
        end
    end)
    dropdown.Refresh = function(self) self:GenerateMenu() end
    return dropdown
end

local function CreateRow(parent, text, y, control)
    local label = CreateLabel(parent, text)
    label:SetPoint("TOPLEFT", LEFT, y - 6)
    control:SetPoint("TOPLEFT", CONTROL_X, y)
    return label
end

---------------------------------------------------------------------------
-- Data Accessors
---------------------------------------------------------------------------

local function GetPersonaOptions()
    local options = { { value = NO_PERSONA, text = "None (race & class only)" } }
    for _, key in ipairs(MonologueEngine:GetPersonaKeys()) do
        options[#options + 1] = { value = key, text = MonologueEngine:GetPersonaDisplayName(key) }
    end
    return options
end

local function GetArcPersona(arc)
    local growthArc = MonologueCharDB and MonologueCharDB.GrowthArc
    local key = growthArc and growthArc[arc]
    if key and MonologueEngine.Data.Personas[key] then return key end
    return NO_PERSONA
end

local function DescribeIntensity(value)
    for _, option in ipairs(INTENSITY_OPTIONS) do
        if option.value == value then return option.text end
    end
    return tostring(value)
end

---------------------------------------------------------------------------
-- Panel Construction
---------------------------------------------------------------------------

function UI:CreatePanel()
    if self.Frame then return end

    self.Controls = {}
    local controls = self.Controls

    local f = CreateFrame("Frame", "MonologueConfigFrame", UIParent, "BackdropTemplate")
    f:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    SolidBackground(f)

    -- Close on Escape
    tinsert(UISpecialFrames, "MonologueConfigFrame")

    -- Title Text
    local title = CreateLabel(f, "Monologue", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", LEFT, -20)

    local closeX = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeX:SetPoint("TOPRIGHT", -6, -6)
    self:AddTabs(f, "settings")

    -----------------------------------------------------------------------
    -- Basics (MonologueDB, account-wide)
    -----------------------------------------------------------------------
    CreateSectionHeader(f, "Basics", -52)

    controls.enabled = CreateCheckbox(f, "Monologue is on", -68,
        function() return MonologueDB.enabled end,
        function(value) MonologueDB.enabled = value end)

    controls.stepdown = CreateCheckbox(f, "Lighter accent in group chat (party, raid, instance)", -94,
        function() return MonologueDB.channelStepdown end,
        function(value) MonologueDB.channelStepdown = value end)

    controls.intensity = CreateDropdown(f, DROPDOWN_WIDTH, INTENSITY_OPTIONS,
        function() return MonologueDB.translationIntensity end,
        function(value) MonologueDB.translationIntensity = value end)
    CreateRow(f, "Accent strength:", -128, controls.intensity)

    controls.openWorld = CreateDropdown(f, DROPDOWN_WIDTH, BACKGROUND_OPTIONS,
        function() return MonologueDB.backgroundSpeech end,
        function(value) MonologueDB.backgroundSpeech = value end)
    CreateRow(f, "Greetings & reactions:", -160, controls.openWorld)

    local backgroundHint = CreateLabel(f, "|cff888888Greetings, duel and PvP reactions happen without a key press, so the "
        .. "game makes them wait: they're said in /s on your next ability press (greetings wait 10 seconds), "
        .. "or shown only in your chat.|r", "GameFontHighlightSmall")
    backgroundHint:SetPoint("TOPLEFT", LEFT, -192)
    backgroundHint:SetWidth(PANEL_WIDTH - LEFT * 2)
    backgroundHint:SetWordWrap(true)

    -----------------------------------------------------------------------
    -- Growth Arc (MonologueCharDB, per character)
    -----------------------------------------------------------------------
    CreateSectionHeader(f, "Personality by Level (this character)", -228)

    local arcHint = CreateLabel(f, "", "GameFontHighlightSmall")
    arcHint:SetPoint("TOPLEFT", LEFT, -248)
    arcHint:SetWidth(PANEL_WIDTH - LEFT * 2)
    controls.arcHint = arcHint

    controls.arcRows = {}
    local rowY = -268
    for _, bracket in ipairs(MonologueEngine:GetGrowthBrackets()) do
        local arc = bracket.arc
        local dropdown = CreateDropdown(f, DROPDOWN_WIDTH, GetPersonaOptions,
            function() return GetArcPersona(arc) end,
            function(value)
                MonologueEngine:SetGrowthArcPersona(arc, value ~= NO_PERSONA and value or nil)
            end)
        local label = CreateRow(f, "", rowY, dropdown)
        controls.arcRows[#controls.arcRows + 1] = { bracket = bracket, dropdown = dropdown, label = label }
        rowY = rowY - 32
    end

    -----------------------------------------------------------------------
    -- Live Test Bench
    -----------------------------------------------------------------------
    CreateSectionHeader(f, "Try Your Accent", -372)

    local testBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    testBox:SetSize(300, 28)
    testBox:SetPoint("TOPLEFT", LEFT + 6, -390)
    testBox:SetAutoFocus(false)
    testBox:SetMaxLetters(255)
    testBox:SetText("Hello friend, do you want a beer?")
    testBox:SetScript("OnEscapePressed", testBox.ClearFocus)

    local testBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    testBtn:SetSize(120, 26)
    testBtn:SetPoint("LEFT", testBox, "RIGHT", 10, 0)
    testBtn:SetText("Translate")

    local outText = CreateLabel(f, "|cff888888Type a line and press Translate to hear it in your character's accent.|r", "GameFontHighlightSmall")
    outText:SetPoint("TOPLEFT", LEFT, -426)
    outText:SetWidth(PANEL_WIDTH - LEFT * 2)
    outText:SetHeight(48)
    outText:SetJustifyV("TOP")
    outText:SetWordWrap(true)

    local function RunTest()
        local input = testBox:GetText() or ""
        if input == "" then
            outText:SetText("|cff888888Type a line to preview.|r")
            return
        end
        local intensity = MonologueDB.translationIntensity
        local translated = MonologueTranslator:Translate(input, intensity)
        local note = ""
        if intensity <= 0 then
            note = "  |cffff8800(translation is Off)|r"
        elseif not MonologueTranslator:HasDialect() then
            note = "  |cffff8800(no dialect loaded for this character)|r"
        end
        outText:SetText("|cff00ff00Result [" .. DescribeIntensity(intensity) .. "]:|r " .. translated .. note)
        testBox:ClearFocus()
    end
    testBtn:SetScript("OnClick", RunTest)
    testBox:SetScript("OnEnterPressed", RunTest)

    -----------------------------------------------------------------------
    -- Debug Mode (MonologueDB.debugMode, also /mono debug)
    -----------------------------------------------------------------------
    controls.debug = CreateCheckbox(f, "Debug Mode: OFF", -480,
        function() return MonologueDB.debugMode end,
        function(value) MonologueEngine:SetDebugMode(value) end)
    local baseDebugRefresh = controls.debug.Refresh
    controls.debug.Refresh = function(self)
        baseDebugRefresh(self)
        self.label:SetText("Debug Mode: " .. (MonologueDB.debugMode and "|cff00ff00ON|r" or "|cff888888OFF|r"))
    end
    controls.debug:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Debug Mode", 1, 0.82, 0)
        GameTooltip:AddLine("Prints [Monologue Debug] lines in chat: speech routing, PvP kills, duels, name upgrades and blocked addon actions. Same as /mono debug.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    controls.debug:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Strict Safe-Mode (MonologueDB.strictSafeMode, also /mono safemode)
    controls.strict = CreateCheckbox(f, "Strict Safe-Mode (Manual & Local Only)", -506,
        function() return MonologueDB.strictSafeMode end,
        function(value) MonologueDB.strictSafeMode = value and true or false end)
    controls.strict:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Strict Safe-Mode", 1, 0.82, 0)
        GameTooltip:AddLine("Automated lines (pulls, greetings, reactions, party banter) only show in your own chat window; nothing is said in /s for you. Typed chat is still translated, and the Battle Cry and Greet buttons still speak. Same as /mono safemode.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    controls.strict:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Translate In (MonologueDB.translateChannels): which chat channels get the accent
    local channelLabel = CreateLabel(f, "Translate in:", "GameFontNormal")
    channelLabel:SetPoint("TOPLEFT", LEFT, -540)
    local channelHint = CreateLabel(f, "|cff888888your typed chat and Monologue's own lines|r", "GameFontHighlightSmall")
    channelHint:SetPoint("LEFT", channelLabel, "RIGHT", 8, 0)
    controls.channels = {}
    local CHANNEL_BOXES = {
        { "SAY", "Say" }, { "YELL", "Yell" }, { "PARTY", "Party" }, { "RAID", "Raid" },
        { "INSTANCE", "Instance" }, { "GUILD", "Guild" }, { "OFFICER", "Officer" }, { "WHISPER", "Whisper" },
    }
    for i, entry in ipairs(CHANNEL_BOXES) do
        local key, text = entry[1], entry[2]
        local col, row = (i - 1) % 4, math.floor((i - 1) / 4)
        local cb = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
        cb:SetSize(24, 24)
        cb:SetPoint("TOPLEFT", LEFT - 4 + col * 108, -556 - row * 24)
        local label = cb.Text or cb.text
        if not label then
            label = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            label:SetPoint("LEFT", cb, "RIGHT", 2, 0)
        end
        label:SetFontObject("GameFontHighlight")
        label:SetText(text)
        cb:SetScript("OnClick", function(self)
            MonologueDB.translateChannels = MonologueDB.translateChannels or {}
            MonologueDB.translateChannels[key] = self:GetChecked() and true or false
        end)
        cb.Refresh = function(self)
            local channels = MonologueDB.translateChannels
            self:SetChecked(type(channels) == "table" and channels[key] == true)
        end
        controls.channels[#controls.channels + 1] = cb
    end

    -- Live preview and speech effects (MonologueDB.chatPreview / speechEffects)
    controls.preview = CreateCheckbox(f, "Preview above the chat box", -608,
        function() return MonologueDB.chatPreview ~= false end,
        function(value) MonologueDB.chatPreview = value and true or false end)
    controls.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Translation preview", 1, 0.82, 0)
        GameTooltip:AddLine("While you type, a line just above the chat box shows how your message will come out. What you see is what is sent.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    controls.preview:SetScript("OnLeave", function() GameTooltip:Hide() end)
    controls.effects = CreateCheckbox(f, "Speech effects", -608,
        function() return MonologueDB.speechEffects ~= false end,
        function(value) MonologueDB.speechEffects = value and true or false end)
    controls.effects:ClearAllPoints()
    controls.effects:SetPoint("TOPLEFT", LEFT + 212, -608)
    controls.effects:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Speech effects", 1, 0.82, 0)
        GameTooltip:AddLine("Your words slur when you're drunk (tipsy, drunk, smashed) and shake when you're badly hurt in a fight. Applies to your typed chat and your character's lines.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    controls.effects:SetScript("OnLeave", function() GameTooltip:Hide() end)
    controls.typos = CreateCheckbox(f, "Fix common typos", -632,
        function() return MonologueDB.fixTypos == true end,
        function(value) MonologueDB.fixTypos = value and true or false end)
    controls.typos:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Fix common typos", 1, 0.82, 0)
        GameTooltip:AddLine("Fixes words with one clear spelling in your typed chat (teh -> the, dont -> don't, i -> I), and one-letter slips when only one real word fits (wepaon -> weapon, ironforg -> Ironforge). Names, links, SHOUTING and Words Never Translated are left alone.", 1, 1, 1, true)
        GameTooltip:AddLine("Try it without sending: /mono test <text>. Start a message with !! to send it exactly as typed, untranslated.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    controls.typos:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Send key (MonologueDB.translateKey, also /mono sendkey)
    local sendKeyLabel = CreateLabel(f, "Translate on:")
    sendKeyLabel:SetPoint("TOPLEFT", LEFT + 212, -637)
    controls.sendKey = CreateDropdown(f, 150, {
            { value = "ENTER", text = "Enter" },
            { value = "SHIFT", text = "Shift+Enter only" },
            { value = "CTRL", text = "Ctrl+Enter only" },
        },
        function() return MonologueDB.translateKey or "ENTER" end,
        function(value) MonologueDB.translateKey = value end)
    controls.sendKey:SetPoint("LEFT", sendKeyLabel, "RIGHT", 8, 0)
    controls.sendKey:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Translate on", 1, 0.82, 0)
        GameTooltip:AddLine("Enter: everything you type in a Translate-in channel gets your accent.", 1, 1, 1, true)
        GameTooltip:AddLine("Shift+Enter or Ctrl+Enter only: plain Enter sends your message exactly as typed; hold Shift or Ctrl as you press Enter to send it translated. Same as /mono sendkey.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    controls.sendKey:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -----------------------------------------------------------------------
    -- Footer: active profile status + close
    -----------------------------------------------------------------------
    local status = CreateLabel(f, "", "GameFontDisableSmall")
    status:SetPoint("BOTTOMLEFT", LEFT, 26)
    status:SetWidth(PANEL_WIDTH - LEFT * 2 - 280)
    status:SetWordWrap(true)
    controls.status = status

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetSize(100, 25)
    closeBtn:SetPoint("BOTTOMRIGHT", -20, 20)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    local rosterBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    rosterBtn:SetSize(160, 25)
    rosterBtn:SetPoint("RIGHT", closeBtn, "LEFT", -8, 0)
    rosterBtn:SetText("Rivals & Friends")
    rosterBtn:SetScript("OnClick", function() UI:ToggleRoster() end)

    f:SetScript("OnShow", function() UI:Refresh() end)

    f:Hide()
    self.Frame = f
end

---------------------------------------------------------------------------
-- Refresh
---------------------------------------------------------------------------

function UI:Refresh()
    if not self.Frame or not MonologueDB or not MonologueCharDB then return end
    local controls = self.Controls

    controls.enabled:Refresh()
    controls.stepdown:Refresh()
    controls.intensity:Refresh()
    controls.openWorld:Refresh()
    controls.debug:Refresh()
    controls.strict:Refresh()
    controls.preview:Refresh()
    controls.effects:Refresh()
    controls.typos:Refresh()
    controls.sendKey:Refresh()
    for _, cb in ipairs(controls.channels) do cb:Refresh() end

    local context = MonologueEngine.ActiveContext or {}
    local personaCount = #MonologueEngine:GetPersonaKeys()
    if personaCount == 0 then
        controls.arcHint:SetText("|cff888888No personas installed yet. Add packs under personas\\ to choose one per stage.|r")
    else
        controls.arcHint:SetText(string.format("|cff888888%d persona(s) installed. Level %s; the highlighted stage is active.|r",
            personaCount, tostring(context.level or UnitLevel("player"))))
    end

    for _, row in ipairs(controls.arcRows) do
        local bracket = row.bracket
        local text = string.format("Levels %d-%d:", bracket.minLevel, bracket.maxLevel)
        if bracket.arc == context.arc then
            text = "|cff00ccff" .. text .. " (current)|r"
        end
        row.label:SetText(text)
        row.dropdown:Refresh()
    end

    controls.status:SetText(string.format("Active: %s / %s  |  Persona: %s  |  Profile: %s",
        context.race or "no race pack", context.class or "no class pack",
        context.persona and MonologueEngine:GetPersonaDisplayName(context.persona) or "none",
        context.profile or "none"))
end

-- Keeps the Debug Mode checkbox in step with MonologueDB.debugMode (called by /mono debug)
function UI:RefreshDebugControl()
    if self.Controls and self.Controls.debug then
        self.Controls.debug:Refresh()
    end
end

---------------------------------------------------------------------------
-- Tabs: "General" (self.Frame), "Voice Lines" (self.LinesFrame) and "My Voice"
-- (self.VoiceFrame). Three panels of the same size that swap in place.
---------------------------------------------------------------------------

local TAB_ORDER = {
    { key = "settings", text = "General", width = 70 },
    { key = "lines", text = "Voice Lines", width = 86 },
    { key = "voice", text = "My Voice", width = 74 },
    { key = "abilities", text = "Abilities", width = 70 },
}

function UI:GetTabFrame(key)
    if key == "lines" then return self.LinesFrame end
    if key == "voice" then return self.VoiceFrame end
    if key == "abilities" then return self.AbilitiesFrame end
    return self.Frame
end

function UI:GetShownTab()
    for _, tab in ipairs(TAB_ORDER) do
        local frame = self:GetTabFrame(tab.key)
        if frame and frame:IsShown() then return frame end
    end
    return nil
end

-- /mono toggles the window: closes whichever tab is open, or opens General
function UI:Toggle()
    if not MonologueDB or not MonologueCharDB then return end
    self:CreatePanel()
    if self:GetShownTab() then
        for _, tab in ipairs(TAB_ORDER) do
            local frame = self:GetTabFrame(tab.key)
            if frame then frame:Hide() end
        end
    else
        self.Frame:Show()
    end
end

function UI:Open()
    if not MonologueDB or not MonologueCharDB then return end
    self:ShowTab("settings")
end

function UI:ShowTab(key)
    if not MonologueDB or not MonologueCharDB then return end
    self:CreatePanel()
    self:CreateLinesPanel()
    self:CreateVoicePanel()
    self:CreateAbilitiesPanel()
    local to = self:GetTabFrame(key)
    local from = self:GetShownTab()
    if from and from ~= to then
        local point, _, relPoint, x, y = from:GetPoint(1)
        if point then
            to:ClearAllPoints()
            to:SetPoint(point, UIParent, relPoint, x, y)
        end
    end
    for _, tab in ipairs(TAB_ORDER) do
        local frame = self:GetTabFrame(tab.key)
        if frame and frame ~= to then frame:Hide() end
    end
    to:Show()
    to:Raise()
end

function UI:AddTabs(frame, active)
    local previous
    for i = #TAB_ORDER, 1, -1 do
        local tab = TAB_ORDER[i]
        local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        button:SetSize(tab.width, 22)
        if previous then
            button:SetPoint("RIGHT", previous, "LEFT", -3, 0)
        else
            button:SetPoint("TOPRIGHT", -36, -18)
        end
        button:SetText(tab.text)
        button:SetScript("OnClick", function() UI:ShowTab(tab.key) end)
        -- The current tab is shown pressed and can't be clicked
        if tab.key == active then button:Disable() end
        previous = button
    end
    -- Alpha testing: one click to a copyable bug report
    local bug = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    bug:SetSize(72, 22)
    bug:SetPoint("RIGHT", previous, "LEFT", -10, 0)
    bug:SetText("Report Bug")
    bug:SetScript("OnClick", function() UI:ShowBugReport() end)
    bug:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:AddLine("Monologue " .. tostring(MonologueEngine.VERSION), 1, 1, 1)
        GameTooltip:AddLine("Make a bug report to copy into Discord (/mono bug).", nil, nil, nil, true)
        GameTooltip:Show()
    end)
    bug:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function UI:OpenVoice()
    self:ShowTab("voice")
end

function UI:OpenLines()
    self:ShowTab("lines")
end

---------------------------------------------------------------------------
-- Shared panel shell and slider widget
---------------------------------------------------------------------------

-- A movable dialog panel with the title, close button and tab row
local function CreateTabPanel(name, activeTab)
    local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    f:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    SolidBackground(f)
    tinsert(UISpecialFrames, name)

    local title = CreateLabel(f, "Monologue", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", LEFT, -20)
    local closeX = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeX:SetPoint("TOPRIGHT", -6, -6)
    UI:AddTabs(f, activeTab)
    return f
end

-- Horizontal slider with a title above it, the current value to its right and the range
-- under its ends. format(value) returns the value text. setter runs only on user drags.
local function CreateSlider(parent, title, width, minValue, maxValue, step, getter, setter, format, lowText, highText)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(width + 140, 46)

    local titleText = CreateLabel(holder, title, "GameFontHighlight")
    titleText:SetPoint("TOPLEFT", 0, 0)

    local slider = CreateFrame("Slider", nil, holder, "BackdropTemplate")
    slider:SetOrientation("HORIZONTAL")
    slider:SetSize(width, 17)
    slider:SetPoint("TOPLEFT", 4, -18)
    slider:SetHitRectInsets(0, 0, -8, -8)
    slider:SetBackdrop({
        bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 3, right = 3, top = 6, bottom = 6 },
    })
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
    slider:EnableMouseWheel(true)

    local valueText = CreateLabel(holder, "", "GameFontNormal")
    valueText:SetPoint("LEFT", slider, "RIGHT", 12, 0)

    local low = CreateLabel(holder, lowText or "", "GameFontDisableSmall")
    low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -1)
    local high = CreateLabel(holder, highText or "", "GameFontDisableSmall")
    high:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -1)

    local function Snap(value)
        value = math.floor((value - minValue) / step + 0.5) * step + minValue
        return math.max(minValue, math.min(maxValue, value))
    end

    slider:SetScript("OnValueChanged", function(self, value)
        value = Snap(value)
        valueText:SetText(format(value))
        if not holder.updating then setter(value) end
    end)
    slider:SetScript("OnMouseWheel", function(self, delta)
        self:SetValue(Snap(self:GetValue() + delta * step))
    end)

    holder.Refresh = function()
        holder.updating = true
        local value = Snap(tonumber(getter()) or minValue)
        slider:SetValue(value)
        valueText:SetText(format(value))
        holder.updating = false
    end
    holder.slider = slider
    return holder
end

local function FormatDuration(seconds)
    seconds = math.floor(seconds + 0.5)
    local minutes, rest = math.floor(seconds / 60), seconds % 60
    if minutes == 0 then return rest .. " sec" end
    if rest == 0 then return minutes .. (minutes == 1 and " minute" or " minutes") end
    return minutes .. " min " .. rest .. " sec"
end

---------------------------------------------------------------------------
-- Voice Lines tab: where and how often lines are said in /s (MonologueDB, all characters)
---------------------------------------------------------------------------

function UI:CreateLinesPanel()
    if self.LinesFrame then return end
    local l = {}
    self.Lines = l
    local f = CreateTabPanel("MonologueLinesFrame", "lines")
    local width = PANEL_WIDTH - LEFT * 2

    local function Hint(text, y)
        local label = CreateLabel(f, "|cff888888" .. text .. "|r", "GameFontHighlightSmall")
        label:SetPoint("TOPLEFT", LEFT, y)
        label:SetWidth(width)
        label:SetWordWrap(true)
        return label
    end

    local function Box(key, text, x, y, onClick)
        local cb = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
        cb:SetSize(26, 26)
        cb:SetPoint("TOPLEFT", x, y)
        local label = cb.Text or cb.text
        if not label then
            label = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            label:SetPoint("LEFT", cb, "RIGHT", 2, 0)
        end
        label:SetFontObject("GameFontHighlight")
        label:SetText(text)
        cb:SetScript("OnClick", onClick or function(self)
            MonologueDB.pressVoice[key] = self:GetChecked() and true or false
            UI:RefreshLines()
        end)
        cb.key = key
        return cb
    end

    -- Where
    CreateSectionHeader(f, "Where to Speak in /s", -52)
    Hint("When you use an ability, your character now and then says a line in /s. The spell you use picks the line.", -70)
    l.master = Box("enabled", "Speak in /s when I use abilities", LEFT - 4, -96)
    l.places = {
        Box("world", "Open world (mobs)", LEFT + 16, -124),
        Box("worldpvp", "World PvP (players)", LEFT + 216, -124),
        Box("dungeon", "Dungeons", LEFT + 16, -150),
        Box("raid", "Raids", LEFT + 216, -150),
        Box("battleground", "Battlegrounds", LEFT + 16, -176),
        Box("boss", "Boss fights", LEFT + 216, -176),
    }

    -- How often
    CreateSectionHeader(f, "How Often", -214)
    l.pullSlider = CreateSlider(f, "Against mobs, say a line about every...", 230, 1, 10, 1,
        function() return MonologueDB.pullEvery end,
        function(value)
            MonologueDB.pullEvery = value
            MonologueEngine:EnsurePullTarget()
            UI:RefreshLines(true)
        end,
        function(value) return value == 1 and "every pull" or (value .. " pulls") end,
        "every pull", "10 pulls")
    l.pullSlider:SetPoint("TOPLEFT", LEFT, -232)

    l.gapSlider = CreateSlider(f, "Wait at least this long between lines...", 230, 30, 600, 30,
        function() return MonologueDB.pressVoice.gap end,
        function(value)
            MonologueDB.pressVoice.gap = value
            UI:RefreshLines(true)
        end,
        FormatDuration, "30 sec", "10 min")
    l.gapSlider:SetPoint("TOPLEFT", LEFT, -286)

    l.chatSlider = CreateSlider(f, "Chance of other reactions (spells, greetings, duels, PvP)", 230, 0, 2, 0.25,
        function() return MonologueDB.chattiness end,
        function(value)
            MonologueDB.chattiness = value
            UI:RefreshLines(true)
        end,
        function(value)
            if value == 0 then return "off" end
            return string.format("%d%%", value * 100)
        end,
        "off", "double")
    l.chatSlider:SetPoint("TOPLEFT", LEFT, -340)

    l.sitSlider = CreateSlider(f, "React to the world (undead, rares, low mana, revenge...)", 230, 0, 100, 10,
        function() return MonologueDB.situationChance end,
        function(value)
            MonologueDB.situationChance = value
            UI:RefreshLines(true)
        end,
        function(value)
            if value == 0 then return "off" end
            return string.format("%d%% of lines", value)
        end,
        "off", "always")
    l.sitSlider:SetPoint("TOPLEFT", LEFT, -394)

    -- Battle Cry button
    CreateSectionHeader(f, "Buttons & Replies", -450)
    l.cry = Box(nil, "Battle Cry button", LEFT - 4, -466, function(self)
        UI:SetCryButtonShown(self:GetChecked())
    end)
    l.greet = Box(nil, "Greet button", LEFT + 216, -466, function(self)
        UI:SetGreetButtonShown(self:GetChecked())
    end)
    l.taunt = Box(nil, "Taunt button", LEFT + 376, -466, function(self)
        UI:SetTauntButtonShown(self:GetChecked())
    end)
    l.emotes = Box(nil, "Reply when players emote at me (/wave, /bow, /cheer...)", LEFT - 4, -490, function(self)
        MonologueDB.emoteReplies = self:GetChecked() and true or false
    end)
    l.moments = Box(nil, "Everyday moments (meals, travel, gathering, pets, mishaps, NPC visits)", LEFT - 4, -514, function(self)
        MonologueDB.momentLines = self:GetChecked() and true or false
    end)
    l.moments:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Everyday moments", 1, 0.82, 0)
        GameTooltip:AddLine("Now and then a short line when you eat or drink, mount up, walk into an inn or city, "
            .. "visit a flight master, trainer, merchant or mailbox, open a profession window, hand in a quest, "
            .. "mine, pick herbs, skin or fish, fill your bags, run out of air, take a long fall, summon or lose "
            .. "your pet, or see a party member fall.", 1, 1, 1, true)
        GameTooltip:AddLine("Add your own lines for any of them on the Abilities tab.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    l.moments:SetScript("OnLeave", function() GameTooltip:Hide() end)
    l.bubble = Box(nil, "Show the waiting line", LEFT - 4, -538, function(self)
        MonologueDB.queueBubble = self:GetChecked() and true or false
    end)
    l.yells = Box(nil, "Answer NPCs who yell", LEFT + 216, -538, function(self)
        MonologueDB.npcYells = self:GetChecked() and true or false
    end)
    l.banter = Box(nil, "Talk with other Monologue users (banter, greetings back, thanks)", LEFT - 4, -562, function(self)
        MonologueDB.partyBanter = self:GetChecked() and true or false
    end)
    l.banter:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Talk with other Monologue users", 1, 0.82, 0)
        GameTooltip:AddLine("When a party member who also runs Monologue says a line (a kill, a meal, the inn, mounting up, loot, a level-up), "
            .. "one of you may answer, and they may have the last word. Friends, and races you've set a cool stance toward, get their own answers.", 1, 1, 1, true)
        GameTooltip:AddLine("Also: greeting back when one greets you (party or guild), answering a thank-you after you raise someone, "
            .. "and duel talk. You won't greet the same group member over and over.", 1, 1, 1, true)
        GameTooltip:AddLine("Off: you neither answer nor get answered.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    l.banter:SetScript("OnLeave", function() GameTooltip:Hide() end)
    Hint("Battle Cry shouts, Greet says hello (it glows when a line is waiting), Taunt jeers at an enemy "
        .. "player. Right-drag to move. Rather not have buttons? Key Bindings > AddOns > Monologue, or "
        .. "/mono cry, /mono greet, /mono taunt in a macro.", -590)

    -- Live status
    CreateSectionHeader(f, "Right Now", -622)
    l.status = CreateLabel(f, "", "GameFontHighlightSmall")
    l.status:SetPoint("TOPLEFT", LEFT, -640)
    l.status:SetWidth(width - 110)
    l.status:SetWordWrap(true)
    l.status:SetJustifyV("TOP")

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetSize(100, 25)
    closeBtn:SetPoint("BOTTOMRIGHT", -20, 20)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    f:SetScript("OnShow", function() UI:RefreshLines() end)
    f:Hide()
    self.LinesFrame = f
end

-- skipSliders: true while a slider is being dragged (don't fight the user's drag)
function UI:RefreshLines(skipSliders)
    local l = self.Lines
    if not l or not self.LinesFrame or not self.LinesFrame:IsShown() or not MonologueDB then return end
    local engine = MonologueEngine
    local settings = MonologueDB.pressVoice

    l.master:SetChecked(settings.enabled and true or false)
    for _, cb in ipairs(l.places) do
        cb:SetChecked(settings[cb.key] and true or false)
        cb:SetEnabled(settings.enabled and true or false)
    end
    l.cry:SetChecked(MonologueDB.buttonShown and true or false)
    l.greet:SetChecked(MonologueDB.greetButtonShown and true or false)
    l.taunt:SetChecked(MonologueDB.tauntButtonShown and true or false)
    l.emotes:SetChecked(MonologueDB.emoteReplies and true or false)
    l.moments:SetChecked(MonologueDB.momentLines ~= false)
    l.bubble:SetChecked(MonologueDB.queueBubble ~= false)
    l.yells:SetChecked(MonologueDB.npcYells ~= false)
    l.banter:SetChecked(MonologueDB.partyBanter ~= false)
    if not skipSliders then
        l.pullSlider.Refresh()
        l.gapSlider.Refresh()
        l.chatSlider.Refresh()
        l.sitSlider.Refresh()
    end

    local ok, info = engine:PressVoiceAllowed()
    local lines = {}
    if ok then
        lines[#lines + 1] = "|cff00ff00On|r here (" .. engine:DescribePressPlace(info) .. ")."
        local state = engine.State
        local wait = (settings.gap or 120) - (GetTime() - (state.LastPressLineAt or -math.huge))
        if wait > 0 then
            lines[#lines + 1] = "Next line possible in " .. FormatDuration(wait) .. "."
        end
    else
        lines[#lines + 1] = "|cffff8800Off|r here: " .. info .. "."
    end
    lines[#lines + 1] = "Mobs: " .. engine:DescribePullProgress() .. "."
    if engine.DescribeSituations then
        local unit = UnitExists("target") and "target" or nil
        lines[#lines + 1] = "Could react to: " .. engine:DescribeSituations(unit) .. "."
    end
    local blocked = {}
    for place, isBlocked in pairs(MonologueDB.pressVoiceBlocked or {}) do
        if isBlocked then blocked[#blocked + 1] = engine:DescribePressPlace(place) end
    end
    table.sort(blocked)
    if #blocked > 0 then
        lines[#lines + 1] = "|cffff8800The game blocked /s in: " .. table.concat(blocked, ", ")
            .. ".|r Type /mono castchat retry to try again."
    end
    if settings.boss then
        lines[#lines + 1] = "|cff888888Boss fights: the game may still block chat during some encounters.|r"
    end
    l.status:SetText(table.concat(lines, "\n"))
end

---------------------------------------------------------------------------
-- My Voice tab (MonologueCharDB.CustomVoice, via MonologueEngine:CustomVoice* helpers)
---------------------------------------------------------------------------

StaticPopupDialogs["MONOLOGUE_RESET_VOICE"] = {
    text = "Reset ALL My Voice customizations for this character? Oaths, swaps, battle cries, persona and guild greeting will be cleared.",
    button1 = YES,
    button2 = NO,
    OnAccept = function() MonologueEngine:ResetCustomVoice() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local VOICE_CONTENT_WIDTH = PANEL_WIDTH - 70
local VOICE_FOLLOW_ARC = ""

local function CreateInput(parent, width, maxLetters)
    local edit = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    edit:SetSize(width, 24)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(maxLetters or 120)
    edit:SetScript("OnEscapePressed", edit.ClearFocus)
    return edit
end

local function CreateButton(parent, text, width, onClick)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(width, 22)
    b:SetText(text)
    b:SetScript("OnClick", onClick)
    return b
end

local function VoicePersonaOptions()
    local options = { { value = VOICE_FOLLOW_ARC, text = "Follow Growth Arc" } }
    for _, key in ipairs(MonologueEngine:GetPersonaKeys()) do
        options[#options + 1] = { value = key, text = MonologueEngine:GetPersonaDisplayName(key) }
    end
    return options
end

local RACE_LABELS = { NightElf = "Night Elf", Scourge = "Undead" }
local function RaceLabel(key) return RACE_LABELS[key] or key end

local STANCE_OPTIONS = {
    { value = "DEFAULT", text = "Default" },
    { value = "WARM", text = "Warm / Respectful" },
    { value = "ADMIRING", text = "Admiring" },
    { value = "PLAYFUL", text = "Playful / Teasing" },
    { value = "WARY", text = "Wary / Distrustful" },
    { value = "GRUFF", text = "Gruff / Rivalry" },
    { value = "DISDAINFUL", text = "Disdainful / Haughty" },
}
local function StanceLabel(value)
    for _, option in ipairs(STANCE_OPTIONS) do
        if option.value == value then return option.text end
    end
    return tostring(value)
end

local function SortedKeys(t)
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end
    table.sort(keys)
    return keys
end

function UI:CreateVoicePanel()
    if self.VoiceFrame then return end
    local v = { rows = {}, headers = {} }
    self.Voice = v

    local f = CreateFrame("Frame", "MonologueVoiceFrame", UIParent, "BackdropTemplate")
    f:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    SolidBackground(f)
    tinsert(UISpecialFrames, "MonologueVoiceFrame")

    local title = CreateLabel(f, "Monologue", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", LEFT, -20)
    local closeX = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeX:SetPoint("TOPRIGHT", -6, -6)
    self:AddTabs(f, "voice")

    local scroll = CreateFrame("ScrollFrame", "MonologueVoiceScroll", f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 18, -52)
    scroll:SetPoint("BOTTOMRIGHT", -36, 20)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(VOICE_CONTENT_WIDTH, 900)
    scroll:SetScrollChild(content)
    v.content = content

    local function Header(text)
        local label = CreateLabel(content, text, "GameFontNormal")
        local rule = content:CreateTexture(nil, "ARTWORK")
        rule:SetColorTexture(1, 0.82, 0, 0.25)
        rule:SetHeight(1)
        rule:SetPoint("LEFT", label, "RIGHT", 8, 0)
        rule:SetPoint("RIGHT", content, "RIGHT", -4, 0)
        v.headers[#v.headers + 1] = label
        return label
    end

    local function Note(text)
        local label = CreateLabel(content, text, "GameFontHighlightSmall")
        label:SetWidth(VOICE_CONTENT_WIDTH - 8)
        label:SetWordWrap(true)
        label:SetJustifyV("TOP")
        return label
    end

    local function Say(text) MonologueEngine.Print(text) end
    local function Report(ok, message)
        if not ok and message then Say("|cffff8800" .. message .. "|r") end
        return ok
    end

    -- Welcome / identity
    v.hWelcome = Header("Identity & Persona")
    v.info = Note("")
    v.personaLabel = CreateLabel(content, "Persona preset:")
    v.persona = CreateDropdown(content, 200, VoicePersonaOptions,
        function()
            local cv = MonologueEngine:GetCustomVoice()
            return cv and cv.persona or VOICE_FOLLOW_ARC
        end,
        function(value) MonologueEngine:CustomVoiceSetPersona(value) end)
    v.tempLabel = CreateLabel(content, "Racial Temperament:")
    v.temper = CreateDropdown(content, 200,
        function()
            local options = {}
            for _, option in ipairs(MonologueEngine:GetRacePresetOptions()) do
                options[#options + 1] = { value = option.key, text = option.name }
            end
            return options
        end,
        function()
            -- A preset key that isn't one of this race's presets reads as Default
            local cv = MonologueEngine:GetCustomVoice()
            local key = cv and cv.racePreset
            for _, option in ipairs(MonologueEngine:GetRacePresetOptions()) do
                if option.key == key then return key end
            end
            return "Default"
        end,
        function(value) MonologueEngine:CustomVoiceSetRacePreset(value) end)
    v.tempBlurb = Note("")
    v.reset = CreateButton(content, "Reset Customizations", 130, function()
        StaticPopup_Show("MONOLOGUE_RESET_VOICE")
    end)
    v.starter = CreateButton(content, "Fill Starter Examples", 150, function()
        local added = MonologueEngine:FillStarterExamples()
        MonologueEngine.Print(added > 0
            and ("Added " .. added .. " starter example(s). Edit or remove them below.")
            or "Starter examples are already in your lists.")
    end)
    v.previewVoice = CreateButton(content, "Preview My Voice", 110, function() UI:PreviewVoice() end)

    -- Azeroth Identity: clan, hometown, allegiance, profession
    local engine = MonologueEngine
    local function SetIdentity(field, value) Report(engine:CustomVoiceSetIdentity(field, value)) end
    local function CurrentCV() return engine:GetCustomVoice() or {} end
    v.hIdentity = Header("Azeroth Identity")
    v.identityHint = Note("|cff888888Who your character is in the world. Clan and allegiance lines join your pull lines and greetings now and then; your hometown gets a line when you come home (or far from it); your trade mutters out of combat, in cities, at the repair vendor. Tokens: {clan} {hometown} {allegiance} {profession}.|r")

    v.clanLabel = CreateLabel(content, "Clan / Lineage:")
    v.clanDD = CreateDropdown(content, 200,
        function()
            local options = { { value = "", text = "None" } }
            for _, option in ipairs(engine:GetClanOptions()) do
                options[#options + 1] = { value = option.key, text = option.name }
            end
            return options
        end,
        function() return CurrentCV().clan or "" end,
        function(value) SetIdentity("clan", value) end)
    v.clanNameLabel = CreateLabel(content, "|cff888888Custom name:|r", "GameFontHighlightSmall")
    v.clanNameInput = CreateInput(content, 150, 40)
    v.clanNameSet = CreateButton(content, "Set", 40, function() SetIdentity("clanName", v.clanNameInput:GetText()) end)
    v.clanNameInput:SetScript("OnEnterPressed", function(self) SetIdentity("clanName", self:GetText()); self:ClearFocus() end)

    v.homeLabel = CreateLabel(content, "Hometown / Origin:")
    v.homeDD = CreateGroupedDropdown(content, 200,
        function()
            local groups = { { value = "", text = "None" } }
            for _, group in ipairs(engine.Data.Hometowns or {}) do
                local options = {}
                for _, option in ipairs(group.list or {}) do
                    options[#options + 1] = { value = option.name, text = option.name .. (option.fallen and " |cff888888(fallen)|r" or "") }
                end
                groups[#groups + 1] = { text = group.region, options = options }
            end
            return groups
        end,
        function() return CurrentCV().hometown or "" end,
        function(value) SetIdentity("hometown", value) end)
    v.homeInputLabel = CreateLabel(content, "|cff888888Or type one:|r", "GameFontHighlightSmall")
    v.homeInput = CreateInput(content, 150, 40)
    v.homeSet = CreateButton(content, "Set", 40, function() SetIdentity("hometown", v.homeInput:GetText()) end)
    v.homeInput:SetScript("OnEnterPressed", function(self) SetIdentity("hometown", self:GetText()); self:ClearFocus() end)

    v.allegianceLabel = CreateLabel(content, "Allegiance / Order:")
    v.allegianceDD = CreateDropdown(content, 200,
        function()
            local options = {}
            for _, key in ipairs(engine.Data.AllegianceOrder or {}) do
                local data = engine.Data.Allegiances[key]
                if data then options[#options + 1] = { value = key, text = data.name } end
            end
            return options
        end,
        function() return CurrentCV().allegiance or "Independent" end,
        function(value) SetIdentity("allegiance", value ~= "Independent" and value or nil) end)

    v.professionLabel = CreateLabel(content, "Profession / Trade:")
    v.professionDD = CreateDropdown(content, 200,
        function()
            local options = { { value = "", text = "Auto-Detect" } }
            for _, key in ipairs(engine.Data.ProfessionOrder or {}) do
                local data = engine.Data.Professions[key]
                if data then options[#options + 1] = { value = key, text = data.name } end
            end
            return options
        end,
        function() return CurrentCV().profession or "" end,
        function(value) SetIdentity("profession", value) end)
    v.professionNote = Note("")

    -- Character Builder: upbringing, defining trait, dialect strength
    local function OrderedOptions(order, data, noneText)
        local options = { { value = "", text = noneText } }
        for _, key in ipairs(order or {}) do
            local entry = data and data[key]
            if entry then options[#options + 1] = { value = key, text = entry.name } end
        end
        return options
    end
    v.upbringingLabel = CreateLabel(content, "Upbringing:")
    v.upbringingDD = CreateDropdown(content, 230,
        function() return OrderedOptions(engine.Data.UpbringingOrder, engine.Data.Upbringings, "None") end,
        function() return CurrentCV().upbringing or "" end,
        function(value) SetIdentity("upbringing", value) end)
    v.traitLabel = CreateLabel(content, "Defining Trait:")
    v.traitDD = CreateDropdown(content, 230,
        function() return OrderedOptions(engine.Data.TraitOrder, engine.Data.Traits, "None") end,
        function() return CurrentCV().trait or "" end,
        function(value) SetIdentity("trait", value) end)
    v.trait2Label = CreateLabel(content, "Secondary Trait:")
    v.trait2DD = CreateDropdown(content, 230,
        function() return OrderedOptions(engine.Data.TraitOrder, engine.Data.Traits, "None") end,
        function() return CurrentCV().trait2 or "" end,
        function(value) SetIdentity("trait2", value) end)
    v.builderNote = Note("")

    -- Character Anchors: free text, used as {oath} {nemesis} {catchphrase} and in their own lines
    v.anchors = {}
    for _, spec in ipairs({
        { field = "oath", label = "Oath:", hint = "finish \"I swore ...\" e.g. to see Gnomeregan free" },
        { field = "nemesis", label = "Nemesis:", hint = "a name, e.g. Mor'Ladim or the Defias" },
        { field = "catchphrase", label = "Catchphrase:", hint = "a full sentence you always say" },
    }) do
        local anchor = { field = spec.field }
        anchor.label = CreateLabel(content, spec.label)
        anchor.input = CreateInput(content, 190, 80)
        anchor.set = CreateButton(content, "Set", 40, function() SetIdentity(spec.field, anchor.input:GetText()) end)
        anchor.input:SetScript("OnEnterPressed", function(self) SetIdentity(spec.field, self:GetText()); self:ClearFocus() end)
        anchor.hint = Note("|cff888888" .. spec.hint .. "|r")
        v.anchors[#v.anchors + 1] = anchor
    end
    v.strengthLabel = CreateLabel(content, "Dialect Strength:")
    v.strengthDD = CreateDropdown(content, 230, {
            { value = "FULL", text = "Full Dialect" },
            { value = "LIGHT", text = "Light Flavor" },
            { value = "CLEAN", text = "Clean" },
        },
        function() return CurrentCV().dialectStrength or "FULL" end,
        function(value) SetIdentity("dialectStrength", value) end)
    v.strengthNote = Note("")
    v.moodLabel = CreateLabel(content, "Mood today:")
    v.moodDD = CreateDropdown(content, 230, {
            { value = "NORMAL", text = "Normal" },
            { value = "Grim", text = "Grim" },
            { value = "Weary", text = "Weary" },
            { value = "Cheerful", text = "Cheerful" },
            { value = "Fierce", text = "Fierce" },
        },
        function() return MonologueEngine:GetMood() or "NORMAL" end,
        function(value) MonologueEngine:SetMood(value ~= "NORMAL" and value or nil) end)
    v.moodNote = Note("|cff888888How your character feels today (also /mono mood). Some greetings, idle, kill and "
        .. "low-health lines take on the mood; Weary and Grim speak a little less, Cheerful a little more.|r")

    -- Cross-race stances
    v.hStance = Header("Cross-Race Stances")
    v.stanceHint = Note("|cff888888How you greet friendly players of each race: from warm or admiring, through playful or wary, to gruff or disdainful. A friend note like Duo still wins. Pick a race and a stance, then Add / Set.|r")
    v.stanceRace, v.stanceValue = nil, "DEFAULT"
    v.stanceRaceDD = CreateDropdown(content, 130,
        function()
            local options = {}
            for _, key in ipairs(MonologueEngine:GetStanceRaceKeys()) do
                options[#options + 1] = { value = key, text = RaceLabel(key) }
            end
            return options
        end,
        function() return v.stanceRace end,
        function(value)
            v.stanceRace = value
            local cv = MonologueEngine:GetCustomVoice()
            v.stanceValue = cv and cv.raceStances[value] or "DEFAULT"
            C_Timer.After(0, function() v.stanceDD:GenerateMenu() end)
        end)
    v.stanceRaceDD:SetDefaultText("Target race")
    v.stanceDD = CreateDropdown(content, 175, STANCE_OPTIONS,
        function() return v.stanceValue end,
        function(value) v.stanceValue = value end)
    v.setStance = CreateButton(content, "Add / Set", 70, function()
        if not v.stanceRace then Report(false, "Pick a target race first."); return end
        MonologueEngine:CustomVoiceSetStance(v.stanceRace, v.stanceValue)
    end)

    -- Enemy Faction: taunts and race nicknames (stored on the custom voice, per character)
    v.hEnemy = Header("Enemy Faction")
    v.enemyHint = Note("|cff888888How you talk about the other faction. Taunts are said when you target an enemy player you have no grudge with yet, and now and then as you open a fight. The other faction sees /say as gibberish; your own side hears every word.|r")
    v.tauntLabel = CreateLabel(content, "Taunts:")
    v.tauntDD = CreateDropdown(content, 230, {
            { value = "OFF", text = "Off" },
            { value = "CIVIL", text = "Civil (an honest rivalry)" },
            { value = "ROUGH", text = "Rough (trash talk)" },
            { value = "SAVAGE", text = "Savage (race nicknames)" },
        },
        function() return CurrentCV().taunts or "OFF" end,
        function(value) SetIdentity("taunts", value) end)
    v.nickLabel = CreateLabel(content, "Race nicknames:")
    v.nickDD = CreateDropdown(content, 230, {
            { value = "OFF", text = "Off" },
            { value = "ENEMY", text = "The other faction's races" },
            { value = "ALL", text = "Every race" },
        },
        function() return CurrentCV().nicknames or "OFF" end,
        function(value) SetIdentity("nicknames", value) end)
    v.nickNote = Note("")

    -- Oaths
    v.hLines = Header("My Oaths")
    v.lineHint = Note("|cff888888Short exclamations said now and then before a greeting, a kill line, a low-health line or a battle cry. Added to your race's own. Example: By my blade!|r")
    v.lineInput = CreateInput(content, 250)
    local function AddLine(listKey)
        local text = v.lineInput:GetText()
        if Report(MonologueEngine:CustomVoiceAddLine(listKey, text)) then v.lineInput:SetText("") end
    end
    v.addOpener = CreateButton(content, "Add Oath", 80, function() AddLine("oaths") end)
    v.lineInput:SetScript("OnEnterPressed", function() AddLine("oaths") end)

    -- Words Never Translated (MonologueDB.keepWords, all characters)
    v.hKeep = Header("Words Never Translated")
    v.keepHint = Note("|cff888888Names and words the accent never touches, in any letter case (all your characters). Names with a capital letter mid-sentence are already kept. Example: battlehammer|r")
    v.keepInput = CreateInput(content, 250, 40)
    local function AddKeep()
        if Report(MonologueEngine:AddKeepWord(v.keepInput:GetText())) then v.keepInput:SetText("") end
    end
    v.addKeep = CreateButton(content, "Add Word", 80, AddKeep)
    v.keepInput:SetScript("OnEnterPressed", AddKeep)

    -- Swaps
    v.hSwaps = Header("Custom Word & Phrase Swaps")
    v.swapHint = Note("|cff888888Word swaps replace one word; phrase swaps replace a whole expression. Separate variants with commas: friend -> pal, mate, comrade.|r")
    v.fromLabel = CreateLabel(content, "From:")
    v.fromInput = CreateInput(content, 120, 40)
    v.toLabel = CreateLabel(content, "To (comma-separated variants):")
    v.toInput = CreateInput(content, 250)
    local function AddSwap(swapKey)
        local ok = Report(MonologueEngine:CustomVoiceAddSwap(swapKey, v.fromInput:GetText(), v.toInput:GetText()))
        if ok then v.fromInput:SetText(""); v.toInput:SetText("") end
    end
    v.addWord = CreateButton(content, "Add Word Swap", 110, function() AddSwap("wordSwaps") end)
    v.addPhrase = CreateButton(content, "Add Phrase Swap", 120, function() AddSwap("phraseSwaps") end)

    -- Battle cries
    v.hCries = Header("Signature Battle Cries")
    v.cryHint = Note("|cff888888Added to your /mono cry pool. Use Preview to see how a line translates, or try lines in the Try Your Accent box on the General tab. Live details work in your lines too: {weapon} {spell} {mob} {party} {myhp} (/mono tokens lists them).|r")
    v.cryInput = CreateInput(content, 280)
    local function AddCry()
        if Report(MonologueEngine:CustomVoiceAddLine("battleCries", v.cryInput:GetText())) then v.cryInput:SetText("") end
    end
    v.addCry = CreateButton(content, "Add Battle Cry", 110, AddCry)
    v.cryInput:SetScript("OnEnterPressed", AddCry)

    -- Guild greeting
    v.hGuild = Header("Guild Greeting")
    v.guildInput = CreateInput(content, 280)
    v.setGuild = CreateButton(content, "Set", 60, function()
        MonologueEngine:CustomVoiceSetGuildGreeting(v.guildInput:GetText())
    end)
    v.guildInput:SetScript("OnEnterPressed", function() MonologueEngine:CustomVoiceSetGuildGreeting(v.guildInput:GetText()) end)
    v.guildHint = Note("|cff888888Said when you target a guildmate. Use {target} for their name. Leave empty and press Set to clear.|r")

    -- Export / import
    v.hShare = Header("Export / Import")
    v.shareInput = CreateInput(content, VOICE_CONTENT_WIDTH - 16, 0)  -- 0 = no length limit
    v.exportBtn = CreateButton(content, "Export", 90, function()
        v.shareInput:SetText(MonologueEngine:ExportCustomVoice())
        v.shareInput:SetFocus()
        v.shareInput:HighlightText()
        Say("Voice string ready: press Ctrl+C to copy it.")
    end)
    v.importBtn = CreateButton(content, "Import", 90, function()
        local ok, message = MonologueEngine:ImportCustomVoice(v.shareInput:GetText())
        if ok then
            Say("Voice imported. Your previous custom voice was replaced.")
            if message then Say("|cffff8800" .. message .. "|r") end
            v.shareInput:SetText("")
            v.shareInput:ClearFocus()
        else
            Report(false, message)
        end
    end)
    v.shareHint = Note("|cff888888Export copies your voice as a MONO1: string; paste one here and press Import to load it (this replaces your current custom voice).|r")

    f:SetScript("OnShow", function() UI:LayoutVoice() end)
    f:Hide()
    self.VoiceFrame = f
end

local function GetVoiceRow(v, index)
    local row = v.rows[index]
    if row then return row end
    row = CreateFrame("Frame", nil, v.content)
    row:SetSize(VOICE_CONTENT_WIDTH - 8, 20)
    row.text = CreateLabel(row, "", "GameFontHighlightSmall")
    row.text:SetPoint("LEFT", 2, 0)
    row.text:SetWidth(VOICE_CONTENT_WIDTH - 130)
    row.text:SetWordWrap(false)
    row.remove = CreateButton(row, "x", 22, nil)
    row.remove:SetPoint("RIGHT", -2, 0)
    row.preview = CreateButton(row, "Preview", 56, nil)
    row.preview:SetPoint("RIGHT", row.remove, "LEFT", -2, 0)
    v.rows[index] = row
    return row
end

-- Positions every widget top to bottom and fills the list rows from the saved data
function UI:LayoutVoice()
    local v = self.Voice
    if not v or not self.VoiceFrame or not self.VoiceFrame:IsShown() then return end
    local engine = MonologueEngine
    local cv = engine:GetCustomVoice()
    if not cv then return end

    -- Keep dropdown labels in step with the saved data (after import, reset, slash commands)
    if v.stanceRace then v.stanceValue = cv.raceStances[v.stanceRace] or "DEFAULT" end
    for _, dropdown in ipairs({ v.persona, v.temper, v.stanceRaceDD, v.stanceDD,
        v.clanDD, v.homeDD, v.allegianceDD, v.professionDD, v.upbringingDD, v.traitDD, v.trait2DD, v.strengthDD,
        v.tauntDD, v.nickDD }) do
        dropdown:GenerateMenu()
    end

    local content = v.content
    local y = 4
    local used = 0
    for _, row in ipairs(v.rows) do row:Hide() end

    local function at(widget, x, dy)
        widget:ClearAllPoints()
        widget:SetPoint("TOPLEFT", content, "TOPLEFT", x, -(y + (dy or 0)))
    end
    local function after(widget, anchor, x, dy)
        widget:ClearAllPoints()
        widget:SetPoint("LEFT", anchor, "RIGHT", x or 6, dy or 0)
    end
    local function noteAt(label)
        at(label, 4)
        y = y + math.max(14, label:GetStringHeight()) + 6
    end
    local function listRows(entries)
        for _, entry in ipairs(entries) do
            used = used + 1
            local row = GetVoiceRow(v, used)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -y)
            row.text:SetText(entry.text)
            row.remove:SetScript("OnClick", entry.remove)
            if entry.preview then
                row.preview:SetScript("OnClick", entry.preview)
                row.preview:Show()
            else
                row.preview:Hide()
            end
            row:Show()
            y = y + 22
        end
        y = y + 4
    end

    -- Identity
    local ctx = engine.ActiveContext or {}
    local source = {}
    source[#source + 1] = "Profile: " .. (ctx.profile or "none (data packs only)")
    if ctx.subtype then source[#source + 1] = "Subtype: " .. ctx.subtype end
    source[#source + 1] = "Persona in use: " .. (ctx.persona and engine:GetPersonaDisplayName(ctx.persona) or "none")
    v.info:SetText(string.format("|cffffd100Race:|r %s   |cffffd100Class:|r %s\n%s\n|cff888888Your custom voice sits on top of all of this and never edits the packs.|r",
        ctx.race or "no race pack", ctx.class or "no class pack", table.concat(source, "   ")))
    at(v.hWelcome, 0); y = y + 22
    noteAt(v.info)
    at(v.personaLabel, 4, 5); at(v.persona, 130, 0); y = y + 30
    at(v.tempLabel, 4, 5); at(v.temper, 130, 0); y = y + 30
    local options = engine:GetRacePresetOptions()
    local blurb = ""
    for _, option in ipairs(options) do
        if option.key == (cv.racePreset or "Default") and option.blurb then blurb = "|cff888888" .. option.blurb .. "|r" end
    end
    if #options <= 1 then blurb = "|cff888888This race has no temperament presets yet.|r" end
    v.tempBlurb:SetText(blurb)
    noteAt(v.tempBlurb)
    at(v.reset, 4); after(v.starter, v.reset, 4); after(v.previewVoice, v.starter, 4); y = y + 30

    -- Azeroth Identity
    at(v.hIdentity, 0); y = y + 22
    noteAt(v.identityHint)
    local hasClans = #engine:GetClanOptions() > 0
    at(v.clanLabel, 4, 5); at(v.clanDD, 130, 0)
    v.clanDD:SetEnabled(hasClans)
    if not hasClans then v.clanDD:SetDefaultText("No clans for this race") end
    y = y + 28
    at(v.clanNameLabel, 20, 5); at(v.clanNameInput, 130, 0); after(v.clanNameSet, v.clanNameInput, 4)
    if not v.clanNameInput:HasFocus() then v.clanNameInput:SetText(cv.clanName or "") end
    y = y + 28
    at(v.homeLabel, 4, 5); at(v.homeDD, 130, 0); y = y + 28
    at(v.homeInputLabel, 20, 5); at(v.homeInput, 130, 0); after(v.homeSet, v.homeInput, 4)
    if not v.homeInput:HasFocus() then
        local _, homeOption = engine:GetHometown()
        v.homeInput:SetText((cv.hometown and not homeOption) and cv.hometown or "")
    end
    y = y + 28
    at(v.allegianceLabel, 4, 5); at(v.allegianceDD, 130, 0); y = y + 30
    at(v.professionLabel, 4, 5); at(v.professionDD, 130, 0); y = y + 30
    local detected = {}
    for _, key in ipairs(engine:DetectProfessions()) do
        detected[#detected + 1] = engine.Data.Professions[key].name
    end
    v.professionNote:SetText("|cff888888Detected: " .. (#detected > 0 and table.concat(detected, ", ") or "none yet")
        .. (cv.profession and "  (overridden by your choice)" or "") .. "|r")
    noteAt(v.professionNote)

    -- Character Builder
    at(v.upbringingLabel, 4, 5); at(v.upbringingDD, 130, 0); y = y + 30
    at(v.traitLabel, 4, 5); at(v.traitDD, 130, 0); y = y + 30
    at(v.trait2Label, 4, 5); at(v.trait2DD, 130, 0); y = y + 30
    local blurbs = {}
    local upbringing = cv.upbringing and engine.Data.Upbringings[cv.upbringing]
    local trait = cv.trait and engine.Data.Traits[cv.trait]
    if upbringing then blurbs[#blurbs + 1] = upbringing.blurb end
    if trait then blurbs[#blurbs + 1] = trait.blurb end
    local trait2 = cv.trait2 and engine.Data.Traits[cv.trait2]
    if trait2 then blurbs[#blurbs + 1] = trait2.blurb end
    blurbs[#blurbs + 1] = "Both traits color your lines; the primary one sets how you react when a party member who also runs Monologue is in trouble or a big fight is won."
    v.builderNote:SetText("|cff888888" .. table.concat(blurbs, " ") .. "|r")
    noteAt(v.builderNote)
    for _, anchor in ipairs(v.anchors) do
        at(anchor.label, 4, 5); at(anchor.input, 130, 0); after(anchor.set, anchor.input, 4)
        if not anchor.input:HasFocus() then anchor.input:SetText(cv[anchor.field] or "") end
        y = y + 24
        at(anchor.hint, 130); y = y + 16
    end
    y = y + 4
    at(v.strengthLabel, 4, 5); at(v.strengthDD, 130, 0); y = y + 30
    local strength = cv.dialectStrength or "FULL"
    v.strengthNote:SetText("|cff888888" .. ((strength == "LIGHT" and "Light Flavor: key word swaps and the odd oath, no accent respelling.")
        or (strength == "CLEAN" and "Clean: standard spelling. Your clan, allegiance, upbringing and the rest still shape what you say.")
        or "Full Dialect: the accent level from the General tab, with every respelling and swap.") .. "|r")
    noteAt(v.strengthNote)
    at(v.moodLabel, 4, 5); at(v.moodDD, 130, 0); y = y + 30
    noteAt(v.moodNote)

    -- Cross-race stances
    at(v.hStance, 0); y = y + 22
    noteAt(v.stanceHint)
    at(v.stanceRaceDD, 4); after(v.stanceDD, v.stanceRaceDD, 2); after(v.setStance, v.stanceDD, 2)
    y = y + 30
    local stanceEntries = {}
    for _, race in ipairs(SortedKeys(cv.raceStances)) do
        stanceEntries[#stanceEntries + 1] = {
            text = string.format("|cff00ccff%s|r  %s", RaceLabel(race), StanceLabel(cv.raceStances[race])),
            remove = function() engine:CustomVoiceSetStance(race, nil) end,
        }
    end
    listRows(stanceEntries)

    -- Enemy Faction
    at(v.hEnemy, 0); y = y + 22
    noteAt(v.enemyHint)
    at(v.tauntLabel, 4, 5); at(v.tauntDD, 130, 0); y = y + 30
    at(v.nickLabel, 4, 5); at(v.nickDD, 130, 0); y = y + 30
    local nickParts = {}
    local nicknames = engine.Data.Taunts and engine.Data.Taunts.Nicknames or {}
    for _, race in ipairs(SortedKeys(nicknames)) do
        nickParts[#nickParts + 1] = RaceLabel(race) .. ": " .. nicknames[race].many
    end
    v.nickNote:SetText("|cff888888Swaps race names in what you type and say (orcs -> green skins), and Savage taunts use them. "
        .. table.concat(nickParts, ", ") .. ". Try it: /mono test the orcs are coming|r")
    noteAt(v.nickNote)

    -- Oaths
    at(v.hLines, 0); y = y + 22
    noteAt(v.lineHint)
    at(v.lineInput, 10); after(v.addOpener, v.lineInput, 6)
    y = y + 28
    local entries = {}
    for i, text in ipairs(cv.oaths) do
        entries[#entries + 1] = { text = "|cff00ccffOath|r  " .. text, remove = function() engine:CustomVoiceRemoveLine("oaths", i, text) end }
    end
    listRows(entries)

    -- Words Never Translated
    at(v.hKeep, 0); y = y + 22
    noteAt(v.keepHint)
    at(v.keepInput, 10); after(v.addKeep, v.keepInput, 6)
    y = y + 28
    entries = {}
    for _, word in ipairs(type(MonologueDB.keepWords) == "table" and MonologueDB.keepWords or {}) do
        entries[#entries + 1] = { text = "|cff00ccffKeep|r  " .. word, remove = function() engine:RemoveKeepWord(word) end }
    end
    listRows(entries)

    -- Swaps
    at(v.hSwaps, 0); y = y + 22
    noteAt(v.swapHint)
    at(v.fromLabel, 4, 5); at(v.fromInput, 44); y = y + 28
    at(v.toLabel, 4, 5); at(v.toInput, 190); y = y + 28
    at(v.addWord, 4); after(v.addPhrase, v.addWord, 6)
    y = y + 28
    entries = {}
    for _, swapKey in ipairs({ "wordSwaps", "phraseSwaps" }) do
        local tag = swapKey == "wordSwaps" and "Word" or "Phrase"
        for _, from in ipairs(SortedKeys(cv[swapKey])) do
            entries[#entries + 1] = {
                text = string.format("|cff00ccff%s|r  %s -> %s", tag, from, tostring(cv[swapKey][from])),
                remove = function() engine:CustomVoiceRemoveSwap(swapKey, from) end,
            }
        end
    end
    listRows(entries)

    -- Battle cries
    at(v.hCries, 0); y = y + 22
    noteAt(v.cryHint)
    at(v.cryInput, 10); after(v.addCry, v.cryInput, 6)
    y = y + 28
    entries = {}
    for i, text in ipairs(cv.battleCries) do
        entries[#entries + 1] = {
            text = text,
            remove = function() engine:CustomVoiceRemoveLine("battleCries", i, text) end,
            preview = function()
                local translated = MonologueTranslator:Translate(text, MonologueDB.translationIntensity)
                engine.Print("Preview (battle cry): " .. tostring(translated))
            end,
        }
    end
    listRows(entries)

    -- Guild greeting
    at(v.hGuild, 0); y = y + 22
    at(v.guildInput, 10); after(v.setGuild, v.guildInput, 6)
    if not v.guildInput:HasFocus() then v.guildInput:SetText(cv.guildGreeting or "") end
    y = y + 28
    noteAt(v.guildHint)

    -- Export / import
    at(v.hShare, 0); y = y + 22
    at(v.shareInput, 10); y = y + 28
    at(v.exportBtn, 4); after(v.importBtn, v.exportBtn, 6)
    y = y + 28
    noteAt(v.shareHint)

    content:SetHeight(y + 10)
end

-- Prints a sample greeting, a translated line and a battle cry in the chat frame
function UI:PreviewVoice()
    local engine = MonologueEngine
    local profile = engine.ActiveProfile or {}
    local intensity = MonologueDB.translationIntensity or 0
    if intensity <= 0 then intensity = 2 end

    local function Pick(pool)
        if type(pool) == "table" and #pool > 0 then return pool[math.random(#pool)] end
    end
    local function Tidy(line)
        line = line:gsub("{target}", "Friend"):gsub("{targetrace}", "Traveler")
        if MonologueRPBridge and MonologueRPBridge.ProcessTokens then
            local ok, processed = pcall(MonologueRPBridge.ProcessTokens, MonologueRPBridge, line, nil)
            if ok and type(processed) == "string" then line = processed end
        end
        return line
    end

    local greetings = type(profile.FriendGreetings) == "table" and profile.FriendGreetings.Default
    local greeting = Pick(greetings) or Pick(type(profile.GuildGreetings) == "table" and profile.GuildGreetings.Standard)
    engine.Print("|cff00ccffMy Voice preview|r")
    if greeting then
        engine.Print("Greeting: " .. MonologueTranslator:Translate(Tidy(greeting), intensity))
    else
        engine.Print("Greeting: (no greeting pool for this character)")
    end
    engine.Print("Line: " .. MonologueTranslator:Translate("Hello friend, do you want a beer? Thank you, good luck!", intensity))
    local cry = Pick(profile.BattleCry)
    if not cry and type(profile.SpellReactions) == "table" then cry = Pick(profile.SpellReactions.Tier1_MajorCD) end
    if cry then engine.Print("Battle cry: " .. MonologueTranslator:Translate(Tidy(cry), intensity)) end
end

-- Called by the engine whenever the active profile is rebuilt
-- Deferred one frame and coalesced: a rebuild can come from inside a dropdown's click
-- handler, and regenerating that dropdown's menu mid-click is unsafe.
function UI:OnVoiceChanged()
    if self.VoiceRefreshPending then return end
    self.VoiceRefreshPending = true
    C_Timer.After(0, function()
        self.VoiceRefreshPending = false
        if self.VoiceFrame and self.VoiceFrame:IsShown() then
            self:LayoutVoice()
        end
        -- The Settings footer shows the active persona/profile, which a rebuild can change
        if self.Frame and self.Frame:IsShown() then
            self:Refresh()
        end
        self:RefreshLines()
        self:LayoutAbilities()
    end)
end

---------------------------------------------------------------------------
-- Abilities tab: what kind of move each spell is (Ability Mapper), your own lines for any
-- spell or moment, and pacing. Choices and lines are per character; the two switches are
-- for all characters (MonologueDB).
---------------------------------------------------------------------------
local ABILITY_CHOICES = {
    { value = "Attack", text = "Attack" },
    { value = "Burst", text = "Burst (big cooldown)" },
    { value = "Defend", text = "Defend" },
    { value = "Interrupt", text = "Interrupt" },
    { value = "Heal", text = "Heal" },
    { value = "None", text = "Silent" },
}
local EVERY_CHOICES = {
    { value = 1, text = "Every cast" },
    { value = 2, text = "Every 2nd cast" },
    { value = 3, text = "Every 3rd cast" },
    { value = 5, text = "Every 5th cast" },
    { value = 10, text = "Every 10th cast" },
}
local ABILITY_KINDS = { "Attack", "Burst", "Defend", "Interrupt", "Heal" }
local SPELLS_PER_SUBMENU = 25

-- "FlightMaster" -> "Flight Master", "PetSummon_Imp" -> "Pet Summon (Imp)"
local function SpacedName(key)
    local base, family = key:match("^(.-)_(.+)$")
    local text = (base or key):gsub("(%l)(%u)", "%1 %2")
    if family then text = text .. " (" .. family .. ")" end
    return text
end

function UI:AbilityPoolGroups()
    local engine = MonologueEngine
    local groups = {}
    local spells = engine:GetSeenSpells()
    for first = 1, #spells, SPELLS_PER_SUBMENU do
        local options = {}
        local last = math.min(#spells, first + SPELLS_PER_SUBMENU - 1)
        for i = first, last do
            options[#options + 1] = { value = "Spell:" .. spells[i], text = spells[i] }
        end
        local label = "Spells you've cast"
        if #spells > SPELLS_PER_SUBMENU then
            label = label .. " (" .. spells[first]:sub(1, 1):upper() .. "-" .. spells[last]:sub(1, 1):upper() .. ")"
        end
        groups[#groups + 1] = { text = label, options = options }
    end
    local moments = {}
    for _, key in ipairs(engine:GetMomentKeys()) do
        moments[#moments + 1] = { value = "Moment:" .. key, text = SpacedName(key) }
    end
    groups[#groups + 1] = { text = "Everyday moments", options = moments }
    local kinds = {}
    for _, key in ipairs(ABILITY_KINDS) do
        kinds[#kinds + 1] = { value = "Ability:" .. key, text = key .. " (spells of this kind)" }
    end
    groups[#groups + 1] = { text = "Kinds of move", options = kinds }
    return groups
end

local function GetAbilityRow(a, index)
    local row = a.spellRows[index]
    if row then return row end
    local engine = MonologueEngine
    row = CreateFrame("Frame", nil, a.content)
    row:SetSize(VOICE_CONTENT_WIDTH - 8, 26)
    row.label = CreateLabel(row, "", "GameFontHighlightSmall")
    row.label:SetPoint("LEFT", 2, 0)
    row.label:SetWidth(150)
    row.label:SetWordWrap(false)
    row.kind = CreateDropdown(row, 160,
        function()
            local options = { { value = "Auto", text = "Auto: " .. engine:DescribeAbility(row.spell or "") } }
            for _, option in ipairs(ABILITY_CHOICES) do options[#options + 1] = option end
            return options
        end,
        function() return engine:GetAbilityChoice(row.spell or "") end,
        function(value)
            if row.spell then engine:SetAbilityCategory(row.spell, value) end
        end)
    row.kind:SetPoint("LEFT", 156, 0)
    row.every = CreateDropdown(row, 130, EVERY_CHOICES,
        function() return engine:GetAbilityEvery(row.spell or "") end,
        function(value)
            if row.spell then engine:SetAbilityEvery(row.spell, value) end
        end)
    row.every:SetPoint("LEFT", row.kind, "RIGHT", 6, 0)
    a.spellRows[index] = row
    return row
end

local function GetPoolLineRow(a, index)
    local row = a.lineRows[index]
    if row then return row end
    row = CreateFrame("Frame", nil, a.content)
    row:SetSize(VOICE_CONTENT_WIDTH - 8, 20)
    row.text = CreateLabel(row, "", "GameFontHighlightSmall")
    row.text:SetPoint("LEFT", 2, 0)
    row.text:SetWidth(VOICE_CONTENT_WIDTH - 50)
    row.text:SetWordWrap(false)
    row.remove = CreateButton(row, "x", 22, nil)
    row.remove:SetPoint("RIGHT", -2, 0)
    a.lineRows[index] = row
    return row
end

function UI:CreateAbilitiesPanel()
    if self.AbilitiesFrame then return end
    local a = { spellRows = {}, lineRows = {} }
    self.Abilities = a
    local engine = MonologueEngine
    local f = CreateTabPanel("MonologueAbilitiesFrame", "abilities")

    local scroll = CreateFrame("ScrollFrame", "MonologueAbilitiesScroll", f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 18, -52)
    scroll:SetPoint("BOTTOMRIGHT", -36, 20)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(VOICE_CONTENT_WIDTH, 900)
    scroll:SetScrollChild(content)
    a.content = content

    local function Header(text)
        local label = CreateLabel(content, text, "GameFontNormal")
        local rule = content:CreateTexture(nil, "ARTWORK")
        rule:SetColorTexture(1, 0.82, 0, 0.25)
        rule:SetHeight(1)
        rule:SetPoint("LEFT", label, "RIGHT", 8, 0)
        rule:SetPoint("RIGHT", content, "RIGHT", -4, 0)
        return label
    end
    local function Note(text)
        local label = CreateLabel(content, text, "GameFontHighlightSmall")
        label:SetWidth(VOICE_CONTENT_WIDTH - 8)
        label:SetWordWrap(true)
        label:SetJustifyV("TOP")
        return label
    end

    a.hMap = Header("What Kind of Move")
    a.mapHint = Note("|cff888888Every spell you cast shows up here. Spells with their own lines keep them; the rest "
        .. "speak from a shared pool for their kind. Attack can open a fight; Burst, Defend, Interrupt and Heal may "
        .. "also speak mid-fight now and then. Silent mutes a spell, even one with its own lines. The fight limits "
        .. "(two lines a fight, each move once) still apply. Same as /mono map.|r")
    a.auto = CreateCheckbox(content, "Spells without their own lines speak for their kind", 0,
        function() return MonologueDB.abilityAuto ~= false end,
        function(value)
            MonologueDB.abilityAuto = value and true or false
            UI:OnAbilitiesChanged()
        end)
    a.empty = Note("|cff888888No spells yet: cast a few and they appear here.|r")

    a.hPace = Header("Pacing")
    a.quiet = CreateCheckbox(content, "Quiet in dungeons (a quarter as often; silent in raids)", 0,
        function() return MonologueDB.dungeonQuiet == true end,
        function(value) MonologueDB.dungeonQuiet = value and true or false end)

    a.hLines = Header("My Lines for a Spell or Moment")
    a.linesHint = Note("|cff888888Pick a spell, an everyday moment or a kind of move, then add your own lines. "
        .. "They join the lines Monologue already has (a spell with none gets yours alone). Saved for this "
        .. "character and included in Export on My Voice. {target} and {zone} work here.|r")
    a.poolDD = CreateGroupedDropdown(content, 280,
        function() return UI:AbilityPoolGroups() end,
        function() return a.poolKey or "" end,
        function(value)
            a.poolKey = (value ~= "" and value) or nil
            UI:OnAbilitiesChanged()
        end)
    if a.poolDD.SetDefaultText then a.poolDD:SetDefaultText("Pick a spell or moment") end
    a.lineInput = CreateInput(content, 290)
    local function AddPoolLine()
        if not a.poolKey then
            engine.Print("|cffff8800Pick a spell or moment first.|r")
            return
        end
        local ok, message = engine:CustomVoiceAddPoolLine(a.poolKey, a.lineInput:GetText())
        if ok then
            a.lineInput:SetText("")
        elseif message then
            engine.Print("|cffff8800" .. message .. "|r")
        end
        UI:OnAbilitiesChanged()
    end
    a.addLine = CreateButton(content, "Add Line", 80, AddPoolLine)
    a.lineInput:SetScript("OnEnterPressed", AddPoolLine)
    a.noLines = Note("|cff888888None of your own yet for this one.|r")

    f:SetScript("OnShow", function() UI:LayoutAbilities() end)
    f:Hide()
    self.AbilitiesFrame = f
end

function UI:LayoutAbilities()
    local a = self.Abilities
    if not a or not self.AbilitiesFrame or not self.AbilitiesFrame:IsShown() then return end
    if not MonologueDB or not MonologueCharDB then return end
    local engine = MonologueEngine
    local content = a.content
    local y = 4
    local function at(widget, x, dy)
        widget:ClearAllPoints()
        widget:SetPoint("TOPLEFT", content, "TOPLEFT", x, -(y + (dy or 0)))
    end
    local function noteAt(label)
        at(label, 4)
        label:Show()
        y = y + math.max(14, label:GetStringHeight()) + 6
    end

    -- What kind of move
    at(a.hMap, 0); y = y + 22
    noteAt(a.mapHint)
    at(a.auto, 0); a.auto:Refresh(); y = y + 28
    for _, row in ipairs(a.spellRows) do row:Hide() end
    local spells = engine:GetSeenSpells()
    if #spells == 0 then noteAt(a.empty) else a.empty:Hide() end
    for i, name in ipairs(spells) do
        local row = GetAbilityRow(a, i)
        row.spell = name
        row.label:SetText(name)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -y)
        row.kind:GenerateMenu()
        row.every:GenerateMenu()
        row:Show()
        y = y + 28
    end
    y = y + 8

    -- Pacing
    at(a.hPace, 0); y = y + 22
    at(a.quiet, 0); a.quiet:Refresh(); y = y + 34

    -- Your own lines
    at(a.hLines, 0); y = y + 22
    noteAt(a.linesHint)
    at(a.poolDD, 4); a.poolDD:GenerateMenu(); y = y + 30
    at(a.lineInput, 10)
    a.addLine:ClearAllPoints()
    a.addLine:SetPoint("LEFT", a.lineInput, "RIGHT", 6, 0)
    y = y + 28
    for _, row in ipairs(a.lineRows) do row:Hide() end
    a.noLines:Hide()
    if a.poolKey then
        local poolKey = a.poolKey
        local lines = engine:GetPoolLines(poolKey)
        if #lines == 0 then noteAt(a.noLines) end
        for i, text in ipairs(lines) do
            local row = GetPoolLineRow(a, i)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -y)
            row.text:SetText(text)
            row.remove:SetScript("OnClick", function()
                engine:CustomVoiceRemovePoolLine(poolKey, i, text)
                UI:OnAbilitiesChanged()
            end)
            row:Show()
            y = y + 22
        end
    end
    content:SetHeight(y + 20)
end

-- Deferred one frame and coalesced, like OnVoiceChanged
function UI:OnAbilitiesChanged()
    if self.AbilitiesRefreshPending then return end
    self.AbilitiesRefreshPending = true
    C_Timer.After(0, function()
        self.AbilitiesRefreshPending = false
        self:LayoutAbilities()
    end)
end

function UI:OpenAbilities()
    self:ShowTab("abilities")
end

---------------------------------------------------------------------------
-- Battle Cry HUD Button
-- A compact button that runs "/mono cry". Left-click to shout; right-drag to move.
-- Position and visibility are saved in MonologueDB (buttonPos, buttonShown) and
-- /mono button shows or hides it. A button click is a hardware event, so the cry can
-- use SAY/YELL in the open world.
---------------------------------------------------------------------------

local CRY_BUTTON_WIDTH = 104
local CRY_BUTTON_HEIGHT = 26
local CRY_BUTTON_DEFAULT_Y = -180

local function SaveCryButtonPosition(button)
    local point, _, relPoint, x, y = button:GetPoint(1)
    if point then
        MonologueDB.buttonPos = { point = point, relPoint = relPoint, x = x, y = y }
    end
end

local function RestoreCryButtonPosition(button)
    local pos = MonologueDB.buttonPos
    button:ClearAllPoints()
    if type(pos) == "table" and type(pos.point) == "string" and type(pos.relPoint) == "string"
        and type(pos.x) == "number" and type(pos.y) == "number" then
        button:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
    else
        button:SetPoint("CENTER", UIParent, "CENTER", 0, CRY_BUTTON_DEFAULT_Y)
    end
end

local GREET_BUTTON_DEFAULT_Y = -212

-- Greet: says a waiting greeting now, or greets your friendly player target. It glows while a
-- greeting is waiting for your next key press. Opt-in (MonologueDB.greetButtonShown).
function UI:CreateGreetButton()
    if self.GreetButton or not MonologueDB then return end

    local button = CreateFrame("Button", "MonologueGreetButton", UIParent, "UIPanelButtonTemplate")
    button:SetSize(CRY_BUTTON_WIDTH, CRY_BUTTON_HEIGHT)
    button:SetText("Greet")
    button:SetFrameStrata("MEDIUM")
    button:SetClampedToScreen(true)
    button:SetMovable(true)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("RightButton")

    local pos = MonologueDB.greetButtonPos
    if type(pos) == "table" and type(pos.point) == "string" and type(pos.relPoint) == "string"
        and type(pos.x) == "number" and type(pos.y) == "number" then
        button:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
    else
        button:SetPoint("CENTER", UIParent, "CENTER", 0, GREET_BUTTON_DEFAULT_Y)
    end

    button:SetScript("OnClick", function() MonologueEngine:GreetNow() end)
    button:SetScript("OnDragStart", function(self) self:StartMoving() end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relPoint, x, y = self:GetPoint(1)
        if point then MonologueDB.greetButtonPos = { point = point, relPoint = relPoint, x = x, y = y } end
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Greet", 1, 0.82, 0)
        GameTooltip:AddLine("Left-click: say the line that's waiting, or say hello to your target", 1, 1, 1, true)
        GameTooltip:AddLine("Glows when a line is waiting (Greet! or Say it!)", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Right-drag: move", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Glow while a greeting is waiting (checked a few times a second, only while shown)
    local elapsed, glowing = 0, false
    button:SetScript("OnUpdate", function(self, delta)
        elapsed = elapsed + delta
        if elapsed < 0.2 then return end
        elapsed = 0
        local waiting, kind = MonologueEngine:HasPendingLine()
        local state = waiting and (kind == "greeting" and "greet" or "say") or false
        if state ~= glowing then
            glowing = state
            if waiting then
                self:LockHighlight()
                -- "Greet!" for a greeting or emote reply, "Say it!" for a duel or PvP line
                self:SetText(state == "greet" and "|cff00ff00Greet!|r" or "|cff00ff00Say it!|r")
            else
                self:UnlockHighlight()
                self:SetText("Greet")
            end
        end
    end)

    button:SetShown(MonologueDB.greetButtonShown == true)
    self.GreetButton = button
end

local TAUNT_BUTTON_DEFAULT_Y = -244

-- Taunt: taunts your enemy player target (Civil when taunts are Off). Opt-in
-- (MonologueDB.tauntButtonShown).
function UI:CreateTauntButton()
    if self.TauntButton or not MonologueDB then return end

    local button = CreateFrame("Button", "MonologueTauntButton", UIParent, "UIPanelButtonTemplate")
    button:SetSize(CRY_BUTTON_WIDTH, CRY_BUTTON_HEIGHT)
    button:SetText("Taunt")
    button:SetFrameStrata("MEDIUM")
    button:SetClampedToScreen(true)
    button:SetMovable(true)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("RightButton")

    local pos = MonologueDB.tauntButtonPos
    if type(pos) == "table" and type(pos.point) == "string" and type(pos.relPoint) == "string"
        and type(pos.x) == "number" and type(pos.y) == "number" then
        button:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
    else
        button:SetPoint("CENTER", UIParent, "CENTER", 0, TAUNT_BUTTON_DEFAULT_Y)
    end

    button:SetScript("OnClick", function() MonologueEngine:TauntNow() end)
    button:SetScript("OnDragStart", function(self) self:StartMoving() end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relPoint, x, y = self:GetPoint(1)
        if point then MonologueDB.tauntButtonPos = { point = point, relPoint = relPoint, x = x, y = y } end
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Taunt", 1, 0.82, 0)
        GameTooltip:AddLine("Left-click: taunt your enemy player target", 1, 1, 1, true)
        local level = MonologueEngine:GetTauntLevel()
        GameTooltip:AddLine("Level: " .. (level and (level:sub(1, 1) .. level:sub(2):lower()) or "Civil (taunts are Off)")
            .. ". Change it on My Voice > Enemy Faction.", 0.7, 0.7, 0.7, true)
        GameTooltip:AddLine("Right-drag: move", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    button:SetShown(MonologueDB.tauntButtonShown == true)
    self.TauntButton = button
end

function UI:SetTauntButtonShown(show)
    if not MonologueDB then return end
    MonologueDB.tauntButtonShown = show and true or false
    self:CreateTauntButton()
    if self.TauntButton then self.TauntButton:SetShown(MonologueDB.tauntButtonShown) end
    self:RefreshLines()
end

function UI:SetGreetButtonShown(show)
    if not MonologueDB then return end
    MonologueDB.greetButtonShown = show and true or false
    self:CreateGreetButton()
    if self.GreetButton then self.GreetButton:SetShown(MonologueDB.greetButtonShown) end
    self:RefreshLines()
end

function UI:CreateBattleCryButton()
    if self.CryButton or not MonologueDB then return end

    local button = CreateFrame("Button", "MonologueBattleCryButton", UIParent, "UIPanelButtonTemplate")
    button:SetSize(CRY_BUTTON_WIDTH, CRY_BUTTON_HEIGHT)
    button:SetText("Battle Cry")
    button:SetFrameStrata("MEDIUM")
    button:SetClampedToScreen(true)
    button:SetMovable(true)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("RightButton")
    RestoreCryButtonPosition(button)

    button:SetScript("OnClick", function()
        SlashCmdList["MONOLOGUE"]("cry")
    end)
    button:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveCryButtonPosition(self)
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Battle Cry", 1, 0.82, 0)
        GameTooltip:AddLine("Left-click: shout a battle cry", 1, 1, 1)
        GameTooltip:AddLine("Right-drag: move", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("/mono button: show or hide", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    button:SetShown(MonologueDB.buttonShown ~= false)
    self.CryButton = button
end

-- Shows or hides the Battle Cry button (menu checkbox); saved in MonologueDB.buttonShown
function UI:SetCryButtonShown(show)
    if not MonologueDB then return end
    MonologueDB.buttonShown = show and true or false
    self:CreateBattleCryButton()
    if self.CryButton then self.CryButton:SetShown(MonologueDB.buttonShown) end
    self:RefreshLines()
end

function UI:ToggleButton()
    if not MonologueDB then return end
    self:CreateBattleCryButton()
    if not self.CryButton then return end

    local show = not self.CryButton:IsShown()
    MonologueDB.buttonShown = show
    self:RefreshLines()
    self.CryButton:SetShown(show)
    if MonologueEngine and MonologueEngine.Print then
        MonologueEngine.Print("Battle Cry button " .. (show and "shown." or "hidden. Type /mono button to bring it back."))
    end
end

---------------------------------------------------------------------------
-- Portrait Right-Click Menu: "Monologue: Add Friend" / "Monologue: Remove Friend"
-- Uses Blizzard's modern Menu.ModifyMenu API (no legacy UnitPopupMenus edits, which
-- taint the unit popups). Every step is wrapped in pcall so a menu change can never
-- break the right-click menu itself.
---------------------------------------------------------------------------

local FRIEND_MENU_TAGS = {
    "MENU_UNIT_PLAYER",
    "MENU_UNIT_PARTY",
    "MENU_UNIT_RAID_PLAYER",
    "MENU_UNIT_FRIEND",
}

-- Works out which player a menu was opened on. Returns name, realm, raceFile or nil.
local function ResolveMenuSubject(contextData)
    if type(contextData) ~= "table" then return nil end

    local unit = contextData.unit
    if type(unit) == "string" and UnitExists(unit) and UnitIsPlayer(unit) then
        if UnitIsUnit(unit, "player") or not UnitIsFriend("player", unit) then return nil end
        -- Full multi-word name (e.g. "Tara Page") via the engine's name helper
        local name, realm = MonologueEngine.GetFullPlayerName(unit)
        -- Clean() drops 12.x secret values, which can't be stored or compared
        local clean = MonologueEngine.Clean
        local _, raceFile = UnitRace(unit)
        raceFile = clean(raceFile)
        local guid = clean(UnitGUID(unit))
        if not MonologueEngine.IsPlayerGUID(guid) then guid = nil end
        if type(name) ~= "string" then return nil end
        return name, realm, raceFile, guid
    end

    -- Names keep their spaces ("Carl Nage"); only a hyphen separates a realm
    local rawName = contextData.name
    if type(rawName) == "string" and rawName ~= "" then
        local name = (MonologueEngine and MonologueEngine.StripRealm and MonologueEngine.StripRealm(rawName)) or rawName
        if name ~= UnitName("player") then
            local realm = contextData.server
            if (type(realm) ~= "string" or realm == "") and name ~= rawName then
                realm = rawName:match("%-(.+)$")
            end
            return name, realm, nil
        end
    end
    return nil
end

local function AddFriendMenuEntries(_, rootDescription, contextData)
    pcall(function()
        local engine = MonologueEngine
        if not engine or not MonologueCharDB or not MonologueCharDB.Friends then return end

        local name, realm, raceFile, guid = ResolveMenuSubject(contextData)
        if not name then return end

        local key = engine:FriendKeyFor(name, realm)
        if not key then return end
        local isFriend = MonologueCharDB.Friends[key] ~= nil

        rootDescription:CreateDivider()
        rootDescription:CreateButton(isFriend and "Monologue: Remove Friend" or "Monologue: Add Friend", function()
            if isFriend then
                local record = engine:RemoveFriend(key)
                engine.Print((record and record.name or name) .. " is no longer marked as a friend.")
            else
                local status, record = engine:AddFriend(name, realm, raceFile, nil, guid)
                if status == "full" then
                    engine.Print("Your friends list is full. Remove someone with /mono unfriend <name>.")
                elseif status then
                    engine.Print(record.name .. " marked as a friend. Add a note with /mono friend <note> while targeting them.")
                end
            end
        end)
    end)
end

function UI:HookFriendMenus()
    if self.FriendMenusHooked then return end
    if type(Menu) ~= "table" or type(Menu.ModifyMenu) ~= "function" then return end

    local hooked = 0
    for _, tag in ipairs(FRIEND_MENU_TAGS) do
        if pcall(Menu.ModifyMenu, tag, AddFriendMenuEntries) then
            hooked = hooked + 1
        end
    end
    self.FriendMenusHooked = hooked > 0
end

---------------------------------------------------------------------------
-- Rivals & Friends Roster Window (/mono roster)
-- Two tabs in a scrollable list: Friends (name, race, note with an Edit popup, date
-- added, Remove) and Rivals (name, tier badge, kills - deaths, last zone, Pin/Unpin,
-- Remove). Both read this character's MonologueCharDB and redraw when it changes.
---------------------------------------------------------------------------

local ROSTER_WIDTH = 660
local ROSTER_HEIGHT = 450
local ROSTER_ROW_WIDTH = 590
local ROSTER_NAME_WIDTH = 165 -- wide enough for two-word names such as "Sota Ironbeard"
local ROSTER_ROW_HEIGHT = 26
local ROSTER_SCROLL_TOP = -84

-- Column x offsets (within a row) and header labels
local FRIEND_COLUMNS = {
    { x = 4, text = "Name" }, { x = 173, text = "Race" }, { x = 252, text = "Note" }, { x = 454, text = "Added" },
}
local RIVAL_COLUMNS = {
    { x = 4, text = "Name" }, { x = 173, text = "Tier" }, { x = 259, text = "K - D" }, { x = 323, text = "Last seen in" },
}

local DUEL_COLUMNS = {
    { x = 4, text = "Opponent" }, { x = 173, text = "W - L" }, { x = 247, text = "Last zone" },
}

local TIER_COLORS = {
    FirstClash = "ff9d9d9d",
    DejaVu = "ff66ccff",
    Rematch = "ff1eff00",
    Vendetta = "ffff8000",
    Dominance = "ffffd100",
    Nemesis = "ffff3030",
}

local PANEL_BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 },
}

local function FormatDate(timestamp)
    if type(timestamp) ~= "number" or timestamp <= 0 then return "?" end
    return date("%Y-%m-%d", timestamp)
end

local function FormatRace(race)
    if type(race) ~= "string" or race == "" then return "|cff888888unknown|r" end
    return (race:gsub("(%l)(%u)", "%1 %2"))
end

local function CreateCell(row, x, width)
    local cell = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cell:SetPoint("LEFT", row, "LEFT", x, 0)
    cell:SetWidth(width)
    cell:SetJustifyH("LEFT")
    cell:SetWordWrap(false)
    return cell
end

local function CreateRowButton(row, x, width, text)
    local button = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    button:SetSize(width, 20)
    button:SetPoint("LEFT", row, "LEFT", x, 0)
    button:SetText(text)
    return button
end

local function CreateRosterRow(parent, index)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(ROSTER_ROW_WIDTH, ROSTER_ROW_HEIGHT)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(index - 1) * ROSTER_ROW_HEIGHT)
    if index % 2 == 0 then
        local shade = row:CreateTexture(nil, "BACKGROUND")
        shade:SetAllPoints()
        shade:SetColorTexture(1, 1, 1, 0.04)
    end
    return row
end

function UI:GetFriendRow(index)
    local row = self.FriendRows[index]
    if not row then
        row = CreateRosterRow(self.RosterContent, index)
        row.name = CreateCell(row, 4, ROSTER_NAME_WIDTH)
        row.race = CreateCell(row, 173, 75)
        row.note = CreateCell(row, 252, 150)
        row.edit = CreateRowButton(row, 406, 44, "Edit")
        row.added = CreateCell(row, 454, 72)
        row.remove = CreateRowButton(row, 530, 48, "Remove")
        row.edit:SetScript("OnClick", function() UI:ShowNotePopup(row.key) end)
        row.remove:SetScript("OnClick", function() MonologueEngine:RemoveFriend(row.key) end)
        self.FriendRows[index] = row
    end
    return row
end

function UI:GetRivalRow(index)
    local row = self.RivalRows[index]
    if not row then
        row = CreateRosterRow(self.RosterContent, index)
        row.name = CreateCell(row, 4, ROSTER_NAME_WIDTH)
        row.tier = CreateCell(row, 173, 82)
        row.record = CreateCell(row, 259, 60)
        row.zone = CreateCell(row, 323, 140)
        row.pin = CreateRowButton(row, 467, 56, "Pin")
        row.remove = CreateRowButton(row, 527, 56, "Remove")
        row.pin:SetScript("OnClick", function()
            local rival = MonologueCharDB.Rivals[row.rivalName]
            MonologueEngine:SetRivalPinned(row.rivalName, not (rival and rival.pinned))
        end)
        row.remove:SetScript("OnClick", function() MonologueEngine:RemoveRival(row.rivalName) end)
        self.RivalRows[index] = row
    end
    return row
end

function UI:GetDuelRow(index)
    local row = self.DuelRows[index]
    if not row then
        row = CreateRosterRow(self.RosterContent, index)
        row.name = CreateCell(row, 4, ROSTER_NAME_WIDTH)
        row.record = CreateCell(row, 173, 70)
        row.zone = CreateCell(row, 247, 250)
        row.remove = CreateRowButton(row, 502, 56, "Remove")
        row.remove:SetScript("OnClick", function() MonologueEngine:RemoveDuel(row.key) end)
        self.DuelRows[index] = row
    end
    return row
end

function UI:CreateRoster()
    if self.RosterFrame then return end

    self.FriendRows = {}
    self.RivalRows = {}
    self.DuelRows = {}
    self.RosterTab = "friends"

    local f = CreateFrame("Frame", "MonologueRosterFrame", UIParent, "BackdropTemplate")
    f:SetSize(ROSTER_WIDTH, ROSTER_HEIGHT)
    f:SetPoint("CENTER", 40, 20)
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetBackdrop(PANEL_BACKDROP)
    SolidBackground(f)
    tinsert(UISpecialFrames, "MonologueRosterFrame")

    local title = CreateLabel(f, "Friends, Rivals & Duels |cff00ccff(this character)|r", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", LEFT, -18)

    local closeX = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeX:SetPoint("TOPRIGHT", -6, -6)

    local function MakeTab(text, tabKey, x)
        local tab = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        tab:SetSize(120, 22)
        tab:SetPoint("TOPLEFT", x, -42)
        tab:SetText(text)
        tab:SetScript("OnClick", function()
            UI.RosterTab = tabKey
            UI:RefreshRoster()
        end)
        return tab
    end
    f.friendsTab = MakeTab("Friends", "friends", 20)
    f.rivalsTab = MakeTab("Rivals", "rivals", 146)
    f.duelsTab = MakeTab("Duels", "duels", 272)

    local function MakeHeaders(columns)
        local headers = {}
        for _, column in ipairs(columns) do
            local header = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            header:SetPoint("TOPLEFT", f, "TOPLEFT", 20 + column.x, -70)
            header:SetText(column.text)
            headers[#headers + 1] = header
        end
        return headers
    end
    f.friendHeaders = MakeHeaders(FRIEND_COLUMNS)
    f.rivalHeaders = MakeHeaders(RIVAL_COLUMNS)
    f.duelHeaders = MakeHeaders(DUEL_COLUMNS)

    local scroll = CreateFrame("ScrollFrame", "MonologueRosterScroll", f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 20, ROSTER_SCROLL_TOP)
    scroll:SetPoint("BOTTOMRIGHT", -36, 44)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(ROSTER_ROW_WIDTH, 1)
    scroll:SetScrollChild(content)
    self.RosterContent = content

    f.empty = CreateLabel(f, "", "GameFontDisable")
    f.empty:SetPoint("TOP", scroll, "TOP", 0, -30)
    f.empty:SetWidth(ROSTER_ROW_WIDTH - 40)
    f.empty:SetJustifyH("CENTER")

    local hint = CreateLabel(f, "|cff888888Rivals come from open-world PvP and are kept apart from friendly duels; pinned rivals are never pruned.|r", "GameFontHighlightSmall")
    hint:SetPoint("BOTTOMLEFT", LEFT, 26)
    hint:SetWidth(ROSTER_WIDTH - LEFT * 2 - 110)
    hint:SetWordWrap(true)

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetSize(100, 25)
    closeBtn:SetPoint("BOTTOMRIGHT", -20, 18)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    f:SetScript("OnShow", function() UI:RefreshRoster() end)
    f:Hide()
    self.RosterFrame = f
end

function UI:RefreshRoster()
    local f = self.RosterFrame
    if not f or not f:IsShown() or not MonologueDB or not MonologueCharDB then return end
    local engine = MonologueEngine
    local tab = self.RosterTab
    if tab ~= "rivals" and tab ~= "duels" then tab = "friends" end
    local isFriends, isRivals = tab == "friends", tab == "rivals"

    local friendList = {}
    for key, record in pairs(MonologueCharDB.Friends) do
        if type(record) == "table" then friendList[#friendList + 1] = { key = key, record = record } end
    end
    table.sort(friendList, function(a, b)
        return tostring(a.record.name):lower() < tostring(b.record.name):lower()
    end)

    local rivalList = {}
    for name, rival in pairs(MonologueCharDB.Rivals) do
        if type(rival) == "table" then
            rivalList[#rivalList + 1] = { name = name, rival = rival, total = (rival.kills or 0) + (rival.deaths or 0) }
        end
    end
    table.sort(rivalList, function(a, b)
        if a.total ~= b.total then return a.total > b.total end
        return (a.rival.lastSeen or 0) > (b.rival.lastSeen or 0)
    end)

    local duelList = {}
    for key, duel in pairs(MonologueCharDB.Duels) do
        if type(duel) == "table" then duelList[#duelList + 1] = { key = key, duel = duel } end
    end
    table.sort(duelList, function(a, b) return (a.duel.lastTime or 0) > (b.duel.lastTime or 0) end)

    f.friendsTab:SetText("Friends (" .. #friendList .. ")")
    f.rivalsTab:SetText("Rivals (" .. #rivalList .. ")")
    f.duelsTab:SetText("Duels (" .. #duelList .. ")")
    -- The selected tab shows as pressed (disabled); the others stay clickable
    f.friendsTab:SetEnabled(not isFriends)
    f.rivalsTab:SetEnabled(not isRivals)
    f.duelsTab:SetEnabled(tab ~= "duels")
    for _, header in ipairs(f.friendHeaders) do header:SetShown(isFriends) end
    for _, header in ipairs(f.rivalHeaders) do header:SetShown(isRivals) end
    for _, header in ipairs(f.duelHeaders) do header:SetShown(tab == "duels") end

    for _, row in ipairs(self.FriendRows) do row:Hide() end
    for _, row in ipairs(self.RivalRows) do row:Hide() end
    for _, row in ipairs(self.DuelRows) do row:Hide() end

    local count
    if isFriends then
        count = #friendList
        for index, item in ipairs(friendList) do
            local record = item.record
            local row = self:GetFriendRow(index)
            row.key = item.key
            row.name:SetText(tostring(record.name))
            row.race:SetText(FormatRace(record.race))
            if type(record.note) == "string" and record.note ~= "" then
                row.note:SetText(record.note)
            else
                row.note:SetText("|cff888888(no note)|r")
            end
            row.added:SetText(FormatDate(record.addedAt))
            row:Show()
        end
        f.empty:SetText(count == 0
            and "No marked friends yet. Target a friendly player and type /mono friend [note], or right-click their portrait." or "")
    elseif isRivals then
        count = #rivalList
        for index, item in ipairs(rivalList) do
            local rival = item.rival
            local tier = engine:GetRivalRecordTier(rival) or "FirstClash"
            local row = self:GetRivalRow(index)
            row.rivalName = item.name
            -- item.name is the lookup key; the display name keeps its spaces
            row.name:SetText((rival.pinned and "|cffffd100*|r " or "") .. tostring(rival.name or item.name))
            row.tier:SetText("|c" .. TIER_COLORS[tier] .. tier .. "|r")
            row.record:SetText(string.format("|cff1eff00%d|r - |cffff3030%d|r", rival.kills or 0, rival.deaths or 0))
            row.zone:SetText(tostring(rival.lastZone or "?"))
            row.pin:SetText(rival.pinned and "Unpin" or "Pin")
            row:Show()
        end
        f.empty:SetText(count == 0
            and "No rivals yet. Enemy players you fight in the open world are recorded here." or "")
    else
        count = #duelList
        for index, item in ipairs(duelList) do
            local duel = item.duel
            local row = self:GetDuelRow(index)
            row.key = item.key
            row.name:SetText(tostring(duel.name or item.key))
            row.record:SetText(string.format("|cff1eff00%d|r - |cffff3030%d|r", duel.wins or 0, duel.losses or 0))
            row.zone:SetText(tostring(duel.lastZone or "?"))
            row:Show()
        end
        f.empty:SetText(count == 0
            and "No duels yet. Duel records appear here after you duel another player." or "")
    end

    self.RosterContent:SetHeight(math.max(count * ROSTER_ROW_HEIGHT, 1))
end

function UI:OnRosterDataChanged()
    if self.RosterFrame and self.RosterFrame:IsShown() then
        self:RefreshRoster()
    end
end

function UI:ToggleRoster()
    if not MonologueDB or not MonologueCharDB then return end
    self:CreateRoster()
    if self.RosterFrame:IsShown() then
        self.RosterFrame:Hide()
    else
        self.RosterFrame:Show()
    end
end

-- Small popup for editing a friend's note (empty text clears it)
function UI:ShowNotePopup(key)
    local record = MonologueCharDB and MonologueCharDB.Friends and MonologueCharDB.Friends[key]
    if not record then return end

    if not self.NotePopup then
        local p = CreateFrame("Frame", "MonologueNoteFrame", UIParent, "BackdropTemplate")
        p:SetSize(360, 160)
        p:SetPoint("CENTER", 0, 60)
        p:SetFrameStrata("FULLSCREEN_DIALOG")
        p:SetToplevel(true)
        p:SetClampedToScreen(true)
        p:EnableMouse(true)
        p:SetBackdrop(PANEL_BACKDROP)
        SolidBackground(p)
        tinsert(UISpecialFrames, "MonologueNoteFrame")

        p.title = CreateLabel(p, "", "GameFontNormal")
        p.title:SetPoint("TOPLEFT", 20, -20)

        local edit = CreateFrame("EditBox", nil, p, "InputBoxTemplate")
        edit:SetSize(310, 28)
        edit:SetPoint("TOPLEFT", 26, -46)
        edit:SetAutoFocus(false)
        edit:SetMaxLetters(100)
        p.edit = edit

        local function Save()
            MonologueEngine:SetFriendNote(p.key, edit:GetText())
            p:Hide()
        end
        edit:SetScript("OnEnterPressed", Save)
        edit:SetScript("OnEscapePressed", function() p:Hide() end)

        -- Quick picks: set the note and save in one click. "Duo" triggers FriendGreetings.Duo.
        local presetLabel = CreateLabel(p, "Quick pick:", "GameFontHighlightSmall")
        presetLabel:SetPoint("TOPLEFT", 22, -84)
        local function AddPreset(text, note, anchor, x)
            local b = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
            b:SetSize(84, 22)
            b:SetPoint("LEFT", anchor, "RIGHT", x, 0)
            b:SetText(text)
            b:SetScript("OnClick", function()
                edit:SetText(note)
                MonologueEngine:SetFriendNote(p.key, note)
                p:Hide()
            end)
            return b
        end
        local duoBtn = AddPreset("Duo", "Duo", presetLabel, 8)
        local allyBtn = AddPreset("Ally", "Ally", duoBtn, 6)
        AddPreset("Clear Note", "", allyBtn, 6)

        local saveBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        saveBtn:SetSize(90, 24)
        saveBtn:SetPoint("BOTTOMRIGHT", -112, 18)
        saveBtn:SetText("Save")
        saveBtn:SetScript("OnClick", Save)

        local cancelBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        cancelBtn:SetSize(90, 24)
        cancelBtn:SetPoint("BOTTOMRIGHT", -18, 18)
        cancelBtn:SetText("Cancel")
        cancelBtn:SetScript("OnClick", function() p:Hide() end)

        self.NotePopup = p
    end

    local p = self.NotePopup
    p.key = key
    p.title:SetText("Note for " .. tostring(record.name))
    p.edit:SetText(record.note or "")
    p:Show()
    p.edit:SetFocus()
    p.edit:HighlightText()
end

---------------------------------------------------------------------------
-- Minimap Button
-- Left-click: config window | Right-click: roster | Shift+Left-click: battle cry.
-- Drag to slide it around the minimap edge; the angle is saved in
-- MonologueDB.minimapAngle and /mono minimap shows or hides it.
---------------------------------------------------------------------------

local MINIMAP_RADIUS_PADDING = 5

local function PositionMinimapButton(button, angle)
    local radians = math.rad(angle)
    local width = Minimap:GetWidth()
    if not width or width <= 0 then width = 140 end  -- minimap not laid out yet
    local radius = (width / 2) + MINIMAP_RADIUS_PADDING
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(radians) * radius, math.sin(radians) * radius)
end

local function MinimapButton_OnUpdate(button)
    local centerX, centerY = Minimap:GetCenter()
    if not centerX then return end
    local scale = Minimap:GetEffectiveScale()
    local cursorX, cursorY = GetCursorPosition()
    local angle = math.deg(math.atan2(cursorY / scale - centerY, cursorX / scale - centerX))
    MonologueDB.minimapAngle = angle
    PositionMinimapButton(button, angle)
end

local function ShowMinimapTooltip(button)
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:AddLine("Monologue |cff00ccff(v.1)|r", 1, 1, 1)

    local ctx = MonologueEngine.ActiveContext or {}
    local persona = ctx.persona and MonologueEngine:GetPersonaDisplayName(ctx.persona) or nil
    local function Layer(label, value)
        GameTooltip:AddDoubleLine(label, value or "none", 0.7, 0.7, 0.7, 1, 1, 1)
    end
    Layer("Race", ctx.race and (ctx.subtype and (ctx.race .. " / " .. ctx.subtype) or ctx.race) or nil)
    Layer("Class", ctx.class)
    Layer("Persona", persona)
    Layer("Guild pack", ctx.guild)
    Layer("Profile", ctx.profile)

    local rivals = 0
    for _ in pairs(MonologueCharDB and MonologueCharDB.Rivals or {}) do rivals = rivals + 1 end
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Friends", tostring(MonologueEngine:CountFriends()), 0.7, 0.7, 0.7, 1, 0.82, 0)
    GameTooltip:AddDoubleLine("Rivals", tostring(rivals), 0.7, 0.7, 0.7, 1, 0.82, 0)

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Left-click: config window", 0.8, 0.8, 0.8)
    GameTooltip:AddLine("Right-click: rivals & friends", 0.8, 0.8, 0.8)
    GameTooltip:AddLine("Shift+Left-click: battle cry", 0.8, 0.8, 0.8)
    GameTooltip:AddLine("Drag: move around the minimap", 0.8, 0.8, 0.8)
    GameTooltip:Show()
end

function UI:CreateMinimapButton()
    if self.MinimapButton or not MonologueDB or not Minimap then return end

    local button = CreateFrame("Button", "MonologueMinimapButton", Minimap)
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetSize(20, 20)
    background:SetPoint("TOPLEFT", 7, -5)

    local icon = button:CreateTexture(nil, "ARTWORK")
    button.icon = icon
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    icon:SetSize(17, 17)
    icon:SetPoint("TOPLEFT", 7, -6)

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT")

    button:SetScript("OnClick", function(_, mouseButton)
        local handler = SlashCmdList and SlashCmdList["MONOLOGUE"]
        if type(handler) ~= "function" then
            -- The core file didn't load (a Lua error in Monologue_Core.lua): say so instead
            -- of failing silently
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff[Monologue]|r The core engine didn't load, so /mono isn't available. "
                .. "Check for a Lua error on login (or /mono bug won't work either) and report it.")
            return
        end
        if mouseButton == "RightButton" then
            handler("roster")
        elseif IsShiftKeyDown() then
            handler("cry")
        else
            handler("ui")
        end
    end)
    button:SetScript("OnDragStart", function(self)
        GameTooltip:Hide()
        self:SetScript("OnUpdate", MinimapButton_OnUpdate)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    button:SetScript("OnEnter", ShowMinimapTooltip)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local angle = tonumber(MonologueDB.minimapAngle)
    if not angle or angle ~= angle or angle == math.huge or angle == -math.huge then angle = 215 end
    MonologueDB.minimapAngle = angle
    PositionMinimapButton(button, angle)
    button:SetShown(MonologueDB.minimapShown ~= false)
    self.MinimapButton = button
    self:UpdateMinimapState()
end

-- Out of character (keybind, /mono ooc): the book goes grey
function UI:UpdateMinimapState()
    local button = self.MinimapButton
    if not button or not button.icon or not MonologueDB then return end
    local ooc = MonologueDB.outOfCharacter == true
    button.icon:SetDesaturated(ooc)
    button.icon:SetVertexColor(ooc and 0.6 or 1, ooc and 0.6 or 1, ooc and 0.6 or 1)
end

-- Each piece is built on its own, so an error in one (e.g. a damaged saved position) can't
-- stop the others from appearing. Errors are reported in chat instead of failing silently.
local function BuildSafely(label, fn)
    local ok, err = pcall(fn)
    if not ok and MonologueEngine and MonologueEngine.Print then
        MonologueEngine.Print("|cffff8800Could not create the " .. label .. ":|r " .. tostring(err))
    end
end

-- /mono minimap reset: back to the default spot, shown
function UI:ResetMinimap()
    if not MonologueDB then return end
    MonologueDB.minimapAngle = 215
    MonologueDB.minimapShown = true
    BuildSafely("minimap button", function() self:CreateMinimapButton() end)
    if not self.MinimapButton then return end
    PositionMinimapButton(self.MinimapButton, 215)
    self.MinimapButton:Show()
    MonologueEngine.Print("Minimap button reset to its default position and shown.")
end

function UI:ToggleMinimap()
    if not MonologueDB then return end
    BuildSafely("minimap button", function() self:CreateMinimapButton() end)
    if not self.MinimapButton then
        MonologueEngine.Print("The minimap button could not be created (no minimap frame?).")
        return
    end

    local show = not self.MinimapButton:IsShown()
    MonologueDB.minimapShown = show
    self.MinimapButton:SetShown(show)
    if MonologueEngine and MonologueEngine.Print then
        MonologueEngine.Print("Minimap button " .. (show and "shown." or "hidden. Type /mono minimap to bring it back."))
    end
end

---------------------------------------------------------------------------
-- Queue bubble: shows the line waiting for your next key press. Left-click says it (a click
-- is a key press), right-click skips it, right-drag moves it. MonologueDB.queueBubble.
---------------------------------------------------------------------------
local BUBBLE_WIDTH = 270
local BUBBLE_COLORS = { SAY = { 1, 1, 1 }, YELL = { 1, 0.25, 0.25 }, EMOTE = { 1, 0.5, 0.25 } }

function UI:CreateQueueBubble()
    if self.QueueBubble or not MonologueDB then return end
    local bubble = CreateFrame("Button", "MonologueQueueBubble", UIParent, "BackdropTemplate")
    bubble:SetSize(BUBBLE_WIDTH, 50)
    bubble:SetFrameStrata("MEDIUM")
    bubble:SetClampedToScreen(true)
    bubble:SetMovable(true)
    bubble:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    bubble:RegisterForDrag("RightButton")
    bubble:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    bubble:SetBackdropColor(0, 0, 0, 0.8)
    bubble:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
    bubble:Hide()

    local pos = MonologueDB.bubblePos
    if type(pos) == "table" and type(pos.point) == "string" and type(pos.relPoint) == "string"
        and type(pos.x) == "number" and type(pos.y) == "number" then
        bubble:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
    else
        bubble:SetPoint("CENTER", UIParent, "CENTER", 0, -150)
    end

    local line = bubble:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    line:SetPoint("TOPLEFT", 10, -9)
    line:SetWidth(BUBBLE_WIDTH - 20)
    line:SetJustifyH("LEFT")
    line:SetWordWrap(true)
    local hint = bubble:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 0, -4)
    hint:SetWidth(BUBBLE_WIDTH - 20)
    hint:SetJustifyH("LEFT")

    bubble:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "RightButton" then
            MonologueEngine:DropPendingLine()
        else
            MonologueEngine:GreetNow()
        end
        self:Hide()
        self.shownText = nil
    end)
    bubble:SetScript("OnDragStart", function(self) self:StartMoving() end)
    bubble:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relPoint, x, y = self:GetPoint(1)
        if point then MonologueDB.bubblePos = { point = point, relPoint = relPoint, x = x, y = y } end
    end)

    -- Watches for a waiting line a few times a second (the bubble itself is hidden meanwhile)
    local watcher = CreateFrame("Frame", nil, UIParent)
    local elapsed = 0
    watcher:SetScript("OnUpdate", function(_, delta)
        elapsed = elapsed + delta
        if elapsed < 0.2 then return end
        elapsed = 0
        local text, chatType = MonologueEngine:GetPendingLine()
        if not text or not MonologueDB or MonologueDB.queueBubble == false then
            if bubble:IsShown() then bubble:Hide() end
            bubble.shownText = nil
            return
        end
        if bubble.shownText ~= text then
            bubble.shownText = text
            local color = BUBBLE_COLORS[chatType] or BUBBLE_COLORS.SAY
            line:SetTextColor(color[1], color[2], color[3])
            line:SetText(text)
            local key = GetBindingKey and GetBindingKey("MONOLOGUE_GREET")
            local keyText = key and (GetBindingText and GetBindingText(key) or key)
            hint:SetText((keyText and ("Click or press " .. keyText .. " to say it") or "Click to say it")
                .. "  |  right-click: skip")
            bubble:SetHeight(line:GetStringHeight() + hint:GetStringHeight() + 24)
        end
        if not bubble:IsShown() then bubble:Show() end
    end)
    self.QueueBubble = bubble
end

local cryButtonFrame = CreateFrame("Frame")
cryButtonFrame:RegisterEvent("PLAYER_LOGIN")
cryButtonFrame:SetScript("OnEvent", function(self)
    BuildSafely("minimap button", function() UI:CreateMinimapButton() end)
    BuildSafely("Battle Cry button", function() UI:CreateBattleCryButton() end)
    BuildSafely("Greet button", function() UI:CreateGreetButton() end)
    BuildSafely("Taunt button", function() UI:CreateTauntButton() end)
    BuildSafely("queue bubble", function() UI:CreateQueueBubble() end)
    BuildSafely("portrait menu entries", function() UI:HookFriendMenus() end)
    self:UnregisterEvent("PLAYER_LOGIN")
end)

---------------------------------------------------------------------------
-- Canvas Settings Category (Game Menu > Options > AddOns > Monologue)
---------------------------------------------------------------------------

local function RegisterSettingsCategory()
    if not (Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory) then return end

    local canvas = CreateFrame("Frame", "MonologueSettingsCanvas")

    local title = CreateLabel(canvas, "Monologue |cff00ccff(v.1)|r", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)

    local desc = CreateLabel(canvas,
        "Public RP & RP-PvP engine: live dialect translation for Say/Yell/Party and cooldown-gated character reactions.\n\n"
        .. "Settings, Growth Arc personas and the Live Test Bench live in the Monologue config panel.",
        "GameFontHighlight")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
    desc:SetWidth(560)

    local openBtn = CreateFrame("Button", nil, canvas, "UIPanelButtonTemplate")
    openBtn:SetSize(200, 26)
    openBtn:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -16)
    openBtn:SetText("Open Monologue Config")
    openBtn:SetScript("OnClick", function() UI:Open() end)

    local slashHint = CreateLabel(canvas, "|cff888888Slash command: /mono (type /mono help for all commands)|r", "GameFontHighlightSmall")
    slashHint:SetPoint("TOPLEFT", openBtn, "BOTTOMLEFT", 0, -12)

    local category = Settings.RegisterCanvasLayoutCategory(canvas, "Monologue")
    Settings.RegisterAddOnCategory(category)
    UI.SettingsCategory = category
end

RegisterSettingsCategory()

---------------------------------------------------------------------------
-- Alpha testing: Bug Report window (/mono bug) and the first-login welcome card
---------------------------------------------------------------------------

local function CreateModal(name, width, height, titleText)
    local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    f:SetSize(width, height)
    f:SetPoint("CENTER")
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetBackdrop(PANEL_BACKDROP)
    SolidBackground(f)
    tinsert(UISpecialFrames, name)
    local title = CreateLabel(f, titleText, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", LEFT, -20)
    local closeX = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeX:SetPoint("TOPRIGHT", -6, -6)
    return f
end

function UI:RefreshBugReport()
    if not self.BugEdit then return end
    local note = self.BugNote and self.BugNote:GetText() or ""
    local ok, report = pcall(MonologueEngine.BuildBugReport, MonologueEngine, note)
    if not ok then report = "Could not build the report: " .. tostring(report) end
    self.BugEdit:SetText(report)
    self.BugEdit:SetCursorPosition(0)
end

function UI:ShowBugReport()
    if not self.BugFrame then
        local f = CreateModal("MonologueBugFrame", 560, 460, "Monologue Bug Report")
        local hint = CreateLabel(f, "|cff888888What happened? (optional) Then press Select Report, Ctrl+C, and paste it into Discord.|r", "GameFontHighlightSmall")
        hint:SetPoint("TOPLEFT", LEFT, -48)
        hint:SetWidth(520)
        hint:SetJustifyH("LEFT")

        local note = CreateInput(f, 510, 200)
        note:SetPoint("TOPLEFT", LEFT + 6, -66)
        note:SetScript("OnTextChanged", function(_, userInput) if userInput then UI:RefreshBugReport() end end)
        note:SetScript("OnEnterPressed", function(box) box:ClearFocus() end)
        self.BugNote = note

        local scroll = CreateFrame("ScrollFrame", "MonologueBugScroll", f, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", LEFT, -100)
        scroll:SetPoint("BOTTOMRIGHT", -40, 54)
        local edit = CreateFrame("EditBox", nil, scroll)
        edit:SetMultiLine(true)
        edit:SetAutoFocus(false)
        edit:SetFontObject(ChatFontNormal)
        edit:SetWidth(490)
        edit:SetScript("OnEscapePressed", function(box) box:ClearFocus() end)
        -- Read-only: any typing is undone by rebuilding the report
        edit:SetScript("OnTextChanged", function(_, userInput) if userInput then UI:RefreshBugReport() end end)
        scroll:SetScrollChild(edit)
        self.BugEdit = edit

        local selectBtn = CreateButton(f, "Select Report", 110, function()
            edit:SetFocus()
            edit:HighlightText()
            MonologueEngine.Print("Report selected: press Ctrl+C to copy it.")
        end)
        selectBtn:SetPoint("BOTTOMLEFT", LEFT, 20)
        local refresh = CreateButton(f, "Refresh", 80, function() UI:RefreshBugReport() end)
        refresh:SetPoint("LEFT", selectBtn, "RIGHT", 6, 0)
        local close = CreateButton(f, "Close", 80, function() f:Hide() end)
        close:SetPoint("BOTTOMRIGHT", -20, 20)
        self.BugFrame = f
    end
    self.BugFrame:Show()
    self.BugFrame:Raise()
    self:RefreshBugReport()
end

function UI:ShowWelcome()
    if MonologueCharDB then MonologueCharDB.welcomed = true end
    if not self.WelcomeFrame then
        local f = CreateModal("MonologueWelcomeFrame", 420, 270, "Welcome to Monologue")
        local body = CreateLabel(f, "", "GameFontHighlight")
        body:SetPoint("TOPLEFT", LEFT, -52)
        body:SetWidth(376)
        body:SetJustifyH("LEFT")
        body:SetJustifyV("TOP")
        body:SetWordWrap(true)
        body:SetText("Your character now talks on their own: pull lines, greetings, rivals, world reactions and more, said in /s when you press an ability.\n\n"
            .. "|cffffd100/mono|r  opens the settings and the |cffffd100My Voice|r studio (clan, hometown, traits, your own lines).\n"
            .. "|cffffd100/mono bug|r  makes a bug report to paste in Discord.\n\n"
            .. "|cff888888Alpha build " .. tostring(MonologueEngine.VERSION) .. ". Thanks for testing!|r")
        local open = CreateButton(f, "Open My Voice", 110, function()
            f:Hide()
            UI:OpenVoice()
        end)
        open:SetPoint("BOTTOMLEFT", LEFT, 20)
        local done = CreateButton(f, "Got it", 80, function() f:Hide() end)
        done:SetPoint("BOTTOMRIGHT", -20, 20)
        self.WelcomeFrame = f
    end
    self.WelcomeFrame:Show()
    self.WelcomeFrame:Raise()
end
