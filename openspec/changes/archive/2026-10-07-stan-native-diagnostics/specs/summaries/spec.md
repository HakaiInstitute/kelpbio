## MODIFIED Requirements

### Requirement: Convergence

`glance()` SHALL return a one-row tibble with `n`, `K`, `nchains`, `niters`, `nthin`, `ess_bulk`, `ess_tail`, `rhat`, `perc_divergent`, and `converged`, the effective sample sizes being the smallest and Rhat the largest over the estimated parameters. `kb_converged()` SHALL return `TRUE` only when every rank-normalized split Rhat is below `rhat` (default 1.01), every bulk and tail effective sample size is at least `ess` times the number of chains (default 100), and the divergence percentage is at or below `max_perc_divergent` (default 0.2), and SHALL return `FALSE` when no Rhat is available. Its documentation SHALL cite the source of each threshold. Per-parameter Rhat and effective sample sizes SHALL be available from `summarise_draws(fit)`. Treedepth saturation and E-BFMI SHALL be reported by `print(summary(fit))`, not used in the verdict.

#### Scenario: Divergences fail a well-mixed fit
- **WHEN** a fit has acceptable Rhat and ESS but a divergence rate above `max_perc_divergent`
- **THEN** `kb_converged()` is `FALSE`

#### Scenario: Effective sample size is judged per chain, not per draw
- **WHEN** every Rhat is below 1.01 and there are no divergences, but one parameter's tail effective sample size is below 100 times the number of chains
- **THEN** `kb_converged()` is `FALSE`, however many draws were saved

#### Scenario: Zero tolerance is satisfiable
- **WHEN** `kb_converged(fit, max_perc_divergent = 0)` is called on a fit with no divergences
- **THEN** it returns `TRUE`

#### Scenario: Per-parameter diagnostics come from posterior
- **WHEN** `summarise_draws(fit)` is called
- **THEN** it returns each estimated parameter's `rhat`, `ess_bulk`, and `ess_tail`

### Requirement: Accessors

`kb_samples(fit)` and `posterior::as_draws(fit)` SHALL return the draws as a `posterior` `draws_rvars` object, the same object from either. The other `posterior` conversions (`as_draws_df()`, `as_draws_array()`, `as_draws_matrix()`, `as_draws_list()`, `as_draws_rvars()`) and `summarise_draws()` SHALL accept a fit and return what they return for those draws. `posterior`'s `nchains()`, `niterations()`, `ndraws()`, `nvariables()`, and `variables()` SHALL return those of the fit's draws, and `as_draws()` and these five are available after attaching kelpbio. `nobs(fit)` SHALL return the number of observations, and `kb_stancode(fit)` the Stan source of the fitted model.

#### Scenario: Draws interoperate with posterior
- **WHEN** `kb_samples(fit)` is called
- **THEN** it returns a `draws_rvars` object usable with the `posterior` package

#### Scenario: A fit converts like any posterior object
- **WHEN** `posterior::as_draws(fit)` or `posterior::as_draws_df(fit)` is called
- **THEN** it returns the draws of `kb_samples(fit)`, in `draws_rvars` or `draws_df` form

#### Scenario: Draw counts read the fit
- **WHEN** `nchains(fit)`, `niterations(fit)`, or `variables(fit)` is called after `library(kelpbio)`
- **THEN** it returns the chains, saved draws per chain, or parameter names of `kb_samples(fit)`

### Requirement: Draws, accessors, and convergence cover only estimated effects

`kb_samples()`, `as_draws()`, `nvariables()`, `variables()`, `glance()`, `kb_converged()`, and `kb_sensitivity()` SHALL cover only the effects the fit estimated. The draws of an omitted effect SHALL NOT be returned, its diagnostics SHALL NOT affect the convergence verdict, and it SHALL NOT appear in the sensitivity table.

#### Scenario: An omitted effect is not in the draws
- **WHEN** `kb_samples(fit)` or `posterior::as_draws(fit)` is called on a fit that omitted the density or site:year effect
- **THEN** the returned draws do not include that effect

#### Scenario: An omitted effect does not affect convergence
- **WHEN** an omitted effect's diagnostics would fail the thresholds
- **THEN** `kb_converged()` is unaffected

#### Scenario: An omitted effect has no sensitivity row
- **WHEN** `kb_sensitivity(fit)` is called on a fit that omitted the density, floor, or site:year effect
- **THEN** the table has no row for that effect or its prior
