## MODIFIED Requirements

### Requirement: Two prediction verbs

Each model with grouping factors SHALL have a row-wise verb and a `_by` verb, both returning a `kb_predictions` object, which records its `conf_level`, whose `estimate`, `lower`, and `upper` columns summarise the posterior distribution of the expected response, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). The row-wise verb SHALL predict at the rows of `new_data`, or at the observed data when `new_data = NULL`. The `_by` verb SHALL predict with one row or curve per level of the factors named in `by` (`NULL`, `"site"`, `"year"`, or `c("site", "year")`, the last taking only observed combinations).

- Weight: `kb_predict_weight(fit, new_data)` and `kb_predict_weight_by(fit, by)` predict expected weight (kg). `kb_predict_weight_by()` predicts curves over a sequence of the species predictor (`diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*), auto-generated over the observed range unless supplied through the argument of the same name. The returned predictor column SHALL take the input column's name. New data SHALL use the predictor reference stored at fit time.
- Size: `kb_predict_size(fit, new_data)` and `kb_predict_size_by(fit, by)` predict expected size, the mean of the size distribution: sub-bulb diameter (mm) for *Nereocystis*, and fronds at 1 m for *Macrocystis*, among plants with at least one. Size has no predictor, so `kb_predict_size_by()` returns one row per group, and `new_data` needs no columns.
- Density: `kb_predict_density(fit, new_data)` predicts the expected count (stipes or plants) on a transect of the supplied `area_m2`, so `new_data` SHALL have an `area_m2` column. `kb_predict_density_by(fit, by)` predicts expected density (stipes or plants per m²), one row per group. For *Nereocystis* both include the probability that a transect holds no stipes.
- Wet/dry: `kb_predict_wetdry(fit)` predicts the expected dry:wet mass ratio, one row for the population of samples. The model has no grouping factors or predictor, so there is no `_by` verb and no `new_data`; the same summary arguments apply.
- Carbon: `kb_predict_carbon(fit)` predicts the expected carbon fraction of dry mass, one row for the population of samples, on the same terms as wet/dry.
- Cover biomass: `kb_predict_cover_biomass(fit, new_data)` predicts the expected wet biomass (kg/m²) of a plot from its `canopy_area_m2`, `plot_area_m2`, and `tide_height_m`, which `new_data` SHALL carry. `kb_predict_cover_biomass_by(fit, by)` predicts curves of expected wet biomass (kg/m²) over tide-corrected cover, a proportion from 0 to 1, over 0 to 1 unless supplied through `cover`, returned in a `cover` column.

#### Scenario: Predict at the observed data
- **WHEN** `kb_predict_weight(fit)`, `kb_predict_size(fit)`, `kb_predict_density(fit)`, or `kb_predict_cover_biomass(fit)` is called
- **THEN** it returns one prediction per observed row, whose `estimate` equals `augment(fit)$fitted`

#### Scenario: Predict at supplied rows
- **WHEN** `new_data` carries the columns the model needs (the species predictor for weight, none for size, `area_m2` for density, `canopy_area_m2`, `plot_area_m2`, and `tide_height_m` for cover)
- **THEN** predictions are returned at exactly those rows

#### Scenario: Curves are returned over the named predictor
- **WHEN** `kb_predict_weight_by(fit, diameter_mm = c(20, 40))` is called on a *Nereocystis* fit
- **THEN** it returns predictions at those values in a `diameter_mm` column

#### Scenario: Size by group returns one row per group
- **WHEN** `kb_predict_size_by(fit, by = "site")` is called
- **THEN** it returns one row per fitted site, and `by = NULL` returns a single row for the typical site and year

#### Scenario: Density by group is per square metre
- **WHEN** `kb_predict_density_by(fit, by = "site")` is called
- **THEN** it returns one row per fitted site, whose `estimate` equals `kb_predict_density()` at the same site with `area_m2 = 1`

#### Scenario: Expected counts scale with area
- **WHEN** `kb_predict_density()` is called with `new_levels = "average"` at the same site and year with `area_m2` of 10 and 20
- **THEN** the second estimate is twice the first, up to rounding

#### Scenario: Cover curves agree with row-wise predictions
- **WHEN** `kb_predict_cover_biomass_by(fit, by = "site", cover = 0.5)` and `kb_predict_cover_biomass()` at the same site with `canopy_area_m2 = 50`, `plot_area_m2 = 100`, and `tide_height_m = 0` are called with `new_levels = "average"`
- **THEN** the estimates are equal

#### Scenario: Zero cover predicts the floor
- **WHEN** `kb_predict_cover_biomass()` is called at `canopy_area_m2 = 0`
- **THEN** the prediction is the same for every site and year

#### Scenario: Wet/dry returns one population estimate
- **WHEN** `kb_predict_wetdry(fit)` is called
- **THEN** it returns one row whose `estimate` equals each value of `augment(fit)$fitted`

#### Scenario: Carbon returns one population estimate
- **WHEN** `kb_predict_carbon(fit)` is called
- **THEN** it returns one row whose `estimate` equals each value of `augment(fit)$fitted`

#### Scenario: A wrong predictor errors
- **WHEN** `new_data` lacks the weight model's species predictor, or `kb_predict_weight_by()` is given the other species' predictor argument
- **THEN** it errors naming the correct column or argument

### Requirement: Groups are resolved per row

A row whose `site`, `year`, or site-year is a fitted level SHALL be conditioned on that level's estimated effect. A new level or an absent grouping column SHALL be handled by `new_levels`: `"sample"` draws a new effect from its estimated distribution, and `"average"` sets it to zero (the typical group). The default SHALL be `"sample"` for the row-wise verbs (`kb_predict_weight()`, `kb_predict_size()`, `kb_predict_density()`, `kb_predict_cover_biomass()`) and the `posterior_*()` generics, and `"average"` for the `_by` verbs. A new level SHALL NOT error. `representative_site` SHALL instead give a new or absent site the estimated site effect of the named fitted site(s), averaged per draw when several are named, while site:year still follows `new_levels`; a name not in the fit SHALL error listing the fitted sites. An effect the fit omitted SHALL contribute nothing, under any `new_levels`.

#### Scenario: New levels are sampled or averaged
- **WHEN** `new_data` holds a site the fit never saw
- **THEN** the prediction does not error; `"sample"` gives an interval at least as wide as `"average"`

#### Scenario: A representative site stands in for a new site
- **WHEN** a new site is predicted with `representative_site = s` and `new_levels = "average"` and no `year` column
- **THEN** the prediction equals predicting fitted site `s` with the same other inputs

#### Scenario: An omitted site:year effect adds nothing
- **WHEN** the fit omitted the site:year effect
- **THEN** `new_levels = "sample"` adds no site:year variation

### Requirement: Draws, likelihood, and priors

`posterior_epred()`, `posterior_linpred()`, and `posterior_predict()` SHALL return a draws-by-rows matrix for `new_data` (or the observed data), resolving groups and density as above. `posterior_epred()` SHALL give the expected response. Where that differs from the inverse link of the linear predictor, `posterior_linpred(transform = TRUE)` SHALL return the inverse link:

- *Nereocystis* weight, whose log weight is Normal: the expected weight is `exp(mu + sWeight^2 / 2)`, above the median `exp(mu)`.
- *Macrocystis* size, whose frond count is a zero-truncated negative binomial: the expected count is the truncated mean, above the untruncated mean `exp(mu)`.
- *Nereocystis* density, whose stipe count is a zero-inflated negative binomial: the expected count is `(1 - zi) * exp(mu)`, below the mean of a transect holding stipes, `exp(mu)`, where `zi` is the zero-inflation probability.

For cover biomass, whose residual is the in situ estimation error rather than variation in biomass, the expected biomass is the inverse link, `exp(mu)`.

The prediction verbs, `fitted()`, and `augment()` SHALL summarise `posterior_epred()`. `posterior_predict()` SHALL add observation noise from the model's likelihood, so repeated calls differ unless a seed is set; for size it draws plant sizes, and *Macrocystis* draws are whole numbers of at least 1; for density it draws transect counts, whole numbers of at least 0; for wet/dry and carbon it draws ratios or fractions between 0 and 1; for cover it draws positive in situ biomass estimates, with each row's precision taken from its `lower` and `upper`, which `new_data` SHALL then carry. `log_lik()` SHALL return the deterministic pointwise log-likelihood of the observed data, suitable for `loo::loo()`, and error for a fit with no observations. `prior_summary()` SHALL return the priors used.

#### Scenario: Expected weight exceeds the median for Nereocystis
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Nereocystis* weight rows
- **THEN** each draw of the former equals the latter times `exp(sWeight^2 / 2)`

#### Scenario: Expected frond count exceeds the untruncated mean
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Macrocystis* size rows
- **THEN** each draw of the former is greater than the latter and at least 1

#### Scenario: Expected stipe count includes zero inflation
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Nereocystis* density rows
- **THEN** each draw of the former equals the latter times one minus that draw's zero-inflation probability

#### Scenario: Cover predictive draws need the in situ limits
- **WHEN** `posterior_predict()` is called on a cover biomass fit with `new_data` lacking `lower` or `upper`
- **THEN** it errors naming the missing columns

#### Scenario: Predictive draws are reproducible under a seed
- **WHEN** `posterior_predict()` is called twice after the same `set.seed()`
- **THEN** it returns identical draws

### Requirement: New data predictor values are validated

`new_data` SHALL be validated before prediction: it SHALL be a data frame; for weight, *Nereocystis* `diameter_mm` SHALL be numeric, greater than 0, with no missing values, and *Macrocystis* `fronds` a positive whole number with no missing values; for density, `area_m2` SHALL be present, numeric, greater than 0, with no missing values; for cover biomass, `canopy_area_m2` (`>= 0`), `plot_area_m2` (> 0 and at least `canopy_area_m2`), and `tide_height_m` SHALL be present, numeric, with no missing values. Size, wet/dry, and carbon `new_data` need no predictor column. An invalid value SHALL error with a message naming the column, pinned by `tests/testthat/_snaps/chk.md`.

#### Scenario: An impossible diameter errors
- **WHEN** weight `new_data` has a `diameter_mm` that is zero, negative, missing, or not numeric
- **THEN** prediction errors naming `diameter_mm`

#### Scenario: A fractional frond count errors
- **WHEN** weight `new_data` has a non-whole `fronds` value
- **THEN** prediction errors naming `fronds`

#### Scenario: Size new data need no columns
- **WHEN** `kb_predict_size(fit, new_data)` is called with a data frame of only `site`, or of no columns and `n` rows
- **THEN** it returns one prediction per row

#### Scenario: Density new data need an area
- **WHEN** `kb_predict_density(fit, new_data)` is called with `new_data` lacking `area_m2`, or with an `area_m2` of zero
- **THEN** prediction errors naming `area_m2` and pointing to `kb_predict_density_by()` for density per m²

#### Scenario: Cover new data need the survey columns
- **WHEN** `kb_predict_cover_biomass(fit, new_data)` is called with `new_data` lacking `tide_height_m`, or with a `canopy_area_m2` above its `plot_area_m2`
- **THEN** prediction errors naming the column
