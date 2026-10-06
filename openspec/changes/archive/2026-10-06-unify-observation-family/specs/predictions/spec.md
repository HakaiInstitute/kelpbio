## MODIFIED Requirements

### Requirement: Draws, likelihood, and priors

`posterior_epred()`, `posterior_linpred()`, and `posterior_predict()` SHALL return a draws-by-rows matrix for `new_data` (or the observed data), resolving groups and density as above. For a density fit, each row SHALL be a transect of its `area_m2`, or of 1 m² when `new_data` has no `area_m2` column, and the observed data SHALL use their recorded areas. `posterior_epred()` SHALL give the expected response. Where that differs from the inverse link of the linear predictor, `posterior_linpred(transform = TRUE)` SHALL return the inverse link:

- *Nereocystis* weight, whose log weight is Normal: the expected weight is `exp(mu + sWeight^2 / 2)`, above the median `exp(mu)`.
- *Macrocystis* size, whose frond count is a zero-truncated negative binomial: the expected count is the truncated mean, above the untruncated mean `exp(mu)`.
- *Nereocystis* density, whose stipe count is a zero-inflated negative binomial: the expected count is `(1 - zi) * exp(mu)`, below the mean of a transect holding stipes, `exp(mu)`, where `zi` is the zero-inflation probability.

For cover biomass, whose residual is the in situ estimation error rather than variation in biomass, the expected biomass is the inverse link, `exp(mu)`.

The prediction verbs, `fitted()`, and `augment()` SHALL summarise `posterior_epred()`; the density verb at 1 m². `posterior_predict()` SHALL add observation noise from the model's likelihood, so repeated calls differ unless a seed is set; for size it draws plant sizes, and *Macrocystis* draws are whole numbers of at least 1; for density it draws transect counts, whole numbers of at least 0; for wet/dry and carbon it draws ratios or fractions between 0 and 1; for cover biomass it draws positive in situ biomass estimates, with each row's precision taken from its `lower` and `upper`, which `new_data` SHALL then carry. `log_lik()` SHALL return the deterministic pointwise log-likelihood of the observed data, suitable for `loo::loo()`, and error for a fit with no observations. Each value SHALL be the log density of the recorded response on its recorded scale (weight in kg, diameter in mm, a count, a ratio or fraction, or an in situ biomass estimate), including the Jacobian where the model's likelihood is stated on a transformed scale, so the pointwise log-likelihoods of two models of the same response are comparable. `log_lik()`, `residuals()`, and `posterior_predict()` SHALL use the same observation distribution, and it SHALL be the distribution of the fitted Stan model. `prior_summary()` SHALL return the priors used.

#### Scenario: Expected weight exceeds the median for Nereocystis
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Nereocystis* weight rows
- **THEN** each draw of the former equals the latter times `exp(sWeight^2 / 2)`

#### Scenario: Expected frond count exceeds the untruncated mean
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Macrocystis* size rows
- **THEN** each draw of the former is greater than the latter and at least 1

#### Scenario: Expected stipe count includes zero inflation
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Nereocystis* density rows
- **THEN** each draw of the former equals the latter times one minus that draw's zero-inflation probability

#### Scenario: Expected counts scale with area
- **WHEN** `posterior_epred()` is called on a density fit at the same site and year with `area_m2` of 10 and of 20
- **THEN** each draw of the second is twice the first

#### Scenario: Density draws default to one square metre
- **WHEN** `posterior_epred()` is called on a density fit with `new_data` lacking `area_m2`
- **THEN** it equals the same call with `area_m2 = 1`, and its summary equals `kb_predict_density()` at those rows

#### Scenario: Cover predictive draws need the in situ limits
- **WHEN** `posterior_predict()` is called on a cover biomass fit with `new_data` lacking `lower` or `upper`
- **THEN** it errors naming the missing columns

#### Scenario: Predictive draws are reproducible under a seed
- **WHEN** `posterior_predict()` is called twice after the same `set.seed()`
- **THEN** it returns identical draws

#### Scenario: Log-likelihood is on the recorded scale
- **WHEN** `log_lik()` is called on a *Nereocystis* weight fit
- **THEN** each value equals the log density of the Normal on log weight minus the log of that row's `weight_kg`

#### Scenario: Log-likelihood agrees with the Stan model
- **WHEN** `log_lik()` is summed over the observed rows for each draw of any fit
- **THEN** it differs from the Stan model's log density with the likelihood, minus the same log density without it, by an amount that is the same for every draw
