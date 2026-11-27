## 1. Support columns

- [x] 1.1 Add `with_support()` to `R/data_support.R`: the fit's support column when the rows have `site` and `year`.
- [x] 1.2 Survey and canopy biomass add support after pooling, so site-year pools keep it.
- [x] 1.3 The model verbs add support through `predict_rows()`; document it in their `@returns`.
- [x] 1.4 Tests for the helper, the model verbs, and site-year and wider pools.
- [x] 1.5 `Rscript scripts/build.R`; review snapshot diffs.
- [x] 1.6 `openspec archive support-columns --yes`.
