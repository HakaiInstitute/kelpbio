# Data dictionary

The columns of each data frame that kelpbio fits or predicts from, with
their types, units, allowed values, and examples.

## Usage

``` r
kb_data_columns(dataset = NULL)
```

## Arguments

- dataset:

  A string of the dataset to describe, one of
  `kb_data_columns()$dataset`, or `NULL` for every dataset.

## Value

A tibble with one row per dataset and column and the character columns
`dataset`, `column`, `type` (`"numeric"`, `"integer"`, `"character"`,
`"logical"`, or `"rvar"`), `units` (`NA` for none), `allowed` (the
values accepted), `description`, and `example` (a typical value), and
the logical column `required`.

## Details

Each dataset is the data frame checked by the data check of the same
name: `"weight_nereo"` by
[`kb_check_data_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_nereo.md),
`"survey_in_situ"` by
[`kb_check_data_survey_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_survey_in_situ.md),
etc. A required column must be present; a required column must have no
missing values unless `allowed` says otherwise. Grouping columns
(`site`, `year`, `survey_id`) may be factors, and a numeric `year` or
`survey_id` is converted to character. Other columns are ignored.

The `survey_in_situ` column `plants` is required when sizes come from a
size sample and must be absent when they come from a size census. The
`survey_in_situ` columns `plot_area_m2`, `canopy_area_m2`, and
`canopy_tide_height_m` are either all present or all missing on each
row.

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
[`kb_check_data_survey_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_survey_in_situ.md),
[`kb_check_data_weight_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_macro.md),
[`kb_check_data_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_nereo.md),
[`kb_check_data_wetdry_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_wetdry_macro.md),
[`kb_check_data_wetdry_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_wetdry_nereo.md),
[`kb_datasets()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_datasets.md)

## Examples

``` r
kb_data_columns("weight_nereo")
#> # A tibble: 4 × 8
#>   dataset      column      required type      units allowed  description example
#>   <chr>        <chr>       <lgl>    <chr>     <chr> <chr>    <chr>       <chr>  
#> 1 weight_nereo diameter_mm TRUE     numeric   mm    > 0      The plant … 26.8   
#> 2 weight_nereo weight_kg   TRUE     numeric   kg    > 0      The plant'… 0.73   
#> 3 weight_nereo site        TRUE     character NA    any text The site t… otter_…
#> 4 weight_nereo year        TRUE     integer   NA    whole n… The year t… 2024   
unique(kb_data_columns()$dataset)
#>  [1] "weight_nereo"            "weight_macro"           
#>  [3] "size_sample_nereo"       "size_census_nereo"      
#>  [5] "size_census_macro"       "survey_in_situ"         
#>  [7] "survey_canopy"           "wetdry_nereo"           
#>  [9] "wetdry_macro"            "carbon_nereo"           
#> [11] "carbon_macro"            "nitrogen_nereo"         
#> [13] "nitrogen_macro"          "cover_calibration_nereo"
#> [15] "cover_calibration_macro"
```
