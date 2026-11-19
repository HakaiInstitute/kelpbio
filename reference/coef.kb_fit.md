# Coefficients

Posterior summaries of the model terms, as returned by
[`tidy()`](https://generics.r-lib.org/reference/tidy.html).

## Usage

``` r
# S3 method for class 'kb_fit'
coef(object, ...)
```

## Arguments

- object:

  A `kb_fit` object.

- ...:

  Passed to [`tidy()`](https://generics.r-lib.org/reference/tidy.html).

## Value

A tibble with one row per term and columns `term`, `estimate`, `lower`,
and `upper`.

## See also

Other fit methods:
[`augment.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/augment.kb_fit.md),
[`fitted.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/fitted.kb_fit.md),
[`glance.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/glance.kb_fit.md),
[`kb_model_describe()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_model_describe.md),
[`kb_samples()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_samples.md),
[`kb_stancode()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_stancode.md),
[`log_lik.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/log_lik.kb_fit.md),
[`posterior_epred.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_epred.kb_fit.md),
[`posterior_linpred.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_linpred.kb_fit.md),
[`posterior_predict.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_predict.kb_fit.md),
[`prior_summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/prior_summary.kb_fit.md),
[`residuals.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit.md),
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md),
[`tidy.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit.md)

## Examples

``` r
coef(fit_weight_sim_nereo)
#> # A tibble: 7 × 4
#>   term           estimate    lower  upper
#>   <chr>             <dbl>    <dbl>  <dbl>
#> 1 intercept       -0.666  -0.918   -0.421
#> 2 diameter_power   2.92    2.71     3.13 
#> 3 weight_floor     0.118   0.098    0.14 
#> 4 sd_site          0.2     0.0406   0.521
#> 5 sd_year          0.0544  0.00298  0.254
#> 6 sd_site_year     0.261   0.179    0.372
#> 7 sd_residual      0.463   0.438    0.488
```
