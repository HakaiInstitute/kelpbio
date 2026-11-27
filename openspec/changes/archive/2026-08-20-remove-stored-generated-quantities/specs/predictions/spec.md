## MODIFIED Requirements

### Requirement: Raw prediction draws via rstantools generics

Raw posterior prediction draws SHALL be provided through the `rstantools` generics rather than a bespoke `_samples()` function. `posterior_epred()`, `posterior_linpred()`, and `posterior_predict()` SHALL return a draws-by-observations (`D x N`) matrix for a `kb_fit_weight`, accepting `new_data`, a `new_levels = c("sample", "average")` axis, and a `representative_site = NULL` axis, with no `by` argument. `posterior_linpred()` returns the log-scale mean and `posterior_epred()` returns its exponential for both species. Conditioning SHALL be resolved per row, per factor by level membership, dispatching the linear predictor on `meta$species`: a row whose `site`/`year` is a known level is conditioned on its estimated random effect; a new level, or an absent grouping column, is handled by `new_levels` (`"sample"` draws, `"average"` zeroes), except that when `representative_site` is non-`NULL` a new/absent site takes its site main effects from the named reference site(s) (per-draw average across several). A new (unseen) level SHALL NOT error. With `new_data = NULL` the generics use the observed data and condition on its site and year, so `posterior_epred()`, `posterior_predict()`, and `augment()` agree at the observed data. `posterior_predict()` SHALL add species-appropriate observation noise: Student-t (scale `sWeight`) for *Nereocystis*, Gamma (shape `shape`) for *Macrocystis*. That noise SHALL be drawn in R for every `new_data`, including `NULL`, so `posterior_predict()` is RNG-dependent and `set.seed()` gives reproducible draws; with `new_data = NULL` on a zero-observation fit it SHALL error rather than return an empty matrix.

#### Scenario: posterior_epred returns the prediction draws
- **WHEN** `posterior_epred(fit, new_data = grid)` is called
- **THEN** it returns a `D x N` matrix of response-scale expected weight (`exp` of the linear predictor), draws as rows and grid rows as columns

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

`log_lik()` SHALL return the `D x N` pointwise log-likelihood for a `kb_fit_weight`, enabling `loo::loo()`. It SHALL be recomputed in R from the stored draws by evaluating the model's own likelihood at the observed data, and SHALL be deterministic. The density is of the response on the scale the model fits it (log weight for *Nereocystis*, weight for *Macrocystis*) with no Jacobian adjustment, matching the Stan likelihood. It SHALL error for a zero-observation fit. `prior_summary()` SHALL return the resolved priors.

#### Scenario: log_lik enables loo
- **WHEN** `log_lik(fit)` is called
- **THEN** it returns the `D x N` pointwise log-likelihood matrix suitable for `loo::loo()`

#### Scenario: log_lik errors for a zero-observation fit
- **WHEN** `log_lik(fit)` is called on a fit with no observed rows
- **THEN** it errors, since a zero-observation fit has no pointwise likelihood and `loo::loo()` has nothing to weight

#### Scenario: prior_summary reports the priors
- **WHEN** `prior_summary(fit)` is called
- **THEN** it returns the resolved prior objects used in the fit
