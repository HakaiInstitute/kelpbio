# Fit a Macrocystis weight model

Fit an allometric weight model for *Macrocystis pyrifera* via Stan.

## Usage

``` r
kb_fit_weight_macro(
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

  A data frame of weight observations (see
  [`kb_check_data_weight_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_macro.md)
  for the required columns).

- priors:

  A named list of prior objects (see
  [`kb_priors_weight_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_weight_macro.md)),
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

A `kb_fit_weight_macro` object (a `kb_fit`).

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

## Site and year interaction

The site:year effect lets a site depart from the year-to-year pattern
shared by all sites. It is separable from the site and year effects only
when a site has data in more than one year and a year has more than one
site; otherwise the fit warns. Estimates for the site-years in the data
are then unaffected, but other predictions depend on the `sd_site_year`
prior (see
[`kb_sensitivity()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_sensitivity.md)).

## See also

Other fit functions:
[`kb_fit_carbon_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_carbon_macro.md),
[`kb_fit_carbon_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_carbon_nereo.md),
[`kb_fit_cover_calibration_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_cover_calibration_macro.md),
[`kb_fit_cover_calibration_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_cover_calibration_nereo.md),
[`kb_fit_nitrogen_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_nitrogen_macro.md),
[`kb_fit_nitrogen_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_nitrogen_nereo.md),
[`kb_fit_size_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_size_nereo.md),
[`kb_fit_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_weight_nereo.md),
[`kb_fit_wetdry_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_wetdry_macro.md),
[`kb_fit_wetdry_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_wetdry_nereo.md),
[`kb_progress()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_progress.md)

## Examples

``` r
# A pre-fit example model ships with the package:
tidy(fit_weight_sim_macro)
#> # A tibble: 6 × 4
#>   term         estimate  lower upper
#>   <chr>           <dbl>  <dbl> <dbl>
#> 1 intercept       1.37  0.997  1.74 
#> 2 fronds_slope    1.13  1.08   1.17 
#> 3 shape           4.44  3.98   4.92 
#> 4 sd_site         0.128 0.022  0.377
#> 5 sd_year         0.328 0.174  0.752
#> 6 sd_site_year    0.138 0.0758 0.227
if (FALSE) { # interactive()
fit <- kb_fit_weight_macro(data_weight_sim_macro)
tidy(fit)
}
```
