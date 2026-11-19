# Check Macrocystis nitrogen data

Check that `data` contains the columns required to fit the *Macrocystis
pyrifera* nitrogen model, with appropriate types and values.

## Usage

``` r
kb_check_data_nitrogen_macro(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
)
```

## Arguments

- data:

  A data frame of nitrogen observations, one row per sample.

- x_name:

  A string naming the data for error messages.

## Value

`data`, invisibly.

## Details

Each row is one dried tissue sample. Required columns:

- `sample_mass_mg`, the mass of the dried tissue sample analysed (mg, \>
  0).

- `nitrogen_mass_ug`, the mass of nitrogen measured in the sample (µg,
  \> 0 and less than the sample mass).

Other columns are ignored.

A warning gives the number of samples whose nitrogen fraction (nitrogen
mass over sample mass) falls outside 0.002 to 0.05, the plausible range
for kelp tissue; they are kept.

## See also

Other data checks:
[`kb_check_data_carbon_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_carbon_macro.md),
[`kb_check_data_carbon_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_carbon_nereo.md),
[`kb_check_data_cover_calibration_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_cover_calibration_macro.md),
[`kb_check_data_cover_calibration_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_cover_calibration_nereo.md),
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
data <- data.frame(sample_mass_mg = c(2.4, 2.7), nitrogen_mass_ug = c(45, 52))
kb_check_data_nitrogen_macro(data)
```
