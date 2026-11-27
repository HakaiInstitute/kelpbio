# Check canopy map data

Check that `data` has the columns and values needed to predict canopy
biomass with
[`kb_predict_biomass_canopy()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_canopy.md),
which applies the same check to its `new_data`.

## Usage

``` r
kb_check_data_survey_canopy(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
)
```

## Arguments

- data:

  A data frame of canopy maps, one row per map.

- x_name:

  A string naming the data for error messages.

## Value

`data`, invisibly.

## Details

Each row is one canopy map of the whole site; a site-year may have
several. A warning is given if the maps of a site-year have
`classified_area_m2` values that differ by more than half, which
suggests maps of parts of the site. Required columns:

- `site`, the site mapped (any text).

- `year`, the year of the map (whole number or text).

- `canopy_area_m2`, the canopy area mapped (m², \>= 0 and \<=
  classified_area_m2).

- `canopy_tide_height_m`, the tide height when the canopy was imaged,
  relative to chart datum, ideally close to 0 m and at most 2 m, or 0
  for canopy already corrected for tide (m, any number).

- `classified_area_m2`, the water area the canopy classification
  covered, including water where no canopy was found (m², \> 0).

Other columns are ignored.

Other grouping columns, such as `region`, can be named in `pool_by`.

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
[`kb_check_data_survey_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_survey_in_situ.md),
[`kb_check_data_weight_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_macro.md),
[`kb_check_data_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_nereo.md),
[`kb_check_data_wetdry_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_wetdry_macro.md),
[`kb_check_data_wetdry_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_wetdry_nereo.md),
[`kb_data_columns()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_data_columns.md),
[`kb_datasets()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_datasets.md)

## Examples

``` r
kb_check_data_survey_canopy(data_survey_canopy_sim_nereo)
```
