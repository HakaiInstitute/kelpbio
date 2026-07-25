# Predict Weight Over a Diameter Sequence by Grouping Factor

Summarise the fitted relationship between weight and diameter over a
generated prediction grid: a sequence of diameter values crossed with
the grouping factors named in `by` (one curve per group).

## Usage

``` r
kb_predict_weight_by(
  fit,
  by = NULL,
  diameter = NULL,
  ...,
  new_levels = c("average", "sample"),
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
)
```

## Arguments

- fit:

  A `kb_fit_weight` object.

- by:

  A character vector of grouping factors, each drawn as a separate
  curve, or `NULL` for a single population-level curve. Each named
  factor is expanded over its observed levels and conditioned on its
  estimated random effects.

- diameter:

  A numeric vector of sub-bulb diameters to predict over (in the same
  units as the fitted data), or `NULL` for an automatic sequence
  spanning the observed range.

- ...:

  These dots are for future extensions and must be empty.

- new_levels:

  A string, one of `"sample"` or `"average"`, controlling how random
  effects that are not conditioned on are treated (factors absent from
  the prediction, and any new level not seen in the fit). `"sample"`
  draws a new random effect from `Normal(0, sd)`, widening the interval
  to include between-group variation; `"average"` holds the random
  effects at zero, giving the typical group. Known levels are always
  conditioned on. `"sample"` draws fresh randomness on each call, so set
  a seed with [`set.seed()`](https://rdrr.io/r/base/Random.html) for a
  reproducible interval.

- conf_level:

  A number between 0 and 1 giving the compatibility-interval level.

- estimate:

  A function that reduces a numeric vector of posterior draws to a
  scalar point estimate (e.g. `median` or `mean`).

- sig_fig:

  A whole number of significant figures for summary output.

## Value

A `kb_predictions` object: a summary tibble with `estimate`, `lower`,
`upper`, the `diameter` predictor, and the `by` grouping columns.

## Details

`by` selects the grouping factors that each get their own curve,
conditioned on their estimated random effects. `new_levels` controls the
factors not named in `by`. The default `"average"` holds those random
effects at zero, giving the typical-group curve. `"sample"` instead
draws a new random effect from its estimated distribution, widening the
uncertainty to include between-group variation. Set a seed with
[`set.seed()`](https://rdrr.io/r/base/Random.html) for reproducible CIs.
The available `by` values are `NULL` (a single population curve),
`"site"`, and `c("site", "year")`.

## See also

[`kb_predict_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_weight.md)
for predictions at the rows of a supplied data frame.

Other prediction:
[`autoplot.kb_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/autoplot.kb_predictions.md),
[`kb_plot_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_predictions.md),
[`kb_predict_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_weight.md)

## Examples

``` r
kb_predict_weight_by(fit_weight_sim_nereo, by = "site")
#> <kb_predictions> predictor: diameter | response: weight | by: site
#> # A tibble: 300 × 5
#>    site  diameter estimate  lower  upper
#>    <fct>    <dbl>    <dbl>  <dbl>  <dbl>
#>  1 site1     15.6   0.0163 0.0127 0.021 
#>  2 site1     18.1   0.0237 0.0194 0.0288
#>  3 site1     20.6   0.0327 0.0277 0.0387
#>  4 site1     23.2   0.0437 0.0376 0.0508
#>  5 site1     25.7   0.0567 0.0489 0.0652
#>  6 site1     28.2   0.0719 0.0626 0.0826
#>  7 site1     30.7   0.0897 0.0782 0.102 
#>  8 site1     33.2   0.11   0.0962 0.125 
#>  9 site1     35.7   0.133  0.116  0.151 
#> 10 site1     38.3   0.158  0.139  0.18  
#> # ℹ 290 more rows
```
