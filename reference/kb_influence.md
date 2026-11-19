# Influential observations

Identify the observations that most influence a fit and those it
predicts poorly, by Pareto-smoothed importance-sampling leave-one-out
cross-validation (PSIS-LOO; Vehtari et al. 2017).

## Usage

``` r
kb_influence(fit, ..., threshold = NULL)
```

## Arguments

- fit:

  A `kb_fit` object.

- ...:

  These dots are for future extensions and must be empty.

- threshold:

  A number greater than 0: an observation with `pareto_k` above it is
  influential. `NULL` (the default) uses the threshold of
  [`loo::loo()`](https://mc-stan.org/loo/reference/loo.html),
  `min(1 - 1 / log10(S), 0.7)` for `S` posterior draws.

## Value

The fitted data as a tibble, one row per observation, with added columns
`elpd_loo`, `pareto_k`, and `influential`.

## Details

`pareto_k` measures how much the fit changes when an observation is left
out, and `elpd_loo` how well the observation is predicted by a fit
without it; see the [Advanced
article](https://hakaiinstitute.github.io/kelpbio/articles/advanced.html#influential-observations)
for details.

## References

Vehtari, A., Gelman, A., and Gabry, J. (2017). Practical Bayesian model
evaluation using leave-one-out cross-validation and WAIC. Statistics and
Computing, 27, 1413-1432.

## See also

[`loo.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/loo.kb_fit.md)
for the full PSIS-LOO result.

Other diagnostics:
[`kb_converged()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_converged.md),
[`kb_plot_trace()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_trace.md),
[`kb_sensitivity()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_sensitivity.md),
[`loo.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/loo.kb_fit.md),
[`pp_check.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/pp_check.kb_fit.md)

## Examples

``` r
influence <- kb_influence(fit_weight_sim_nereo)
influence[influence$influential, ]
#> # A tibble: 0 × 7
#> # ℹ 7 variables: diameter_mm <dbl>, weight_kg <dbl>, site <fct>, year <fct>,
#> #   elpd_loo <dbl>, pareto_k <dbl>, influential <lgl>
```
