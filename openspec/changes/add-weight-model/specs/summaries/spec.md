## ADDED Requirements

### Requirement: Tidy and group-level summaries

`tidy(x, conf_level, estimate, sig_fig, include_random_effects)` and `coef()` SHALL summarise a `kb_fit` from its stored draws. `tidy()` carries `conf_level` (default `0.95`), `estimate` (a point-estimate function, default `median`), `sig_fig` (default `3`), and `include_random_effects` (default `TRUE`). `coef()` is a pure wrapper on `tidy()`. Output columns are `term`, `estimate`, `lower`, `upper` (the house convention shared with `bboutools`/`ssdtools`), with `lower`/`upper` the `conf_level` compatibility limits from the posterior draws and all numeric columns rounded to `sig_fig`.

#### Scenario: tidy returns term summaries with house columns
- **WHEN** `tidy(fit)` is called
- **THEN** it returns a tibble with columns `term`, `estimate`, `lower`, `upper`, one row per population-level term (`bWeight30`, `bDiameter`, `bDiameter2`), per random-effect SD (`sSite`, `sSiteDiameter`, `sSiteYear`, `sWeight`), and (because `include_random_effects` defaults to `TRUE`) per group-level random effect (`bSite[.]`, `bSiteDiameter[.]`, `bSiteYear[.,.]`)

#### Scenario: tidy honours estimate, sig_fig, and conf_level
- **WHEN** `tidy(fit, conf_level = 0.9, estimate = mean, sig_fig = 4)` is called
- **THEN** `estimate` is the posterior mean, `lower`/`upper` are the 90% compatibility limits, and the numeric columns are rounded to 4 significant figures

#### Scenario: include_random_effects toggles group-level rows
- **WHEN** `tidy(fit, include_random_effects = FALSE)` is called
- **THEN** the per-level random-effect rows (`bSite[.]`, `bSiteDiameter[.]`, `bSiteYear[.,.]`) are omitted, leaving the population-level terms and SDs

#### Scenario: coef wraps tidy
- **WHEN** `coef(fit)` is called
- **THEN** it returns the same tibble as `tidy(fit)`, forwarding all arguments

### Requirement: Glance and convergence

`glance(x, rhat, esr, ...)` and `converged(x, rhat, esr, ...)` SHALL report model-level summaries and a convergence verdict using exposed thresholds. The thresholds default to the `report` analysis-mode values `rhat = 1.05` and `esr = 0.1`, where `esr` is the effective sample **rate** (`ess_bulk / ndraws`); both are arguments so they can be tightened. `esr` is preferred over an absolute ESS because the rate is stable under changes to the number of saved iterations.

#### Scenario: glance one-row summary
- **WHEN** `glance(fit)` is called
- **THEN** it returns a one-row tibble with columns `n`, `K`, `nchains`, `niters`, `nthin`, `ess`, `rhat`, and `converged` (the `bboutools` column set)

#### Scenario: converged honours thresholds
- **WHEN** `converged(fit, rhat = 1.05, esr = 0.1)` is called
- **THEN** it returns a single logical, `TRUE` only if all Rhat `<` `rhat` and all effective sample rates `>` `esr`

### Requirement: Augmented fitted values

`augment(x)` SHALL return the input data augmented with `fitted`, `residual`, `lower`, and `upper` (no dot prefix), fitted at each observed row using that row's estimated random effects (site intercept, site slope, and site:year), at full precision.

#### Scenario: augment adds fitted/residual columns
- **WHEN** `augment(fit)` is called
- **THEN** it returns the original data columns plus `fitted`, `residual`, `lower`, `upper`

### Requirement: Draws accessor and diagnostics surface

`samples(x)` SHALL return the raw parameter draws as a `posterior` draws object, and the accessors `rhat`, `esr`, `nobs`, `nchains`, `niters`, `npars`, `nterms`, `pars`, `estimates` and `kb_stancode(x)` SHALL operate on the fit object. All summaries and diagnostics are computed from the stored draws via `posterior` (see `decisions/prediction-engine.md` and `decisions/prediction-engine.md`).

#### Scenario: samples returns a draws container
- **WHEN** `samples(fit)` is called
- **THEN** it returns a `posterior` draws object (`draws_rvars`), not a melted one-row-per-draw tibble, that interoperates with bayesplot/coda/posterior

#### Scenario: accessors return scalar/structural values
- **WHEN** `rhat(fit)`, `esr(fit)`, `nobs(fit)`, `nchains(fit)`, `niters(fit)`, `npars(fit)`, `pars(fit)` are called
- **THEN** each returns the documented scalar or vector for the fit (`esr` being the effective sample rate `ess_bulk / ndraws`)

#### Scenario: kb_stancode returns the model source
- **WHEN** `kb_stancode(fit)` is called
- **THEN** it returns the Stan source for the fitted model

### Requirement: Summary and print methods

`summary(x)` SHALL return a classed `summary_kb_fit` object exposing the parameter numeric table (with its own `print` method), and `print(x)` SHALL display a stable, human-readable summary of a `kb_fit` (model, species, n obs, convergence) without embedding raw MCMC numbers, so it is snapshot-testable.

#### Scenario: print shows stable metadata
- **WHEN** `print(fit)` is called
- **THEN** it shows the model type, species, number of observations, and convergence status, and contains no raw MCMC numerics

#### Scenario: summary returns the numeric table
- **WHEN** `summary(fit)` is called
- **THEN** it returns a `summary_kb_fit` object whose `print` method shows the per-parameter posterior summary
