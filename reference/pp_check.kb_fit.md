# Posterior predictive check

Plot the density of the observed data over the densities of replicate
datasets simulated from the fitted model, to check that the model
reproduces its data.

## Usage

``` r
# S3 method for class 'kb_fit'
pp_check(object, type = c("response", "residual"), ..., ndraws = 50L)
```

## Arguments

- object:

  A `kb_fit` object.

- type:

  A string, one of `"response"` (the recorded response) or `"residual"`
  (deviance residuals), specifying what to compare.

- ...:

  These dots are for future extensions and must be empty.

- ndraws:

  A whole number of replicate datasets to draw, at most the number of
  draws in the fit.

## Value

A `ggplot` object from
[`bayesplot::ppc_dens_overlay()`](https://mc-stan.org/bayesplot/reference/PPC-distributions.html).

## Details

Each replicate is simulated at the observed rows from one random
posterior draw, so set a seed with
[`set.seed()`](https://rdrr.io/r/base/Random.html) for a reproducible
plot. For a fit made with `prior_only = TRUE`, the plot is a prior
predictive check. See the [Advanced
article](https://hakaiinstitute.github.io/kelpbio/articles/advanced.html#posterior-predictive-check)
for how to read it.

## See also

[`posterior_predict()`](https://mc-stan.org/rstantools/reference/posterior_predict.html)
for the replicates themselves.

Other diagnostics:
[`kb_converged()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_converged.md),
[`kb_influence()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_influence.md),
[`kb_plot_trace()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_trace.md),
[`kb_sensitivity()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_sensitivity.md),
[`loo.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/loo.kb_fit.md)

## Examples

``` r
set.seed(1)
pp_check(fit_weight_sim_nereo)

pp_check(fit_size_sim_nereo, "residual", ndraws = 20)
```
