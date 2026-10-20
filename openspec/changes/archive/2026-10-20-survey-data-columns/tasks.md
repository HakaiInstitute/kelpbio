## 1. Year instead of date

- [x] 1.1 Weight and size sample checks require `site` and `year` (`.chk_group_columns()`), not `date`; replace `.chk_dated_site()` and drop `.chk_date()`, `.chk_date_year()`, and their `.vld_` partners from `R/chk.R` and `R/vld.R`.
- [x] 1.2 Fit assembly reads `year` directly: remove `date_year()` (and `test-date_year.R`); `with_year()` now only converts a numeric year and makes `year` a factor placed after `site`.
- [x] 1.3 Convert a numeric `year` (whole numbers only) and a numeric `survey_id` to character at entry (`ids_as_character()`): in the weight, size, and cover calibration fits, `kb_predict_biomass_survey()`, and `kb_predict_biomass_canopy()` before `pool_by`; other `new_data` already matches years as character. `.chk_group_columns()` accepts whole-number `year` and numeric `survey_id`.
- [x] 1.4 Tests: weight and size data with `year` pass; data with `date` and no `year` error naming `year`; a numeric `year` gives character levels and matches the fitted year in `new_data`; `2021.5` errors naming `year`; a numeric `survey_id` joins and comes back as character.

## 2. Survey key

- [x] 2.1 The survey check requires `survey_id`, `site`, `year`, and `survey_area_m2`, not `plot_id` or `date`; `survey_id` is character, factor, or numeric with no missing values and unique (`.chk_unique_surveys()` and `.vld_unique_surveys()` on `survey_id`, listing repeated values).
- [x] 2.2 Replace `survey_key()` (and `test-survey_key.R`) with the `survey_id` join in `.chk_plants_join()`/`.vld_plants_join()` (renamed for the size census) and in `R/kb_predict_biomass_survey.R`; the no-plants message lists `survey_id` values.
- [x] 2.3 `kb_predict_biomass_survey()` takes `year` from `survey` instead of `date_year()`, and keeps `survey_id` in its output.
- [x] 2.4 Tests in `test-kb_check_data_survey.R`, `test-vld.R`, and `test-kb_predict_biomass_survey.R`: a repeated `survey_id` errors; two surveys in one site-year on one day pass and give two rows; an unmatched census `survey_id` errors.

## 3. Size tables by role

- [x] 3.1 Rename `kb_check_data_size_nereo()` to `kb_check_data_size_sample_nereo()` (file, tests, snapshots); drop the optional `plot_id`.
- [x] 3.2 Rename `kb_check_data_plants_nereo()`/`_macro()` to `kb_check_data_size_census_nereo()`/`_macro()` (files, tests, snapshots); the census needs `survey_id` and the size column, optional `partial`, and no `site`, `plot_id`, or `date`.
- [x] 3.3 `kb_check_data_survey(data, size_census = NULL)`: rename the argument and its messages; `kb_fit_size_nereo()` calls the size sample check.
- [x] 3.4 Update `_pkgdown.yml`, `NAMESPACE` (via `devtools::document()`), and every `@seealso`/`[kb_check_data_*()]` link.

## 4. Simulated data (no MCMC)

- [x] 4.1 `data-raw/data_sim_nereo.R` and `data-raw/data_sim_macro.R` write `year` instead of `date`, a `survey_id` per survey, no `plot_id`, at least one site-year with more than one survey; write `data_size_sample_sim_nereo` and `data_size_census_sim_macro` in place of `data_size_sim_nereo` and `data_plants_sim_macro` (delete the old `.rda` files).
- [x] 4.2 Update `R/data.R` (formats and titles for the renamed datasets, no `date` or `plot_id`) and `test-data.R`.

## 5. Docs

- [x] 5.1 Roxygen for the data checks, `kb_fit_weight_*()`, `kb_fit_size_nereo()`, `kb_predict_biomass_survey()`, and `R/params.R`: `year`, `survey_id`, the two size tables by role; no `date` or `plot_id`; `region` as the extra-column example.
- [x] 5.2 README, `vignettes/kelpbio.Rmd`, `decisions/architecture.md`, `decisions/intermediate-predictions.md`, `decisions/vignettes.md`, and `scripts/demo-api-*.R`.
- [x] 5.3 `devtools::document()`; check the delta specs and reader docs against the code.

## 6. Pre-fits and fixtures (MCMC, confirm with the user before running)

- [x] 6.1 `Rscript scripts/build.R --fits` rebuilds the weight, size, and cover calibration pre-fits and fixtures (`tests/testthat/fixtures/make-fixtures.R`), whose stored data change; wet/dry and carbon are unaffected.
- [x] 6.2 Run the test suite; changed snapshots (message wording only) accepted for review in the diff.

## 7. Archive

- [x] 7.1 Once this branch has the archived `bound-tide-correction` and CI passes, `openspec archive survey-data-columns --yes`. The deltas drop the date and plot-key scenarios on purpose, which the archive refuses for a MODIFIED requirement: first copy the modified "Input data" and "Survey biomass" blocks into `openspec/specs/`, then archive.
