## ADDED Requirements

### Requirement: Fit the Macrocystis weight model

`kb_fit_weight_macro(data, priors, ..., prior_only, chains, niters, nthin,
cores, seed, progress, progress_dir)` SHALL fit the *Macrocystis pyrifera*
allometric weight model via `stanmodels$weight_macro` and return an object of
class `c("kb_fit_weight", "kb_fit")`. The model is a Gamma GLM: the expected
weight is `exp(bWeight + bSite[site] + bFronds * (log(fronds) -
log(fronds_ref)) + bYear[year] + site:year)`, and the response is
`weight ~ Gamma(shape = alpha * fronds, rate = shape / eWeight)`, so the Gamma
shape grows linearly with frond count (a compound-sum dispersion). The species is
fixed by the function (there is no `species` argument); it is recorded as
`"macrocystis"` in `meta$species`. The sampler invocation, draw extraction, and
diagnostics are delegated to the shared internal engine `fit_stan()`.

#### Scenario: Returns a kb_fit_weight object
- **WHEN** `kb_fit_weight_macro()` is called on valid macro weight data
- **THEN** it returns an object of class `c("kb_fit_weight", "kb_fit")` with
  `meta$species` equal to `"macrocystis"`

#### Scenario: Stores the macro parameters
- **WHEN** the fit object is inspected
- **THEN** it exposes draws for the fixed effects `bWeight`, `bFronds`; the Gamma
  shape `alpha`; the SDs `sSite`, `sYear`, `sSiteYear`; the per-level `bSite`,
  `bYear`, `bSiteYear`; and the `log_lik` and `yrep` generated quantities, and
  retains no live `stanfit`

#### Scenario: Arguments are validated at entry
- **WHEN** `kb_fit_weight_macro()` is called with an invalid argument (bad
  `data`, or a `priors` entry of the wrong family)
- **THEN** it errors at entry via `chk`/`cli` before sampling

#### Scenario: Prior-only and zero-observation fits
- **WHEN** `kb_fit_weight_macro(data, prior_only = TRUE)` is called, including on
  a zero-row data frame
- **THEN** it returns a valid `kb_fit_weight` object whose draws reflect the
  priors only; `fronds_ref` falls back to 5 when there are no observations

### Requirement: Weight fit metadata carries the predictor and response names

A `kb_fit_weight` object SHALL record `meta$predictor` and `meta$response` so the
model-level prediction, grid, and plotting code is species-agnostic:
`meta$predictor` is `"diameter"` for nereo and `"fronds"` for macro, and
`meta$response` is `"weight"` for both. Macro additionally stores
`meta$fronds_ref` (the geometric mean of the observed `fronds`, or 5 when there
are none).

#### Scenario: Predictor name is available for downstream code
- **WHEN** `meta$predictor` is read from a macro fit
- **THEN** it is `"fronds"`, and from a nereo fit it is `"diameter"`
