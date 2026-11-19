# Summarise a fit

A model fit's metadata paired with a per-term posterior summary table.

## Usage

``` r
# S3 method for class 'kb_fit'
summary(
  object,
  ...,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3,
  include_random_effects = FALSE,
  rhat = 1.01,
  ess = 100
)
```

## Arguments

- object:

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

- rhat:

  A number giving the maximum acceptable Rhat.

- ess:

  A number giving the minimum acceptable bulk and tail effective sample
  size per chain.

## Value

A `summary_kb_fit` object: a list of fit metadata and a `coefficients`
tibble with columns `term`, `estimate`, `lower`, `upper`, `rhat`,
`ess_bulk`, `ess_tail`, and `converged`.

## Details

The printed summary adds the sampler diagnostics (divergent transitions,
maximum treedepth, and E-BFMI). A term's `converged` uses the Rhat and
effective sample size thresholds of
[`kb_converged()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_converged.md);
the fit's verdict also covers the group-level deviations and divergent
transitions, so it can be `FALSE` when every term shown has converged.

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
[`tidy.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit.md)

## Examples

``` r
summary(fit_weight_sim_nereo)
#> <summary_kb_fit>
#> Model:     Weight (Nereocystis luetkeana)
#> Predictor: diameter_mm, reference 24.9 (geometric mean)
#> Data:      660 observations; groups: site (6), year (6), site:year (33)
#> Draws:     3 chains, 500 post-warmup draws each (thin = 4), 1500 total
#> Converged: TRUE
#> 
#> # A tibble: 7 × 8
#>   term           estimate    lower  upper  rhat ess_bulk ess_tail converged
#>   <chr>             <dbl>    <dbl>  <dbl> <dbl>    <dbl>    <dbl> <lgl>    
#> 1 intercept       -0.666  -0.918   -0.421  1        1399     1217 TRUE     
#> 2 diameter_power   2.92    2.71     3.13   1.00     1399     1345 TRUE     
#> 3 weight_floor     0.118   0.098    0.14   1.00     1395     1318 TRUE     
#> 4 sd_site          0.2     0.0406   0.521  1.00      733      589 TRUE     
#> 5 sd_year          0.0544  0.00298  0.254  1.00     1117     1457 TRUE     
#> 6 sd_site_year     0.261   0.179    0.372  1        1082     1460 TRUE     
#> 7 sd_residual      0.463   0.438    0.488  1        1348     1425 TRUE     
#> 
#> estimate: posterior point estimate; lower, upper: 95% compatibility limits.
#> rhat: potential scale reduction factor (1 at convergence).
#> ess_bulk, ess_tail: bulk and tail effective sample sizes.
#> converged: rhat below 1.01 and ess_bulk, ess_tail at least 100 per chain.
#> 0% divergent transitions; 0% max-treedepth; min E-BFMI 1.6.

# Looser thresholds, for a quick exploratory fit:
summary(fit_weight_sim_nereo, rhat = 1.05, ess = 50)
#> <summary_kb_fit>
#> Model:     Weight (Nereocystis luetkeana)
#> Predictor: diameter_mm, reference 24.9 (geometric mean)
#> Data:      660 observations; groups: site (6), year (6), site:year (33)
#> Draws:     3 chains, 500 post-warmup draws each (thin = 4), 1500 total
#> Converged: TRUE
#> 
#> # A tibble: 7 × 8
#>   term           estimate    lower  upper  rhat ess_bulk ess_tail converged
#>   <chr>             <dbl>    <dbl>  <dbl> <dbl>    <dbl>    <dbl> <lgl>    
#> 1 intercept       -0.666  -0.918   -0.421  1        1399     1217 TRUE     
#> 2 diameter_power   2.92    2.71     3.13   1.00     1399     1345 TRUE     
#> 3 weight_floor     0.118   0.098    0.14   1.00     1395     1318 TRUE     
#> 4 sd_site          0.2     0.0406   0.521  1.00      733      589 TRUE     
#> 5 sd_year          0.0544  0.00298  0.254  1.00     1117     1457 TRUE     
#> 6 sd_site_year     0.261   0.179    0.372  1        1082     1460 TRUE     
#> 7 sd_residual      0.463   0.438    0.488  1        1348     1425 TRUE     
#> 
#> estimate: posterior point estimate; lower, upper: 95% compatibility limits.
#> rhat: potential scale reduction factor (1 at convergence).
#> ess_bulk, ess_tail: bulk and tail effective sample sizes.
#> converged: rhat below 1.05 and ess_bulk, ess_tail at least 50 per chain.
#> 0% divergent transitions; 0% max-treedepth; min E-BFMI 1.6.
```
