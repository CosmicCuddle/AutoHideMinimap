-- Lua 5.1 offline regression tests: mocked World of Warcraft 3.3.5a API.
-- Run from repo root: lua5.1 tests/test_autohide.lua
local assertions = 0
local function check(value, why)
    assert(value, why or "assertion failed")
    assertions = assertions + 1
end

local function NewWidget()
    local w = { scripts = {}, visible = true }
    function w:RegisterEvent(event)
        self.registeredEvent = event
    end
    function w:SetScript(event, handler)
        self.scripts[event] = handler
    end
    function w:SetPoint() end
    function w:SetWidth(width) self.width = width end
    function w:SetHeight(height) self.height = height end
    function w:SetJustifyH() end
    function w:SetText(text) self.text = text end
    function w:CreateFontString()
        return NewWidget()
    end
    function w:IsShown() return self.visible end
    function w:Show() self.visible = true end
    function w:Hide() self.visible = false end
    function w:SetChecked(value) self.checked = not not value end
    -- WotLK 3.3.5a commonly returns 1/nil rather than boolean.
    function w:GetChecked() return self.checked and 1 or nil end
    return w
end

local function Invoke(widget, event, ...)
    check(widget ~= nil and type(widget.scripts[event]) == "function",
        "Missing expected UI " .. event .. " handler")
    return widget.scripts[event](widget, ...)
end

local function LoadAddon(saved, hasOptions)
    local ctx = { messages = {} }
    AutoHideMinimapDB = saved
    UIParent = NewWidget()
    MinimapCluster = NewWidget()
    SlashCmdList = {}
    DEFAULT_CHAT_FRAME = {
        AddMessage = function(self, text)
            table.insert(ctx.messages, text)
        end
    }
    CreateFrame = function(kind, name, parent, template)
        local w = NewWidget()
        if kind == "Frame" and name == nil and parent == nil then
            ctx.frame = w
        end
        if name == "AutoHideMinimapAutoHideCheck" then
            ctx.check = w
        end
        if name == "AutoHideMinimapOptionsPanel" then
            ctx.panel = w
        end
        if kind == "Button" and template == "UIPanelButtonTemplate" then
            ctx.manualButton = w
        end
        return w
    end
    InterfaceOptions_AddCategory = hasOptions and function(panel)
        ctx.category = panel
    end or nil
    InterfaceOptionsFrame_OpenToCategory = hasOptions and function(panel)
        ctx.opened = panel
    end or nil

    assert(loadfile("AutoHideMinimap.lua"))()
    check(ctx.frame.registeredEvent == "PLAYER_LOGIN", "Login event unchanged")
    check(SLASH_AUTOHIDEMINIMAP1 == "/ahm", "Original slash command retained")
    check(type(SlashCmdList.AUTOHIDEMINIMAP) == "function",
        "Manual slash toggle registered")
    if hasOptions then
        check(ctx.panel and ctx.check and ctx.manualButton,
            "3.3.5a Interface AddOns option and manual toggle created")
        check(ctx.category == ctx.panel, "Options registered with WoW")
    else
        check(ctx.panel == nil, "No UI panel when options API unavailable")
    end
    return ctx
end

local function Slash(command)
    SlashCmdList.AUTOHIDEMINIMAP(command)
end

-- Existing installs start with automatic hiding ON, just like v1.2.0.
local original = LoadAddon(nil, true)
Invoke(original.frame, "OnEvent", "PLAYER_LOGIN")
check(AutoHideMinimapDB.autoHideEnabled == true, "Legacy default is ON")
Invoke(original.frame, "OnUpdate", 0.26)
check(not MinimapCluster:IsShown(), "Auto-hide hides during startup")
Slash("")
check(MinimapCluster:IsShown(), "Original /ahm toggles to shown")
Invoke(original.frame, "OnUpdate", 9.0)
check(MinimapCluster:IsShown(), "Manual toggle stops startup hiding")
Invoke(original.panel, "OnShow")
check(original.check:GetChecked() == 1, "Panel displays saved ON setting")

-- Disabled automatic mode leaves the minimap alone, even after 8 seconds.
local savedOff = { autoHideEnabled = false, futureField = "untouched" }
local off = LoadAddon(savedOff, true)
Invoke(off.frame, "OnEvent", "PLAYER_LOGIN")
Invoke(off.frame, "OnUpdate", 0.3)
Invoke(off.frame, "OnUpdate", 10)
check(MinimapCluster:IsShown(), "OFF never auto-hides on login")
check(AutoHideMinimapDB == savedOff and
    AutoHideMinimapDB.futureField == "untouched",
    "Persistent table and unrelated saved fields preserved")
