# Exponential prior

Construct an Exponential prior object to replace an entry of a
`kb_priors_*()` list passed to the `priors` argument of the `kb_fit_*()`
functions. Used for positive parameters such as standard deviations,
dispersion, shape, and precision.

## Usage

``` r
kb_prior_exponential(rate = 1)
```

## Arguments

- rate:

  A positive number giving the rate.

## Value

A `kb_prior_exponential` object.

## See also

Other priors:
[`kb_prior_lognormal()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_prior_lognormal.md),
[`kb_prior_normal()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_prior_normal.md),
[`kb_priors_carbon_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_carbon_macro.md),
[`kb_priors_carbon_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_carbon_nereo.md),
[`kb_priors_cover_calibration_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_cover_calibration_macro.md),
[`kb_priors_cover_calibration_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_cover_calibration_nereo.md),
[`kb_priors_nitrogen_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_nitrogen_macro.md),
[`kb_priors_nitrogen_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_nitrogen_nereo.md),
[`kb_priors_size_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_size_nereo.md),
[`kb_priors_weight_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_weight_macro.md),
[`kb_priors_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_weight_nereo.md),
[`kb_priors_wetdry_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_wetdry_macro.md),
[`kb_priors_wetdry_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_wetdry_nereo.md)

## Examples

``` r
kb_prior_exponential(rate = 1)
#> exponential(rate = 1)
```
