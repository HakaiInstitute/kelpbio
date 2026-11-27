## MODIFIED Requirements

### Requirement: Two prediction verbs

Each model SHALL have a row-wise verb and a `_by` verb, both returning a `kb_predictions` object whose `estimate`, `lower`, and `upper` columns summarise the posterior distribution of the expected response, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). The row-wise verb SHALL predict at the rows of `new_data`, or at the observed data when `new_data = NULL`. The `_by` verb SHALL predict with one row or curve per level of the factors named in `by` (`NULL`, `"site"`, `"year"`, or `c("site", "year")`, the last taking only observed combinations).

- Weight: `kb_predict_weight(fit, new_data)` and `kb_predict_weight_by(fit, by)` predict expected weight (kg). `kb_predict_weight_by()` predicts curves over a sequence of the species predictor (`diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*), auto-generated over the observed range unless supplied through the argument of the same name. The returned predictor column SHALL take the input column's name. New data SHALL use the predictor reference stored at fit time.
- Size: `kb_predict_size(fit, new_data)` and `kb_predict_size_by(fit, by)` predict expected size, the mean of the size distribution: sub-bulb diameter (mm) for *Nereocystis*, and fronds at 1 m for *Macrocystis*, among plants with at least one. Size has no predictor, so `kb_predict_size_by()` returns one row per group, and `new_data` needs no columns.

#### Scenario: Predict at the observed data
- **WHEN** `kb_predict_weight(fit)` or `kb_predict_size(fit)` is called
- **THEN** it returns one prediction per observed row, whose `estimate` equals `augment(fit)$fitted`

#### Scenario: Predict at supplied rows
- **WHEN** `new_data` carries the columns the model needs (the species predictor for weight, none for size)
- **THEN** predictions are returned at exactly those rows

#### Scenario: Curves are returned over the named predictor
- **WHEN** `kb_predict_weight_by(fit, diameter_mm = c(20, 40))` is called on a *Nereocystis* fit
- **THEN** it returns predictions at those values in a `diameter_mm` column

#### Scenario: Size by group returns one row per group
- **WHEN** `kb_predict_size_by(fit, by = "site")` is called
- **THEN** it returns one row per fitted site, and `by = NULL` returns a single row for the typical site and year

#### Scenario: A wrong predictor errors
- **WHEN** `new_data` lacks the weight model's species predictor, or `kb_predict_weight_by()` is given the other species' predictor argument
- **THEN** it errors naming the correct column or argument

### Requirement: Density is resolved per row

For a *Nereocystis* fit with the density effect, each row SHALL use its `stipes_m2` value if present, otherwise the recorded density of its site-year in the fitted data, otherwise the fitted mean. This applies to every prediction and summary computed at rows, including the observed data. A `stipes_m2` column in `new_data` SHALL be validated (numeric, `>= 0`, `NA` allowed) and is ignored by a fit without the density effect.

#### Scenario: Resolution order
- **WHEN** rows supply `stipes_m2`, omit it for a fitted site-year with recorded density, and omit it for a new site-year
- **THEN** they use the supplied value, the recorded value, and the fitted mean, respectively

#### Scenario: Curves by site and year use recorded densities
- **WHEN** `kb_predict_weight_by(fit, by = c("site", "year"))` is called
- **THEN** each curve uses its site-year's recorded density, and other `by` values use the fitted mean

### Requirement: Plot predictions

`kb_plot_predictions(predictions)` SHALL return a `ggplot` built from a `kb_predictions` object, never from a fit, and `autoplot()` on a `kb_predictions` object SHALL return the same plot. A curve from `kb_predict_weight_by()` over a varying predictor SHALL be drawn as a line with a compatibility-interval ribbon; otherwise predictions SHALL be drawn as point ranges. The x-axis variable SHALL default from the prediction's metadata and be overridable through `x`; the remaining grouping variables SHALL be faceted, the x-axis variable never. `max_facets` SHALL cap the panels drawn with a warning giving how many were shown. The plot SHALL draw only the predictions; raw data are not overlaid, and a user can add them as a layer. The y-axis SHALL extend to zero. Axis titles SHALL be descriptive (e.g. "Sub-bulb diameter", "Wet weight"). When the prediction's metadata has been stripped, it SHALL error asking for `x`.

#### Scenario: Curves get a ribbon, rows get points
- **WHEN** a curve from `kb_predict_weight_by()` and rows from `kb_predict_weight()` are plotted
- **THEN** the first is a line with a ribbon and the second point ranges

#### Scenario: Two grouping factors
- **WHEN** point-range predictions grouped by site and year are plotted
- **THEN** year is on the x-axis and site is faceted

#### Scenario: Size by site
- **WHEN** `kb_predict_size_by(fit, by = "site")` is plotted
- **THEN** point ranges are drawn per site, and the y-axis is titled with the size response

#### Scenario: Too many facets
- **WHEN** a prediction has more groups than `max_facets`
- **THEN** only `max_facets` panels are drawn and a warning reports how many were shown

#### Scenario: Raw data can be added as a layer
- **WHEN** a weight curve plot gets `+ geom_point(aes(diameter_mm, weight_kg), data = fit$data)`
- **THEN** the plot builds with the raw data drawn over the curve

### Requirement: Values far outside the fitted range are flagged

Prediction SHALL warn when supplied values of the species predictor lie below half the fitted minimum or above twice the fitted maximum, or supplied `stipes_m2` values (for a fit with the density effect) lie above twice the fitted maximum, naming the column, the fitted range, and the column's expected unit where it has one. This applies to `new_data` and to a predictor sequence supplied to `kb_predict_weight_by()`. The warning SHALL NOT stop the prediction. The message is pinned by `tests/testthat/_snaps/warn_outside_range.md`.

#### Scenario: Diameter in centimetres at prediction is flagged
- **WHEN** `new_data` gives `diameter_mm` in centimetres to a fit made in millimetres
- **THEN** a warning names `diameter_mm` and the fitted range, and predictions are still returned

#### Scenario: Values within the fitted range raise no warning
- **WHEN** supplied values lie within twice the fitted range
- **THEN** no warning is issued

### Requirement: New data predictor values are validated

`new_data` SHALL be validated before prediction: it SHALL be a data frame; for weight, *Nereocystis* `diameter_mm` SHALL be numeric, greater than 0, with no missing values, and *Macrocystis* `fronds` a positive whole number with no missing values. Size `new_data` needs no predictor column. An invalid value SHALL error with a message naming the column, pinned by `tests/testthat/_snaps/chk.md`.

#### Scenario: An impossible diameter errors
- **WHEN** weight `new_data` has a `diameter_mm` that is zero, negative, missing, or not numeric
- **THEN** prediction errors naming `diameter_mm`

#### Scenario: A fractional frond count errors
- **WHEN** weight `new_data` has a non-whole `fronds` value
- **THEN** prediction errors naming `fronds`

#### Scenario: Size new data need no columns
- **WHEN** `kb_predict_size(fit, new_data)` is called with a data frame of only `site`, or of no columns and `n` rows
- **THEN** it returns one prediction per row
