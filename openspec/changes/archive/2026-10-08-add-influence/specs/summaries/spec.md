## ADDED Requirements

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
