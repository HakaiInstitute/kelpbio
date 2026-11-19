# Lognormal prior

Construct a lognormal prior object to replace an entry of a
`kb_priors_*()` list passed to the `priors` argument of the `kb_fit_*()`
functions. Used for positive parameters whose plausible values span
orders of magnitude.

## Usage

``` r
kb_prior_lognormal(meanlog = 0, sdlog = 1)
```

## Arguments

- meanlog:

  A number giving the mean of the log of the parameter.

- sdlog:

  A positive number giving the standard deviation of the log of the
  parameter.

## Value

A `kb_prior_lognormal` object.

## Details

`meanlog` and `sdlog` are on the log scale: a lognormal prior with
`meanlog` and `sdlog` is a Normal prior with that mean and standard
deviation on the log of the parameter, so its median is `exp(meanlog)`.

## See also

Other priors:
[`kb_prior_exponential()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_prior_exponential.md),
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
kb_prior_lognormal(meanlog = 2, sdlog = 1)
#> lognormal(meanlog = 2, sdlog = 1)
```
