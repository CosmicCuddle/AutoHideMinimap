# Auto Hide Minimap v1.3.0

**World of Warcraft 3.3.5a (Interface 30300) · Lua 5.1**

This release adds an optional, remembered **Automatically hide the minimap at login** setting without taking away the existing manual show/hide control.

## What's new

- **Auto-hide ON/OFF checkbox:** Esc → Interface → AddOns → Auto Hide Minimap.
- **Manual button:** **Show / Hide Minimap Now** works regardless of the auto-hide setting.
- **Saved preference:** your auto-hide choice persists across logins and `/reload` with account-wide `AutoHideMinimapDB` SavedVariables.
- **Backwards-compatible default:** auto-hide starts **ON** for existing installs that have no saved option, preserving v1.2.0 behaviour.
- **Instant OFF:** turning automatic hiding off ends any active startup hiding checks. Turning it on begins automatic hiding on the **next login or `/reload`**, so the addon does not unexpectedly reverse a deliberate manual toggle.
- **Original `/ahm` still works:** show/hide the minimap manually at any time.

## Commands

| Command | Purpose |
| --- | --- |
| `/ahm` | Manually show or hide the minimap |
| `/ahm auto` | Toggle the saved auto-hide option |
| `/ahm auto on` | Enable auto-hide for the next login or `/reload` |
| `/ahm auto off` | Disable automatic hiding |
| `/ahm status` | Show minimap visibility and auto-hide setting |
| `/ahm options` | Open addon settings |

## How auto-hide works

When auto-hide is enabled, the addon hides the minimap during the first **eight seconds after login**, including repeated checks if another addon re-shows it. It stops adjusting the minimap afterward, or immediately when you manually toggle it. When disabled, it does not automatically hide the minimap.

## Installation / updating

1. **Fully exit World of Warcraft.**
2. Back up your existing `Interface/AddOns/AutoHideMinimap` folder and (if present) `WTF/Account/<account>/SavedVariables/AutoHideMinimap.lua`.
3. Download **AutoHideMinimap-v1.3.0.zip** under the release **Assets**.
4. Extract the `AutoHideMinimap` directory into `Interface/AddOns/`, replacing only the old addon files.
5. Launch WoW; open **Interface → AddOns → Auto Hide Minimap**, or type `/ahm status`.

The ZIP contains **only** `AutoHideMinimap/AutoHideMinimap.lua` and `AutoHideMinimap/AutoHideMinimap.toc`. Do not delete or distribute personal SavedVariables.

## Validation

- **89 Lua 5.1 automated assertions** passed, covering ON/OFF, persistence, manual toggling, 3.3.5a options API and startup behaviour.
- Installable ZIP structure, version and SHA-256 integrity checks passed.
- The owner installed the review build in WoW and reported the new controls work correctly, including **auto-hide OFF surviving `/reload` and leaving the minimap visible**.
- These are focused checks, not certification of all third-party UI addon interactions.

**Compatibility:** WoW 3.3.5a / Interface 30300 / Lua 5.1. Standalone; no other addon dependencies.

[Repository](https://github.com/CosmicCuddle/AutoHideMinimap) · [Changelog](https://github.com/CosmicCuddle/AutoHideMinimap/blob/main/CHANGELOG.md)

_N-Addon-Collection is deliberately not updated as part of this release._
