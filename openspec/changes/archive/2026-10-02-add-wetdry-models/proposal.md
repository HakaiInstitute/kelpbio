## Why

Biomass is estimated as wet weight, and dry and carbon biomass follow from it by the
dry:wet mass ratio, so kelpbio needs a wet/dry model for each species. The analysis
project's production models are a Beta likelihood on the dry:wet ratio of lab
samples, with a month random effect on the logit mean, identical for both species.

## What Changes

- New fit functions `kb_fit_wetdry_nereo()` and `kb_fit_wetdry_macro()`, with
  `kb_check_data_wetdry_nereo()`, `kb_check_data_wetdry_macro()`,
  `kb_priors_wetdry_nereo()`, and `kb_priors_wetdry_macro()`, following the other
  sub-models' data-check, prior, sampler, progress, and fit-object behaviour.
- Input data are one row per sample: `wet_mass_g` and `dry_mass_g` (g, > 0), with
  `dry_mass_g` less than `wet_mass_g`. Samples with a ratio outside 0.02 to 0.5
  raise a warning and are kept. Other columns are ignored.
- The ratio `dry_mass_g / wet_mass_g` follows a Beta distribution with logit mean
  `bDryWet` and precision `bPrecision`, common to all samples. There are no random
  effects: the analysis month effect is dropped, and samples are pooled over the
  months, sites, and tissues they come from. A season-specific ratio is estimated
  by fitting to that season's samples.
- Default priors match the analysis: `intercept` Normal(0, 2) on the logit scale and
  `precision` Exponential(0.01).
- New prediction verb `kb_predict_wetdry(fit)`, plus `predict()`, returning the
  expected dry:wet ratio as one row. The model has nothing to vary by row or group,
  so there is no `_by` verb and no `new_data`.
- Every existing `kb_fit` method works on wet/dry fits.
- `wet_mass_g` and `dry_mass_g` join the implausible-unit warning.
- Bundled `data_wetdry_sim_nereo`, `data_wetdry_sim_macro`,
  `fit_wetdry_sim_nereo`, and `fit_wetdry_sim_macro`, with test fixtures.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: the fit, input data, priors, data-determined effects, bundled objects,
  and implausible-unit requirements gain the wet/dry models.
- `predictions`: the prediction verbs cover a model with a single population
  estimate; the expected-value generics and new-data validation cover wet/dry.
- `summaries`: fitted values, the print header, and the unsupported-object errors
  cover wet/dry.

## Non-goals

- A month, site, year, or tissue effect, or a tissue-specific precision.
- Plotting the single-row prediction.
- Carbon or nitrogen fractions, and the biomass composition.

## Impact

- New: `inst/stan/wetdry.stan`, shared by both species (recompiled at install), one
  file per new exported function, simulated data and fits under `data/` and
  `data-raw/`, and test fixtures.
- Methods registered at the `kb_fit_wetdry` tier, since the species are
  structurally identical; no change to the other models' numbers or outputs.
- `print.md`, `summary.md`, `kb_model_describe.md`, and `chk.md` snapshots gain
  wet/dry cases.
- `_pkgdown.yml` gains the wet/dry functions. README and vignette updates are
  deferred until all sub-models are in place.
