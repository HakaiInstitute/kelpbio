## Why

Site-year biomass totals for site-years without a dive survey come from drone
canopy imagery, through a calibration of in situ biomass on canopy cover. kelpbio
needs that calibration for each species. The analysis project's production models
(`models-cover-{nereo,macro}.R`, `stan/{nereo,macro}/cover/cover-offset.stan`) are
linear in tide-corrected cover with a biomass floor, fitted to per-survey in situ
biomass estimates weighted by their precision, and identical in form for both
species.

## What Changes

- New fit functions `kb_fit_cover_biomass_nereo()` and `kb_fit_cover_biomass_macro()`, with
  `kb_check_data_cover_biomass_nereo()`, `kb_check_data_cover_biomass_macro()`,
  `kb_priors_cover_biomass_nereo()`, and `kb_priors_cover_biomass_macro()`.
- Two inputs: `data`, one row per drone survey, with `canopy_area_m2` (canopy
  delineated in the plot, m², `>= 0`), `plot_area_m2` (plot area, m², `> 0`, at
  least `canopy_area_m2`), `tide_height_m` (tide height at the survey, m, chart
  datum), `site`, and `year`; and `biomass`, the in situ wet biomass (kg/m²) of
  each site-year as `estimate`, `lower`, and `upper`, so the output of a biomass
  prediction passes in unchanged. The fit is `kb_fit_cover_biomass_*(data, biomass,
  priors = NULL, ...)`. Surveys are paired with their site-year's biomass, and
  surveys with none are dropped with a message. The interval level comes from the
  `kb_predictions` object, else a name-only `conf_level`, else 0.95. Other columns
  are ignored.
- `kb_predictions` objects record their `conf_level`.
- The model: `log(estimate) ~ Normal(log(mu), bScaling * sd_log)`, where `sd_log`
  is the log-scale SD implied by `lower` and `upper`; `mu = bFloor + bCanopy *
  exp(bSite + bYear) * cover`, and `cover` is the canopy area corrected to a
  reference tide by `bTide`, divided by the plot area and capped at 1. Site and
  year effects, never a site:year effect.
- Default priors match the analysis, including the species-specific floor and tide
  priors.
- New prediction verbs `kb_predict_cover_biomass(fit, new_data)`, plus `predict()`, giving
  the expected wet biomass (kg/m²) of a plot from `canopy_area_m2`, `plot_area_m2`, and
  `tide_height_m`, and `kb_predict_cover_biomass_by(fit, by)`, giving curves of expected
  wet biomass over tide-corrected cover by group.
- Bundled `data_cover_biomass_sim_nereo`, `data_cover_biomass_sim_macro`,
  `data_plot_biomass_sim_nereo`, `data_plot_biomass_sim_macro`, `fit_cover_biomass_sim_nereo`,
  and `fit_cover_biomass_sim_macro`, with test fixtures.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: the fit, input data, data-determined effects, priors, bundled
  objects, and implausible-unit requirements gain the cover biomass models.
- `predictions`: the prediction verbs, per-row group resolution, the predictive
  draws, and new-data validation cover cover.
- `summaries`: fitted values, print, and the unsupported-object errors cover
  cover.

## Non-goals

- Site-year biomass totals from mapped canopy area (`kb_predict_site_biomass()`),
  which take a cover biomass fit and canopy areas and follow the biomass composition.
- A site:year effect, a free cover exponent, a Student-t likelihood, or
  clumpiness covariates, all comparison arms in the analysis.
- Modelling the correlation between the in situ biomass estimates.

## Impact

- New: `inst/stan/cover_biomass.stan`, shared by both species, one file per new exported
  function, simulated data and fits, and test fixtures.
- `posterior_predict()`'s internal noise generic gains the prediction rows, since
  the cover biomass noise depends on each row's in situ precision; no change to other
  models' draws.
- `print.md`, `kb_model_describe.md`, and `chk.md` snapshots gain cover cases.
- `_pkgdown.yml` gains the cover biomass functions; README and vignette deferred.

## Note

Rebased onto `unify-prediction-api` before merging: `kb_predict_cover_biomass_by()`
became `kb_predict_cover_biomass(fit, kb_new_data(fit, by, cover = ))`, and the
verb's default `new_levels` became `"average"`. The current behaviour is in
`openspec/specs/predictions/spec.md`.
