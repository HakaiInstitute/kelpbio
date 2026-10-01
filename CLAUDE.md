# CLAUDE.md — kelpbio

R package for Bayesian kelp biomass estimation. All exported functions use the `kb_` prefix.

## Common Commands

| Task | Command |
|------|---------|
| Routine build + QC | `Rscript scripts/build.R` (runs `rstan_config()` → `install()` → `roxygen2md()` → `document()` → `test()`) |
| Full check (slow) | `Rscript scripts/build.R --check` (adds pkgdown and `R CMD check`) |
| Rebuild pre-fit objects + fixtures (slow, MCMC) | `Rscript scripts/build.R --fits` (re-fits `data/fit_weight_sim_*` and `tests/testthat/fixtures/*.rds`; run after changing the fit object structure or a model) |
| Run all tests | `devtools::test()` |
| Run one test file | `testthat::test_file("tests/testthat/test-<name>.R")` or `devtools::test_active_file()` |
| Document | `devtools::document()` |

The build runs are also Positron/VS Code tasks (Command Palette > "Tasks: Run Task" > "kelpbio: ...", `.vscode/tasks.json`). Flags combine (`--fits --check`); `--help` lists them.

- **After editing any `inst/stan/*.stan` file**: run `rstantools::rstan_config()` (regenerates `src/stanExports_*` and `R/stanmodels.R`), then `devtools::install()`. `devtools::load_all()`/`test()` compile from the generated C++ but do NOT re-transpile the Stan source, so `.stan` edits are silently missed without `rstan_config()` first.
- When a change removes exports, run `devtools::document()` before `devtools::install()`: install reads NAMESPACE and fails on exports that no longer exist.
- Generated files (`R/stanmodels.R`, `src/stanExports_*`, `src/RcppExports.cpp`) are never hand-edited and are excluded from styling and linting.
- **Linting** runs in CI via jarl (`.github/workflows/lint-with-jarl.yaml`, config `jarl.toml`); the build script does not lint.

## Where Things Live

| Resource | Path |
|----------|------|
| Analysis project (final models + Stan code) | `~/Analyses/poissonconsulting/hakai-kelp-biomass-25/` |
| Reference package architecture | `~/Code/poissonconsulting/bboutools/` |
| Observable behaviour (the package contract) | `openspec/specs/` (`fitting`, `predictions`, `summaries`) |
| OpenSpec workflow and what lives where | `openspec/workflow.md` |
| Rules for change artifacts | `openspec/config.yaml` |
| Decision records | `decisions/` (superseded records in `decisions/archive/`) |

One fact, one home: behaviour in the specs, the exact models and outputs in code, tests, and snapshots, conventions here, lasting rationale in `decisions/`, per-change rationale in that change's `design.md`. When implementing any feature, read the corresponding analysis project script and Stan file first; the analysis project contains the final, validated model code that kelpbio adapts.

## Change Workflow

Follow `openspec/workflow.md`. In addition:

- **A change folder only for user-visible behaviour or model changes.** Fixes, refactors, tests, and docs go straight through, with `Spec impact: none` in the PR.
- **Definition of done, all in the same PR:** code + tests green in CI, reader docs (roxygen / README / vignette) updated, specs and reader docs checked against the code, and the change archived. Do not defer archiving.
- **One open change per capability.** Two unarchived changes rewriting the same requirement regress the spec when the second is archived.
- **Trust the test suite + green CI as the "done" signal**, not `tasks.md` checkboxes.
- **Stacked PRs.** Each change gets its own branch and PR, based on the previous branch in the stack (the first bases on `dev`). Every PR must pass CI on its own before review is requested on the whole stack; merge in stack order, retargeting each PR to `dev` as its base merges.
- **`decisions/` are live documents**: overwrite them to describe the current design rather than appending dated revisions. Git keeps the history.

## Analysis Project Structure

The analysis project uses `embr`/`cmdstanr`. kelpbio re-implements the same models using `rstan`/`rstantools`. Key analysis scripts:

| Topic | Model script | Stan file |
|-------|-------------|-----------|
| Weight (allometric) | `models-weight-nereo.R` | `stan/nereo/weight/weight-nereo.stan` |
| Size (distribution) | `models-size-nereo.R` | `stan/nereo/size/size-nereo.stan` |
| Density | `models-density-nereo.R` | `stan/nereo/density/density-nereo.stan` |
| Blade fraction | `models-blade-frac-nereo.R` | `stan/nereo/blade/blade-frac-nereo.stan` |
| Wet/dry | `models-wetdry-nereo.R` | `stan/nereo/wetdry/wetdry-nereo.stan` |
| Carbon | `models-carbon-nereo.R` | `stan/nereo/carbon/carbon-nereo.stan` |

