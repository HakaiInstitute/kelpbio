# Posterior Draws

The raw posterior draws from a fitted model object.

## Usage

``` r
samples(fit, ...)

# S3 method for class 'kb_fit'
samples(fit, ...)
```

## Arguments

- fit:

  A fitted model object.

- ...:

  Unused.

## Value

A `posterior` draws object.

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
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md),
[`tidy.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit_weight.md)

## Examples

``` r
samples(fit_weight_sim_nereo)
#> # A draws_rvars: 400 iterations, 2 chains, and 10 variables
#> $bWeight: rvar<400,2>[1] mean ± sd:
#> [1] -1.5 ± 0.1 
#> 
#> $bDiameter: rvar<400,2>[1] mean ± sd:
#> [1] 2.5 ± 0.12 
#> 
#> $bDiameter2: rvar<400,2>[1] mean ± sd:
#> [1] 0.079 ± 0.12 
#> 
#> $sSite: rvar<400,2>[1] mean ± sd:
#> [1] 0.28 ± 0.079 
#> 
#> $sSiteDiameter: rvar<400,2>[1] mean ± sd:
#> [1] 0.33 ± 0.11 
#> 
#> $sSiteYear: rvar<400,2>[1] mean ± sd:
#> [1] 0.098 ± 0.025 
#> 
#> $sWeight: rvar<400,2>[1] mean ± sd:
#> [1] 0.16 ± 0.011 
#> 
#> $bSite: rvar<400,2>[10] mean ± sd:
#>  [1] -0.257 ± 0.12   0.054 ± 0.11  -0.157 ± 0.12  -0.052 ± 0.12   0.108 ± 0.12 
#>  [6]  0.434 ± 0.12   0.054 ± 0.12  -0.179 ± 0.12   0.316 ± 0.12  -0.350 ± 0.12 
#> 
#> # ... with 2 more variables
```
