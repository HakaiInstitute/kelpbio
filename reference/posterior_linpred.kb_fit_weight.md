# Linear-Predictor Posterior Draws

Draws of the weight-model linear predictor on the log scale (or, with
`transform = TRUE`, on the response scale).

## Usage

``` r
# S3 method for class 'kb_fit_weight'
posterior_linpred(
  object,
  transform = FALSE,
  new_data = NULL,
  ...,
  new_levels = "sample",
  representative_site = NULL
)
```

## Arguments

- object:

  A `kb_fit_weight` object.

- transform:

  A flag specifying whether to return the response-scale value (`exp`).

- new_data:

  A data frame with a `diameter` column (and optional `site` / `year`
  columns), or `NULL` for the observed data.

- ...:

  Unused.

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

## Value

A draws-by-observations (`D x N`) matrix.

## Details

Conditioning is inferred from the grouping columns present in `new_data`
(see
[`posterior_epred()`](https://mc-stan.org/rstantools/reference/posterior_epred.html));
with `new_data = NULL` the observed data is used and conditioned on its
site and year.

## See also

Other generics:
[`augment.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/augment.kb_fit.md),
[`coef.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/coef.kb_fit.md),
[`converged.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/converged.kb_fit.md),
[`fitted.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/fitted.kb_fit_weight.md),
[`glance.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/glance.kb_fit.md),
[`kb_stancode()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_stancode.md),
[`log_lik.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/log_lik.kb_fit.md),
[`posterior_epred.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_epred.kb_fit_weight.md),
[`posterior_predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_predict.kb_fit_weight.md),
[`predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_weight.md),
[`prior_summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/prior_summary.kb_fit.md),
[`residuals.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit_weight.md),
[`samples()`](https://hakaiinstitute.github.io/kelpbio/reference/samples.md),
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md),
[`tidy.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit_weight.md)

## Examples

``` r
lp <- posterior_linpred(fit_weight_sim_nereo)
dim(lp)
#> [1] 800 234
```
