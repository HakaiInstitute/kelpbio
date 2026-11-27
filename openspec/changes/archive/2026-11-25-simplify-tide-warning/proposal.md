## Why

The tide correction is explained through a "tide limit" (a tide height of one over `tide_height_slope`) and a warning that fires when a row is past it on more than 5% of draws, or with more than 5% prior probability in the fits.
Users have to follow a posterior or prior share to understand the warning, and every reader-facing surface (methods vignette, roxygen, `kb_model_describe()`, specs) has to explain what happens past the limit.
A fixed recommendation, canopy imaged at tides of 2 m or below, says the same thing more simply: with the default priors the limit is above 3.5 m, and at 2 m the correction already multiplies canopy by about 1.8 (*Macrocystis*) to 2.2 (*Nereocystis*).

## What Changes

- The cover calibration fits, `kb_predict_cover_calibration()`, and `kb_predict_biomass_canopy()` warn when a row with canopy has `canopy_tide_height_m` above 2 m, giving the number of such rows and advising flying at lower tides. This replaces the tide-limit warning and its 5% rule.
- The tide correction, its cap at the plot or classified area, and predictions finite at any tide height are unchanged. What happens past one over the slope is no longer described to users.
- `tide_height_slope` loses its upper bound of 0.5 per metre and keeps its lower bound of 0, so a user's slope prior is fitted as specified; `kb_model_describe()` shows it as `T[0, ]`. The cover calibration pre-fits and fixtures are refitted.
- Reader docs state the correction in one sentence: canopy is corrected to zero tide using the share of canopy lost per metre of tide from Timmer et al. (2024), capped at the plot or classified area, and imagery should be flown at 2 m or below.

## Non-goals

- A change to the correction's form or the default slope priors.
- An error for tide heights above 2 m: chart-datum tides in British Columbia reach about 5 m, and such data stay usable (see the archived `bound-tide-correction` change).
- Warning in the data checks; the warning stays where the tide-limit warning was.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: "Surveys past the tide limit are flagged" becomes a warning for surveys with canopy above 2 m tide.
- `predictions`: "Canopy biomass" and "The tide correction is bounded" drop the tide-limit behaviour; predictions stay finite at any tide height, and rows with canopy above 2 m tide warn.

## Impact

- `R/warn.R` (one fixed-threshold warning replaces the tide-limit warning and its two share helpers), `R/fit_cover_calibration_model.R`, `R/kb_predict_cover_calibration.R`, `R/kb_predict_biomass_canopy.R`.
- `R/kb_fit_cover_calibration_nereo.R` and macro roxygen, `R/kb_model_describe.R` prose and centering line, `vignettes/methods.Rmd`.
- `inst/stan/cover_calibration.stan` (the slope's upper bound), `R/tide.R`, so `--fits=cover_calibration` rebuilds the pre-fits and fixtures, and kelpbiodata's cover calibration reference fits need rebuilding.
- `tests/testthat/test-warn.R` and `_snaps/warn.md`, tide tests in the fit and prediction test files, the `kb_model_describe` snapshot.
