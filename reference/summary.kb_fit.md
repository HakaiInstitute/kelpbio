# Summarise a Model Fit

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
  include_random_effects = FALSE
)
```

## Arguments

- object:

  A `kb_fit` object.

- ...:

  Unused.

- conf_level:

  A number between 0 and 1 giving the compatibility-interval level.

- estimate:

  A function that reduces a numeric vector of posterior draws to a
  scalar point estimate (e.g. `median` or `mean`).

- sig_fig:

  A whole number of significant figures for summary output.

- include_random_effects:

  A flag specifying whether to include the group-level random-effect
  terms in the output.

## Value

A `summary_kb_fit` object: a list of fit metadata and a `coefficients`
tibble with columns `term`, `estimate`, `lower`, `upper`, `rhat`,
`ess_bulk`, and `ess_tail`.

## Details

The `print` method renders a header (likelihood family, fixed- and
random-effect structure, observation and group counts, sampler
configuration, and the convergence verdict), the coefficient table, and
a diagnostics footer. For a compact overview without the numeric table,
call [`print()`](https://rdrr.io/r/base/print.html) on the fit itself.

The coefficient table reports, per term:

- `estimate`:

  the posterior point estimate (the `estimate` function; the median by
  default).

- `lower`, `upper`:

  the `conf_level` equal-tailed compatibility limits.

- `rhat`:

  the potential scale reduction factor, comparing between- and
  within-chain variance; values near 1 indicate convergence.

- `ess_bulk`:

  the bulk effective sample size, governing the reliability of central
  posterior summaries.

- `ess_tail`:

  the tail effective sample size, governing the reliability of the
  interval limits.

Population-level coefficients and random-effect standard deviations are
always shown. The group-level deviations are included only when
`include_random_effects = TRUE`, following the convention that `summary`
reports the variance hyperparameters rather than the per-level effects
(the latter are the
[`tidy()`](https://generics.r-lib.org/reference/tidy.html) default).

## See also

Other generics:
[`augment.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/augment.kb_fit.md),
[`coef.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/coef.kb_fit.md),
[`converged.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/converged.kb_fit.md),
[`fitted.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/fitted.kb_fit_weight.md),
[`glance.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/glance.kb_fit.md),
[`kb_stancode()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_stancode.md),
[`log_lik.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/log_lik.kb_fit.md),
[`posterior_epred.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_epred.kb_fit_weight.md),
[`posterior_linpred.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_linpred.kb_fit_weight.md),
[`posterior_predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_predict.kb_fit_weight.md),
[`predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_weight.md),
[`prior_summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/prior_summary.kb_fit.md),
[`residuals.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit_weight.md),
[`samples()`](https://hakaiinstitute.github.io/kelpbio/reference/samples.md),
[`tidy.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit_weight.md)

## Examples

``` r
summary(fit_weight_sim_nereo)
#> <summary_kb_fit>
#> Model:     weight (nereocystis)
#> Family:    Student-t (df = 4); response log(weight)
#> Fixed:     intercept + linear + quadratic log(diameter/d0)
#> Random:    site (intercept, slope); site:year (intercept)
#> Centered:  log-diameter at d0 = 40.1 (geometric mean of diameter)
#> Data:      234 observations; groups: site (10), site:year (39)
#> Draws:     2 chains, 400 post-warmup draws each (thin = 1), 800 total
#> Converged: TRUE
#> 
#> # A tibble: 7 × 7
#>   term          estimate   lower  upper  rhat ess_bulk ess_tail
#>   <chr>            <dbl>   <dbl>  <dbl> <dbl>    <dbl>    <dbl>
#> 1 bWeight        -1.47   -1.66   -1.24  1.00       249      331
#> 2 bDiameter       2.5     2.28    2.74  1.03       218      444
#> 3 bDiameter2      0.0749 -0.156   0.313 0.998     1176      739
#> 4 sSite           0.27    0.176   0.459 1.00       226      501
#> 5 sSiteDiameter   0.313   0.169   0.62  1.02       201      380
#> 6 sSiteYear       0.0962  0.0521  0.149 1.01       222      356
#> 7 sWeight         0.161   0.141   0.185 1.00       538      561
#> 
#> estimate: posterior point estimate; lower, upper: 95% compatibility limits.
#> rhat: potential scale reduction factor (1 at convergence).
#> ess_bulk, ess_tail: bulk and tail effective sample sizes.
#> 0 divergent transitions.
```
