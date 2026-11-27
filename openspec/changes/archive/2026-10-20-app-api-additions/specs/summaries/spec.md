## ADDED Requirements

### Requirement: Trace plot

`kb_plot_trace(fit, ...)` SHALL return a `ggplot` of the draws of each term `tidy(fit)` reports, against iteration, one panel per term and one line per chain. `...` SHALL be empty, and `fit` SHALL be a kelpbio fit.

#### Scenario: One panel per term
- **WHEN** `kb_plot_trace(fit)` is called
- **THEN** it returns a `ggplot` with one panel for each term of `tidy(fit)` and one line per chain

#### Scenario: A non-fit errors
- **WHEN** `kb_plot_trace(1)` is called
- **THEN** it errors stating the required class

## MODIFIED Requirements

### Requirement: Print and summary

`print(fit)` SHALL show a header with the model and species, the predictor and its reference value (for a model with a predictor), the observation count and any group counts, the sampler settings, the convergence verdict, and a prior-only note when applicable, followed by a pointer to `kb_model_describe()`, with no parameter estimates. `summary(fit)` SHALL return an object whose print shows the same header, a table of `term`, `estimate`, `lower`, `upper`, `rhat`, `ess_bulk`, `ess_tail`, and `converged` (per-level effects only with `include_random_effects = TRUE`), and a footer with the divergence rate, treedepth-saturation rate, and minimum E-BFMI. A term's `converged` SHALL be `TRUE` when its Rhat is below `rhat` and its bulk and tail effective sample sizes are at least `ess` times the number of chains, with the thresholds and missing-value handling of `kb_converged()`. `summary()` SHALL take name-only `rhat` (default 1.01) and `ess` (default 100), and its header's convergence verdict SHALL use the same values. The output is pinned by `tests/testthat/_snaps/print.md` and `tests/testthat/_snaps/summary.md`.

#### Scenario: print shows no estimates
- **WHEN** `print(fit)` is called
- **THEN** it shows the header and no parameter estimates

#### Scenario: A size fit has no predictor line
- **WHEN** `print()` is called on a size fit
- **THEN** the header has no predictor line

#### Scenario: A cover calibration fit has no predictor line
- **WHEN** `print()` is called on a cover calibration fit
- **THEN** the header has no predictor line, since cover is derived from the canopy, plot, and tide columns rather than supplied

#### Scenario: A wet/dry fit has no predictor or group line
- **WHEN** `print()` is called on a wet/dry fit whose data have no `site` or `year` column
- **THEN** the header shows the observation count with no predictor or group counts

#### Scenario: Per-term convergence agrees with the verdict
- **WHEN** a term in the `summary(fit)` table has `converged` of `FALSE`
- **THEN** the header verdict is `FALSE`

#### Scenario: Thresholds are passed through
- **WHEN** `summary(fit, rhat = 1.05, ess = 10)` is called
- **THEN** each term's `converged` and the header verdict use those thresholds
