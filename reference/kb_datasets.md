# Datasets

The datasets that kelpbio fits or predicts from, with what one row of
each holds.
[`kb_data_columns()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_data_columns.md)
gives each dataset's columns.

## Usage

``` r
kb_datasets(dataset = NULL)
```

## Arguments

- dataset:

  A string of the dataset to describe, one of `kb_datasets()$dataset`,
  or `NULL` for every dataset.

## Value

A tibble with one row per dataset and the character columns `dataset`
and `row` (what one row of the dataset holds, as markdown with column
names in backticks).

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
[`kb_data_columns()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_data_columns.md)

## Examples

``` r
kb_datasets()
#> # A tibble: 15 × 2
#>    dataset                 row                                                  
#>    <chr>                   <chr>                                                
#>  1 weight_nereo            Harvested plant, with its size, wet weight, `site`, …
#>  2 weight_macro            Harvested plant, with its size, wet weight, `site`, …
#>  3 size_sample_nereo       Measured plant, with its size, `site`, and `year`    
#>  4 size_census_nereo       Counted plant, with its size and the `survey_id` of …
#>  5 size_census_macro       Counted plant, with its size and the `survey_id` of …
#>  6 survey_in_situ          In situ survey, with its `survey_id`, `site`, `year`…
#>  7 survey_canopy           Canopy map, with its `site`, `year`, and mapped cano…
#>  8 wetdry_nereo            Tissue sample, with no site or year                  
#>  9 wetdry_macro            Tissue sample, with no site or year                  
#> 10 carbon_nereo            Tissue sample, with no site or year                  
#> 11 carbon_macro            Tissue sample, with no site or year                  
#> 12 nitrogen_nereo          Tissue sample, with no site or year                  
#> 13 nitrogen_macro          Tissue sample, with no site or year                  
#> 14 cover_calibration_nereo In situ survey, with its estimated biomass and plot …
#> 15 cover_calibration_macro In situ survey, with its estimated biomass and plot …
kb_datasets("survey_canopy")
#> # A tibble: 1 × 2
#>   dataset       row                                                   
#>   <chr>         <chr>                                                 
#> 1 survey_canopy Canopy map, with its `site`, `year`, and mapped canopy
```
