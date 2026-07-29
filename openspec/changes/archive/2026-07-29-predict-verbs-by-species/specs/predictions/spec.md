## MODIFIED Requirements

### Requirement: Predict allometric curves

Prediction is split into two verbs, each an S3 generic dispatching on the fit's species subclass (`kb_fit_weight_nereo`, `kb_fit_weight_macro`). `kb_predict_weight(fit, new_data, ..., new_levels, representative_site, conf_level, estimate, sig_fig)` SHALL predict weight at the rows supplied in `new_data` (a data frame with the fit's predictor column -- `diameter` for *Nereocystis*, `fronds` for *Macrocystis* -- and optional `site` / `year` columns), or at the observed data when `new_data = NULL` (matching base R `predict()`), returning a `kb_predictions` object. It SHALL NOT take a `by` argument. Each species method delegates to a shared internal implementation, so the methods differ only in their species-specific argument and documentation, not in behaviour. Both verbs are computed from the fit's stored draws via the `.weight_linpred()` internal generic, which dispatches on the fit subclass to the species-specific mean, per `decisions/prediction-engine.md`.

`representative_site` SHALL be `NULL` (default) or a character vector of site levels present in the fit, validated with a `cli` error naming any value not in `meta$site_levels`. When non-`NULL`, any new or absent site SHALL take its site main effects from the named reference site, or the per-draw average across the reference sites when more than one is given, instead of the `new_levels` treatment. The site main effects are the `bSite` intercept and (for *Nereocystis*) the `bSiteDiameter` slope; the *Macrocystis* model has no site slope, so only the `bSite` intercept is borrowed. `representative_site` SHALL affect only the site main effects; the `site:year` interaction for new combinations is still governed by `new_levels`, which remains the sole control of new-site handling when `representative_site = NULL`. Rows whose site is a known level are conditioned on their own estimated effects regardless of `representative_site`.

#### Scenario: The verbs dispatch on the fit species
- **WHEN** `kb_predict_weight()` or `kb_predict_weight_by()` is called on a `kb_fit_weight_nereo` versus a `kb_fit_weight_macro`
- **THEN** it dispatches to that species' method, which exposes `diameter` (*Nereocystis*) or `fronds` (*Macrocystis*) as the predictor argument for the curve verb and validates the species-appropriate `new_data` predictor column for the row-wise verb

#### Scenario: Predict at observed data
- **WHEN** `kb_predict_weight(fit)` is called with `new_data = NULL`
- **THEN** it returns predictions at the observed rows, conditioned on each row's site and year, with `estimate`/`lower`/`upper`; the `estimate` equals `augment(fit)`'s fitted values

#### Scenario: Prediction at supplied new_data
- **WHEN** `new_data` is supplied with the fit's predictor column
- **THEN** predictions are returned at exactly those rows

#### Scenario: Predictor enters on a stored-reference scale
- **WHEN** predictions are formed at any predictor value
- **THEN** the predictor enters through the transform `log(x) - log(x_ref)`, where `x_ref` is the geometric mean of the observed predictor computed at fit time and stored in `meta` (`diameter_ref` for *Nereocystis*, `fronds_ref` for *Macrocystis*); new data uses that same stored reference (no re-derivation from the new data), and centering in log space makes the predictor unit immaterial and predictions scale-invariant

#### Scenario: Representative site borrows a known site's main effects
- **WHEN** `new_data` contains a site the fit never saw and `representative_site` names one or more fit sites
- **THEN** that row's site main effects are the reference site's estimated effects (the per-draw average when several are named), while its `site:year` term still follows `new_levels`; with `new_levels = "average"` and no `year` column the prediction equals predicting the named reference site at the same predictor value

#### Scenario: Unknown representative site errors
- **WHEN** `representative_site` contains a value not in `meta$site_levels`
- **THEN** it errors with a `cli` message naming the offending value(s) and listing the available sites

