# predictions

## MODIFIED Requirements

### Requirement: Predict allometric curves

Prediction is split into two verbs with independent arguments. `kb_predict_weight(fit, new_data, new_levels, conf_level, estimate, sig_fig)` SHALL predict weight at the rows supplied in `new_data` (a data frame with a `diameter` column and optional `site` / `year` columns), or at the observed data when `new_data = NULL` (matching base R `predict()`), returning a `kb_predictions` object. It SHALL NOT take a `by` argument. `kb_predict_weight_by()` (a separate requirement) provides the curve summary. Both are computed from the fit's stored draws via the single internal helper `.weight_linpred()`.

#### Scenario: Predict at observed data
- **WHEN** `kb_predict_weight(fit)` is called with `new_data = NULL`
- **THEN** it returns predictions at the observed rows, conditioned on each row's site and year, with `estimate`/`lower`/`upper`; the `estimate` equals `augment(fit)`'s fitted values

#### Scenario: Prediction at supplied new_data
- **WHEN** `new_data` is supplied with a `diameter` column
- **THEN** predictions are returned at exactly those rows

#### Scenario: Predictor enters on a fixed-reference scale
- **WHEN** predictions are formed at any diameter
- **THEN** the diameter enters through the fixed transform `log(diameter) - log(30)` with no training-data-dependent rescaling step

### Requirement: Grouping and uncertainty axes

`kb_predict_weight_by(fit, by, new_levels, diameter, ...)` SHALL summarise the weight-at-diameter relationship over a diameter sequence (auto-generated over the observed range, or supplied via `diameter`) as a `kb_predictions` object, with a `by` grouping axis and a `new_levels = c("sample", "average")` axis (`"sample"` default), validated with `rlang::arg_match()`. It SHALL NOT take a `new_data` argument. `by` names the grouping factors that each get their own curve, conditioned on their estimated random effects; its available values are `NULL`, `"site"`, and `c("site", "year")`. `new_levels` governs the factors not conditioned on: `"sample"` draws a new random effect from `Normal(0, s)`, `"average"` holds it at zero.

#### Scenario: Population curve, new group vs typical group
- **WHEN** `kb_predict_weight_by(fit, new_levels = "sample")` vs `new_levels = "average"` with `by = NULL`
- **THEN** both return a single population curve over a diameter-only grid; `"sample"` draws fresh site, site-slope, and site:year effects (band includes between-group variation) and `"average"` holds them at zero (the typical-group curve), giving a `"sample"` interval at least as wide as `"average"`

#### Scenario: Per-site and per-site-year curves
- **WHEN** `by = "site"` or `by = c("site", "year")`
- **THEN** one curve per group is returned, conditioned on the group's estimated random effects; under `by = "site"` the omitted site:year effect follows `new_levels`

#### Scenario: year alone is not a valid grouping
- **WHEN** `by = "year"` is supplied
- **THEN** it errors with a `cli` message explaining that year enters only through the `site:year` interaction (no year main effect)

### Requirement: Raw prediction draws via rstantools generics

Raw posterior prediction draws SHALL be provided through the `rstantools` generics. `posterior_epred()`, `posterior_linpred()`, and `posterior_predict()` SHALL return a draws-by-observations (`D x N`) matrix for a `kb_fit_weight`, accepting `newdata` and a `new_levels = c("sample", "average")` axis, with no `by` argument. Conditioning SHALL be resolved per row, per factor by level membership: a row whose `site`/`year` is a known level is conditioned on its estimated random effect; a new level, or an absent grouping column, is handled by `new_levels` (`"sample"` draws, `"average"` zeroes). A new (unseen) level SHALL NOT error. With `newdata = NULL` the generics use the observed data and condition on its site and year, so `posterior_epred()`, `posterior_predict()`, and `augment()` agree at the observed data.

#### Scenario: posterior_epred returns the prediction draws
- **WHEN** `posterior_epred(fit, newdata = grid)` is called
- **THEN** it returns a `D x N` matrix of response-scale expected weight, draws as rows and grid rows as columns

#### Scenario: A new level is sampled, not errored
- **WHEN** `newdata` contains a `site` (or `year`) level the fit never saw
- **THEN** that row's affected random effects are drawn per `new_levels` (no error); a mix of known and new levels resolves per row in one call

#### Scenario: newdata = NULL conditions on the observed groups
- **WHEN** any generic is called with `newdata = NULL`
- **THEN** it evaluates at the observed data conditioning on each row's site and year, so its central estimate matches `augment()`'s fitted values (`posterior_predict()` adds observation noise and with `newdata = NULL` returns the stored `yrep`)

#### Scenario: posterior_predict adds observation noise
- **WHEN** `posterior_predict(fit, newdata = grid)` is called
- **THEN** it returns a `D x N` matrix adding Student-t observation noise (scale `sWeight`) to the expected weight
