# fitting

## MODIFIED Requirements

### Requirement: Sampler control

`kb_fit_weight()` SHALL expose `chains`, `niters`, `nthin`, `cores`, and `quiet` as first-class arguments and forward other arguments to `rstan::sampling()` via `...`. `niters` is the number of saved post-warmup draws per chain (default `1000`); warmup defaults to match and the post-warmup phase is thinned by `nthin` (default `1`, no thinning). The sampler SHALL NOT open an HTML progress viewer (`open_progress = FALSE`); with `quiet = FALSE` progress is streamed to the console as text.

#### Scenario: niters means saved post-warmup draws
- **WHEN** `kb_fit_weight(niters = 1000, nthin = 2, chains = 4)` is called
- **THEN** `niters(fit)` is `1000` (saved draws per chain) regardless of `nthin`

#### Scenario: Defaults and parallelism
- **WHEN** `kb_fit_weight()` is called with defaults
- **THEN** it fits `chains = 4` with `nthin = 1`, fits chains in parallel by default (`cores = NULL`), and (`quiet = FALSE`) streams textual sampling progress to the console without opening an HTML progress viewer
