## Why

Biomass summed by year, or by site and year, is a standing stock that readers expect as a bar chart, but `kb_plot_predictions()` draws every prediction that is not a curve as point ranges.

## What Changes

- `kb_plot_predictions()` gains `geom`, a name-only argument: `"pointrange"` (the default, unchanged) or `"bar"`, which draws predictions that are not a curve as columns from zero with the compatibility interval as a line.
- `geom = "bar"` errors for a curve and with a log axis.
- `autoplot()` on a `kb_predictions` object passes `geom` on.

## Non-goals

- No change to the default plot of any prediction.
- No fill, colour, or theme settings beyond a translucent column.
- The README and vignettes follow in their pending pass.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `predictions`: the "Plot predictions" requirement gains the column geometry.

## Impact

- `kb_plot_predictions()` and its roxygen, the `autoplot()` roxygen, one new plot snapshot, and two new error snapshots.
