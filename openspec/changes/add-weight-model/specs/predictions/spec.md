## ADDED Requirements

### Requirement: Predict allometric curves

`kb_predict_weight(new_data, fit, by, uncertainty, conf_level, estimate, sig_fig)` SHALL return a summary of predicted weight over a diameter sequence, computed R-side from the fit's stored draws, as a `kb_predictions` object.

#### Scenario: Auto-generated diameter sequence
- **WHEN** `kb_predict_weight(fit)` is called with `new_data = NULL`
- **THEN** it predicts over a diameter sequence spanning the fit's observed range and returns a `kb_predictions` tibble with `estimate`, `lower`, `upper`

#### Scenario: Prediction at supplied new_data
- **WHEN** `new_data` is supplied with a `diameter` column
- **THEN** predictions are returned at exactly those diameters

### Requirement: Grouping and uncertainty axes

Predictions SHALL support a `by` grouping axis and an `uncertainty = c("marginal", "typical")` axis (marginal default), validated with `rlang::arg_match()`.

#### Scenario: Population-average vs new-site
- **WHEN** `uncertainty = "typical"` vs `uncertainty = "marginal"` with `by = NULL`
- **THEN** `typical` zeroes the site effect (population-average curve) and `marginal` draws a new site effect from `Normal(0, sSite)`, giving an interval at least as wide as typical

#### Scenario: Per-site curves
- **WHEN** `by = "site"` is supplied
- **THEN** one curve per observed site is returned, using each site's estimated effect

#### Scenario: Marginal requires an omitted RE factor
- **WHEN** `uncertainty = "marginal"` is requested but `by` already conditions on every available random-effect factor
- **THEN** it errors with an informative `cli` message

### Requirement: Raw prediction draws

`kb_predict_weight_samples()` SHALL return the raw posterior prediction draws (no `conf_level`/`sig_fig`) in a standard draws container with the prediction grid associated.

#### Scenario: Samples variant returns draws
- **WHEN** `kb_predict_weight_samples(fit)` is called
- **THEN** it returns the full prediction draws (not a summary), suitable for composition

### Requirement: kb_predictions carries plotting metadata

The `kb_predictions` object SHALL be a tibble subclass carrying column-role metadata (predictor, grouping variables, response and units) as attributes.

#### Scenario: Metadata attributes present
- **WHEN** a `kb_predictions` object is produced
- **THEN** it records the predictor column, the grouping variables (from `by`), and the response name/units, while still behaving as a tibble
