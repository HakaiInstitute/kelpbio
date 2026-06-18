## ADDED Requirements

### Requirement: Predict allometric curves

`kb_predict_weight(new_data, fit, by, uncertainty, conf_level, estimate, sig_fig)` SHALL return a summary of predicted weight over a diameter sequence, computed from the fit's stored posterior draws, as a `kb_predictions` object. The computation uses the `posterior` `rvar` engine specified in `docs/predictions.md`.

#### Scenario: Auto-generated diameter sequence
- **WHEN** `kb_predict_weight(fit)` is called with `new_data = NULL`
- **THEN** it generates the diameter sequence with `newdata::xnew_data()` spanning the fit's observed range and returns a `kb_predictions` tibble with `estimate`, `lower`, `upper`

#### Scenario: Prediction at supplied new_data
- **WHEN** `new_data` is supplied with a `diameter` column
- **THEN** predictions are returned at exactly those diameters

#### Scenario: Predictor enters on a fixed-reference scale
- **WHEN** predictions are formed at any diameter
- **THEN** the diameter enters through the fixed transform `log(diameter) - log(30)` with no training-data-dependent rescaling step

### Requirement: Grouping and uncertainty axes

Predictions SHALL support a `by` grouping axis and an `uncertainty = c("marginal", "typical")` axis (marginal default), validated with `rlang::arg_match()`. The weight model carries three random effects across two grouping factors: a site intercept and a site slope (both keyed on `site`) and a site:year effect (keyed on `site` and `year`). Its available `by` values are therefore `NULL`, `"site"`, and `c("site", "year")`.

#### Scenario: Population-average vs new site-year
- **WHEN** `uncertainty = "typical"` vs `uncertainty = "marginal"` with `by = NULL`
- **THEN** `typical` zeroes all random effects (the population-average curve) and `marginal` draws a new site intercept from `Normal(0, sSite)`, a new site slope from `Normal(0, sSiteDiameter)`, and a new site:year effect from `Normal(0, sSiteYear)`, giving an interval at least as wide as typical

#### Scenario: Per-site curves
- **WHEN** `by = "site"` is supplied
- **THEN** one curve per observed site is returned, holding that site's estimated intercept and slope at their posterior values; under `uncertainty = "marginal"` the omitted site:year effect is drawn from `Normal(0, sSiteYear)`, and under `"typical"` it is zeroed

#### Scenario: Per-site-year curves
- **WHEN** `by = c("site", "year")` is supplied
- **THEN** one curve per observed site-by-year combination is returned, holding the site intercept, site slope, and that site:year effect at their estimated posterior values

#### Scenario: Marginal requires an omitted RE factor
- **WHEN** `uncertainty = "marginal"` is requested with `by = c("site", "year")`, which conditions on every random-effect factor and leaves nothing to draw
- **THEN** it errors with an informative `cli` message

#### Scenario: year alone is not a valid grouping for the weight model
- **WHEN** `by = "year"` is supplied
- **THEN** it errors with a `cli` message explaining that year enters the weight model only through the `site:year` interaction (there is no year main effect), so the available groupings are `NULL`, `"site"`, and `c("site", "year")`

### Requirement: Raw prediction draws

`kb_predict_weight_samples()` SHALL return the raw posterior prediction draws (no `conf_level`/`sig_fig`) as the prediction-grid tibble with the draws attached as an `rvar` column.

#### Scenario: Samples variant returns draws
- **WHEN** `kb_predict_weight_samples(fit)` is called
- **THEN** it returns the grid tibble carrying a `.prediction` `rvar` column (the full posterior draws, grid-aligned), suitable for composition into derived quantities and not a melted one-row-per-draw tibble

#### Scenario: Summary is the summariser over the samples
- **WHEN** `kb_predict_weight()` is compared to `kb_predict_weight_samples()`
- **THEN** the summary's `estimate`/`lower`/`upper` are the median and `conf_level` interval of the `rvar` column, rounded to `sig_fig`

### Requirement: kb_predictions carries plotting metadata

The `kb_predictions` object SHALL be a tibble subclass carrying column-role metadata (predictor, grouping variables, response and units) as attributes.

#### Scenario: Metadata attributes present
- **WHEN** a `kb_predictions` object is produced
- **THEN** it records the predictor column, the grouping variables (from `by`), and the response name/units, while still behaving as a tibble
