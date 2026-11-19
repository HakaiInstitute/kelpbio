# Prior sensitivity

Assess how much each parameter's posterior depends on its prior and on
the data, by power-scaling (Kallioinen et al. 2024).

## Usage

``` r
kb_sensitivity(fit, ..., prior_threshold = 0.1, likelihood_threshold = 0.05)
```

## Arguments

- fit:

  A `kb_fit` object.

- ...:

  These dots are for future extensions and must be empty.

- prior_threshold:

  A number greater than 0: a parameter with `prior_cjs` below it has a
  weak prior.

- likelihood_threshold:

  A number greater than 0: a parameter with `likelihood_cjs` at or above
  it has strong data.

## Value

A tibble with one row per parameter that has a prior and columns `term`
(the parameter, which is also its prior entry), `prior_cjs` and
`likelihood_cjs` (the sensitivity to the prior and to the likelihood),
`weak_prior`, `strong_data`, and `informative_prior` (whether the prior
is informative by design).

## Details

A parameter is driven by the data when it has both `weak_prior` and
`strong_data`; see the [Advanced
article](https://hakaiinstitute.github.io/kelpbio/articles/advanced.html#prior-sensitivity)
for the other cases. The cover calibration's `tide_height_slope` has an
informative prior by design, so `informative_prior` marks it. Requires
the priorsense package.

## References

Kallioinen, N., Paananen, T., Bürkner, P.-C., and Vehtari, A. (2024).
Detecting and diagnosing prior and likelihood sensitivity with
power-scaling. Statistics and Computing, 34, 57.

## See also

Other diagnostics:
[`kb_converged()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_converged.md),
[`kb_influence()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_influence.md),
[`kb_plot_trace()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_trace.md),
[`loo.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/loo.kb_fit.md),
[`pp_check.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/pp_check.kb_fit.md)

## Examples

``` r
kb_sensitivity(fit_weight_sim_nereo)
#> # A tibble: 7 × 6
#>   term         prior_cjs likelihood_cjs weak_prior strong_data informative_prior
#>   <chr>            <dbl>          <dbl> <lgl>      <lgl>       <lgl>            
#> 1 intercept      0.0105          0.0352 TRUE       FALSE       FALSE            
#> 2 diameter_po…   0.0223          0.0944 TRUE       TRUE        FALSE            
#> 3 weight_floor   0.0164          0.143  TRUE       TRUE        FALSE            
#> 4 sd_site        0.0365          0.0665 TRUE       TRUE        FALSE            
#> 5 sd_year        0.0300          0.0649 TRUE       TRUE        FALSE            
#> 6 sd_site_year   0.00918         0.151  TRUE       TRUE        FALSE            
#> 7 sd_residual    0.00181         0.224  TRUE       TRUE        FALSE            
```
