# Predict biomass from canopy cover

Predict the expected wet biomass (kg/m²) of a plot from its plot cover.

## Usage

``` r
kb_predict_cover_calibration(
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

  A `kb_fit_cover_calibration` object.

- new_data:

  A data frame of the rows to predict at, with `canopy_area_m2` (the
  canopy area in the plot, m²), `plot_area_m2` (the plot area, m²),
  `canopy_tide_height_m` (the tide height, m), and optionally `site` and
  `year`, or `NULL` for the observed surveys. `year` may be numeric or
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

A `kb_predictions` object: the rows of `new_data` with `cover_support`
(when the rows have a site and year), `estimate`, `lower`, and `upper`.

## Details

Cover is tide-corrected and capped at full cover, 100% (see
[Methods](https://hakaiinstitute.github.io/kelpbio/articles/methods.html#cover-calibration)).
A warning is given if a row with canopy has a tide height above 2 m.
When the fit has a presence part (when any survey in its data counted no
plants), the prediction includes the probability that the plot holds
plants.

## See also

[`kb_new_data()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_new_data.md)
to build rows by site or year over tide-corrected cover.

Other prediction functions:
[`autoplot.kb_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/autoplot.kb_predictions.md),
[`kb_new_data()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_new_data.md),
[`kb_plot_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_predictions.md),
[`kb_predict_biomass_canopy()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_canopy.md),
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.md),
[`kb_predict_carbon()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_carbon.md),
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
fit <- fit_cover_calibration_sim_nereo

# At the observed surveys
kb_predict_cover_calibration(fit)
#> <kb_predictions> predictor: cover | response: biomass_kg_m2 | by: site, year
#> # A tibble: 54 × 16
#>    survey_id       site  year  survey_area_m2 plants plot_area_m2 canopy_area_m2
#>    <chr>           <fct> <fct>          <dbl>  <int>        <dbl>          <dbl>
#>  1 otter_cove-202… otte… 2020            140     992         215            87.3
#>  2 otter_cove-202… otte… 2020             80     297         262.          110. 
#>  3 gull_rock-2020… gull… 2020            233.    660         233.           30.3
#>  4 cedar_bay-2020… ceda… 2020             40       0         270.           34.3
#>  5 cedar_bay-2020… ceda… 2020            180     861         255.           81.2
#>  6 heron_reef-202… hero… 2020            120     550         217.           73.5
#>  7 urchin_shoal-2… urch… 2020            160    1815         218.          116. 
#>  8 sculpin_head-2… scul… 2020            193.   1245         193.           30.1
#>  9 eagle_spit-202… eagl… 2020            200     471         259.           97.3
#> 10 tidepool_bluff… tide… 2020            180     698         229            62.3
#> # ℹ 44 more rows
#> # ℹ 9 more variables: canopy_tide_height_m <dbl>, weight_support <chr>,
#> #   size_support <chr>, biomass_kg_m2 <dbl>, biomass_sd_kg_m2 <dbl>,
#> #   cover_support <chr>, estimate <dbl>, lower <dbl>, upper <dbl>

# Curves over tide-corrected cover by site
kb_predict_cover_calibration(fit, kb_new_data(fit, by = "site"))
#> <kb_predictions> predictor: cover | response: biomass_kg_m2 | by: site
#> # A tibble: 270 × 8
#>    site   cover canopy_area_m2 plot_area_m2 canopy_tide_height_m estimate  lower
#>    <fct>  <dbl>          <dbl>        <dbl>                <dbl>    <dbl>  <dbl>
#>  1 otte… 0              0                 1                    0    0.148 0.0139
#>  2 otte… 0.0345         0.0345            1                    0    0.39  0.205 
#>  3 otte… 0.0690         0.0690            1                    0    0.658 0.432 
#>  4 otte… 0.103          0.103             1                    0    0.931 0.648 
#>  5 otte… 0.138          0.138             1                    0    1.2   0.877 
#>  6 otte… 0.172          0.172             1                    0    1.47  1.08  
#>  7 otte… 0.207          0.207             1                    0    1.73  1.28  
#>  8 otte… 0.241          0.241             1                    0    2     1.49  
#>  9 otte… 0.276          0.276             1                    0    2.26  1.69  
#> 10 otte… 0.310          0.310             1                    0    2.52  1.89  
#> # ℹ 260 more rows
#> # ℹ 1 more variable: upper <dbl>

# At new surveys, including a new site
kb_predict_cover_calibration(
  fit,
  data.frame(
    site = c("otter_cove", "new_site"),
    canopy_area_m2 = 80,
    plot_area_m2 = 200,
    canopy_tide_height_m = 0.5
  )
)
#> <kb_predictions> predictor: cover | response: biomass_kg_m2 | by: site
#> # A tibble: 2 × 7
#>   site     canopy_area_m2 plot_area_m2 canopy_tide_height_m estimate lower upper
#>   <chr>             <dbl>        <dbl>                <dbl>    <dbl> <dbl> <dbl>
#> 1 otter_c…             80          200                  0.5     3.65  2.73  4.86
#> 2 new_site             80          200                  0.5     3.79  2.92  4.99
```
