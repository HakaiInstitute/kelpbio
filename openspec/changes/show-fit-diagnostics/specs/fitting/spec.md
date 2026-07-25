## MODIFIED Requirements

### Requirement: Sampler control

`kb_fit_weight_nereo()` SHALL expose `chains`, `niters`, `nthin`, `cores`, and `quiet` as first-class arguments and forward other arguments to `rstan::sampling()` via `...`. `niters` is the number of saved post-warmup draws per chain (default `1000`); warmup defaults to match and the post-warmup phase is thinned by `nthin` (default `1`, no thinning). The sampler SHALL run with `adapt_delta = 0.95` by default (raised above Stan's `0.8` for the hierarchical geometry); `adapt_delta` is not a first-class argument, but a `control` list passed through `...` SHALL be merged over this default so power users can override `adapt_delta` or set other control entries (e.g. `max_treedepth`) without dropping it. The sampler SHALL NOT open an HTML progress viewer (`open_progress = FALSE`). With `quiet = FALSE` (the default) progress AND rstan's post-sampling HMC diagnostic warnings (divergent transitions, treedepth, low BFMI, Rhat/ESS) are streamed to the console; `quiet = TRUE` suppresses both (muffled at the call site, not via a global option). A structured convergence summary is available regardless through `converged()`/`glance()` (Rhat and the effective sample rate) and `summary()` (per-term Rhat/ESS and the divergent-transition count). `cores = NULL` SHALL resolve to `getOption("mc.cores")` (falling back to `chains`), capped at the available cores so the default never oversubscribes; servers, containers, and `load_all()`-on-Windows users can throttle via `options(mc.cores = 1)` or `cores = 1`.

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
