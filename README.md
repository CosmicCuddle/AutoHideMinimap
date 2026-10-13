# Auto Hide Minimap

A lightweight World of Warcraft **3.3.5a** addon for automatically hiding the minimap after login, with full manual control.

## Current development version

**1.3.0 (proposed, not yet released)**

The latest published version remains **1.2.0** until the changes are reviewed and released.

## New: Optional automatic hiding

Go to **Esc → Interface → AddOns → Auto Hide Minimap** and choose:

- **Automatically hide the minimap at login** — enabled by default, matching v1.2.0.
- **Disabled** — leave the minimap alone when you log in.
- **Show / Hide Minimap Now** — a manual toggle button that works regardless of the auto-hide setting.

The checkbox is saved per WoW account in `WTF/Account/<account>/SavedVariables/AutoHideMinimap.lua` (the variable is `AutoHideMinimapDB`). Your preference persists through logout, login and `/reload`.

When enabled, automatic hiding runs for the first **8 seconds** after login or `/reload`, checking every **0.25 seconds** in case other addons restore the minimap. After those 8 seconds, Auto Hide Minimap stops interfering.

Turning automatic hiding **OFF** immediately stops the startup checks. Turning it **ON** begins its hiding window on the **next login or `/reload`**, not immediately; this avoids undoing a manual choice. Using `/ahm` manually also stops the remaining startup checks.

## Slash commands

| Command | Action |
| --- | --- |
| `/ahm` | Show or hide the minimap **now** (unchanged from 1.2.0) |
| `/ahm auto` | Toggle automatic hiding ON/OFF |
| `/ahm auto on` | Save automatic hiding as ON |
| `/ahm auto off` | Save automatic hiding as OFF |
| `/ahm status` | Display current minimap visibility and auto-hide setting |
| `/ahm options` | Open the Interface AddOns settings page |

No slash command automatically switches your persisted option unless it explicitly mentions `auto`.

## Installation / safe updating

1. Fully close World of Warcraft.
2. **Back up** `Interface/AddOns/AutoHideMinimap` and, if it exists, `WTF/Account/<account>/SavedVariables/AutoHideMinimap.lua`.
3. Replace only the addon folder with the reviewed build.
4. Start WoW and choose your preferred auto-hide setting in Interface → AddOns or use `/ahm auto off`.

The folder should contain:

```text
Interface/
└── AddOns/
    └── AutoHideMinimap/
        ├── AutoHideMinimap.toc
        └── AutoHideMinimap.lua
```

Do **not** delete the SavedVariables file when upgrading, because it stores your chosen setting.

## Compatibility and testing

- WoW **3.3.5a**, Interface `30300`, Lua **5.1**
- No Ace libraries or other addon dependencies
- Automated mocked WoW UI regression tests in `tests/test_autohide.lua`
- A final in-game check is required before merging/releasing changes

## Credits

Created by **CosmicCuddle** for World of Warcraft 3.3.5a.

World of Warcraft and related names, artwork and assets are trademarks or copyrights of Blizzard Entertainment. This project is not affiliated with or endorsed by Blizzard Entertainment.
