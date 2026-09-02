-- Auto Hide Minimap v1.2.0
-- WoW 3.3.5a
--
-- Some UI/addons re-show the minimap several seconds after login.
-- This version repeatedly hides it during a short startup window,
-- then completely stops interfering so manual toggles still work.

local f = CreateFrame("Frame")

local startupActive = false
local elapsed = 0
local tick = 0
local STARTUP_WINDOW = 8.0
local CHECK_INTERVAL = 0.25

local function HideMinimap()
    if MinimapCluster and MinimapCluster:IsShown() then
        MinimapCluster:Hide()
    end
end

f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        startupActive = true
        elapsed = 0
        tick = 0
    end
end)

f:SetScript("OnUpdate", function(self, delta)
    if not startupActive then
        return
    end

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

-- Manual toggle command.
SLASH_AUTOHIDEMINIMAP1 = "/ahm"

SlashCmdList["AUTOHIDEMINIMAP"] = function()
    if not MinimapCluster then
        return
    end

    -- If used during startup, stop the automatic hiding immediately.
    startupActive = false

    if MinimapCluster:IsShown() then
        MinimapCluster:Hide()
        DEFAULT_CHAT_FRAME:AddMessage("|cffFFD100Auto Hide Minimap:|r hidden.")
    else
        MinimapCluster:Show()
        DEFAULT_CHAT_FRAME:AddMessage("|cffFFD100Auto Hide Minimap:|r shown.")
    end
end
