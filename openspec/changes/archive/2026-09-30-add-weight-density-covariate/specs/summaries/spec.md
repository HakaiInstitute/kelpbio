## ADDED Requirements

### Requirement: The density term is reported only when fitted

`tidy()`, `coef()`, and `summary()` SHALL include a `bDensity` row for a *Nereocystis* weight fit whose `meta$density_on` is `TRUE`, and SHALL NOT include it otherwise, since the draws of an omitted term never met the likelihood.

#### Scenario: Density fit reports bDensity
- **WHEN** `tidy(fit)` is called on a fit with `meta$density_on` `TRUE`
- **THEN** the result has a `bDensity` row

#### Scenario: Fit without density omits bDensity
- **WHEN** `tidy(fit)` is called on a fit with `meta$density_on` `FALSE`
- **THEN** the result has no `bDensity` row
