## Why

The weight, size, survey, and plant tables take a `date` that the package uses only for its year and, on surveys, as part of the key `site` + `plot_id` + `date`. Every other table and output already works in `year` (canopy `new_data`, `kb_new_data()` grids, the cover calibration input, every summary), so users convert dates for no gain, the checks carry date/year agreement rules, and two surveys of one plot on one day cannot be entered. The two size tables are also named by what they hold (`size`, `plants`) rather than the role they play, which hides that one is a sample for the size fit and the other a census joined to surveys.

## What Changes

- **BREAKING** `year` replaces `date` in the weight, size, survey, and counted-plant tables. `date` is no longer read, and no date/year agreement is checked; a `date` column is ignored like any other extra column. `year` may be character, factor, or whole numbers; numbers are converted to character on entry, here and in `new_data`.
- **BREAKING** Surveys are keyed by a required `survey_id` (character, factor, or numeric, converted to character), unique per row, replacing the `site` + `plot_id` + `date` key. Two surveys of the same site in the same year, including on the same day, are separate rows with their own `survey_id`. `plot_id` is no longer required, and the docs no longer mention it; `region` stays the documented example of an extra column for `pool_by`.
- **BREAKING** The two size tables are named by role:
  - `size_sample`: plants measured to fit the size model, one row per plant with `site`, `year`, and `diameter_mm`. `kb_check_data_size_sample_nereo()` replaces `kb_check_data_size_nereo()`, and `data_size_sample_sim_nereo` replaces `data_size_sim_nereo`.
  - `size_census`: every plant counted by a survey, one row per plant with `survey_id`, the size column, and optional `partial`; the plant's site and year come from its survey. `kb_check_data_size_census_nereo()` and `kb_check_data_size_census_macro()` replace `kb_check_data_plants_nereo()` and `kb_check_data_plants_macro()`, and `data_size_census_sim_macro` replaces `data_plants_sim_macro`.
- **BREAKING** `kb_check_data_survey(data, plants = NULL)` becomes `kb_check_data_survey(data, size_census = NULL)`.
- `kb_fit_size_nereo()`, `fit_size_sim_nereo`, the survey `plants` count column, and `kb_predict_biomass_survey(weight, size, survey)` keep their names; `size` still takes a size fit or a `size_census` table. Survey biomass rows carry the survey's own `year` instead of one derived from `date`.
- The bundled simulated datasets, pre-fits, and test fixtures that hold weight, size, or survey data are rebuilt with the new columns.

## Non-goals

- A single size table whose mode is set by its columns, or a datasheet-shaped survey call with an optional per-survey count (see `design.md`).
- A ratio estimator from a survey's own measured plants in place of the size model for subsampled surveys: a methods question for the client.
- Month or within-year resolution: the fits stay at site-year resolution (see `decisions/prediction-engine.md`).
- The kelpbioshiny follow-up (sheets named `size_sample` and `size_census`, and an explicit choice of how sizes were recorded).
- The wet/dry and carbon tables, which have no date or site.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: the input data requirement (year instead of date, the survey key, the `size_sample` and `size_census` tables and their checks) and the bundled example objects requirement (renamed datasets, surveys rather than plots).
- `predictions`: group resolution (a numeric `year` in `new_data`) and the survey biomass requirement (`size_census`, the year taken from the survey, surveys keyed by `survey_id`).

## Impact

- Data checks: `R/kb_check_data_weight_*.R`, `R/kb_check_data_size_nereo.R` (renamed), `R/kb_check_data_plants_*.R` (renamed), `R/kb_check_data_survey.R`, `R/chk.R`, `R/vld.R`; removal of `R/date_year.R`, `R/with_year.R`, and `R/survey_key.R` or their replacement by a `survey_id` join.
- Fit assembly (`R/assemble_weight_*_data.R`, `R/assemble_size_nereo_data.R`, `R/new_kb_fit.R`, `R/fit_stan.R`) and `R/kb_predict_biomass_survey.R`.
- `R/data.R`, `R/fits.R`, `R/params.R`, `_pkgdown.yml`; `data-raw/data_sim_*.R` and the `fit_*` scripts; `data/` (renamed and rebuilt datasets, rebuilt weight, size, and cover calibration pre-fits); `tests/testthat/fixtures/`.
- README, `vignettes/kelpbio.Rmd`, `decisions/architecture.md`, the demo scripts in `scripts/`.
- Tests and snapshots for the renamed checks, the survey check, and survey biomass.
- No Stan source change.
