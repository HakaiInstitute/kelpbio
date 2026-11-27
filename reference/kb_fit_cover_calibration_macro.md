# Fit a Macrocystis cover calibration model

Fit a calibration of in situ survey biomass on plot cover for
*Macrocystis pyrifera* via Stan.

## Usage

``` r
kb_fit_cover_calibration_macro(
  data,
  priors = NULL,
  ...,
  prior_only = FALSE,
  chains = 4L,
  niters = 1000L,
  nthin = 1L,
  cores = NULL,
  seed = NULL,
  progress = c("bar", "verbose", "none"),
  progress_dir = NULL
)
```

## Arguments

- data:

  A data frame of in situ survey biomass with plot cover, one row per
  survey (see
  [`kb_check_data_cover_calibration_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_cover_calibration_macro.md)
  for the columns).

- priors:

  A named list of prior objects (see
  [`kb_priors_cover_calibration_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_cover_calibration_macro.md)),
  or `NULL` to use the defaults. Entries not supplied keep their
  defaults.

- ...:

  Additional arguments passed to
  [`rstan::sampling()`](https://mc-stan.org/rstan/reference/stanmodel-method-sampling.html),
  such as `control`.

- prior_only:

  A flag specifying whether to sample from the priors only, for prior
  predictive checks.

- chains:

  A whole number of MCMC chains.

- niters:

  A whole number of saved post-warmup draws per chain (minimum 2; number
  of warmup draws defaults to match).

- nthin:

  A whole number of the thinning interval.

- cores:

  A whole number of cores used to sample chains in parallel, or `NULL`
  to use `getOption("mc.cores")` if set or `chains` if not. Capped at
  the number of available cores.

- seed:

  A whole number passed to
  [`rstan::sampling()`](https://mc-stan.org/rstan/reference/stanmodel-method-sampling.html)
  to make the fit reproducible, or `NULL` (the default, which uses a
  random seed). A preceding
  [`set.seed()`](https://rdrr.io/r/base/Random.html) also makes the fit
  reproducible.

- progress:

  A string, one of `"bar"` (the default, a console progress bar),
  `"verbose"` (rstan's per-iteration output and diagnostic warnings), or
  `"none"` (silent).

- progress_dir:

  A string giving an existing directory in which to record progress for
  [`kb_progress()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_progress.md),
  or `NULL` (the default) to record none.

## Value

A `kb_fit_cover_calibration_macro` object (a `kb_fit`). Its `data` holds
the fitted surveys, with `biomass_kg_m2` the mean of each survey's draws
and `biomass_sd_kg_m2` their SD.

## Details

`data` is the output of
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.md)
with its defaults. Surveys without plot cover are not fitted, and a
message gives their number. The model is described in
[Methods](https://hakaiinstitute.github.io/kelpbio/articles/methods.html#cover-calibration).

The fit warns when a survey with canopy has a tide height above 2 m, and
when every survey with no plants has a plot cover at or below that of
every survey with plants, since `presence_cover_slope` is then informed
only by its prior. If canopy is already tide-corrected, set
`canopy_tide_height_m = 0`.

## Model

[`kb_model_describe()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_model_describe.md)
prints the fitted model, with its priors, in notation or as a written
description. The [Methods
article](https://hakaiinstitute.github.io/kelpbio/articles/methods.html)
describes each model and its assumptions.

## Sampling

Chains run in parallel by default, one core per chain, capped at the
cores available. `cores` sets the number of cores; when it is `NULL`,
`getOption("mc.cores")` is used if set. Set `cores = 1` (or
`options(mc.cores = 1)`) where cores are shared or limited, or inside
another parallel process.

The sampler runs with `adapt_delta = 0.95` by default, which reduces
divergences at the cost of slightly longer runtime. Override it, or set
any other sampler control, by passing a `control` list through `...`,
for example `control = list(adapt_delta = 0.99)`; only the entries
supplied are changed. See the `control` argument of
[`rstan::stan()`](https://mc-stan.org/rstan/reference/stan.html) for the
full set of entries.

By default, each of 4 chains runs 1000 warmup iterations and then saves
1000 draws with no thinning, giving 4000 draws in total. These match the
defaults of
[`rstan::stan()`](https://mc-stan.org/rstan/reference/stan.html) and
Stan's general recommendations.

Check convergence with
[`kb_converged()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_converged.md),
[`glance()`](https://generics.r-lib.org/reference/glance.html), or
[`summary()`](https://rdrr.io/r/base/summary.html).

## See also

Other fit functions:
[`kb_fit_carbon_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_carbon_macro.md),
[`kb_fit_carbon_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_carbon_nereo.md),
[`kb_fit_cover_calibration_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_cover_calibration_nereo.md),
[`kb_fit_nitrogen_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_nitrogen_macro.md),
[`kb_fit_nitrogen_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_nitrogen_nereo.md),
[`kb_fit_size_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_size_nereo.md),
[`kb_fit_weight_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_weight_macro.md),
[`kb_fit_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_weight_nereo.md),
[`kb_fit_wetdry_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_wetdry_macro.md),
[`kb_fit_wetdry_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_wetdry_nereo.md),
[`kb_progress()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_progress.md)

## Examples

``` r
# A pre-fit example model is included with the package:
tidy(fit_cover_calibration_sim_macro)
#> # A tibble: 6 × 4
#>   term              estimate   lower  upper
#>   <chr>                <dbl>   <dbl>  <dbl>
#> 1 cover_slope         8.55   6.92    10.3  
#> 2 biomass_floor       0.328  0.116    0.601
#> 3 tide_height_slope   0.233  0.18     0.287
#> 4 cv_residual         0.22   0.161    0.293
#> 5 sd_site             0.0753 0.00323  0.26 
#> 6 sd_year             0.0632 0.00281  0.281
if (FALSE) { # interactive()
biomass <- kb_predict_biomass_in_situ(
  fit_weight_sim_macro,
  data_size_census_sim_macro,
  data_survey_in_situ_sim_macro
)
fit <- kb_fit_cover_calibration_macro(biomass)
tidy(fit)
}
```
