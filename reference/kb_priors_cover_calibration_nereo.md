# Default priors for the Nereocystis cover calibration model

The default priors for the *Nereocystis luetkeana* cover calibration
model, for the `priors` argument of
[`kb_fit_cover_calibration_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_cover_calibration_nereo.md).

## Usage

``` r
kb_priors_cover_calibration_nereo()
```

## Value

A named list of prior objects, one per parameter.

## Details

The presence priors apply only when the data hold a survey with no
plants counted.

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
[`kb_priors_nitrogen_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_nitrogen_macro.md),
[`kb_priors_nitrogen_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_nitrogen_nereo.md),
[`kb_priors_size_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_size_nereo.md),
[`kb_priors_weight_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_weight_macro.md),
[`kb_priors_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_weight_nereo.md),
[`kb_priors_wetdry_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_wetdry_macro.md),
[`kb_priors_wetdry_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_wetdry_nereo.md)

## Examples

``` r
kb_priors_cover_calibration_nereo()
#> $cover_slope
#> lognormal(meanlog = 2, sdlog = 1)
#> 
#> $biomass_floor
#> normal(mean = 0, sd = 0.2)
#> 
#> $tide_height_slope
#> normal(mean = 0.276, sd = 0.04)
#> 
#> $cv_residual
#> exponential(rate = 1)
#> 
#> $presence_intercept
#> normal(mean = 0, sd = 2)
#> 
#> $presence_cover_slope
#> normal(mean = 0, sd = 20)
#> 
#> $sd_site
#> exponential(rate = 1)
#> 
#> $sd_year
#> exponential(rate = 1)
#> 
if (FALSE) { # interactive()
# Change one prior; the others keep their defaults:
biomass <- kb_predict_biomass_in_situ(
  fit_weight_sim_nereo,
  fit_size_sim_nereo,
  data_survey_in_situ_sim_nereo
)
kb_fit_cover_calibration_nereo(
  biomass,
  priors = list(cover_slope = kb_prior_lognormal(meanlog = 2, sdlog = 0.5))
)
}
```
