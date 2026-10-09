## Why

Weights, densities, and biomass span orders of magnitude, so on a linear axis
the smaller sites and low-cover surveys are squashed against zero and their
intervals cannot be read. Prediction plots had no way to draw them on a log
scale; adding `scale_y_log10()` by hand clashed with the zero-anchored y-axis
and gave a warning.

## What Changes

- `kb_plot_predictions()` gains a name-only `log_axis` argument, one of
  `"none"` (default), `"y"`, or `"xy"`. With `"y"` the y-axis is log-scaled and
  no longer extends to zero; `"xy"` also log-scales a numeric x-axis.
- Log-scaled tick labels are plain numbers (`0.1`, `1`, `10`).
- A log axis errors when the values it would show are not all positive, and
  `"xy"` errors when the x-axis is not numeric.

## Non-goals

- No per-model default: the default is always `"none"`, and callers such as the
  web app choose the scale for each model.
- No change to `kb_new_data()` grids. A cover grid starts at zero cover, so a
  log-log cover curve needs a grid of positive cover values.
