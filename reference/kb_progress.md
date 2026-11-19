# Completed fraction of a running task

The proportion completed by a fit,
[`kb_predict_mean_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_mean_weight.md),
or
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.md)
writing to `progress_dir`, as a number from 0 to 1.

## Usage

``` r
kb_progress(progress_dir)
```

## Arguments

- progress_dir:

  A string giving the directory passed as `progress_dir` to the task.

## Value

A number between 0 and 1.

## Details

Pass the same directory given as `progress_dir` to a `kb_fit_*`
function,
[`kb_predict_mean_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_mean_weight.md),
or
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.md).
This reads progress from another R process: for example, a Shiny app can
run the task in the background and poll `kb_progress()` from the main
session to drive a progress indicator. It returns `0` before the task
has written anything and `1` once it has finished. Use a separate
directory for each task.

## See also

Other fit functions:
[`kb_fit_carbon_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_carbon_macro.md),
[`kb_fit_carbon_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_carbon_nereo.md),
[`kb_fit_cover_calibration_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_cover_calibration_macro.md),
[`kb_fit_cover_calibration_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_cover_calibration_nereo.md),
[`kb_fit_nitrogen_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_nitrogen_macro.md),
[`kb_fit_nitrogen_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_nitrogen_nereo.md),
[`kb_fit_size_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_size_nereo.md),
[`kb_fit_weight_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_weight_macro.md),
[`kb_fit_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_weight_nereo.md),
[`kb_fit_wetdry_macro()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_wetdry_macro.md),
[`kb_fit_wetdry_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_wetdry_nereo.md)

## Examples

``` r
progress_dir <- tempfile()
dir.create(progress_dir)
# Before a task has written anything, progress is 0.
kb_progress(progress_dir)
#> [1] 0
```
