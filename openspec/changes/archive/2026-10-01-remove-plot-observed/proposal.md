## Why

`kb_plot_predictions(observed = )` overlays raw data on a prediction plot. A
prediction holds the effects it does not name at their typical values (and, for
the `_by` verbs, shrinks group estimates toward the mean), while each raw
observation carries its own site, year, and site-year effects. The estimates
therefore look wrong against the points even when the model fits well. The
match of model to data is shown by plotting fitted values against the observed
response and by posterior-predictive checks, which kelpbio already supports.
Raw data remain one `geom_point()` layer away for users who want them.

## What Changes

- **BREAKING**: `kb_plot_predictions()` loses its `observed` argument.
- The documentation points to `augment()` (fitted against observed) and
  `posterior_predict()` (predictive checks) for comparing the model with the
  data, and notes that raw data can be added as a layer with `+`.
- The demo scripts add raw data as a layer instead.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `predictions`: the plot requirement no longer offers a raw-data overlay.

## Non-goals

- A built-in predicted-against-observed plot.
- Any change to plot geometry, faceting, or axes.
