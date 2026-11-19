# Add fitted values and residuals to the data

Append the [`fitted()`](https://rdrr.io/r/stats/fitted.values.html) and
deviance [`residuals()`](https://rdrr.io/r/stats/residuals.html) values
to the input data.

## Usage

``` r
# S3 method for class 'kb_fit'
augment(x, ...)
```

## Arguments

- x:

  A `kb_fit` object.

- ...:

  These dots are for future extensions and must be empty.

## Value

The input data with added columns `fitted` (the posterior median of the
expected response) and `residual` (the posterior median of the deviance
residual).

## See also

[`fitted()`](https://rdrr.io/r/stats/fitted.values.html) and
[`residuals()`](https://rdrr.io/r/stats/residuals.html).

Other fit methods:
[`coef.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/coef.kb_fit.md),
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
augment(fit_weight_sim_nereo)
#> # A tibble: 660 × 6
#>    diameter_mm weight_kg site       year  fitted residual
#>          <dbl>     <dbl> <fct>      <fct>  <dbl>    <dbl>
#>  1        28.6     0.663 otter_cove 2020   0.779  -0.117 
#>  2        16.5     0.569 otter_cove 2020   0.262   1.91  
#>  3        27.3     0.841 otter_cove 2020   0.697   0.640 
#>  4        38.3     1.38  otter_cove 2020   1.64   -0.154 
#>  5        16.2     0.153 otter_cove 2020   0.255  -0.877 
#>  6        29.8     0.793 otter_cove 2020   0.861   0.0529
#>  7        34.7     1.36  otter_cove 2020   1.27    0.389 
#>  8        16.2     0.141 otter_cove 2020   0.255  -1.05  
#>  9        25.9     0.311 otter_cove 2020   0.615  -1.25  
#> 10        35.5     1.53  otter_cove 2020   1.34    0.508 
#> # ℹ 650 more rows
```
