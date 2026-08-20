# fitting

## Purpose

Fitting the Nereocystis and Macrocystis weight models and the kb_fit object contract: draws-not-stanfit storage, prior-only / zero-observation support, and sampler control.
## Requirements
### Requirement: Fit the Nereocystis weight model

`kb_fit_weight_nereo(data, priors, ..., prior_only, chains, niters, nthin, cores, seed, progress, progress_dir)` SHALL fit the *Nereocystis luetkeana* allometric weight model (quadratic log-diameter mean with site intercept, site slope, and a data-determined site:year random effect) via `stanmodels$weight_nereo` and return an object of class `c("kb_fit_weight_nereo", "kb_fit_weight", "kb_fit")`. The species is fixed by the function (there is no `species` argument); it is recorded as `"nereocystis"` in `meta$species`. There SHALL be no `site_year_on` argument: the site:year effect is determined from the data (see below) and the determination is recorded in `meta$site_year_on`.

The site:year effect SHALL be included when the data span more than one distinct year and omitted otherwise. When years are present but no site was sampled in more than one year (an aliased design in which the site and site:year contributions are not separately identifiable) the effect SHALL be retained and a `cli` warning issued; predictions conditioned on the observed site-years are unaffected, but the individual site and site:year terms and their standard deviations (`sSite`, `sSiteYear`) are prior-driven and SHALL NOT be interpreted separately. When the effect is omitted an informational message SHALL be issued unless `progress = "none"`.

#### Scenario: Returns a kb_fit_weight object
- **WHEN** `kb_fit_weight_nereo()` is called on valid weight data
- **THEN** it returns an object of class `c("kb_fit_weight_nereo", "kb_fit_weight", "kb_fit")` with `meta$species` equal to `"nereocystis"`

#### Scenario: Arguments are validated at entry
- **WHEN** `kb_fit_weight_nereo()` is called with an invalid argument (e.g. bad `data`, a `priors` entry of the wrong family)
- **THEN** it errors at entry via `chk`/`cli` before sampling (a family mismatch reports that a family change needs a different model variant)

#### Scenario: Site:year effect included for multi-year data
- **WHEN** the data span more than one year and at least one site is sampled in more than one year
- **THEN** the site:year effect is included (`meta$site_year_on` is `TRUE`) and no structural message is issued

#### Scenario: Site:year effect omitted for single-year data
- **WHEN** the data contain fewer than two distinct years
- **THEN** the site:year effect is omitted (`meta$site_year_on` is `FALSE`) and, unless `progress = "none"`, an informational message reports the omission

#### Scenario: Aliased design retains the effect with a warning
- **WHEN** the data span more than one year but no site is sampled in more than one year
- **THEN** the site:year effect is retained (`meta$site_year_on` is `TRUE`) and a `cli` warning reports that the site and site:year effects are not separately identifiable and that the estimate reflects the prior

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

### Requirement: Prior-only and zero-observation fits

`kb_fit_weight_nereo()` SHALL support fitting from the priors alone.

#### Scenario: prior_only ignores the data
- **WHEN** `kb_fit_weight_nereo(data, prior_only = TRUE)` is called
- **THEN** the resulting draws reflect the priors only (a fit on permuted responses yields the same prior-only distribution)

#### Scenario: Empty data is accepted under prior_only
- **WHEN** `kb_fit_weight_nereo()` is given a zero-row data frame with `prior_only = TRUE`
- **THEN** it returns a valid `kb_fit_weight` object sampled from the priors

### Requirement: Sampler control

`kb_fit_weight_nereo()` SHALL expose `chains`, `niters`, `nthin`, `cores`, `seed`, `progress`, and `progress_dir` as first-class arguments and forward other arguments to `rstan::sampling()` via `...`. `seed` (default `NULL`) SHALL be forwarded to `rstan::sampling()`; when `NULL`, rstan derives its own seed from R's RNG so a preceding `set.seed()` makes the fit reproducible, and an explicit `seed` takes precedence. `niters` is the number of saved post-warmup draws per chain (default `1000`); warmup defaults to match and the post-warmup phase is thinned by `nthin` (default `1`, no thinning). The sampler SHALL run with `adapt_delta = 0.95` by default (raised above Stan's `0.8` for the hierarchical geometry); `adapt_delta` is not a first-class argument, but a `control` list passed through `...` SHALL be merged over this default so power users can override `adapt_delta` or set other control entries (e.g. `max_treedepth`) without dropping it. The sampler SHALL NOT open an HTML progress viewer (`open_progress = FALSE`).

