# predictions

## Purpose

Predicting from a fit: the two prediction verbs, how groups and optional inputs
are resolved per row, the rstantools draw generics, and plotting predictions.
## Requirements
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

### Requirement: Groups are resolved per row

A row whose `site`, `year`, or site-year is a fitted level SHALL be conditioned on that level's estimated effect. A new level or an absent grouping column SHALL be handled by `new_levels`: `"sample"` draws a new effect from its estimated distribution, and `"average"` sets it to zero (the typical group). The default SHALL be `"sample"` for the row-wise verbs (`kb_predict_weight()`, `kb_predict_size()`) and the `posterior_*()` generics, and `"average"` for the `_by` verbs. A new level SHALL NOT error. `representative_site` SHALL instead give a new or absent site the estimated site effect of the named fitted site(s), averaged per draw when several are named, while site:year still follows `new_levels`; a name not in the fit SHALL error listing the fitted sites. An effect the fit omitted SHALL contribute nothing, under any `new_levels`.

#### Scenario: New levels are sampled or averaged
- **WHEN** `new_data` holds a site the fit never saw
- **THEN** the prediction does not error; `"sample"` gives an interval at least as wide as `"average"`

#### Scenario: A representative site stands in for a new site
- **WHEN** a new site is predicted with `representative_site = s` and `new_levels = "average"` and no `year` column
- **THEN** the prediction equals predicting fitted site `s` with the same other inputs

#### Scenario: An omitted site:year effect adds nothing
- **WHEN** the fit omitted the site:year effect
- **THEN** `new_levels = "sample"` adds no site:year variation

### Requirement: Density is resolved per row

For a *Nereocystis* fit with the density effect, each row SHALL use its `stipes_m2` value if present, otherwise the recorded density of its site-year in the fitted data, otherwise the fitted mean. This applies to every prediction and summary computed at rows, including the observed data. A `stipes_m2` column in `new_data` SHALL be validated (numeric, `>= 0`, `NA` allowed) and is ignored by a fit without the density effect.

#### Scenario: Resolution order
- **WHEN** rows supply `stipes_m2`, omit it for a fitted site-year with recorded density, and omit it for a new site-year
- **THEN** they use the supplied value, the recorded value, and the fitted mean, respectively

#### Scenario: Curves by site and year use recorded densities
- **WHEN** `kb_predict_weight_by(fit, by = c("site", "year"))` is called
- **THEN** each curve uses its site-year's recorded density, and other `by` values use the fitted mean

### Requirement: Draws, likelihood, and priors

`posterior_epred()`, `posterior_linpred()`, and `posterior_predict()` SHALL return a draws-by-rows matrix for `new_data` (or the observed data), resolving groups and density as above. `posterior_epred()` SHALL give the expected response. Where that differs from the inverse link of the linear predictor, `posterior_linpred(transform = TRUE)` SHALL return the inverse link:

- *Nereocystis* weight, whose log weight is Normal: the expected weight is `exp(mu + sWeight^2 / 2)`, above the median `exp(mu)`.
- *Macrocystis* size, whose frond count is a zero-truncated negative binomial: the expected count is the truncated mean, above the untruncated mean `exp(mu)`.

The prediction verbs, `fitted()`, and `augment()` SHALL summarise `posterior_epred()`. `posterior_predict()` SHALL add observation noise from the model's likelihood, so repeated calls differ unless a seed is set; for size it draws plant sizes, and *Macrocystis* draws are whole numbers of at least 1. `log_lik()` SHALL return the deterministic pointwise log-likelihood of the observed data, suitable for `loo::loo()`, and error for a fit with no observations. `prior_summary()` SHALL return the priors used.

#### Scenario: Expected weight exceeds the median for Nereocystis
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Nereocystis* weight rows
- **THEN** each draw of the former equals the latter times `exp(sWeight^2 / 2)`

#### Scenario: Expected frond count exceeds the untruncated mean
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Macrocystis* size rows
- **THEN** each draw of the former is greater than the latter and at least 1

#### Scenario: Predictive draws are reproducible under a seed
- **WHEN** `posterior_predict()` is called twice after the same `set.seed()`
- **THEN** it returns identical draws

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

