# Draws of the linear predictor

Draws of the linear predictor on the link scale (or, with
`transform = TRUE`, on the response scale).

## Usage

``` r
# S3 method for class 'kb_fit'
posterior_linpred(
  object,
  transform = FALSE,
  new_data = NULL,
  ...,
  new_levels = c("average", "sample"),
  representative_site = NULL
)
```

## Arguments

- object:

  A `kb_fit` object.

- transform:

  A flag specifying whether to apply the inverse of the model's link
  function (see
  [`kb_model_describe()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_model_describe.md)).

- new_data:

  A data frame with the fit's predictor column (and optional `site` and
  `year` columns), or `NULL` for the observed data. `year` may be
  numeric or character: `2022` and `"2022"` match the same fitted year.

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
[`posterior_epred()`](https://mc-stan.org/rstantools/reference/posterior_epred.html);
with `new_data = NULL` the observed data is used, with its sites and
years.

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
[`posterior_predict.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_predict.kb_fit.md),
[`prior_summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/prior_summary.kb_fit.md),
[`residuals.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit.md),
[`summary.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md),
[`tidy.kb_fit()`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit.md)

## Examples

``` r
lp <- posterior_linpred(fit_weight_sim_nereo)
dim(lp)
#> [1] 1500  660
```
