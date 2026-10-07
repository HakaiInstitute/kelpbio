## ADDED Requirements

### Requirement: Prior sensitivity

`kb_sensitivity(fit, ..., prior_threshold = 0.1, likelihood_threshold = 0.05)` SHALL return a tibble with one row per estimated parameter that has a prior, and columns `term` (the parameter, as in `tidy()`, which is also the name of its prior's entry in the model's `kb_priors_*()` list), `prior_cjs` and `likelihood_cjs` (the power-scaling sensitivity of the parameter's posterior to the prior and to the likelihood, as computed by priorsense), `weak_prior` (`prior_cjs` less than `prior_threshold`), and `strong_data` (`likelihood_cjs` greater than or equal to `likelihood_threshold`). Random-effect levels and derived quantities SHALL NOT be reported. The result SHALL be computed from the stored fit, without refitting. `prior_threshold` and `likelihood_threshold` SHALL be numbers greater than 0, and `...` SHALL be empty.

priorsense's functions SHALL accept a `kb_fit` directly, giving the same sensitivity values as `kb_sensitivity()`, when priorsense is installed.

#### Scenario: One row per parameter with a prior
- **WHEN** `kb_sensitivity(fit)` is called on a fit
- **THEN** it returns one row per estimated parameter with a prior, with both sensitivity values and both flags

#### Scenario: The term identifies the prior to change
- **WHEN** a row is flagged
- **THEN** its `term` is the name of an entry in the list returned by the model's `kb_priors_*()` function

#### Scenario: Thresholds set the flags
- **WHEN** `prior_threshold` or `likelihood_threshold` is changed
- **THEN** `weak_prior` and `strong_data` change accordingly and the sensitivity values do not

#### Scenario: priorsense works on a fit
- **WHEN** `priorsense::powerscale_sensitivity(fit)` is called on a `kb_fit`
- **THEN** it returns priorsense's sensitivity table for the same parameters, with the values `kb_sensitivity()` reports

#### Scenario: A prior-only fit errors
- **WHEN** `kb_sensitivity()` is called on a fit made with `prior_only = TRUE`
- **THEN** it errors stating that a prior-only fit has no likelihood to assess

#### Scenario: priorsense is required
- **WHEN** `kb_sensitivity()` is called and priorsense is not installed
- **THEN** it errors naming priorsense and how to install it

## MODIFIED Requirements

### Requirement: Errors for unsupported objects

A kelpbio function taking a fit (the generics `kb_model_describe()`, `kb_stancode()`, and `samples()`, the prediction verbs `kb_predict_weight()`, `kb_predict_size()`, `kb_predict_density()`, `kb_predict_wetdry()`, `kb_predict_carbon()`, and `kb_predict_cover_biomass()`, the biomass compositions `kb_predict_plot_biomass()` and `kb_predict_site_biomass()`, `kb_new_data()`, and `kb_sensitivity()`) called on an object it does not support SHALL error with a `cli` message naming the argument and the required class (`kb_fit`, or the model class such as `kb_fit_weight`, `kb_fit_size`, `kb_fit_density`, `kb_fit_wetdry`, `kb_fit_carbon`, or `kb_fit_cover_biomass` for the prediction verbs) and pointing to the `kb_fit_*()` functions, attributed to the function the user called. Any method called on a fit whose model has no implementation for it SHALL error naming the object's class rather than return a value. kelpbio SHALL NOT add default methods to generics owned by other packages.

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

`samples()`, `rhat()`, `esr()`, `estimates()`, `npars()`, `nterms()`, `pars()`, `glance()`, `converged()`, and `kb_sensitivity()` SHALL cover only the effects the fit estimated. The draws of an omitted effect SHALL NOT be returned, its diagnostics SHALL NOT affect the convergence verdict, and it SHALL NOT appear in the sensitivity table.

#### Scenario: An omitted effect is not in the draws
- **WHEN** `samples(fit)` is called on a fit that omitted the density or site:year effect
- **THEN** the returned draws do not include that effect

#### Scenario: An omitted effect does not affect convergence
- **WHEN** an omitted effect's diagnostics would fail the thresholds
- **THEN** `converged()` is unaffected

#### Scenario: An omitted effect has no sensitivity row
- **WHEN** `kb_sensitivity(fit)` is called on a fit that omitted the density, floor, or site:year effect
- **THEN** the table has no row for that effect or its prior
