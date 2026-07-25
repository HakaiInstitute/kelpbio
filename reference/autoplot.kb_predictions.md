# Autoplot Method for Predictions

The conventional
[`ggplot2::autoplot`](https://ggplot2.tidyverse.org/reference/autoplot.html)
entry point for a `kb_predictions` object: a thin wrapper on
[`kb_plot_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_predictions.md).
Dispatches on the prediction data frame, never on a fit.

## Usage

``` r
# S3 method for class 'kb_predictions'
autoplot(object, ...)
```

## Arguments

- object:

  A `kb_predictions` object.

- ...:

  Passed to
  [`kb_plot_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_predictions.md)
  (e.g. `x`, `observed`).

## Value

A `ggplot` object.

## See also

Other prediction:
[`kb_plot_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_predictions.md),
[`kb_predict_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_weight.md),
[`kb_predict_weight_by()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_weight_by.md)

## Examples

``` r
p <- kb_predict_weight_by(fit_weight_sim_nereo, by = "site")
ggplot2::autoplot(p)
```
