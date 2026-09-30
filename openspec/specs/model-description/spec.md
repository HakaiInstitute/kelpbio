# model-description Specification

## Purpose

Rendering a fitted model as a description: kb_model_describe() over any kb_fit,
in scientific notation or as a report-ready methods paragraph.

## Requirements
### Requirement: Model description in scientific notation

`kb_model_describe(fit, prose = FALSE)` SHALL render the complete fitted model and return the rendered character vector invisibly. It is an S3 generic dispatching on the fit's sub-model and species subclass, accepting any `kb_fit`; each sub-model registers its own method. With `prose = FALSE` (default) it prints a multilevel scientific-notation block: the likelihood, the linear predictor for the (log) mean, the random-effect distributions, and the priors. With `prose = TRUE` it prints the same content as a report-ready methods paragraph. Both forms are derived from a single model descriptor, so they cannot disagree.

The notation SHALL use the package's own parameter names (`bWeight`, `bPower`, `bFloor`, `sSite`, `sYear`, `sSiteYear`, `sWeight` for *Nereocystis*; `bWeight`, `bFronds`, `shape`, `sSite`, `sYear`, `sSiteYear` for *Macrocystis*), so every symbol in the equation matches a row of `tidy()` / `summary()` / `coef()`. It SHALL NOT introduce Greek symbols or an R-formula (`~ (1|group)`) syntax.

The description SHALL reflect the fitted instance, not the defaults: the priors SHALL be the fit's stored priors (`meta$priors`); the centering reference SHALL be the fit's stored `d0` / `f0` (`meta$predictor_ref`), shown as a bare number; priors on parameters constrained to be positive SHALL be marked `T[0, ]`; and when `site_year_on` is `FALSE` the `site:year` term SHALL be omitted from both the linear predictor and the random-effect list. The response and predictor SHALL be named descriptively (for example "wet weight", "sub-bulb diameter", "frond count"), with units where the default priors assume them (*Nereocystis* weight in kg and diameter in mm).

#### Scenario: Notation block for a Nereocystis fit
- **WHEN** `kb_model_describe(nereo_fit)` is called
- **THEN** it prints a block with the likelihood `log(weight) ~ Normal(log(mu), sWeight)`, the mean `mu = bFloor + alpha * x^bPower`, a linear predictor for `log(alpha)` in the package parameter names (`bWeight`, `bYear[year]`, `bSite[site]`, `bSiteYear[site, year]`) with `x = diameter / d0`, the random-effect distributions `~ Normal(0, sYear)` / `Normal(0, sSite)` / `Normal(0, sSiteYear)`, and the priors from the fit

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

