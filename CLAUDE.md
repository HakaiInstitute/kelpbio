# CLAUDE.md — kelpbio

R package for Bayesian kelp biomass estimation. All exported functions use the `kb_` prefix.

## Common Commands

| Task | Command |
|------|---------|
| Routine build + QC | `Rscript scripts/build.R` (runs `rstan_config()` → `install()` → `document()` → `test()`) |
| Full check (slow) | `Rscript scripts/build.R --check` (`R CMD check` in place of `test()`, since check runs the tests) |
| pkgdown site | `Rscript scripts/build.R --site` (CI builds the site and runs `R CMD check` on every PR, so neither is needed locally for routine work) |
| Rebuild pre-fit objects + fixtures (slow, MCMC) | `Rscript scripts/build.R --fits` re-fits every `data/fit_*_sim_*` and `tests/testthat/fixtures/*.rds`; `--fits=density,wetdry` only those models'. Run after changing the fit object structure (all models) or a model (that model) |
| Run all tests | `devtools::test()` |
| Run one test file | `testthat::test_file("tests/testthat/test-<name>.R")` or `devtools::test_active_file()` |
| Document | `devtools::document()` |

The build runs are also Positron/VS Code tasks (Command Palette > "Tasks: Run Task" > "kelpbio: ...", `.vscode/tasks.json`). Flags combine (`--fits=wetdry --check`); `--help` lists them.

- **After editing any `inst/stan/*.stan` file**: run `rstantools::rstan_config()` (regenerates `src/stanExports_*` and `R/stanmodels.R`), then `devtools::install()`. `devtools::load_all()`/`test()` compile from the generated C++ but do NOT re-transpile the Stan source, so `.stan` edits are silently missed without `rstan_config()` first. A fit stores its Stan source (`kb_stancode()`), so any `.stan` edit, comments included, also means rebuilding the pre-fits and fixtures (`--fits`) in the same PR.
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
- **Definition of done, all in the same PR:** code + tests green in CI, reader docs (roxygen / README / vignette) updated, specs and reader docs checked against the code, and the change archived. Do not defer archiving. Exception until the pending README and vignette pass lands: README and vignette updates wait for that one pass; roxygen, `_pkgdown.yml`, specs, and the demo scripts still update per PR.
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

Adaptations from the analysis Stan models: prior hyperparameters are passed through the `data` block (the analysis hard-codes them), and columns are snake_case (`diameter_mm`, `weight_kg`, `site`, `year`) rather than CamelCase.

## Bayesian Engine

- **Backend**: `rstan` + `rstantools`; Stan models in `inst/stan/` are pre-compiled at `R CMD INSTALL`. Users need no `cmdstanr` or Stan installation. Why: `decisions/engine-choice.md`.
- **Priors as data**: hyperparameters go in the Stan `data` block as `prior_<entry>_<argument>` (built by `prior_data()`); the prior family is fixed at compile time. Users set priors with `kb_prior_normal()` / `kb_prior_exponential()` / `kb_prior_lognormal()` in the list from `kb_priors_*()`.
- **Structural flags**: small effects are toggled by 0/1 data flags (`site_year_on`, `density_on`, `floor_on`, `prior_only`) that the fitting layer sets from the data or from a model-choice argument (`form`), never exposed as flag arguments themselves. Use a separate `.stan` only for a different likelihood or major variant; each species is such a variant (`decisions/species-as-variant.md`).
- **Parameter names** (snake_case, applied by rule even where nothing would collide; rationale and the mapping from the analysis names in `decisions/parameter-naming.md`):
  1. The intercept of a linear predictor is `intercept`.
  2. A parameter tied to a predictor is `<predictor>_<role>`, `<predictor>` being the Stan data field it acts on without its unit suffix: `<predictor>_slope` for a coefficient (`density_slope`, `fronds_slope`, `tide_height_slope`, `cover_slope`), `<predictor>_power` for an exponent (`diameter_power`).
  3. Group-level terms are `sd_<group>`, `<group>_effect`, and `z_<group>` (non-centred deviates) for `site`, `year`, and `site_year`.
  4. Distribution parameters take their standard names: `shape`, `dispersion` (negative binomial, variance `mu + dispersion * mu^2`), `precision` (Beta), `sd_residual`.
  5. A floor is `<quantity>_floor` (`weight_floor`, `biomass_floor`).
  6. Link-scale terms of a linear predictor take no scale prefix; a standalone scalar stored on a transformed scale takes `log_` or `logit_` (`logit_zero_inflation`).
  7. No parameter shares a name with a data field, an input column, a Stan reserved word (`lower`, `upper`, `offset`, `multiplier`, `target`), or a Stan function (`floor`, `gamma`, `beta`, `log`, `exp`).
  8. A parameter's prior entry in `kb_priors_*()` has the parameter's name.
