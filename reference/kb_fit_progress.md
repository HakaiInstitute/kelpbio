# Completed Fraction of a Running Fit

The proportion of sampling completed by a fit writing to `progress_dir`,
as a number from 0 to 1.

## Usage

``` r
kb_fit_progress(progress_dir)
```

## Arguments

- progress_dir:

  A string giving the directory passed as `progress_dir` to a `kb_fit_*`
  function.

## Value

A number between 0 and 1.

## Details

Pass the same directory given as `progress_dir` to a `kb_fit_*`
function. This reads fit progress from another R process: for example, a
Shiny app can run the fit in a background task and poll
`kb_fit_progress()` from the main session to drive a progress indicator.
It returns `0` before sampling has produced any output (or when the
directory holds no fit artifact yet) and `1` once every chain has
finished.

## Examples

``` r
progress_dir <- tempfile()
dir.create(progress_dir)
# Before a fit has written anything, progress is 0.
kb_fit_progress(progress_dir)
#> [1] 0
```
