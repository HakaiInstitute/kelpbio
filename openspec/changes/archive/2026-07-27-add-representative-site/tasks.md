## 1. Engine and validator

- [x] 1.1 `R/weight_linpred.R`: `resolve_re1(param, idx, new_levels, sd_rvar, rep_idx = NULL)` - for unknown rows, when `rep_idx` is non-NULL assign `rowMeans(posterior::draws_of(param)[, rep_idx, drop = FALSE])` (recycled across unknown columns) instead of the `new_levels` draw/zero.
- [x] 1.2 `R/weight_linpred.R`: `.weight_linpred(fit, grid, new_levels, representative_site = NULL)` - compute `rep_idx <- match(representative_site, fit$meta$site_levels)` when non-NULL and pass to the `bSite` and `bSiteDiameter` `resolve_re1()` calls only; leave `resolve_re2()` unchanged. `.weight_linpred_obs()` keeps the default.
- [x] 1.3 `R/weight_linpred.R`: `weight_data_linpred(fit, new_data, new_levels, representative_site = NULL)` threads the argument through.
- [x] 1.4 `R/chk.R`: add `.chk_representative_site(fit, representative_site)` - `NULL` ok; else `chk::chk_character`, non-empty, and a `cli::cli_abort` naming any value not in `fit$meta$site_levels` (list available sites).

## 2. Surface and docs

- [x] 2.1 `R/kb_predict_weight.R`: add `representative_site = NULL`; call `.chk_representative_site()`; pass to `weight_data_linpred()`. Update `@details` (three behaviours + borrow-strength caveat) and add a runnable example using a fit site as reference.
- [x] 2.2 `R/predict.R`: add `representative_site = NULL` and forward to `kb_predict_weight()`.
- [x] 2.3 `R/posterior_epred.R`, `R/posterior_linpred.R`, `R/posterior_predict.R`: add `representative_site = NULL`, validate, thread to `weight_data_linpred()`.
- [x] 2.4 `R/params.R`: add a shared `@param representative_site` (three behaviours; sets only the site main effects).

## 3. Tests, docs, verify

- [x] 3.1 `tests/testthat/test-kb_predict_weight.R`: unknown reference site errors; result shape; invariant - with `new_levels = "average"` and no `year` column, a new site with `representative_site = "<known>"` gives the same `estimate` as predicting that known site; multiple-site case runs and differs from the single-site case.
- [x] 3.2 `tests/testthat/test-posterior_epred.R`: a focused `representative_site` case (new site borrows the reference site's main effects).
- [x] 3.3 `devtools::document()`; `devtools::test()` green; `devtools::run_examples()` clean.
- [x] 3.4 `devtools::check()` clean (modulo the pre-existing `newdata` NOTE).
- [x] 3.5 `openspec validate add-representative-site --strict` passes.