`progress` SHALL be a string, one of `"bar"` (default), `"verbose"`, or `"none"`, validated with `rlang::arg_match()`. It controls only fit-time console output; it SHALL NOT change the returned object, the draws, or reproducibility.

- `progress = "bar"` SHALL display a determinate console progress bar that advances with the fraction of sampler iterations (warmup and sampling) completed across all chains, and SHALL suppress rstan's raw per-iteration stream and its post-sampling HMC diagnostic warnings.
- `progress = "verbose"` SHALL stream rstan's per-iteration output AND its post-sampling HMC diagnostic warnings (divergent transitions, treedepth, low BFMI, Rhat/ESS) to the console (the previous default behaviour), and SHALL NOT display the progress bar.
- `progress = "none"` SHALL suppress all fit-time output (progress bar, rstan stream, and HMC warnings), muffled at the call site, not via a global option.

`progress_dir` (default `NULL`) SHALL be `NULL` or a path to an existing, writable directory, validated at entry. When a directory is supplied, `kb_fit_weight_nereo()` SHALL write a kelpbio-owned, pollable progress artifact into it while the fit runs (a manifest recording the total expected iterations, plus the working sampler output), so another R process can read fit progress via `kb_fit_progress()`. Writing the artifact SHALL be independent of `progress`: it is produced under any of `"bar"`, `"verbose"`, `"none"` whenever `progress_dir` is supplied. A caller-supplied `progress_dir` and its contents are the caller's to clean up; kelpbio SHALL NOT delete a caller-supplied directory, and the artifact SHALL remain readable after the fit completes (a final poll reads complete). When `progress_dir` is `NULL` no external artifact is produced (the console `"bar"` may use an internal temporary location that it removes on exit).

A structured convergence summary SHALL be available regardless of `progress` through `converged()`/`glance()` (Rhat and the effective sample rate) and `summary()` (per-term Rhat/ESS and the divergent-transition count). `cores = NULL` SHALL resolve to `getOption("mc.cores")` (falling back to `chains`), capped at the available cores so the default never oversubscribes; servers, containers, and `load_all()`-on-Windows users can throttle via `options(mc.cores = 1)` or `cores = 1`.

`kb_fit_weight_macro()` exposes the same sampler-control arguments (`chains`, `niters`, `nthin`, `cores`, `seed`, `progress`, `progress_dir`) with identical semantics: both fit functions route through the shared internal engine `fit_stan()`, so the `progress` modes, `adapt_delta = 0.95` default and `control` merge, `cores` resolution, and `open_progress = FALSE` behaviour are the same for either species.

#### Scenario: niters means saved post-warmup draws
- **WHEN** `kb_fit_weight_nereo(niters = 1000, nthin = 2, chains = 4)` is called
- **THEN** `niters(fit)` is `1000` (saved draws per chain) regardless of `nthin`

#### Scenario: Defaults and parallelism
- **WHEN** `kb_fit_weight_nereo()` is called with defaults
- **THEN** it fits `chains = 4` with `nthin = 1`, runs chains in parallel using `getOption("mc.cores")` (falling back to `chains`) capped at the available cores, and (`progress = "bar"`) displays a determinate console progress bar without opening an HTML progress viewer

#### Scenario: Parallelism can be throttled
- **WHEN** `options(mc.cores = 1)` is set (or `cores = 1` is passed)
- **THEN** the fit runs the chains serially, so it is safe on shared servers, in containers, and from `devtools::load_all()` on Windows

#### Scenario: adapt_delta default and override
- **WHEN** `kb_fit_weight_nereo()` is called with defaults, and separately with `control = list(adapt_delta = 0.99)` or `control = list(max_treedepth = 12)`
- **THEN** the default fit samples at `adapt_delta = 0.95`; a supplied `control` is merged over the default so `adapt_delta = 0.99` overrides it and `max_treedepth = 12` is added while `adapt_delta = 0.95` is retained

