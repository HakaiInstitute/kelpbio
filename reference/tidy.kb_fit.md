# Summaries of the model terms

Posterior summaries of the model terms.

## Usage

``` r
# S3 method for class 'kb_fit'
tidy(
  x,
  ...,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3,
  include_random_effects = FALSE
)
```

## Arguments

- x:

  A `kb_fit` object.

- ...:

  These dots are for future extensions and must be empty.

- conf_level:

  A number greater than 0 and less than 1 giving the
  compatibility-interval level.

- estimate:

  A function that reduces a numeric vector of posterior draws to a
  single estimate, such as `median` or `mean`.

- sig_fig:

  A whole number of significant figures for summary output.

- include_random_effects:

  A flag specifying whether to include the group-level random-effect
  terms in the output.

## Value

A tibble with one row per term and columns `term`, `estimate`, `lower`,
`upper`.

## Details

The terms are the population-level effects and the random-effect
standard deviations. With `include_random_effects = TRUE`, the
group-level deviations are added, each named by its level, as in
`site_effect[otter_cove]` or `site_year_effect[otter_cove,2020]`.

## See also

Other fit methods:
[`augment.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/augment.kb_fit.md),
[`coef.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/coef.kb_fit.md),
[`fitted.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/fitted.kb_fit.md),
[`glance.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/glance.kb_fit.md),
[`kb_model_describe()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_model_describe.md),
[`kb_samples()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_samples.md),
[`kb_stancode()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_stancode.md),
[`log_lik.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/log_lik.kb_fit.md),
[`posterior_epred.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_epred.kb_fit.md),
[`posterior_linpred.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_linpred.kb_fit.md),
[`posterior_predict.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_predict.kb_fit.md),
[`prior_summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/prior_summary.kb_fit.md),
[`residuals.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit.md),
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md)

## Examples

``` r
tidy(fit_weight_sim_nereo)
#> # A tibble: 7 × 4
#>   term           estimate    lower  upper
#>   <chr>             <dbl>    <dbl>  <dbl>
#> 1 intercept       -0.666  -0.918   -0.421
#> 2 diameter_power   2.92    2.71     3.13 
#> 3 weight_floor     0.118   0.098    0.14 
#> 4 sd_site          0.2     0.0406   0.521
#> 5 sd_year          0.0544  0.00298  0.254
#> 6 sd_site_year     0.261   0.179    0.372
#> 7 sd_residual      0.463   0.438    0.488
```
