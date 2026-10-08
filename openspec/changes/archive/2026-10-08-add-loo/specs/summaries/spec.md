## ADDED Requirements

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
