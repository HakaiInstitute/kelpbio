## ADDED Requirements

### Requirement: Tidy and group-level summaries

`tidy()` and `coef()` SHALL summarise a `kb_fit` from its stored draws, carrying `conf_level`, `estimate`, and `sig_fig`.

#### Scenario: tidy returns fixed-effect and SD summaries
- **WHEN** `tidy(fit)` is called
- **THEN** it returns a tibble with one row per population-level term (`bWeight30`, `bDiameter`, `bDiameter2`) and per random-effect SD (`sSite`, `sSiteDiameter`, `sSiteYear`, `sWeight`), with columns `term`, `estimate`, `std.error`, `conf.low`, `conf.high`

#### Scenario: coef returns group-level estimates
- **WHEN** `coef(fit)` is called
- **THEN** it returns the group-level coefficient estimates (the per-site intercepts and slopes, and the site:year effects; wrapping `tidy`)

### Requirement: Glance and convergence

`glance(x, rhat, ess, ...)` and `converged(x, rhat, ess, ...)` SHALL report model-level summaries and a convergence verdict using exposed thresholds.

#### Scenario: glance one-row summary
- **WHEN** `glance(fit)` is called
- **THEN** it returns a one-row tibble including `nobs`, `nchains`, `niters`, `npars`, and `converged`

#### Scenario: converged honours thresholds
- **WHEN** `converged(fit, rhat = 1.05, ess = 400)` is called
- **THEN** it returns a single logical, TRUE only if all Rhat `<` `rhat` and ESS `>` `ess`

### Requirement: Augmented fitted values

`augment(x)` SHALL return the input data augmented with `.fitted`, `.resid`, `.lower`, `.upper`, fitted at each observed row using that row's estimated random effects (site intercept, site slope, and site:year), at full precision.

#### Scenario: augment adds fitted/resid columns
- **WHEN** `augment(fit)` is called
- **THEN** it returns the original data columns plus `.fitted`, `.resid`, `.lower`, `.upper`

### Requirement: Draws accessor and diagnostics surface

`samples(x)` SHALL return the raw parameter draws as a `posterior` draws object, and the accessors `rhat`, `ess`, `nobs`, `nchains`, `niters`, `npars`, `nterms`, `pars` and `kb_stancode(x)` SHALL operate on the fit object. All summaries and diagnostics are computed from the stored draws via `posterior` (see `docs/predictions.md`).

#### Scenario: samples returns a draws container
- **WHEN** `samples(fit)` is called
- **THEN** it returns a `posterior` draws object (`draws_rvars`), not a melted one-row-per-draw tibble, that interoperates with bayesplot/coda/posterior

#### Scenario: accessors return scalar/structural values
- **WHEN** `rhat(fit)`, `ess(fit)`, `nobs(fit)`, `nchains(fit)`, `niters(fit)`, `npars(fit)`, `pars(fit)` are called
- **THEN** each returns the documented scalar or vector for the fit

#### Scenario: kb_stancode returns the model source
- **WHEN** `kb_stancode(fit)` is called
- **THEN** it returns the Stan source for the fitted model

### Requirement: Print method

`print()` SHALL display a stable, human-readable summary of a `kb_fit` (model, species, n obs, convergence) without embedding raw MCMC numbers.

#### Scenario: print shows stable metadata
- **WHEN** `print(fit)` is called
- **THEN** it shows the model type, species, number of observations, and convergence status
