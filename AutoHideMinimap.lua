-- Auto Hide Minimap v1.3.0
-- World of Warcraft 3.3.5a / Lua 5.1
--
-- Automatic hiding is optional and remembered across logins.
-- /ahm always toggles the minimap manually, including during startup.

local frame = CreateFrame("Frame")
local STARTUP_WINDOW = 8.0
local CHECK_INTERVAL = 0.25

local startupActive = false
local elapsed = 0
local tick = 0
local optionsPanel
local autoHideCheckbox

local function Print(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffFFD100Auto Hide Minimap:|r " .. message)
    end
end

local function Settings()
    if type(AutoHideMinimapDB) ~= "table" then
        AutoHideMinimapDB = {}
    end
    -- Preserve the v1.2.0 behaviour for existing installations.
    if type(AutoHideMinimapDB.autoHideEnabled) ~= "boolean" then
        AutoHideMinimapDB.autoHideEnabled = true
    end
    return AutoHideMinimapDB
end

local function AutoHideEnabled()
    return Settings().autoHideEnabled
end

local function HideMinimap()
    if MinimapCluster and MinimapCluster:IsShown() then
        MinimapCluster:Hide()
    end
end

local function ToggleMinimap()
    -- A manual decision always wins over the startup hiding window.
    startupActive = false

    if not MinimapCluster then
        Print("Minimap unavailable.")
        return
    end

    if MinimapCluster:IsShown() then
        MinimapCluster:Hide()
        Print("hidden.")
    else
        MinimapCluster:Show()
        Print("shown.")
    end
end

local function SetAutoHide(enabled)
    enabled = not not enabled
    Settings().autoHideEnabled = enabled

    if not enabled then
        -- Turning it off immediately stops any remaining startup checks.
        startupActive = false
    end
    -- Turning it ON does not unexpectedly hide a manually shown minimap.
    -- The automatic hiding window starts on the next login or /reload.
    if autoHideCheckbox then
        autoHideCheckbox:SetChecked(enabled)
    end

    Print(enabled and
        "Automatic hiding ON (applies next login or /reload)." or
        "Automatic hiding OFF. Manual /ahm still works.")
end

local function CreateOptionsPanel()
    -- The slash settings remain usable if the client has no options API.
    if type(InterfaceOptions_AddCategory) ~= "function" then
        return
    end

    local panel = CreateFrame("Frame", "AutoHideMinimapOptionsPanel", UIParent)
    panel.name = "Auto Hide Minimap"
    optionsPanel = panel

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
    title:SetText("Auto Hide Minimap")

    local description = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
    description:SetWidth(500)
    description:SetJustifyH("LEFT")
    description:SetText("Choose whether the minimap hides automatically when you log in. You can always toggle it manually.")

    local check = CreateFrame("CheckButton", "AutoHideMinimapAutoHideCheck",
        panel, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -18)
    autoHideCheckbox = check

    local label = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("LEFT", check, "RIGHT", 5, 0)
    label:SetText("Automatically hide the minimap at login")

    local help = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    help:SetPoint("TOPLEFT", check, "BOTTOMLEFT", 0, -14)
    help:SetWidth(500)
    help:SetJustifyH("LEFT")
    help:SetText("ON: hide for the first 8 seconds after login. OFF: leave the minimap alone. A manual toggle always takes priority.")

    check:SetScript("OnClick", function(self)
        -- WoW 3.3.5a GetChecked() may return 1 or nil, not strict booleans.
        SetAutoHide(self:GetChecked() and true or false)
    end)

    local toggle = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    toggle:SetWidth(185)
    toggle:SetHeight(24)
    toggle:SetPoint("TOPLEFT", help, "BOTTOMLEFT", 0, -20)
    toggle:SetText("Show / Hide Minimap Now")
    toggle:SetScript("OnClick", ToggleMinimap)

    panel:SetScript("OnShow", function()
        check:SetChecked(AutoHideEnabled())
    end)

    InterfaceOptions_AddCategory(panel)
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        startupActive = AutoHideEnabled()
        elapsed = 0
        tick = 0
    end
end)

frame:SetScript("OnUpdate", function(self, delta)
    if not startupActive then return end

    elapsed = elapsed + delta
    tick = tick + delta

    if tick >= CHECK_INTERVAL then
        tick = 0
        HideMinimap()
    end

    if elapsed >= STARTUP_WINDOW then
        HideMinimap()
        startupActive = false
    end
end)

SLASH_AUTOHIDEMINIMAP1 = "/ahm"

SlashCmdList["AUTOHIDEMINIMAP"] = function(message)
    local command = string.lower((message or ""):match("^%s*(.-)%s*$") or "")

    if command == "" or command == "toggle" then
        ToggleMinimap()
    elseif command == "auto" then
        SetAutoHide(not AutoHideEnabled())
    elseif command == "auto on" then
        SetAutoHide(true)
    elseif command == "auto off" then
        SetAutoHide(false)
    elseif command == "status" then
        local current = MinimapCluster and
            (MinimapCluster:IsShown() and "shown" or "hidden") or "unavailable"
        Print("Minimap " .. current .. "; auto-hide " ..
            (AutoHideEnabled() and "ON" or "OFF") .. ".")
    elseif command == "options" then
        if optionsPanel and type(InterfaceOptionsFrame_OpenToCategory) == "function" then
            InterfaceOptionsFrame_OpenToCategory(optionsPanel)
        else
            Print("Use /ahm auto on or /ahm auto off to configure auto-hide.")
        end
    else
        Print("Usage: /ahm (show/hide), /ahm auto (toggle), " ..
            "/ahm auto on, /ahm auto off, /ahm status, /ahm options.")
    end
end

CreateOptionsPanel()
