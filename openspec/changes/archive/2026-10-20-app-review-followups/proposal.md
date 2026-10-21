## Why

Reviewing the kelpbioshiny app against kelpbio turned up three gaps. The trace plot is bayesplot's figure, with bayesplot's own theme and layout, unlike kelpbio's other figures, which take the active theme. `kb_sensitivity()` flags the cover calibration's tide slope on every fit, although its prior is informative by design and the data are expected to say little about it, so the app cannot tell an expected flag from a problem. Prediction plots label large totals in scientific notation (`2e+05`).

## What Changes

- `kb_plot_trace()` is drawn by kelpbio with ggplot2: `ncol` facet columns (default 2) with free y-axes, a colour per chain with a "Chain" legend, and the x-axis titled "Iteration". It sets no theme, following the tidyverse convention that a plotting function returns a plain `ggplot` in the active theme, to which the caller adds a theme.
- `kb_plot_predictions()` labels the ticks of linear axes as plain numbers with thousands separators, as its log axes already do. It sets no theme, as now.
- `kb_sensitivity()` gains an `informative_prior` column, `TRUE` for the cover calibration's `tide_height_slope`, whose default prior comes from Timmer et al. (2024). The cover calibration fits record the list, so they are refitted.

## Non-goals

- No change to `pp_check()`, which keeps bayesplot's theme.
- No theme set by any kelpbio figure; the app applies its own.
- No user-set flag on prior objects: the list is fixed per model.
- No change to the sensitivity values or the `weak_prior` and `strong_data` thresholds.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `summaries`: "Trace plot" fixes the figure's layout and labels and leaves the theme to the caller; "Prior sensitivity" adds `informative_prior`.
- `predictions`: "Plot predictions" labels linear axes as plain numbers and states that it sets no theme. This change modifies a different requirement from the open `per-fit-representative-site` change, so archiving both does not overwrite either.

## Impact

- Refit of the cover calibration pre-fits and fixtures (`--fits=cover_calibration`).
- Plot tests updated; the prediction figures' vdiffr snapshots are unchanged.
