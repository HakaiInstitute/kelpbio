## Why

`kb_predict_biomass_canopy()` sums the rows of each `pool_by` group, so a site-year mapped more than once (e.g. two flights in a season) has its bed counted once per map: totals by year or region are overstated, and a total by site and year cannot be formed.
It warns, but still returns the inflated sum.
The bar style of `kb_plot_predictions()` also stacks rows that share an x value, so several maps or several in situ surveys of a site-year are drawn as one summed column with a single row's interval (poissonconsulting/kelpbio#26).

## What Changes

- **BREAKING** Pooled canopy totals average the maps of each site-year within a group, draw by draw, then sum across the group's site-years.
  Results are unchanged when no group holds more than one map of a site-year.
- The overlapping-canopy warning is removed; canopy maps of one site-year whose `classified_area_m2` differ widely warn instead, since each map must cover the whole site.
- In situ pooling is unchanged, and its rule is stated: a pooled per-area value weights each survey by its area, and a pooled total counts a plot surveyed more than once once per survey.
- `geom = "bar"` in `kb_plot_predictions()` places rows that share an x value in a panel side by side, each with its own interval.
- Reader docs: each verb's `pool_by` states its own rule, and the Methods article gives the standing-stock rationale.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `predictions`: the `Pooling over groups`, `Canopy biomass`, and `Plot predictions` requirements.

## Non-goals

- No plot identifier for in situ surveys, and no averaging of repeat visits to a plot.
- No change to unpooled output (one row per map or survey).
- No dodging of the point-range style.
- No model or fit changes, so no refits.

## Impact

- `R/kb_predict_biomass_canopy.R`, `R/biomass.R` (pooling), `R/warn.R` (remove the overlap warning, add the classified-area warning), `R/kb_check_data_survey_canopy.R`, `R/kb_plot_predictions.R`.
- `R/params.R` and the two biomass verbs' roxygen, `vignettes/methods.Rmd`.
- Tests and snapshots for those files.
- kelpbioshiny can then offer canopy totals by site and year (poissonconsulting/kelpbioshiny#13).
