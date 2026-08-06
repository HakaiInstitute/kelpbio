## Context

`kb_fit_weight_nereo()` delegates sampling to `fit_stan()` (`R/fit_stan.R`), which calls `rstan::sampling(stanmodels$weight_nereo, ..., cores = N)` and then reduces the returned `stanfit` to `posterior` draws, sampler diagnostics, and the Stan source, discarding the live `stanfit`. Fit-time console output is controlled by a single `quiet` logical: `quiet = FALSE` sets rstan's `refresh` so the C++ layer streams per-iteration lines and lets post-sampling HMC warnings through; `quiet = TRUE` sets `refresh = 0` and muffles the warnings.

Two constraints shape the design (`decisions/engine-choice.md`):

- rstan exposes no R-level per-iteration callback. Progress text comes from the Stan C++ layer writing to the terminal; there is no hook to read a completed-iteration count from within the calling R session.
- `rstan::sampling()` blocks the calling R process for the whole run. A parent cannot poll anything while it is blocked inside that call.

The planned Shiny companion runs the fit in a background R process via `ExtendedTask` for exactly this reason (`decisions/webapp-decision.md`), so any progress fraction must cross a process boundary regardless of the console case.

## Goals / Non-Goals

**Goals:**
- A clean, determinate console progress bar for fitting, advancing with the fraction of sampler iterations completed, with rstan's raw per-iteration stream suppressed.
- Preserve rstan's full stream as an opt-in (`progress = "verbose"`) and a fully silent mode (`progress = "none"`).
- Keep rstan the single source of truth for the returned draws, RNG streams, and error handling, so a progress bug can never corrupt a fit.
- Produce the progress fraction independently of how it is rendered, so the console bar and an external (Shiny) poller share one mechanism.
- Ship a public polling seam (`progress_dir` + `kb_fit_progress()`) so a Shiny front end can read fit progress across a process boundary.

**Non-Goals:**
- The Shiny companion app itself (only the seam it consumes).
- A caller-supplied reporter callback argument (weaker than polling across `ExtendedTask`; see D6).
- No switch to cmdstanr; no first-class cancellation API.
- No change to the fit object or any downstream behaviour.

## Decisions

### D1. One background wrapper around the whole `rstan::sampling()` call, not self-launched chains

The fitting path runs the existing single `rstan::sampling(..., cores = N, sample_file = <tmp>)` call inside one background R process (D4), and the parent polls the `sample_file` CSVs only to compute the progress fraction. The authoritative result is the `stanfit` that rstan itself assembles and returns.

Alternative considered: launch each chain as its own background process (`chains = 1, chain_id = i`), poll per-chain CSVs, and reassemble with `rstan::read_stan_csv()`. Rejected. It moves the CSV onto the correctness path and forces us to re-implement, faithfully, what rstan already does: per-chain RNG-stream derivation from `seed` + `chain_id` (reproducibility), partial-failure semantics (a bad chain surfaced while good chains are kept), and result assembly. A subtle error there would change the numbers without any snapshot test catching it (the project never snapshots MCMC numerics). Wrapping the whole call keeps all of that inside rstan; the CSV is read only to move the bar, so the worst a polling bug can do is misplace the bar, never alter the draws.

### D2. `quiet` (logical) -> `progress` (string enum), default `"bar"`

