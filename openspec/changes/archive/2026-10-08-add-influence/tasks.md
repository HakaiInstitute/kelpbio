## 1. Implementation

- [x] 1.1 `kb_influence()` in `R/kb_influence.R`: validate `threshold` and `...`, guard fits without a likelihood, join the pointwise `elpd_loo` and `pareto_k` to the data and flag `pareto_k > threshold`
- [x] 1.2 Tests in `tests/testthat/test-kb_influence.R`: every model type, values match `loo::loo()`, threshold sets the flag only, no Pareto k warning and errors (snapshots for messages only)

## 2. Docs

- [x] 2.1 Roxygen for `kb_influence()`; add it to `_pkgdown.yml` beside `kb_sensitivity()`
- [x] 2.2 Add the README and vignette mentions to the deferred docs-pass checklist

## 3. Close

- [x] 3.1 Document, run the affected tests, check the spec against the code, and archive the change
