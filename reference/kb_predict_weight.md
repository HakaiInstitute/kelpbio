# Predict Weight for New Data

Predict weight for the supplied rows, or for the observed data when
`new_data = NULL`. For an allometric curve over a diameter sequence, use
[`kb_predict_weight_by()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_weight_by.md)
instead.

## Usage

``` r
kb_predict_weight(
  fit,
  new_data = NULL,
  ...,
  new_levels = c("sample", "average"),
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

  A data frame with a `diameter` column (and optional `site` / `year`
  columns), or `NULL` to predict at the observed data.

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

- representative_site:

  A character vector of site levels present in the fit, or `NULL` (the
  default). When supplied, a new or absent site takes its site main
  effects (intercept and slope) from the named reference site (the
  per-draw average when several are named), instead of the `new_levels`
  treatment; the `site:year` interaction still follows `new_levels`.

- conf_level:

  A number between 0 and 1 giving the compatibility-interval level.

- estimate:

  A function that reduces a numeric vector of posterior draws to a
  scalar point estimate (e.g. `median` or `mean`).

- sig_fig:

  A whole number of significant figures for summary output.

## Value

A `kb_predictions` object: the input rows with added `estimate`,
`lower`, and `upper` columns.

## Details

Conditioning is resolved per row: a `site`/`year` value the model has
seen is conditioned on its estimated random effects; a new site or year,
or an absent grouping column, is handled by `new_levels`.

With the default `new_levels = "sample"`, an absent or new group draws a
random effect from its estimated distribution, so the interval includes
between-group variation; `"average"` instead holds those random effects
at zero. `"sample"` draws fresh values on each call; set a seed with
[`set.seed()`](https://rdrr.io/r/base/Random.html) for a reproducible
interval. `"sample"` is the default because it produces honest
uncertainty for a new, unobserved site/year.

For a new site, `representative_site` offers a third approach: instead
of `new_levels` (`"sample"` or `"average"`) it borrows the site
intercept and slope of one or more named reference sites (the per-draw
average across several). The `site:year` interaction still follows
`new_levels`.

## See also

[`kb_predict_weight_by()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_weight_by.md)
to generate new_data by grouping factors and diameter sequence, and
[`augment()`](https://generics.r-lib.org/reference/augment.html) for
fitted/residual values at the observed data.

Other prediction:
[`autoplot.kb_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/autoplot.kb_predictions.md),
[`kb_plot_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_predictions.md),
[`kb_predict_weight_by()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_weight_by.md)

## Examples

``` r
new_data <- data.frame(diameter = c(20, 40, 60))
kb_predict_weight(fit_weight_sim_nereo, new_data, new_levels = "average")
#> <kb_predictions> predictor: diameter | response: weight
#> # A tibble: 3 × 4
#>   diameter estimate  lower  upper
#>      <dbl>    <dbl>  <dbl>  <dbl>
#> 1       20    0.042 0.0332 0.0565
#> 2       40    0.229 0.189  0.288 
#> 3       60    0.64  0.517  0.824 

# Predict a new site as if it behaves like a known reference site:
new_site <- data.frame(diameter = c(20, 40, 60), site = "new_site")
kb_predict_weight(
  fit_weight_sim_nereo, new_site,
  representative_site = fit_weight_sim_nereo$meta$site_levels[1]
)
#> <kb_predictions> predictor: diameter | response: weight | by: site
#> # A tibble: 3 × 5
#>   diameter site     estimate  lower  upper
#>      <dbl> <chr>       <dbl>  <dbl>  <dbl>
#> 1       20 new_site   0.0302 0.0233 0.0396
#> 2       40 new_site   0.177  0.141  0.217 
#> 3       60 new_site   0.519  0.403  0.675 
```
