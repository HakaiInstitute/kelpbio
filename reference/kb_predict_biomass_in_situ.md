# Predict the biomass of in situ surveys

Combine a weight fit with the plants counted by each in situ survey into
the biomass of the surveyed area: wet or dry (kg/m² or kg), or carbon or
nitrogen (g/m² or kg).

## Usage

``` r
kb_predict_biomass_in_situ(
  weight,
  size,
  survey,
  wetdry = NULL,
  carbon = NULL,
  nitrogen = NULL,
  ...,
  measure = c("wet", "dry", "carbon", "nitrogen"),
  per_area = TRUE,
  pool_by = NULL,
  new_levels = c("sample", "average"),
  representative_site = NULL,
  n_plants = 100L,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3,
  progress = c("bar", "none"),
  progress_dir = NULL
)
```

## Arguments

- weight:

  A `kb_fit_weight` object.

- size:

  A `kb_fit_size` object, or a size census, a data frame with one row
  per counted plant (see
  [`kb_check_data_size_census_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_size_census_nereo.md)
  and
  [`kb_check_data_size_census_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_size_census_macro.md)
  for the columns).

- survey:

  A data frame of in situ surveys, one row per survey (see
  [`kb_check_data_survey_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_survey_in_situ.md)
  for the columns).

- wetdry:

  A `kb_fit_wetdry` object, required for dry, carbon, and nitrogen
  biomass, or `NULL`. All fits must be of the same species and have the
  same number of draws.

- carbon:

  A `kb_fit_carbon` object, required for carbon biomass, or `NULL`.

- nitrogen:

  A `kb_fit_nitrogen` object, required for nitrogen biomass, or `NULL`.

- ...:

  These dots are for future extensions and must be empty.

- measure:

  A string, one of `"wet"`, `"dry"`, `"carbon"`, or `"nitrogen"`, giving
  the type of biomass to predict.

- per_area:

  A flag specifying whether to give biomass per m² of the surveyed area,
  or else the biomass in that area.

- pool_by:

  A character vector naming character or factor columns to group the
  rows by, such as `c("site", "year")`, `character(0)` to pool all rows,
  or `NULL` (the default) for one row per input row. On each draw, the
  biomass of a group is the sum of its rows' biomass (kg). For another
  summary, such as an unweighted mean of rows, summarise the draws
  column, for example with
  [`posterior::rvar_mean()`](https://mc-stan.org/posterior/reference/rvar-summaries-within-draws.html).

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

- representative_site:

  A character vector of sites whose effects a new site takes in every
  fit (averaged when several are named), a list naming the sites per
  fit, such as `list(weight = "site_a")`, where a fit left out follows
  `new_levels`, or `NULL` (the default) to follow `new_levels`.

- n_plants:

  A whole number of sizes averaged per draw to compute the mean plant
  weight from a size fit; larger values are more precise and slower. Not
  used with a size census.

- conf_level:

  A number greater than 0 and less than 1 giving the
  compatibility-interval level.

- estimate:

  A function that reduces a numeric vector of posterior draws to a
  single estimate, such as `median` or `mean`.

- sig_fig:

  A whole number of significant figures for summary output.

- progress:

  A string, one of `"bar"` (the default, a console progress bar) or
  `"none"` (silent).

- progress_dir:

  A string giving an existing directory in which to record progress for
  [`kb_progress()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_progress.md),
  or `NULL` (the default) to record none.

## Value

A `kb_predictions` object: the rows of `survey`, or one row per
`pool_by` group, with `weight_support` and, with a size fit,
`size_support` (as in
[`kb_predict_mean_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_mean_weight.md)),
the draws of the biomass (for example `biomass_kg_m2` or
`carbon_biomass_kg`), and `estimate`, `lower`, and `upper`.

## Details

Plant sizes come from a size fit, when only a sample of plants was
measured, or from a size census, when every counted plant was measured,
joined to its survey by `survey_id` (see
[Methods](https://hakaiinstitute.github.io/kelpbio/articles/methods.html#survey-biomass)).
A survey with no rows in the size census has zero biomass, and a message
lists such surveys. With `pool_by` and `per_area = TRUE`, a group's
biomass per m² is its summed biomass over its summed `survey_area_m2`.

## See also

[`kb_fit_cover_calibration_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_cover_calibration_nereo.md)
to calibrate plot cover on the result.

Other prediction functions:
[`autoplot.kb_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/autoplot.kb_predictions.md),
[`kb_new_data()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_new_data.md),
[`kb_plot_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_predictions.md),
[`kb_predict_biomass_canopy()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_canopy.md),
[`kb_predict_carbon()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_carbon.md),
[`kb_predict_cover_calibration()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_cover_calibration.md),
[`kb_predict_mean_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_mean_weight.md),
[`kb_predict_nitrogen()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_nitrogen.md),
[`kb_predict_size()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_size.md),
[`kb_predict_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_weight.md),
[`kb_predict_wetdry()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_wetdry.md),
[`predict.kb_fit_carbon()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_carbon.md),
[`predict.kb_fit_cover_calibration()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_cover_calibration.md),
[`predict.kb_fit_nitrogen()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_nitrogen.md),
[`predict.kb_fit_size()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_size.md),
[`predict.kb_fit_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_weight.md),
[`predict.kb_fit_wetdry()`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_wetdry.md)

## Examples

``` r
# Tallied plants, sizes from a size fit
set.seed(1)
kb_predict_biomass_in_situ(
  fit_weight_sim_nereo,
  fit_size_sim_nereo,
  data_survey_in_situ_sim_nereo
)
#> <kb_predictions> response: biomass_kg_m2 | by: site, year
#> # A tibble: 54 × 14
#>    survey_id       site  year  survey_area_m2 plants plot_area_m2 canopy_area_m2
#>    <chr>           <fct> <fct>          <dbl>  <int>        <dbl>          <dbl>
#>  1 otter_cove-202… otte… 2020            140     992         215            87.3
#>  2 otter_cove-202… otte… 2020             80     297         262.          110. 
#>  3 gull_rock-2020… gull… 2020            233.    660         233.           30.3
#>  4 cedar_bay-2020… ceda… 2020             40       0         270.           34.3
#>  5 cedar_bay-2020… ceda… 2020            180     861         255.           81.2
#>  6 heron_reef-202… hero… 2020            120     550         217.           73.5
#>  7 urchin_shoal-2… urch… 2020            160    1815         218.          116. 
#>  8 sculpin_head-2… scul… 2020            193.   1245         193.           30.1
#>  9 eagle_spit-202… eagl… 2020            200     471         259.           97.3
#> 10 tidepool_bluff… tide… 2020            180     698         229            62.3
#> # ℹ 44 more rows
#> # ℹ 7 more variables: canopy_tide_height_m <dbl>, weight_support <chr>,
#> #   size_support <chr>, biomass_kg_m2 <rvar[1d]>, estimate <dbl>, lower <dbl>,
#> #   upper <dbl>

# A site the weight fit has no data for, weighed like a fitted site
set.seed(1)
kb_predict_biomass_in_situ(
  fit_weight_sim_nereo,
  fit_size_sim_nereo,
  subset(data_survey_in_situ_sim_nereo, site == "fog_islet"),
  representative_site = list(weight = "otter_cove")
)
#> <kb_predictions> response: biomass_kg_m2 | by: site, year
#> # A tibble: 4 × 14
#>   survey_id        site  year  survey_area_m2 plants plot_area_m2 canopy_area_m2
#>   <chr>            <fct> <fct>          <dbl>  <int>        <dbl>          <dbl>
#> 1 fog_islet-2021-1 fog_… 2021            207.    278         207.          122. 
#> 2 fog_islet-2022-1 fog_… 2022            217.    346         217.          108. 
#> 3 fog_islet-2024-1 fog_… 2024            218.    253         218.           50.5
#> 4 fog_islet-2025-1 fog_… 2025            229.    423         229.           84.3
#> # ℹ 7 more variables: canopy_tide_height_m <dbl>, weight_support <chr>,
#> #   size_support <chr>, biomass_kg_m2 <rvar[1d]>, estimate <dbl>, lower <dbl>,
#> #   upper <dbl>

# Every counted plant measured
set.seed(1)
kb_predict_biomass_in_situ(
  fit_weight_sim_macro,
  data_size_census_sim_macro,
  data_survey_in_situ_sim_macro,
  pool_by = c("site", "year")
)
#> ℹ 1 survey with no size census rows has no biomass.
#>   Survey: "cormorant_rock-2020-1".
#> <kb_predictions> response: biomass_kg_m2 | by: site, year
#> # A tibble: 49 × 7
#>    site         year  weight_support biomass_kg_m2 estimate lower upper
#>    <fct>        <fct> <chr>             <rvar[1d]>    <dbl> <dbl> <dbl>
#>  1 seal_ledge   2020  site-year         3.2 ± 0.31     3.18  2.64  3.84
#>  2 seal_ledge   2021  site-year         1.9 ± 0.18     1.9   1.6   2.29
#>  3 seal_ledge   2022  site-year         1.7 ± 0.16     1.74  1.46  2.11
#>  4 seal_ledge   2023  site-year         1.6 ± 0.15     1.57  1.32  1.9 
#>  5 seal_ledge   2024  site-year         1.8 ± 0.17     1.77  1.5   2.14
#>  6 seal_ledge   2025  site-year         3.5 ± 0.32     3.52  2.97  4.23
#>  7 mussel_point 2020  site-year         6.5 ± 0.62     6.44  5.36  7.77
#>  8 mussel_point 2021  site-year         4.4 ± 0.43     4.36  3.61  5.29
#>  9 mussel_point 2022  site-year         4.0 ± 0.38     4.01  3.34  4.81
#> 10 mussel_point 2023  site-year         1.4 ± 0.13     1.38  1.15  1.65
#> # ℹ 39 more rows
```
