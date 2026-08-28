# stan-engine

## Purpose

How kelpbio compiles, exposes, and runs its Stan models: pre-compilation into the package binary at `R CMD INSTALL` via rstan/rstantools, exposure as the `stanmodels` list, sampling through `rstan::sampling()`, and the model and dependency conventions that keep the build reproducible. See `decisions/engine-choice.md`.
## Requirements
### Requirement: Stan models compile at install and are exposed as `stanmodels`

The package SHALL pre-compile every Stan source file under `inst/stan/` at `R CMD INSTALL` and expose each as an entry of the `stanmodels` list keyed by the file's base name.

#### Scenario: Installed package exposes the compiled weight model

- **WHEN** the package is installed with `devtools::install()` and loaded
- **THEN** `kelpbio::stanmodels$weight_nereo` exists and is a compiled Stan model object (S4 `stanmodel`)

#### Scenario: Stan source filename maps to the model name

- **WHEN** `inst/stan/weight_nereo.stan` is present at install time
- **THEN** the compiled model is reachable as `stanmodels$weight_nereo` (snake_case filename, no spaces/dashes/leading digits)

### Requirement: Compiled models are samplable via `rstan::sampling()`

A compiled model SHALL be samplable through `rstan::sampling(stanmodels$<name>, data = ...)`, returning a `stanfit` whose parameters match the model's declared parameter block.

#### Scenario: Sampling the weight model returns a stanfit

- **WHEN** `rstan::sampling()` is called on `stanmodels$weight_nereo` with a valid data list (observation vectors, `site`/`year` factor indices, and prior hyperparameters)
- **THEN** it returns a `stanfit` object containing the fixed effects `bWeight`, `bPower`, `bFloor`, `bNu`, the random-effect SDs `sSite`, `sYear`, `sSitePower`, `sSiteYear`, the residual scale `sWeight`, the per-site vectors `bSite` and `bSitePower`, the per-year vector `bYear`, the site-by-year matrix `bSiteYear`

### Requirement: The weight model follows the engine conventions

The bundled `inst/stan/weight_nereo.stan` SHALL implement the full allometric weight structure -- a Packard three-parameter power mean with year, site intercept, site exponent, and site:year random effects, and a Student-t likelihood whose degrees of freedom are estimated -- with priors passed as data and a likelihood guard, per `decisions/engine-choice.md` and the model catalogue in `decisions/bboutools-api-review.md`. The mean (`log_eWeight`) SHALL be a local in the `model` block, computed only when the likelihood is evaluated, so rstan does not save it with the draws. There SHALL be no `generated quantities` block: the pointwise log-likelihood and the posterior-predictive replicates are computed in R from the stored draws, because storing them scales as `2 x nObs x ndraws` and dominates the fit object. The site:year contribution to the mean SHALL be gated by a `site_year_on` (0/1) value in the data block, so a single compiled model serves both the full structure and the site:year-omitted structure; that value is set by the fitting layer from the data, not by the user.

#### Scenario: The mean follows the full allometric structure

- **WHEN** the linear predictor for an observation is formed in the `model` block with `site_year_on = 1`
- **THEN** it is `bWeight + bYear[year] + bSite[site] + log(bFloor + (1 - bFloor) * (diameter / diameter_ref)^power[site]) + bSiteYear[site, year]`, where `power[site] = bPower * exp(bSitePower[site])` so the exponent is positive and expected weight is monotone in diameter within every site, and `diameter_ref` is passed as data (the geometric mean of the observed diameter, so the diameter unit is immaterial and the exponent term stays bounded), with `bSite`, `bYear`, `bSitePower`, and `bSiteYear` non-centered (`z_* * s_*`)

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

### Requirement: The package declares the Stan runtime stack

`DESCRIPTION` and `NAMESPACE` SHALL declare the dependencies and dynamic-library directives required to load and run the compiled Stan binary.

#### Scenario: Stan-stack dependencies are present

- **WHEN** `DESCRIPTION` is inspected
- **THEN** it lists the rstan stack in Imports (Rcpp, RcppParallel, rstan, rstantools) and LinkingTo (BH, Rcpp, RcppEigen, RcppParallel, StanHeaders, rstan), with `rstan` and `StanHeaders` pinned to `>= 2.32.0`

#### Scenario: The compiled library is registered

- **WHEN** `NAMESPACE` is inspected
- **THEN** it contains a `useDynLib(kelpbio, .registration = TRUE)` directive and the rstan imports required by `R/stanmodels.R`

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

