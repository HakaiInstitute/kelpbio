## Context

The prediction engine is built on a single linear-predictor helper, `.weight_linpred()`, surfaced through `kb_predict_weight()`, the three `rstantools` generics, and `augment()` (see `decisions/prediction-engine.md`). Today the random-effect regime is selected by two arguments threaded through all of them: `by` (a character vector of factors to condition on) and `uncertainty = c("marginal", "typical")`.

For `kb_predict_weight()`, `by` earns its place: that function auto-builds a grid and must be told which grouping factors to expand it over. For the generics, the caller supplies `newdata`, so the grouping columns are already present, and `by` only restates which of them to use. This creates two problems. First, the generics carry an argument with no analogue in the rstantools/brms ecosystem, where conditioning is read from the columns of `newdata` plus `re_formula`. Second, the default `by = NULL` makes `posterior_epred(fit, newdata = NULL)` ignore each observed row's site and simulate new sites, so it disagrees with `augment()` and the stored `yrep` from `posterior_predict()` at the observed data. The `marginal`/`typical` value names also describe the statistical concept, not the action.

`.weight_linpred()` currently decides conditioning with `"site" %in% by` (`R/weight_linpred.R:10`), even though, once a grid exists, "is this factor a column of the grid" carries the same information.

## Goals / Non-Goals

**Goals:**
- Make the generics match ecosystem convention: drop `by`, infer conditioning from `newdata` columns, so `newdata = NULL` conditions on observed groups and `posterior_epred` / `posterior_predict` / `augment` agree at the observed data.
- Rename the random-effect regime to an action-oriented enum, `new_levels = c("sample", "average")`, with `"sample"` the default.
- Keep `by` as the grid-builder control on `kb_predict_weight()` only.
- Preserve the single-source-of-truth invariant: one helper still defines the mean, every consumer calls it.

**Non-Goals:**
- No change to the Stan models or any recompile (`inst/stan/` untouched).
- No `allow_new_levels`-style gate, and no third `new_levels` value (e.g. brms's `"old_levels"`); the enum is left extensible but not extended now.
- No change to the biomass composition or the other sub-models (only the weight model exists; the pattern propagates to later models as they land).

## Decisions

**Conditioning is a property of the grid, not a separate argument.** `.weight_linpred()` keys off `names(grid)`: `site_obs <- "site" %in% names(grid)`, `sy_obs <- all(c("site", "year") %in% names(grid))`. This removes the `by` parameter from the helper and unifies the two paths: `kb_predict_weight()` builds a grid with the columns implied by its `by`, the generics receive a grid (the user's `newdata` or the observed data) whose columns are whatever the caller supplied, and in both cases the columns are the conditioning set.

- Alternative considered: keep `by` on the generics and just fix the default to condition. Rejected: it retains a non-ecosystem argument and the `by`-vs-columns redundancy (a `site` column with `by = NULL` would still be ignorable), which is the original footgun.

**`by` remains on `kb_predict_weight()` as grid construction.** `validate_by_weight()` stays, scoped to that function: it rejects invalid factors, rejects `by = "year"` (no year main effect), and rejects the `sample` + fully-conditioned combination. The validation is unchanged except that the `uncertainty == "marginal" && all conditioned` check is reworded for `new_levels == "sample"`.

**`new_levels = c("sample", "average")` replaces `uncertainty = c("marginal", "typical")`.** `"sample"` (default) -> `re_draw()` draws from `Normal(0, s)`; `"average"` -> the random effect is held at zero. The `re_draw()` helper switches on `new_levels` instead of `uncertainty`. Roxygen for `"average"` states the precise meaning: the random effects are held at their central (zero) value, giving the typical (central) group on the linear-predictor scale, not the response-scale arithmetic mean across the group population (the lognormal Jensen gap means those differ).

- Alternative considered: a boolean `sample_new_levels`. Rejected: the `FALSE` branch does not communicate "population-average", and a boolean cannot grow to a third regime; an enum named by the action is self-documenting and extensible.

**`newdata = NULL` semantics differ by entry point, by design.** For the generics, `newdata = NULL` means the observed data (ecosystem convention), now conditioned on observed groups. For `kb_predict_weight()`, `new_data = NULL` means an auto-generated diameter sequence (a forward prediction). These are distinct use-cases sharing one engine; `predict_newdata()` already encodes the generics' convention.

## Risks / Trade-offs

- [Breaking change to a public API] -> Pre-1.0, R-universe distribution (not CRAN), so no deprecation cycle is mandated; the rename and signature change land together. Callers and the demo/vignette are updated in the same change; tests pin the new signatures.
- [`newdata = NULL` now conditions instead of marginalizing, changing `posterior_epred(fit)` output] -> This is the intended fix (the previous behaviour was the defect); the spec scenario "newdata = NULL conditions on the observed groups" pins it and asserts agreement with `augment()`.
- [A user passes `newdata` with a partial grouping (e.g. `site` but not `year`)] -> Well-defined: condition on `site`, apply `new_levels` to the site:year factor. Covered by the "Conditioning inferred from newdata columns" scenario.
- [Silent miscondition if a grouping column is misnamed in `newdata`] -> A misnamed column is simply absent, so the factor falls to `new_levels`; a present-but-unknown level still errors via `match_levels()`. No new silent path.
- [Pattern must stay consistent as later sub-models add their own `_linpred` helpers] -> The "condition on columns present" rule is model-agnostic and documented here and in `decisions/prediction-engine.md`; later models follow it.