#### Scenario: Macro predicts from a fronds column
- **WHEN** `kb_predict_weight(macro_fit, new_data)` is called with `new_data` carrying a `fronds` column
- **THEN** predictions are returned at those rows, with `fronds` entering through `log(fronds) - log(fronds_ref)` using the stored `meta$fronds_ref`

#### Scenario: Wrong predictor column errors
- **WHEN** `new_data` lacks the fit's predictor column (e.g. a `diameter` column passed to a *Macrocystis* fit)
- **THEN** it errors with a `cli` message naming the required column (`fronds` for *Macrocystis*)

### Requirement: Grouping and uncertainty axes

`kb_predict_weight_by()` is an S3 generic dispatching on the fit's species subclass. The *Nereocystis* method is `kb_predict_weight_by(fit, by = NULL, diameter = NULL, ..., new_levels, conf_level, estimate, sig_fig)`; the *Macrocystis* method takes `fronds = NULL` in place of `diameter`. Each SHALL summarise the weight-at-predictor relationship over a predictor sequence (auto-generated over the observed range, or supplied via the species argument `diameter` / `fronds`) as a `kb_predictions` object, with a `by` grouping axis and a `new_levels = c("average", "sample")` axis (`"average"` default), validated with `rlang::arg_match()`. It SHALL NOT take a `new_data` argument, and SHALL NOT expose a generic `predictor` argument. The grid variable is the fit's `meta$predictor` (`diameter` for *Nereocystis*, `fronds` for *Macrocystis*). Passing the other species' predictor argument (for example `fronds` to a *Nereocystis* fit) SHALL error with a `cli` message naming the correct argument. `by` names the grouping factors that each get their own curve, conditioned on their estimated random effects; its available values depend on the fitted random-effect structure: `NULL`, `"site"`, and `c("site", "year")` for both species, and additionally `"year"` for *Macrocystis* (which has a year main effect). `new_levels` governs the factors not conditioned on: `"sample"` draws a new random effect from `Normal(0, s)`, `"average"` holds it at zero.

#### Scenario: Predictor sequence supplied via the species argument
- **WHEN** `kb_predict_weight_by(nereo_fit, diameter = c(20, 40))` or `kb_predict_weight_by(macro_fit, fronds = c(2, 5))`
- **THEN** the curve grid uses the supplied values instead of the auto-generated observed-range sequence, and the predictor column of the result is named `diameter` or `fronds` accordingly

#### Scenario: Wrong-species predictor argument errors
- **WHEN** the other species' predictor argument is supplied (`fronds =` to a *Nereocystis* fit, or `diameter =` to a *Macrocystis* fit)
- **THEN** it errors with a `cli` message naming the correct argument for that species (`diameter` for *Nereocystis*, `fronds` for *Macrocystis*)

#### Scenario: Population curve, new group vs typical group
- **WHEN** `kb_predict_weight_by(fit, new_levels = "sample")` vs `new_levels = "average"` with `by = NULL`
- **THEN** both return a single population curve over a predictor-only grid; `"sample"` draws fresh random effects (band includes between-group variation) and `"average"` holds them at zero (the typical-group curve), giving a `"sample"` interval at least as wide as `"average"`

#### Scenario: Per-site and per-site-year curves
- **WHEN** `by = "site"` or `by = c("site", "year")`
- **THEN** one curve per group is returned, conditioned on the group's estimated random effects; under `by = "site"` the omitted site:year effect follows `new_levels`

#### Scenario: year alone is not a valid grouping for the weight model
- **WHEN** `by = "year"` is supplied to a *Nereocystis* fit
- **THEN** it errors with a `cli` message explaining that year enters the *Nereocystis* weight model only through the `site:year` interaction (there is no year main effect), so the available groupings are `NULL`, `"site"`, and `c("site", "year")`

#### Scenario: year is a valid grouping for the Macrocystis model
- **WHEN** `by = "year"` is supplied to a *Macrocystis* fit
- **THEN** it returns one curve per year, each conditioned on that year's estimated `bYear` main effect, with the site and site:year effects following `new_levels`
