## Why

The analysis project (`hakai-kelp-biomass-25`, `decisions/cover-count-calibration.md`,
approach C) now calibrates drone cover on the biomass the divers' surveys hold:
plants counted per m² times their wet weight, with the count treated as a census
of the area searched. The density models and the *Macrocystis* size model are
gone from it, since the calibration no longer needs a modelled plot density, and
totals moved little (*Nereocystis* +11%, *Macrocystis* +2%). kelpbio still
regresses cover on modelled plot biomass from the density, size, and weight fits,
so its calibration, its prediction surface, and much of its internal machinery
describe a model the analysis no longer uses.

## What Changes

- **BREAKING** Remove the density models (`kb_fit_density_*()`,
  `kb_priors_density_*()`, `kb_check_data_density_*()`, `kb_predict_density()`,
  `predict()` for density fits) and the *Macrocystis* size model
  (`kb_fit_size_macro()`, `kb_priors_size_macro()`, `kb_check_data_size_macro()`).
- **BREAKING** Replace `kb_predict_plot_biomass()` with
  `kb_predict_biomass_survey(weight, size, survey)`: the biomass of each in situ
  survey from its plants, with sizes modelled by a size fit (plants tallied) or
  taken from a table of every counted plant (a census). New inputs: a `survey`
  table and a `plants` table, checked by `kb_check_data_survey()`,
  `kb_check_data_plants_nereo()`, and `kb_check_data_plants_macro()`.
- **BREAKING** Rename the cover biomass model to the cover calibration model
  (`kb_fit_cover_calibration_*()`, `kb_priors_cover_calibration_*()`,
  `kb_check_data_cover_calibration_*()`, `kb_predict_cover_calibration()`). The
  fit takes one data frame, the survey biomass with each survey's drone cover on
  its row, and the model is linear on the natural scale with a censored Normal
  likelihood whose SD combines a constant, a part proportional to the mean, and
  each survey's weight uncertainty. The tide correction divides canopy by
  (1 - slope × tide). `error_scaling` and the `conf_level` of the in situ limits
  go.
- **BREAKING** Rename `kb_predict_site_biomass()` to
  `kb_predict_biomass_canopy()`, with the new tide correction and a `per_area`
  switch.
- Add `kb_predict_mean_weight(weight, size)`: the expected weight per plant of a
  site-year from the weight and size fits.
- The derived verbs (`kb_predict_mean_weight()`, `kb_predict_biomass_survey()`,
  `kb_predict_biomass_canopy()`) carry their response as a column of posterior
  draws next to the summary, and share `sum_by`, `per_area`, `measure`, and
  `new_levels = "sample"` where they apply.
- **BREAKING** *Nereocystis* counts are `plants`, not `stipes`, for both species.
- **BREAKING** Weight and size data take `date` in place of `year` (the year is
  derived), as the survey and plant data do; size data may carry `plot_id`.
- The grouping argument of the biomass verbs is `pool_by`: kg are summed, and
  per area divided by the summed area.
- Estimates are scoped to the peak season at site-year resolution; several plots
  per site-year and several surveys per plot are allowed.
- Bundled data and pre-fits follow: survey, plants, and canopy datasets replace
  the density, size macro, cover survey, and plot biomass datasets.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: the list of models, input data and checks, priors, effects, bundled
  objects, and unit warnings; the cover calibration's inputs.
- `predictions`: the prediction verbs and grids, draws and likelihood for the
  cover calibration, plot labels, and the derived verbs (survey biomass, mean
  weight, canopy biomass) replacing plot and site biomass; the recorded
  interval level goes.
- `summaries`: fitted values and `augment()`, print, `pp_check()`, and the
  unsupported-object errors no longer mention density, and name the renamed
  model and verbs.

## Non-goals

- No change to the weight, *Nereocystis* size, wet/dry, or carbon models.
- No sub-year period, survey date window, or flight-to-dive gap warning; `date`
  keys surveys only.
- No site:year effect in the cover calibration (a follow-up once replicated
  plots support it).
- No mean weight from a census plant table, and no counted density output.
- No external calibration response other than a column of draws.
- README and vignette rewrites wait for the pending docs pass, except the one
  definition of "plant".

## Impact

- Stan: `inst/stan/cover_biomass.stan` becomes `cover_calibration.stan`;
  `density_nereo.stan`, `density_macro.stan`, and `size_macro.stan` are removed
  (`rstan_config()`, install, and every pre-fit and fixture rebuilt).
- Removes the rate-model offset, the count and zero-truncated families, the
  in situ log-SD and interval-level machinery, the cover join, and the size
  dispatch used only by *Macrocystis* (listed in `design.md`).
- `decisions/prediction-engine.md`, `decisions/architecture.md`,
  `decisions/species-as-variant.md`, `decisions/parameter-naming.md`,
  `decisions/intermediate-predictions.md`, and CLAUDE.md are updated;
  `decisions/transect-calibration-plan.md` is folded into `design.md` and removed.
- kelpbioshiny needs a follow-up (fit queue, mocks, sheets, help text).
