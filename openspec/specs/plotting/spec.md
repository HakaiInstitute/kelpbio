# plotting

## Purpose

Plotting predictions from a kb_predictions data frame: kb_plot_predictions() and autoplot.kb_predictions() (never a fit object).

## Requirements

### Requirement: Plot predictions

`kb_plot_predictions(predictions, x, style, facet, observed, ...)` SHALL render a `ggplot` from a `kb_predictions` object, taking a prediction data frame in a pipe-based workflow and never a fit object.

#### Scenario: Returns a composable ggplot
- **WHEN** `kb_plot_predictions()` is called on a `kb_predictions` object
- **THEN** it returns a `ggplot` object the user can extend with `+` (e.g. `+ theme_minimal()`)

#### Scenario: Ribbon for a continuous predictor
- **WHEN** the prediction's predictor is continuous (an allometric weight-vs-diameter curve) and `style = NULL`
- **THEN** it draws a line with a credible-interval ribbon

### Requirement: Metadata-driven, overridable defaults

`x`, `style`, and `facet` SHALL default to `NULL` and be inferred from the prediction's metadata, while remaining overridable arguments.

#### Scenario: Inference from metadata
- **WHEN** the arguments are left `NULL`
- **THEN** `x` is the predictor, `facet` is the grouping variables, and `style` follows the predictor type

#### Scenario: Graceful fallback when metadata is missing
- **WHEN** the metadata has been stripped (e.g. by dplyr post-processing) and cannot be inferred
- **THEN** the function errors with a `cli` message directing the user to supply `x`/`facet`

### Requirement: Optional observed-data overlay

`kb_plot_predictions()` SHALL overlay raw observations when the user supplies `observed`, mapping its columns via the prediction's stored predictor/response names; the overlay is off by default.

#### Scenario: Observed points overlaid
- **WHEN** `observed = kb_data_weight` is supplied
- **THEN** the plot adds a points layer of the raw observations aligned to the prediction's axes

### Requirement: autoplot method on predictions

`autoplot.kb_predictions()` SHALL provide the conventional `ggplot2::autoplot` entry point, dispatching on the `kb_predictions` data frame (via its stored column-role attributes) and wrapping `kb_plot_predictions()`. It SHALL NOT dispatch on a fit object, preserving the rule that plotting functions take data frames, not fits.

#### Scenario: autoplot on a kb_predictions object
- **WHEN** `autoplot(predictions)` is called on a `kb_predictions` object
- **THEN** it returns the same `ggplot` as `kb_plot_predictions(predictions)`, inferring `x`/`style`/`facet` from the stored metadata
