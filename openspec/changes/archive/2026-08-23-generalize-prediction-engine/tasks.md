## 1. Shared prediction helpers

- [x] 1.1 `R/summarise_predictions.R`: rename from `summarise_weight_predictions()`, take `response` and `predictor` from `meta`, drop the `%||% "diameter"` fallback
- [x] 1.2 `R/validate_by.R`: `validate_by(fit, by)` plus the `.chk_by()` internal generic, its terminal-abort default and both species methods; the *Nereocystis* message kept verbatim
- [x] 1.3 `R/build_by_grid.R`: move, split out `predictor_grid()` and `by_grid()`, tolerate a `NULL` predictor and a grid with neither predictor nor grouping
- [x] 1.4 `R/by_linpred.R`: rename from `weight_by_linpred()`, check `.chk_kb_fit` rather than `.chk_kb_fit_weight`
- [x] 1.5 Update both prediction verbs to call the renamed helpers

## 2. Fit constructor

- [x] 2.1 `R/new_kb_fit.R`: `new_kb_fit(core, data, priors, model, species, prior_only, nthin, meta_extra)`, class tiers from `model` and `species`, model not stored in `meta`
- [x] 2.2 Both weight fit functions call it with `model = "weight"`; delete `new_kb_fit_weight()`

## 3. Offset

- [x] 3.1 `R/offset.R`: `.offset()` generic, terminal-abort default, `.offset.kb_fit_weight` returning `0`
- [x] 3.2 `offset = TRUE` argument on `.linpred_obs()` and `data_linpred()`, applied to the `rvar` so it broadcasts over grid rows

## 4. Incidental fixes found on the way

- [x] 4.1 `fit_stan()`: `as.character()` on the `get_stancode()` capture, dropping the temp-file `model_name2` attribute
- [x] 4.2 `DESCRIPTION`: `dplyr (>= 1.1.0)`, already required by `cross_join()`
- [x] 4.3 `openspec/config.yaml`: `rhat = 1.05` corrected to the `1.01` the code uses
- [x] 4.4 `decisions/prediction-engine.md`, `CLAUDE.md`: the `newdata::xnew_data` grid claim was never implemented; record `build_by_grid()` and the offset instead

## 5. Tests

- [x] 5.1 New mirroring files for each moved or new source file
- [x] 5.2 Moved-function tests leave `test-kb_predict_weight_by.R`
- [x] 5.3 `test-abort.R`: the internal-generic discovery test `4d3e374` described but did not add, pinning both the aborting set and the one deliberately total default
- [x] 5.4 Full suite green, no snapshot changes

## 6. Proof and close-out

- [x] 6.1 Tolerance-zero comparison against the installed pre-refactor build, 47 quantities over both fixtures; table recorded in `design.md`
- [x] 6.2 `dispatch-errors` spec delta: `.offset` and `.chk_by` added, the `.fit_descriptor` exception named
- [x] 6.3 `decisions/architecture.md` updated to the current symbols
- [x] 6.4 Sync and archive
