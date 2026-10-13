# Changelog

## Unreleased — 1.3.0 (proposed)

- Add a saved **Automatically hide the minimap at login** option in Interface → AddOns.
- Preserve existing automatic hiding as the default for older installations.
- Add an in-options **Show / Hide Minimap Now** button and preserve the original `/ahm` manual toggle.
- Add `/ahm auto`, `/ahm auto on`, `/ahm auto off`, `/ahm status`, and `/ahm options`.
- Turning auto-hide off immediately ends startup hiding; turning it on starts on the next login or reload.
- Add Lua 5.1 automated tests without changing unrelated WoW UI components.

## 1.2.0

- During the first eight seconds after login, repeatedly hide the minimap to counter addons that show it again.
- Stop adjusting the minimap after startup, or immediately when `/ahm` is used manually.
- Support `/ahm` to toggle the minimap on demand.
