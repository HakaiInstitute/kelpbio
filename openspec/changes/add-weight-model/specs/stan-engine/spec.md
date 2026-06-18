## RENAMED Requirements

- FROM: `### Requirement: The weight smoke-test model follows the engine conventions`
- TO: `### Requirement: The weight model follows the engine conventions`

## MODIFIED Requirements

### Requirement: Compiled models are samplable via `rstan::sampling()`

A compiled model SHALL be samplable through `rstan::sampling(stanmodels$<name>, data = ...)`, returning a `stanfit` whose parameters match the model's declared parameter block.

#### Scenario: Sampling the weight model returns a stanfit

- **WHEN** `rstan::sampling()` is called on `stanmodels$weight` with a valid data list (observation vectors, `site`/`year` factor indices, and prior hyperparameters)
- **THEN** it returns a `stanfit` object containing the fixed effects `bWeight30`, `bDiameter`, `bDiameter2`, the random-effect SDs `sSite`, `sSiteDiameter`, `sSiteYear`, the residual scale `sWeight`, the per-site vectors `bSite` and `bSiteDiameter`, and the site-by-year matrix `bSiteYear`

### Requirement: The weight model follows the engine conventions

The bundled `inst/stan/weight.stan` SHALL implement the full allometric weight structure -- a quadratic log-diameter mean with site intercept, site slope (on log diameter), and site:year random effects, and a Student-t(4) likelihood -- with priors passed as data, a likelihood guard, and both prediction terms, per `docs/bayesian-engine.md` and the model catalogue in `docs/package-design.md`.

#### Scenario: The mean follows the full allometric structure

- **WHEN** the linear predictor for an observation is formed
- **THEN** it is `bWeight30 + bSite[site] + (bDiameter + bSiteDiameter[site]) * log(diameter / 30) + bDiameter2 * log(diameter / 30)^2 + bSiteYear[site, year]`, with `bSite`, `bSiteDiameter`, and `bSiteYear` non-centered (`z_* * s_*`)

#### Scenario: Prior hyperparameters are read from the data block

- **WHEN** the data list supplies `prior_intercept_mu`/`prior_intercept_sd`, `prior_diameter_mu`/`prior_diameter_sd`, `prior_diameter2_mu`/`prior_diameter2_sd`, and the four rates `prior_sd_site_rate`, `prior_sd_site_diameter_rate`, `prior_sd_site_year_rate`, and `prior_sd_residual_rate`
- **THEN** sampling uses those values for the corresponding priors without recompilation (the prior family is fixed at compile time)

#### Scenario: Prior-only fit ignores the likelihood

- **WHEN** the data list sets `prior_only = 1`
- **THEN** the model samples the parameters from their priors and the likelihood contributes nothing

#### Scenario: Zero observations are accepted

- **WHEN** the data list sets `nObs = 0` (no observed rows, `nSite`/`nYear >= 1`)
- **THEN** the model samples without error (the likelihood loop is a no-op)

#### Scenario: Generated quantities expose typical and marginal terms

- **WHEN** the model is sampled over an observed grid
- **THEN** the `generated quantities` block produces a `typical` term (all random effects zeroed) and a `marginal` term (a new, unobserved site-year with the site intercept, site slope, and site:year effects each drawn from their estimated hyperpriors via `normal_rng`)
