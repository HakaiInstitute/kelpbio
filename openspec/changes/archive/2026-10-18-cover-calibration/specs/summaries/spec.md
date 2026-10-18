## MODIFIED Requirements

### Requirement: Errors for unsupported objects

A kelpbio function taking a fit (`kb_model_describe()`, `kb_stancode()`, `kb_samples()`, `kb_converged()`, and `kb_influence()`, the prediction verbs `kb_predict_weight()`, `kb_predict_size()`, `kb_predict_wetdry()`, `kb_predict_carbon()`, and `kb_predict_cover_calibration()`, the derived verbs `kb_predict_mean_weight()`, `kb_predict_biomass_survey()`, and `kb_predict_biomass_canopy()`, `kb_new_data()`, and `kb_sensitivity()`) called on an object it does not support SHALL error with a `cli` message naming the argument and the required class (`kb_fit`, or the model class such as `kb_fit_weight`, `kb_fit_size`, `kb_fit_wetdry`, `kb_fit_carbon`, or `kb_fit_cover_calibration` for the prediction verbs) and pointing to the `kb_fit_*()` functions, attributed to the function the user called. Any method called on a fit whose model has no implementation for it SHALL error naming the object's class rather than return a value. kelpbio SHALL NOT add default methods to generics owned by other packages.

#### Scenario: A non-fit errors helpfully
- **WHEN** `kb_model_describe(1)` or `kb_predict_weight(1)` is called
- **THEN** it errors stating the required class and pointing to the fitting functions

#### Scenario: A fit of the other model errors
- **WHEN** `kb_predict_size()` is called on a weight fit, or `kb_predict_weight()` on a size fit
- **THEN** it errors stating the required model class

#### Scenario: A fit without methods fails loudly
- **WHEN** `log_lik()`, `residuals()`, `fitted()`, `augment()`, or `kb_sensitivity()` is called on a fit whose model has no methods
- **THEN** it errors rather than returning a value

### Requirement: Fitted values, residuals, and augment

`fitted()` SHALL return the posterior median of the expected response at each observed row (weight, size, the dry:wet ratio, the carbon fraction, or for the cover calibration the expected wet biomass per m² of that row's plot), and `residuals()` the posterior median of the deviance residual under the model's likelihood. `augment()` SHALL return the input data with `fitted` and `residual` columns equal to those values, and no interval columns added.

#### Scenario: augment agrees with fitted and residuals
- **WHEN** `augment(fit)` is called on a weight, size, wet/dry, carbon, or cover calibration fit
- **THEN** its `fitted` and `residual` columns equal `fitted(fit)` and `residuals(fit)`

#### Scenario: augment keeps the survey biomass of a cover calibration fit
- **WHEN** `augment(fit)` is called on a cover calibration fit
- **THEN** it returns the fitted surveys with `biomass_kg_m2`, the mean of each survey's biomass draws, and `biomass_sd_kg_m2`, their SD

### Requirement: Print and summary

`print(fit)` SHALL show a header with the model and species, the predictor and its reference value (for a model with a predictor), the observation count and any group counts, the sampler settings, the convergence verdict, and a prior-only note when applicable, followed by a pointer to `kb_model_describe()`, with no parameter estimates. `summary(fit)` SHALL return an object whose print shows the same header, a table of `term`, `estimate`, `lower`, `upper`, `rhat`, `ess_bulk`, and `ess_tail` (per-level effects only with `include_random_effects = TRUE`), and a footer with the divergence rate, treedepth-saturation rate, and minimum E-BFMI. The output is pinned by `tests/testthat/_snaps/print.md` and `tests/testthat/_snaps/summary.md`.

#### Scenario: print shows no estimates
- **WHEN** `print(fit)` is called
- **THEN** it shows the header and no parameter estimates

#### Scenario: A size fit has no predictor line
- **WHEN** `print()` is called on a size fit
- **THEN** the header has no predictor line

#### Scenario: A cover calibration fit has no predictor line
- **WHEN** `print()` is called on a cover calibration fit
- **THEN** the header has no predictor line, since cover is derived from the canopy, plot, and tide columns rather than supplied

#### Scenario: A wet/dry fit has no predictor or group line
- **WHEN** `print()` is called on a wet/dry fit whose data have no `site` or `year` column
- **THEN** the header shows the observation count with no predictor or group counts

### Requirement: Posterior predictive check

`pp_check(object, type = c("response", "residual"), ..., ndraws = 50)` SHALL be available after `library(kelpbio)` for any fit and SHALL return a `ggplot` overlaying the density of the observed values on the densities of `ndraws` replicate datasets, each simulated at the observed rows from one posterior draw chosen at random. With `type = "response"` the values SHALL be the recorded response (weight, size, dry:wet ratio, carbon fraction, or a survey's biomass per m²), and the x-axis SHALL be titled with it. With `type = "residual"` the observed values SHALL be `residuals(object)`, each replicate's values SHALL be the deviance residuals of that replicate under the draw that generated it, and the x-axis SHALL be titled "Deviance residual". Repeated calls SHALL differ unless a seed is set. `ndraws` SHALL be a whole number from 1 to the number of draws in the fit, and `...` SHALL be empty. A fit with no observations SHALL error.

#### Scenario: Response check by default
- **WHEN** `pp_check(fit)` is called
- **THEN** it returns a `ggplot` with the observed response and 50 replicate datasets, and the x-axis titled with the response

#### Scenario: Calibration replicates hold zeros
- **WHEN** `pp_check(fit)` is called on a cover calibration fit
- **THEN** the replicate surveys are censored at zero as the data are, and the x-axis is titled with the wet biomass per m²

#### Scenario: Residual check
- **WHEN** `pp_check(fit, "residual")` is called
- **THEN** the observed values equal `residuals(fit)` and the x-axis is titled "Deviance residual"

#### Scenario: Number of replicates
- **WHEN** `pp_check(fit, ndraws = 10)` is called
- **THEN** the plot holds 10 replicate datasets

#### Scenario: Reproducible under a seed
- **WHEN** `pp_check()` is called twice with the same seed
- **THEN** the replicate values are identical

#### Scenario: Invalid ndraws
- **WHEN** `ndraws` is not a whole number or exceeds the fit's number of draws
- **THEN** it errors naming `ndraws`

#### Scenario: No observations
- **WHEN** `pp_check()` is called on a fit with no observations
- **THEN** it errors
