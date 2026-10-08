## 1. Implementation

- [x] 1.0 Move loo to Imports and re-export `loo()` and `loo_compare()` from `R/generics.R`
- [x] 1.1 `.vld_loo_fit()` / `.chk_loo_fit()` guarding prior-only and zero-observation fits
- [x] 1.2 `loo.kb_fit()` in `R/loo.R`, registered on `loo::loo()`: relative efficiencies from the chain-major draws, `...` passed to loo
- [x] 1.3 Tests in `tests/testthat/test-loo.R`: every model type, pointwise rows, `r_eff` agreement, `loo_compare()`, prior-only and zero-observation errors (snapshots for messages only)

## 2. Docs

- [x] 2.1 Roxygen for `loo.kb_fit()`; point `log_lik()` at it; add it to `_pkgdown.yml`
- [x] 2.2 Add the README and vignette mentions to the deferred docs-pass checklist
- [x] 2.3 File an issue for per-observation influence (`augment()` columns or a `kb_` function): poissonconsulting/kelpbio#12

## 3. Close

- [x] 3.1 Document, run the affected tests, check the spec against the code, and archive the change
