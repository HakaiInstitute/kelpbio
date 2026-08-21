## MODIFIED Requirements

### Requirement: Predict allometric curves

Prediction is split into two verbs, each an S3 generic dispatching on the fit's species subclass (`kb_fit_weight_nereo`, `kb_fit_weight_macro`). `kb_predict_weight(fit, new_data, ..., new_levels, representative_site, conf_level, estimate, sig_fig)` SHALL predict weight at the rows supplied in `new_data` (a data frame with the fit's predictor column -- `diameter` for *Nereocystis*, `fronds` for *Macrocystis* -- and optional `site` / `year` columns), or at the observed data when `new_data = NULL` (matching base R `predict()`), returning a `kb_predictions` object. It SHALL NOT take a `by` argument. Each species method delegates to a shared internal implementation, so the methods differ only in their species-specific argument and documentation, not in behaviour. Both verbs are computed from the fit's stored draws via the `.linpred()` internal internal generic, which dispatches on the fit subclass to the model's mean, per `decisions/prediction-engine.md`.

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

### Requirement: Raw prediction draws via rstantools generics

Raw posterior prediction draws SHALL be provided through the `rstantools` generics rather than a bespoke `_samples()` function. `posterior_epred()`, `posterior_linpred()`, and `posterior_predict()` SHALL return a draws-by-observations (`D x N`) matrix for a `kb_fit`, accepting `new_data`, a `new_levels = c("sample", "average")` axis, and a `representative_site = NULL` axis, with no `by` argument. `posterior_linpred()` returns the link-scale mean; `posterior_epred()` returns the response-scale expectation, and `posterior_linpred(transform = TRUE)` the inverse link. Both route through the `.epred()` internal generic, whose `expectation` flag distinguishes them: they coincide unless the likelihood is a mixture, so for both weight models each is `exp()` of the linear predictor. Conditioning SHALL be resolved per row, per factor by level membership, dispatching the linear predictor on the fit subclass: a row whose `site`/`year` is a known level is conditioned on its estimated random effect; a new level, or an absent grouping column, is handled by `new_levels` (`"sample"` draws, `"average"` zeroes), except that when `representative_site` is non-`NULL` a new/absent site takes its site main effects from the named reference site(s) (per-draw average across several). A new (unseen) level SHALL NOT error. With `new_data = NULL` the generics use the observed data and condition on its site and year, so `posterior_epred()`, `posterior_predict()`, and `augment()` agree at the observed data. `posterior_predict()` SHALL add species-appropriate observation noise: Student-t (scale `sWeight`) for *Nereocystis*, Gamma (shape `shape`) for *Macrocystis*. That noise SHALL be drawn in R for every `new_data`, including `NULL`, so `posterior_predict()` is RNG-dependent and `set.seed()` gives reproducible draws; with `new_data = NULL` on a zero-observation fit it SHALL error rather than return an empty matrix.

#### Scenario: posterior_epred returns the prediction draws
- **WHEN** `posterior_epred(fit, new_data = grid)` is called
- **THEN** it returns a `D x N` matrix of the response-scale value of the linear predictor, draws as rows and grid rows as columns

#### Scenario: A new level is sampled, not errored
- **WHEN** `new_data` contains a `site` (or `year`) level the fit never saw
- **THEN** that row's affected random effects are drawn per `new_levels` (no error); a mix of known and new levels resolves per row in one call

#### Scenario: Representative site borrows a known site's main effects
- **WHEN** `posterior_epred(fit, new_data = grid, representative_site = s)` is called with `grid` containing a new site and `s` a fit site
- **THEN** the new site's site main effects are taken from `s` (per-draw average if `s` names several), with the `site:year` term still resolved per `new_levels`

#### Scenario: new_data = NULL conditions on the observed groups
- **WHEN** any of `posterior_epred()`, `posterior_linpred()`, or `posterior_predict()` is called with `new_data = NULL`
- **THEN** it evaluates at the observed data conditioning on each row's observed site and year, so its central estimate matches `augment()`'s fitted values (`posterior_predict()` additionally adds observation noise, drawn in R)

#### Scenario: posterior_predict adds observation noise
- **WHEN** `posterior_predict(fit, new_data = grid)` is called
- **THEN** it returns a `D x N` matrix that adds the species-appropriate observation noise to the expected weight (Student-t scale `sWeight` for *Nereocystis*), and does so for `new_data = NULL` too

#### Scenario: Macro posterior_predict adds Gamma noise
- **WHEN** `posterior_predict(macro_fit, new_data = grid)` is called
- **THEN** it returns a `D x N` matrix of strictly positive weights drawn from `gamma(shape, shape / eWeight)`, and does so for `new_data = NULL` too

### Requirement: Pointwise log-likelihood and prior summary

`log_lik()` SHALL return the `D x N` pointwise log-likelihood for a `kb_fit`, enabling `loo::loo()`. It SHALL be recomputed in R from the stored draws by evaluating the model's own likelihood at the observed data, and SHALL be deterministic. The density is of the response on the scale the model fits it (log weight for *Nereocystis*, weight for *Macrocystis*) with no Jacobian adjustment, matching the Stan likelihood. It SHALL error for a zero-observation fit. `prior_summary()` SHALL return the resolved priors.

#### Scenario: log_lik enables loo
- **WHEN** `log_lik(fit)` is called
- **THEN** it returns the `D x N` pointwise log-likelihood matrix suitable for `loo::loo()`

#### Scenario: log_lik errors for a zero-observation fit
- **WHEN** `log_lik(fit)` is called on a fit with no observed rows
- **THEN** it errors, since a zero-observation fit has no pointwise likelihood and `loo::loo()` has nothing to weight

#### Scenario: prior_summary reports the priors
- **WHEN** `prior_summary(fit)` is called
- **THEN** it returns the resolved prior objects used in the fit

### Requirement: Predictions respect the fitted site:year structure

Predictions SHALL reflect whether the fit retained the site:year effect. When the fit omitted the effect (`meta$site_year_on` is `FALSE`), the prediction engine (the `.linpred()` internal generic and its per-species methods) and all verbs and generics built on it SHALL add no site:year contribution or variation, for any `new_levels` value; the prior-only `bSiteYear` / `sSiteYear` draws SHALL NOT be reintroduced.

#### Scenario: Omitted site:year adds no variation
- **WHEN** predictions are formed from a fit whose `meta$site_year_on` is `FALSE`
- **THEN** the site:year term contributes nothing to the linear predictor, and `new_levels = "sample"` adds no site:year between-year variation (only the site intercept and site-slope effects vary)

#### Scenario: Retained site:year behaves as specified
- **WHEN** predictions are formed from a fit whose `meta$site_year_on` is `TRUE`
- **THEN** the site:year term is resolved per row and per `new_levels` as specified by the other prediction requirements
