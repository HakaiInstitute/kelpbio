## 1. Rename

- [x] 1.1 Rename `tide_height_m` to `canopy_tide_height_m` in R code, the Stan data block, `data-raw/`, tests, `decisions/`, and the demo script.
- [x] 1.2 Re-save the bundled in situ survey and canopy datasets with the renamed column.
- [x] 1.3 Reword "tide height at the flight" and "flight" in reader docs; update the canopy map row in `.claude/STYLE.md`.
- [x] 1.4 `rstantools::rstan_config()`; `Rscript scripts/build.R --fits=cover_calibration`; review snapshot diffs.
- [x] 1.5 `openspec archive rename-canopy-tide --yes`.
