# Prior Summary

The resolved prior objects used to fit the model.

## Usage

``` r
# S3 method for class 'kb_fit'
prior_summary(object, ...)
```

## Arguments

- object:

  A `kb_fit` object.

- ...:

  Unused.

## Value

The named list of prior objects (see
[`kb_priors_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_weight_nereo.md)).

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
[`residuals.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit_weight.md),
[`samples()`](https://hakaiinstitute.github.io/kelpbio/reference/samples.md),
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md),
[`tidy.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit_weight.md)

## Examples

``` r
prior_summary(fit_weight_sim_nereo)
#> $intercept
#> normal(mean = 0, sd = 2)
#> 
#> $diameter
#> normal(mean = 2, sd = 1)
#> 
#> $diameter2
#> normal(mean = 0, sd = 0.5)
#> 
#> $sd_site
#> exponential(rate = 1)
#> 
#> $sd_site_diameter
#> exponential(rate = 1)
#> 
#> $sd_site_year
#> exponential(rate = 1)
#> 
#> $sd_residual
#> exponential(rate = 1)
#> 
```
