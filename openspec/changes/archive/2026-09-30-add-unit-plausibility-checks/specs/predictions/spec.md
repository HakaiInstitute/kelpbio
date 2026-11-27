## ADDED Requirements

### Requirement: Values far outside the fitted range are flagged

Prediction SHALL warn when supplied values of the species predictor lie below half the fitted minimum or above twice the fitted maximum, or supplied `density` values (for a fit with the density effect) lie above twice the fitted maximum, naming the column, the fitted range, and the column's expected unit where it has one. This applies to `new_data` and to a predictor sequence supplied to `kb_predict_weight_by()`. The warning SHALL NOT stop the prediction. The message is pinned by `tests/testthat/_snaps/warn_outside_range.md`.

#### Scenario: Diameter in centimetres at prediction is flagged
- **WHEN** `new_data` gives `diameter` in centimetres to a fit made in millimetres
- **THEN** a warning names `diameter` and the fitted range, and predictions are still returned

#### Scenario: Values within the fitted range raise no warning
- **WHEN** supplied values lie within twice the fitted range
- **THEN** no warning is issued
