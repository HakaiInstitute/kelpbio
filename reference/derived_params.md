# Parameter Descriptions for the Derived Verbs

Parameter descriptions shared by
[`kb_predict_mean_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_mean_weight.md),
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.md),
and
[`kb_predict_biomass_canopy()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_canopy.md).

## Arguments

- weight:

  A `kb_fit_weight` object.

- wetdry:

  A `kb_fit_wetdry` object, required for dry, carbon, and nitrogen
  biomass, or `NULL`. All fits must be of the same species and have the
  same number of draws.

- carbon:

  A `kb_fit_carbon` object, required for carbon biomass, or `NULL`.

- nitrogen:

  A `kb_fit_nitrogen` object, required for nitrogen biomass, or `NULL`.

- measure:

  A string, one of `"wet"`, `"dry"`, `"carbon"`, or `"nitrogen"`, giving
  the type of biomass to predict.

- n_plants:

  A whole number of sizes averaged per draw to compute the mean plant
  weight; larger values are more precise and slower to compute.

- progress:

  A string, one of `"bar"` (the default, a console progress bar) or
  `"none"` (silent).

- new_levels:

  A string giving how uncertainty is shown for a site or year not in the
  fit. Sites and years in the fit always use their own estimates. One
  of:

  - `"sample"` (the default): a new effect for each new site or year,
    drawn from the estimated variation among sites or among years (the
    random-effect standard deviation). The point estimate is equivalent,
    but the interval is wider since it also includes that variation. Use
    it to get realistic uncertainty about a particular site or year that
    the model has no information on. The interval varies slightly
    between calls; use
    [`set.seed()`](https://rdrr.io/r/base/Random.html) to reproduce it.

  - `"average"`: the typical site or year. The site and year effects are
    set to 0, their mean, so the interval does not include among-site or
    among-year variation. Use it to describe an average site or year.

- pool_by:

  A character vector naming character or factor columns to group the
  rows by, such as `c("site", "year")`, `character(0)` to pool all rows,
  or `NULL` (the default) for one row per input row. On each draw, the
  biomass of a group is the sum of its rows' biomass (kg). For another
  summary, such as an unweighted mean of rows, summarise the draws
  column, for example with
  [`posterior::rvar_mean()`](https://mc-stan.org/posterior/reference/rvar-summaries-within-draws.html).
