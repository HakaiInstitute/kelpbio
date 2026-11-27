## MODIFIED Requirements

### Requirement: Accessors

`kb_samples(fit)` and `posterior::as_draws(fit)` SHALL return the draws as a `posterior` `draws_rvars` object, the same object from either. The other `posterior` conversions (`as_draws_df()`, `as_draws_array()`, `as_draws_matrix()`, `as_draws_list()`, `as_draws_rvars()`) and `summarise_draws()` SHALL accept a fit and return what they return for those draws. `rhat()`, `esr()`, `nobs()`, `nchains()`, `niters()`, `npars()`, `nterms()`, `pars()`, and `estimates()` SHALL return the fit's values, and `kb_stancode(fit)` the Stan source of the fitted model.

#### Scenario: Draws interoperate with posterior
- **WHEN** `kb_samples(fit)` is called
- **THEN** it returns a `draws_rvars` object usable with the `posterior` package

#### Scenario: A fit converts like any posterior object
- **WHEN** `posterior::as_draws(fit)` or `posterior::as_draws_df(fit)` is called
- **THEN** it returns the draws of `kb_samples(fit)`, in `draws_rvars` or `draws_df` form

### Requirement: Errors for unsupported objects

A kelpbio function taking a fit (`kb_model_describe()`, `kb_stancode()`, and `kb_samples()`, the prediction verbs `kb_predict_weight()`, `kb_predict_size()`, `kb_predict_density()`, `kb_predict_wetdry()`, `kb_predict_carbon()`, and `kb_predict_cover_biomass()`, the biomass compositions `kb_predict_plot_biomass()` and `kb_predict_site_biomass()`, `kb_new_data()`, and `kb_sensitivity()`) called on an object it does not support SHALL error with a `cli` message naming the argument and the required class (`kb_fit`, or the model class such as `kb_fit_weight`, `kb_fit_size`, `kb_fit_density`, `kb_fit_wetdry`, `kb_fit_carbon`, or `kb_fit_cover_biomass` for the prediction verbs) and pointing to the `kb_fit_*()` functions, attributed to the function the user called. Any method called on a fit whose model has no implementation for it SHALL error naming the object's class rather than return a value. kelpbio SHALL NOT add default methods to generics owned by other packages.

#### Scenario: A non-fit errors helpfully
- **WHEN** `kb_model_describe(1)` or `kb_predict_weight(1)` is called
- **THEN** it errors stating the required class and pointing to the fitting functions

#### Scenario: A fit of the other model errors
- **WHEN** `kb_predict_density()` is called on a weight or size fit, or `kb_predict_weight()` on a density fit
- **THEN** it errors stating the required model class

#### Scenario: A fit without methods fails loudly
- **WHEN** `log_lik()`, `residuals()`, `fitted()`, `augment()`, or `kb_sensitivity()` is called on a fit whose model has no methods
- **THEN** it errors rather than returning a value

### Requirement: Draws, accessors, and convergence cover only estimated effects

`kb_samples()`, `as_draws()`, `rhat()`, `esr()`, `estimates()`, `npars()`, `nterms()`, `pars()`, `glance()`, `converged()`, and `kb_sensitivity()` SHALL cover only the effects the fit estimated. The draws of an omitted effect SHALL NOT be returned, its diagnostics SHALL NOT affect the convergence verdict, and it SHALL NOT appear in the sensitivity table.

#### Scenario: An omitted effect is not in the draws
- **WHEN** `kb_samples(fit)` or `posterior::as_draws(fit)` is called on a fit that omitted the density or site:year effect
- **THEN** the returned draws do not include that effect

#### Scenario: An omitted effect does not affect convergence
- **WHEN** an omitted effect's diagnostics would fail the thresholds
- **THEN** `converged()` is unaffected

#### Scenario: An omitted effect has no sensitivity row
- **WHEN** `kb_sensitivity(fit)` is called on a fit that omitted the density, floor, or site:year effect
- **THEN** the table has no row for that effect or its prior
