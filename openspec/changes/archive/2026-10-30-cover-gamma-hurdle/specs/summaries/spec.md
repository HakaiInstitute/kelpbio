## MODIFIED Requirements

### Requirement: Omitted effects are not reported

An effect the fit omitted (the weight floor of a power-law fit, the presence part of a cover calibration fitted without an empty survey) SHALL NOT appear in `tidy()`, `coef()`, `summary()`, or `kb_model_describe()`, since its draws never met the data.

#### Scenario: An omitted effect is absent
- **WHEN** a fit omitted the floor term
- **THEN** its terms appear in none of `tidy()`, `summary()`, or `kb_model_describe()`, including under `include_random_effects = TRUE`

### Requirement: Posterior predictive check

`pp_check(object, type = c("response", "residual"), ..., ndraws = 50)` SHALL be available after `library(kelpbio)` for any fit and SHALL return a `ggplot` overlaying the density of the observed values on the densities of `ndraws` replicate datasets, each simulated at the observed rows from one posterior draw chosen at random. With `type = "response"` the values SHALL be the recorded response (weight, size, dry:wet ratio, carbon or nitrogen fraction, or a survey's biomass per m²), and the x-axis SHALL be titled with it. With `type = "residual"` the observed values SHALL be `residuals(object)`, each replicate's values SHALL be the deviance residuals of that replicate under the draw that generated it, and the x-axis SHALL be titled "Deviance residual". Repeated calls SHALL differ unless a seed is set. `ndraws` SHALL be a whole number from 1 to the number of draws in the fit, and `...` SHALL be empty. A fit with no observations SHALL error.

#### Scenario: Response check by default
- **WHEN** `pp_check(fit)` is called
- **THEN** it returns a `ggplot` with the observed response and 50 replicate datasets, and the x-axis titled with the response

#### Scenario: Calibration replicates hold zeros
- **WHEN** `pp_check(fit)` is called on a cover calibration fit
- **THEN** the replicate surveys hold zeros where the fit has a presence part, and the x-axis is titled with the wet biomass per m²

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
