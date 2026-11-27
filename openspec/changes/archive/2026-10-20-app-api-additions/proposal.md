## Why

The kelpbioshiny web app computes no numbers of its own: every output is a `kb_*` call. Three of its views still rely on mocks, because kelpbio has no function for them: a trace plot of the sampled parameters, a per-parameter convergence table, and a check of the uploaded canopy sheet (every other sheet is checked with an exported `kb_check_data_*()`).

## What Changes

- New `kb_plot_trace(fit)`: a `ggplot` of the draws of the terms `tidy()` reports, one panel per term and one line per chain.
- `summary(fit)` gains a `converged` column in its coefficient table, applying the thresholds of `kb_converged()` to each term, and takes name-only `rhat` and `ess` arguments that also set its header verdict.
- New `kb_check_data_canopy(data)`: the check `kb_predict_biomass_canopy()` already applies to its `new_data`, exported with the unit and group-name warnings the other data checks give.

## Non-goals

- No change to `kb_converged()`, `glance()`, or the checks themselves; the canopy check is the existing one, exported.
- No trace plots of per-level group effects.
- No data plots.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `summaries`: adds "Trace plot"; "Print and summary" gains the `converged` column and the `rhat` and `ess` arguments.
- `fitting`: "Input data" lists the canopy map columns and `kb_check_data_canopy()`.

## Impact

- New exports `kb_plot_trace()` and `kb_check_data_canopy()`, in `_pkgdown.yml`.
- The `summary()` snapshot gains the `converged` column and a footer line.
- No refit: fits and fixtures are unchanged.
