# model-description Specification

## Purpose
TBD - created by archiving change add-model-describe. Update Purpose after archive.
## Requirements
### Requirement: Model description in scientific notation

`kb_model_describe(fit, prose = FALSE)` SHALL render the complete fitted model and return the rendered character vector invisibly. It is an S3 generic dispatching on the fit's species subclass. With `prose = FALSE` (default) it prints a multilevel scientific-notation block: the likelihood, the linear predictor for the (log) mean, the random-effect distributions, and the priors. With `prose = TRUE` it prints the same content as a report-ready methods paragraph. Both forms are derived from a single model descriptor, so they cannot disagree.

The notation SHALL use the package's own parameter names (`bWeight`, `bDiameter`, `bDiameter2`, `sSite`, `sSiteDiameter`, `sSiteYear`, `sWeight` for *Nereocystis*; `bWeight`, `bFronds`, `shape`, `sSite`, `sYear`, `sSiteYear` for *Macrocystis*), so every symbol in the equation matches a row of `tidy()` / `summary()` / `coef()`. It SHALL NOT introduce Greek symbols or an R-formula (`~ (1|group)`) syntax.

The description SHALL reflect the fitted instance, not the defaults: the priors SHALL be the fit's stored priors (`meta$priors`); the centering reference SHALL be the fit's stored `d0` / `f0` (`meta$diameter_ref` / `meta$fronds_ref`), shown as a bare number without units; the fixed Student-t degrees of freedom SHALL be shown as the constant `4`, not as a parameter; and when `site_year_on` is `FALSE` the `site:year` term SHALL be omitted from both the linear predictor and the random-effect list. The response and predictor SHALL be named descriptively (for example "wet weight", "sub-bulb diameter", "frond count") without units, because the data columns are unitless and the model is scale-invariant.

#### Scenario: Notation block for a Nereocystis fit
- **WHEN** `kb_model_describe(nereo_fit)` is called
- **THEN** it prints a block with the likelihood `log(weight) ~ Student-t(4, mu, sWeight)`, a linear predictor for `mu` in the package parameter names (intercept `bWeight`, `bSite[site]`, `(bDiameter + bSiteDiameter[site]) * x`, `bDiameter2 * x^2`, `bSiteYear[site, year]`) with `x = log(diameter) - log(d0)`, the random-effect distributions `~ Normal(0, sSite)` / `Normal(0, sSiteDiameter)` / `Normal(0, sSiteYear)`, and the priors from the fit

#### Scenario: Notation block for a Macrocystis fit
- **WHEN** `kb_model_describe(macro_fit)` is called
- **THEN** it prints `weight ~ Gamma(shape, shape / mu)`, a linear predictor with `bFronds` and the site / year / site:year random intercepts, the random-effect distributions, and the fit's priors

#### Scenario: Reflects stored priors and centering
- **WHEN** the fit was made with custom priors or a non-default centering reference
- **THEN** the rendered priors and the `d0` / `f0` value match the fit's stored priors and reference, not the package defaults

#### Scenario: Respects a dropped site:year effect
- **WHEN** `kb_model_describe(fit)` is called on a fit whose `meta$site_year_on` is `FALSE`
- **THEN** the `site:year` term is absent from the linear predictor and no `site:year` random-effect line is shown

#### Scenario: Prose methods paragraph
- **WHEN** `kb_model_describe(fit, prose = TRUE)` is called
- **THEN** it prints a methods-section paragraph describing the same likelihood, mean structure, centering, random effects, and priors, suitable for a report

