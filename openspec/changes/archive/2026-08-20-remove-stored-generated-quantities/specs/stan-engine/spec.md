## MODIFIED Requirements

### Requirement: Compiled models are samplable via `rstan::sampling()`

A compiled model SHALL be samplable through `rstan::sampling(stanmodels$<name>, data = ...)`, returning a `stanfit` whose parameters match the model's declared parameter block.

#### Scenario: Sampling the weight model returns a stanfit

- **WHEN** `rstan::sampling()` is called on `stanmodels$weight_nereo` with a valid data list (observation vectors, `site`/`year` factor indices, and prior hyperparameters)
- **THEN** it returns a `stanfit` object containing the fixed effects `bWeight`, `bDiameter`, `bDiameter2`, the random-effect SDs `sSite`, `sSiteDiameter`, `sSiteYear`, the residual scale `sWeight`, the per-site vectors `bSite` and `bSiteDiameter`, the site-by-year matrix `bSiteYear`

### Requirement: The weight model follows the engine conventions

The bundled `inst/stan/weight_nereo.stan` SHALL implement the full allometric weight structure -- a quadratic log-diameter mean with site intercept, site slope (on log diameter), and site:year random effects, and a Student-t(4) likelihood -- with priors passed as data and a likelihood guard, per `decisions/engine-choice.md` and the model catalogue in `decisions/bboutools-api-review.md`. The mean (`log_eWeight`) SHALL be a local in the `model` block, computed only when the likelihood is evaluated, so rstan does not save it with the draws. There SHALL be no `generated quantities` block: the pointwise log-likelihood and the posterior-predictive replicates are computed in R from the stored draws, because storing them scales as `2 x nObs x ndraws` and dominates the fit object. The site:year contribution to the mean SHALL be gated by a `site_year_on` (0/1) value in the data block, so a single compiled model serves both the full structure and the site:year-omitted structure; that value is set by the fitting layer from the data, not by the user.

#### Scenario: The mean follows the full allometric structure

- **WHEN** the linear predictor for an observation is formed in the `model` block with `site_year_on = 1`
- **THEN** it is `bWeight + bSite[site] + (bDiameter + bSiteDiameter[site]) * log(diameter / diameter_ref) + bDiameter2 * log(diameter / diameter_ref)^2 + bSiteYear[site, year]`, where `diameter_ref` is passed as data (the geometric mean of the observed diameter, so log-diameter is centered at its mean and the diameter unit is immaterial), with `bSite`, `bSiteDiameter`, and `bSiteYear` non-centered (`z_* * s_*`)

#### Scenario: The site:year term is gated by a data flag

- **WHEN** the data list sets `site_year_on = 0`
- **THEN** the `bSiteYear` contribution is removed from `log_eWeight` (the `bSiteYear` / `sSiteYear` parameters are still declared and sampled from their priors, but do not enter the mean or the likelihood)

#### Scenario: Prior hyperparameters are read from the data block

- **WHEN** the data list supplies `prior_intercept_mu`/`prior_intercept_sd`, `prior_diameter_mu`/`prior_diameter_sd`, `prior_diameter2_mu`/`prior_diameter2_sd`, and the four rates `prior_sd_site_rate`, `prior_sd_site_diameter_rate`, `prior_sd_site_year_rate`, and `prior_sd_residual_rate`
- **THEN** sampling uses those values for the corresponding priors without recompilation (the prior family is fixed at compile time)

#### Scenario: Prior-only fit ignores the likelihood

- **WHEN** the data list sets `prior_only = 1`
- **THEN** the model samples the parameters from their priors and the likelihood contributes nothing

#### Scenario: Zero observations are accepted

- **WHEN** the data list sets `nObs = 0` (no observed rows, `nSite`/`nYear >= 1`)
- **THEN** the model samples without error (the likelihood loop is a no-op)

### Requirement: The Macrocystis weight model follows the engine conventions

`inst/stan/weight_macro.stan` SHALL follow the same engine conventions as
`weight_nereo.stan`: priors passed as data (all hyperparameters in the `data`
block, the prior family fixed at compile time), a `prior_only` flag and `nObs >=
0` supporting prior-only and zero-observation fits, non-centred random effects
(`z_*` standard-normal deviations scaled by their SD), and the mean as a local in
the `model` block rather than a saved transformed parameter. There are no
generated quantities. It is exposed as `stanmodels$weight_macro`.

The macro model SHALL differ from nereo in its likelihood and structure: the
response `weight` is modelled on the natural scale by `weight ~ gamma(shape,
shape ./ eWeight)`, where `eWeight = exp(bWeight + bSite[site]
+ bFronds * log_fronds + bYear[year] + site_year_on * bSiteYear[site, year])` and
`log_fronds = log(fronds) - log(fronds_ref)`. There is no quadratic term, no site
slope, and no residual SD; dispersion comes from the constant Gamma shape
`shape`. A standalone year main effect `bYear` is present in addition to `bSite`
and `bSiteYear`.

#### Scenario: Samples and exposes the expected quantities
- **WHEN** `stanmodels$weight_macro` is sampled on assembled macro data
- **THEN** it returns a stanfit exposing `bWeight`, `bFronds`, `shape`, `sSite`,
  `sYear`, `sSiteYear`, and the per-level `bSite` / `bYear` / `bSiteYear`

#### Scenario: Prior-only guard and empty data
- **WHEN** the model is sampled with `prior_only = 1` or `nObs = 0`
- **THEN** the likelihood is skipped, and the mean is not computed at all since it is a local inside the likelihood guard
