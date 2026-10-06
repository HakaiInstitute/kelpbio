## MODIFIED Requirements

### Requirement: Fitted values, residuals, and augment

`fitted()` SHALL return the posterior median of the expected response at each observed row (weight, size, the dry:wet ratio, the carbon fraction, for density the expected count on that row's transect area, or for cover the expected wet biomass per m² of that row's plot), and `residuals()` the posterior median of the deviance residual under the model's likelihood. `augment()` SHALL return the input data with `fitted` and `residual` columns equal to those values, and no interval columns added.

#### Scenario: augment agrees with fitted and residuals
- **WHEN** `augment(fit)` is called on a weight, size, density, wet/dry, carbon, or cover biomass fit
- **THEN** its `fitted` and `residual` columns equal `fitted(fit)` and `residuals(fit)`

#### Scenario: augment keeps the in situ biomass of a cover biomass fit
- **WHEN** `augment(fit)` is called on a cover biomass fit
- **THEN** it returns the fitted surveys with their paired `estimate`, `lower`, and `upper` columns unchanged

### Requirement: Print and summary

`print(fit)` SHALL show a header with the model and species, the predictor and its reference value (for a model with a predictor), the observation count and any group counts, the sampler settings, the convergence verdict, and a prior-only note when applicable, followed by a pointer to `kb_model_describe()`, with no parameter estimates. `summary(fit)` SHALL return an object whose print shows the same header, a table of `term`, `estimate`, `lower`, `upper`, `rhat`, `ess_bulk`, and `ess_tail` (per-level effects only with `include_random_effects = TRUE`), and a footer with the divergence rate, treedepth-saturation rate, and minimum E-BFMI. The output is pinned by `tests/testthat/_snaps/print.md` and `tests/testthat/_snaps/summary.md`.

#### Scenario: print shows no estimates
- **WHEN** `print(fit)` is called
- **THEN** it shows the header and no parameter estimates

#### Scenario: A size fit has no predictor line
- **WHEN** `print()` is called on a size fit
- **THEN** the header has no predictor line

#### Scenario: A density fit has no predictor line
- **WHEN** `print()` is called on a density fit
- **THEN** the header has no predictor line, since the area is an offset rather than a predictor

#### Scenario: A cover biomass fit has no predictor line
- **WHEN** `print()` is called on a cover biomass fit
- **THEN** the header has no predictor line, since cover is derived from the canopy, plot, and tide columns rather than supplied

#### Scenario: A wet/dry fit has no predictor or group line
- **WHEN** `print()` is called on a wet/dry fit whose data have no `site` or `year` column
- **THEN** the header shows the observation count with no predictor or group counts

### Requirement: Errors for unsupported objects

A kelpbio generic (`kb_model_describe()`, `kb_stancode()`, `samples()`, `kb_predict_weight()`, `kb_predict_weight_by()`, `kb_predict_size()`, `kb_predict_size_by()`, `kb_predict_density()`, `kb_predict_density_by()`, `kb_predict_wetdry()`, `kb_predict_carbon()`, `kb_predict_cover_biomass()`, `kb_predict_cover_biomass_by()`) called on an object it does not support SHALL error with a `cli` message naming the argument and the required class (`kb_fit`, or the model class such as `kb_fit_weight`, `kb_fit_size`, `kb_fit_density`, `kb_fit_wetdry`, `kb_fit_carbon`, or `kb_fit_cover_biomass` for the prediction verbs) and pointing to the `kb_fit_*()` functions, attributed to the generic the user called. Any method called on a fit whose model has no implementation for it SHALL error naming the object's class rather than return a value. kelpbio SHALL NOT add default methods to generics owned by other packages.

#### Scenario: A non-fit errors helpfully
- **WHEN** `kb_model_describe(1)` or `kb_predict_weight(1)` is called
- **THEN** it errors stating the required class and pointing to the fitting functions

#### Scenario: A fit of the other model errors
- **WHEN** `kb_predict_density()` is called on a weight or size fit, or `kb_predict_weight()` on a density fit
- **THEN** it errors stating the required model class

#### Scenario: A fit without methods fails loudly
- **WHEN** `log_lik()`, `residuals()`, `fitted()`, or `augment()` is called on a fit whose model has no methods
- **THEN** it errors rather than returning a value
