## Why

Carbon biomass is dry biomass times the carbon fraction of dry mass, so kelpbio
needs a carbon model for each species. The analysis project's production models are
a Beta likelihood on the carbon fraction of lab samples, with a month random effect
on the logit mean, identical for both species.

## What Changes

- New fit functions `kb_fit_carbon_nereo()` and `kb_fit_carbon_macro()`, with
  `kb_check_data_carbon_nereo()`, `kb_check_data_carbon_macro()`,
  `kb_priors_carbon_nereo()`, and `kb_priors_carbon_macro()`, following the wet/dry
  models.
- Input data are one row per sample, as the isotope lab reports them:
  `sample_mass_mg` and `carbon_mass_ug`. The response is the carbon fraction,
  `carbon_mass_ug / 1000 / sample_mass_mg`, which must be below 1. Samples with a
  fraction outside 0.10 to 0.50 raise a warning and are kept. Other columns are
  ignored.
- The carbon fraction follows a Beta distribution with logit mean `bCarbon` and
  precision `bPrecision`, common to all samples, with no random effects (the
  analysis month effect is dropped, as for wet/dry).
- Default priors match the analysis: `intercept` Normal(-0.8, 0.3) on the logit
  scale and `precision` Exponential(0.001).
- New prediction verb `kb_predict_carbon(fit)`, plus `predict()`, returning the
  expected carbon fraction as one row.
- Bundled `data_carbon_sim_nereo`, `data_carbon_sim_macro`, `fit_carbon_sim_nereo`,
  and `fit_carbon_sim_macro`, with test fixtures.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: the fit, input data, priors, data-determined effects, and bundled
  objects requirements gain the carbon models.
- `predictions`: the prediction verbs, the predictive draws, and new-data
  validation cover carbon.
- `summaries`: fitted values and the unsupported-object errors cover carbon.

## Non-goals

- A month, site, year, or tissue effect.
- The nitrogen fraction model, which the analysis also has.
- Plotting the single-row prediction, and the biomass composition.

## Impact

- New: `inst/stan/carbon.stan`, shared by both species, one file per new exported
  function, simulated data and fits, and test fixtures.
- The Beta likelihood, residual, and predictive draws used by wet/dry move to shared
  helpers so both models call one implementation; no change to wet/dry numbers.
- `print.md`, `kb_model_describe.md`, and `chk.md` snapshots gain carbon cases.
- `_pkgdown.yml` gains the carbon functions; README and vignette deferred.
