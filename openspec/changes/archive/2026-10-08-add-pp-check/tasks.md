## 1. Implementation

- [x] 1.1 Move bayesplot to Imports and re-export `pp_check()` from `R/generics.R`
- [x] 1.2 `pp_check.kb_fit()` in `R/pp_check.R`: validate `type`, `ndraws`, and `...`; sample draws; build response or residual replicates from the observation family; return `bayesplot::ppc_dens_overlay()` with the x-axis title
- [x] 1.3 Axis titles for the count responses (stipes and plants per transect)
- [x] 1.4 Tests in `tests/testthat/test-pp_check.R`: every model type returns a plot with `ndraws` replicates, response and residual titles, residuals match `residuals()`, seed reproducibility, `ndraws` and zero-observation errors (snapshots for messages only)

## 2. Docs

- [x] 2.1 Roxygen for `pp_check.kb_fit()`; point `posterior_predict()` at it; add it to `_pkgdown.yml`
- [x] 2.2 Add the README and vignette mentions to the deferred docs-pass checklist

## 3. Close

- [x] 3.1 Document, run the affected tests, check the spec against the code, and archive the change
