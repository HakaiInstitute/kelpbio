## Why

`kb_plot_predictions()` inferred its style from the x-column type (`is.numeric` → ribbon, else pointrange) and always defaulted `x` to the predictor. For the weight model the predictor (`diameter`) is always numeric, so the pointrange path was unreachable as a default and there was no way to put a grouping factor on the x-axis. A weight-at-reference-diameter plot (`by = "site", diameter = 30`) drew a degenerate one-point ribbon per facet, and faceting could not be turned off (`facet = ""` broke). This is the same layout the density and size models need by default (grouped points, no continuous predictor), so the inference needed to be generalised rather than patched per model.

## What Changes

- **BREAKING**: Remove the `style` and `facet` arguments from `kb_plot_predictions()`. The style is derived from the prediction's shape, and faceting follows from `x` (the remaining grouping variables are faceted); neither is a separate user knob.
- A ribbon (line + credible interval) is drawn only for a **generated curve** over a varying predictor; every other prediction renders as `geom_pointrange`. This is recorded by a new `kb_curve` flag on the prediction (set TRUE by the grid-generating `_by` verb, FALSE by the row-wise verb), because scattered supplied rows cannot be told from a generated grid by data shape alone.
- When the predictor does not vary (a held reference value, or a model with no continuous predictor), the **last grouping factor** goes on the x-axis and the remaining grouping factors become facets.
- The variable on the x-axis is **never also used as a facet**; the remaining grouping variables are faceted.

## Capabilities

### New Capabilities
<!-- None. -->

### Modified Capabilities
- `plotting`: `style` and `facet` removed; style derived (ribbon only for a generated curve, else pointrange); grouping factor on the x-axis when the predictor does not vary (last factor on x, rest faceted); faceting follows from `x` so the x variable is never a facet.
- `predictions`: `kb_predictions` carries a `kb_curve` flag (TRUE for the `_by` curve verb, FALSE for the row-wise predict verb) so plotting can choose ribbon vs pointrange.

## Impact

- API (breaking, pre-1.0, R-universe): `style` and `facet` removed from `kb_plot_predictions()`; a caller passing either now trips `rlang::check_dots_empty()`.
- Code: `R/kb_plot_predictions.R`, `R/kb_predictions.R`, `R/kb_predict_weight.R`, `R/kb_predict_weight_by.R`, `R/autoplot.R`, mirrored tests.
- No `inst/stan/` change (no recompile); the fixture fit stays valid.
