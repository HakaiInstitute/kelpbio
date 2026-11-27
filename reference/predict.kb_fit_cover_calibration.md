# Predict method for cover calibration fits

Predict the expected wet biomass per m² of plot at the rows of
`new_data`, or at the observed data when `new_data = NULL`. Equivalent
to
[`kb_predict_cover_calibration()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_cover_calibration.md).

## Usage

``` r
# S3 method for class 'kb_fit_cover_calibration'
predict(
  object,
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

- object:

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

A `kb_predictions` object.

## See also

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
[`kb_predict_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_weight.md),
[`kb_predict_wetdry()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_wetdry.md),
[`predict.kb_fit_carbon()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_carbon.md),
[`predict.kb_fit_nitrogen()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_nitrogen.md),
[`predict.kb_fit_size()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_size.md),
[`predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_weight.md),
[`predict.kb_fit_wetdry()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_wetdry.md)

## Examples

``` r
predict(
  fit_cover_calibration_sim_macro,
  data.frame(canopy_area_m2 = 120, plot_area_m2 = 200, canopy_tide_height_m = 0.5)
)
#> <kb_predictions> predictor: cover | response: biomass_kg_m2
#> # A tibble: 1 × 6
#>   canopy_area_m2 plot_area_m2 canopy_tide_height_m estimate lower upper
#>            <dbl>        <dbl>                <dbl>    <dbl> <dbl> <dbl>
#> 1            120          200                  0.5     6.14  5.19  7.12
```
