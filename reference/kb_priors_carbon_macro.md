# Default priors for the Macrocystis carbon model

The default priors for the *Macrocystis pyrifera* carbon model, for the
`priors` argument of
[`kb_fit_carbon_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_carbon_macro.md).

## Usage

``` r
kb_priors_carbon_macro()
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
kb_priors_carbon_macro()
#> $intercept
#> normal(mean = -0.8, sd = 0.3)
#> 
#> $precision
#> exponential(rate = 0.001)
#> 
if (FALSE) { # interactive()
# Change one prior; the others keep their defaults:
kb_fit_carbon_macro(
  data_carbon_sim_macro,
  priors = list(intercept = kb_prior_normal(mean = -1, sd = 0.5))
)
}
```
