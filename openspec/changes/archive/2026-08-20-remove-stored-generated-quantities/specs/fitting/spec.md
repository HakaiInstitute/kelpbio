## MODIFIED Requirements

### Requirement: Fit object stores draws, not the stanfit

The returned `kb_fit` SHALL store extracted posterior draws (a `posterior` draws object) plus sampler diagnostics, the input data, and resolved metadata — and SHALL NOT retain the live `stanfit`.

The fit SHALL NOT store any per-observation quantity. Neither the pointwise
log-likelihood nor posterior-predictive replicates are retained: both scale as
`nObs x ndraws` and would dominate the object, so both are recomputed in R from
the stored draws on demand. Object size is therefore a function of the draw count
alone, not of the number of observations.

The stored sampler diagnostics SHALL comprise the per-parameter Rhat and bulk/tail
effective sample sizes, and the run-level divergent-transition count, divergence
rate, treedepth-saturation rate, and minimum E-BFMI across chains. Every one of
these SHALL be computed while the `stanfit` is still in scope, since none can be
recovered from the stored draws afterwards.

The rates SHALL be derived from rstan's own per-iteration diagnostic vectors, so
the numerator and the denominator come from one source and the reported
percentages match the warnings rstan itself would emit. Because rstan records
sampler parameters per saved iteration, a rate is over retained draws: with
`nthin > 1` divergences on thinned-away iterations are not observable.

#### Scenario: Draws and diagnostics are retained, stanfit discarded
- **WHEN** the fit object is inspected
- **THEN** it exposes posterior draws (the fixed effects `bWeight`, `bDiameter`, `bDiameter2`; the SDs `sSite`, `sSiteDiameter`, `sSiteYear`, `sWeight`; the per-site `bSite` and `bSiteDiameter`; the site-by-year `bSiteYear`) and diagnostics, and contains no live `stanfit`

#### Scenario: Sampler diagnostics survive the stanfit
- **WHEN** the fit object is inspected
- **THEN** its diagnostics carry the divergent-transition count, the divergence and treedepth-saturation rates, and the minimum E-BFMI, so `converged()`, `glance()`, and `print(summary(fit))` need no live `stanfit`

#### Scenario: A rate with no draws is unknown, not zero
- **WHEN** a rate would be computed against an empty denominator
- **THEN** it is `NA`, so the verdict surfaces the missing evidence rather than passing

### Requirement: Fit the Macrocystis weight model

`kb_fit_weight_macro(data, priors, ..., prior_only, chains, niters, nthin,
cores, seed, progress, progress_dir)` SHALL fit the *Macrocystis pyrifera*
allometric weight model via `stanmodels$weight_macro` and return an object of
class `c("kb_fit_weight_macro", "kb_fit_weight", "kb_fit")`. The model is a Gamma GLM: the expected
weight is `exp(bWeight + bSite[site] + bFronds * (log(fronds) -
log(fronds_ref)) + bYear[year] + site:year)`, and the response is
`weight ~ Gamma(shape, shape / eWeight)`, a constant Gamma shape
`shape`. The species is
fixed by the function (there is no `species` argument); it is recorded as
`"macrocystis"` in `meta$species`. The site:year effect is data-determined by the
same rule as the *Nereocystis* model (included when the data span more than one
distinct year, omitted otherwise, retained with a `cli` warning under an aliased
design) and recorded in `meta$site_year_on`. The sampler invocation, draw
extraction, and diagnostics are delegated to the shared internal engine
`fit_stan()`.

#### Scenario: Returns a kb_fit_weight object
- **WHEN** `kb_fit_weight_macro()` is called on valid macro weight data
- **THEN** it returns an object of class `c("kb_fit_weight_macro", "kb_fit_weight", "kb_fit")` with
  `meta$species` equal to `"macrocystis"`

#### Scenario: Stores the macro parameters
- **WHEN** the fit object is inspected
- **THEN** it exposes draws for the fixed effects `bWeight`, `bFronds`; the Gamma
  shape `shape`; the SDs `sSite`, `sYear`, `sSiteYear`; the per-level `bSite`,
  `bYear`, `bSiteYear`; and retains no live `stanfit`

#### Scenario: Arguments are validated at entry
- **WHEN** `kb_fit_weight_macro()` is called with an invalid argument (bad
  `data`, or a `priors` entry of the wrong family)
- **THEN** it errors at entry via `chk`/`cli` before sampling

#### Scenario: Prior-only and zero-observation fits
- **WHEN** `kb_fit_weight_macro(data, prior_only = TRUE)` is called, including on
  a zero-row data frame
- **THEN** it returns a valid `kb_fit_weight` object whose draws reflect the
  priors only; `fronds_ref` falls back to 5 when there are no observations
