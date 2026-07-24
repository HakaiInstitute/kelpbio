## MODIFIED Requirements

### Requirement: Tidy and group-level summaries

`tidy(x, conf_level, estimate, sig_fig, include_random_effects)` and `coef()`
SHALL summarise a `kb_fit` from its stored draws, with output columns `term`,
`estimate`, `lower`, `upper` and the behaviour already specified for
`conf_level` / `estimate` / `sig_fig` / `include_random_effects`. The set of
`term` rows is species-specific, selected on `meta$species`.

#### Scenario: Macro tidy returns the macro term list
- **WHEN** `tidy(macro_fit)` is called
- **THEN** it returns one row per population-level term (`bWeight`, `bFronds`),
  the Gamma shape (`alpha`), and each random-effect SD (`sSite`, `sYear`,
  `sSiteYear`), with the per-level deviations (`bSite[.]`, `bYear[.]`,
  `bSiteYear[.,.]`) omitted by default and added when `include_random_effects =
  TRUE`

### Requirement: Fitted values and deviance residuals

`fitted(object)` SHALL return a numeric vector of posterior point estimates of
the expected weight at each observed row, on the response scale (the posterior
median of `posterior_epred()`), for both species. `residuals(object)` SHALL
return a numeric vector of deviance residuals at each observed row, computed per
draw from the fitted likelihood and summarised to the posterior median: from the
Student-t log-weight likelihood for nereo, and from the Gamma likelihood (shape
`alpha * fronds`, rate `shape / eWeight`) for macro. Both return a vector of
length `nobs(object)`. Neither takes interval or `estimate` arguments, and
`residuals()` SHALL NOT take a residual-type argument.

#### Scenario: Macro residuals are Gamma deviance residuals
- **WHEN** `residuals(macro_fit)` is called
- **THEN** it returns a numeric vector of length `nobs(macro_fit)` of Gamma
  deviance residuals whose values equal `augment(macro_fit)$residual`

### Requirement: Summary and print methods

`summary(x)` and `print(x)` SHALL render a shared fit-metadata header (model and
species, likelihood family, fixed- and random-effect structure, observation and
group counts, sampler configuration, convergence verdict) from a single shared
renderer, with the coefficient table and diagnostics footer as already specified.
The header's family and effect-structure prose is species-specific, selected on
`meta$species`: nereo reports a Student-t (df = 4) likelihood on log-weight with
site intercept, site slope, and site:year effects; macro reports a Gamma
likelihood (shape proportional to frond count) on weight with site intercept,
year, and site:year effects.

#### Scenario: Macro header reports the Gamma family and macro structure
- **WHEN** `print(macro_fit)` or `print(summary(macro_fit))` is called
- **THEN** the header shows `species = macrocystis`, a Gamma family string, and
  the fixed (`bWeight`, `bFronds`) and random (`bSite`, `bYear`, `bSiteYear`)
  structure, with no raw MCMC numerics in `print()`
