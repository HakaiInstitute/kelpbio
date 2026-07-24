## MODIFIED Requirements

### Requirement: Predict allometric curves

Prediction is split into two verbs with independent arguments.
`kb_predict_weight(fit, new_data, new_levels, representative_site, conf_level,
estimate, sig_fig)` SHALL predict weight at the rows supplied in `new_data` (a
data frame with the fit's predictor column and optional `site` / `year`
columns), or at the observed data when `new_data = NULL`, returning a
`kb_predictions` object. The predictor column is the fit's `meta$predictor`:
`diameter` for a nereo fit, `fronds` for a macro fit. It SHALL NOT take a `by`
argument. Both verbs are computed from the fit's stored draws via the
species-specific linear-predictor builder selected on `meta$species`
(`.weight_nereo_linpred()` or `.weight_macro_linpred()`), per
`decisions/prediction-engine.md`.

`representative_site` SHALL borrow a named fit site's site main effects for any
new or absent site. For nereo these are the `bSite` intercept and
`bSiteDiameter` slope; for macro, which has no site slope, only the `bSite`
intercept. Its other semantics are unchanged.

#### Scenario: Macro predicts from a fronds column
- **WHEN** `kb_predict_weight(macro_fit, new_data)` is called with `new_data`
  carrying a `fronds` column
- **THEN** predictions are returned at those rows, with `fronds` entering through
  `log(fronds) - log(fronds_ref)` using the stored `meta$fronds_ref`

#### Scenario: Wrong predictor column errors
- **WHEN** `new_data` lacks the fit's predictor column (e.g. a `diameter` column
  passed to a macro fit)
- **THEN** it errors with a `cli` message naming the required column
  (`fronds` for macro)

#### Scenario: Predict at observed data agrees with augment
- **WHEN** `kb_predict_weight(macro_fit)` is called with `new_data = NULL`
- **THEN** it returns predictions at the observed rows conditioned on each row's
  site and year, whose `estimate` equals `augment(macro_fit)`'s fitted values

### Requirement: Grouping and uncertainty axes

`kb_predict_weight_by(fit, by, new_levels, <predictor>, conf_level, estimate,
sig_fig)` SHALL summarise the weight-at-predictor relationship over a predictor
sequence (auto-generated over the observed range, or supplied) as a
`kb_predictions` object, with a `by` grouping axis and a `new_levels =
c("average", "sample")` axis (`"average"` default). The predictor sequence
argument and grid variable are the fit's `meta$predictor` (`diameter` for nereo,
`fronds` for macro). `by` names the grouping factors that each get their own
curve; its available values depend on the fitted random-effect structure. For
nereo they are `NULL`, `"site"`, and `c("site", "year")` (year enters only
through the site:year interaction). For macro, which has a standalone year main
effect, they additionally include `"year"` and `c("site", "year")`.
`new_levels` governs the factors not conditioned on: `"sample"` draws a new
random effect from `Normal(0, s)`, `"average"` holds it at zero.

#### Scenario: year is a valid grouping for macro
- **WHEN** `kb_predict_weight_by(macro_fit, by = "year")` is called
- **THEN** it returns one curve per year, each conditioned on that year's
  estimated `bYear` main effect, with the site and site:year effects following
  `new_levels`

#### Scenario: year alone is not valid for nereo
- **WHEN** `kb_predict_weight_by(nereo_fit, by = "year")` is called
- **THEN** it errors with a `cli` message explaining that year enters the nereo
  weight model only through the `site:year` interaction (there is no year main
  effect), so the groupings are `NULL`, `"site"`, and `c("site", "year")`

### Requirement: Raw prediction draws via rstantools generics

Raw posterior prediction draws SHALL be provided through the `rstantools`
generics. `posterior_epred()`, `posterior_linpred()`, and `posterior_predict()`
SHALL return a draws-by-observations (`D x N`) matrix for a `kb_fit_weight`,
accepting `newdata`, a `new_levels = c("sample", "average")` axis, and a
`representative_site = NULL` axis, with no `by` argument. `posterior_linpred()`
returns the log-scale mean and `posterior_epred()` returns its exponential
(response-scale expected weight) for both species. Conditioning is resolved per
row, per factor by level membership, dispatching the linear predictor on
`meta$species`. `posterior_predict()` adds species-appropriate observation noise:
Student-t (scale `sWeight`) for nereo, Gamma (`shape = alpha * fronds`, `rate =
shape / eWeight`) for macro; with `newdata = NULL` it returns the stored `yrep`.

#### Scenario: Macro posterior_predict adds Gamma noise
- **WHEN** `posterior_predict(macro_fit, newdata = grid)` is called
- **THEN** it returns a `D x N` matrix of strictly positive weights drawn from
  `gamma(alpha * fronds, alpha * fronds / eWeight)`; with `newdata = NULL` it
  returns the stored `yrep`

#### Scenario: posterior_epred exponentiates the linear predictor
- **WHEN** `posterior_epred(macro_fit, newdata = grid)` is called
- **THEN** it returns the response-scale expected weight `exp(linpred)`, equal to
  the Gamma mean `eWeight`, with draws as rows and grid rows as columns
