# stan-engine

## Purpose

How kelpbio compiles, exposes, and runs its Stan models: pre-compilation into the package binary at `R CMD INSTALL` via rstan/rstantools, exposure as the `stanmodels` list, sampling through `rstan::sampling()`, and the model and dependency conventions that keep the build reproducible. See `docs/bayesian-engine.md`.

## Requirements

### Requirement: Stan models compile at install and are exposed as `stanmodels`

The package SHALL pre-compile every Stan source file under `inst/stan/` at `R CMD INSTALL` and expose each as an entry of the `stanmodels` list keyed by the file's base name.

#### Scenario: Installed package exposes the compiled weight model

- **WHEN** the package is installed with `devtools::install()` and loaded
- **THEN** `kelpbio::stanmodels$weight` exists and is a compiled Stan model object (S4 `stanmodel`)

#### Scenario: Stan source filename maps to the model name

- **WHEN** `inst/stan/weight.stan` is present at install time
- **THEN** the compiled model is reachable as `stanmodels$weight` (snake_case filename, no spaces/dashes/leading digits)

### Requirement: Compiled models are samplable via `rstan::sampling()`

A compiled model SHALL be samplable through `rstan::sampling(stanmodels$<name>, data = ...)`, returning a `stanfit` whose parameters match the model's declared parameter block.

#### Scenario: Sampling the weight smoke-test model returns a stanfit

- **WHEN** `rstan::sampling()` is called on `stanmodels$weight` with a valid data list (observation vectors, factor indices, and prior hyperparameters)
- **THEN** it returns a `stanfit` object containing the parameters `bWeight30`, `bDiameter`, `sSite`, `sWeight`, and the per-site vector `bSite`

### Requirement: The weight smoke-test model follows the engine conventions

The bundled `inst/stan/weight.stan` SHALL implement the site-intercept-only allometric structure with priors passed as data, a likelihood guard, and both prediction terms, per `docs/bayesian-engine.md` and `docs/vertical-slice.md`.

#### Scenario: Prior hyperparameters are read from the data block

- **WHEN** the data list supplies `prior_intercept_mu`/`prior_intercept_sd`, `prior_slope_mu`/`prior_slope_sd`, and separate `prior_sd_site_rate` and `prior_sd_residual_rate`
- **THEN** sampling uses those values for the corresponding priors without recompilation (the prior family is fixed at compile time)

#### Scenario: Prior-only fit ignores the likelihood

- **WHEN** the data list sets `prior_only = 1`
- **THEN** the model samples the parameters from their priors and the likelihood contributes nothing

#### Scenario: Zero observations are accepted

- **WHEN** the data list sets `nObs = 0` (no observed rows)
- **THEN** the model samples without error (the likelihood loop is a no-op)

#### Scenario: Generated quantities expose typical and marginal terms

- **WHEN** the model is sampled over an observed grid
- **THEN** the `generated quantities` block produces a `typical` term (random effects zeroed) and a `marginal` term (a new site drawn from `normal_rng(0, sSite)`)

### Requirement: The package declares the Stan runtime stack

`DESCRIPTION` and `NAMESPACE` SHALL declare the dependencies and dynamic-library directives required to load and run the compiled Stan binary.

#### Scenario: Stan-stack dependencies are present

- **WHEN** `DESCRIPTION` is inspected
- **THEN** it lists the rstan stack in Imports (Rcpp, RcppParallel, rstan, rstantools) and LinkingTo (BH, Rcpp, RcppEigen, RcppParallel, StanHeaders, rstan), with `rstan` and `StanHeaders` pinned to `>= 2.32.0`

#### Scenario: The compiled library is registered

- **WHEN** `NAMESPACE` is inspected
- **THEN** it contains a `useDynLib(kelpbio, .registration = TRUE)` directive and the rstan imports required by `R/stanmodels.R`
