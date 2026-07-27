# predictions

## MODIFIED Requirements

### Requirement: kb_predictions carries plotting metadata

The `kb_predictions` object SHALL be a tibble subclass carrying column-role metadata (predictor, grouping variables, response and units) as attributes. It SHALL also carry a `kb_curve` flag recording whether the rows form an ordered, generated grid over the predictor (ribbon-eligible) rather than scattered supplied rows. The grid-generating verb (`kb_predict_weight_by()`) SHALL set it true; the row-wise verb (`kb_predict_weight()` / `predict()`) SHALL set it false. Plotting consumes the flag to choose a ribbon (only for a generated curve over a varying predictor) versus grouped points.

#### Scenario: Metadata attributes present
- **WHEN** a `kb_predictions` object is produced
- **THEN** it records the predictor column, the grouping variables (from `by`), the response name/units, and the `kb_curve` flag, while still behaving as a tibble

#### Scenario: Curve flag distinguishes the prediction verbs
- **WHEN** the prediction comes from `kb_predict_weight_by()` versus `kb_predict_weight()`
- **THEN** `kb_curve` is true for the former (a generated curve) and false for the latter (supplied rows)
