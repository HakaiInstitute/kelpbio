# Exponential Prior

Construct an Exponential prior object for use in
[`kb_priors_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_weight_nereo.md)
and the `priors` argument of the `kb_fit_*()` functions. Used for the
standard deviation (scale) hyperparameters.

## Usage

``` r
kb_prior_exponential(rate = 1)
```

## Arguments

- rate:

  A positive number giving the rate.

## Value

A `kb_prior_exponential` object.

## See also

Other priors:
[`kb_prior_normal()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_prior_normal.md),
[`kb_priors_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_weight_nereo.md)

## Examples

``` r
kb_prior_exponential(rate = 1)
#> exponential(rate = 1)
```
