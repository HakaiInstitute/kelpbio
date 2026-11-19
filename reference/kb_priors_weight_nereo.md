# Default priors for the Nereocystis weight model

The default priors for the *Nereocystis luetkeana* weight model, for the
`priors` argument of
[`kb_fit_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_weight_nereo.md).
`weight_floor` applies only to `form = "packard_floor"`.

## Usage

``` r
kb_priors_weight_nereo()
```

## Value

A named list of prior objects, one per parameter.

## Priors

Each entry is named after the parameter it sets, which
[`kb_model_describe()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_model_describe.md)
prints with the model. A list passed to `priors` replaces the entries it
names; the others keep their defaults. The prior family of each entry is
fixed; only its arguments can be changed.

## See also

Other priors:
[`kb_prior_exponential()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_prior_exponential.md),
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
[`kb_priors_wetdry_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_wetdry_macro.md),
[`kb_priors_wetdry_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_wetdry_nereo.md)

## Examples

``` r
kb_priors_weight_nereo()
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
if (FALSE) { # interactive()
# Change one prior; the others keep their defaults:
kb_fit_weight_nereo(
  data_weight_sim_nereo,
  priors = list(sd_site = kb_prior_exponential(rate = 2))
)
}
```
