# Pointwise log-likelihood

The pointwise log-likelihood of the observed data, suitable for
[`loo::loo()`](https://mc-stan.org/loo/reference/loo.html).

## Usage

``` r
# S3 method for class 'kb_fit'
log_lik(object, ...)
```

## Arguments

- object:

  A `kb_fit` object.

- ...:

  These dots are for future extensions and must be empty.

## Value

A draws-by-observations (`D x N`) matrix.

## Details

Each value is the log density of the response as recorded (for example
weight in kg, not log weight), so models of the same response can be
compared with
[`loo::loo_compare()`](https://mc-stan.org/loo/reference/loo_compare.html).

## See also

[`loo.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/loo.kb_fit.md)
for leave-one-out cross-validation of a fit.

Other fit methods:
[`augment.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/augment.kb_fit.md),
[`coef.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/coef.kb_fit.md),
[`fitted.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/fitted.kb_fit.md),
[`glance.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/glance.kb_fit.md),
[`kb_model_describe()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_model_describe.md),
[`kb_samples()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_samples.md),
[`kb_stancode()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_stancode.md),
[`posterior_epred.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_epred.kb_fit.md),
[`posterior_linpred.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_linpred.kb_fit.md),
[`posterior_predict.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_predict.kb_fit.md),
[`prior_summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/prior_summary.kb_fit.md),
[`residuals.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit.md),
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md),
[`tidy.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit.md)

## Examples

``` r
ll <- log_lik(fit_weight_sim_nereo)
dim(ll)
#> [1] 1500  660
```
