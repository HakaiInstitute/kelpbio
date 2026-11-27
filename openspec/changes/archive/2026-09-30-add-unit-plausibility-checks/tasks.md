## 1. Helpers

- [x] 1.1 `R/column_units.R`: expected unit per column (`diameter`, `weight`, `density`)
- [x] 1.2 `R/warn_implausible_units.R`: median thresholds, one `cli` warning per implausible column
- [x] 1.3 `R/warn_outside_range.R`: supplied values against half the fitted minimum and twice the fitted maximum

## 2. Wiring

- [x] 2.1 Call the unit check from `kb_check_data_weight_nereo()` and `kb_check_data_weight_macro()`
- [x] 2.2 Call the range check where `new_data` enters (`data_linpred()`) and where a predictor sequence is supplied (`predictor_grid()`)

## 3. Tests and docs

- [x] 3.1 Mirroring tests for the helpers; data-check and prediction tests for the warnings (snapshot the messages)
- [x] 3.2 Roxygen for the data checks and prediction verbs; run the suite and leave `.new` snapshots
- [x] 3.3 Check specs and docs against the code, then archive the change