- **Stan data names**: a field passing an input column through takes the column's name (`diameter_mm`, `area_m2`, `tide_height_m`); a derived field is named for its quantity (`log_biomass`, `dry_wet_ratio`, standardised `density`); sizes are `n_obs`, `n_site`, `n_year`; flags keep `<effect>_on`.
- **Stan code**: non-centred random effects (`site_effect = z_site * sd_site`); the mean is a local in the `model` block and there are no generated quantities, since `log_lik` and replicates are computed in R from the stored draws.
- **Sampling** defaults: 4 chains, `adapt_delta = 0.95`, thinning by `nthin`.

## Fit Objects and S3 Pattern (following bboutools)

```r
# Construction (internal only, new_kb_fit()). Store EXTRACTED posterior draws, NOT
# the live stanfit (portable, small, rstan-version-robust; makes pre-fit models a
# non-special case).
fit <- list(draws = <posterior draws>, diagnostics = <sampler diag>, data = data, meta = meta)
class(fit) <- c("kb_fit_weight_nereo", "kb_fit_weight", "kb_fit")

# Public method bodies live at the highest class tier at which they are invariant:
augment.kb_fit         # kb_fit: model-agnostic (also coef/glance/converged/
                       #   summary/tidy/fitted/residuals/log_lik/posterior_*)
predict.kb_fit_weight  # model tier: wraps the model-named kb_predict_weight()

# Whatever varies goes into an internal generic, in its own file (R/linpred.R,
# R/epred.R, R/obs_family.R) or the file of the public generic it serves. None
# that feeds a number has a total default: each aborts via .abort_no_method(), so
# a sub-model added without its methods fails loudly. .fit_descriptor is the one exception, supplying print()'s header
# fields, where a missing method degrades a display rather than a number.
.epred.kb_fit_weight              # model tier (nereo overrides for the lognormal mean)
.linpred.kb_fit_weight_nereo      # leaf: also .obs_family/.chk_new_data
# Per-model facts that are values, not behaviour, live in meta instead (offset,
# terms, predictor, predictor_ref, form, and the site_year_on/density_on flags). See "Meta Versus
# Dispatch" in decisions/architecture.md for the rule that decides which.
```

Access via `$`: `x$draws`, `x$data`, `x$meta`; `kb_samples(x)` and `posterior::as_draws(x)` return a `posterior` `draws_rvars` object of the estimated effects. Predictions and summaries are computed from the stored draws with `posterior` `rvar` arithmetic; read the `predictions`/`summaries` specs and `decisions/prediction-engine.md` before touching any `kb_predict_*`, summary, or biomass code. kelpbio ships via R-universe (not CRAN); its `data/` holds only simulated data and slim pre-fit models, and real data and coastwide fits belong in the companion package `kelpbiodata`.

## Package Conventions

