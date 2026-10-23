## Why

`tide_height_m` sits on the in situ survey rows next to the dive's own columns, so it reads as the tide during the dive. It is the tide when the canopy imagery was taken, which may be from a drone or from other remote sensing.

## What Changes

- The column `tide_height_m` becomes `canopy_tide_height_m` in the in situ survey, canopy map, and cover calibration data, in `new_data` for `kb_predict_cover_calibration()` and `kb_predict_biomass_canopy()`, and in `kb_new_data()` grids.
- Reader docs describe it as the tide height when the canopy was imaged, and say "canopy imagery" rather than "flight".
- The bundled in situ survey and canopy datasets carry the new column name, and the cover calibration pre-fits and fixtures are refitted, since the Stan data field passes the column through under its name.

## Non-goals

- The parameter `tide_height_slope` and its prior entry keep their names: parameters take no unit suffix and the name still describes the slope on tide height.
- No change to the tide correction, its cap, or the warnings, apart from the column name.
- kelpbiodata and kelpbioshiny are updated in their own repositories.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: input data, plausibility warnings, and the tide limit warning name the renamed column.
- `predictions`: the cover calibration verb, prediction grids, new data validation, canopy biomass, and the bounded tide correction name the renamed column.

## Impact

- `inst/stan/cover_calibration.stan` (data field renamed; a refit of the cover calibration pre-fits and fixtures, `--fits=cover_calibration`).
- R code and roxygen reading the column, `column_units`, the warnings, `data-raw/`, `data/data_in_situ_sim_*` and `data/data_canopy_sim_*`, tests, snapshots, `decisions/`, the demo script, and `.claude/STYLE.md`.
- kelpbiodata's Hakai cover calibration reference fits need rebuilding; kelpbioshiny's sheets and calls use the old name.
