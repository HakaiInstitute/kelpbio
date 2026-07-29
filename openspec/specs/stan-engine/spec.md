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
- **THEN** it returns a `stanfit` object containing the fixed effects `bWeight`, `bDiameter`, `bDiameter2`, the random-effect SDs `sSite`, `sSiteDiameter`, `sSiteYear`, the residual scale `sWeight`, the per-site vectors `bSite` and `bSiteDiameter`, the site-by-year matrix `bSiteYear`, and the generated quantities `log_lik` and `yrep`

### Requirement: The weight model follows the engine conventions

The bundled `inst/stan/weight_nereo.stan` SHALL implement the full allometric weight structure -- a quadratic log-diameter mean with site intercept, site slope (on log diameter), and site:year random effects, and a Student-t(4) likelihood -- with priors passed as data, a likelihood guard, and `log_lik`/`yrep` generated quantities, per `decisions/engine-choice.md` and the model catalogue in `decisions/bboutools-api-review.md`. The mean (`log_eWeight`) SHALL be defined once, in `transformed parameters`, and reused by both the likelihood and the generated quantities. The site:year contribution to the mean SHALL be gated by a `site_year_on` (0/1) value in the data block, so a single compiled model serves both the full structure and the site:year-omitted structure; that value is set by the fitting layer from the data, not by the user.

#### Scenario: The mean follows the full allometric structure

- **WHEN** the linear predictor for an observation is formed in `transformed parameters` with `site_year_on = 1`
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

#### Scenario: Generated quantities expose log_lik and yrep

- **WHEN** the model is sampled
- **THEN** the `generated quantities` block, reusing `log_eWeight`, produces a pointwise `log_lik` (`student_t_lpdf` of `log_weight` given the mean and `sWeight`, for `loo`) and a `yrep` (response-scale posterior-predictive replicate via `student_t_rng`, for `bayesplot::pp_check`); predictions at new data are computed in R from the stored draws, not via standalone generated quantities

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
(`z_*` standard-normal deviations scaled by their SD), the mean defined once in
`transformed parameters`, and `log_lik` / `yrep` generated quantities that are
no-ops when `nObs == 0`. It is exposed as `stanmodels$weight_macro`.

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
  `sYear`, `sSiteYear`, the per-level `bSite` / `bYear` / `bSiteYear`, and the
  `log_lik` / `yrep` generated quantities

#### Scenario: Prior-only guard and empty data
- **WHEN** the model is sampled with `prior_only = 1` or `nObs = 0`
- **THEN** the likelihood is skipped and the `log_lik` / `yrep` loops are no-ops

