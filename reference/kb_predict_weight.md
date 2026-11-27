# Predict weight

Predict the expected wet weight (kg) of a plant at each row of
`new_data`, or at the observed data when `new_data = NULL`.

## Usage

``` r
kb_predict_weight(
  fit,
  new_data = NULL,
  ...,
  new_levels = c("average", "sample"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
)
```

## Arguments

- fit:

  A `kb_fit_weight` object.

- new_data:

  A data frame of the rows to predict at, with the fit's predictor
  column (`diameter_mm` or `fronds`) and optional `site` and `year`
  columns, or `NULL` for the observed data. `year` may be numeric or
  character: `2022` and `"2022"` match the same fitted year.

- ...:

  These dots are for future extensions and must be empty.

- new_levels:

  A string giving how uncertainty is estimated for a site or year not in
  the data used to fit the model, or when `new_data` has no `site` or
  `year` column. Sites and years in the model fit always use their own
  estimates. One of:

  - `"average"` (the default): the typical site or year. The site and
    year effects are set to 0, their mean, so the interval does not
    include among-site or among-year variation. Use it to describe an
    average site or year.

  - `"sample"`: a new effect for each new site or year, drawn from the
    estimated variation among sites or among years (the random-effect
    standard deviation). The point estimate is equivalent, but the
    interval is wider since it also includes that variation. Use it to
    get realistic uncertainty about a particular site or year that the
    model has no information on. Rows that name the same new site or
    year, or that have no `site` or `year` column, share one effect;
    give new sites or years different names for independent effects. The
    interval varies slightly between calls; use
    [`set.seed()`](https://rdrr.io/r/base/Random.html) to reproduce it.

- representative_site:

  A character vector of sites in the fit whose effects a new site adopts
  (averaged when several are named), or `NULL` (the default) to follow
  `new_levels`.

- conf_level:

  A number greater than 0 and less than 1 giving the
  compatibility-interval level.

- estimate:

  A function that reduces a numeric vector of posterior draws to a
  single estimate, such as `median` or `mean`.

- sig_fig:

  A whole number of significant figures for summary output.

## Value

A `kb_predictions` object: the rows of `new_data` with added `estimate`,
`lower`, and `upper` columns summarising the posterior distribution of
expected weight. When the rows have `site` and `year`, a
`weight_support` column (as in
[`kb_predict_mean_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_mean_weight.md))
precedes the summary.

## Details

With `representative_site`, a new site also takes the named sites'
site:year effect in a year in which they have data.

## See also

[`kb_new_data()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_new_data.md)
to build rows by site or year over a predictor sequence, and
[`posterior_predict()`](https://mc-stan.org/rstantools/reference/posterior_predict.html)
for draws of individual plant weights.

Other prediction functions:
[`autoplot.kb_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/autoplot.kb_predictions.md),
[`kb_new_data()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_new_data.md),
[`kb_plot_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_predictions.md),
[`kb_predict_biomass_canopy()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_canopy.md),
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.md),
[`kb_predict_carbon()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_carbon.md),
[`kb_predict_cover_calibration()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_cover_calibration.md),
[`kb_predict_mean_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_mean_weight.md),
[`kb_predict_nitrogen()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_nitrogen.md),
[`kb_predict_size()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_size.md),
[`kb_predict_wetdry()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_wetdry.md),
[`predict.kb_fit_carbon()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_carbon.md),
[`predict.kb_fit_cover_calibration()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_cover_calibration.md),
[`predict.kb_fit_nitrogen()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_nitrogen.md),
[`predict.kb_fit_size()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_size.md),
[`predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_weight.md),
[`predict.kb_fit_wetdry()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_wetdry.md)

## Examples

``` r
fit <- fit_weight_sim_nereo

# At the observed plants:
kb_predict_weight(fit)
#> <kb_predictions> predictor: diameter_mm | response: weight_kg | by: site, year
#> # A tibble: 660 × 8
#>    diameter_mm weight_kg site       year  weight_support estimate lower upper
#>          <dbl>     <dbl> <fct>      <fct> <chr>             <dbl> <dbl> <dbl>
#>  1        28.6     0.663 otter_cove 2020  site-year         0.779 0.632 0.96 
#>  2        16.5     0.569 otter_cove 2020  site-year         0.262 0.23  0.299
#>  3        27.3     0.841 otter_cove 2020  site-year         0.697 0.567 0.855
#>  4        38.3     1.38  otter_cove 2020  site-year         1.64  1.31  2.08 
#>  5        16.2     0.153 otter_cove 2020  site-year         0.255 0.224 0.291
#>  6        29.8     0.793 otter_cove 2020  site-year         0.861 0.697 1.06 
#>  7        34.7     1.36  otter_cove 2020  site-year         1.27  1.01  1.58 
#>  8        16.2     0.141 otter_cove 2020  site-year         0.255 0.224 0.291
#>  9        25.9     0.311 otter_cove 2020  site-year         0.615 0.505 0.752
#> 10        35.5     1.53  otter_cove 2020  site-year         1.34  1.07  1.68 
#> # ℹ 650 more rows

# Curves by site:
kb_predict_weight(fit, kb_new_data(fit, by = "site"))
#> <kb_predictions> predictor: diameter_mm | response: weight_kg | by: site
#> # A tibble: 180 × 5
#>    site       diameter_mm estimate lower upper
#>    <fct>            <dbl>    <dbl> <dbl> <dbl>
#>  1 otter_cove        3.8     0.133 0.112 0.158
#>  2 otter_cove        6.12    0.14  0.121 0.163
#>  3 otter_cove        8.45    0.154 0.137 0.176
#>  4 otter_cove       10.8     0.179 0.162 0.2  
#>  5 otter_cove       13.1     0.216 0.195 0.242
#>  6 otter_cove       15.4     0.268 0.239 0.306
#>  7 otter_cove       17.7     0.336 0.296 0.391
#>  8 otter_cove       20.1     0.425 0.367 0.5  
#>  9 otter_cove       22.4     0.535 0.457 0.638
#> 10 otter_cove       24.7     0.671 0.567 0.808
#> # ℹ 170 more rows

# At new measurements:
kb_predict_weight(fit, data.frame(diameter_mm = c(20, 40, 60)))
#> <kb_predictions> predictor: diameter_mm | response: weight_kg
#> # A tibble: 3 × 4
#>   diameter_mm estimate lower  upper
#>         <dbl>    <dbl> <dbl>  <dbl>
#> 1          20    0.434 0.368  0.522
#> 2          40    2.41  1.94   3.08 
#> 3          60    7.58  5.9   10    

# A new site, with between-site variation:
set.seed(1)
kb_predict_weight(
  fit,
  data.frame(diameter_mm = 40, site = "new_site"),
  new_levels = "sample"
)
#> <kb_predictions> predictor: diameter_mm | response: weight_kg | by: site
#> # A tibble: 1 × 5
#>   diameter_mm site     estimate lower upper
#>         <dbl> <chr>       <dbl> <dbl> <dbl>
#> 1          40 new_site     2.45  1.16  5.26
```
