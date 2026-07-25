# Default Priors for the Nereocystis Weight Model

The default prior list for the *Nereocystis luetkeana* allometric weight
model. Edit individual entries and pass the list to the `priors`
argument of
[`kb_fit_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_weight_nereo.md)
to override defaults; unmodified entries keep their defaults.

## Usage

``` r
kb_priors_weight_nereo()
```

## Value

A named list of prior objects with entries `intercept`, `diameter`,
`diameter2`, `sd_site`, `sd_site_diameter`, `sd_site_year`, and
`sd_residual`.

## Details

The prior family of each entry is fixed (the population-level terms are
Normal, the standard deviations are Exponential); only the
hyperparameters can be changed.

## See also

Other priors:
[`kb_prior_exponential()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_prior_exponential.md),
[`kb_prior_normal()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_prior_normal.md)

## Examples

``` r
priors <- kb_priors_weight_nereo()
priors$sd_site <- kb_prior_exponential(2)
```
