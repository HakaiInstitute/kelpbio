## ADDED Requirements

### Requirement: Fit the weight model

`kb_fit_weight(data, species, priors, prior_only, chains, niters, nthin, cores, quiet, ...)` SHALL fit the full allometric weight model (quadratic log-diameter mean with site intercept, site slope, and site:year random effects) via `stanmodels$weight` and return an object of class `c("kb_fit_weight", "kb_fit")`.

#### Scenario: Returns a kb_fit_weight object
- **WHEN** `kb_fit_weight()` is called on valid weight data
- **THEN** it returns an object of class `c("kb_fit_weight", "kb_fit")`

#### Scenario: Arguments are validated at entry
- **WHEN** `kb_fit_weight()` is called with an invalid argument (e.g. bad `data`, unknown `species`, a `priors` entry of the wrong family)
- **THEN** it errors at entry via `chk`/`cli` before sampling (family mismatch reports that a family change needs a different model variant)

### Requirement: Fit object stores draws, not the stanfit

The returned `kb_fit` SHALL store extracted posterior draws (a `posterior` draws object) plus sampler diagnostics, the input data, and resolved metadata — and SHALL NOT retain the live `stanfit`.

#### Scenario: Draws and diagnostics are retained, stanfit discarded
- **WHEN** the fit object is inspected
- **THEN** it exposes posterior draws (the fixed effects `bWeight30`, `bDiameter`, `bDiameter2`; the SDs `sSite`, `sSiteDiameter`, `sSiteYear`, `sWeight`; the per-site `bSite` and `bSiteDiameter`; the site-by-year `bSiteYear`; and the `log_lik` and `yrep` generated quantities) and diagnostics, and contains no live `stanfit`

#### Scenario: log_lik and yrep are stored for downstream tools
- **WHEN** the fit object is inspected
- **THEN** it retains the pointwise `log_lik` draws (for `loo`) and the `yrep` posterior-predictive draws (for `bayesplot::pp_check`)

### Requirement: Prior-only and zero-observation fits

`kb_fit_weight()` SHALL support fitting from the priors alone.

#### Scenario: prior_only ignores the data
- **WHEN** `kb_fit_weight(data, prior_only = TRUE)` is called
- **THEN** the resulting draws reflect the priors only (a fit on permuted responses yields the same prior-only distribution)

#### Scenario: Empty data is accepted under prior_only
- **WHEN** `kb_fit_weight()` is given a zero-row data frame with `prior_only = TRUE`
- **THEN** it returns a valid `kb_fit_weight` object sampled from the priors

### Requirement: Sampler control

`kb_fit_weight()` SHALL expose `chains`, `niters`, `nthin`, `cores`, and `quiet` as first-class arguments and forward other arguments to `rstan::sampling()` via `...`. `niters` is the number of saved post-warmup draws per chain (default `1000`); warmup defaults to match and the post-warmup phase is thinned by `nthin` (default `10`). The sampler SHALL run with `adapt_delta = 0.95` by default (raised above Stan's `0.8` for the hierarchical geometry); `adapt_delta` is not a first-class argument, but a `control` list passed through `...` SHALL be merged over this default so power users can override `adapt_delta` or set other control entries without dropping it.

#### Scenario: niters means saved post-warmup draws
- **WHEN** `kb_fit_weight(niters = 1000, nthin = 10, chains = 4)` is called
- **THEN** `niters(fit)` is `1000` (saved draws per chain) regardless of `nthin`

#### Scenario: Defaults and parallelism
- **WHEN** `kb_fit_weight()` is called with defaults
- **THEN** it fits `chains = 4`, fits chains in parallel by default (`cores = NULL`), and (`quiet = FALSE`) shows sampling progress

#### Scenario: adapt_delta default and override
- **WHEN** `kb_fit_weight()` is called with defaults, and separately with `control = list(adapt_delta = 0.99)` or `control = list(max_treedepth = 12)`
- **THEN** the default fit samples at `adapt_delta = 0.95`; a supplied `control` is merged over the default so `adapt_delta = 0.99` overrides it and `max_treedepth = 12` is added while `adapt_delta = 0.95` is retained

#### Scenario: Progress shown, diagnostic noise suppressed
- **WHEN** `kb_fit_weight()` is called with the default `quiet = FALSE`
- **THEN** it shows the sampling progress but suppresses other Stan messages and the post-sampling HMC diagnostic warnings (divergent transitions, treedepth, low BFMI, Rhat/ESS) at the call site (not via a global option); convergence is surfaced through `converged()`/`glance()`/`print()`
