## RENAMED Requirements

- FROM: `### Requirement: The weight smoke-test model follows the engine conventions`
- TO: `### Requirement: The weight model follows the engine conventions`

## MODIFIED Requirements

### Requirement: Compiled models are samplable via `rstan::sampling()`

A compiled model SHALL be samplable through `rstan::sampling(stanmodels$<name>, data = ...)`, returning a `stanfit` whose parameters match the model's declared parameter block.

#### Scenario: Sampling the weight model returns a stanfit

- **WHEN** `rstan::sampling()` is called on `stanmodels$weight` with a valid data list (observation vectors, `site`/`year` factor indices, and prior hyperparameters)
- **THEN** it returns a `stanfit` object containing the fixed effects `bWeight`, `bDiameter`, `bDiameter2`, the random-effect SDs `sSite`, `sSiteDiameter`, `sSiteYear`, the residual scale `sWeight`, the per-site vectors `bSite` and `bSiteDiameter`, the site-by-year matrix `bSiteYear`, and the generated quantities `log_lik` and `yrep`

### Requirement: The weight model follows the engine conventions

The bundled `inst/stan/weight.stan` SHALL implement the full allometric weight structure -- a quadratic log-diameter mean with site intercept, site slope (on log diameter), and site:year random effects, and a Student-t(4) likelihood -- with priors passed as data, a likelihood guard, and `log_lik`/`yrep` generated quantities, per `decisions/engine-choice.md` and the model catalogue in `decisions/bboutools-api-review.md`. The mean (`log_eWeight`) SHALL be defined once, in `transformed parameters`, and reused by both the likelihood and the generated quantities.

#### Scenario: The mean follows the full allometric structure

- **WHEN** the linear predictor for an observation is formed in `transformed parameters`
- **THEN** it is `bWeight + bSite[site] + (bDiameter + bSiteDiameter[site]) * log(diameter / diameter_ref) + bDiameter2 * log(diameter / diameter_ref)^2 + bSiteYear[site, year]`, where `diameter_ref` is passed as data (the geometric mean of the observed diameter, so log-diameter is centered at its mean and the diameter unit is immaterial), with `bSite`, `bSiteDiameter`, and `bSiteYear` non-centered (`z_* * s_*`)

#### Scenario: Prior hyperparameters are read from the data block

- **WHEN** the data list supplies `prior_intercept_mu`/`prior_intercept_sd`, `prior_diameter_mu`/`prior_diameter_sd`, `prior_diameter2_mu`/`prior_diameter2_sd`, and the four rates `prior_sd_site_rate`, `prior_sd_site_diameter_rate`, `prior_sd_site_year_rate`, and `prior_sd_residual_rate`
- **THEN** sampling uses those values for the corresponding priors without recompilation (the prior family is fixed at compile time)

#### Scenario: Prior-only fit ignores the likelihood

- **WHEN** the data list sets `prior_only = 1`
- **THEN** the model samples the parameters from their priors and the likelihood contributes nothing

#### Scenario: Zero observations are accepted

- **WHEN** the data list sets `nObs = 0` (no observed rows, `nSite`/`nYear >= 1`)
- **THEN** the model samples without error (the likelihood loop is a no-op)

#### Scenario: Generated quantities expose log_lik and yrep

- **WHEN** the model is sampled
- **THEN** the `generated quantities` block, reusing `log_eWeight`, produces a pointwise `log_lik` (`student_t_lpdf` of `log_weight` given the mean and `sWeight`, for `loo`) and a `yrep` (response-scale posterior-predictive replicate via `student_t_rng`, for `bayesplot::pp_check`); predictions at new data are computed in R from the stored draws, not via standalone generated quantities
