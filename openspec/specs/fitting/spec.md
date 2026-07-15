# fitting

## Purpose

Fitting the weight model and the kb_fit object contract: draws-not-stanfit storage, prior-only / zero-observation support, and sampler control.

## Requirements

### Requirement: Fit the Nereocystis weight model

`kb_fit_weight_nereo(data, priors, prior_only, chains, niters, nthin, cores, seed, quiet, ...)` SHALL fit the *Nereocystis luetkeana* allometric weight model (quadratic log-diameter mean with site intercept, site slope, and a data-determined site:year random effect) via `stanmodels$weight_nereo` and return an object of class `c("kb_fit_weight", "kb_fit")`. The species is fixed by the function (there is no `species` argument); it is recorded as `"nereocystis"` in `meta$species`. There SHALL be no `site_year_on` argument: the site:year effect is determined from the data (see below) and the determination is recorded in `meta$site_year_on`.

The site:year effect SHALL be included when the data span more than one distinct year and omitted otherwise. When years are present but no site was sampled in more than one year (an aliased design in which the site and site:year contributions are not separately identifiable) the effect SHALL be retained and a `cli` warning issued. When the effect is omitted an informational message SHALL be issued unless `quiet = TRUE`.

#### Scenario: Returns a kb_fit_weight object
- **WHEN** `kb_fit_weight_nereo()` is called on valid weight data
- **THEN** it returns an object of class `c("kb_fit_weight", "kb_fit")` with `meta$species` equal to `"nereocystis"`

#### Scenario: Arguments are validated at entry
- **WHEN** `kb_fit_weight_nereo()` is called with an invalid argument (e.g. bad `data`, a `priors` entry of the wrong family)
- **THEN** it errors at entry via `chk`/`cli` before sampling (a family mismatch reports that a family change needs a different model variant)

#### Scenario: Site:year effect included for multi-year data
- **WHEN** the data span more than one year and at least one site is sampled in more than one year
- **THEN** the site:year effect is included (`meta$site_year_on` is `TRUE`) and no structural message is issued

#### Scenario: Site:year effect omitted for single-year data
- **WHEN** the data contain fewer than two distinct years
- **THEN** the site:year effect is omitted (`meta$site_year_on` is `FALSE`) and, unless `quiet = TRUE`, an informational message reports the omission

#### Scenario: Aliased design retains the effect with a warning
- **WHEN** the data span more than one year but no site is sampled in more than one year
- **THEN** the site:year effect is retained (`meta$site_year_on` is `TRUE`) and a `cli` warning reports that the site and site:year effects are not separately identifiable and that the estimate reflects the prior

### Requirement: Fit object stores draws, not the stanfit

The returned `kb_fit` SHALL store extracted posterior draws (a `posterior` draws object) plus sampler diagnostics, the input data, and resolved metadata — and SHALL NOT retain the live `stanfit`.

#### Scenario: Draws and diagnostics are retained, stanfit discarded
- **WHEN** the fit object is inspected
- **THEN** it exposes posterior draws (the fixed effects `bWeight`, `bDiameter`, `bDiameter2`; the SDs `sSite`, `sSiteDiameter`, `sSiteYear`, `sWeight`; the per-site `bSite` and `bSiteDiameter`; the site-by-year `bSiteYear`; and the `log_lik` and `yrep` generated quantities) and diagnostics, and contains no live `stanfit`

#### Scenario: log_lik and yrep are stored for downstream tools
- **WHEN** the fit object is inspected
- **THEN** it retains the pointwise `log_lik` draws (for `loo`) and the `yrep` posterior-predictive draws (for `bayesplot::pp_check`)

### Requirement: Prior-only and zero-observation fits

`kb_fit_weight_nereo()` SHALL support fitting from the priors alone.

#### Scenario: prior_only ignores the data
- **WHEN** `kb_fit_weight_nereo(data, prior_only = TRUE)` is called
- **THEN** the resulting draws reflect the priors only (a fit on permuted responses yields the same prior-only distribution)

