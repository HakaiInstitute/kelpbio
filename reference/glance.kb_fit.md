# One-row summary of a fit

One-row summary of a model fit with convergence diagnostics.

## Usage

``` r
# S3 method for class 'kb_fit'
glance(x, ..., rhat = 1.01, ess = 100, max_perc_divergent = 0.2)
```

## Arguments

- x:

  A `kb_fit` object.

- ...:

  These dots are for future extensions and must be empty.

- rhat:

  A number of at least 1 giving the maximum acceptable Rhat.

- ess:

  A number giving the minimum acceptable bulk and tail effective sample
  size per chain.

- max_perc_divergent:

  A number giving the maximum acceptable percentage of saved draws that
  ended in a divergent transition.

## Value

A one-row tibble with `n` (the number of observations), `K` (the number
of terms [`tidy()`](https://generics.r-lib.org/reference/tidy.html)
reports, excluding the per-level group effects), `nchains`, `niters`,
`nthin`, the worst `ess_bulk`, `ess_tail`, and `rhat` across parameters,
`perc_divergent` (the percentage of saved draws that ended in a
divergent transition), and `converged` (from
[`kb_converged()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_converged.md)).

## See also

[`kb_converged()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_converged.md)
for the convergence thresholds and what to do when they fail.

Other fit methods:
[`augment.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/augment.kb_fit.md),
[`coef.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/coef.kb_fit.md),
[`fitted.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/fitted.kb_fit.md),
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
glance(fit_weight_sim_nereo)
#> # A tibble: 1 × 10
#>       n     K nchains niters nthin ess_bulk ess_tail  rhat perc_divergent
#>   <int> <int>   <int>  <dbl> <int>    <dbl>    <dbl> <dbl>          <dbl>
#> 1   660     7       3    500     4     733.     589.  1.00              0
#> # ℹ 1 more variable: converged <lgl>
```
