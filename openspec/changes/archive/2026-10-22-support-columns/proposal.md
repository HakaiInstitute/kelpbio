## Why

The support columns (`weight_support`, `size_support`, `cover_support`) say whether a prediction's site-year has data in the fit or is borrowed from other site-years. They are dropped whenever survey or canopy biomass is pooled, even when pooling by site and year leaves each row one site-year, and the model prediction verbs never add them. So a site-year without model data cannot be flagged in pooled site-year totals or in plant weights predicted at measured plants (`kb_predict_weight()` at size sample rows).

## What Changes

- `kb_predict_biomass_survey()` and `kb_predict_biomass_canopy()` keep their support columns when `pool_by` includes both `site` and `year`. Pools that span sites or years still drop them.
- `kb_predict_weight()`, `kb_predict_size()`, and `kb_predict_cover_calibration()` (and `predict()` on those fits) add `weight_support`, `size_support`, or `cover_support` when the rows have both `site` and `year`, including the observed data when `new_data = NULL`.

## Non-goals

- No support column for rows with only a site or only a year, which name no site-year.
- No change to the support values or to `kb_predict_mean_weight()`, which already adds both columns and takes no `pool_by`.
- No refit: fits and fixtures are unchanged.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `predictions`: the prediction verb output (support column for rows with a site and a year) and pooling (support columns kept for site-year pools).

## Impact

- `R/data_support.R`, `R/predict_rows.R`, `R/kb_predict_biomass_survey.R`, `R/kb_predict_biomass_canopy.R`, and the `@returns` of the three model verbs.
- Tests in `test-data_support.R`, `test-predict_rows.R`, `test-kb_predict_biomass_survey.R`, and `test-kb_predict_biomass_canopy.R`; output-table snapshots of the model verbs at observed data gain the support column.