#### Scenario: Empty data is accepted under prior_only
- **WHEN** `kb_fit_weight_nereo()` is given a zero-row data frame with `prior_only = TRUE`
- **THEN** it returns a valid `kb_fit_weight` object sampled from the priors

### Requirement: Sampler control

`kb_fit_weight_nereo()` SHALL expose `chains`, `niters`, `nthin`, `cores`, `seed`, and `quiet` as first-class arguments and forward other arguments to `rstan::sampling()` via `...`. `seed` (default `NULL`) SHALL be forwarded to `rstan::sampling()`; when `NULL`, rstan derives its own seed from R's RNG so a preceding `set.seed()` makes the fit reproducible, and an explicit `seed` takes precedence. `niters` is the number of saved post-warmup draws per chain (default `1000`); warmup defaults to match and the post-warmup phase is thinned by `nthin` (default `1`, no thinning). The sampler SHALL run with `adapt_delta = 0.95` by default (raised above Stan's `0.8` for the hierarchical geometry); `adapt_delta` is not a first-class argument, but a `control` list passed through `...` SHALL be merged over this default so power users can override `adapt_delta` or set other control entries (e.g. `max_treedepth`) without dropping it. The sampler SHALL NOT open an HTML progress viewer (`open_progress = FALSE`). With `quiet = FALSE` (the default) progress AND rstan's post-sampling HMC diagnostic warnings (divergent transitions, treedepth, low BFMI, Rhat/ESS) are streamed to the console; `quiet = TRUE` suppresses both (muffled at the call site, not via a global option). A structured convergence summary is available regardless through `converged()`/`glance()` (Rhat and the effective sample rate) and `summary()` (per-term Rhat/ESS and the divergent-transition count). `cores = NULL` SHALL resolve to `getOption("mc.cores")` (falling back to `chains`), capped at the available cores so the default never oversubscribes; servers, containers, and `load_all()`-on-Windows users can throttle via `options(mc.cores = 1)` or `cores = 1`.

#### Scenario: niters means saved post-warmup draws
- **WHEN** `kb_fit_weight_nereo(niters = 1000, nthin = 2, chains = 4)` is called
- **THEN** `niters(fit)` is `1000` (saved draws per chain) regardless of `nthin`

#### Scenario: Defaults and parallelism
- **WHEN** `kb_fit_weight_nereo()` is called with defaults
- **THEN** it fits `chains = 4` with `nthin = 1`, runs chains in parallel using `getOption("mc.cores")` (falling back to `chains`) capped at the available cores, and (`quiet = FALSE`) streams textual sampling progress to the console without opening an HTML progress viewer

#### Scenario: Parallelism can be throttled
- **WHEN** `options(mc.cores = 1)` is set (or `cores = 1` is passed)
- **THEN** the fit runs the chains serially, so it is safe on shared servers, in containers, and from `devtools::load_all()` on Windows

#### Scenario: adapt_delta default and override
- **WHEN** `kb_fit_weight_nereo()` is called with defaults, and separately with `control = list(adapt_delta = 0.99)` or `control = list(max_treedepth = 12)`
- **THEN** the default fit samples at `adapt_delta = 0.95`; a supplied `control` is merged over the default so `adapt_delta = 0.99` overrides it and `max_treedepth = 12` is added while `adapt_delta = 0.95` is retained

#### Scenario: Diagnostics shown unless quiet
- **WHEN** `kb_fit_weight_nereo()` is called with the default `quiet = FALSE`, and separately with `quiet = TRUE`
- **THEN** with `quiet = FALSE` the sampling progress and rstan's post-sampling HMC diagnostic warnings (divergent transitions, treedepth, low BFMI, Rhat/ESS) reach the console; with `quiet = TRUE` both are suppressed at the call site (not via a global option); either way the convergence summary remains available through `converged()`/`glance()`/`summary()`
