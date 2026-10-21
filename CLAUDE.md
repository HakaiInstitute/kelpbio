# CLAUDE.md — kelpbio

R package for Bayesian kelp biomass estimation. All exported functions use the `kb_` prefix.

## Repositories and issues

- Development (branches, commits, pull requests) happens in the HakaiInstitute repo (`HakaiInstitute/kelpbio`), never in the poissonconsulting fork.
- GitHub issues go in the poissonconsulting fork (`poissonconsulting/kelpbio`), not the HakaiInstitute repo, to keep them out of the client's repo. The fork is public, so its issues are still publicly visible: write nothing in them that should stay internal.
- The fork does not track the HakaiInstitute repo: sync it only once in a while, as it mostly holds the issues.

## Development workflow

- New work goes on a new branch in the main checkout (`~/Code/HakaiInstitute/kelpbio`), not a worktree unless asked: the user reviews diffs and accepts snapshots there. Other sessions may share the checkout, so stage only the files this session changed and list any others instead of committing them.
- Branches are stacked by default. Branch from the tip of the open PR stack (the open PR's branch that no other PR targets, from `gh pr list`) and confirm the tip before branching. When a change could stand apart from the stack, ask whether to stack it or base it on `dev`; never pick `dev` unasked. Each PR targets the branch below it, and only the bottom PR of a stack targets `dev`. Merge in stack order, retargeting each PR as its base merges.
- Commit and push only when asked, to `origin`; a request to push includes the build and `jarl check .` below. Never amend a pushed commit. After a push, show the stack (PR, branch, base, CI) and update the title and description of every PR whose contents changed.
- Before pushing, run `Rscript scripts/build.R` and `jarl check .`. CI runs R CMD check and jarl on every push to a PR, and lint is what fails most often: CI installs the latest jarl, so keep the local one current (`jarl --version`), and never assign inside a call (`out <- expect_no_warning(f())`, not `expect_no_warning(out <- f())`).
- Planned work goes in an issue on `poissonconsulting/kelpbio`, not session memory, so the next session can find it.
- Before opening or pushing a PR, scan the open issues (`gh issue list --repo poissonconsulting/kelpbio`, and the other two repos' forks for cross-repo work) for any the PR resolves, and list each in the PR description as `Closes poissonconsulting/kelpbio#<n>`. GitHub closes them only when the PR merges into the default branch, so a stacked PR's issues close once the stack reaches `main`; close any left open by hand after merging.
- Draft vignettes, simulation and side-analysis scripts, and review exports (`review/`) are never committed; ask when unsure whether a new file belongs in history.

## Common Commands

| Task | Command |
|------|---------|
| Routine build + QC | `Rscript scripts/build.R` (runs `rstan_config()` → `install()` → `document()` → `test()`) |
| Full check (slow) | `Rscript scripts/build.R --check` (`R CMD check` in place of `test()`, since check runs the tests) |
| pkgdown site | `Rscript scripts/build.R --site` (CI builds the site and runs `R CMD check` on every PR, so neither is needed locally for routine work) |
| Rebuild pre-fit objects + fixtures (slow, MCMC) | `Rscript scripts/build.R --fits` re-fits every `data/fit_*` (simulated) and `tests/testthat/fixtures/*.rds`; `--fits=size,wetdry` only those models' (when: see Tests or rebuilt fits) |
| Run all tests | `devtools::test()` |
| Run one test file | `testthat::test_file("tests/testthat/test-<name>.R")` or `devtools::test_active_file()` |
| Document | `devtools::document()` |

The build runs are also Positron/VS Code tasks (Command Palette > "Tasks: Run Task" > "kelpbio: ...", `.vscode/tasks.json`). Flags combine (`--fits=wetdry --check`); `--help` lists them.

- **After editing any `inst/stan/*.stan` file**: run `rstantools::rstan_config()` (regenerates `src/stanExports_*` and `R/stanmodels.R`), then `devtools::install()`. `devtools::load_all()`/`test()` compile from the generated C++ but do NOT re-transpile the Stan source, so `.stan` edits are silently missed without `rstan_config()` first. Then rebuild that model's fits (see Tests or rebuilt fits).
- When a change removes exports, run `devtools::document()` before `devtools::install()`: install reads NAMESPACE and fails on exports that no longer exist.
- Generated files (`R/stanmodels.R`, `src/stanExports_*`, `src/RcppExports.cpp`) are never hand-edited and are excluded from styling and linting.
- `install()` writes to the user's library, which kelpbioshiny and kelpbiodata use: never build while the user's own build is running.

## Tests or rebuilt fits

- Any change: `Rscript scripts/build.R` runs the tests. It never refits.
- Rebuild a model's pre-fit and test fixture (`--fits=<model>`) when its `.stan` file changes (comments included, as a fit stores its Stan source), when what its fit stores changes (data assembly, default priors, `meta`), or when the simulated data it is fitted to change. Rebuild all of them (`--fits`) when the shared fit object changes (`new_kb_fit()`, shared `meta` or diagnostics).
- A refit is Stan MCMC: confirm before running one, unless it is part of a change the user approved, then report the snapshot diffs. A design that needs a refit is fine when it is better.
- The same triggers mean kelpbiodata's reference fits need rebuilding, and a change to the simulated data means kelpbioshiny's example workbooks do.

## Where Things Live

| Resource | Path |
|----------|------|
| Analysis project (final models + Stan code) | `~/Analyses/poissonconsulting/hakai-kelp-biomass-25/` |
| Reference package architecture | `~/Code/poissonconsulting/bboutools/` |
| Observable behaviour (the package contract) | `openspec/specs/` (`fitting`, `predictions`, `summaries`) |
| OpenSpec workflow and what lives where | `openspec/workflow.md` |
| Rules for change artifacts | `openspec/config.yaml` |
| Decision records | `decisions/` (superseded records in `decisions/archive/`) |
| Documentation style | `STYLE.md` |

One fact, one home: behaviour in the specs, the exact models and outputs in code, tests, and snapshots, conventions here, lasting rationale in `decisions/`, per-change rationale in that change's `design.md`. When implementing any feature, read the corresponding analysis project script and Stan file first; the analysis project contains the final, validated model code that kelpbio adapts.

## Change Workflow (OpenSpec)

@openspec/workflow.md

In addition:

- **One change, one branch, one PR.** An OpenSpec change is proposed, implemented and archived (`openspec archive <name> --yes`) on its own branch in the stack, and archived before review is requested; never leave archiving to a later PR.
- **README and vignettes wait** for the one pending pass over them; roxygen, `_pkgdown.yml`, specs and the demo scripts still update in each PR.
- **Trust the test suite + green CI as the "done" signal**, not `tasks.md` checkboxes. Every PR in the stack passes CI on its own before review is requested on the whole stack.
- **The analysis project wins**: when a spec and the analysis project's model code disagree, follow the analysis project.
- **Simplest design**: optimise for one reviewer; prefer the design with less code, and report the net lines added or removed.
- **Pre-release** (version `0.0.0.9000`): no NEWS entries, version bumps, deprecations or backward compatibility; rename freely. From the first release, follow the tidyverse release process: a NEWS bullet for each user-facing change, semantic versions set with `usethis::use_version()`, and lifecycle for deprecations.
- **`decisions/` are live documents**: overwrite them to describe the current design rather than appending dated revisions. Git keeps the history.

## Analysis Project Structure

The analysis project uses `embr`/`cmdstanr`. kelpbio re-implements the same models using `rstan`/`rstantools`. Key analysis scripts:

| Topic | Model script | Stan file |
|-------|-------------|-----------|
| Weight (allometric) | `models-weight-nereo.R` | `stan/nereo/weight/weight-nereo.stan` |
| Size (distribution) | `models-size-nereo.R` | `stan/nereo/size/size-nereo.stan` |
| Cover calibration | `models-cover-nereo.R` | `stan/nereo/cover/cover-offset.stan` |
| Blade fraction | `models-blade-frac-nereo.R` | `stan/nereo/blade/blade-frac-nereo.stan` |
| Wet/dry | `models-wetdry-nereo.R` | `stan/nereo/wetdry/wetdry-nereo.stan` |
| Carbon | `models-carbon-nereo.R` | `stan/nereo/carbon/carbon-nereo.stan` |

kelpbio estimates the **peak season at site-year resolution, with no month dimension** (the analysis models' month effects are dropped); a site-year may hold several plots and a plot several surveys. Biomass of an in situ survey is its counted plants' expected weight over the area searched (mean plant weight by size integration for tallied plants); the cover calibration relates it to drone cover, and totals apply the calibration over mapped canopy. There is no density model and no *Macrocystis* size model; see `decisions/prediction-engine.md`.

Adaptations from the analysis Stan models: prior hyperparameters are passed through the `data` block (the analysis hard-codes them), and columns are snake_case (`diameter_mm`, `weight_kg`, `site`, `year`) rather than CamelCase.

## Bayesian Engine

- **Backend**: `rstan` + `rstantools`; Stan models in `inst/stan/` are pre-compiled at `R CMD INSTALL`. Users need no `cmdstanr` or Stan installation. Why: `decisions/engine-choice.md`.
- **Priors as data**: hyperparameters go in the Stan `data` block as `prior_<entry>_<argument>` (built by `prior_data()`); the prior family is fixed at compile time. Users set priors with `kb_prior_normal()` / `kb_prior_exponential()` / `kb_prior_lognormal()` in the list from `kb_priors_*()`.
- **Structural flags**: small effects are toggled by 0/1 data flags (`floor_on`, `prior_only`) that the fitting layer sets from the data or from a model-choice argument (`form`), never exposed as flag arguments themselves. Use a separate `.stan` only for a different likelihood or major variant; each species is such a variant (`decisions/species-as-variant.md`).
- **Parameter and Stan data names** follow the rules in `decisions/parameter-naming.md`: read them before adding or renaming a parameter, prior entry or Stan data field.
- **Stan code**: non-centred random effects (`site_effect = z_site * sd_site`); the mean is a local in the `model` block and there are no generated quantities, since `log_lik` and replicates are computed in R from the stored draws.
- **Sampling** defaults: 4 chains, `adapt_delta = 0.95`, thinning by `nthin`.

## Fit Objects and S3 Pattern (following bboutools)

A fit is a list of `draws` (extracted posterior draws, never the live stanfit), `diagnostics`, `data` and `meta`, built only by the internal `new_kb_fit()` and classed `c("kb_fit_<model>_<species>", "kb_fit_<model>", "kb_fit")`. Public method bodies live at the highest class tier at which they are invariant (most on `kb_fit`); what varies goes to an internal generic (`.linpred`, `.epred`, `.obs_family`, each in its own file) whose default aborts. Whether a per-model fact is a `meta` value or a generic: `decisions/architecture.md` ("Meta Versus Dispatch").

Access via `$`: `x$draws`, `x$data`, `x$meta`; `kb_samples(x)` and `posterior::as_draws(x)` return a `posterior` `draws_rvars` object of the estimated effects. Predictions and summaries are computed from the stored draws with `posterior` `rvar` arithmetic; read the `predictions`/`summaries` specs and `decisions/prediction-engine.md` before touching any `kb_predict_*`, summary, or biomass code. kelpbio ships via R-universe (not CRAN); its `data/` holds only simulated data and slim pre-fit models. Real data and the reference fits to Hakai Institute and coastwide data (`fit_*_hakai_*`, `fit_weight_coastwide_nereo`) live in the companion package `kelpbiodata` (in Suggests, installed from GitHub via `Remotes`); kelpbioshiny reads them from there. Code in kelpbio that uses them (README, examples, vignettes) guards on `rlang::is_installed("kelpbiodata")` and calls them as `kelpbiodata::fit_*`.

## Package Conventions

- **Plain functions, not generics**: kelpbio's own exported functions (`kb_predict_*()`, `kb_samples()`, `kb_stancode()`, `kb_model_describe()`) are plain functions that check the fit class; every fit inherits `kb_fit`, so dispatch would add nothing. S3 methods are for generics owned by other packages (`tidy`, `predict`, `posterior_*`, `posterior::as_draws`) and for internal generics where behaviour varies by model.
- **Validation**: all exported function arguments validated with `chk`; user-facing messages via `cli`. Bespoke internal validators follow the bboutools `.vld_`/`.chk_` split: a `.vld_<name>()` in `R/vld.R` is a pure predicate returning a logical scalar (minimal args, no messaging); its `.chk_<name>()` partner in `R/chk.R` calls it and either returns the input invisibly or aborts via `cli`. Every bespoke `.chk_` has a matching `.vld_` (multi-arg `chk::` bundles like `.chk_sampler_args()` are exempt: no single predicate to pair). The `.chk_` may layer `chk::` primitives or re-derive granular messages where one boolean would be too coarse. Both are internal (leading dot, unexported). Errors name the function the user called: `chk::` errors name whichever function called the `chk_*()`, so an exported function (or a shared fit body, via its `call`) runs a check bundle inside `.with_call(..., rlang::current_env())`, and a bundle that aborts via `cli` takes a `call` argument. (`.vld_kb_fit()` and `.chk_kb_fit()` are the pattern to follow).
- **Input columns**: a column measured in a unit names it as a suffix (`diameter_mm`, `weight_kg`, `survey_area_m2`); counts (`fronds`, `plants`) and grouping columns (`site`, `year`) take none. A column shared by sub-models keeps one name and unit (`column_units`). Units are fixed, never converted; the plausibility warnings back them. Stan data fields that pass a column through keep its name and suffix; parameters and prior entries are not columns and take no unit suffix (`fronds_slope`, `diameter_power`).
- **Output columns**: summaries use `term` / `estimate` / `lower` / `upper` (following bboutools).
- **Documentation**: roxygen2 with markdown; shared parameters and sections live in `R/params.R` (`@inheritParams params`, `@inheritSection params`). Wording follows `STYLE.md`.
- **Arguments**: name by type, not by dispatch: `data` for input data, `fit` for a fit object (including `kb_stancode()` and `kb_samples()`), `predictions` for a `kb_predictions` frame. S3 methods must keep the generic's first-arg name (`object` for base/stats/rstantools/ggplot2, `x` for generics/posterior), which `R CMD check` enforces, so `object`/`x`/`fit` all naming the same fit is expected, not an inconsistency to fix. Multi-word names are snake_case (`new_data`, `new_levels`, `conf_level`); take the ecosystem spelling only where a generic fixes it (e.g. `transform` in `posterior_linpred`). Order follows the tidyverse data-descriptors-details shape: primary object, then descriptor arguments meant to be passed positionally (`new_data`, `by`, `priors`, then any model choice such as `form`, after `priors` so `priors` stays second in every fit function; the derived verbs take their fits first, then their data, then the optional conversion fits `wetdry` and `carbon`), then `...`, then every optional detail knob as a name-only argument after `...` (`measure`, `per_area`, `pool_by`, `new_levels`, `representative_site`, `conf_level`, `estimate`, `sig_fig`, `include_random_effects`, `rhat`, `ess`, sampler config) so details cannot be set positionally; guard an empty `...` with `rlang::check_dots_empty()`. The exception is `kb_new_data()`, whose `...` takes the predictor by its column name (`diameter_mm`, `fronds`, or `cover`) and levels of `site` or `year` not in `by`, checked against the fit. The summary trio `conf_level, estimate, sig_fig` keeps that order everywhere. `@param` wording follows `STYLE.md`.
- **Writing**: every reader-facing text (roxygen, `_pkgdown.yml`, README, vignettes, specs, PR and commit text) follows `STYLE.md`.
- **File layout**: one function per file, file named after the function (`kb_fit_weight_nereo()` → `R/kb_fit_weight_nereo.R`). S3 methods grouped one file per generic, named after the generic (`R/print.R` holds all `print.*` methods, `R/tidy.R` all `tidy.*`, etc.). Internal functions that share one contract go in one family file named for the family: `chk.R` (`.chk_*`), `vld.R` (`.vld_*`), `warn.R` (plausibility warnings on user data), `structural_flags.R` (`.site_year_on()`, `.floor_on()`), and one file per distribution for the extras-style `log_lik_*`/`res_*`/`ran_*` functions (`weibull.R`). Dataset documentation lives in `R/data.R` (simulated datasets) and `R/fits.R` (pre-fit models). A computation and the notifier that reports it share a file (`site_year_aliasing()` and `notify_site_year()`). Other internal helpers go in clearly-named files, never a catch-all `utils.R`.
- **Testing**: testthat 3e; strict 1:1 test mirroring (`R/<name>.R` ↔ `tests/testthat/test-<name>.R`). A change in behaviour adds or updates a test in the mirrored file; a bug fix adds a test that fails before the fix. Extend an existing test before adding one, and test nothing that cannot happen. Test the wrapper, not the model's numbers. Snapshot messages, print methods, plots (`vdiffr::expect_doppelganger()`) and output tables (`expect_snapshot_data()`, a CSV rounded to 3 significant figures) computed from the fixtures: their draws are stored, so these change only when the code or a fixture does, and a refit's snapshot diffs are reviewed with it. Relationships between outputs (per area is total over area, dry is wet times the ratio) stay as expectations, and printed values a refit can flip (`Converged`) are redacted. **Never accept snapshot changes** (`testthat::snapshot_accept()`, or accepting via any other route): snapshots are the user's review surface. Run the tests, report what changed and why, and leave the `.new` files in place for the user to review locally with `testthat::snapshot_review()`. Small pre-built fits in `tests/testthat/fixtures/` (built with `rstan::sampling(seed=)`, not `set.seed`); they test structure, not inference, and may not meet the strict `converged()` thresholds. Slow end-to-end fits `skip_on_cran()`. Factor pure logic (data/prior assembly) out of fit functions for MCMC-free testing.
- **Code style**: tidyverse; no lubridate, reshape2, plyr, or data.table
- **No `library()` calls** in package code; use `@importFrom` or `pkg::fun()`
