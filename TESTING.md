Testing instructions for physcomod

Overview

This file explains quick steps to verify that defaults are centralized in `defaults.lua`, that Reset/Save flow uses the canonical functions, and how to validate the Structural Integrity Scanner settings and behavior during playtesting.

1) Confirm centralized defaults apply on Reset

- In Teardown, open the mod options and press the "IBSIT v2" page (top-right button).
- Click the "Reset" button.
- Expected: `ApplyDefaultSettings()` will run and apply canonical defaults from `defaults.lua`.
  - You should see the debug print string "ApplyDefaultSettings: setting canonical defaults" in the Teardown console or game log when defaults are applied.

Notes: Teardown prints from Lua appear in the in-game console (`~`) and in the game's log files (e.g., `output_log.txt`).

2) Verify Scanner settings are centralized

- After reset, open the IBSIT v2 page and check the Scanner controls (cell size, iterations, factor, pad, threshold, auto-break toggle, cooldown, legend/numbers, max breaks per tick).
- Change a scanner value (for example, change Cell Size), press "Save".
- Close and re-open the options menu (or quit and re-load) and verify the changed value persisted.
- Alternatively, use the in-game Lua console to manually query registry keys, e.g.:

  -- In the game's Lua console
  print(GetFloat("savegame.mod.combined.scanner_cell"))
  print(GetInt("savegame.mod.combined.scanner_iter"))
  print(GetBool("savegame.mod.combined.scanner_autobreak"))

3) Validate scanner behavior (visual, no auto-break)

- In `TEST` scenarios, set `scanner_autobreak` OFF first and use the scanner visuals to inspect structural stress.
- Open a scene with structures (bridges, buildings) and enable the Structural Scanner tool.
- Expected: The scanner draws colored debug boxes and numeric stress values on bodies; it sets tags on bodies (`scanner_stress`, `scanner_center`, `scanner_last`) but does not immediately create holes while `scanner_autobreak` is off.
- If you enable `scanner_autobreak` (and tune threshold/cooldown), the main runtime (IBSIT) will consume the tags and trigger material-aware collapses.

4) If defaults don't apply or values are missing

- If you don't see the DebugPrint message when pressing Reset, ensure `defaults.lua` is included by `options.lua` and `main.lua` (the mod's scripts already include it). You can also call `ApplyDefaultSettings()` manually from the in-game Lua console:

  pcall(ApplyDefaultSettings)

- If scanner settings appear missing, run the same `print(GetFloat(...))` checks above to confirm keys exist.

5) Repo quick sanity check (developer)

- I ran a repo search for `scanner_` keys. Findings:
  - Canonical scanner default writes live in `defaults.lua`.
  - Scanner UI reads/writes keys via the options UI and save paths in `options.lua` and `main.lua`.
  - There are no remaining fallback Set* initializers in `options.lua.resetSettings()`; centralization is complete.

Next steps (if you'd like me to continue)

- Remove duplicate persistence `Set*` lines from `options.lua.saveSettings()` so the UI strictly defers saving to `SaveAllSettings()` in `main.lua` (low risk but reversible).
- Add a tiny automated in-mod test that toggles `scanner_autobreak` and reports counts of `scanner_stress` tags to validate the breaking flow.

If you want one of the next steps, tell me which and I'll implement it.
