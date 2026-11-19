# Check a Nereocystis size census

Check that `data` has the columns and values of a census of every
*Nereocystis luetkeana* plant counted by in situ surveys, for
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.md).

## Usage

``` r
kb_check_data_size_census_nereo(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
)
```

## Arguments

- data:

  A data frame of counted plants, one row per plant.

- x_name:

  A string naming the data for error messages.

## Value

`data`, invisibly.

## Details

Each row is one counted plant; its site and year are those of its
survey. Required columns:

- `survey_id`, the survey the plant was counted in (a survey_id of the
  in situ data).

- `diameter_mm`, the plant diameter, measured as in the weight data (mm,
  \> 0).

Optional columns:

- `partial`, whether the plant counts as half, such as a plant on the
  edge of a transect (TRUE or FALSE).

Other columns are ignored.

## See also

[`kb_check_data_size_sample_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_size_sample_nereo.md)
for a sample measured for the size model.

Other data checks:
[`kb_check_data_carbon_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_carbon_macro.md),
[`kb_check_data_carbon_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_carbon_nereo.md),
[`kb_check_data_cover_calibration_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_cover_calibration_macro.md),
[`kb_check_data_cover_calibration_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_cover_calibration_nereo.md),
[`kb_check_data_nitrogen_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_nitrogen_macro.md),
[`kb_check_data_nitrogen_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_nitrogen_nereo.md),
[`kb_check_data_size_census_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_size_census_macro.md),
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
size_census <- data.frame(
  survey_id = "s1", diameter_mm = c(32, 41), partial = c(FALSE, TRUE)
)
kb_check_data_size_census_nereo(size_census)
```
