# Predict mean plant weight

Combine a weight and a size fit into the expected weight per plant of
each site-year: wet or dry (kg), or carbon or nitrogen (g).

## Usage

``` r
kb_predict_mean_weight(
  weight,
  size,
  new_data = NULL,
  wetdry = NULL,
  carbon = NULL,
  nitrogen = NULL,
  ...,
  measure = c("wet", "dry", "carbon", "nitrogen"),
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

  A `kb_fit_size` object.

- new_data:

  A data frame of the rows to predict at, with `site` and `year` columns
  (either may be absent, as in a grid from
  [`kb_new_data()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_new_data.md)),
  or `NULL` for the site-years in the size fit's data. `year` may be
  numeric or character: `2022` and `"2022"` match the same fitted year.

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

  A string, one of `"wet"` (kg), `"dry"` (kg), `"carbon"` (g C), or
  `"nitrogen"` (g N), giving the weight to predict.

- new_levels:

  A string giving how uncertainty is shown for a site or year not in the
  fit. Sites and years in the fit always use their own estimates. One
  of:

  - `"sample"` (the default): a new effect for each new site or year,
    drawn from the estimated variation among sites or among years (the
    random-effect standard deviation). The point estimate is equivalent,
    but the interval is wider since it also includes that variation. Use
    it to get realistic uncertainty about a particular site or year that
    the model has no information on. Rows that name the same new site or
    year, or that have no `site` or `year` column, share one effect;
    give new sites or years different names for independent effects. The
    interval varies slightly between calls; use
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
  weight; larger values are more precise and slower to compute.

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

A `kb_predictions` object: the rows of `new_data` with added
`weight_support` and `size_support`, the draws of the mean weight in a
`weight_kg`, `dry_weight_kg`, `carbon_weight_g`, or `nitrogen_weight_g`
column, and `estimate`, `lower`, and `upper`.

## Details

Mean plant weight is the weight model averaged over the site-year's size
distribution (see
[Methods](https://hakaiinstitute.github.io/kelpbio/articles/methods.html#mean-plant-weight)).
`weight_support` and `size_support` show the data each fit has for the
site-year, from most to least local: `"site-year"`, `"site, year"` (its
site and its year, but not together), `"site"`, `"year"`, or `"none"`.

## See also

[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.md)
for the biomass of in situ surveys.

Other prediction functions:
[`autoplot.kb_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/autoplot.kb_predictions.md),
[`kb_new_data()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_new_data.md),
[`kb_plot_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_predictions.md),
[`kb_predict_biomass_canopy()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_canopy.md),
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.md),
[`kb_predict_carbon()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_carbon.md),
[`kb_predict_cover_calibration()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_cover_calibration.md),
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
set.seed(1)
kb_predict_mean_weight(fit_weight_sim_nereo, fit_size_sim_nereo)
#> <kb_predictions> response: weight_kg | by: site, year
#> # A tibble: 45 × 8
#>    site      year  weight_support size_support    weight_kg estimate lower upper
#>    <fct>     <fct> <chr>          <chr>          <rvar[1d]>    <dbl> <dbl> <dbl>
#>  1 otter_co… 2020  site-year      site-year     0.86 ± 0.15    0.839 0.621  1.2 
#>  2 otter_co… 2021  site-year      site-year     0.85 ± 0.15    0.839 0.611  1.18
#>  3 otter_co… 2022  site-year      site-year     1.19 ± 0.22    1.17  0.84   1.68
#>  4 otter_co… 2023  site-year      site-year     0.92 ± 0.18    0.905 0.604  1.32
#>  5 otter_co… 2024  site-year      site-year     1.00 ± 0.18    0.98  0.692  1.4 
#>  6 otter_co… 2025  site-year      site-year     1.19 ± 0.21    1.17  0.846  1.65
#>  7 gull_rock 2021  site-year      site-year     0.89 ± 0.16    0.872 0.631  1.25
#>  8 gull_rock 2022  site-year      site-year     1.20 ± 0.21    1.17  0.846  1.67
#>  9 gull_rock 2023  site-year      site-year     1.52 ± 0.27    1.48  1.06   2.12
#> 10 gull_rock 2024  site-year      site-year     0.81 ± 0.14    0.796 0.566  1.1 
#> # ℹ 35 more rows

# The typical year at each site
kb_predict_mean_weight(
  fit_weight_sim_nereo,
  fit_size_sim_nereo,
  kb_new_data(fit_size_sim_nereo, by = "site"),
  new_levels = "average"
)
#> <kb_predictions> response: weight_kg | by: site
#> # A tibble: 9 × 7
#>   site           weight_support size_support     weight_kg estimate lower upper
#>   <fct>          <chr>          <chr>           <rvar[1d]>    <dbl> <dbl> <dbl>
#> 1 otter_cove     site           site          1.00 ± 0.155    0.993 0.725 1.34 
#> 2 gull_rock      site           site          1.06 ± 0.173    1.05  0.76  1.44 
#> 3 cedar_bay      site           site          0.93 ± 0.158    0.919 0.65  1.29 
#> 4 heron_reef     site           site          0.93 ± 0.147    0.919 0.68  1.27 
#> 5 urchin_shoal   none           site          0.49 ± 0.082    0.486 0.36  0.691
#> 6 sculpin_head   none           site          0.75 ± 0.112    0.737 0.552 0.986
#> 7 eagle_spit     site           site          1.33 ± 0.207    1.32  0.966 1.77 
#> 8 fog_islet      site           site          1.80 ± 0.332    1.78  1.24  2.57 
#> 9 tidepool_bluff none           site          1.22 ± 0.195    1.2   0.896 1.67 
```
