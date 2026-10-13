# Auto Hide Minimap — Development handover

**Development track:** `feature/persistent-auto-hide-toggle` (v1.3.0, unmerged/unreleased)

**Current `main` baseline:** v1.2.0 — unconditional 8-second login hide plus `/ahm` manual toggle.

## Scope and behavior

The owner requested a choice whether to **automatically hide at login**, while **keeping manual minimap visibility toggling**. The feature must remain small, standalone, Lua 5.1 / WoW 3.3.5a compatible.

- Default **ON**, so updating preserves existing v1.2.0 behavior.
- Account-wide saved preference: `AutoHideMinimapDB.autoHideEnabled`, stored in WoW's own SavedVariables by the `.toc`.
- Interface Options → AddOns → Auto Hide Minimap: a checkbox plus an immediate manual Show/Hide button.
- `/ahm` retains its existing manual toggling behavior and always cancels the remainder of automatic startup hiding.
- New optional slash setting `/ahm auto on|off`; `/ahm auto` flips the preference. `/ahm status` and `/ahm options` are read-only convenience commands.
- OFF takes effect immediately and stays saved; ON starts auto-hiding after the **next login or /reload** so it does not unexpectedly hide the minimap the player deliberately showed.
- With auto-hide ON: hide every 0.25 sec during the first eight seconds after login, then stop, matching old behavior.
- If Interface Options APIs aren't available, slash commands still work.

## Boundaries

- Do not change unrelated UI, Naxxramas Core modules, other addons, or global minimap behavior when auto-hide is disabled.
- No auto-publishing GitHub Actions, tags, or releases from this branch.
- Preserve user choices and other SavedVariables fields. Back up the addon folder and any SavedVariables file before replacing on a live client.
- AddOn does **not** save manual visibility; the preference controls *only the login automatic hiding*.

## Verification

`lua5.1 tests/test_autohide.lua` provides mock WoW API regression coverage for default ON, OFF, relog persistence, UI/command switches, startup cancellation, fallback slash commands and preservation of existing manual minimap control. `luac5.1 -p` validates syntax.

`python3 scripts/build_review_zip.py` builds a deterministic, **review-only** ZIP with exactly `AutoHideMinimap/AutoHideMinimap.toc` and `AutoHideMinimap/AutoHideMinimap.lua`, plus a SHA256SUMS file. GitHub Actions may attach it as a workflow artifact; it does not create a release.

## Remaining acceptance

- [ ] Automated Lua 5.1 suite and review ZIP both pass on **current branch HEAD**.
- [ ] Owner installs review ZIP on a backed-up WoW 3.3.5a client and checks `/ahm`, checkbox ON/OFF, and remembered state across `/reload`.
- [ ] Owner separately approves merging the draft PR.
- [ ] Owner separately approves a published v1.3.0 GitHub release (if desired).
- [ ] Keep N-Addon-Collection unchanged until the owner finishes their other addons.
