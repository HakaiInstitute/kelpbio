## 1. Canopy data check

- [x] 1.1 Export `kb_check_data_canopy(data, x_name)` wrapping the canopy map check with the unit and group-name warnings
- [x] 1.2 Tests: valid maps pass silently; a canopy above its classified area and a missing column error naming the column; a unit warning

## 2. Per-term convergence in summary()

- [x] 2.1 Add name-only `rhat` and `ess` to `summary.kb_fit()`, a `converged` column, the header verdict at the same thresholds, and a footer line
- [x] 2.2 Tests: the column agrees with the thresholds, an NA Rhat is skipped, a non-converged term makes the verdict `FALSE`, the arguments are validated; update the summary snapshot

## 3. Trace plot

- [x] 3.1 Add `kb_plot_trace(fit, ...)` returning `bayesplot::mcmc_trace()` of the `tidy()` terms
- [x] 3.2 Tests: a `ggplot` with one panel per term for every model, a non-fit errors, dots must be empty

## 4. Documentation

- [x] 4.1 roxygen, `_pkgdown.yml`, `devtools::document()`
- [x] 4.2 Check the specs and reader docs against the code; archive the change
