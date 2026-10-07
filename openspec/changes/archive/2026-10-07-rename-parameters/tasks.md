Mappings and rules: design.md. Every Stan file changes, so `rstan_config()` and
`devtools::install()` checkpoints apply, and the pre-fit objects and fixtures are
refitted once, last (section 7). Until then, tests that read the old fixtures
fail on the old names; the R-only steps are tested with `load_all()` where they
do not touch stored draws.

## 1. Prior constructors and default priors

- [x] 1.1 Add `kb_prior_lognormal(meanlog, sdlog)` (`R/kb_prior_lognormal.R`): chk validation, print method, `.describe_prior()` form `LogNormal(meanlog, sdlog)`, roxygen, test file
- [x] 1.2 Rename the entries of every `kb_priors_*()` per design.md; cover `cover_slope` becomes `kb_prior_lognormal()` with the current hyperparameters; update each topic's roxygen and examples
- [x] 1.3 Update `tests/testthat/test-kb_priors_*.R` and `test-resolve_priors.R` for the new entry names

## 2. Stan programs

- [x] 2.1 Rename parameters, transformed parameters, data fields, sizes, and prior hyperparameter fields in every `inst/stan/*.stan` file per design.md; update header comments
- [x] 2.2 Update every `assemble_*_data()` to emit the new data field names, and their tests
- [x] 2.3 CHECKPOINT: `rstantools::rstan_config()`, then `devtools::install()`; confirm every model compiles

## 3. R code reading draws or parameter names

- [x] 3.1 Update the `param_vars` and `terms` passed by each fit function and `fit_beta_model()` / `fit_cover_biomass_model()`
- [x] 3.2 Update every draw access by name (`.linpred`, `.epred`, `.log_lik`, `residuals`, `posterior_predict`, `mean_plant_weight`, `site_biomass_draws`, `population_draws`, random-effect resolution, and any other reference found by grep)
- [x] 3.3 Update `kb_model_describe()` notation, priors, prose, and truncation lists to the new names; the cover prior line reads `cover_slope ~ LogNormal(...)`
- [x] 3.4 Update roxygen that names parameters (fit functions, predict verbs, `kb_model_describe()`, `kb_stancode()` examples)
- [x] 3.5 Update tests that name parameters or draws

## 4. Supporting scripts and data-raw

- [x] 4.1 Update `data-raw/` simulation scripts and `scripts/` demo, benchmark, and simulation scripts that name parameters or Stan data fields
- [x] 4.2 Grep `R/`, `inst/stan/`, `tests/`, `data-raw/`, `scripts/`, `vignettes/`, and `README.Rmd` for `\b[bs][A-Z][a-z]`, `z_b`, `nObs`, `nSite`, `nYear`, and `_mu\b` prior fields; resolve every remaining hit (vignette and README prose may wait for the final docs pass, per CLAUDE.md)

## 5. Conventions and decisions

- [x] 5.1 Rewrite CLAUDE.md "Parameter names" with the parameter rules, and "Input columns" with the data-field rules (remove "Stan data fields ... take no suffix"); update the Bayesian Engine bullets that mention `kb_prior_normal()` / `kb_prior_exponential()` and `z_* * s_*`
- [x] 5.2 Add `decisions/parameter-naming.md`: the rules, the reasons, and the previous-to-new parameter mapping for reviewers of the analysis reports
- [x] 5.3 Update other `decisions/` records that name parameters

## 6. Docs

- [x] 6.1 Add `kb_prior_lognormal` to the "Priors" section of `_pkgdown.yml`
- [x] 6.2 `devtools::document()`

## 7. Refit, test, archive

- [x] 7.1 Run `Rscript scripts/build.R --fits` (confirm with the user first: MCMC) to refit every pre-fit object and fixture
- [x] 7.2 Run the tests; report every snapshot `.new` file for review (do not accept); expected diffs are term names in summaries, print, describe, and priors
- [x] 7.3 Check the delta specs and roxygen against the code; archive the change (`openspec archive rename-parameters --yes`)
- [ ] 7.4 Start `add-prior-sensitivity` afresh on a branch from this one, reusing from WIP commit b70a8fe the priorsense method, log prior, `kb_sensitivity()` (without the `prior` column), the sensitivity-fit validator pair, their tests, and the change artifacts (without the pairing layer); then delete the old branch and worktree
