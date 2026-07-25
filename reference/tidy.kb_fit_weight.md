# Tidy a Weight Model Fit

Posterior summaries of the model terms: the population-level effects and
the random-effect standard deviations, plus (when
`include_random_effects = TRUE`) the group-level deviations. By default
the per-level deviations are omitted, following the `broom.mixed`
convention.

## Usage

``` r
# S3 method for class 'kb_fit_weight'
tidy(
  x,
  ...,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3,
  include_random_effects = FALSE
)
```

## Arguments

- x:

  A `kb_fit_weight` object.

- ...:

  Unused.

- conf_level:

  A number between 0 and 1 giving the compatibility-interval level.

- estimate:

  A function that reduces a numeric vector of posterior draws to a
  scalar point estimate (e.g. `median` or `mean`).

- sig_fig:

  A whole number of significant figures for summary output.

- include_random_effects:

  A flag specifying whether to include the group-level random-effect
  terms in the output.

## Value

A tibble with one row per term and columns `term`, `estimate`, `lower`,
`upper`.

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
[`posterior_linpred.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_linpred.kb_fit_weight.md),
[`posterior_predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_predict.kb_fit_weight.md),
[`predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_weight.md),
[`prior_summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/prior_summary.kb_fit.md),
[`residuals.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit_weight.md),
[`samples()`](https://hakaiinstitute.github.io/kelpbio/reference/samples.md),
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md)

## Examples

``` r
tidy(fit_weight_sim_nereo)
#> # A tibble: 7 × 4
#>   term          estimate   lower  upper
#>   <chr>            <dbl>   <dbl>  <dbl>
#> 1 bWeight        -1.47   -1.66   -1.24 
#> 2 bDiameter       2.5     2.28    2.74 
#> 3 bDiameter2      0.0749 -0.156   0.313
#> 4 sSite           0.27    0.176   0.459
#> 5 sSiteDiameter   0.313   0.169   0.62 
#> 6 sSiteYear       0.0962  0.0521  0.149
#> 7 sWeight         0.161   0.141   0.185
```
