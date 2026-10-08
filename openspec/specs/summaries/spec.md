# summaries

## Purpose

Summarising and inspecting a fit: parameter summaries, convergence, fitted values
and residuals, posterior predictive checks, print and summary output, the model
description, accessors, and the errors raised for unsupported objects.
## Requirements
### Requirement: Parameter summaries

`tidy()` and `coef()` SHALL return a tibble with columns `term`, `estimate`, `lower`, and `upper`, one row per population-level term and standard deviation of the fitted model, with `conf_level` (default 0.95) compatibility limits, `estimate` (default `median`), and `sig_fig` (default 3). `include_random_effects = TRUE` (default `FALSE`) SHALL add the per-level group effects, each term naming its level, as in `site_effect[<site>]`, `year_effect[<year>]`, and `site_year_effect[<site>,<year>]`. `coef()` SHALL return what `tidy()` returns.

#### Scenario: Default rows
- **WHEN** `tidy(fit)` is called
- **THEN** it returns the population-level terms and SDs, without per-level group effects

#### Scenario: Summary options are honoured
- **WHEN** `tidy(fit, conf_level = 0.9, estimate = mean, sig_fig = 4)` is called
- **THEN** it returns posterior means with 90% compatibility limits to 4 significant figures

#### Scenario: Group effects are named by level
- **WHEN** `tidy(fit, include_random_effects = TRUE)` is called on a fit with site effects
- **THEN** each site effect's term is `site_effect[` followed by its site name and `]`, one per fitted site

### Requirement: Omitted effects are not reported

An effect the fit omitted (site:year for single-year data, density when not fitted, or the weight floor of a power-law fit) SHALL NOT appear in `tidy()`, `coef()`, `summary()`, or `kb_model_describe()`, since its draws never met the data.

#### Scenario: An omitted effect is absent
- **WHEN** a fit omitted the site:year, density, or floor term
- **THEN** its terms appear in none of `tidy()`, `summary()`, or `kb_model_describe()`, including under `include_random_effects = TRUE`

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

### Requirement: Fitted values, residuals, and augment

`fitted()` SHALL return the posterior median of the expected response at each observed row (weight, size, the dry:wet ratio, the carbon fraction, for density the expected count on that row's transect area, or for cover the expected wet biomass per m² of that row's plot), and `residuals()` the posterior median of the deviance residual under the model's likelihood. `augment()` SHALL return the input data with `fitted` and `residual` columns equal to those values, and no interval columns added.

#### Scenario: augment agrees with fitted and residuals
- **WHEN** `augment(fit)` is called on a weight, size, density, wet/dry, carbon, or cover biomass fit
- **THEN** its `fitted` and `residual` columns equal `fitted(fit)` and `residuals(fit)`

#### Scenario: augment keeps the in situ biomass of a cover biomass fit
- **WHEN** `augment(fit)` is called on a cover biomass fit
- **THEN** it returns the fitted surveys with their paired `estimate`, `lower`, and `upper` columns unchanged

### Requirement: Print and summary

`print(fit)` SHALL show a header with the model and species, the predictor and its reference value (for a model with a predictor), the observation count and any group counts, the sampler settings, the convergence verdict, and a prior-only note when applicable, followed by a pointer to `kb_model_describe()`, with no parameter estimates. `summary(fit)` SHALL return an object whose print shows the same header, a table of `term`, `estimate`, `lower`, `upper`, `rhat`, `ess_bulk`, and `ess_tail` (per-level effects only with `include_random_effects = TRUE`), and a footer with the divergence rate, treedepth-saturation rate, and minimum E-BFMI. The output is pinned by `tests/testthat/_snaps/print.md` and `tests/testthat/_snaps/summary.md`.

#### Scenario: print shows no estimates
- **WHEN** `print(fit)` is called
- **THEN** it shows the header and no parameter estimates

#### Scenario: A size fit has no predictor line
- **WHEN** `print()` is called on a size fit
- **THEN** the header has no predictor line

#### Scenario: A density fit has no predictor line
- **WHEN** `print()` is called on a density fit
- **THEN** the header has no predictor line, since the area is an offset rather than a predictor

#### Scenario: A cover biomass fit has no predictor line
- **WHEN** `print()` is called on a cover biomass fit
- **THEN** the header has no predictor line, since cover is derived from the canopy, plot, and tide columns rather than supplied

#### Scenario: A wet/dry fit has no predictor or group line
- **WHEN** `print()` is called on a wet/dry fit whose data have no `site` or `year` column
- **THEN** the header shows the observation count with no predictor or group counts

### Requirement: Model description

`kb_model_describe(fit)` SHALL print the fitted model in notation using the package's parameter names (the same terms as `tidy()`), with no Greek letters or R formula syntax, and `kb_model_describe(fit, prose = TRUE)` the same model as a methods paragraph; both SHALL return the lines invisibly. The description SHALL reflect the fit, not the defaults: its stored priors, its predictor reference and density standardisation, and only the effects it fitted. Priors truncated at zero SHALL be marked `T[0, ]`. The content for each model is pinned by `tests/testthat/_snaps/kb_model_describe.md`.

