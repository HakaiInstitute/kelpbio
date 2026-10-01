# summaries

## Purpose

Summarising and inspecting a fit: parameter summaries, convergence, fitted values
and residuals, print and summary output, the model description, accessors, and
the errors raised for unsupported objects.
## Requirements
### Requirement: Parameter summaries

`tidy()` and `coef()` SHALL return a tibble with columns `term`, `estimate`, `lower`, and `upper`, one row per population-level term and standard deviation of the fitted model, with `conf_level` (default 0.95) compatibility limits, `estimate` (default `median`), and `sig_fig` (default 3). `include_random_effects = TRUE` (default `FALSE`) SHALL add the per-level group effects. `coef()` SHALL return what `tidy()` returns.

#### Scenario: Default rows
- **WHEN** `tidy(fit)` is called
- **THEN** it returns the population-level terms and SDs, without per-level group effects

#### Scenario: Summary options are honoured
- **WHEN** `tidy(fit, conf_level = 0.9, estimate = mean, sig_fig = 4)` is called
- **THEN** it returns posterior means with 90% compatibility limits to 4 significant figures

### Requirement: Omitted effects are not reported

An effect the fit omitted (site:year for single-year data, or density when not fitted) SHALL NOT appear in `tidy()`, `coef()`, `summary()`, or `kb_model_describe()`, since its draws never met the data.

#### Scenario: An omitted effect is absent
- **WHEN** a fit omitted the site:year or density effect
- **THEN** its terms appear in none of `tidy()`, `summary()`, or `kb_model_describe()`, including under `include_random_effects = TRUE`

### Requirement: Convergence

`glance()` SHALL return a one-row tibble with `n`, `K`, `nchains`, `niters`, `nthin`, `ess`, `rhat`, `perc_divergent`, and `converged`. `converged()` SHALL return `TRUE` only when every Rhat is below `rhat` (default 1.01), every effective sample rate (`ess_bulk / ndraws`) is above `esr` (default 0.1), and the divergence percentage is at or below `max_perc_divergent` (default 0.2), and SHALL return `FALSE` when no Rhat is available. Treedepth saturation and E-BFMI SHALL be reported by `print(summary(fit))`, not used in the verdict.

#### Scenario: Divergences fail a well-mixed fit
- **WHEN** a fit has acceptable Rhat and ESS but a divergence rate above `max_perc_divergent`
- **THEN** `converged()` is `FALSE`

#### Scenario: Zero tolerance is satisfiable
- **WHEN** `converged(fit, max_perc_divergent = 0)` is called on a fit with no divergences
- **THEN** it returns `TRUE`

### Requirement: Fitted values, residuals, and augment

`fitted()` SHALL return the posterior median of the expected response (weight or size) at each observed row, and `residuals()` the posterior median of the deviance residual under the model's likelihood. `augment()` SHALL return the input data with `fitted` and `residual` columns equal to those values, and no interval columns.

#### Scenario: augment agrees with fitted and residuals
- **WHEN** `augment(fit)` is called on a weight or size fit
- **THEN** its `fitted` and `residual` columns equal `fitted(fit)` and `residuals(fit)`

### Requirement: Print and summary

`print(fit)` SHALL show a header with the model and species, the predictor and its reference value (for a model with a predictor), the observation and group counts, the sampler settings, the convergence verdict, and a prior-only note when applicable, followed by a pointer to `kb_model_describe()`, with no parameter estimates. `summary(fit)` SHALL return an object whose print shows the same header, a table of `term`, `estimate`, `lower`, `upper`, `rhat`, `ess_bulk`, and `ess_tail` (per-level effects only with `include_random_effects = TRUE`), and a footer with the divergence rate, treedepth-saturation rate, and minimum E-BFMI. The output is pinned by `tests/testthat/_snaps/print.md` and `tests/testthat/_snaps/summary.md`.

#### Scenario: print shows no estimates
- **WHEN** `print(fit)` is called
- **THEN** it shows the header and no parameter estimates

#### Scenario: A size fit has no predictor line
- **WHEN** `print()` is called on a size fit
- **THEN** the header has no predictor line

### Requirement: Model description

`kb_model_describe(fit)` SHALL print the fitted model in notation using the package's parameter names (the same terms as `tidy()`), with no Greek letters or R formula syntax, and `kb_model_describe(fit, prose = TRUE)` the same model as a methods paragraph; both SHALL return the lines invisibly. The description SHALL reflect the fit, not the defaults: its stored priors, its predictor reference and density standardisation, and only the effects it fitted. Priors truncated at zero SHALL be marked `T[0, ]`. The content for each model is pinned by `tests/testthat/_snaps/kb_model_describe.md`.

#### Scenario: The description follows the fit
- **WHEN** a fit used custom priors or omitted an effect
- **THEN** the description shows those priors and leaves the omitted effect out

### Requirement: Accessors

`samples(fit)` SHALL return the draws as a `posterior` `draws_rvars` object. `rhat()`, `esr()`, `nobs()`, `nchains()`, `niters()`, `npars()`, `nterms()`, `pars()`, and `estimates()` SHALL return the fit's values, and `kb_stancode(fit)` the Stan source of the fitted model.

#### Scenario: Draws interoperate with posterior
- **WHEN** `samples(fit)` is called
- **THEN** it returns a `draws_rvars` object usable with the `posterior` package

### Requirement: Errors for unsupported objects

A kelpbio generic (`kb_model_describe()`, `kb_stancode()`, `samples()`, `kb_predict_weight()`, `kb_predict_weight_by()`, `kb_predict_size()`, `kb_predict_size_by()`) called on an object it does not support SHALL error with a `cli` message naming the argument and the required class (`kb_fit`, or the model class such as `kb_fit_weight` or `kb_fit_size` for the prediction verbs) and pointing to the `kb_fit_*()` functions, attributed to the generic the user called. Any method called on a fit whose model has no implementation for it SHALL error naming the object's class rather than return a value. kelpbio SHALL NOT add default methods to generics owned by other packages.

#### Scenario: A non-fit errors helpfully
- **WHEN** `kb_model_describe(1)` or `kb_predict_weight(1)` is called
- **THEN** it errors stating the required class and pointing to the fitting functions

#### Scenario: A fit of the other model errors
- **WHEN** `kb_predict_size()` is called on a weight fit, or `kb_predict_weight()` on a size fit
- **THEN** it errors stating the required model class

#### Scenario: A fit without methods fails loudly
- **WHEN** `log_lik()`, `residuals()`, `fitted()`, or `augment()` is called on a fit whose model has no methods
- **THEN** it errors rather than returning a value

### Requirement: Draws, accessors, and convergence cover only estimated effects

`samples()`, `rhat()`, `esr()`, `estimates()`, `npars()`, `nterms()`, `pars()`, `glance()`, and `converged()` SHALL cover only the effects the fit estimated. The draws of an omitted effect SHALL NOT be returned, and its diagnostics SHALL NOT affect the convergence verdict.

#### Scenario: An omitted effect is not in the draws
- **WHEN** `samples(fit)` is called on a fit that omitted the density or site:year effect
- **THEN** the returned draws do not include that effect

#### Scenario: An omitted effect does not affect convergence
- **WHEN** an omitted effect's diagnostics would fail the thresholds
- **THEN** `converged()` is unaffected

