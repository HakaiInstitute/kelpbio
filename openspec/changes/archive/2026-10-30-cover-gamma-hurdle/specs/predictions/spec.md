## MODIFIED Requirements

### Requirement: Draws, likelihood, and priors

`posterior_epred()`, `posterior_linpred()`, and `posterior_predict()` SHALL return a draws-by-rows matrix for `new_data` (or the observed data), resolving groups as above. `posterior_epred()` SHALL give the expected response. Where that differs from the inverse link of the linear predictor, `posterior_linpred(transform = TRUE)` SHALL return the inverse link:

- *Nereocystis* weight, whose log weight is Normal: the expected weight is `exp(mu + sd_residual^2 / 2)`, above the median `exp(mu)`.
- Cover calibration with a presence part: the expected biomass is the probability that the plot holds plants times the Gamma mean `mu`.

The cover calibration's likelihood SHALL be a Gamma with mean `mu` and a coefficient of variation combining a residual part and the survey's coefficient of variation from plant weight. Totals over canopy SHALL use `mu`, at full cover.

The prediction verbs, `fitted()`, and `augment()` SHALL summarise `posterior_epred()`. `posterior_predict()` SHALL add observation noise from the model's likelihood, so repeated calls differ unless a seed is set; for size it draws plant sizes; for wet/dry, carbon, and nitrogen it draws ratios or fractions between 0 and 1; for the cover calibration it draws biomass per m² of at least 0, zero at the rate of absence where the fit has a presence part, each row's spread including its survey's coefficient of variation from plant weight, from `biomass_kg_m2` and `biomass_sd_kg_m2` columns or a `biomass_kg_m2` column of draws, and none when `new_data` has neither. `log_lik()` SHALL return the deterministic pointwise log-likelihood of the observed data, suitable for `loo::loo()`, and error for a fit with no observations. Each value SHALL be the log density of the recorded response on its recorded scale (weight in kg, diameter in mm, a ratio or fraction, or a survey's biomass per m², a survey with none taking the log probability that the plot holds no plants), including the Jacobian where the model's likelihood is stated on a transformed scale, so the pointwise log-likelihoods of two models of the same response are comparable. `log_lik()`, `residuals()`, and `posterior_predict()` SHALL use the same observation distribution, and it SHALL be the distribution of the fitted Stan model. `prior_summary()` SHALL return the priors used.

#### Scenario: Expected weight exceeds the median for Nereocystis
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Nereocystis* weight rows
- **THEN** each draw of the former equals the latter times `exp(sd_residual^2 / 2)`

#### Scenario: Calibration replicates are never negative
- **WHEN** `posterior_predict()` is called on a cover calibration fit
- **THEN** every draw is at least 0

#### Scenario: Calibration replicates without a survey biomass SD
- **WHEN** `posterior_predict()` is called on a cover calibration fit with `new_data` lacking `biomass_kg_m2`
- **THEN** it returns draws whose spread is the residual alone, narrower than with `biomass_kg_m2` and `biomass_sd_kg_m2` columns

#### Scenario: The presence part scales the expected biomass but not totals
- **WHEN** `posterior_epred()` is called on a cover calibration fit with a presence part
- **THEN** each draw equals `posterior_linpred(transform = TRUE)` times that draw's probability that the plot holds plants, and `kb_predict_biomass_canopy()` is unchanged by it

#### Scenario: Predictive draws are reproducible under a seed
- **WHEN** `posterior_predict()` is called twice after the same `set.seed()`
- **THEN** it returns identical draws

#### Scenario: Log-likelihood is on the recorded scale
- **WHEN** `log_lik()` is called on a *Nereocystis* weight fit
- **THEN** each value equals the log density of the Normal on log weight minus the log of that row's `weight_kg`

#### Scenario: Log-likelihood agrees with the Stan model
- **WHEN** `log_lik()` is summed over the observed rows for each draw of any fit
- **THEN** it differs from the Stan model's log density with the likelihood, minus the same log density without it, by an amount that is the same for every draw
