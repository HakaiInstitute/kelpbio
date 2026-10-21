## MODIFIED Requirements

### Requirement: Trace plot

`kb_plot_trace(fit, ...)` SHALL return a `ggplot` of the draws of each term `tidy(fit)` reports, against iteration, one panel per term in `ncol` columns (a name-only whole number, default 2), each with its own y-axis, and one line per chain, coloured by chain with a legend titled "Chain" and the x-axis titled "Iteration". It SHALL set no theme, so the active theme applies. `...` SHALL be empty, and `fit` SHALL be a kelpbio fit.

#### Scenario: One panel per term
- **WHEN** `kb_plot_trace(fit)` is called
- **THEN** it returns a `ggplot` with one panel for each term of `tidy(fit)` and one line per chain

#### Scenario: A non-fit errors
- **WHEN** `kb_plot_trace(1)` is called
- **THEN** it errors stating the required class

### Requirement: Prior sensitivity

`kb_sensitivity(fit, ..., prior_threshold = 0.1, likelihood_threshold = 0.05)` SHALL return a tibble with one row per estimated parameter that has a prior, and columns `term` (the parameter, as in `tidy()`, which is also the name of its prior's entry in the model's `kb_priors_*()` list), `prior_cjs` and `likelihood_cjs` (the power-scaling sensitivity of the parameter's posterior to the prior and to the likelihood, as computed by priorsense), `weak_prior` (`prior_cjs` less than `prior_threshold`), `strong_data` (`likelihood_cjs` greater than or equal to `likelihood_threshold`), and `informative_prior` (`TRUE` for a parameter whose prior is informative by design, so that its prior dominating the data is expected rather than a problem). The cover calibration's `tide_height_slope`, whose default prior comes from published estimates, SHALL be the only such parameter, whatever prior was used; the documentation SHALL say which parameters are marked and why. Random-effect levels and derived quantities SHALL NOT be reported. The result SHALL be computed from the stored fit, without refitting. `prior_threshold` and `likelihood_threshold` SHALL be numbers greater than 0, and `...` SHALL be empty.

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

#### Scenario: Priors informative by design are marked
- **WHEN** `kb_sensitivity()` is called on a cover calibration fit
- **THEN** `informative_prior` is `TRUE` for `tide_height_slope` and `FALSE` for every other term, and on every other model's fit it is `FALSE` for every term
