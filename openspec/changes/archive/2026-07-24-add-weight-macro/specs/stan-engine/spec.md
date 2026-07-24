## ADDED Requirements

### Requirement: The Macrocystis weight model follows the engine conventions

`inst/stan/weight_macro.stan` SHALL follow the same engine conventions as
`weight_nereo.stan`: priors passed as data (all hyperparameters in the `data`
block, the prior family fixed at compile time), a `prior_only` flag and `nObs >=
0` supporting prior-only and zero-observation fits, non-centred random effects
(`z_*` standard-normal deviations scaled by their SD), the mean defined once in
`transformed parameters`, and `log_lik` / `yrep` generated quantities that are
no-ops when `nObs == 0`. It is exposed as `stanmodels$weight_macro`.

The macro model SHALL differ from nereo in its likelihood and structure: the
response `weight` is modelled on the natural scale by `weight ~ gamma(alpha .*
fronds, alpha .* fronds ./ eWeight)`, where `eWeight = exp(bWeight + bSite[site]
+ bFronds * log_fronds + bYear[year] + site_year_on * bSiteYear[site, year])` and
`log_fronds = log(fronds) - log(fronds_ref)`. There is no quadratic term, no site
slope, and no residual SD; dispersion comes from the per-frond Gamma shape
`alpha`. A standalone year main effect `bYear` is present in addition to `bSite`
and `bSiteYear`.

#### Scenario: Samples and exposes the expected quantities
- **WHEN** `stanmodels$weight_macro` is sampled on assembled macro data
- **THEN** it returns a stanfit exposing `bWeight`, `bFronds`, `alpha`, `sSite`,
  `sYear`, `sSiteYear`, the per-level `bSite` / `bYear` / `bSiteYear`, and the
  `log_lik` / `yrep` generated quantities

#### Scenario: Prior-only guard and empty data
- **WHEN** the model is sampled with `prior_only = 1` or `nObs = 0`
- **THEN** the likelihood is skipped and the `log_lik` / `yrep` loops are no-ops
