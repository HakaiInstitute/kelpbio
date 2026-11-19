# Predict biomass over mapped canopy

Predict the biomass over each row's mapped canopy from a cover
calibration fit: wet, dry, carbon, or nitrogen (kg), optionally pooled
by grouping columns.

## Usage

``` r
kb_predict_biomass_canopy(
  fit,
  new_data,
  wetdry = NULL,
  carbon = NULL,
  nitrogen = NULL,
  ...,
  measure = c("wet", "dry", "carbon", "nitrogen"),
  pool_by = NULL,
  new_levels = c("sample", "average"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
)
```

## Arguments

- fit:

  A `kb_fit_cover_calibration` object.

- new_data:

  A data frame of canopy maps, one row per map (see
  [`kb_check_data_survey_canopy()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_survey_canopy.md)
  for the columns). Other columns are kept and can be named in
  `pool_by`. `year` may be numeric or character: `2022` and `"2022"`
  match the same fitted year.

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

  A character vector of sites in the fit whose effects a new site adopts
  (averaged when several are named), or `NULL` (the default) to follow
  `new_levels`.

- conf_level:

  A number greater than 0 and less than 1 giving the
  compatibility-interval level.

- estimate:

  A function that reduces a numeric vector of posterior draws to a
  single estimate, such as `median` or `mean`.

- sig_fig:

  A whole number of significant figures for summary output.

## Value

A `kb_predictions` object: the rows of `new_data`, or one row per
`pool_by` group, with `cover_support` (when the rows have a site and
year), the draws of the total (`biomass_kg`, `dry_biomass_kg`,
`carbon_biomass_kg`, or `nitrogen_biomass_kg`), and `estimate`, `lower`,
and `upper`.

## Details

A row's total is the calibration at full cover times its tide-corrected
canopy area, capped at `classified_area_m2` (see
[Methods](https://hakaiinstitute.github.io/kelpbio/articles/methods.html#total-biomass)).
A warning is given if a row is past the tide limit on more than 5% of
draws, or if a pooled group has more than one map of a site-year, which
counts its bed more than once.

## See also

[`kb_predict_cover_calibration()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_cover_calibration.md)
for biomass per m² of a plot.

Other prediction functions:
[`autoplot.kb_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/autoplot.kb_predictions.md),
[`kb_new_data()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_new_data.md),
[`kb_plot_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_predictions.md),
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.md),
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
fit <- fit_cover_calibration_sim_nereo

# One total per row
set.seed(1)
kb_predict_biomass_canopy(fit, data_survey_canopy_sim_nereo)
#> <kb_predictions> response: biomass_kg | by: site, year
#> # A tibble: 49 × 11
#>    site      year  canopy_area_m2 canopy_tide_height_m classified_area_m2 region
#>    <fct>     <fct>          <dbl>                <dbl>              <dbl> <fct> 
#>  1 otter_co… 2020            6817                 1.2               18504 north 
#>  2 gull_rock 2020           53242                 0.15             142539 north 
#>  3 cedar_bay 2020            5893                 1.05              11737 north 
#>  4 heron_re… 2020           24787                 0.6               51227 north 
#>  5 urchin_s… 2020           20431                 0.75              55633 south 
#>  6 sculpin_… 2020           16455                 1                 45632 south 
#>  7 eagle_sp… 2020           38273                 1.3               76960 south 
#>  8 tidepool… 2020           20110                 0.2               41234 south 
#>  9 otter_co… 2021            4819                 1.6                9556 north 
#> 10 gull_rock 2021           38877                 0.2               83128 north 
#> # ℹ 39 more rows
#> # ℹ 5 more variables: cover_support <chr>, biomass_kg <rvar[1d]>,
#> #   estimate <dbl>, lower <dbl>, upper <dbl>

# Wet totals by region and year
set.seed(1)
kb_predict_biomass_canopy(
  fit,
  data_survey_canopy_sim_nereo,
  pool_by = c("region", "year")
)
#> <kb_predictions> response: biomass_kg | by: region, year
#> # A tibble: 12 × 6
#>    region year         biomass_kg estimate  lower   upper
#>    <fct>  <fct>        <rvar[1d]>    <dbl>  <dbl>   <dbl>
#>  1 north  2020    989350 ± 144459   980000 735000 1310000
#>  2 north  2021    598562 ± 92683    594000 426000  781000
#>  3 north  2022    396554 ± 68212    391000 278000  543000
#>  4 north  2023    306940 ± 46859    304000 224000  406000
#>  5 north  2024    220094 ± 40111    221000 140000  298000
#>  6 north  2025    477421 ± 70150    469000 355000  639000
#>  7 south  2020   1110012 ± 141970  1090000 867000 1420000
#>  8 south  2021    549527 ± 75487    548000 410000  700000
#>  9 south  2022    566128 ± 75479    560000 433000  732000
#> 10 south  2023    369234 ± 49059    366000 281000  475000
#> 11 south  2024    262608 ± 41242    263000 176000  343000
#> 12 south  2025    853358 ± 121528   841000 650000 1120000

# Carbon stock by year
set.seed(1)
kb_predict_biomass_canopy(
  fit,
  data_survey_canopy_sim_nereo,
  fit_wetdry_sim_nereo,
  fit_carbon_sim_nereo,
  measure = "carbon",
  pool_by = "year"
)
#> <kb_predictions> response: carbon_biomass_kg | by: year
#> # A tibble: 6 × 5
#>   year  carbon_biomass_kg estimate lower upper
#>   <fct>        <rvar[1d]>    <dbl> <dbl> <dbl>
#> 1 2020       48826 ± 6095    48300 38100 62500
#> 2 2021       26706 ± 3654    26700 19800 33900
#> 3 2022       22391 ± 2970    22200 16700 28800
#> 4 2023       15727 ± 2066    15700 12000 20100
#> 5 2024       11227 ± 1789    11300  7420 14800
#> 6 2025       30952 ± 4019    30500 24100 40100
```
