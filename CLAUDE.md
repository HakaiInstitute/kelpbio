# CLAUDE.md — kelpbio

R package for Bayesian kelp biomass estimation. All exported functions use the `kb_` prefix.

## Common Commands

| Task | Command |
|------|---------|
| Routine build + QC | `Rscript scripts/build.R` (runs `rstan_config()` → `roxygen2md()` → `styler` → `document()` → `test()`) |
| Full check (slow) | `KELPBIO_FULL_CHECK=true Rscript scripts/build.R` (adds `R CMD check` + pkgdown, recompiles Stan) |
| Rebuild pre-fit objects + fixtures (slow, MCMC) | `KELPBIO_REBUILD_FITS=true Rscript scripts/build.R` (re-fits `data/fit_weight_sim_*` and `tests/testthat/fixtures/*.rds`; run after changing the fit object structure or a model) |
| Run all tests | `devtools::test()` |
| Run one test file | `testthat::test_file("tests/testthat/test-<name>.R")` or `devtools::test_active_file()` |
| Document | `devtools::document()` |
| Regenerate architecture HTML | `quarto render decisions/architecture.md --to html --embed-resources` (needs Quarto; RStudio bundles it) |

- **After editing any `inst/stan/*.stan` file**: run `rstantools::rstan_config()` (regenerates `src/stanExports_*` and `R/stanmodels.R`), then `devtools::install()`. `devtools::load_all()`/`test()` compile from the generated C++ but do NOT re-transpile the Stan source, so `.stan` edits are silently missed without `rstan_config()` first.
- Generated files (`R/stanmodels.R`, `src/stanExports_*`, `src/RcppExports.cpp`) are never hand-edited and are excluded from styling and linting.
- **Linting** runs in CI via jarl (`.github/workflows/lint-with-jarl.yaml`, config `jarl.toml`); the build script does not lint, so local and CI checks stay in sync.
- `decisions/architecture.html` is a gitignored local render of `architecture.md` (self-contained, via the command above); regenerate it after editing the doc. It is a local preview only, not a committed artifact.

## Key Reference Locations

| Resource | Path |
|----------|------|
| Analysis project (final models + Stan code) | `~/Analyses/poissonconsulting/hakai-kelp-biomass-25/` |
| Reference package architecture | `~/Code/poissonconsulting/bboutools/` |
| Observable behaviour (the package contract) | `openspec/specs/` |
| Cross-cutting rules / conventions | `openspec/config.yaml` (`context:`) |
| Decision records (engine, prediction engine, S3, API review, webapp) | `decisions/` |
| OpenSpec workflow for this repo | `openspec/tutorial.md` |

Knowledge lives in OpenSpec, not a `docs/` design-doc tree (one fact, one home): behaviour in `openspec/specs/`, cross-cutting rules in `openspec/config.yaml`, cross-cutting rationale in `decisions/`, per-change rationale in that change's `design.md`. When implementing any feature, read the corresponding analysis project script and Stan file first; the analysis project contains the final, validated model code that kelpbio adapts.

## Spec & Change Workflow (learned conventions)

- **One feature = one change.** Keep at most one change touching a given capability in flight at a time. Two unarchived changes that rewrite the same requirement produce stale deltas that regress the spec on a later sync/archive (this is what happened when the `quiet` fitting delta was superseded by `progress` while both sat unarchived).
- **Definition of done, all in the same PR:** code + tests green in CI, main spec synced, reader docs (roxygen / README / vignette) updated, and the change archived. Do NOT defer sync/archive to a later cleanup pass; deferring is what let the `quiet` -> `progress` rename drift out of the spec and vignette.
- **Archive each change on completion** (pre-release: deleting the change folder is fine, since `openspec/specs/` is the source of truth and git keeps history). Never let change folders accumulate. `sync` is the escape hatch for updating the contract mid-flight; `archive` is the normal completion step (it syncs the delta and files the folder). Default to archive-on-completion.
- **Sub-model changes are thin.** The weight model settled the shared fit/predict/summarise/plot patterns; the remaining sub-models (size, density, blade fraction, wet/dry, carbon) reference the weight contract and spell out only their differences (distribution, columns, random-effect structure, month handling). Do not re-derive the shared contract for each.
- **Trust the test suite + green CI as the "done" signal, not `tasks.md` checkboxes** (checkboxes drift out of date).
- **Before requesting review or archiving, run a quick drift check** (specs vs code, reader docs vs code).
- **Stacked PRs.** Changes are developed as a stack: each change gets its own branch and PR, based on the previous branch in the stack (the first PR bases on `dev`). Review is requested on the whole stack at once, not per-PR, but every PR in the stack must independently pass CI checks and tests before review is requested. Merge in stack order, retargeting each PR to `dev` as its base merges.

