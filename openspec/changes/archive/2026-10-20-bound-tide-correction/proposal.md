## Why

The cover calibration corrects drone canopy for tide as `canopy_area_m2 / (1 - tide_height_slope * tide_height_m)`, the inverse of the per-bed linear regressions of Timmer et al. (2024). The denominator reaches zero at a tide of `1 / tide_height_slope` (2 to 4 m for the default prior) and is negative above it, so the fit, `kb_predict_cover_calibration()`, and `kb_predict_biomass_canopy()` give infinite or negative biomass at tide heights that are routine on chart datum in British Columbia. With the bundled *Nereocystis* fit, a 100 m² canopy at 4 m gives a median total of -4090 kg. Nothing stops or flags such input: tide heights are only checked to be finite, and the plausibility warning looks at the median.

## What Changes

- The tide correction keeps the linear form, and past `1 / tide_height_slope` takes its cap, the limit the corrected canopy reaches as the denominator falls to zero: cover of 1 in the cover calibration fits and `kb_predict_cover_calibration()`, and the classified area in `kb_predict_biomass_canopy()`. Totals are finite and non-negative at any tide height.
- **BREAKING** `kb_predict_biomass_canopy()` renames `site_area_m2` to `classified_area_m2` and requires it: the water area within the site that the canopy classification covered, including water where no canopy was found. It caps every row's tide-corrected canopy. The simulated canopy datasets rename the column.
- A warning gives the number of rows whose result is set by the cap rather than the canopy measured: rows past the tide limit on more than 5% of the slope's draws in `kb_predict_cover_calibration()` and `kb_predict_biomass_canopy()`, and surveys past it with more than 5% prior probability in the cover calibration fits. The docs advise flying at 2 m or below, and a higher slope prior for beds in strong current.
- The cover calibration fits and `kb_predict_biomass_canopy()` cite Timmer et al. (2024), and say that canopy already corrected for tide is passed with `tide_height_m = 0`, which leaves it uncorrected.

## Non-goals

- A different functional form for the correction (log-linear or logistic): the linear form is the published one, and no data identify the shape above 2 m.
- A current-speed term, or a site-varying tide slope.
- The kelpbioshiny changes the rename implies.
- The analysis project, whose flights are all at or below 2.0 m.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: the implausible-units requirement renames `site_area_m2`; a new requirement flags surveys past the tide limit.
- `predictions`: the canopy biomass requirement requires `classified_area_m2` and caps every row; a new requirement bounds the tide correction past `1 / tide_height_slope` in every cover calibration prediction and flags rows past the limit.

## Impact

- `inst/stan/cover_calibration.stan` (the cap), so `--fits=cover_calibration` rebuilds the pre-fits and fixtures.
- `R/tide_corrected_canopy.R`, `R/tide_corrected_cover.R`, `R/canopy_biomass_draws.R`, `R/kb_predict_biomass_canopy.R`, `R/kb_predict_cover_calibration.R`, the cover calibration fit and data check topics, `R/chk.R`, `R/vld.R`, `R/warn.R`, `R/column_units.R`.
- `data-raw/data_sim_*.R` and `data/data_canopy_sim_*.rda`; `R/data.R`.
- Tests and snapshots for the tide correction, the canopy verb, and the warnings.
