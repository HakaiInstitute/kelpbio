# CLAUDE.md — kelpbio

R package for Bayesian kelp biomass estimation. All exported functions use the `kb_` prefix.

## Common Commands

| Task | Command |
|------|---------|
| Routine build + QC | `Rscript scripts/build.R` (runs `rstan_config()` → `roxygen2md()` → `styler` → `document()` → `test()`) |
| Full check (slow) | `KELPBIO_FULL_CHECK=true Rscript scripts/build.R` (adds `R CMD check` + pkgdown, recompiles Stan) |
| Run all tests | `devtools::test()` |
| Run one test file | `testthat::test_file("tests/testthat/test-<name>.R")` or `devtools::test_active_file()` |
| Document | `devtools::document()` |

- **After editing any `inst/stan/*.stan` file**: run `rstantools::rstan_config()` (regenerates `src/stanExports_*` and `R/stanmodels.R`), then `devtools::install()`. `devtools::load_all()`/`test()` compile from the generated C++ but do NOT re-transpile the Stan source, so `.stan` edits are silently missed without `rstan_config()` first.
- Generated files (`R/stanmodels.R`, `src/stanExports_*`, `src/RcppExports.cpp`) are never hand-edited and are excluded from styling and linting.
- **Linting** runs in CI via jarl (`.github/workflows/lint-with-jarl.yaml`, config `jarl.toml`); the build script does not lint, so local and CI checks stay in sync.

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
augment.kb_fit    # all subclasses
tidy.kb_fit_weight  # subclass-specific
```

Access via `$`: `x$draws`, `x$data`, `x$meta`. `samples(x)` returns a `posterior` `draws_rvars` object. The live `stanfit` is discarded after fitting — see the `fitting` spec. Single package (R-universe, not CRAN): demo + coastwide data + slim pre-fit models in `data/`; no companion data package.

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
- **Documentation**: roxygen2 with markdown; `@inheritParams` for shared parameters
- **Writing** (docs, README, vignettes, roxygen, PR/commit text): follow the writing style in `~/.claude/CLAUDE.md`; in particular no em-dashes or en-dashes (use hyphens, commas, or colons) and no mid-sentence bold for emphasis; concise technical register
- **File layout**: one function per file, file named after the function (`kb_fit_weight_nereo()` → `R/kb_fit_weight_nereo.R`). S3 methods grouped one file per generic, named after the generic (`R/print.R` holds all `print.*` methods, `R/tidy.R` all `tidy.*`, etc.). Internal helpers in clearly-named files, never a catch-all `utils.R`.
- **Testing**: testthat 3e; strict 1:1 test mirroring (`R/<name>.R` ↔ `tests/testthat/test-<name>.R`). Test the wrapper, not the model's numbers. Snapshot print methods + messages; NEVER snapshot MCMC numerics (test structure + invariants instead). Small pre-built fits in `tests/testthat/fixtures/` (built with `rstan::sampling(seed=)`, not `set.seed`); slow end-to-end fits `skip_on_cran()`. Factor pure logic (data/prior assembly) out of fit functions for MCMC-free testing. See `decisions/bboutools-api-review.md` for the testing rationale.
- **Code style**: tidyverse; no lubridate, reshape2, plyr, or data.table
- **No `library()` calls** in package code; use `@importFrom` or `pkg::fun()`
- **Do not run Stan MCMC** during a session without confirming first; fitting is slow
