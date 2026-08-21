## MODIFIED Requirements

### Requirement: Fitted values and deviance residuals

`fitted(object)` SHALL return a numeric vector of posterior point estimates at each observed row, on the response scale (the posterior median of `posterior_epred()` at the observed data; the full posterior is available from `posterior_epred()`). Note the *Nereocystis* likelihood is a Student-t on log weight, whose response-scale expectation does not exist, so the value there is the conditional median rather than a mean; the per-model likelihood is reported by `kb_model_describe()`. `residuals(object)` SHALL return a numeric vector of deviance residuals at each observed row, computed per draw from the fitted likelihood and summarised to the posterior median: the Student-t log-weight likelihood for *Nereocystis*, and the Gamma likelihood (shape `shape`, rate `shape / eWeight`) for *Macrocystis*. Both return a vector of length `nobs(object)`, suitable for appending to the data. Neither takes interval or `estimate` arguments, and `residuals()` SHALL NOT take a residual-type argument.

#### Scenario: fitted returns response-scale point estimates
- **WHEN** `fitted(fit)` is called
- **THEN** it returns a numeric vector of length `nobs(fit)` of positive response-scale values whose values equal `augment(fit)$fitted`

#### Scenario: residuals returns deviance residuals
- **WHEN** `residuals(fit)` is called
- **THEN** it returns a numeric vector of length `nobs(fit)` of deviance residuals whose values equal `augment(fit)$residual`

#### Scenario: Macro residuals are Gamma deviance residuals
- **WHEN** `residuals(macro_fit)` is called
- **THEN** it returns a numeric vector of length `nobs(macro_fit)` of Gamma deviance residuals whose values equal `augment(macro_fit)$residual`
