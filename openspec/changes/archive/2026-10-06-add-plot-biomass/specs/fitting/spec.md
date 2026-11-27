## MODIFIED Requirements

### Requirement: Sampler control and progress

The fit functions SHALL take `chains` (default 4), `niters` (saved post-warmup draws per chain, default 1000; warmup matches), `nthin` (default 1), `cores`, `seed`, `progress`, and `progress_dir`, passing other arguments to `rstan::sampling()`. The sampler SHALL use `adapt_delta = 0.95` unless a `control` list overrides it; a supplied `control` is merged over the default. `cores = NULL` SHALL use `getOption("mc.cores")`, falling back to `chains`, capped at the available cores. A fit SHALL be reproducible from `seed`, or from a preceding `set.seed()` when `seed` is `NULL`. No HTML viewer SHALL open.

`progress` SHALL be one of `"bar"` (default, a progress bar with rstan's output suppressed), `"verbose"` (rstan's per-iteration output and warnings), or `"none"` (silent). It SHALL change only console output, never the draws. When `progress_dir` names an existing directory, the fit SHALL write a progress record there under any `progress` mode, and `kb_progress(progress_dir)` SHALL return the completed fraction in `[0, 1]` from another R process: `0` before sampling starts, `1` once complete, and no error mid-write. kelpbio SHALL NOT delete a caller's `progress_dir`.

#### Scenario: niters counts saved draws
- **WHEN** a fit uses `niters = 1000` and `nthin = 2`
- **THEN** `niters(fit)` is `1000`

#### Scenario: control is merged over the default
- **WHEN** a fit is called with `control = list(max_treedepth = 12)`
- **THEN** it samples with `max_treedepth = 12` and `adapt_delta = 0.95`

#### Scenario: progress changes only output
- **WHEN** the same model is fitted with the same `seed` and different `progress` values
- **THEN** the draws are identical

#### Scenario: Progress can be polled from another process
- **WHEN** a fit writes to `progress_dir` and `kb_progress(progress_dir)` is called during and after it
- **THEN** it returns the completed fraction, reaching `1` when the fit finishes
