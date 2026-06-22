# predictions

## Purpose

Predicting from a fitted model: the two prediction verbs (kb_predict_weight() for new data, kb_predict_weight_by() for curves), the rstantools generics (posterior_epred / posterior_linpred / posterior_predict / log_lik), per-row level resolution, the new_levels axis, prior_summary(), and the kb_predictions object.

## Requirements

### Requirement: Predict allometric curves

Prediction is split into two verbs with independent arguments. `kb_predict_weight(fit, new_data, new_levels, representative_site, conf_level, estimate, sig_fig)` SHALL predict weight at the rows supplied in `new_data` (a data frame with a `diameter` column and optional `site` / `year` columns), or at the observed data when `new_data = NULL` (matching base R `predict()`), returning a `kb_predictions` object. It SHALL NOT take a `by` argument. Both verbs are computed from the fit's stored draws via the single internal helper `.weight_nereo_linpred()` specified in `decisions/prediction-engine.md`.

`representative_site` SHALL be `NULL` (default) or a character vector of site levels present in the fit, validated with a `cli` error naming any value not in `meta$site_levels`. When non-`NULL`, any new or absent site SHALL take its site main effects (the `bSite` intercept and `bSiteDiameter` slope) from the named reference site, or the per-draw average across the reference sites when more than one is given, instead of the `new_levels` treatment. `representative_site` SHALL affect only the site main effects; the `site:year` interaction for new combinations is still governed by `new_levels`, which remains the sole control of new-site handling when `representative_site = NULL`. Rows whose site is a known level are conditioned on their own estimated effects regardless of `representative_site`.

#### Scenario: Predict at observed data
- **WHEN** `kb_predict_weight(fit)` is called with `new_data = NULL`
- **THEN** it returns predictions at the observed rows, conditioned on each row's site and year, with `estimate`/`lower`/`upper`; the `estimate` equals `augment(fit)`'s fitted values

#### Scenario: Prediction at supplied new_data
- **WHEN** `new_data` is supplied with a `diameter` column
- **THEN** predictions are returned at exactly those rows

#### Scenario: Predictor enters on a stored-reference scale
- **WHEN** predictions are formed at any diameter
- **THEN** the diameter enters through the transform `log(diameter) - log(diameter_ref)`, where `diameter_ref` is the geometric mean of the observed diameter computed at fit time and stored in `meta$diameter_ref`; new data uses that same stored reference (no re-derivation from the new data), and centering in log space makes the diameter unit immaterial and predictions scale-invariant

#### Scenario: Representative site borrows a known site's main effects
- **WHEN** `new_data` contains a site the fit never saw and `representative_site` names one or more fit sites
- **THEN** that row's `bSite` intercept and `bSiteDiameter` slope are the reference site's estimated effects (the per-draw average when several are named), while its `site:year` term still follows `new_levels`; with `new_levels = "average"` and no `year` column the prediction equals predicting the named reference site at the same diameter

#### Scenario: Unknown representative site errors
- **WHEN** `representative_site` contains a value not in `meta$site_levels`
- **THEN** it errors with a `cli` message naming the offending value(s) and listing the available sites

### Requirement: Grouping and uncertainty axes

`kb_predict_weight_by(fit, by, new_levels, diameter, conf_level, estimate, sig_fig)` SHALL summarise the weight-at-diameter relationship over a diameter sequence (auto-generated over the observed range, or supplied via `diameter`) as a `kb_predictions` object, with a `by` grouping axis and a `new_levels = c("sample", "average")` axis (`"sample"` default), validated with `rlang::arg_match()`. It SHALL NOT take a `new_data` argument. `by` names the grouping factors that each get their own curve, conditioned on their estimated random effects; its available values are `NULL`, `"site"`, and `c("site", "year")`. `new_levels` governs the factors not conditioned on: `"sample"` draws a new random effect from `Normal(0, s)`, `"average"` holds it at zero.

#### Scenario: Population curve, new group vs typical group
- **WHEN** `kb_predict_weight_by(fit, new_levels = "sample")` vs `new_levels = "average"` with `by = NULL`
- **THEN** both return a single population curve over a diameter-only grid; `"sample"` draws fresh site, site-slope, and site:year effects (band includes between-group variation) and `"average"` holds them at zero (the typical-group curve), giving a `"sample"` interval at least as wide as `"average"`

#### Scenario: Per-site and per-site-year curves
- **WHEN** `by = "site"` or `by = c("site", "year")`
- **THEN** one curve per group is returned, conditioned on the group's estimated random effects; under `by = "site"` the omitted site:year effect follows `new_levels`

