# Example Macrocystis cover calibration fit

A fit of
[`kb_fit_cover_calibration_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_cover_calibration_macro.md)
to the survey biomass from
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.md)
with
[fit_weight_sim_macro](https://hakaiinstitute.github.io/kelpbio/reference/fit_weight_sim_macro.md),
[data_size_census_sim_macro](https://hakaiinstitute.github.io/kelpbio/reference/data_size_census_sim_macro.md),
and
[data_survey_in_situ_sim_macro](https://hakaiinstitute.github.io/kelpbio/reference/data_survey_in_situ_sim_macro.md),
with fewer draws than the default, for exploring the fit methods without
running the sampler.

## Usage

``` r
fit_cover_calibration_sim_macro
```

## Format

An object of class
`c("kb_fit_cover_calibration_macro", "kb_fit_cover_calibration", "kb_fit")`.

## See also

[`kb_fit_cover_calibration_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_cover_calibration_macro.md)
and
[data_survey_in_situ_sim_macro](https://hakaiinstitute.github.io/kelpbio/reference/data_survey_in_situ_sim_macro.md).

Other example fits:
[`fit_carbon_sim_macro`](https://hakaiinstitute.github.io/kelpbio/reference/fit_carbon_sim_macro.md),
[`fit_carbon_sim_nereo`](https://hakaiinstitute.github.io/kelpbio/reference/fit_carbon_sim_nereo.md),
[`fit_cover_calibration_sim_nereo`](https://hakaiinstitute.github.io/kelpbio/reference/fit_cover_calibration_sim_nereo.md),
[`fit_nitrogen_sim_macro`](https://hakaiinstitute.github.io/kelpbio/reference/fit_nitrogen_sim_macro.md),
[`fit_nitrogen_sim_nereo`](https://hakaiinstitute.github.io/kelpbio/reference/fit_nitrogen_sim_nereo.md),
[`fit_size_sim_nereo`](https://hakaiinstitute.github.io/kelpbio/reference/fit_size_sim_nereo.md),
[`fit_weight_sim_macro`](https://hakaiinstitute.github.io/kelpbio/reference/fit_weight_sim_macro.md),
[`fit_weight_sim_nereo`](https://hakaiinstitute.github.io/kelpbio/reference/fit_weight_sim_nereo.md),
[`fit_weight_sim_nereo_power`](https://hakaiinstitute.github.io/kelpbio/reference/fit_weight_sim_nereo_power.md),
[`fit_wetdry_sim_macro`](https://hakaiinstitute.github.io/kelpbio/reference/fit_wetdry_sim_macro.md),
[`fit_wetdry_sim_nereo`](https://hakaiinstitute.github.io/kelpbio/reference/fit_wetdry_sim_nereo.md)
