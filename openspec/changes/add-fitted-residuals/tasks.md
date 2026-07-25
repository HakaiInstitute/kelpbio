## 1. Dependency and fit metadata

- [x] 1.1 Add `extras` to `DESCRIPTION` Imports.
- [x] 1.2 In `new_kb_fit_weight()` (`R/kb_fit_weight.R`), record the Student-t degrees of freedom in `meta$nu` (the `nu = 4` constant from `inst/stan/weight.stan`).
- [x] 1.3 Rebuild the shipped `fit_weight` (`data-raw/fit_weight.R`) and the test fixture (`tests/testthat/fixtures/make-fixtures.R`) so both carry `meta$nu` (no Stan recompile).

## 2. fitted() and residuals()

- [x] 2.1 Add `R/fitted.R`: `fitted.kb_fit_weight(object, ...)` returns the posterior median of `posterior_epred(object)` (response scale) as a numeric vector; validate with `.chk_kb_fit_weight()`; `@exportS3Method stats::fitted`.
- [x] 2.2 Add `R/residuals.R`: `residuals.kb_fit_weight(object, ...)` returns the deviance residual as a numeric vector, computed per draw via `extras::res_student(log(weight), .weight_linpred(...), sd = sWeight, theta = 1 / meta$nu)` and summarised with the posterior median; `@exportS3Method stats::residuals`.
- [x] 2.3 Simplify `augment.kb_fit_weight()` (`R/augment.R`) to append only `fitted = stats::fitted(x)` and `residual = stats::residuals(x)` (no `lower`/`upper`, no `conf_level`), so the columns are taken straight from the methods and cannot drift; update its `@return`.
- [x] 2.4 Add runnable `@examples` (`fitted(fit_weight)`, `residuals(fit_weight)`) and `@seealso` cross-links between `fitted`, `residuals`, and `augment`.

## 3. Tests and verification

- [x] 3.1 Add `tests/testthat/test-fitted.R` and `tests/testthat/test-residuals.R`: vector type, length `nobs`, finite; `fitted` positive; assert equality with `augment(fit)$fitted` / `$residual`.
- [x] 3.2 Update `tests/testthat/test-augment.R` for the deviance `residual` column (structure/invariants, not MCMC numerics).
- [x] 3.3 `devtools::document()`; `devtools::test()` green; `devtools::run_examples()` clean.
- [x] 3.4 `devtools::check()`: 0 errors / 0 warnings (extras resolves the prior unused-import NOTE only if newdata is also used; otherwise the pre-existing `newdata` NOTE may remain).
- [x] 3.5 `openspec validate add-fitted-residuals --strict` passes.