#### Scenario: year alone is not a valid grouping for the weight model
- **WHEN** `by = "year"` is supplied
- **THEN** it errors with a `cli` message explaining that year enters the weight model only through the `site:year` interaction (there is no year main effect), so the available groupings are `NULL`, `"site"`, and `c("site", "year")`

### Requirement: Raw prediction draws via rstantools generics

Raw posterior prediction draws SHALL be provided through the `rstantools` generics rather than a bespoke `_samples()` function. `posterior_epred()`, `posterior_linpred()`, and `posterior_predict()` SHALL return a draws-by-observations (`D x N`) matrix for a `kb_fit_weight`, accepting `newdata`, a `new_levels = c("sample", "average")` axis, and a `representative_site = NULL` axis, with no `by` argument. Conditioning SHALL be resolved per row, per factor by level membership: a row whose `site`/`year` is a known level is conditioned on its estimated random effect; a new level, or an absent grouping column, is handled by `new_levels` (`"sample"` draws, `"average"` zeroes), except that when `representative_site` is non-`NULL` a new/absent site takes its site main effects from the named reference site(s) (per-draw average across several). A new (unseen) level SHALL NOT error. With `newdata = NULL` the generics use the observed data and condition on its site and year, so `posterior_epred()`, `posterior_predict()`, and `augment()` agree at the observed data.

#### Scenario: posterior_epred returns the prediction draws
- **WHEN** `posterior_epred(fit, newdata = grid)` is called
- **THEN** it returns a `D x N` matrix of response-scale expected weight (`exp` of the linear predictor), draws as rows and grid rows as columns

#### Scenario: A new level is sampled, not errored
- **WHEN** `newdata` contains a `site` (or `year`) level the fit never saw
- **THEN** that row's affected random effects are drawn per `new_levels` (no error); a mix of known and new levels resolves per row in one call

#### Scenario: Representative site borrows a known site's main effects
- **WHEN** `posterior_epred(fit, newdata = grid, representative_site = s)` is called with `grid` containing a new site and `s` a fit site
- **THEN** the new site's `bSite` and `bSiteDiameter` are taken from `s` (per-draw average if `s` names several), with the `site:year` term still resolved per `new_levels`

#### Scenario: newdata = NULL conditions on the observed groups
- **WHEN** any of `posterior_epred()`, `posterior_linpred()`, or `posterior_predict()` is called with `newdata = NULL`
- **THEN** it evaluates at the observed data conditioning on each row's observed site and year, so its central estimate matches `augment()`'s fitted values (`posterior_predict()` additionally adds observation noise, and with `newdata = NULL` returns the stored `yrep`)

#### Scenario: posterior_predict adds observation noise
- **WHEN** `posterior_predict(fit, newdata = grid)` is called
- **THEN** it returns a `D x N` matrix that adds Student-t observation noise (scale `sWeight`) to the expected weight; with `newdata = NULL` it returns the stored `yrep`

### Requirement: Pointwise log-likelihood and prior summary

`log_lik()` SHALL return the `D x N` pointwise log-likelihood for a `kb_fit_weight` (from the Stan generated quantities), enabling `loo::loo()`; `prior_summary()` SHALL return the resolved priors.

#### Scenario: log_lik enables loo
- **WHEN** `log_lik(fit)` is called
- **THEN** it returns the `D x N` pointwise log-likelihood matrix suitable for `loo::loo()`

#### Scenario: prior_summary reports the priors
- **WHEN** `prior_summary(fit)` is called
- **THEN** it returns the resolved prior objects used in the fit

### Requirement: kb_predictions carries plotting metadata

The `kb_predictions` object SHALL be a tibble subclass carrying column-role metadata (predictor, grouping variables, response and units) as attributes. It SHALL also carry a `kb_curve` flag recording whether the rows form an ordered, generated grid over the predictor (ribbon-eligible) rather than scattered supplied rows. The grid-generating verb (`kb_predict_weight_by()`) SHALL set it true; the row-wise verb (`kb_predict_weight()` / `predict()`) SHALL set it false. Plotting consumes the flag to choose a ribbon (only for a generated curve over a varying predictor) versus grouped points.

#### Scenario: Metadata attributes present
- **WHEN** a `kb_predictions` object is produced
- **THEN** it records the predictor column, the grouping variables (from `by`), the response name/units, and the `kb_curve` flag, while still behaving as a tibble

#### Scenario: Curve flag distinguishes the prediction verbs
- **WHEN** the prediction comes from `kb_predict_weight_by()` versus `kb_predict_weight()`
- **THEN** `kb_curve` is true for the former (a generated curve) and false for the latter (supplied rows)
