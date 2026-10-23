## Why

"Survey" names the in situ count of plants over a searched area, but drone flights are also surveys, and the remote-sensing literature on kelp uses "survey" for both. Readers took `kb_predict_biomass_survey()` and the survey data to mean drone surveys. "In situ" is the term the drone-era kelp literature uses for dive and boat data, and it pairs with the drone side's "canopy".

## What Changes

- `kb_predict_biomass_survey()` becomes `kb_predict_biomass_in_situ()`.
- `kb_check_data_survey()` becomes `kb_check_data_in_situ()`.
- `data_survey_sim_nereo` and `data_survey_sim_macro` become `data_in_situ_sim_nereo` and `data_in_situ_sim_macro`.
- The predictions requirement "Survey biomass" is renamed "In situ survey biomass".
- Reader docs say "in situ survey" on first mention in a topic.

## Non-goals

- The `survey` argument and the `survey_id` and `survey_area_m2` columns keep their names: inside an in situ function or table, "survey" is unambiguous.
- No change in behaviour, outputs, or messages, and no refit.
- kelpbiodata and kelpbioshiny are updated in their own repositories.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: input data and the bundled example objects name the in situ functions and datasets.
- `predictions`: the requirements naming survey biomass, and the rename of "Survey biomass".
- `summaries`: errors for unsupported objects name the renamed function.

## Impact

- Renamed files: `R/kb_predict_biomass_in_situ.R`, `R/kb_check_data_in_situ.R`, their tests and snapshots, and `data/data_in_situ_sim_*.rda` (the same data under the new names).
- References in roxygen, `_pkgdown.yml`, `data-raw/`, `decisions/`, the demo scripts, the vignettes and the workflow diagram; the vocabulary rule in `.claude/STYLE.md`.
- kelpbiodata (`data-raw/fit_cover_calibration_hakai_*.R`, `R/fits.R`) and kelpbioshiny call the old names.
