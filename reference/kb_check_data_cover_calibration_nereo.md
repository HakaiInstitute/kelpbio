# Check Nereocystis cover calibration data

Check that `data` has the columns and values needed to fit the
*Nereocystis luetkeana* cover calibration model.

## Usage

``` r
kb_check_data_cover_calibration_nereo(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
)
```

## Arguments

- data:

  A data frame of in situ survey biomass, one row per survey.

- x_name:

  A string naming the data for error messages.

## Value

`data`, invisibly.

## Details

`data` is the output of
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.md),
one row per in situ survey. Required columns:

- `biomass_kg_m2`, the draws of the survey's wet biomass per m² (kg/m²,
  \>= 0).

- `site`, the site surveyed (any text).

- `year`, the year of the survey (whole number or text).

- `plot_area_m2`, the area of the plot polygon bounding the survey area
  that the canopy cover is measured over (m², \> 0, or missing).

- `canopy_area_m2`, the canopy area delineated within the plot polygon
  (m², \>= 0 and \<= plot_area_m2, or missing).

- `canopy_tide_height_m`, the tide height when the canopy was imaged,
  relative to chart datum, ideally close to 0 m and at most 2 m, or 0
  for canopy already corrected for tide (m, any number, or missing).

Other columns are ignored.

The plot cover columns are given or missing together; a row without them
is not fitted.

## See also

Other data checks:
[`kb_check_data_carbon_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_carbon_macro.md),
[`kb_check_data_carbon_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_carbon_nereo.md),
[`kb_check_data_cover_calibration_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_cover_calibration_macro.md),
[`kb_check_data_nitrogen_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_nitrogen_macro.md),
[`kb_check_data_nitrogen_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_nitrogen_nereo.md),
[`kb_check_data_size_census_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_size_census_macro.md),
[`kb_check_data_size_census_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_size_census_nereo.md),
[`kb_check_data_size_sample_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_size_sample_nereo.md),
[`kb_check_data_survey_canopy()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_survey_canopy.md),
[`kb_check_data_survey_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_survey_in_situ.md),
[`kb_check_data_weight_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_macro.md),
[`kb_check_data_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_nereo.md),
[`kb_check_data_wetdry_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_wetdry_macro.md),
[`kb_check_data_wetdry_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_wetdry_nereo.md),
[`kb_data_columns()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_data_columns.md),
[`kb_datasets()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_datasets.md)

## Examples

``` r
biomass <- kb_predict_biomass_in_situ(
  fit_weight_sim_nereo,
  fit_size_sim_nereo,
  data_survey_in_situ_sim_nereo,
  progress = "none"
)
kb_check_data_cover_calibration_nereo(biomass)
```