#### Scenario: The description follows the fit
- **WHEN** a fit used custom priors or omitted an effect
- **THEN** the description shows those priors and leaves the omitted effect out

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

### Requirement: Posterior predictive check

`pp_check(object, type = c("response", "residual"), ..., ndraws = 50)` SHALL be available after `library(kelpbio)` for any fit and SHALL return a `ggplot` overlaying the density of the observed values on the densities of `ndraws` replicate datasets, each simulated at the observed rows from one posterior draw chosen at random. With `type = "response"` the values SHALL be the recorded response (weight, size, dry:wet ratio, carbon fraction, or in situ biomass estimate), or for a density model the transect count divided by the transect's area, and the x-axis SHALL be titled with it (for density, as a density per m²). With `type = "residual"` the observed values SHALL be `residuals(object)`, each replicate's values SHALL be the deviance residuals of that replicate under the draw that generated it, and the x-axis SHALL be titled "Deviance residual". Repeated calls SHALL differ unless a seed is set. `ndraws` SHALL be a whole number from 1 to the number of draws in the fit, and `...` SHALL be empty. A fit with no observations SHALL error.

#### Scenario: Response check by default
- **WHEN** `pp_check(fit)` is called
- **THEN** it returns a `ggplot` with the observed response and 50 replicate datasets, and the x-axis titled with the response

#### Scenario: Density is compared per m²
- **WHEN** `pp_check(fit)` is called on a density fit
- **THEN** the observed and replicate counts are divided by their transect's area and the x-axis is titled as a density per m²

#### Scenario: Residual check
- **WHEN** `pp_check(fit, "residual")` is called
- **THEN** the observed values equal `residuals(fit)` and the x-axis is titled "Deviance residual"

#### Scenario: Number of replicates
- **WHEN** `pp_check(fit, ndraws = 10)` is called
- **THEN** the plot holds 10 replicate datasets

#### Scenario: Reproducible under a seed
- **WHEN** `pp_check()` is called twice with the same seed
- **THEN** the replicate values are identical

#### Scenario: Invalid ndraws
- **WHEN** `ndraws` is not a whole number or exceeds the fit's number of draws
- **THEN** it errors naming `ndraws`

#### Scenario: No observations
- **WHEN** `pp_check()` is called on a fit with no observations
- **THEN** it errors

### Requirement: Leave-one-out cross-validation

`loo()` and `loo_compare()` SHALL be available after `library(kelpbio)`. `loo(x, ...)` SHALL accept any fit and SHALL return a `psis_loo` object computed by Pareto-smoothed importance sampling from the stored draws and `log_lik(x)`, with relative efficiencies computed from the fit's chains, without refitting. It SHALL hold one pointwise row per observation, in the order of the fitted data, with the expected log predictive density and the Pareto k diagnostic, and SHALL be accepted by `loo_compare()`. `...` SHALL be passed to loo. A fit made with `prior_only = TRUE` or with no observations SHALL error.

#### Scenario: PSIS-LOO on a fit
- **WHEN** `loo(fit)` is called after `library(kelpbio)`
- **THEN** it returns a `psis_loo` object with one pointwise row per observation

#### Scenario: Relative efficiencies use the chains
- **WHEN** `loo(fit)` is called
- **THEN** its estimates equal those of `loo::loo()` on `log_lik(fit)` with relative efficiencies computed from the fit's chains

#### Scenario: Fits of the same response can be compared
- **WHEN** `loo_compare()` is given the `loo()` results of two fits to the same data
- **THEN** it returns their comparison

#### Scenario: A fit without a likelihood errors
- **WHEN** `loo()` is called on a fit made with `prior_only = TRUE` or with no observations
- **THEN** it errors stating that the fit has no likelihood to cross-validate

### Requirement: Influential observations

`kb_influence(fit, ..., threshold = 0.7)` SHALL return the fitted data as a tibble, one row per observation in the fitted order, with added columns `elpd_loo` and `pareto_k` (the pointwise values of `loo(fit)`) and `influential` (`pareto_k` greater than `threshold`). The result SHALL be computed from the stored fit, without refitting, and SHALL NOT warn about high Pareto k values, which the `influential` column reports. `threshold` SHALL be a number greater than 0, and `...` SHALL be empty. A fit made with `prior_only = TRUE` or with no observations SHALL error.

#### Scenario: One row per observation
- **WHEN** `kb_influence(fit)` is called
- **THEN** it returns the fitted data with `elpd_loo`, `pareto_k`, and `influential` added, one row per observation

#### Scenario: Values match loo
- **WHEN** `kb_influence(fit)` is called
- **THEN** `elpd_loo` and `pareto_k` equal the pointwise values of `loo(fit)`

#### Scenario: The threshold sets the flag
- **WHEN** `threshold` is changed
- **THEN** `influential` changes accordingly and `elpd_loo` and `pareto_k` do not

#### Scenario: A fit without a likelihood errors
- **WHEN** `kb_influence()` is called on a fit made with `prior_only = TRUE` or with no observations
- **THEN** it errors stating that the fit has no likelihood to cross-validate

