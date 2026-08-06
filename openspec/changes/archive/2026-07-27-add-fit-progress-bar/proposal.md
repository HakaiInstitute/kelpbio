## Why

With the default `quiet = FALSE`, `kb_fit_weight_nereo()` streams rstan's raw per-iteration output (`Chain 1: Iteration: 200/2000 [10%] (Warmup)`) and post-sampling HMC diagnostics to the console. For the non-technical audience this package and its planned Shiny companion target (`decisions/webapp-decision.md`), that output is verbose and confusing rather than informative. There is currently no middle ground between rstan's full stream (`quiet = FALSE`) and total silence (`quiet = TRUE`): no clean "the model is fitting, here is how far along" signal, and nothing a Shiny front end can read to drive a responsive progress indicator (GitHub issue #8).

## What Changes

- Add a clean, determinate console progress bar for model fitting, driven by the fraction of sampler iterations completed, with rstan's raw per-iteration stream suppressed.
- **BREAKING**: replace the `quiet` (logical) argument on `kb_fit_weight_nereo()` with `progress`, a string argument (one of `"bar"`, `"verbose"`, `"none"`, default `"bar"`). `progress = "verbose"` reproduces the old `quiet = FALSE` behaviour (rstan's full stream and HMC warnings); `progress = "none"` reproduces `quiet = TRUE` (silent). The package is pre-release (weight model only), so `quiet` is removed outright rather than deprecated.
- Add a `progress_dir` argument to `kb_fit_weight_nereo()`: when supplied, a pollable, kelpbio-owned progress artifact is written there so another R process can read fit progress while the fit runs. This is decoupled from `progress`, so the artifact is produced regardless of console mode.
- Export `kb_fit_progress(progress_dir)`, returning the completed fraction (0 to 1) read from that directory. This is the seam a Shiny companion app uses: run the fit in a background process (`ExtendedTask`) and poll `kb_fit_progress()` from the main session to drive a responsive UI progress indicator (`decisions/webapp-decision.md`).
- Produce the fraction signal independently of how it is rendered (an internal reporter seam), so the console bar and the external poller share one mechanism.

## Capabilities

### New Capabilities
<!-- none: the progress-reporting seam is internal implementation, not an exported contract; it lives in design.md -->

### Modified Capabilities
- `fitting`: the "Sampler control" requirement changes: the `quiet` logical argument is replaced by the `progress` string argument (`"bar"` default, `"verbose"`, `"none"`), the three fit-time output modes are specified, a `progress_dir` argument is added, and the default becomes a determinate progress bar rather than rstan's raw stream. A new requirement specifies external fit-progress polling via the exported `kb_fit_progress(progress_dir)`. The structural-message and site:year scenarios that reference `quiet = TRUE` are restated in terms of `progress = "none"`.

## Impact

- **API**: `kb_fit_weight_nereo()` signature (`quiet` -> `progress`, add `progress_dir`); all `quiet` references in its documentation, `params.R`, and examples. New exported `kb_fit_progress()` (`R/kb_fit_progress.R`). `.chk_sampler_args()` validation (`quiet` flag -> `progress` string via `rlang::arg_match()`; validate `progress_dir`).
- **Engine**: `R/fit_stan.R` (`fit_stan()`, `with_quiet_sampler()`) gains a background-wrapped sampling path (for the console `"bar"`) that writes a Stan `sample_file` and a parent-side poll loop that reads it to advance the bar; the pollable progress artifact is written whenever `progress_dir` is supplied, independent of console mode; rstan remains the source of truth for the returned draws (see `design.md`). `with_quiet_sampler()` generalises to the three modes.
- **Dependencies**: adds one background-process dependency (callr or mirai) to Imports; adds cli progress-bar usage (cli is already a dependency).
- **Specs/docs**: `openspec/specs/fitting/spec.md` "Sampler control" requirement and a new external-polling requirement; roxygen for `kb_fit_weight_nereo()` and `kb_fit_progress()`.
- **Rationale references**: `decisions/engine-choice.md` (rstan blocks the R process; no per-iteration R callback), `decisions/webapp-decision.md` (Shiny runs the fit in a background process via `ExtendedTask`, so a progress fraction crosses a process boundary regardless).

## Non-goals

- No change to the returned `kb_fit_weight` object, the draws it stores, or any downstream summary/prediction behaviour: this change is confined to fit-time console output.
- No switch away from rstan to cmdstanr (which offers native per-iteration callbacks); the engine choice stands (`decisions/engine-choice.md`).
- The Shiny companion app itself is out of scope (`decisions/webapp-decision.md`); this change ships only the polling seam (`progress_dir` + `kb_fit_progress()`) the app will consume.
- No caller-supplied reporter callback argument: across the `ExtendedTask` process boundary a callback cannot update the Shiny session's reactive state, so polling a progress artifact is the supported cross-process mechanism, not a callback (see `design.md`).
- No cancellation/interrupt feature beyond leaving the fit interruptible; a first-class cancel API is out of scope.
