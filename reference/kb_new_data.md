# Build new data to predict at

Build a grid of rows to predict at: one row per fitted site, year, or
observed site-year, or per supplied site or year, crossed for a weight
or cover calibration fit with a sequence of its predictor.

## Usage

``` r
kb_new_data(fit, by = NULL, ...)
```

## Arguments

- fit:

  A `kb_fit_weight`, `kb_fit_size`, or `kb_fit_cover_calibration`
  object.

- by:

  A character vector of grouping factors giving the rows of the grid.
  One of:

  - `NULL`: no grouping columns (the typical site and year).

  - `"site"`: one row per fitted site.

  - `"year"`: one row per fitted year.

  - `c("site", "year")`: one row per site-year.

- ...:

  Named values to cross into the grid: for a weight or cover calibration
  fit, the predictor values as a numeric vector (`diameter_mm`,
  `fronds`, or `cover`); and the levels of `site` or `year` not named in
  `by`. If the predictor is omitted, 30 evenly spaced values span the
  observed range for weight (whole numbers for `fronds`), and 0 to 1 for
  cover.

## Value

A tibble with the grouping columns named in `by` or `...`, the predictor
column for a weight or cover calibration fit, and for a cover
calibration fit the survey columns.

## Details

Pass the result as `new_data` to the model's prediction function, for
example `kb_predict_size(fit, kb_new_data(fit, by = "site"))`. The
grouping factors not named in `by` are absent from the grid, so the
prediction treats them as set by `new_levels`: with the default
`"average"`, the typical site or year.

For a cover calibration fit, the predictor `cover` is the tide-corrected
proportion of the plot covered by canopy (0 to 1); each row is then a
unit plot at zero tide height, with the in situ survey columns that give
that cover. A single predictor value gives one row per group at that
value.

To fix a grouping factor at chosen levels, supply them by name in `...`,
for example `year = 2021` with `by = "site"` for every fitted site in
2021, or `site = "otter_cove", year = 2022:2025`. Each value is crossed
with the rest of the grid. A level not in the fit, such as a future
year, is a new level, treated as set by `new_levels`.

`by = c("site", "year")` gives only the site-years in the fitted data.
The result is a tibble; rows can be filtered and columns added before
predicting.

## See also

Other prediction functions:
[`autoplot.kb_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/autoplot.kb_predictions.md),
[`kb_plot_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_predictions.md),
[`kb_predict_biomass_canopy()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_canopy.md),
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.md),
[`kb_predict_carbon()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_carbon.md),
[`kb_predict_cover_calibration()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_cover_calibration.md),
[`kb_predict_mean_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_mean_weight.md),
[`kb_predict_nitrogen()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_nitrogen.md),
[`kb_predict_size()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_size.md),
[`kb_predict_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_weight.md),
[`kb_predict_wetdry()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_wetdry.md),
[`predict.kb_fit_carbon()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_carbon.md),
[`predict.kb_fit_cover_calibration()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_cover_calibration.md),
[`predict.kb_fit_nitrogen()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_nitrogen.md),
[`predict.kb_fit_size()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_size.md),
[`predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_weight.md),
[`predict.kb_fit_wetdry()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_wetdry.md)

## Examples

``` r
kb_new_data(fit_size_sim_nereo, by = "site")
#> # A tibble: 9 × 1
#>   site          
#>   <fct>         
#> 1 otter_cove    
#> 2 gull_rock     
#> 3 cedar_bay     
#> 4 heron_reef    
#> 5 urchin_shoal  
#> 6 sculpin_head  
#> 7 eagle_spit    
#> 8 fog_islet     
#> 9 tidepool_bluff

# Weight curves by site, and weight at 50 mm by site:
kb_new_data(fit_weight_sim_nereo, by = "site")
#> # A tibble: 180 × 2
#>    site       diameter_mm
#>    <fct>            <dbl>
#>  1 otter_cove        3.8 
#>  2 otter_cove        6.12
#>  3 otter_cove        8.45
#>  4 otter_cove       10.8 
#>  5 otter_cove       13.1 
#>  6 otter_cove       15.4 
#>  7 otter_cove       17.7 
#>  8 otter_cove       20.1 
#>  9 otter_cove       22.4 
#> 10 otter_cove       24.7 
#> # ℹ 170 more rows
kb_new_data(fit_weight_sim_nereo, by = "site", diameter_mm = 50)
#> # A tibble: 6 × 2
#>   site       diameter_mm
#>   <fct>            <dbl>
#> 1 otter_cove          50
#> 2 gull_rock           50
#> 3 cedar_bay           50
#> 4 heron_reef          50
#> 5 eagle_spit          50
#> 6 fog_islet           50

# Every site in 2021, and one site across years:
kb_new_data(fit_weight_sim_nereo, by = "site", diameter_mm = 50, year = 2021)
#> # A tibble: 6 × 3
#>   site       year  diameter_mm
#>   <fct>      <chr>       <dbl>
#> 1 otter_cove 2021           50
#> 2 gull_rock  2021           50
#> 3 cedar_bay  2021           50
#> 4 heron_reef 2021           50
#> 5 eagle_spit 2021           50
#> 6 fog_islet  2021           50
kb_new_data(fit_size_sim_nereo, site = "otter_cove", year = 2022:2025)
#> # A tibble: 4 × 2
#>   site       year 
#>   <chr>      <chr>
#> 1 otter_cove 2022 
#> 2 otter_cove 2023 
#> 3 otter_cove 2024 
#> 4 otter_cove 2025 

kb_predict_size(fit_size_sim_nereo, kb_new_data(fit_size_sim_nereo, by = "site"))
#> <kb_predictions> response: diameter_mm | by: site
#> # A tibble: 9 × 4
#>   site           estimate lower upper
#>   <fct>             <dbl> <dbl> <dbl>
#> 1 otter_cove         25.6  23.3  28  
#> 2 gull_rock          27.5  25    30.3
#> 3 cedar_bay          22.4  20.5  24.8
#> 4 heron_reef         24.4  22.1  26.9
#> 5 urchin_shoal       18.7  16.7  21.3
#> 6 sculpin_head       22.4  20.5  24.6
#> 7 eagle_spit         29.1  26.6  31.9
#> 8 fog_islet          31.8  28.1  36  
#> 9 tidepool_bluff     27.3  25    30.1
```
