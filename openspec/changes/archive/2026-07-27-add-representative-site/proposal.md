## Why

Predicting weight for a site the model never saw currently offers only
`new_levels = "sample"` (draw a fresh site effect from `Normal(0, sd)`) or
`"average"` (the typical group, effects at zero). Neither lets a user predict an
unsurveyed site *as if it behaves like one or more known reference sites*, which
is the natural ask when a new site is expected to resemble specific surveyed ones
and the user wants those sites' (narrower) posterior uncertainty rather than the
full between-site spread.

## What Changes

- Add `representative_site = NULL` to `kb_predict_weight()` (and its
  `predict.kb_fit_weight()` wrapper) and to `posterior_epred()` /
  `posterior_linpred()` / `posterior_predict()`.
- When non-`NULL` (a character vector of sites present in the fit), any
  new/absent site's **site main effects** (`bSite` intercept and `bSiteDiameter`
  slope) are set to the reference site's estimated effects, or the per-draw
  average across several. `new_levels` continues to govern the `site:year`
  interaction, and remains the sole control when `representative_site = NULL`.
- Validate that supplied sites exist in the fit; error via `cli` otherwise.
- `kb_predict_weight_by()` is unchanged (it walks known levels only).

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `predictions`: the new-data verb and the `rstantools` generics gain a
  `representative_site` axis for resolving new/absent sites.

## Impact

- Engine `R/weight_linpred.R` (`resolve_re1()`, `.weight_linpred()`,
  `weight_data_linpred()`); a shared validator in `R/chk.R`; argument added to
  `R/kb_predict_weight.R`, `R/predict.R`, `R/posterior_epred.R`,
  `R/posterior_linpred.R`, `R/posterior_predict.R`; shared `@param` in
  `R/params.R`. New tests; `man/` + spec regenerated.
- No Stan/model change; pure prediction-engine extension (no recompile).
- Backward compatible: default `NULL` reproduces current behaviour exactly;
  `fitted()`/`residuals()`/`augment()` are unaffected (they call the engine with
  the default).

## Non-goals

- Not added to `kb_predict_weight_by()` (no new-level handling there).
- Does not affect the `site:year` interaction (still governed by `new_levels`).
- No new residual/uncertainty machinery; reuses the existing rvar pipeline.
