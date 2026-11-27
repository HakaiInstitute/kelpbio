# Check in situ survey data

Check that `data` has the columns and values needed to predict the
biomass of in situ surveys with
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.md).

## Usage

``` r
kb_check_data_survey_in_situ(
  data,
  size_census = NULL,
  x_name = chk::deparse_backtick_chk(substitute(data))
)
```

## Arguments

- data:

  A data frame of in situ surveys, one row per survey.

- size_census:

  A data frame of every plant the surveys counted, one row per plant
  (see
  [`kb_check_data_size_census_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_size_census_nereo.md)
  and
  [`kb_check_data_size_census_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_size_census_macro.md)
  for the columns), or `NULL` to check `data` alone with its `plants`
  column.

- x_name:

  A string naming the data for error messages.

## Value

`data`, invisibly. Warns when a survey's `survey_area_m2` exceeds its
`plot_area_m2`.

## Details

Each row is one survey, with a count of the plants in the surveyed area.
A survey is the area over which canopy percent cover is calculated, and
can combine several transects. Required columns:

- `survey_id`, the survey's identifier (text or number, unique to each
  survey).

- `site`, the site surveyed (any text).

- `year`, the year of the survey (whole number or text).

- `survey_area_m2`, the area surveyed for plants (m², \> 0).

Optional columns:

- `plants`, the number of plants counted, given only when sizes come
  from a size sample (whole number \>= 0).

- `plot_area_m2`, the area of the plot polygon bounding the survey area
  that the canopy cover is measured over (m², \> 0, or missing).

- `canopy_area_m2`, the canopy area delineated within the plot polygon
  (m², \>= 0 and \<= plot_area_m2, or missing).

- `canopy_tide_height_m`, the tide height when the canopy was imaged,
  relative to chart datum, ideally close to 0 m and at most 2 m, or 0
  for canopy already corrected for tide (m, any number, or missing).

Other columns are ignored.

`plants` is required when only a sample of plants is measured (a size
sample), and must be absent when every plant is measured (a size
census), since the count then comes from the census rows. The plot cover
columns (`plot_area_m2`, `canopy_area_m2`, and `canopy_tide_height_m`)
are either all present or all missing on each row. Other grouping
columns, such as `region`, can be named in `pool_by`.

## See also

Other data checks:
[`kb_check_data_carbon_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_carbon_macro.md),
[`kb_check_data_carbon_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_carbon_nereo.md),
[`kb_check_data_cover_calibration_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_cover_calibration_macro.md),
[`kb_check_data_cover_calibration_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_cover_calibration_nereo.md),
[`kb_check_data_nitrogen_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_nitrogen_macro.md),
[`kb_check_data_nitrogen_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_nitrogen_nereo.md),
[`kb_check_data_size_census_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_size_census_macro.md),
[`kb_check_data_size_census_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_size_census_nereo.md),
[`kb_check_data_size_sample_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_size_sample_nereo.md),
[`kb_check_data_survey_canopy()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_survey_canopy.md),
[`kb_check_data_weight_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_macro.md),
[`kb_check_data_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_nereo.md),
[`kb_check_data_wetdry_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_wetdry_macro.md),
[`kb_check_data_wetdry_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_wetdry_nereo.md),
[`kb_data_columns()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_data_columns.md),
[`kb_datasets()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_datasets.md)

## Examples

``` r
kb_check_data_survey_in_situ(data_survey_in_situ_sim_nereo)
kb_check_data_survey_in_situ(data_survey_in_situ_sim_macro, data_size_census_sim_macro)
```
