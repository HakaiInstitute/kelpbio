# Posterior predictive draws

Draws from the posterior predictive distribution: replicate responses
(weights, plant sizes, dry:wet ratios, carbon or nitrogen fractions, or
in situ survey biomass) carrying both parameter uncertainty and
observation noise from the model's likelihood. With `new_data = NULL`
the replicates are at the observed data, as plotted by
[pp_check()](https://hakaiinstitute.github.io/kelpbio/reference/pp_check.kb_fit.md).

## Usage

``` r
# S3 method for class 'kb_fit'
posterior_predict(
  object,
  new_data = NULL,
  ...,
  new_levels = c("average", "sample"),
  representative_site = NULL
)
```

## Arguments

- object:

  A `kb_fit` object.

- new_data:

  A data frame with the fit's predictor column (and optional `site` and
  `year` columns; `canopy_area_m2`, `plot_area_m2`, and
  `canopy_tide_height_m` for a cover calibration fit), or `NULL` to
  predict at the observed data. `year` may be numeric or character:
  `2022` and `"2022"` match the same fitted year.

- ...:

  These dots are for future extensions and must be empty.

- new_levels:

  A string giving how uncertainty is estimated for a site or year not in
  the data used to fit the model, or when `new_data` has no `site` or
  `year` column. Sites and years in the model fit always use their own
  estimates. One of:

  - `"average"` (the default): the typical site or year. The site and
    year effects are set to 0, their mean, so the interval does not
    include among-site or among-year variation. Use it to describe an
    average site or year.

  - `"sample"`: a new effect for each new site or year, drawn from the
    estimated variation among sites or among years (the random-effect
    standard deviation). The point estimate is equivalent, but the
    interval is wider since it also includes that variation. Use it to
    get realistic uncertainty about a particular site or year that the
    model has no information on. The interval varies slightly between
    calls; use [`set.seed()`](https://rdrr.io/r/base/Random.html) to
    reproduce it.

- representative_site:

  A character vector of sites in the fit whose effects a new site adopts
  (averaged when several are named), or `NULL` (the default) to follow
  `new_levels`.

## Value

A draws-by-observations (`D x N`) matrix.

## Details

Site and year columns in `new_data` are handled as in
[`posterior_epred()`](https://mc-stan.org/rstantools/reference/posterior_epred.html).

The observation noise follows the likelihood of the fit's model (see
[`kb_model_describe()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_model_describe.md)).
A cover calibration fit with a presence part also draws whether each
survey holds plants, and a survey drawn without plants is 0. Each row's
spread includes the coefficient of variation of its survey biomass, from
`biomass_kg_m2` and `biomass_sd_kg_m2` columns or a `biomass_kg_m2`
column of draws, and the residual alone when `new_data` has neither.

Repeated calls return different draws; use
[`set.seed()`](https://rdrr.io/r/base/Random.html) to reproduce them.

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
[`prior_summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/prior_summary.kb_fit.md),
[`residuals.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit.md),
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md),
[`tidy.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit.md)

## Examples

``` r
set.seed(1)
pp <- posterior_predict(fit_weight_sim_nereo)
dim(pp)
#> [1] 1500  660
```
