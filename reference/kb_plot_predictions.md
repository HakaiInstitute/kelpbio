# Plot predictions

Render a `ggplot` from a `kb_predictions` object (the output of a
`kb_predict_*()` function).

## Usage

``` r
kb_plot_predictions(
  predictions,
  ...,
  x = NULL,
  geom = c("pointrange", "bar"),
  log_axis = c("none", "y", "xy"),
  max_facets = 12L
)
```

## Arguments

- predictions:

  A `kb_predictions` object.

- ...:

  These dots are for future extensions and must be empty.

- x:

  A string naming the x-axis column, or `NULL` to choose it from the
  predictions.

- geom:

  A string, one of `"pointrange"` (points with intervals) or `"bar"`
  (columns from zero with intervals), for predictions not drawn as a
  curve.

- log_axis:

  A string, one of `"none"` (linear axes), `"y"` (log-scaled y-axis), or
  `"xy"` (log-scaled x- and y-axes).

- max_facets:

  A whole number capping the facet panels drawn; if the grouping has
  more groups, the first `max_facets` are shown with a warning. Use
  `Inf` to disable.

## Value

A `ggplot` object.

## Details

The x-axis, facets, and geometry are chosen from the predictions:
predictions over a grid of predictor values (as from
[`kb_new_data()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_new_data.md))
are drawn as a line and compatibility-interval ribbon, and others as
points or columns with intervals. The result is a `ggplot` that can be
extended with `+`, for example to add the raw data as a layer.

## See also

Other prediction functions:
[`autoplot.kb_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/autoplot.kb_predictions.md),
[`kb_new_data()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_new_data.md),
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
fit <- fit_weight_sim_nereo

# Allometric curve by site (ribbon):
kb_predict_weight(fit, kb_new_data(fit, by = "site")) |>
  kb_plot_predictions()


# Add the raw data as a layer:
kb_predict_weight(fit, kb_new_data(fit)) |>
  kb_plot_predictions() +
  ggplot2::geom_point(
    ggplot2::aes(diameter_mm, weight_kg),
    data = data_weight_sim_nereo,
    alpha = 0.3
  )


# Expected size by site (pointrange):
kb_predict_size(
  fit_size_sim_nereo,
  kb_new_data(fit_size_sim_nereo, by = "site")
) |>
  kb_plot_predictions()


# Weight at a reference diameter by site (pointrange, sites on the y-axis):
kb_predict_weight(fit, kb_new_data(fit, by = "site", diameter_mm = 30)) |>
  kb_plot_predictions() +
  ggplot2::coord_flip()


# Canopy biomass by year (columns):
kb_predict_biomass_canopy(
  fit_cover_calibration_sim_nereo,
  data_survey_canopy_sim_nereo,
  pool_by = "year"
) |>
  kb_plot_predictions(geom = "bar")


# Allometric curve on log-log axes:
kb_predict_weight(fit, kb_new_data(fit)) |>
  kb_plot_predictions(log_axis = "xy")


# Cover curve on log-log axes, over positive cover values:
cover_fit <- fit_cover_calibration_sim_nereo
kb_predict_cover_calibration(
  cover_fit,
  kb_new_data(cover_fit, cover = 10^seq(-3, 0, length.out = 30))
) |>
  kb_plot_predictions(log_axis = "xy")
```