## Analysis Project Structure

The analysis project uses `embr`/`cmdstanr`. kelpbio re-implements the same models using `rstan`/`rstantools` (pre-compiled Stan, no cmdstan required at runtime). Key analysis scripts:

| Topic | Model script | Stan file |
|-------|-------------|-----------|
| Weight (allometric) | `models-weight-nereo.R` | `stan/nereo/weight/weight-nereo.stan` |
| Size (distribution) | `models-size-nereo.R` | `stan/nereo/size/size-nereo.stan` |
| Density | `models-density-nereo.R` | `stan/nereo/density/density-nereo.stan` |
| Blade fraction | `models-blade-frac-nereo.R` | `stan/nereo/blade/blade-frac-nereo.stan` |
| Wet/dry | `models-wetdry-nereo.R` | `stan/nereo/wetdry/wetdry-nereo.stan` |
| Carbon | `models-carbon-nereo.R` | `stan/nereo/carbon/carbon-nereo.stan` |

kelpbio works at **site-year resolution — no month dimension** (the analysis models' month effects are dropped). Biomass combines all six models via **size-integration** (`density × E_size[weight(diameter)] × ratios`), not `density × weight`; see the `predictions` spec and `decisions/prediction-engine.md`. wetdry/carbon become intercept-only Beta (no REs) once month is dropped.

## Bayesian Engine

- **Backend**: `rstan` + `rstantools`. Stan models live in `inst/stan/` and are pre-compiled at `R CMD INSTALL` time.
- **No cmdstan**: users do not need `cmdstanr` or a separate Stan installation.
- **Sampling**: `rstan::sampling(stanmodels$<name>, data = stan_data, chains = 4, adapt_delta = 0.95, thin = nthin, ...)`
- **`devtools::load_all()` does not work** for Stan changes — always use `devtools::install()`.
- See `openspec/config.yaml` for the engine rules (Stan conventions, priors-as-data, structural flags) and `decisions/engine-choice.md` for why rstan/rstantools.

## Stan Model Adaptations (analysis project → kelpbio)

The analysis project Stan models require these adaptations for kelpbio:

1. **Priors as data** — analysis models hard-code priors; kelpbio passes all prior hyperparameters through the `data` block so users can adjust them via `kb_priors_*()`.
2. **Column naming** — analysis uses CamelCase (`SbulbMax`, `PlantW`, `Site`, `Year`); kelpbio uses snake_case (`diameter`, `weight`, `site`, `year`).

## OOP Pattern (S3, following bboutools)

```r
# Construction (internal only)
# Store EXTRACTED posterior draws, NOT the live stanfit (portable, small,
# rstan-version-robust; makes pre-fit models a non-special case).
fit <- list(draws = <posterior draws>, diagnostics = <sampler diag>, data = data, meta = meta)
class(fit) <- c("kb_fit_weight", "kb_fit")

# S3 methods dispatch to parent by default
augment.kb_fit         # parent: model-agnostic (coef/glance/converged/log_lik/samples/summary too)
tidy.kb_fit_weight     # subclass-specific: names its own terms (also fitted/residuals/predict/posterior_*)
```

Access via `$`: `x$draws`, `x$data`, `x$meta`. `samples(x)` returns a `posterior` `draws_rvars` object. The live `stanfit` is discarded after fitting — see the `fitting` spec. kelpbio ships via R-universe (not CRAN); its `data/` holds only simulated demo data and slim pre-fit models. The real publicly shared coastwide data and model fits live in a companion data package (`kelpbiodata`).

**Prediction / derived-quantity engine.** Predictions, summaries, and the biomass composition are computed from the stored draws with the `posterior` `rvar` datatype (per-model prediction is plain `rvar` arithmetic); grids built with `newdata::xnew_data` (no `rescale`); `coef`/`tidy`/`glance`/`augment`/`samples`/diagnostics reconstructed from the draws via `posterior`. The `predictions`/`summaries` specs are the behavioural contract and `decisions/prediction-engine.md` the rationale — read them before touching any `kb_predict_*`, summary, or biomass code.

## Package Conventions

- **Prefix**: all exported functions use `kb_`
- **Validation**: all exported function arguments validated with `chk`; user-facing messages via `cli`. Bespoke internal validators follow the bboutools `.vld_`/`.chk_` split: a `.vld_<name>()` in `R/vld.R` is a pure predicate returning a logical scalar (minimal args, no messaging); its `.chk_<name>()` partner in `R/chk.R` calls it and either returns the input invisibly or aborts via `cli`. Every bespoke `.chk_` has a matching `.vld_` (multi-arg `chk::` bundles like `.chk_sampler_args()` are exempt: no single predicate to pair). The `.chk_` may layer `chk::` primitives or re-derive granular messages where one boolean would be too coarse. Both are internal (leading dot, unexported). Example:

  ```r
  # R/vld.R
  .vld_new_data_weight_nereo <- function(x) {
    is.data.frame(x) && "diameter" %in% names(x)
  }
  # R/chk.R
  .chk_new_data_weight_nereo <- function(x, x_name = deparse(substitute(x))) {
    if (.vld_new_data_weight_nereo(x)) {
      return(invisible(x))
    }
    if (!is.data.frame(x)) {
      cli::cli_abort("{.arg {x_name}} must be a data frame or {.code NULL}.")
    }
    cli::cli_abort("{.arg {x_name}} must have a {.field diameter} column.")
  }
  ```
- **Documentation**: roxygen2 with markdown; `@inheritParams` for shared parameters. Write every exported topic for a first-time reader (see `~/.claude/CLAUDE.md`): no development/decision/debate context, rare edge cases, or testing/developer jargon (e.g. `snapshot-safe`, `load_all()` gotchas) in reader-facing docs; route rationale to code comments, `decisions/`, or a change's `design.md`. One job per section: **description** (first paragraph) is one short statement of what the function does or produces, not the return mechanics or a re-listing of arguments; **@details** covers only non-obvious behaviour a caller could get wrong (edge cases, argument interactions, a default's user-visible tradeoff rather than the mechanism behind it); **@return** is the sole home for the returned type/structure and any invisibly/side-effect note (validators return the input invisibly and are called for their side effect). Description voice: extractor/accessor topics use a noun phrase naming what they yield (`fitted`, `tidy`, `glance`, `log_lik`, `posterior_*`, `samples`); action functions use the imperative (`fit`, `predict`, `plot`, `check`, `construct`).
- **Arguments**: name by type, not by dispatch: `data` for input data, `fit` for a fit object (including the package's own generics `kb_stancode`/`samples`), `predictions` for a `kb_predictions` frame. S3 methods must keep the generic's first-arg name (`object` for base/stats/rstantools/ggplot2, `x` for generics/universals), which `R CMD check` enforces, so `object`/`x`/`fit` all naming the same fit is expected, not an inconsistency to fix. Multi-word names are snake_case (`new_data`, `new_levels`, `conf_level`); take the ecosystem spelling only where a generic fixes it (e.g. `transform` in `posterior_linpred`). Order follows the tidyverse data-descriptors-details shape: primary object, then descriptor arguments meant to be passed positionally (`new_data`, `by`, `diameter`/`fronds`, `priors`), then `...`, then every optional detail knob as a name-only argument after `...` (`new_levels`, `representative_site`, `conf_level`, `estimate`, `sig_fig`, `include_random_effects`, `rhat`, `esr`, sampler config) so details cannot be set positionally; guard an empty `...` with `rlang::check_dots_empty()`. The summary trio `conf_level, estimate, sig_fig` keeps that order everywhere. `@param` prose uses the chk vocabulary (`A flag specifying whether to ...`, `A whole number of ...`, `A number between 0 and 1 ...`, `A string, one of ...`, `A data frame of ...`), and names a fit argument by its dispatch class (`kb_fit` for parent-class methods, `kb_fit_weight` for weight-specific ones).
- **Writing** (docs, README, vignettes, roxygen, PR/commit text): follow the writing style in `~/.claude/CLAUDE.md`; in particular no em-dashes or en-dashes (use hyphens, commas, or colons) and no mid-sentence bold for emphasis; concise technical register
- **File layout**: one function per file, file named after the function (`kb_fit_weight_nereo()` → `R/kb_fit_weight_nereo.R`). S3 methods grouped one file per generic, named after the generic (`R/print.R` holds all `print.*` methods, `R/tidy.R` all `tidy.*`, etc.). Internal helpers in clearly-named files, never a catch-all `utils.R`.
- **Testing**: testthat 3e; strict 1:1 test mirroring (`R/<name>.R` ↔ `tests/testthat/test-<name>.R`). Test the wrapper, not the model's numbers. Snapshot print methods + messages; NEVER snapshot MCMC numerics (test structure + invariants instead). Small pre-built fits in `tests/testthat/fixtures/` (built with `rstan::sampling(seed=)`, not `set.seed`); slow end-to-end fits `skip_on_cran()`. Factor pure logic (data/prior assembly) out of fit functions for MCMC-free testing. See `decisions/bboutools-api-review.md` for the testing rationale.
- **Code style**: tidyverse; no lubridate, reshape2, plyr, or data.table
- **No `library()` calls** in package code; use `@importFrom` or `pkg::fun()`
- **Do not run Stan MCMC** during a session without confirming first; fitting is slow
