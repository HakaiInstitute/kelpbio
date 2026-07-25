# Model Fit Diagnostic Summary

One-row summary of a model fit with convergence diagnostics.

## Usage

``` r
# S3 method for class 'kb_fit'
glance(x, ..., rhat = 1.05, esr = 0.1)
```

## Arguments

- x:

  A `kb_fit` object.

- ...:

  Unused.

- rhat:

  A number giving the maximum acceptable Rhat.

- esr:

  A number giving the minimum acceptable effective sample rate
  (effective sample size divided by the number of draws).

## Value

A one-row tibble with `n`, `K`, `nchains`, `niters`, `nthin`, `ess` (the
minimum bulk effective sample size), `rhat` (the maximum Rhat), and
`converged`.

## See also

Other generics:
[`augment.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/augment.kb_fit.md),
[`coef.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/coef.kb_fit.md),
[`converged.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/converged.kb_fit.md),
[`fitted.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/fitted.kb_fit_weight.md),
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
glance(fit_weight_sim_nereo)
#> # A tibble: 1 × 8
#>       n     K nchains niters nthin   ess  rhat converged
#>   <int> <int>   <int>  <dbl> <int> <dbl> <dbl> <lgl>    
#> 1   234    10       2    400     1  201.  1.03 TRUE     
```