There are three fit-time output states (clean bar, rstan's full stream, silent); a single logical cannot carry three. Rather than add a second boolean (four combinations, one nonsensical), `quiet` is replaced by `progress = c("bar", "verbose", "none")`, validated with `rlang::arg_match()` per the enumerated-argument convention (config `context`). The package is pre-release (weight model only), so `quiet` is removed outright, not deprecated. Mapping: `"verbose"` == old `quiet = FALSE` (rstan stream + HMC warnings), `"none"` == old `quiet = TRUE` (silent), `"bar"` is new and the default. `converged()`/`glance()`/`summary()` remain the structured convergence path in every mode, unchanged.

### D3. Internal reporter seam; string keywords are the built-in reporters

`fit_stan()` drives the console rendering through a small internal reporter interface (an object exposing `start(total)`, `update(completed)`, `finish()`), so the fraction signal is produced independently of rendering. `progress = "bar"` binds a cli reporter (`cli::cli_progress_bar()`); `"none"` binds a no-op reporter; `"verbose"` binds no reporter and restores rstan's native stream. The reporter is the console consumer of the fraction; the external (Shiny) consumer reads the same fraction from the progress artifact (D6). A caller-supplied reporter callback is deliberately not offered (D6 explains why polling beats a callback for Shiny).

### D4. Background-process dependency: `callr`

`callr::r_bg()` spawns a fresh R process running the sampling call and returns a handle the parent polls (`$is_alive()`, `$get_result()`) while reading the sample_file. `callr` is chosen over `mirai`/`future` for a single, self-contained background call with no persistent worker or `plan()` side effect on the user's session, matching the one-shot nature of a fit. The compiled Stan model is an external pointer that cannot cross the process boundary, so the background process references `kelpbio::stanmodels$weight_nereo` and loads the installed package's DSO itself (the same install-vs-`load_all()` constraint already documented for parallel chains, config `context`). Verified before commit (see Risks): the returned `stanfit`, once serialized back, still yields draws via `posterior::as_draws_rvars()`, `rstan::get_sampler_params()`, and `rstan::get_stancode()` in a parent where the DSO is not loaded (these read stored arrays/strings, not the live pointer).

### D5. Honest fraction across warmup (confirmed by the task-1 spike)

The spike (task 1) established the sample_file behaviour on the pinned rstan version:

- rstan writes one CSV per chain, named `<sample_file_base>_<chain>.csv`.
- Warmup rows ARE written by default (no `save_warmup` toggle needed); the fraction is honest through warmup without extra configuration.
- Rows are the SAVED (thinned) iterations across both phases. Per chain the total is `ceil(warmup / nthin) + niters` (verified: `nthin = 1` gives `warmup + niters`; `niters = 40, nthin = 3, warmup = 40` gives `14 + 40 = 54`). The naive `warmup + niters * nthin` is wrong and is not used.
- Each chain's CSV ends with a `#  Elapsed Time:` comment block, written only at chain completion. This is an authoritative in-file completion signal.

The fraction is (complete data rows across all chains) / (total expected rows), counting warmup, excluding the header line (the one containing `lp__`) and all `#` comment lines, and ignoring any incomplete trailing line (a row being written while a reader in another process counts). Because both real consumers already know completion out of band (the console path sees the `callr` process exit; Shiny sees the `ExtendedTask` resolve), the exact denominator is not correctness-critical; `kb_fit_progress()` additionally treats a chain as complete when its `#  Elapsed Time:` marker is present, so a standalone poller still snaps to `1` at the end regardless of small denominator error. The fraction advances in steps as Stan flushes the file (first rows appear ~1 s after launch, then grow smoothly at the `refresh` cadence); before a chain's file exists its contribution is `0`.

### D6. Public polling seam: `progress_dir` + `kb_fit_progress()`, not a callback

The pollable progress artifact is a kelpbio-owned directory, not the raw Stan CSV. `kb_fit_weight_nereo(..., progress_dir = <path>)` writes into that directory a small manifest (the total expected rows) plus the working sample_file(s); `kb_fit_progress(progress_dir)` reads both and returns the completed fraction in `[0, 1]` (`0` before any rows, `1` at completion), applying the D5 row-counting rule. Callers pass only a directory and call `kb_fit_progress()`; they never parse the files, so the on-disk format stays private and a later mechanism change (or a cmdstanr switch) does not break the app.

Producing the artifact is decoupled from the console mode: it is written whenever `progress_dir` is supplied, under any `progress` value. `progress_dir = NULL` (default) means no external artifact; the console `"bar"` still uses an internal temp directory it cleans up on exit. A caller-supplied `progress_dir` is the caller's to clean up, and the artifacts are left in place on exit so a final `kb_fit_progress()` poll reads `1`.

This targets the Shiny pattern in `decisions/webapp-decision.md`: the app runs `kb_fit_weight_nereo(data, progress_dir = d, progress = "none")` inside an `ExtendedTask` background process and polls `kb_fit_progress(d)` from the main session (`reactivePoll`/`invalidateLater`) to move a UI bar.

Alternative considered: accept a reporter/callback function as the `progress` value and invoke it per update. Rejected for the Shiny case: the fit runs inside the `ExtendedTask` background process, so a callback fires there and cannot touch the main session's reactive state; it would itself have to write to a file the main session polls. Polling a progress artifact is that mechanism directly, without the indirection, and it also serves the plain background-R-process case. The callback adds surface without removing the cross-process poll.

For the Shiny case sampling runs in-process inside the `ExtendedTask` worker (blocking is fine there) and only writes the artifact; the `callr` background wrapper (D1/D4) is used only for the foreground console `"bar"`, where the calling session must stay free to poll and draw the bar. The two paths share the D5 row-counting helper and the D6 artifact format.

## Risks / Trade-offs

- **Deserialized `stanfit` needs the live DSO** -> RESOLVED by the task-1 spike: `as_draws_rvars()`, `get_sampler_params()`, and `get_stancode()` all succeed on a `stanfit` returned from a `callr::r_bg()` process in a parent that never loaded kelpbio (deserialization auto-loads the kelpbio namespace, which is harmless; real use has it loaded anyway). The task-1.3 fallback (return extracted draws instead of the `stanfit`) is not needed.
- **sample_file granularity / warmup rows** -> RESOLVED by the task-1 spike (see D5): warmup rows are written by default, rows are thinned, and a `#  Elapsed Time:` completion marker exists. The bar degrades to coarse steps, never to a wrong final state.
- **Orphaned background process / temp-file leak on interrupt** -> `on.exit()` kills the `callr` handle and removes the temp sample_file directory on both normal exit and error/interrupt; a stale bar is cosmetic, a stale process is not, so cleanup is mandatory and tested.
- **DSO load cost in the background process** -> The background process loads the installed package (no recompile), a one-time cost per fit; acceptable against multi-minute MCMC. Dev sessions must test against `devtools::install()`, not `load_all()` (existing constraint).
- **New Imports dependency (`callr`)** -> A permanent, small, well-maintained dependency; justified by the Shiny-shared background-fit pattern (`decisions/webapp-decision.md`).
- **Progress in `"bar"` mode hides rstan's HMC warnings** -> Acceptable and intended (the warnings are the confusing output for the target audience); the structured convergence summary via `converged()`/`glance()`/`summary()` is unchanged and remains the recommended check, and `progress = "verbose"` restores the full stream for power users.
- **`kb_fit_progress()` reads a file another process is writing** -> Count only complete rows and ignore an incomplete trailing line (D5); a torn read then under-counts by at most one row, never errors. `kb_fit_progress()` on a directory with no artifact yet (or a nonexistent path) returns `0` rather than erroring, so an early poll is safe.
- **Caller-supplied `progress_dir` cleanup** -> The caller owns the directory; kelpbio writes into it and does not delete a caller-supplied directory (so the final poll reads `1`). Validated as an existing, writable directory at entry via `chk`; `progress_dir = NULL` uses an internal temp directory cleaned up on exit.

## Migration Plan

- Remove `quiet` from `kb_fit_weight_nereo()` and `.chk_sampler_args()`; add `progress` and `progress_dir`; export `kb_fit_progress()`. No deprecation shim (pre-release, weight model only).
- Update fixtures and tests that pass `quiet = TRUE`/`FALSE` to `progress = "none"`/`"verbose"`; the site:year structural-message tests assert on `progress = "none"` (was `quiet = TRUE`).
- Rollback is reverting the change: no persisted state or data-format change is involved.

## Open Questions

- None. The two verification unknowns (deserialized-`stanfit` round-trip, warmup-row exposure) were resolved by the task-1 spike; see D5 and Risks.
