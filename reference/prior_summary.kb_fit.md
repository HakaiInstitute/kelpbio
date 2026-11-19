# Priors of a fit

The priors used to fit the model.

## Usage

``` r
# S3 method for class 'kb_fit'
prior_summary(object, ...)
```

## Arguments

- object:

  A `kb_fit` object.

- ...:

  These dots are for future extensions and must be empty.

## Value

The named list of prior objects (see the model's `kb_priors_*()`
function).

## See also

Other fit methods:
[`augment.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/augment.kb_fit.md),
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
[`residuals.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit.md),
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md),
[`tidy.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit.md)

## Examples

``` r
prior_summary(fit_weight_sim_nereo)
#> $intercept
#> normal(mean = 0, sd = 2)
#> 
#> $diameter_power
#> normal(mean = 2, sd = 1)
#> 
#> $weight_floor
#> normal(mean = 0, sd = 0.5)
#> 
#> $sd_site
#> exponential(rate = 1)
#> 
#> $sd_year
#> exponential(rate = 1)
#> 
#> $sd_site_year
#> exponential(rate = 1)
#> 
#> $sd_residual
#> exponential(rate = 1)
#> 
```
