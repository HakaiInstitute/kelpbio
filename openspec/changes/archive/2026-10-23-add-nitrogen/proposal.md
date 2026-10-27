## Why

Biomass is needed in nitrogen as well as wet, dry, and carbon. The analysis project models the nitrogen fraction of dry tissue for both species in the same way as the carbon fraction.

## What Changes

- A nitrogen fraction model for each species: `kb_check_data_nitrogen_nereo()`/`_macro()`, `kb_priors_nitrogen_nereo()`/`_macro()`, `kb_fit_nitrogen_nereo()`/`_macro()`, and `kb_predict_nitrogen()`, with `predict()`, `tidy()`, and the other fit methods. Like carbon, the model is a Beta likelihood on the nitrogen fraction of each dried sample (`nitrogen_mass_ug / 1000 / sample_mass_mg`) with an intercept and a precision, pooled over samples: no site, year, or season effects. The default priors are the analysis project's, Normal(-3.7, 0.5) on the logit intercept and Exponential(0.001) on the precision.
- A warning gives the number of samples whose nitrogen fraction lies outside 0.002 to 0.05, the analysis project's plausibility bounds, and keeps them.
- The derived verbs `kb_predict_mean_weight()`, `kb_predict_biomass_in_situ()`, and `kb_predict_biomass_canopy()` take an optional `nitrogen` fit after `carbon` and `measure = "nitrogen"`: dry biomass times the expected nitrogen fraction, in g per plant or g/m², and kg in total.
- Simulated datasets `data_nitrogen_sim_nereo`/`_macro` and pre-fits `fit_nitrogen_sim_nereo`/`_macro`.

## Non-goals

- No month or season effect, as for carbon: fit the model to one season's samples to estimate that season.
- No blade fraction model (poissonconsulting/kelpbio#15).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: the nitrogen fit, its data check and priors, and the bundled objects.
- `predictions`: `kb_predict_nitrogen()` and the `nitrogen` measure of the derived verbs.
- `summaries`: fitted values, residuals, and checks cover nitrogen fits.

## Impact

- New `inst/stan/nitrogen.stan` (compiled with the package), its R wrappers, data, pre-fits, and test fixtures.
- Shared code gains a `nitrogen` argument (`measure_factor()`, the measure checks, the derived verbs), and `_pkgdown.yml`, `scripts/build.R`, and the fixtures script list the model.
- kelpbioshiny can offer nitrogen once installed; kelpbiodata has no nitrogen reference fit yet.
