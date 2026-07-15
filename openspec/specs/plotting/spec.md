# plotting

## Purpose

Plotting predictions from a kb_predictions data frame: kb_plot_predictions() and autoplot.kb_predictions() (never a fit object).

## Requirements

### Requirement: Plot predictions

`kb_plot_predictions(predictions, x, observed, ...)` SHALL render a `ggplot` from a `kb_predictions` object, taking a prediction data frame in a pipe-based workflow and never a fit object. It SHALL NOT take `style` or `facet` arguments; the plot style is derived from the prediction's shape and faceting follows from `x` (the remaining grouping variables).

#### Scenario: Returns a composable ggplot
- **WHEN** `kb_plot_predictions()` is called on a `kb_predictions` object
- **THEN** it returns a `ggplot` object the user can extend with `+` (e.g. `+ theme_minimal()`)

#### Scenario: Ribbon only for a generated curve
- **WHEN** the prediction is a generated curve (`kb_predict_weight_by()` over a varying predictor, `kb_curve` true)
- **THEN** it draws a line with a credible-interval ribbon over the predictor

#### Scenario: Grouped points when the predictor does not vary
- **WHEN** the predictor is held at a single value or absent (e.g. `kb_predict_weight_by(by = "site", diameter = 30)`, or a model with no continuous predictor)
- **THEN** it draws `geom_pointrange` with the grouping factor on the x-axis and does not facet by that factor

#### Scenario: Scattered supplied rows render as points
- **WHEN** the prediction is from `kb_predict_weight()` at supplied rows (`kb_curve` false), even with a varying predictor
- **THEN** it draws `geom_pointrange` over the predictor rather than a connecting ribbon

#### Scenario: Last grouping factor on the x-axis
- **WHEN** a grouped-points prediction has two grouping factors (e.g. `c("site", "year")`)
- **THEN** the last factor (`year`) is placed on the x-axis and the remaining factors (`site`) become facets

#### Scenario: Publication-ready axis titles
- **WHEN** `kb_plot_predictions()` labels the axes
- **THEN** it uses descriptive titles for the known model variables (e.g. `Sub-bulb diameter`, `Wet weight`, `Site`) rather than the raw column names; units are not asserted in the labels (the weight model is unit-flexible), though a unit is appended in parentheses if one is supplied on the prediction's metadata

### Requirement: Metadata-driven, overridable defaults

`x` SHALL default to `NULL` and be inferred from the prediction's metadata, while remaining an overridable argument; the plot style SHALL be derived from the prediction's shape rather than supplied, and faceting SHALL follow from `x` rather than being a separate argument. The remaining grouping variables (those not on the x-axis) are faceted, so the variable on the x-axis is never also used as a facet. A `max_facets` argument SHALL cap the number of facet panels drawn (default a small finite number); when the grouping has more groups than `max_facets`, the first `max_facets` are shown and a `cli` warning names how many were dropped and how to override. `Inf` disables the cap.

#### Scenario: Inference from metadata
- **WHEN** `x` is left `NULL`
- **THEN** `x` is the predictor when it varies, otherwise the last grouping factor; the remaining grouping variables are faceted; and the style follows whether the prediction is a generated curve

#### Scenario: Graceful fallback when metadata is missing
- **WHEN** the metadata has been stripped (e.g. by dplyr post-processing) and cannot be inferred
- **THEN** the function errors with a `cli` message directing the user to supply `x`

#### Scenario: x is never used as a facet
- **WHEN** the inferred or supplied `x` is one of the grouping variables
- **THEN** it is dropped from the facet set so no panel is faceted by the x variable

#### Scenario: Facet panels are capped
- **WHEN** a prediction has more grouping combinations than `max_facets`
- **THEN** only the first `max_facets` groups are plotted and a `cli` warning reports how many of the total were shown

### Requirement: Optional observed-data overlay

`kb_plot_predictions()` SHALL overlay raw observations when the user supplies `observed`, mapping its columns via the prediction's stored predictor/response names; the overlay is off by default.

#### Scenario: Observed points overlaid
- **WHEN** `observed = data_weight_sim_nereo` is supplied
- **THEN** the plot adds a points layer of the raw observations aligned to the prediction's axes

### Requirement: autoplot method on predictions

`autoplot.kb_predictions()` SHALL provide the conventional `ggplot2::autoplot` entry point, dispatching on the `kb_predictions` data frame (via its stored column-role attributes) and wrapping `kb_plot_predictions()`. It SHALL NOT dispatch on a fit object, preserving the rule that plotting functions take data frames, not fits.

#### Scenario: autoplot on a kb_predictions object
- **WHEN** `autoplot(predictions)` is called on a `kb_predictions` object
- **THEN** it returns the same `ggplot` as `kb_plot_predictions(predictions)`, inferring `x`/`style`/`facet` from the stored metadata
