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

### Requirement: Tidy and group-level summaries

`tidy(x, conf_level, estimate, sig_fig, include_random_effects)` and `coef()` SHALL summarise a `kb_fit` from its stored draws. `tidy()` carries `conf_level` (default `0.95`), `estimate` (a point-estimate function, default `median`), `sig_fig` (default `3`), and `include_random_effects` (default `FALSE`, omitting the per-level group deviations and leaving the population-level terms and random-effect SDs, following the `broom.mixed` convention). `coef()` is a pure wrapper on `tidy()` forwarding all arguments, so it inherits the same default. Output columns are `term`, `estimate`, `lower`, `upper` (the house convention shared with `bboutools`/`ssdtools`), with `lower`/`upper` the `conf_level` compatibility limits from the posterior draws and all numeric columns rounded to `sig_fig`. The set of `term` rows is model- and species-specific, chosen by the `.terms()` internal generic dispatching on the fit subclass. A random effect the fit dropped (`meta$site_year_on` is `FALSE`) SHALL NOT appear: its draws never met the likelihood, so reporting `sSiteYear` or `bSiteYear[.,.]` would present the prior as an estimate. `tidy()`, `coef()` and `summary()` therefore agree with `kb_model_describe()` about which effects the fit has.

#### Scenario: tidy returns term summaries with house columns
- **WHEN** `tidy(fit)` is called
- **THEN** it returns a tibble with columns `term`, `estimate`, `lower`, `upper`, one row per population-level term (`bWeight`, `bDiameter`, `bDiameter2`) and per random-effect SD (`sSite`, `sSiteDiameter`, `sSiteYear`, `sWeight`), with the per-level group deviations (`bSite[.]`, `bSiteDiameter[.]`, `bSiteYear[.,.]`) omitted because `include_random_effects` defaults to `FALSE`

#### Scenario: A dropped random effect is not reported

- **WHEN** `tidy()`, `coef()` or `summary()` is called on a fit whose `meta$site_year_on` is `FALSE`
- **THEN** no `sSiteYear` row appears, and no `bSiteYear[.,.]` row appears under `include_random_effects = TRUE`

#### Scenario: tidy honours estimate, sig_fig, and conf_level
- **WHEN** `tidy(fit, conf_level = 0.9, estimate = mean, sig_fig = 4)` is called
- **THEN** `estimate` is the posterior mean, `lower`/`upper` are the 90% compatibility limits, and the numeric columns are rounded to 4 significant figures

#### Scenario: include_random_effects toggles group-level rows
- **WHEN** `tidy(fit, include_random_effects = TRUE)` is called
- **THEN** the per-level random-effect rows (`bSite[.]`, `bSiteDiameter[.]`, `bSiteYear[.,.]`) are included alongside the population-level terms and SDs

#### Scenario: coef wraps tidy
- **WHEN** `coef(fit)` is called
- **THEN** it returns the same tibble as `tidy(fit)`, forwarding all arguments

#### Scenario: Macro tidy returns the macro term list
- **WHEN** `tidy(macro_fit)` is called
- **THEN** it returns one row per population-level term (`bWeight`, `bFronds`), the Gamma shape (`shape`), and each random-effect SD (`sSite`, `sYear`, `sSiteYear`), with the per-level deviations (`bSite[.]`, `bYear[.]`, `bSiteYear[.,.]`) omitted by default and added when `include_random_effects = TRUE`
