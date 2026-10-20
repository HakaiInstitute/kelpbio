## 1. Tide correction in R

- [x] 1.1 `tide_corrected_canopy()` takes the cap: per draw, positive canopy with `1 - tide_height_slope * tide_height_m <= 0` returns the cap, otherwise `min(canopy / (1 - s * t), cap)`; zero canopy returns 0. Works for numeric and rvar slopes.
- [x] 1.2 `tide_corrected_cover()` passes the plot area as the cap; `canopy_biomass_draws()` passes `classified_area_m2`.
- [x] 1.3 Tests in `test-tide_corrected_canopy.R` and `test-tide_corrected_cover.R`: 0, 2, 3.5, and 5 m, a negative tide, zero canopy past the limit, and continuity just below and above `1 / s`.

## 2. classified_area_m2

- [x] 2.1 Rename `site_area_m2` to `classified_area_m2` in `R/` (`column_units.R`, `chk.R`, `vld.R`, `warn.R`, `canopy_biomass_draws.R`), and make it required in the canopy `new_data` check (`> 0`, at least `canopy_area_m2`, no missing values).
- [x] 2.2 Update `data-raw/data_sim_nereo.R` and `data-raw/data_sim_macro.R` to write `classified_area_m2`; rebuild `data/data_canopy_sim_*.rda` (no MCMC); update `R/data.R`.
- [x] 2.3 Update tests (`test-chk.R`, `test-vld.R`, `test-warn.R`, `test-column_units.R`, `test-data.R`, `test-canopy_biomass_draws.R`, `test-kb_predict_biomass_canopy.R`): a missing `classified_area_m2` errors; every row is capped.

## 3. Tide-limit warning

- [x] 3.1 Add `warn_tide_cap()`, `tide_cap_share()` (slope draws), and `tide_cap_prior_share()` (truncated Normal prior) in `R/warn.R`: one warning giving the number of rows past the tide limit on more than 5% of the slope's distribution.
- [x] 3.2 Call it from `kb_predict_cover_calibration()` and `kb_predict_biomass_canopy()` (posterior draws) and the cover calibration fit (prior).
- [x] 3.3 Tests in `test-warn.R` (snapshot of the message), the verbs' tests, and the fit test (stubbed sampler); ordinary tides do not warn.

## 4. Stan model

- [x] 4.1 In `inst/stan/cover_calibration.stan`, cover is 1 for positive canopy when `1 - tide_height_slope * tide_height_m <= 0`, 0 for zero canopy, else the current capped value; update the header comment.
- [x] 4.2 `rstantools::rstan_config()`, then `devtools::install()` (checkpoint: `load_all()` does not re-transpile Stan).
- [x] 4.3 Test that `log_lik()` at a survey past the tide limit is finite and equals the log-likelihood at full cover (fixture draws, no MCMC).

## 5. Docs and specs

- [x] 5.1 Roxygen: the tide correction and its cap, and that canopy already corrected for tide is passed with `tide_height_m = 0`, in `kb_fit_cover_calibration_*()`, `kb_predict_cover_calibration()`, and `kb_predict_biomass_canopy()`; `classified_area_m2` in the canopy `new_data`; the 2 m warning; `@references` Timmer et al. (2024), doi:10.3389/fenvs.2024.1338483.
- [x] 5.2 Update the demo scripts and `decisions/architecture.md` for `classified_area_m2`.
- [x] 5.3 `devtools::document()`; check the delta specs and reader docs against the code.

## 6. Pre-fits and fixtures (MCMC, confirm before running)

- [x] 6.1 `Rscript scripts/build.R --fits=cover_calibration` rebuilds the cover calibration pre-fits and fixtures, since the Stan source changed.
- [x] 6.2 Run the test suite; leave changed snapshots for review.

## 7. Archive

- [x] 7.1 `openspec archive bound-tide-correction --yes` once CI passes.
