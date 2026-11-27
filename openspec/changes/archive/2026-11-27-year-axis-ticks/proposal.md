## Why

`kb_plot_predictions()` draws `year` on a discrete axis, so every year gets a tick label.
Across the 11 years of the Hakai Institute canopy data, the labels overlap in the narrow facet panels and cannot be read.

## What Changes

- A year x-axis whose years are all whole numbers SHALL be continuous, with whole-number ticks chosen by ggplot's default breaks and no thousands separator, so the labels thin as years are added and years without predictions show as gaps.
- Any other non-numeric x-axis, including years with a new level such as `"new"`, SHALL stay discrete and drop tick labels that would overlap.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `predictions`: the `Plot predictions` requirement.

## Non-goals

- No change to the predictions table: `year` stays a factor there.
- No angled labels or theme settings: the plot still sets no theme.
- `site` and other grouping columns are never converted to numbers, even when their labels are whole numbers.

## Impact

- `R/kb_plot_predictions.R` and its tests; the `vdiffr` snapshots with year on the x-axis change.
