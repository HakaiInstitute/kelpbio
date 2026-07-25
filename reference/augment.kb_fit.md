# Augment Model Data

Append the [`fitted()`](https://rdrr.io/r/stats/fitted.values.html) and
deviance [`residuals()`](https://rdrr.io/r/stats/residuals.html) values
to the input data. Values are the point estimate (median) of the
posterior distributions.

## Usage

``` r
# S3 method for class 'kb_fit'
augment(x, ...)
```

## Arguments

- x:

  A `kb_fit` object.

- ...:

  Unused.

## Value

The input data with added columns `fitted` (response-scale fitted value)
and `residual` (deviance residual).

## See also

[`fitted()`](https://rdrr.io/r/stats/fitted.values.html) and
[`residuals()`](https://rdrr.io/r/stats/residuals.html).

Other generics:
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
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md),
[`tidy.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit_weight.md)

## Examples

``` r
augment(fit_weight_sim_nereo)
#> # A tibble: 234 × 6
#>    diameter weight site  year  fitted residual
#>       <dbl>  <dbl> <fct> <fct>  <dbl>    <dbl>
#>  1     53.8  0.412 site1 2019  0.427   -0.242 
#>  2     38.2  0.183 site1 2019  0.173    0.378 
#>  3     25.2  0.059 site1 2019  0.0595  -0.0540
#>  4     54.5  0.523 site1 2019  0.442    1.11  
#>  5     25.6  0.06  site1 2019  0.0619  -0.212 
#>  6     49.5  0.411 site1 2019  0.342    1.19  
#>  7     63.7  0.693 site2 2019  0.672    0.199 
#>  8     32.6  0.144 site2 2019  0.132    0.582 
#>  9     44.5  0.166 site2 2019  0.279   -2.53  
#> 10     58    0.457 site2 2019  0.534   -1.02  
#> # ℹ 224 more rows
```
