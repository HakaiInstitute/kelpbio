# Trace plot

Plot the posterior draws of each term against iteration, one panel per
term and one line per chain, to check that the chains have mixed.

## Usage

``` r
kb_plot_trace(fit, ..., ncol = 2L)
```

## Arguments

- fit:

  A `kb_fit` object.

- ...:

  These dots are for future extensions and must be empty.

- ncol:

  A whole number of panel columns.

## Value

A `ggplot` object. It sets no theme, so it takes the active one
([`ggplot2::theme_get()`](https://ggplot2.tidyverse.org/reference/get_theme.html));
add a theme with `+` to change it.

## Details

The terms are those reported by
[`tidy()`](https://generics.r-lib.org/reference/tidy.html): the
population-level coefficients and the random-effect standard deviations.
Chains that have converged resemble a "fuzzy caterpillar", overlapping
and wandering around a common value with no trend. A chain stuck apart
from the others, or slowly drifting, indicates a convergence problem,
which
[`kb_converged()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_converged.md),
[`glance()`](https://generics.r-lib.org/reference/glance.html), and
[summary()](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md)
also report.

## See also

Other diagnostics:
[`kb_converged()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_converged.md),
[`kb_influence()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_influence.md),
[`kb_sensitivity()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_sensitivity.md),
[`loo.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/loo.kb_fit.md),
[`pp_check.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/pp_check.kb_fit.md)

## Examples

``` r
kb_plot_trace(fit_weight_sim_nereo)
```
