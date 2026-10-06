# predictions

## Purpose

Predicting from a fit: the two prediction verbs, how groups and optional inputs
are resolved per row, the rstantools draw generics, and plotting predictions.
## Requirements
### Requirement: Two prediction verbs

Each model with grouping factors SHALL have a row-wise verb and a `_by` verb, both returning a `kb_predictions` object whose `estimate`, `lower`, and `upper` columns summarise the posterior distribution of the expected response, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). The row-wise verb SHALL predict at the rows of `new_data`, or at the observed data when `new_data = NULL`. The `_by` verb SHALL predict with one row or curve per level of the factors named in `by` (`NULL`, `"site"`, `"year"`, or `c("site", "year")`, the last taking only observed combinations).

- Weight: `kb_predict_weight(fit, new_data)` and `kb_predict_weight_by(fit, by)` predict expected weight (kg). `kb_predict_weight_by()` predicts curves over a sequence of the species predictor (`diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*), auto-generated over the observed range unless supplied through the argument of the same name. The returned predictor column SHALL take the input column's name. New data SHALL use the predictor reference stored at fit time.
- Size: `kb_predict_size(fit, new_data)` and `kb_predict_size_by(fit, by)` predict expected size, the mean of the size distribution: sub-bulb diameter (mm) for *Nereocystis*, and fronds at 1 m for *Macrocystis*, among plants with at least one. Size has no predictor, so `kb_predict_size_by()` returns one row per group, and `new_data` needs no columns.
- Density: `kb_predict_density(fit, new_data)` predicts the expected count (stipes or plants) on a transect of the supplied `area_m2`, so `new_data` SHALL have an `area_m2` column. `kb_predict_density_by(fit, by)` predicts expected density (stipes or plants per m²), one row per group. For *Nereocystis* both include the probability that a transect holds no stipes.
- Wet/dry: `kb_predict_wetdry(fit)` predicts the expected dry:wet mass ratio, one row for the population of samples. The model has no grouping factors or predictor, so there is no `_by` verb and no `new_data`; the same summary arguments apply.
- Carbon: `kb_predict_carbon(fit)` predicts the expected carbon fraction of dry mass, one row for the population of samples, on the same terms as wet/dry.

#### Scenario: Predict at the observed data
- **WHEN** `kb_predict_weight(fit)`, `kb_predict_size(fit)`, or `kb_predict_density(fit)` is called
- **THEN** it returns one prediction per observed row, whose `estimate` equals `augment(fit)$fitted`

#### Scenario: Predict at supplied rows
- **WHEN** `new_data` carries the columns the model needs (the species predictor for weight, none for size, `area_m2` for density)
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

A row whose `site`, `year`, or site-year is a fitted level SHALL be conditioned on that level's estimated effect. A new level or an absent grouping column SHALL be handled by `new_levels`: `"sample"` draws a new effect from its estimated distribution, and `"average"` sets it to zero (the typical group). Rows naming the same new site, year, or site-year SHALL share one sampled effect, since they are one group; rows whose grouping column is absent SHALL each draw their own. The default SHALL be `"sample"` for the row-wise verbs (`kb_predict_weight()`, `kb_predict_size()`, `kb_predict_density()`), `kb_predict_plot_biomass()`, and the `posterior_*()` generics, and `"average"` for the `_by` verbs. A new level SHALL NOT error. `representative_site` SHALL instead give a new or absent site the estimated site effect of the named fitted site(s), averaged per draw when several are named, while site:year still follows `new_levels`; a name not in the fit SHALL error listing the fitted sites. An effect the fit omitted SHALL contribute nothing, under any `new_levels`.

#### Scenario: New levels are sampled or averaged
- **WHEN** `new_data` holds a site the fit never saw
- **THEN** the prediction does not error; `"sample"` gives an interval at least as wide as `"average"`

#### Scenario: Rows naming one new level share its effect
- **WHEN** `posterior_epred()` is called with two rows naming the same new site and a fitted year, under `new_levels = "sample"`
- **THEN** the two rows' draws are identical where their other inputs are

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
- *Nereocystis* density, whose stipe count is a zero-inflated negative binomial: the expected count is `(1 - zi) * exp(mu)`, below the mean of a transect holding stipes, `exp(mu)`, where `zi` is the zero-inflation probability.

The prediction verbs, `fitted()`, and `augment()` SHALL summarise `posterior_epred()`. `posterior_predict()` SHALL add observation noise from the model's likelihood, so repeated calls differ unless a seed is set; for size it draws plant sizes, and *Macrocystis* draws are whole numbers of at least 1; for density it draws transect counts, whole numbers of at least 0; for wet/dry and carbon it draws ratios or fractions between 0 and 1. `log_lik()` SHALL return the deterministic pointwise log-likelihood of the observed data, suitable for `loo::loo()`, and error for a fit with no observations. `prior_summary()` SHALL return the priors used.

#### Scenario: Expected weight exceeds the median for Nereocystis
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Nereocystis* weight rows
- **THEN** each draw of the former equals the latter times `exp(sWeight^2 / 2)`

#### Scenario: Expected frond count exceeds the untruncated mean
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Macrocystis* size rows
- **THEN** each draw of the former is greater than the latter and at least 1

#### Scenario: Expected stipe count includes zero inflation
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Nereocystis* density rows
- **THEN** each draw of the former equals the latter times one minus that draw's zero-inflation probability

#### Scenario: Predictive draws are reproducible under a seed
- **WHEN** `posterior_predict()` is called twice after the same `set.seed()`
- **THEN** it returns identical draws

### Requirement: Plot predictions

`kb_plot_predictions(predictions)` SHALL return a `ggplot` built from a `kb_predictions` object, never from a fit, and `autoplot()` on a `kb_predictions` object SHALL return the same plot. A curve from `kb_predict_weight_by()` over a varying predictor SHALL be drawn as a line with a compatibility-interval ribbon; otherwise predictions SHALL be drawn as point ranges. The x-axis variable SHALL default from the prediction's metadata and be overridable through `x`; the remaining grouping variables SHALL be faceted, the x-axis variable never. `max_facets` SHALL cap the panels drawn with a warning giving how many were shown. The plot SHALL draw only the predictions; raw data are not overlaid, and a user can add them as a layer. The y-axis SHALL extend to zero. Axis titles SHALL be descriptive (e.g. "Sub-bulb diameter", "Wet weight", "Stipe density"). When the prediction's metadata has been stripped, it SHALL error asking for `x`.

#### Scenario: Curves get a ribbon, rows get points
- **WHEN** a curve from `kb_predict_weight_by()` and rows from `kb_predict_weight()` are plotted
- **THEN** the first is a line with a ribbon and the second point ranges

#### Scenario: Two grouping factors
- **WHEN** point-range predictions grouped by site and year are plotted
- **THEN** year is on the x-axis and site is faceted

#### Scenario: Size by site
- **WHEN** `kb_predict_size_by(fit, by = "site")` is plotted
- **THEN** point ranges are drawn per site, and the y-axis is titled with the size response

#### Scenario: Density by site
- **WHEN** `kb_predict_density_by(fit, by = "site")` is plotted
- **THEN** point ranges are drawn per site, and the y-axis is titled as a density per m², not a count

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

`new_data` SHALL be validated before prediction: it SHALL be a data frame; for weight, *Nereocystis* `diameter_mm` SHALL be numeric, greater than 0, with no missing values, and *Macrocystis* `fronds` a positive whole number with no missing values; for density, `area_m2` SHALL be present, numeric, greater than 0, with no missing values. Size, wet/dry, and carbon `new_data` need no predictor column. An invalid value SHALL error with a message naming the column, pinned by `tests/testthat/_snaps/chk.md`.

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

### Requirement: Plot biomass

`kb_predict_plot_biomass(weight, size, density, wetdry, carbon)` SHALL combine a weight, a size, and a density fit of the same species into the expected biomass per m² of each site-year in the density fit's data, for the `measure` chosen by a name-only argument: `"wet"` (the default, kg/m²), `"dry"` (kg/m², needing a wet/dry fit as `wetdry`), or `"carbon"` (g C/m², needing `wetdry` and a carbon fit as `carbon`). It SHALL return a `kb_predictions` object with one row per such site-year and columns `site`, `year`, `weight_support`, `size_support`, `estimate`, `lower`, and `upper`, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). `weight_support` and `size_support` SHALL give the data the weight or size fit has for the site-year: `"site-year"` where the site-year is in its data, else `"site, year"` where both its site and its year are, else `"site"` or `"year"` where only one is, else `"none"`.

Per draw, biomass SHALL be the site-year's expected density per m² times its mean plant weight: the expected weight at size averaged over the site-year's size distribution, truncated above at the largest size in the size fit's data. The name-only `n_plants` (default 100) SHALL set the number of plants averaged per draw. For a *Nereocystis* weight fit with the density effect, each site-year SHALL use its observed stipe density in the density fit's data. Per draw, dry biomass SHALL be wet biomass times the expected dry:wet ratio, and carbon biomass dry biomass times the expected carbon fraction, converted to grams.

Weight and size at a site-year SHALL be resolved as in the row-wise verbs, with name-only `new_levels` (default `"sample"`) and `representative_site`. A `representative_site` SHALL be fitted in both the weight and size fits. A name-only `progress` (`"bar"`, the default, or `"none"`) SHALL control a console progress bar, and a `progress_dir` naming an existing directory SHALL receive a progress record that `kb_progress()` reads, as for the fits. The function SHALL error, naming the problem, when an argument is not a fit of the required model, a fit the `measure` needs is not supplied, the fits supplied differ in species, or they differ in their number of draws.

#### Scenario: One row per density-surveyed site-year
- **WHEN** `kb_predict_plot_biomass(weight, size, density)` is called on fits of one species
- **THEN** it returns one row for each site-year in the density fit's data, and no other

#### Scenario: Biomass is density times mean plant weight
- **WHEN** the fits' site and year effects are all observed for a site-year
- **THEN** each draw of its biomass equals that site-year's expected density per m² times the mean expected weight over its truncated size distribution, within the integration error of `n_plants`

#### Scenario: Dry and carbon are per-draw conversions of wet
- **WHEN** `measure = "dry"` or `measure = "carbon"` is requested with the fits it needs
- **THEN** each draw equals the wet biomass draw times the expected dry:wet ratio draw, and for carbon also times the expected carbon fraction draw and 1000

#### Scenario: A missing conversion fit errors
- **WHEN** `measure = "carbon"` is requested without a `carbon` fit, or `"dry"` without a `wetdry` fit
- **THEN** it errors naming the missing argument

#### Scenario: The data support of weight and size is reported
- **WHEN** a density-surveyed site-year is absent from the weight or size fit's data
- **THEN** it still returns a row, with `weight_support` or `size_support` naming the data the fit does have for it (`"site, year"`, `"site"`, `"year"`, or `"none"`)

#### Scenario: Averaging narrows an unseen site's interval
- **WHEN** a density-surveyed site is absent from the weight and size fits
- **THEN** its interval under `new_levels = "sample"` is at least as wide as under `"average"`

#### Scenario: Mismatched fits error
- **WHEN** the fits differ in species, a fit is of the wrong model, or the fits differ in their number of draws
- **THEN** it errors naming the mismatch

#### Scenario: Progress can be polled
- **WHEN** it is called with `progress_dir` and `kb_progress(progress_dir)` is called during and after it
- **THEN** it returns the completed fraction, reaching `1` when the prediction finishes

#### Scenario: Reproducible under a seed
- **WHEN** it is called twice after the same `set.seed()`
- **THEN** the results are identical

### Requirement: Predictions record their interval level

Every `kb_predictions` object SHALL record the `conf_level` its `lower` and `upper` columns were computed at.

#### Scenario: The level travels with the prediction
- **WHEN** a prediction verb is called with `conf_level = 0.9`
- **THEN** the returned object records 0.9 as its interval level

