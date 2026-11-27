## 1. Column contract (pure, no Stan)

- [x] 1.1 `column_units` keys `diameter_mm`, `weight_kg`, `stipes_m2`; `warn_implausible_units()` and `warn_outside_range()` limits keyed by the new names; tests
- [x] 1.2 Data checks `kb_check_data_weight_*()`, `kb_check_data_size_nereo()`: required and optional columns renamed; the site-year `stipes_m2` conflict check; roxygen states each column's unit and what it measures; tests, including the unsuffixed-name scenario
- [x] 1.3 `new_data` checks (`.chk_new_data_weight_nereo()` and density validation) and density resolution (`density_structure()`, `standardised_density()`, `density_on()`, `.linpred` reads) read `stipes_m2`; messages name `stipes_m2`
- [x] 1.4 `assemble_*_data()` read the renamed columns; Stan data field names unchanged (no `.stan` edit, so no `rstan_config()` / install checkpoint)

## 2. Fit metadata, prediction, and plotting

- [x] 2.1 Fit functions set `meta$response` (`weight_kg`, `diameter_mm`) and `meta$predictor` (`diameter_mm`); `predictor_ref` computed from the renamed column
- [x] 2.2 `kb_predict_weight_by()` *Nereocystis* argument `diameter` to `diameter_mm` (roxygen `@param`, `.chk_wrong_predictor()` message); `build_by_grid()` and returned predictor column follow `meta$predictor`
- [x] 2.3 `kb_plot_predictions()` axis-title lookup keyed by the new names, titles unchanged ("Sub-bulb diameter", "Wet weight")
- [x] 2.4 Sweep for remaining old names in `R/`, `tests/`, `scripts/`, `data-raw/`: quoted strings, `$` access, `aes()` mappings, `@param`/`@format`/`@examples`; update the demo scripts

## 3. Bundled data and fits (MCMC, confirm first)

- [x] 3.1 `data-raw/data_*_sim_*.R` emit the renamed columns; `R/data_*_sim_*.R` `@format` entries updated
- [x] 3.2 `Rscript scripts/build.R --fits` to rebuild `data/fit_*` and `tests/testthat/fixtures/*.rds`
- [x] 3.3 Run the tests; leave changed snapshots (`chk`, `print`, `summary`, `kb_model_describe`, `warn_*`, plots) as `.new` for review, do not accept

## 4. Docs and archive

- [x] 4.1 `devtools::document()`; check roxygen, `_pkgdown.yml`, and specs against the code
- [x] 4.2 CLAUDE.md conventions: measured columns carry a unit suffix (`_mm`, `_kg`, `_m2`), counts and grouping columns do not; add to the README/vignette final-pass checklist (column renames in prose and README.md re-knit); README.Rmd and vignette code chunks updated now so the vignette builds
- [ ] 4.3 `openspec archive rename-unit-columns --yes` in the same PR
