# Normal Prior

Construct a Normal prior object for use in
[`kb_priors_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_weight_nereo.md)
and the `priors` argument of the `kb_fit_*()` functions.

## Usage

``` r
kb_prior_normal(mean = 0, sd = 1)
```

## Arguments

- mean:

  A number giving the mean.

- sd:

  A positive number giving the standard deviation.

## Value

A `kb_prior_normal` object.

## See also

Other priors:
[`kb_prior_exponential()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_prior_exponential.md),
[`kb_priors_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_weight_nereo.md)

## Examples

``` r
kb_prior_normal(mean = 0, sd = 2)
#> normal(mean = 0, sd = 2)
```
