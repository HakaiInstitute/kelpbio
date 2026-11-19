# Whether a fit has converged

Whether a model fit has converged, from the Rhat and effective sample
sizes of its parameters and its rate of divergent transitions.

## Usage

``` r
kb_converged(fit, ..., rhat = 1.01, ess = 100, max_perc_divergent = 0.2)
```

## Arguments

- fit:

  A `kb_fit` object.

- ...:

  These dots are for future extensions and must be empty.

- rhat:

  A number giving the maximum acceptable Rhat.

- ess:

  A number giving the minimum acceptable bulk and tail effective sample
  size per chain.

- max_perc_divergent:

  A number giving the maximum acceptable percentage of saved draws that
  ended in a divergent transition.

## Value

A flag: `TRUE` if all three conditions are met, otherwise `FALSE`.

## Assessing convergence

Three conditions must be met:

- every parameter's rank-normalized split Rhat below `rhat` (default
  1.01; Vehtari et al. 2021, Section 2);

- every parameter's bulk and tail effective sample size at least `ess`
  times the number of chains (default 100, which is 400 for four chains;
  Vehtari et al. 2021);

- the percentage of divergent transitions at or below
  `max_perc_divergent` (default 0.2% of saved draws). Set
  `max_perc_divergent = 0` to require none.

Rhat and the effective sample sizes are those of
[`posterior::rhat()`](https://mc-stan.org/posterior/reference/rhat.html),
[`posterior::ess_bulk()`](https://mc-stan.org/posterior/reference/ess_bulk.html),
and
[`posterior::ess_tail()`](https://mc-stan.org/posterior/reference/ess_tail.html),
reported for each parameter by `posterior::summarise_draws(fit)`.

## Resolving convergence failure

In order, try the following:

1.  For Rhat or effective sample sizes that fail their thresholds,
    increase `nthin` to run more iterations while saving the same number
    of draws or increase `niters` for more saved draws per chain.

2.  For divergent transitions, increase `adapt_delta` through the
    `control` argument of the `kb_fit_*()` functions (for example,
    `kb_fit_*(df, control = list(adapt_delta = 0.99))`; the default is
    0.95). A higher value makes the sampler take smaller steps, which
    reduces divergent transitions at the cost of a longer runtime.

3.  If either problem persists, check the data and the fit with
    [`pp_check()`](https://mc-stan.org/bayesplot/reference/pp_check.html)
    and
    [`kb_influence()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_influence.md):
    a unit mistake, outliers, or a poor fit can cause both.

## References

Vehtari, A., Gelman, A., Simpson, D., Carpenter, B., and Bürkner, P.-C.
(2021). Rank-normalization, folding, and localization: An improved
\\\widehat{R}\\ for assessing convergence of MCMC. *Bayesian Analysis*,
16(2), 667-718.
[doi:10.1214/20-BA1221](https://doi.org/10.1214/20-BA1221)

Stan Development Team. Runtime warnings and convergence problems.
<https://mc-stan.org/learn-stan/diagnostics-warnings.html>

## See also

Other diagnostics:
[`kb_influence()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_influence.md),
[`kb_plot_trace()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_trace.md),
[`kb_sensitivity()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_sensitivity.md),
[`loo.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/loo.kb_fit.md),
[`pp_check.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/pp_check.kb_fit.md)

## Examples

``` r
kb_converged(fit_weight_sim_nereo)
#> [1] TRUE

# Require no divergent transitions at all:
kb_converged(fit_weight_sim_nereo, max_perc_divergent = 0)
#> [1] TRUE
```
