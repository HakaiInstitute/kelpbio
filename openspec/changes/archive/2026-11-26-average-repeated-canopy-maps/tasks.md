## 1. Canopy pooling

- [x] 1.1 In `R/biomass.R`, let `pool_draws_by()` average the rows of each site-year within a group before summing (an argument used by the canopy verb only); add tests in `tests/testthat/test-biomass.R` for two maps of one site-year (mean by site and year, mean plus other sites by year), a group key that separates the maps, and no repeated maps (unchanged sums)
- [x] 1.2 Use it in `kb_predict_biomass_canopy()` and remove `warn_overlapping_canopy()` and its test and snapshot
- [x] 1.3 Add a warning in `R/warn.R` for maps of a site-year whose largest `classified_area_m2` exceeds 1.5 times the smallest; call it from `kb_predict_biomass_canopy()` and `kb_check_data_survey_canopy()`; test it, including the no-warning case, with the message snapshotted in `tests/testthat/_snaps/warn.md`

## 2. Bar plots

- [x] 2.1 In `R/kb_plot_predictions.R`, dodge columns and intervals that share an x value within a panel, keeping single rows at full width
- [x] 2.2 Add vdiffr snapshots for unpooled canopy biomass with several maps of a site-year and unpooled in situ biomass with several surveys of a site-year

## 3. Documentation

- [x] 3.1 Split the `pool_by` text in `R/params.R`: keep the shared part (columns, `character(0)`, `NULL`) and move each verb's rule to its own roxygen
- [x] 3.2 `kb_predict_biomass_canopy()`: the averaging rule in `pool_by` and `@details`, that each row maps the whole site, and the new warning in place of the overlap warning; `kb_check_data_survey_canopy()` details likewise
- [x] 3.3 `kb_predict_biomass_in_situ()`: a pooled per-area value weights each survey by its area, and a pooled total with `per_area = FALSE` counts a resurveyed plot once per survey
- [x] 3.4 `vignettes/methods.Rmd` "Total biomass": the standing-stock rationale and that pooled totals never sum maps of one site-year

## 4. Check and archive

- [x] 4.1 `Rscript scripts/build.R` and `jarl check .`; report snapshot changes without accepting them
- [x] 4.2 Check the specs and reader docs against the code, then `openspec archive average-repeated-canopy-maps --yes`