kelpbio works at **site-year resolution, with no month dimension** (the analysis models' month effects are dropped). Biomass combines the sub-models by size integration, not `density × weight`; see `decisions/prediction-engine.md`.

Adaptations from the analysis Stan models: prior hyperparameters are passed through the `data` block (the analysis hard-codes them), and columns are snake_case (`diameter`, `weight`, `site`, `year`) rather than CamelCase.

## Bayesian Engine

- **Backend**: `rstan` + `rstantools`; Stan models in `inst/stan/` are pre-compiled at `R CMD INSTALL`. Users need no `cmdstanr` or Stan installation. Why: `decisions/engine-choice.md`.
- **Priors as data**: hyperparameters go in the Stan `data` block; the prior family is fixed at compile time. Users set priors with `kb_prior_normal()` / `kb_prior_exponential()` in the list from `kb_priors_*()`.
- **Structural flags**: small effects are toggled by 0/1 data flags (`site_year_on`, `density_on`, `prior_only`) that the fitting layer sets from the data, never user arguments. Use a separate `.stan` only for a different likelihood or major variant; each species is such a variant (`decisions/species-as-variant.md`).
- **Stan code**: non-centred random effects (`z_* * s_*`); the mean is a local in the `model` block and there are no generated quantities, since `log_lik` and replicates are computed in R from the stored draws.
- **Sampling** defaults: 4 chains, `adapt_delta = 0.95`, thinning by `nthin`.

## Fit Objects and S3 Pattern (following bboutools)

```r
# Construction (internal only, new_kb_fit()). Store EXTRACTED posterior draws, NOT
# the live stanfit (portable, small, rstan-version-robust; makes pre-fit models a
# non-special case).
fit <- list(draws = <posterior draws>, diagnostics = <sampler diag>, data = data, meta = meta)
class(fit) <- c("kb_fit_weight_nereo", "kb_fit_weight", "kb_fit")

# Public method bodies live at the highest class tier at which they are invariant:
augment.kb_fit         # kb_fit: model-agnostic (also coef/glance/converged/samples/
                       #   summary/tidy/fitted/residuals/log_lik/posterior_*)
predict.kb_fit_weight  # model tier: wraps the model-named kb_predict_weight()

# Whatever varies goes into an internal generic, defined in the file of the public
# generic it serves. None that feeds a number has a total default: each aborts via
# .abort_no_method() with generic = NULL, so a sub-model added without its methods
# fails loudly. .fit_descriptor is the one exception, supplying print()'s header
# fields, where a missing method degrades a display rather than a number.
.epred.kb_fit_weight              # model tier (nereo overrides for the lognormal mean)
.linpred.kb_fit_weight_nereo      # leaf: also .log_lik/.deviance/.add_noise/.chk_new_data
# Per-model facts that are values, not behaviour, live in meta instead (offset,
# terms, predictor, predictor_ref, the structural flags). See "Meta Versus
# Dispatch" in decisions/architecture.md for the rule that decides which.
```

Access via `$`: `x$draws`, `x$data`, `x$meta`; `samples(x)` returns a `posterior` `draws_rvars` object. Predictions and summaries are computed from the stored draws with `posterior` `rvar` arithmetic; read the `predictions`/`summaries` specs and `decisions/prediction-engine.md` before touching any `kb_predict_*`, summary, or biomass code. kelpbio ships via R-universe (not CRAN); its `data/` holds only simulated data and slim pre-fit models, and real data and coastwide fits belong in the companion package `kelpbiodata`.

## Package Conventions

- **Prefix**: all exported functions use `kb_`
- **Validation**: all exported function arguments validated with `chk`; user-facing messages via `cli`. Bespoke internal validators follow the bboutools `.vld_`/`.chk_` split: a `.vld_<name>()` in `R/vld.R` is a pure predicate returning a logical scalar (minimal args, no messaging); its `.chk_<name>()` partner in `R/chk.R` calls it and either returns the input invisibly or aborts via `cli`. Every bespoke `.chk_` has a matching `.vld_` (multi-arg `chk::` bundles like `.chk_sampler_args()` are exempt: no single predicate to pair). The `.chk_` may layer `chk::` primitives or re-derive granular messages where one boolean would be too coarse. Both are internal (leading dot, unexported). Example:

  ```r
  # R/vld.R
  .vld_density <- function(x) {
    all(is.na(x)) || (is.numeric(x) && all(x >= 0, na.rm = TRUE))
  }
  # R/chk.R
  .chk_density <- function(x, x_name = deparse(substitute(x))) {
    if (.vld_density(x)) {
      return(invisible(x))
    }
    if (!is.numeric(x)) {
      cli::cli_abort("{x_name} must be numeric.")
    }
    cli::cli_abort("{x_name} must be greater than or equal to 0.")
  }
  ```
- **Output columns**: summaries use `term` / `estimate` / `lower` / `upper` (following bboutools).
- **Documentation**: roxygen2 with markdown; `@inheritParams` (donor `R/params.R`) for shared parameters. Write every exported topic for a first-time reader (see `~/.claude/CLAUDE.md`): no development/decision/debate context, rare edge cases, or testing/developer jargon (e.g. `snapshot-safe`, `load_all()` gotchas) in reader-facing docs; route rationale to code comments, `decisions/`, or a change's `design.md`. One job per section: **description** (first paragraph) is one short statement of what the function does or produces, not the return mechanics or a re-listing of arguments; **@details** covers only non-obvious behaviour a caller could get wrong (edge cases, argument interactions, a default's user-visible tradeoff rather than the mechanism behind it); **@return** is the sole home for the returned type/structure and any invisibly/side-effect note (validators return the input invisibly and are called for their side effect). Description voice: extractor/accessor topics use a noun phrase naming what they yield (`fitted`, `tidy`, `glance`, `log_lik`, `posterior_*`, `samples`); action functions use the imperative (`fit`, `predict`, `plot`, `check`, `construct`).
- **Arguments**: name by type, not by dispatch: `data` for input data, `fit` for a fit object (including the package's own generics `kb_stancode`/`samples`), `predictions` for a `kb_predictions` frame. S3 methods must keep the generic's first-arg name (`object` for base/stats/rstantools/ggplot2, `x` for generics/universals), which `R CMD check` enforces, so `object`/`x`/`fit` all naming the same fit is expected, not an inconsistency to fix. Multi-word names are snake_case (`new_data`, `new_levels`, `conf_level`); take the ecosystem spelling only where a generic fixes it (e.g. `transform` in `posterior_linpred`). Order follows the tidyverse data-descriptors-details shape: primary object, then descriptor arguments meant to be passed positionally (`new_data`, `by`, `diameter`/`fronds`, `priors`), then `...`, then every optional detail knob as a name-only argument after `...` (`new_levels`, `representative_site`, `conf_level`, `estimate`, `sig_fig`, `include_random_effects`, `rhat`, `esr`, sampler config) so details cannot be set positionally; guard an empty `...` with `rlang::check_dots_empty()`. The summary trio `conf_level, estimate, sig_fig` keeps that order everywhere. `@param` prose uses the chk vocabulary (`A flag specifying whether to ...`, `A whole number of ...`, `A number between 0 and 1 ...`, `A string, one of ...`, `A data frame of ...`), and names a fit argument by its dispatch class (`kb_fit` for parent-class methods, `kb_fit_weight` for weight-specific ones).
- **Writing** (docs, README, vignettes, roxygen, specs, PR/commit text): follow the writing style in `~/.claude/CLAUDE.md`; in particular no em-dashes or en-dashes (use hyphens, commas, or colons) and no mid-sentence bold for emphasis; concise technical register
- **File layout**: one function per file, file named after the function (`kb_fit_weight_nereo()` → `R/kb_fit_weight_nereo.R`). S3 methods grouped one file per generic, named after the generic (`R/print.R` holds all `print.*` methods, `R/tidy.R` all `tidy.*`, etc.). Internal helpers in clearly-named files, never a catch-all `utils.R`.
- **Testing**: testthat 3e; strict 1:1 test mirroring (`R/<name>.R` ↔ `tests/testthat/test-<name>.R`). Test the wrapper, not the model's numbers. Snapshot print methods + messages; NEVER snapshot MCMC numerics (test structure + invariants instead). **Never accept snapshot changes** (`testthat::snapshot_accept()`, or accepting via any other route): snapshots are the user's review surface. Run the tests, report what changed and why, and leave the `.new` files in place for the user to review locally with `testthat::snapshot_review()`. Small pre-built fits in `tests/testthat/fixtures/` (built with `rstan::sampling(seed=)`, not `set.seed`); they test structure, not inference, and may not meet the strict `converged()` thresholds. Slow end-to-end fits `skip_on_cran()`. Factor pure logic (data/prior assembly) out of fit functions for MCMC-free testing.
- **Code style**: tidyverse; no lubridate, reshape2, plyr, or data.table
- **No `library()` calls** in package code; use `@importFrom` or `pkg::fun()`
- **Do not run Stan MCMC** during a session without confirming first; fitting is slow
