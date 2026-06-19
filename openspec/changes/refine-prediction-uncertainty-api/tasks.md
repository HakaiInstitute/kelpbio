## 1. Engine helper (`R/weight_linpred.R`)

- [x] 1.1 Change `.weight_linpred()` to drop the `by` parameter and key conditioning off the grid columns: `site_obs <- "site" %in% names(grid)`, `sy_obs <- all(c("site", "year") %in% names(grid))`; rename the `uncertainty` argument to `new_levels` and pass it to `re_draw()`
- [x] 1.2 Rename `re_draw()`'s switch from `uncertainty == "typical"` to `new_levels == "average"` (zero) with the default `"sample"` drawing from `Normal(0, sd)`
- [x] 1.3 Update `weight_grid_linpred()` to take `new_levels`, `arg_match()` it against `c("sample", "average")`, and call `.weight_linpred(fit, grid, new_levels)` (no `by` passed to the helper)
- [x] 1.4 Update `validate_by_weight()`: keep the invalid-factor and year-alone checks; reword the fully-conditioned guard to fire on `new_levels == "sample"` with `by = c("site", "year")`, pointing the user to `new_levels = "average"`
- [x] 1.5 Confirm `predict_newdata()` (observed data when `newdata = NULL`) is unchanged and now feeds a grid carrying `site`/`year` columns so the generics condition on observed groups

## 2. Public summariser (`R/kb_predict_weight.R`)

- [x] 2.1 Rename the `uncertainty = c("marginal", "typical")` argument to `new_levels = c("sample", "average")`; thread it through `weight_grid_linpred()`
- [x] 2.2 Update the roxygen: describe `by` as the grid-builder control and `new_levels` with the precise `"average"` definition (random effects held at their central/zero value, the typical group on the linear-predictor scale, not the response-scale mean)

## 3. Generics (`R/posterior_epred.R`, `R/posterior_linpred.R`, `R/posterior_predict.R`)

- [x] 3.1 Remove the `by` argument from all three generics; replace `uncertainty` with `new_levels = c("sample", "average")`
- [x] 3.2 Have each generic build the grid from `predict_newdata(object, newdata)` and call `weight_grid_linpred()` so conditioning is inferred from the columns present
- [x] 3.3 Verify `posterior_predict(newdata = NULL)` still returns stored `yrep`, and that `posterior_epred(newdata = NULL)` / `posterior_linpred(newdata = NULL)` now condition on observed groups
- [x] 3.4 Update each generic's roxygen (drop `by`; document `new_levels` and the column-inferred conditioning)

## 4. Augment and shared docs

- [x] 4.1 Update `augment.kb_fit_weight()` to call `.weight_linpred()` with its new signature (grid carries `site`/`year`; no `by`/`uncertainty` args)
- [x] 4.2 Update the shared `@inheritParams` donor (`R/params.R` or equivalent) so `new_levels` (not `uncertainty`) is the documented param; remove the `by` entry from anything the generics inherit
- [x] 4.3 Add a one-line note to `decisions/prediction-engine.md` recording that conditioning is keyed off grid columns and the generics do not take `by`

## 5. Tests (mirrored under `tests/testthat/`)

- [x] 5.1 Update `test-weight_linpred.R`: conditioning follows grid columns; `new_levels = "sample"` widens vs `"average"`; the fully-conditioned-`sample` error fires
- [x] 5.2 Update `test-kb_predict_weight.R` for the `new_levels` rename and the `by`/`new_levels` interaction
- [x] 5.3 Update `test-posterior_epred.R` / `test-posterior_linpred.R` / `test-posterior_predict.R`: no `by` argument; conditioning inferred from `newdata` columns; `newdata = NULL` central estimate agrees with `augment()`; `posterior_predict(newdata = NULL)` returns `yrep`
- [x] 5.4 Update any `cli` message snapshots for the reworded `new_levels` error
- [x] 5.5 Update `test-augment.R` for the helper signature change

## 6. Docs build and verification

- [x] 6.1 `devtools::document()` to regenerate the affected `.Rd` files
- [x] 6.2 Update the demo/vignette and any README usage that calls `uncertainty =` or passes `by` to a generic
- [x] 6.3 Run the mirrored tests for the touched files and confirm green (no Stan recompile required)
