## Why

The prediction surface currently exposes two controls, `by` and `uncertainty`, that overlap. The `by` argument decides which random-effect factors are conditioned on, but for the `posterior_*` generics that information is already carried by the grouping columns present in `newdata`, so `by` is redundant there and has no analogue in the rstantools/brms ecosystem. The redundancy produces a concrete defect: with the default `by = NULL`, `posterior_epred(fit, newdata = NULL)` ignores each observed row's site and simulates new random sites, so it disagrees with `augment()` and `posterior_predict()` (which condition on the observed groups) at the observed data. The `uncertainty = c("marginal", "typical")` value names also describe the statistical concept rather than the action the user is requesting.

## What Changes

- **BREAKING**: Remove `by` and `uncertainty` from the `posterior_epred`, `posterior_linpred`, and `posterior_predict` generics. Conditioning is inferred from the grouping columns present in `newdata` (brms semantics): a grouping column present and matching a known level conditions on it; a factor with no column is handled by `new_levels`.
- **BREAKING**: Rename `uncertainty = c("marginal", "typical")` to `new_levels = c("sample", "average")` on `kb_predict_weight()` and the generics' remaining surface. `"sample"` draws a new random effect from `Normal(0, s)` for factors not represented in the data (was `"marginal"`); `"average"` holds them at their central (zero) value (was `"typical"`). `"sample"` remains the default.
- The notion of `allow_new_levels` (the brms gate permitting unseen group labels) is not introduced: new levels are always available through the `"sample"` path, and conditioned levels are validated by `match_levels()`, so there is no silent-typo exposure to gate.
- `by` survives only on `kb_predict_weight()`, where it is the grid-builder control: it decides which grouping columns the auto-generated grid is expanded over. Once a grid exists, the columns present in it are the conditioning set.
- `newdata = NULL` on the generics now conditions on the observed site and year, so `posterior_epred()`, `posterior_predict()`, and `augment()` agree at the observed data (and `posterior_epred(newdata = NULL)` becomes a valid `bayesplot` input alongside the stored `yrep`).
- `.weight_linpred()` keys conditioning off `names(grid)` rather than a `by` argument, becoming the single place that maps "column present" to "condition on this factor".

## Capabilities

### New Capabilities
<!-- None: no new capability is introduced. -->

### Modified Capabilities
- `predictions`: the "Grouping and uncertainty axes" and "Raw prediction draws via rstantools generics" requirements change. The generics drop `by`/`uncertainty` and infer conditioning from `newdata` columns; the `uncertainty` axis is renamed to `new_levels` with values `c("sample", "average")`; `kb_predict_weight()` retains `by` as its grid control; `newdata = NULL` conditions on observed groups.

## Impact

- API (breaking, pre-1.0, R-universe distribution): `kb_predict_weight()` argument rename `uncertainty` -> `new_levels`; `posterior_epred()` / `posterior_linpred()` / `posterior_predict()` lose `by` and `uncertainty`, gain `new_levels` where they previously took `uncertainty`.
- Code: `R/weight_linpred.R` (`.weight_linpred()`, `weight_grid_linpred()`, `validate_by_weight()`, `re_draw()`), `R/kb_predict_weight.R`, `R/posterior_epred.R`, `R/posterior_linpred.R`, `R/posterior_predict.R`, `R/augment.R`, and the shared `@inheritParams` donor in `R/params.R` (or equivalent). Mirrored tests under `tests/testthat/`.
- Docs: roxygen for the affected functions (the `new_levels` value definitions, in particular the precise meaning of `"average"`), plus `decisions/prediction-engine.md` rationale note. No change to `inst/stan/` (no recompile).
- Consistent with `decisions/prediction-engine.md` (single `.weight_linpred()` source of truth) and the API-simplicity philosophy; no new dependencies.
