# Auto Hide Minimap

A lightweight World of Warcraft 3.3.5a addon that automatically hides the minimap shortly after logging in while still allowing it to be shown or hidden manually afterwards.

## Current Version

**Version 1.2.0**

Supported client:

**World of Warcraft 3.3.5a**

## Features

- Automatically hides the minimap after logging in.
- Continues checking for a short period after login in case the game or another addon shows the minimap again.
- Stops interfering after the startup period so the minimap can still be controlled manually.
- Includes a simple slash command for showing or hiding the minimap at any time.
- Does not require any saved settings or configuration.

## How It Works

For the first few seconds after logging in, the addon checks whether the minimap is visible and hides it when necessary.

After this short startup period finishes, the addon stops automatically changing the minimap. This means you can show or hide it normally without the addon immediately hiding it again.

Using the manual toggle command during the startup period also stops the automatic hiding immediately.

## Command

Use:

`/ahm`

This toggles the minimap between shown and hidden.

When used, the addon will display a short chat message confirming whether the minimap was shown or hidden.

## Installation

1. Download the latest release.
2. Extract the archive.
3. Copy the `AutoHideMinimap` folder into:

   `World of Warcraft/Interface/AddOns/`

4. Restart World of Warcraft or use `/reload`.
5. The minimap will automatically be hidden shortly after logging in.

The installed folder should look like:

```text
World of Warcraft
└── Interface
    └── AddOns
        └── AutoHideMinimap
            ├── AutoHideMinimap.toc
            └── AutoHideMinimap.lua
```

## Updating

When updating to a newer version, replace the existing `AutoHideMinimap` folder with the new one.

## Credits

Created by **CosmicCuddle** for World of Warcraft 3.3.5a.

World of Warcraft and related names, artwork and assets are trademarks or copyrights of Blizzard Entertainment.

This project is not affiliated with or endorsed by Blizzard Entertainment.
