# Describe a fitted model

Render the complete fitted model in scientific notation (the default) or
as a written description (`prose = TRUE`). The notation uses the
package's own parameter names (`intercept`, `sd_site`, ...), so every
symbol matches a row of
[`tidy()`](https://generics.r-lib.org/reference/tidy.html),
[`summary()`](https://rdrr.io/r/base/summary.html), and
[`coef()`](https://rdrr.io/r/stats/coef.html).

## Usage

``` r
kb_model_describe(fit, ..., prose = FALSE)
```

## Arguments

- fit:

  A `kb_fit` object.

- ...:

  These dots are for future extensions and must be empty.

- prose:

  A flag specifying whether to render a methods-section paragraph
  instead of the notation block.

## Value

The rendered lines, invisibly (a character vector). Called for the
printed description.

## Details

Priors, centring, and random effects are those of the fit; an effect not
fitted (such as the weight floor of a power-law fit) is omitted. Priors
marked `T[0, ]` are truncated at zero.

## See also

Other fit methods:
[`augment.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/augment.kb_fit.md),
[`coef.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/coef.kb_fit.md),
[`fitted.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/fitted.kb_fit.md),
[`glance.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/glance.kb_fit.md),
[`kb_samples()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_samples.md),
[`kb_stancode()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_stancode.md),
[`log_lik.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/log_lik.kb_fit.md),
[`posterior_epred.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_epred.kb_fit.md),
[`posterior_linpred.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_linpred.kb_fit.md),
[`posterior_predict.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_predict.kb_fit.md),
[`prior_summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/prior_summary.kb_fit.md),
[`residuals.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit.md),
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md),
[`tidy.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit.md)

## Examples

``` r
kb_model_describe(fit_weight_sim_nereo)
#> Weight allometry - Nereocystis luetkeana
#> Response: wet weight (kg); predictor: plant diameter (mm)
#> 
#> Likelihood
#>   log(weight_kg) ~ Normal(log(mu), sd_residual)
#>   mu = weight_floor + alpha * x^diameter_power
#>   log(alpha) = intercept
#>              + site_effect[site]
#>              + year_effect[year]
#>              + site_year_effect[site, year]
#>   x = diameter_mm / d0,  d0 = 24.9 mm  (geometric mean diameter)
#> 
#> Random effects
#>   site_effect[site]            ~ Normal(0, sd_site)       site effect on log(alpha)
#>   year_effect[year]            ~ Normal(0, sd_year)       year effect on log(alpha)
#>   site_year_effect[site, year] ~ Normal(0, sd_site_year)  site:year effect on log(alpha)
#> 
#> Priors
#>   intercept      ~ Normal(0, 2)
#>   diameter_power ~ Normal(2, 1) T[0, ]
#>   weight_floor   ~ Normal(0, 0.5) T[0, ]
#>   sd_residual    ~ Exponential(1)
#>   sd_site        ~ Exponential(1)
#>   sd_year        ~ Exponential(1)
#>   sd_site_year   ~ Exponential(1)
kb_model_describe(fit_weight_sim_macro, prose = TRUE)
#> Wet weight was modelled with a Gamma likelihood as an allometric function
#> of frond count. The expected weight was mu, where mu followed a power law
#> in frond count relative to the geometric mean frond count (4.48), in which
#> alpha is the expected weight at the geometric mean frond count and
#> fronds_slope the allometric exponent. The log of alpha varied by site, by
#> year, and by site:year. Regularising priors were placed on all parameters
#> (see the notation form for the prior arguments).
```
