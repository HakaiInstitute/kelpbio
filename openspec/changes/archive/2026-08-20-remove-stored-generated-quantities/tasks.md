Editing `inst/stan/*.stan` requires `rstantools::rstan_config()` and then a
*clean* install — `pkgbuild::clean_dll()` first, because the makefile depends on
the `.cc` rather than the regenerated `.h` and will otherwise reuse a stale `.o`.
See the design; this bit in practice.

## 0. Preserve the pre-change objects

- [x] 0.1 Copy both demo fits and both fixtures (each still carrying `gq`) outside the repo, before anything overwrites them

## 1. Stan

- [x] 1.1 `inst/stan/weight_nereo.stan`: delete `generated quantities`; move `log_eWeight` from `transformed parameters` into a local inside `if (prior_only == 0)`; update the header comment
- [x] 1.2 `inst/stan/weight_macro.stan`: same, keeping the existing per-observation likelihood loop unvectorised
- [x] 1.3 `rstantools::rstan_config()`, `pkgbuild::clean_dll()`, `devtools::install()`
- [x] 1.4 **Gate**: sample both models and assert `model_pars` contains none of `log_lik`, `yrep`, `log_eWeight`

## 2. Engine and constructors

- [x] 2.1 `R/fit_stan.R`: drop the `gq_vars` formal, the `gq` build block, and `gq` from the return; note that `subset_draws()` still drops `lp__` and the `z_*` parameters
- [x] 2.2 Both `R/kb_fit_weight_*.R`: drop the `gq_vars =` argument, drop `gq = core$gq` from `new_kb_fit_weight()`, and fix the `@details` sentence promising the stored generated quantities

## 3. Recomputation

- [x] 3.1 `R/log_lik.R`: `log_lik.kb_fit_weight` plus the `.weight_log_lik()` generic and both species methods, preallocated `D x N`
- [x] 3.2 `R/posterior_predict.R`: delete the stored-`yrep` branch; guard on `is.null(new_data) && nrow(object$data) == 0L`; document the RNG dependence and `set.seed()`
- [x] 3.3 `_pkgdown.yml`: `log_lik.kb_fit` to `log_lik.kb_fit_weight` (pkgdown hard-errors on a missing topic, and only the full check runs pkgdown)
- [x] 3.4 `devtools::document()`; confirm the old Rd is removed and NAMESPACE registers the subclass method
- [x] 3.5 Validate against the four preserved objects: `log_lik` exact, `loo` elpd agreement, determinism, `yrep` distributional on robust statistics. Numbers in the design

## 4. Rebuild artifacts

- [x] 4.1 Raise `n_per` from 6 to 20 in both `data-raw/data_weight_sim_*.R`, and rewrite the size rationale in those comments and in both `data-raw/fit_weight_sim_*.R`
- [x] 4.2 Regenerate in dependency order: simulated data, then fixtures, then demo fits
- [x] 4.3 Confirm sizes and that all four objects still converge

## 5. Tests

- [x] 5.1 `test-log_lik.R`: keep the orientation assertions; add a macro counterpart, determinism, and closed-form checks against `stats::dt` / `stats::dgamma` independent of `extras`; zero-obs via `data[0, ]`
- [x] 5.2 `test-posterior_predict.R`: drop the exact-equality assertion against stored `yrep` for a robust distributional check; pin the seed contract; add a zero-obs fit *with* `new_data` to guard the `is.null(new_data)` conjunct
- [x] 5.3 Both `test-kb_fit_weight_*.R`: `expect_named` without `gq`; assert `gq` absent and `log_eWeight` not among the draws
- [x] 5.4 `test-stanmodels.R`: drop `log_lik`/`yrep` from the `model_pars` vectors and assert none of the three is present
- [ ] 5.5 Re-record the `print`, `kb_model_describe` and prediction-ribbon snapshots (observation count and geometric-mean references move with the data) — **left for the user to review locally**

## 6. Reader docs

- [x] 6.1 `decisions/architecture.md`: the fit-object diagram node, the mean/generated-quantities bullet, the `fit_stan()` description, the deleted `gq` table row, the rstantools-generics paragraph, the Stan key symbols, `log_lik.kb_fit()` to `log_lik.kb_fit_weight()`, and the deleted `gq` glossary entry
- [x] 6.2 `vignettes/kelpbio.Rmd`: the posterior-predictive section no longer says "the stored `yrep`"; the check chunk sets a seed
- [x] 6.3 `CLAUDE.md`: move `log_lik` to the subclass line of the S3 sketch
- [x] 6.4 Re-knit `README.md` (n = 780 now)
- [ ] 6.5 Regenerate `decisions/architecture.html`

## 7. Verification and completion

- [x] 7.1 `devtools::test()` green apart from the snapshots awaiting review
- [ ] 7.2 `KELPBIO_FULL_CHECK=true Rscript scripts/build.R` — `R CMD check` plus pkgdown, which is what catches the `_pkgdown.yml` rename
- [x] 7.3 Drift check: specs vs code, reader docs vs code
- [ ] 7.4 Archive the change, syncing the three deltas
- [ ] 7.5 Open the PR stacked on `add-divergence-diagnostics` and confirm CI is green
