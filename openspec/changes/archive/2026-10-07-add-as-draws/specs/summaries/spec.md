## MODIFIED Requirements

### Requirement: Accessors

`samples(fit)` and `posterior::as_draws(fit)` SHALL return the draws as a `posterior` `draws_rvars` object, the same object from either. The other `posterior` conversions (`as_draws_df()`, `as_draws_array()`, `as_draws_matrix()`, `as_draws_list()`, `as_draws_rvars()`) and `summarise_draws()` SHALL accept a fit and return what they return for those draws. `rhat()`, `esr()`, `nobs()`, `nchains()`, `niters()`, `npars()`, `nterms()`, `pars()`, and `estimates()` SHALL return the fit's values, and `kb_stancode(fit)` the Stan source of the fitted model.

#### Scenario: Draws interoperate with posterior
- **WHEN** `samples(fit)` is called
- **THEN** it returns a `draws_rvars` object usable with the `posterior` package

#### Scenario: A fit converts like any posterior object
- **WHEN** `posterior::as_draws(fit)` or `posterior::as_draws_df(fit)` is called
- **THEN** it returns the draws of `samples(fit)`, in `draws_rvars` or `draws_df` form

### Requirement: Draws, accessors, and convergence cover only estimated effects

`samples()`, `as_draws()`, `rhat()`, `esr()`, `estimates()`, `npars()`, `nterms()`, `pars()`, `glance()`, `converged()`, and `kb_sensitivity()` SHALL cover only the effects the fit estimated. The draws of an omitted effect SHALL NOT be returned, its diagnostics SHALL NOT affect the convergence verdict, and it SHALL NOT appear in the sensitivity table.

#### Scenario: An omitted effect is not in the draws
- **WHEN** `samples(fit)` or `posterior::as_draws(fit)` is called on a fit that omitted the density or site:year effect
- **THEN** the returned draws do not include that effect

#### Scenario: An omitted effect does not affect convergence
- **WHEN** an omitted effect's diagnostics would fail the thresholds
- **THEN** `converged()` is unaffected

#### Scenario: An omitted effect has no sensitivity row
- **WHEN** `kb_sensitivity(fit)` is called on a fit that omitted the density, floor, or site:year effect
- **THEN** the table has no row for that effect or its prior
