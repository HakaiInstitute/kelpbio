## MODIFIED Requirements

### Requirement: Tidy and group-level summaries

`tidy(x, conf_level, estimate, sig_fig, include_random_effects)` and `coef()` SHALL summarise a `kb_fit` from its stored draws. `tidy()` carries `conf_level` (default `0.95`), `estimate` (a point-estimate function, default `median`), `sig_fig` (default `3`), and `include_random_effects` (default `FALSE`, omitting the per-level group deviations and leaving the population-level terms and random-effect SDs, following the `broom.mixed` convention). `coef()` is a pure wrapper on `tidy()` forwarding all arguments, so it inherits the same default. Output columns are `term`, `estimate`, `lower`, `upper` (the house convention shared with `bboutools`/`ssdtools`), with `lower`/`upper` the `conf_level` compatibility limits from the posterior draws and all numeric columns rounded to `sig_fig`. The set of `term` rows is species-specific, selected on `meta$species`.

#### Scenario: tidy returns term summaries with house columns
- **WHEN** `tidy(fit)` is called
- **THEN** it returns a tibble with columns `term`, `estimate`, `lower`, `upper`, one row per population-level term (`bWeight`, `bDiameter`, `bDiameter2`) and per random-effect SD (`sSite`, `sSiteDiameter`, `sSiteYear`, `sWeight`), with the per-level group deviations (`bSite[.]`, `bSiteDiameter[.]`, `bSiteYear[.,.]`) omitted because `include_random_effects` defaults to `FALSE`

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
- **THEN** it returns one row per population-level term (`bWeight`, `bFronds`), the Gamma shape (`alpha`), and each random-effect SD (`sSite`, `sYear`, `sSiteYear`), with the per-level deviations (`bSite[.]`, `bYear[.]`, `bSiteYear[.,.]`) omitted by default and added when `include_random_effects = TRUE`

### Requirement: Fitted values and deviance residuals

`fitted(object)` SHALL return a numeric vector of posterior point estimates of the expected weight at each observed row, on the response scale (the posterior median of `posterior_epred()` at the observed data; the full posterior is available from `posterior_epred()`). `residuals(object)` SHALL return a numeric vector of deviance residuals at each observed row, computed per draw from the fitted likelihood and summarised to the posterior median: the Student-t log-weight likelihood for *Nereocystis*, and the Gamma likelihood (shape `alpha * fronds`, rate `shape / eWeight`) for *Macrocystis*. Both return a vector of length `nobs(object)`, suitable for appending to the data. Neither takes interval or `estimate` arguments, and `residuals()` SHALL NOT take a residual-type argument.

#### Scenario: fitted returns response-scale point estimates
- **WHEN** `fitted(fit)` is called
- **THEN** it returns a numeric vector of length `nobs(fit)` of positive expected weights whose values equal `augment(fit)$fitted`

#### Scenario: residuals returns deviance residuals
- **WHEN** `residuals(fit)` is called
- **THEN** it returns a numeric vector of length `nobs(fit)` of deviance residuals whose values equal `augment(fit)$residual`

#### Scenario: Macro residuals are Gamma deviance residuals
- **WHEN** `residuals(macro_fit)` is called
- **THEN** it returns a numeric vector of length `nobs(macro_fit)` of Gamma deviance residuals whose values equal `augment(macro_fit)$residual`

### Requirement: Summary and print methods

`summary(x)` SHALL return a classed `summary_kb_fit` object collecting fit-level metadata and a per-term posterior summary table (with its own `print` method), laid out as a fit-metadata header, a coefficient table, and a diagnostics footer. The header SHALL describe the model's effect structure in prose (fixed- and random-effect terms) rather than a mixed-model formula, so the output does not imply a formula interface or a particular fitting engine. `print(x)` and the summary object SHALL render the same fit-metadata header (model and species, likelihood family, fixed- and random-effect structure, observation and group counts, sampler configuration, convergence verdict) from a single shared renderer, so the two cannot diverge. The header's family and effect-structure prose is species-specific, selected on `meta$species`: *Nereocystis* reports a Student-t (df = 4) likelihood on log-weight with site intercept, site slope, and site:year effects; *Macrocystis* reports a Gamma likelihood (shape proportional to frond count) on weight with site intercept, year, and site:year effects. `print(x)` SHALL display only that header, without embedding raw MCMC numbers, so it is snapshot-testable.

The `summary_kb_fit` coefficient table SHALL carry columns `term`, `estimate`, `lower`, `upper`, `rhat`, `ess_bulk`, `ess_tail`, with the diagnostic columns taken from the stored fit diagnostics (the same source as `converged()`/`glance()`). It SHALL show population-level terms and random-effect SDs, including the per-level group deviations only when `include_random_effects = TRUE` (default `FALSE`, matching `tidy()`). Its `print` method SHALL render the shared header, the coefficient table, and a diagnostics footer defining the columns and reporting the divergent-transition count.

#### Scenario: print shows stable metadata
- **WHEN** `print(fit)` is called
- **THEN** it shows the shared fit-metadata header (model, species, family, fixed- and random-effect structure, observation and group counts, sampler configuration, convergence) with no coefficient table, footer, or raw MCMC numerics, identical to the header shown by `print(summary(fit))`

#### Scenario: summary returns metadata and a diagnostic table
- **WHEN** `summary(fit)` is called
- **THEN** it returns a `summary_kb_fit` object carrying fit metadata (family, fixed- and random-effect structure, observation and group counts, sampler draws) and a `coefficients` tibble with columns `term`, `estimate`, `lower`, `upper`, `rhat`, `ess_bulk`, `ess_tail`, whose `print` method renders the header, table, and diagnostics footer

#### Scenario: summary omits group-level deviations by default
- **WHEN** `summary(fit)` is called
- **THEN** the per-level deviations (`bSite[.]`, `bSiteDiameter[.]`, `bSiteYear[.,.]`) are omitted and the random-effect SDs are retained; `summary(fit, include_random_effects = TRUE)` adds the per-level rows

#### Scenario: Macro header reports the Gamma family and macro structure
- **WHEN** `print(macro_fit)` or `print(summary(macro_fit))` is called
- **THEN** the header shows `species = macrocystis`, a Gamma family string, and the fixed (`bWeight`, `bFronds`) and random (`bSite`, `bYear`, `bSiteYear`) structure, with no raw MCMC numerics in `print()`
