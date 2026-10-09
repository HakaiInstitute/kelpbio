## 1. Implementation

- [x] 1.1 Year validators accepting whole-number numeric years, used by the fitting data checks, `biomass`, site surveys, `new_data`, and `kb_new_data()`
- [x] 1.2 Convert a numeric year to a factor at fit entry, after the cover biomass join, in prediction `new_data`, and in `kb_predict_site_biomass()` before `sum_by`
- [x] 1.3 Roxygen: data check columns and examples, `new_data` of the prediction verbs and `kb_predict_site_biomass()`
- [x] 1.4 Tests: validators, error snapshots, fit functions (stubbed sampler), prediction paths

## 2. Close

- [x] 2.1 Document; tests green; archive the change
