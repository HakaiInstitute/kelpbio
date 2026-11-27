## 1. Spike: de-risk the two verification unknowns (design Risks)

- [x] 1.1 Confirmed: a `stanfit` returned from a `callr::r_bg()` background process yields draws (`posterior::as_draws_rvars()`), sampler params (`rstan::get_sampler_params()`), and source (`rstan::get_stancode()`) in a parent that never loaded kelpbio. No fallback needed.
- [x] 1.2 Confirmed on the pinned rstan version: one CSV per chain (`<base>_<chain>.csv`); warmup rows written by default (no `save_warmup` needed); rows are thinned, total per chain = `ceil(warmup / nthin) + niters` (NOT `warmup + niters * nthin`); each chain CSV ends with a `#  Elapsed Time:` completion marker; count rule = drop empty, `#`-comment, and the `lp__` header lines, ignore an incomplete trailing row. Findings recorded in `design.md` (D5).
- [x] 1.3 Not needed (1.1 passed).

## 2. Pure helpers (no MCMC, unit-testable)

- [x] 2.1 Added `.vld_progress()` in `R/vld.R` and `.chk_progress()` in `R/chk.R`; `.chk_sampler_args()` now takes `progress` (+ `progress_dir`) in place of `quiet`. `rlang::arg_match()` runs in the public `kb_fit_weight_nereo()` (config convention: enumerated args matched in the calling function, default = first value).
- [x] 2.2 Added `.vld_progress_dir()` in `R/vld.R` and `.chk_progress_dir()` in `R/chk.R` (aborts via `cli`; writability checked with a distinct message).
- [x] 2.3 Row-counting / fraction helpers in `R/progress.R` (`count_chain_rows`, `chain_is_complete`, `count_progress_rows`, `read_progress_fraction`); per-chain expected = `ceil(warmup / nthin) + niters`; excludes `lp__` header and `#` lines; ignores torn rows via field-count; `#  Elapsed Time` marks a chain complete so the result reaches `1`.
- [x] 2.4 Progress-artifact format in `R/progress.R`: `write_progress_manifest`/`read_progress_manifest` (manifest.rds) + the rstan sample_file CSVs; `read_progress_fraction()` maps a dir to a fraction. `resolve_progress_dir()` picks caller dir vs internal temp.
- [x] 2.5 Reporter seam in `R/progress.R`: `progress_reporter()` returns a `bar_reporter()` (cli) for `"bar"` and a `noop_reporter()` otherwise.

## 3. Engine wiring (`R/fit_stan.R`)

- [x] 3.1 Added `callr` to `DESCRIPTION` Imports.
- [x] 3.2 `fit_stan()` now takes `progress`/`progress_dir`/`stanmodel_name`; `with_quiet_sampler()` generalised to a `muffle` flag (verbose = pass through; bar/none = muffle HMC warnings).
- [x] 3.3 `resolve_progress_dir()` uses a caller-supplied `progress_dir`, else an internal temp dir for `"bar"`; `sample_file` passed to `rstan::sampling()` (warmup written by default). Artifact production is independent of console mode.
- [x] 3.4 `sample_with_bar()` runs the single `rstan::sampling()` inside `callr::r_bg()` (re-fetching the model by `stanmodel_name`), polls the artifact via `count_progress_rows()`, advances the reporter; `refresh = 0`/`open_progress = FALSE` for bar/none. rstan returns the stanfit.
- [x] 3.5 `"none"`/`"verbose"` sample in-process (no `callr`); the artifact is still written when `progress_dir` is supplied so an external poller can read it. `"verbose"` keeps the native `refresh` stream.
- [x] 3.6 `on.exit()` removes only an internal temp dir; `sample_with_bar()` kills the `callr` handle if still alive. A caller-supplied `progress_dir` is never deleted.

## 4. API surface and documentation

- [x] 4.1 `kb_fit_weight_nereo()` signature now ends `progress = c("bar","verbose","none"), progress_dir = NULL`; `rlang::arg_match(progress)`, both passed to `fit_stan()` (with `stanmodel_name = "weight_nereo"`), `progress` passed to `notify_site_year()` (suppressed when `"none"`).
- [x] 4.2 Added exported `kb_fit_progress(progress_dir)` in `R/kb_fit_progress.R`; `@return` A number between 0 and 1; `@details` documents the Shiny background-poll use.
- [x] 4.3 Updated `@param progress`/`@param progress_dir` in `R/params.R` and replaced the `quiet` prose in the `kb_fit_weight_nereo()` `@details` with the three-mode + `progress_dir` description.
- [x] 4.4 `devtools::document()` run (exports `kb_fit_progress`; no unresolved links).

## 5. Tests (testthat 3e, 1:1 mirroring)

- [x] 5.1 `.vld_progress`/`.vld_progress_dir` tested in `test-vld.R`; `.chk_progress`/`.chk_progress_dir`/`.chk_sampler_args` tested in `test-chk.R` (cli messages snapshotted). PASS.
- [x] 5.2 Row-counting / fraction helpers tested in `test-progress.R` against fixture CSVs (absent, mid-run, complete, over-full, torn row); no MCMC. PASS.
- [x] 5.3 `kb_fit_progress()` tested in `test-kb_fit_progress.R` (mid-run fraction, `0` on empty/absent, `1` complete, torn read, arg validation). PASS. (`write_fake_chain()` shared via `helper-progress.R`.)
- [x] 5.4 Reporter seam tested in `test-progress.R` (bar vs no-op vs verbose binding; lifecycle runs without error). PASS.
- [x] 5.5 Updated fixture builder and tests from `quiet` to `progress`; site:year message test restated on `progress = "none"`. PASS.
- [~] 5.6 End-to-end `skip_on_cran()` tests written in `test-kb_fit_weight_nereo.R` (`progress = "bar"` fit, `progress_dir` artifact read as `1`, progress-invariant draws). NOT YET RUN (requires MCMC + installed package; awaiting confirmation).

## 6. Spec sync and QC

- [~] 6.1 `devtools::document()` clean and `styler` applied; MCMC-free tests pass (103). Full `Rscript scripts/build.R` (including MCMC tests + `R CMD check`) NOT YET RUN (awaiting confirmation).
- [ ] 6.2 Sync the `fitting` delta into `openspec/specs/fitting/spec.md` (via `/opsx:sync` or the archive step) once implementation matches.
