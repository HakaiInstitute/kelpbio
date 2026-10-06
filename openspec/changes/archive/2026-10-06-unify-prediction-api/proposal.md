## Why

Each sub-model has a row-wise verb and a `_by` verb, but the line between them is
drawn differently per model: at supplied predictor values versus curves for weight,
at site/year rows versus per group for size, and a transect count versus a density
per m² for density. The default `new_levels` also flips between the two. A user who
learns one model cannot predict what another returns, and every new sub-model
(cover biomass next) adds another pair. The split was designed around weight, the
one model with a continuous predictor (`decisions/prediction-engine.md`,
"Cross-model prediction contract").

## What Changes

- **BREAKING** Every `kb_predict_<model>(fit, new_data = NULL)` returns the
  expected response at the rows of `new_data`, or at the observed data when
  `new_data = NULL`, in the model's natural quantity. The verbs keep their
  model names.
- **BREAKING** `kb_predict_weight_by()`, `kb_predict_size_by()`, and
  `kb_predict_density_by()` are removed, without deprecation. A new
  `kb_new_data(fit, by = NULL, ...)` builds the rows they used to: one per fitted
  site, year, or observed site-year named in `by`, crossed with a sequence of the
  species predictor for weight (`diameter_mm` or `fronds`, named in `...`,
  defaulting to 30 values over the observed range). Group predictions become
  `kb_predict_weight(fit, kb_new_data(fit, by = "site"))`.
- **BREAKING** `kb_predict_density()` always returns density per m² (`stipes_m2`
  or `plants_m2`) and does not read `area_m2`. The draw generics
  (`posterior_epred()`, `posterior_linpred()`, `posterior_predict()`) read an
  optional `area_m2` column, defaulting to 1 m², so transect counts come from
  `posterior_predict()`.
- **BREAKING** One `new_levels` default, `"average"`, for every prediction verb,
  `predict()`, and the draw generics. `"sample"` stays available to include
  between-group variation. `kb_predict_plot_biomass()` keeps `"sample"`: its rows
  are particular surveyed site-years, not the typical site.
- Calling a verb with `by =`, or with a character vector of grouping factors in
  place of `new_data`, errors with the equivalent `kb_new_data()` call.
- `kb_plot_predictions()` draws a line with a ribbon for predictions made at a
  `kb_new_data()` grid over a varying predictor, and point ranges otherwise.
- The `predict()` methods stay, as thin wrappers over each verb.
- Internal simplification with no user-visible effect: the prediction verbs
  become plain functions instead of single-method S3 generics, the internal mean
  helpers work on posterior `rvar`s only, and the unused unit attributes on
  `kb_predictions` objects are removed.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `predictions`: "Two prediction verbs" is replaced by one verb per model plus a
  grid builder; group resolution, density resolution, draws, plotting, and
  validation take the single `new_levels` default and the per-m² density.
- `summaries`: "Errors for unsupported objects" no longer describes the
  prediction verbs as generics.

## Non-goals

- Generic, dispatching prediction verbs (`kb_predict()`); the verbs stay
  model-named for legibility at the call site.
- Convenience `_by` wrappers. They can be added later without breaking code, as
  exact one-line wrappers over `kb_new_data()`.
- Changes to the models, the fitted draws, the summary arguments
  (`conf_level`, `estimate`, `sig_fig`), `representative_site`, or `max_facets`.
- Paging large faceted plots across several plots.
- The README and vignette final pass: only the calls this change breaks are
  updated.

## Impact

- R: the prediction verbs, `predict()` methods, draw generics, the grid and
  summary helpers, `kb_plot_predictions()`, and a new `R/kb_new_data.R`; the
  `_by` verb files and their tests are removed. No Stan or fit-structure change,
  so no pre-fit or fixture rebuild.
- Tests and snapshots: most prediction tests, and the error and plot snapshots.
- Docs: roxygen, `_pkgdown.yml`, the demo scripts, and the README and vignette
  calls; `decisions/prediction-engine.md` (cross-model contract and offset
  paragraphs) is rewritten.
- kelpbioshiny: its `_by` calls and mocks move to `kb_new_data()` (separate repo).
- The cover biomass branch rebases onto this change and adds
  `kb_predict_cover_biomass()` in the new shape, with `cover` as the grid's
  predictor.