#### Scenario: Progress bar is the default
- **WHEN** `kb_fit_weight_nereo()` is called with the default `progress = "bar"`
- **THEN** a determinate progress bar advances with the fraction of iterations completed, rstan's raw per-iteration stream and HMC warnings do not reach the console, and the convergence summary remains available through `converged()`/`glance()`/`summary()`

#### Scenario: Verbose reproduces the rstan stream
- **WHEN** `kb_fit_weight_nereo(progress = "verbose")` is called
- **THEN** rstan's per-iteration output and its post-sampling HMC diagnostic warnings (divergent transitions, treedepth, low BFMI, Rhat/ESS) reach the console and no progress bar is shown

#### Scenario: None is silent
- **WHEN** `kb_fit_weight_nereo(progress = "none")` is called
- **THEN** no progress bar, rstan stream, or HMC warnings reach the console (suppressed at the call site, not via a global option); the convergence summary remains available through `converged()`/`glance()`/`summary()`

#### Scenario: Invalid progress value errors at entry
- **WHEN** `kb_fit_weight_nereo(progress = "loud")` is called
- **THEN** it errors at entry via `rlang::arg_match()` before sampling, reporting the allowed values `"bar"`, `"verbose"`, `"none"`

#### Scenario: Progress does not affect the draws
- **WHEN** the same model is fit twice with the same `seed` (or the same preceding `set.seed()`) but different `progress` values
- **THEN** the returned draws are identical: `progress` changes only console output

#### Scenario: progress_dir writes a pollable artifact independent of console mode
- **WHEN** `kb_fit_weight_nereo(data, progress_dir = d, progress = "none")` is called with `d` an existing writable directory
- **THEN** a kelpbio-owned progress artifact is written into `d` during the fit (readable via `kb_fit_progress(d)`), no console output is produced, and the artifact remains in `d` after the fit returns (kelpbio does not delete a caller-supplied directory)

#### Scenario: Invalid progress_dir errors at entry
- **WHEN** `kb_fit_weight_nereo(data, progress_dir = "/no/such/dir")` is called with a path that is not an existing writable directory
- **THEN** it errors at entry via `chk`/`cli` before sampling

### Requirement: External fit-progress polling

`kb_fit_progress(progress_dir)` SHALL be an exported function returning the completed fraction of a fit, as a number in `[0, 1]`, read from the kelpbio-owned progress artifact written by `kb_fit_weight_nereo(..., progress_dir = progress_dir)`. It SHALL enable a separate R process (for example a Shiny session polling a fit running in an `ExtendedTask` background process) to read progress without parsing the on-disk format itself. The same artifact is written by `kb_fit_weight_macro(..., progress_dir = progress_dir)`, and `kb_fit_progress()` reads it identically regardless of which fit function produced it. The fraction SHALL be computed as complete saved sampler rows across all chains (counting the thinned warmup and post-warmup rows) divided by the total expected saved rows, excluding the artifact's header and comment lines and ignoring any incomplete trailing row. A chain whose completion marker is present SHALL count as fully complete, so the function returns exactly `1` once every chain has finished regardless of small differences in the expected-row estimate. `progress_dir` SHALL be validated as a string path.

#### Scenario: Returns the completed fraction
- **WHEN** `kb_fit_progress(progress_dir)` is called while a fit writing to `progress_dir` is partway through sampling
- **THEN** it returns a number in `[0, 1]` equal to the fraction of expected sampler iterations completed so far

#### Scenario: Zero before progress, complete at end
- **WHEN** `kb_fit_progress(progress_dir)` is called before any sampler rows are written (or on a directory holding no progress artifact yet), and separately after the fit has finished
- **THEN** it returns `0` in the first case and `1` in the second, without erroring

#### Scenario: Does not error on a torn read
- **WHEN** `kb_fit_progress(progress_dir)` reads the artifact while another process is writing a row to it
- **THEN** it ignores the incomplete trailing row and returns a valid fraction rather than erroring

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

