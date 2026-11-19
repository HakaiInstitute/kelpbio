# Posterior draws

The posterior draws of the estimated parameters from a fitted model.

## Usage

``` r
kb_samples(fit, ...)

# S3 method for class 'kb_fit'
as_draws(x, ...)

# S3 method for class 'kb_fit'
nchains(x, ...)

# S3 method for class 'kb_fit'
niterations(x, ...)

# S3 method for class 'kb_fit'
ndraws(x, ...)

# S3 method for class 'kb_fit'
nvariables(x, ...)

# S3 method for class 'kb_fit'
variables(x, ...)
```

## Arguments

- fit:

  A `kb_fit` object.

- ...:

  These dots are for future extensions and must be empty.

- x:

  A `kb_fit` object.

## Value

A `posterior` `draws_rvars` object.

## Details

The `posterior` functions, such as `as_draws_df()`, `summarise_draws()`,
[`nchains()`](https://mc-stan.org/posterior/reference/draws-index.html),
[`ndraws()`](https://mc-stan.org/posterior/reference/draws-index.html),
and
[`variables()`](https://mc-stan.org/posterior/reference/variables.html),
also accept a fit. `summarise_draws(fit)` reports each parameter's Rhat
and effective sample size.

## See also

Other fit methods:
[`augment.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/augment.kb_fit.md),
[`coef.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/coef.kb_fit.md),
[`fitted.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/fitted.kb_fit.md),
[`glance.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/glance.kb_fit.md),
[`kb_model_describe()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_model_describe.md),
[`kb_stancode()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_stancode.md),
[`log_lik.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/log_lik.kb_fit.md),
[`posterior_epred.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_epred.kb_fit.md),
[`posterior_linpred.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_linpred.kb_fit.md),
[`posterior_predict.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_predict.kb_fit.md),
[`prior_summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/prior_summary.kb_fit.md),
[`residuals.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit.md),
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md),
[`tidy.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit.md)

## Examples

``` r
kb_samples(fit_weight_sim_nereo)
#> # A draws_rvars: 500 iterations, 3 chains, and 10 variables
#> $intercept: rvar<500,3>[1] mean ± sd:
#> [1] -0.67 ± 0.13 
#> 
#> $diameter_power: rvar<500,3>[1] mean ± sd:
#> [1] 2.9 ± 0.11 
#> 
#> $weight_floor: rvar<500,3>[1] mean ± sd:
#> [1] 0.12 ± 0.011 
#> 
#> $sd_site: rvar<500,3>[1] mean ± sd:
#> [1] 0.22 ± 0.12 
#> 
#> $sd_year: rvar<500,3>[1] mean ± sd:
#> [1] 0.072 ± 0.067 
#> 
#> $sd_site_year: rvar<500,3>[1] mean ± sd:
#> [1] 0.26 ± 0.049 
#> 
#> $sd_residual: rvar<500,3>[1] mean ± sd:
#> [1] 0.46 ± 0.013 
#> 
#> $site_effect: rvar<500,3>[6] mean ± sd:
#>      otter_cove       gull_rock       cedar_bay      heron_reef      eagle_spit 
#> -0.0380 ± 0.14  -0.1777 ± 0.15   0.2504 ± 0.16   0.0252 ± 0.14  -0.0795 ± 0.14  
#>       fog_islet 
#>  0.0079 ± 0.14  
#> 
#> # ... with 2 more variables
posterior::summarise_draws(fit_weight_sim_nereo)
#> # A tibble: 55 × 10
#>    variable           mean  median     sd    mad       q5     q95  rhat ess_bulk
#>    <chr>             <dbl>   <dbl>  <dbl>  <dbl>    <dbl>   <dbl> <dbl>    <dbl>
#>  1 intercept       -0.669  -0.666  0.126  0.115  -0.863   -0.470  1.00     1399.
#>  2 diameter_power   2.92    2.92   0.108  0.111   2.75     3.10   1.00     1399.
#>  3 weight_floor     0.118   0.118  0.0109 0.0109  0.101    0.137  1.00     1395.
#>  4 sd_site          0.220   0.200  0.121  0.102   0.0604   0.439  1.00      733.
#>  5 sd_year          0.0721  0.0544 0.0675 0.0514  0.00539  0.206  1.00     1117.
#>  6 sd_site_year     0.264   0.261  0.0490 0.0487  0.191    0.353  1.00     1082.
#>  7 sd_residual      0.463   0.463  0.0130 0.0131  0.442    0.484  1.00     1348.
#>  8 site_effect[ot… -0.0380 -0.0295 0.137  0.117  -0.259    0.177  1.000    1365.
#>  9 site_effect[gu… -0.178  -0.163  0.148  0.143  -0.434    0.0285 1.000    1093.
#> 10 site_effect[ce…  0.250   0.243  0.160  0.159   0.00327  0.527  1.000     778.
#> # ℹ 45 more rows
#> # ℹ 1 more variable: ess_tail <dbl>
```