Slash("")
check(not MinimapCluster:IsShown(), "Manual /ahm still hides when auto OFF")
Slash("")
check(MinimapCluster:IsShown(), "Manual /ahm still shows when auto OFF")
Invoke(off.panel, "OnShow")
check(off.check:GetChecked() == nil, "Panel displays saved OFF setting")
Slash("status")
check(off.messages[#off.messages]:find("auto-hide OFF", 1, true),
    "Status reports saved OFF setting")

-- Checkbox updates SavedVariables without hiding the minimap immediately.
off.check:SetChecked(true)
Invoke(off.check, "OnClick")
check(AutoHideMinimapDB.autoHideEnabled == true,
    "UICheckButton ON persists even when GetChecked returns number 1")
Invoke(off.frame, "OnUpdate", 1.0)
check(MinimapCluster:IsShown(),
    "Enabling auto-hide does not override current manual visibility")
Invoke(off.frame, "OnEvent", "PLAYER_LOGIN")
Invoke(off.frame, "OnUpdate", 0.3)
check(not MinimapCluster:IsShown(), "Enabled choice applies at next login")
-- Manual button in options uses the very same safe toggle action.
Invoke(off.manualButton, "OnClick")
check(MinimapCluster:IsShown(), "Options manual button shows minimap")
Invoke(off.frame, "OnUpdate", 4.0)
check(MinimapCluster:IsShown(), "Options manual button interrupts startup")

-- Disabling via checkbox during the startup period stops future hiding.
Invoke(off.frame, "OnEvent", "PLAYER_LOGIN")
MinimapCluster:Show()
off.check:SetChecked(false)
Invoke(off.check, "OnClick")
Invoke(off.frame, "OnUpdate", 0.5)
check(MinimapCluster:IsShown(), "Checkbox OFF immediately stops auto-hide")
check(AutoHideMinimapDB.autoHideEnabled == false,
    "Checkbox OFF persists even when GetChecked returns nil")

-- Slash auto on/off, auto toggle and options must not break /ahm.
Slash("auto on")
check(AutoHideMinimapDB.autoHideEnabled == true,
    "Explicit auto on saved")
check(off.check:GetChecked() == 1, "Slash updates visible settings checkbox")
Slash("auto")
check(AutoHideMinimapDB.autoHideEnabled == false, "Auto shorthand toggles OFF")
Slash("auto")
check(AutoHideMinimapDB.autoHideEnabled == true, "Auto shorthand toggles ON")
Slash("auto off")
check(AutoHideMinimapDB.autoHideEnabled == false, "Explicit auto off saved")
Slash("options")
check(off.opened == off.panel, "Options shortcut opens client settings")
Slash("invalid")
check(off.messages[#off.messages]:find("/ahm auto off", 1, true),
    "Invalid commands show help")

-- A new session sees exactly the saved toggle from the previous session.
local relog = LoadAddon(savedOff, true)
Invoke(relog.frame, "OnEvent", "PLAYER_LOGIN")
Invoke(relog.frame, "OnUpdate", 0.26)
check(MinimapCluster:IsShown(), "Saved OFF choice persists across relog")
-- The command continues to work even if the Blizzard Interface UI is absent.
local withoutUI = LoadAddon({autoHideEnabled=false}, false)
Invoke(withoutUI.frame, "OnEvent", "PLAYER_LOGIN")
Slash("auto on")
Invoke(withoutUI.frame, "OnUpdate", 1.0)
check(MinimapCluster:IsShown(), "Auto ON waits until next login without UI")
Invoke(withoutUI.frame, "OnEvent", "PLAYER_LOGIN")
Invoke(withoutUI.frame, "OnUpdate", 0.3)
check(not MinimapCluster:IsShown(), "Slash fallback takes effect next login")
Slash("")
check(MinimapCluster:IsShown(), "Slash manual toggle works without UI")

-- Startup completes after eight seconds and never hides again.
local complete = LoadAddon({autoHideEnabled=true}, true)
Invoke(complete.frame, "OnEvent", "PLAYER_LOGIN")
Invoke(complete.frame, "OnUpdate", 8.1)
check(not MinimapCluster:IsShown(), "Final startup tick hides once")
MinimapCluster:Show()
Invoke(complete.frame, "OnUpdate", 1.0)
check(MinimapCluster:IsShown(), "Auto-hide does not run after eight seconds")

local corrupt = LoadAddon({autoHideEnabled="yes", unrelated=9}, true)
Invoke(corrupt.frame, "OnEvent", "PLAYER_LOGIN")
check(AutoHideMinimapDB.autoHideEnabled == true,
    "Invalid saved preference safely uses legacy default")
check(AutoHideMinimapDB.unrelated == 9,
    "Settings normalization preserves unrelated data")

print("PASS: " .. assertions ..
    " WoW 3.3.5a / Lua 5.1 auto-hide, persistence, options and manual toggle assertions")
