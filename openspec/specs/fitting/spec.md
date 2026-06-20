# fitting

## Purpose

Fitting the weight model and the kb_fit object contract: draws-not-stanfit storage, prior-only / zero-observation support, and sampler control.

## Requirements

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

`kb_fit_weight()` SHALL expose `chains`, `niters`, `nthin`, `cores`, and `quiet` as first-class arguments and forward other arguments to `rstan::sampling()` via `...`. `niters` is the number of saved post-warmup draws per chain (default `1000`); warmup defaults to match and the post-warmup phase is thinned by `nthin` (default `1`, no thinning). The sampler SHALL NOT open an HTML progress viewer (`open_progress = FALSE`); with `quiet = FALSE` progress is streamed to the console as text. `cores = NULL` SHALL resolve to `getOption("mc.cores")` (falling back to `chains`), capped at the available cores so the default never oversubscribes; servers, containers, and `load_all()`-on-Windows users can throttle via `options(mc.cores = 1)` or `cores = 1`.

#### Scenario: niters means saved post-warmup draws
- **WHEN** `kb_fit_weight(niters = 1000, nthin = 2, chains = 4)` is called
- **THEN** `niters(fit)` is `1000` (saved draws per chain) regardless of `nthin`

#### Scenario: Defaults and parallelism
- **WHEN** `kb_fit_weight()` is called with defaults
- **THEN** it fits `chains = 4` with `nthin = 1`, runs chains in parallel using `getOption("mc.cores")` (falling back to `chains`) capped at the available cores, and (`quiet = FALSE`) streams textual sampling progress to the console without opening an HTML progress viewer

#### Scenario: Parallelism can be throttled
- **WHEN** `options(mc.cores = 1)` is set (or `cores = 1` is passed)
- **THEN** the fit runs the chains serially, so it is safe on shared servers, in containers, and from `devtools::load_all()` on Windows

#### Scenario: Progress shown, diagnostic noise suppressed
- **WHEN** `kb_fit_weight()` is called with the default `quiet = FALSE`
- **THEN** it shows the sampling progress but suppresses other Stan messages and the post-sampling HMC diagnostic warnings (divergent transitions, treedepth, low BFMI, Rhat/ESS) at the call site (not via a global option); convergence is surfaced through `converged()`/`glance()`/`print()`
