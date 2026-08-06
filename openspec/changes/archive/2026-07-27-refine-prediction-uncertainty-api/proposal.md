## Why

A demo test-drive of the weight model showed the prior column-inference design was confusing (a grid-builder like `xnew_data` silently switched on conditioning, so `new_levels` was ignored) and that erroring on unknown levels forced a clumsy bind pattern for the common "new site" case. It also surfaced concrete bugs (an HTML progress popup, `nthin` default 10, no facet cap) and the need for real data. The fix is a two-verb prediction API with independent arguments, per-row level resolution, and the review bug fixes.

## What Changes

- **BREAKING**: Split prediction into two verbs with independent arguments (tidyverse argument independence; the `fct_lump_n`/`fct_lump_prop` precedent), so `by` and `new_data` can never collide:
  - `kb_predict_weight(fit, new_data, new_levels, ...)` + `predict()` - predict at supplied rows (or observed data when `new_data = NULL`, matching base R). No `by`.
  - `kb_predict_weight_by(fit, by, new_levels, diameter, ...)` - the curve summary over a diameter sequence. No `new_data`.
- **Per-row level resolution** in `.weight_linpred()`: known level → condition; new level → drawn per `new_levels`; absent column → `new_levels`. A new level no longer errors, so a mix of known and new sites resolves in one call (no bind pattern). The `rstantools` generics inherit this.
- `new_levels = c("sample", "average")`, default `"sample"`, governs every random effect that can't be conditioned (uniform across both verbs and the generics).
- `augment()` stays a diagnostics verb (unchanged).
- **Fix**: `nthin` default 1 (was 10); `open_progress = FALSE` (kills the URL popup and restores console progress with `quiet = FALSE`); `max_facets` cap on `kb_plot_predictions()`.
- **Data**: `kb_data_weight` becomes the real Hakai allometry data; a small simulated set is retained in test fixtures.
- This is the **cross-model contract** (recorded in `decisions/prediction-engine.md`): bare verb + `_by` where there are grouping factors; scalar models get only the bare verb; size deferred.

## Capabilities

### New Capabilities
<!-- None. -->

### Modified Capabilities
- `predictions`: the two-verb split, per-row resolution, no-error-on-new-levels, `new_levels` semantics.
- `fitting`: `nthin` default 1; `open_progress = FALSE` / console progress.
- `plotting`: `max_facets` panel cap.
- `data`: `kb_data_weight` is real Hakai data; simulated set kept for fixtures.

## Impact

- API (breaking, pre-1.0, R-universe): new export `kb_predict_weight_by()`; `by` removed from `kb_predict_weight()` / `predict()` / the generics; `kb_predict_weight(NULL)` now returns observed-data predictions.
- Code: `R/weight_linpred.R`, `R/kb_predict_weight.R`, `R/kb_predict_weight_by.R` (new), `R/predict.R`, `R/posterior_*.R`, `R/kb_plot_predictions.R`, `R/kb_fit_weight.R`, `R/params.R`, `data-raw/kb_data_weight.R`, `data/kb_data_weight.rda`, fixtures, mirrored tests, `decisions/prediction-engine.md`, `scripts/demo-weight-prediction.R`.
- No `inst/stan/` change (no recompile).
