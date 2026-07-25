# fitting

## MODIFIED Requirements

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
