# Default priors for the Macrocystis cover calibration model

The default priors for the *Macrocystis pyrifera* cover calibration
model, for the `priors` argument of
[`kb_fit_cover_calibration_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_cover_calibration_macro.md).

## Usage

``` r
kb_priors_cover_calibration_macro()
```

## Value

A named list of prior objects, one per parameter.

## Details

The `tide_height_slope` prior, the share of canopy lost per metre of
tide, is informative and from Timmer et al. (2024); the calibration data
do not inform it. The presence priors apply only when the data hold a
survey with no plants counted.

## Priors

Each entry is named after the parameter it sets, which
[`kb_model_describe()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_model_describe.md)
prints with the model. A list passed to `priors` replaces the entries it
names; the others keep their defaults. The prior family of each entry is
fixed; only its arguments can be changed.

## References

Timmer, B., Reshitnyk, L. Y., Hessing-Lewis, M., Juanes, F., Gendall,
L., and Costa, M. (2024). Capturing accurate kelp canopy extent:
integrating tides, currents, and species-level morphology in kelp remote
sensing. Frontiers in Environmental Science, 12, 1338483.
[doi:10.3389/fenvs.2024.1338483](https://doi.org/10.3389/fenvs.2024.1338483)

## See also

Other priors:
[`kb_prior_exponential()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_prior_exponential.md),
[`kb_prior_lognormal()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_prior_lognormal.md),
[`kb_prior_normal()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_prior_normal.md),
[`kb_priors_carbon_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_carbon_macro.md),
[`kb_priors_carbon_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_carbon_nereo.md),
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
kb_priors_cover_calibration_macro()
#> $cover_slope
#> lognormal(meanlog = 2, sdlog = 1)
#> 
#> $biomass_floor
#> normal(mean = 0.4, sd = 0.3)
#> 
#> $tide_height_slope
#> normal(mean = 0.227, sd = 0.03)
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
  fit_weight_sim_macro,
  data_size_census_sim_macro,
  data_survey_in_situ_sim_macro
)
kb_fit_cover_calibration_macro(
  biomass,
  priors = list(cover_slope = kb_prior_lognormal(meanlog = 2, sdlog = 0.5))
)
}
```