- **Prefix**: all exported functions use `kb_`
- **Plain functions, not generics**: kelpbio's own exported functions (`kb_predict_*()`, `kb_samples()`, `kb_stancode()`, `kb_model_describe()`) are plain functions that check the fit class; every fit inherits `kb_fit`, so dispatch would add nothing. S3 methods are for generics owned by other packages (`tidy`, `predict`, `posterior_*`, `posterior::as_draws`) and for internal generics where behaviour varies by model.
- **Validation**: all exported function arguments validated with `chk`; user-facing messages via `cli`. Bespoke internal validators follow the bboutools `.vld_`/`.chk_` split: a `.vld_<name>()` in `R/vld.R` is a pure predicate returning a logical scalar (minimal args, no messaging); its `.chk_<name>()` partner in `R/chk.R` calls it and either returns the input invisibly or aborts via `cli`. Every bespoke `.chk_` has a matching `.vld_` (multi-arg `chk::` bundles like `.chk_sampler_args()` are exempt: no single predicate to pair). The `.chk_` may layer `chk::` primitives or re-derive granular messages where one boolean would be too coarse. Both are internal (leading dot, unexported). Errors name the function the user called: `chk::` errors name whichever function called the `chk_*()`, so an exported function (or a shared fit body, via its `call`) runs a check bundle inside `.with_call(..., rlang::current_env())`, and a bundle that aborts via `cli` takes a `call` argument. Example:

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
- **Input columns**: a column measured in a unit names it as a suffix (`diameter_mm`, `weight_kg`, `stipes_m2`); counts (`fronds`) and grouping columns (`site`, `year`) take none. A column shared by sub-models keeps one name and unit (`column_units`). Units are fixed, never converted; the plausibility warnings back them. Stan data fields that pass a column through keep its name and suffix; parameters and prior entries are not columns and take no unit suffix (`density_slope`, `diameter_power`).
- **Output columns**: summaries use `term` / `estimate` / `lower` / `upper` (following bboutools).
- **Documentation**: roxygen2 with markdown; `@inheritParams` (donor `R/params.R`) for shared parameters. Write every exported topic for a first-time reader (see `~/.claude/CLAUDE.md`): no development/decision/debate context, rare edge cases, or testing/developer jargon (e.g. `snapshot-safe`, `load_all()` gotchas) in reader-facing docs; route rationale to code comments, `decisions/`, or a change's `design.md`. One job per section: **description** (first paragraph) is one short statement of what the function does or produces, not the return mechanics or a re-listing of arguments; **@details** covers only non-obvious behaviour a caller could get wrong (edge cases, argument interactions, a default's user-visible tradeoff rather than the mechanism behind it); **@return** is the sole home for the returned type/structure and any invisibly/side-effect note (validators return the input invisibly and are called for their side effect). Description voice: extractor/accessor topics use a noun phrase naming what they yield (`fitted`, `tidy`, `glance`, `log_lik`, `posterior_*`, `kb_samples`); action functions use the imperative (`fit`, `predict`, `plot`, `check`, `construct`).
- **Arguments**: name by type, not by dispatch: `data` for input data, `fit` for a fit object (including `kb_stancode()` and `kb_samples()`), `predictions` for a `kb_predictions` frame. S3 methods must keep the generic's first-arg name (`object` for base/stats/rstantools/ggplot2, `x` for generics/posterior), which `R CMD check` enforces, so `object`/`x`/`fit` all naming the same fit is expected, not an inconsistency to fix. Multi-word names are snake_case (`new_data`, `new_levels`, `conf_level`); take the ecosystem spelling only where a generic fixes it (e.g. `transform` in `posterior_linpred`). Order follows the tidyverse data-descriptors-details shape: primary object, then descriptor arguments meant to be passed positionally (`new_data`, `by`, `priors`, then any model choice such as `form`, after `priors` so `priors` stays second in every fit function except the cover biomass fits, whose required `biomass` data frame comes second, before it), then `...`, then every optional detail knob as a name-only argument after `...` (`new_levels`, `representative_site`, `conf_level`, `estimate`, `sig_fig`, `include_random_effects`, `rhat`, `ess`, sampler config) so details cannot be set positionally; guard an empty `...` with `rlang::check_dots_empty()`. The exception is `kb_new_data()`, whose `...` takes the predictor by its column name (`diameter_mm`, `fronds`, or `cover`), checked against the fit. The summary trio `conf_level, estimate, sig_fig` keeps that order everywhere. `@param` prose uses the chk vocabulary (`A flag specifying whether to ...`, `A whole number of ...`, `A number between 0 and 1 ...`, `A string, one of ...`, `A data frame of ...`), and names a fit argument by its dispatch class (`kb_fit` for parent-class methods, `kb_fit_weight` for weight-specific ones).
- **Writing** (docs, README, vignettes, roxygen, specs, PR/commit text): follow the writing style in `~/.claude/CLAUDE.md`; in particular no em-dashes or en-dashes (use hyphens, commas, or colons) and no mid-sentence bold for emphasis; concise technical register
- **File layout**: one function per file, file named after the function (`kb_fit_weight_nereo()` → `R/kb_fit_weight_nereo.R`). S3 methods grouped one file per generic, named after the generic (`R/print.R` holds all `print.*` methods, `R/tidy.R` all `tidy.*`, etc.). Internal functions that share one contract go in one family file named for the family: `chk.R` (`.chk_*`), `vld.R` (`.vld_*`), `warn.R` (plausibility warnings on user data), `structural_flags.R` (`.site_year_on()`, `.density_on()`, `.floor_on()`), and one file per distribution for the extras-style `log_lik_*`/`res_*`/`ran_*` functions (`weibull.R`). Dataset documentation lives in `R/data.R` (simulated datasets) and `R/fits.R` (pre-fit models). A computation and the notifier that reports it share a file (`density_structure()` and `notify_density()`). Other internal helpers go in clearly-named files, never a catch-all `utils.R`.
- **Testing**: testthat 3e; strict 1:1 test mirroring (`R/<name>.R` ↔ `tests/testthat/test-<name>.R`). Test the wrapper, not the model's numbers. Snapshot print methods + messages; NEVER snapshot MCMC numerics (test structure + invariants instead). **Never accept snapshot changes** (`testthat::snapshot_accept()`, or accepting via any other route): snapshots are the user's review surface. Run the tests, report what changed and why, and leave the `.new` files in place for the user to review locally with `testthat::snapshot_review()`. Small pre-built fits in `tests/testthat/fixtures/` (built with `rstan::sampling(seed=)`, not `set.seed`); they test structure, not inference, and may not meet the strict `converged()` thresholds. Slow end-to-end fits `skip_on_cran()`. Factor pure logic (data/prior assembly) out of fit functions for MCMC-free testing.
- **Code style**: tidyverse; no lubridate, reshape2, plyr, or data.table
- **No `library()` calls** in package code; use `@importFrom` or `pkg::fun()`
- **Do not run Stan MCMC** during a session without confirming first; fitting is slow
