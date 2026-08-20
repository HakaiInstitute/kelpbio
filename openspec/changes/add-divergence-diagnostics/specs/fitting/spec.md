## MODIFIED Requirements

### Requirement: Fit object stores draws, not the stanfit

The returned `kb_fit` SHALL store extracted posterior draws (a `posterior` draws object) plus sampler diagnostics, the input data, and resolved metadata — and SHALL NOT retain the live `stanfit`.

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
- **THEN** it exposes posterior draws (the fixed effects `bWeight`, `bDiameter`, `bDiameter2`; the SDs `sSite`, `sSiteDiameter`, `sSiteYear`, `sWeight`; the per-site `bSite` and `bSiteDiameter`; the site-by-year `bSiteYear`; and the `log_lik` and `yrep` generated quantities) and diagnostics, and contains no live `stanfit`

#### Scenario: Sampler diagnostics survive the stanfit
- **WHEN** the fit object is inspected
- **THEN** its diagnostics carry the divergent-transition count, the divergence and treedepth-saturation rates, and the minimum E-BFMI, so `converged()`, `glance()`, and `print(summary(fit))` need no live `stanfit`

#### Scenario: A rate with no draws is unknown, not zero
- **WHEN** a rate would be computed against an empty denominator
- **THEN** it is `NA`, so the verdict surfaces the missing evidence rather than passing

#### Scenario: log_lik and yrep are stored for downstream tools
- **WHEN** the fit object is inspected
- **THEN** it retains the pointwise `log_lik` draws (for `loo`) and the `yrep` posterior-predictive draws (for `bayesplot::pp_check`)
