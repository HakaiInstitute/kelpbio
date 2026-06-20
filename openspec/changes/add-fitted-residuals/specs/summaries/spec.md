## ADDED Requirements

### Requirement: Fitted values and deviance residuals

`fitted(object)` SHALL return a numeric vector of posterior point estimates of the expected weight at each observed row, on the response scale (the posterior median of `posterior_epred()` at the observed data). `residuals(object)` SHALL return a numeric vector of deviance residuals at each observed row, from the Student-t log-weight likelihood, computed via `extras::res_student(log(weight), fit, sd = sWeight, theta = 1 / nu)` per draw and summarised to a point estimate. Both return a vector of length `nobs(object)`, suitable for appending to the data. `residuals()` SHALL NOT take a residual-type argument.

#### Scenario: fitted returns response-scale point estimates
- **WHEN** `fitted(fit)` is called
- **THEN** it returns a numeric vector of length `nobs(fit)` of positive expected weights whose values equal `augment(fit)$fitted`

#### Scenario: residuals returns deviance residuals
- **WHEN** `residuals(fit)` is called
- **THEN** it returns a numeric vector of length `nobs(fit)` of deviance residuals whose values equal `augment(fit)$residual`

## MODIFIED Requirements

### Requirement: Augmented fitted values

`augment(x)` SHALL return the input data with two columns appended: `fitted` (response-scale fitted weight, from `fitted(x)`) and `residual` (deviance residual, from `residuals(x)`), evaluated at the observed rows. The columns SHALL be taken directly from the `fitted()` and `residuals()` methods so they cannot diverge from them. `augment()` SHALL NOT add interval (`lower`/`upper`) columns; prediction intervals are obtained from `kb_predict_weight()`.

#### Scenario: augment adds fitted/residual columns
- **WHEN** `augment(fit)` is called
- **THEN** it returns the original data columns plus `fitted` and `residual` (and no `lower`/`upper`), with `fitted` matching `fitted(fit)` and `residual` matching `residuals(fit)`
