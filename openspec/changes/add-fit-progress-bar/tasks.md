## 1. Spike: de-risk the two verification unknowns (design Risks)

- [x] 1.1 Confirmed: a `stanfit` returned from a `callr::r_bg()` background process yields draws (`posterior::as_draws_rvars()`), sampler params (`rstan::get_sampler_params()`), and source (`rstan::get_stancode()`) in a parent that never loaded kelpbio. No fallback needed.
- [x] 1.2 Confirmed on the pinned rstan version: one CSV per chain (`<base>_<chain>.csv`); warmup rows written by default (no `save_warmup` needed); rows are thinned, total per chain = `ceil(warmup / nthin) + niters` (NOT `warmup + niters * nthin`); each chain CSV ends with a `#  Elapsed Time:` completion marker; count rule = drop empty, `#`-comment, and the `lp__` header lines, ignore an incomplete trailing row. Findings recorded in `design.md` (D5).
- [x] 1.3 Not needed (1.1 passed).

## 2. Pure helpers (no MCMC, unit-testable)

- [ ] 2.1 Add `.vld_progress()` in `R/vld.R` (predicate: length-1 character in `c("bar","verbose","none")`) and update `.chk_sampler_args()` in `R/chk.R` to validate `progress` via `rlang::arg_match()` in place of the `quiet` flag.
- [ ] 2.2 Add `.vld_progress_dir()` in `R/vld.R` (predicate: `NULL` or an existing writable directory) and `.chk_progress_dir()` in `R/chk.R` (aborts via `cli`).
- [ ] 2.3 Implement the row-counting / fraction helper as a standalone function (per-chain complete saved rows summed / total expected saved rows, where per-chain expected = `ceil(warmup / nthin) + niters`; exclude the `lp__` header and `#` comment lines; ignore an incomplete trailing row; treat a chain with its `#  Elapsed Time:` marker as complete so the result reaches exactly `1` at the end). Testable against fixture CSVs without sampling; backs both the console reporter and `kb_fit_progress()`.
- [ ] 2.4 Define the kelpbio-owned progress-artifact format: a writer (manifest with total expected rows + working sampler output) and a reader that maps a `progress_dir` to a fraction via 2.3, so the on-disk layout is private to kelpbio.
- [ ] 2.5 Implement the internal reporter seam (`start(total)`/`update(completed)`/`finish()`): a cli reporter (`cli::cli_progress_bar()`) for `"bar"` and a no-op reporter for `"none"`; `"verbose"` uses no reporter.

## 3. Engine wiring (`R/fit_stan.R`)

- [ ] 3.1 Add `callr` to `DESCRIPTION` Imports.
- [ ] 3.2 Thread `progress` (replacing `quiet`) through `fit_stan()`; generalise `with_quiet_sampler()` to the three modes (verbose = pass through; bar/none = muffle HMC warnings).
- [ ] 3.3 Route sampler output to the progress artifact directory: when `progress_dir` is supplied write the artifact there (2.4); otherwise, for the console `"bar"`, use an internal temp directory. Pass `sample_file` to `rstan::sampling()` (warmup is written by default, no `save_warmup` needed, per the spike). Decouple artifact production from console mode (written under any `progress`).
- [ ] 3.4 Add the background-wrapped sampling path for the console `"bar"`: run the single `rstan::sampling(..., cores = N)` inside `callr::r_bg()`; parent polls the handle and the artifact, advancing the reporter via 2.3; `refresh`/`open_progress` set so no raw stream leaks in `"bar"`/`"none"`. Keep rstan as the source of the returned `stanfit`/draws.
- [ ] 3.5 For `"none"`/`"verbose"` sample in-process (no `callr`); when `progress_dir` is supplied the artifact is still written so an external poller (Shiny in `ExtendedTask`) can read it. Preserve `"verbose"` as the current native-stream path.
- [ ] 3.6 Add `on.exit()` cleanup that kills the `callr` handle (when used) and removes only an internal temp directory on normal exit, error, and interrupt; never delete a caller-supplied `progress_dir`.

## 4. API surface and documentation

- [ ] 4.1 Replace `quiet = FALSE` with `progress = "bar"` and add `progress_dir = NULL` (name-only, after `...`) in the `kb_fit_weight_nereo()` signature (`R/kb_fit_weight_nereo.R`); pass both to `fit_stan()` and pass `progress` to `notify_site_year()` (message suppressed when `progress = "none"`).
- [ ] 4.2 Add the exported `kb_fit_progress(progress_dir)` in `R/kb_fit_progress.R` wrapping the reader (2.4); roxygen `@return` A number between 0 and 1; document the Shiny `ExtendedTask` polling use in `@details`.
- [ ] 4.3 Update the `progress` and `progress_dir` `@param`s in `R/params.R` (chk vocabulary: `A string, one of ...`; `progress_dir` NULL or a directory path) and replace the `quiet` prose in the `kb_fit_weight_nereo()` roxygen `@details` with the three-mode description; update `@examples` if they reference `quiet`.
- [ ] 4.4 `devtools::document()` (adds `kb_fit_progress` to NAMESPACE).

## 5. Tests (testthat 3e, 1:1 mirroring)

- [ ] 5.1 Unit-test `.vld_progress()` / `.vld_progress_dir()` / `.chk_sampler_args()` / `.chk_progress_dir()`: valid values pass, invalid values error (snapshot the cli messages).
- [ ] 5.2 Unit-test the row-counting / fraction helper against fixture CSV files (0%, mid-warmup, mid-sampling, complete, torn trailing row); no MCMC.
- [ ] 5.3 Unit-test `kb_fit_progress()` against fixture progress-artifact directories: returns the expected fraction, `0` on an empty/absent artifact, `1` when complete, no error on a torn read (mirrors the `test-kb_fit_progress.R` file for `R/kb_fit_progress.R`).
- [ ] 5.4 Unit-test the reporter seam (bar vs no-op vs verbose binding) without sampling.
- [ ] 5.5 Update existing tests/fixtures that pass `quiet = TRUE`/`FALSE` to `progress = "none"`/`"verbose"`; restate the site:year structural-message tests on `progress = "none"`.
- [ ] 5.6 Add a `skip_on_cran()` end-to-end test (installed package required): fitting with `progress = "bar"` returns a valid `kb_fit_weight`; fitting with `progress_dir` set writes an artifact that `kb_fit_progress()` reads as `1` on completion and leaves in place; the same `seed` with different `progress` values yields identical draws. Assert structure/invariants only, never MCMC numerics.

## 6. Spec sync and QC

- [ ] 6.1 Run `Rscript scripts/build.R` (rstan_config -> roxygen2md -> styler -> document -> test); confirm docs and tests are clean.
- [ ] 6.2 Sync the `fitting` delta into `openspec/specs/fitting/spec.md` (via `/opsx:sync` or the archive step) once implementation matches.
