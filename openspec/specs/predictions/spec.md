# predictions

## Purpose

Predicting from a fit: the prediction verb of each model and the grids built for
it, how groups and optional inputs are resolved per row, the rstantools draw
generics, plot and site biomass, and plotting predictions.
## Requirements
### Requirement: Groups are resolved per row

A row whose `site`, `year`, or site-year is a fitted level SHALL be conditioned on that level's estimated effect. A new level or an absent grouping column SHALL be handled by `new_levels`: `"average"` sets it to zero (the typical group), and `"sample"` draws a new effect from its estimated distribution. Rows naming the same new site, year, or site-year SHALL share one sampled effect, since they are one group; rows whose grouping column is absent SHALL each draw their own. The default SHALL be `"average"` for every prediction verb, `predict()`, and the `posterior_*()` generics, and `"sample"` for `kb_predict_plot_biomass()` and `kb_predict_site_biomass()`, whose rows are particular surveyed site-years. A new level SHALL NOT error. `representative_site` SHALL instead give a new or absent site the estimated site effect of the named fitted site(s), averaged per draw when several are named, while site:year still follows `new_levels`; a name not in the fit SHALL error listing the fitted sites. An effect the fit omitted SHALL contribute nothing, under any `new_levels`.

#### Scenario: New levels are sampled or averaged
- **WHEN** `new_data` holds a site the fit never saw
- **THEN** the prediction does not error; `"sample"` gives an interval at least as wide as `"average"`

#### Scenario: The default is the typical group
- **WHEN** a prediction verb or `posterior_epred()` is called without `new_levels` on rows with no `site` or `year` column
- **THEN** it equals the same call with `new_levels = "average"`, and repeated calls agree without a seed

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
- **WHEN** `kb_predict_weight(fit, kb_new_data(fit, by = c("site", "year")))` is called
- **THEN** each curve uses its site-year's recorded density, and grids by other `by` values use the fitted mean

### Requirement: Draws, likelihood, and priors

`posterior_epred()`, `posterior_linpred()`, and `posterior_predict()` SHALL return a draws-by-rows matrix for `new_data` (or the observed data), resolving groups and density as above. For a density fit, each row SHALL be a transect of its `area_m2`, or of 1 m² when `new_data` has no `area_m2` column, and the observed data SHALL use their recorded areas. `posterior_epred()` SHALL give the expected response. Where that differs from the inverse link of the linear predictor, `posterior_linpred(transform = TRUE)` SHALL return the inverse link:

- *Nereocystis* weight, whose log weight is Normal: the expected weight is `exp(mu + sd_residual^2 / 2)`, above the median `exp(mu)`.
- *Macrocystis* size, whose frond count is a zero-truncated negative binomial: the expected count is the truncated mean, above the untruncated mean `exp(mu)`.
- *Nereocystis* density, whose stipe count is a zero-inflated negative binomial: the expected count is `(1 - zi) * exp(mu)`, below the mean of a transect holding stipes, `exp(mu)`, where `zi` is the zero-inflation probability.

For cover biomass, whose residual is the in situ estimation error rather than variation in biomass, the expected biomass is the inverse link, `exp(mu)`.

The prediction verbs, `fitted()`, and `augment()` SHALL summarise `posterior_epred()`; the density verb at 1 m². `posterior_predict()` SHALL add observation noise from the model's likelihood, so repeated calls differ unless a seed is set; for size it draws plant sizes, and *Macrocystis* draws are whole numbers of at least 1; for density it draws transect counts, whole numbers of at least 0; for wet/dry and carbon it draws ratios or fractions between 0 and 1; for cover biomass it draws positive in situ biomass estimates, with each row's precision taken from its `lower` and `upper`, which `new_data` SHALL then carry. `log_lik()` SHALL return the deterministic pointwise log-likelihood of the observed data, suitable for `loo::loo()`, and error for a fit with no observations. Each value SHALL be the log density of the recorded response on its recorded scale (weight in kg, diameter in mm, a count, a ratio or fraction, or an in situ biomass estimate), including the Jacobian where the model's likelihood is stated on a transformed scale, so the pointwise log-likelihoods of two models of the same response are comparable. `log_lik()`, `residuals()`, and `posterior_predict()` SHALL use the same observation distribution, and it SHALL be the distribution of the fitted Stan model. `prior_summary()` SHALL return the priors used.

#### Scenario: Expected weight exceeds the median for Nereocystis
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Nereocystis* weight rows
- **THEN** each draw of the former equals the latter times `exp(sd_residual^2 / 2)`

#### Scenario: Expected frond count exceeds the untruncated mean
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Macrocystis* size rows
- **THEN** each draw of the former is greater than the latter and at least 1

#### Scenario: Expected stipe count includes zero inflation
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Nereocystis* density rows
- **THEN** each draw of the former equals the latter times one minus that draw's zero-inflation probability

#### Scenario: Expected counts scale with area
- **WHEN** `posterior_epred()` is called on a density fit at the same site and year with `area_m2` of 10 and of 20
- **THEN** each draw of the second is twice the first

#### Scenario: Density draws default to one square metre
- **WHEN** `posterior_epred()` is called on a density fit with `new_data` lacking `area_m2`
- **THEN** it equals the same call with `area_m2 = 1`, and its summary equals `kb_predict_density()` at those rows

#### Scenario: Cover predictive draws need the in situ limits
- **WHEN** `posterior_predict()` is called on a cover biomass fit with `new_data` lacking `lower` or `upper`
- **THEN** it errors naming the missing columns

#### Scenario: Predictive draws are reproducible under a seed
- **WHEN** `posterior_predict()` is called twice after the same `set.seed()`
- **THEN** it returns identical draws

#### Scenario: Log-likelihood is on the recorded scale
- **WHEN** `log_lik()` is called on a *Nereocystis* weight fit
- **THEN** each value equals the log density of the Normal on log weight minus the log of that row's `weight_kg`

#### Scenario: Log-likelihood agrees with the Stan model
- **WHEN** `log_lik()` is summed over the observed rows for each draw of any fit
- **THEN** it differs from the Stan model's log density with the likelihood, minus the same log density without it, by an amount that is the same for every draw

### Requirement: Plot predictions

`kb_plot_predictions(predictions)` SHALL return a `ggplot` built from a `kb_predictions` object, never from a fit, and `autoplot()` on a `kb_predictions` object SHALL return the same plot. Predictions made at a `kb_new_data()` grid over a varying predictor SHALL be drawn as a line with a compatibility-interval ribbon; otherwise predictions SHALL be drawn as point ranges. The x-axis variable SHALL default from the prediction's metadata and be overridable through `x`; the remaining grouping variables SHALL be faceted, the x-axis variable never. `max_facets` SHALL cap the panels drawn with a warning giving how many were shown. The plot SHALL draw only the predictions; raw data are not overlaid, and a user can add them as a layer. The y-axis SHALL extend to zero. Axis titles SHALL be descriptive (e.g. "Sub-bulb diameter", "Wet weight", "Stipe density"). When the prediction's metadata has been stripped, it SHALL error asking for `x`.

#### Scenario: Curves get a ribbon, rows get points
- **WHEN** weight predictions at `kb_new_data(fit)` and at the observed data are plotted
- **THEN** the first is a line with a ribbon and the second point ranges

#### Scenario: A single predictor value gives points
- **WHEN** `kb_predict_weight(fit, kb_new_data(fit, by = "site", diameter_mm = 50))` is plotted
- **THEN** point ranges are drawn per site

#### Scenario: Two grouping factors
- **WHEN** point-range predictions grouped by site and year are plotted
- **THEN** year is on the x-axis and site is faceted

#### Scenario: Size by site
- **WHEN** `kb_predict_size(fit, kb_new_data(fit, by = "site"))` is plotted
- **THEN** point ranges are drawn per site, and the y-axis is titled with the size response

#### Scenario: Density by site
- **WHEN** `kb_predict_density(fit, kb_new_data(fit, by = "site"))` is plotted
- **THEN** point ranges are drawn per site, and the y-axis is titled as a density per m², not a count

#### Scenario: Too many facets
- **WHEN** a prediction has more groups than `max_facets`
- **THEN** only `max_facets` panels are drawn and a warning reports how many were shown

#### Scenario: Raw data can be added as a layer
- **WHEN** a weight curve plot gets `+ geom_point(aes(diameter_mm, weight_kg), data = fit$data)`
- **THEN** the plot builds with the raw data drawn over the curve

### Requirement: Values far outside the fitted range are flagged

Prediction SHALL warn when supplied values of the species predictor lie below half the fitted minimum or above twice the fitted maximum, or supplied `stipes_m2` values (for a fit with the density effect) lie above twice the fitted maximum, naming the column, the fitted range, and the column's expected unit where it has one. This applies to any `new_data`, including a grid from `kb_new_data()` with supplied predictor values. The warning SHALL NOT stop the prediction. The message is pinned by `tests/testthat/_snaps/warn.md`.

#### Scenario: Diameter in centimetres at prediction is flagged
- **WHEN** `new_data` gives `diameter_mm` in centimetres to a fit made in millimetres
- **THEN** a warning names `diameter_mm` and the fitted range, and predictions are still returned

#### Scenario: Values within the fitted range raise no warning
- **WHEN** supplied values lie within twice the fitted range
- **THEN** no warning is issued

### Requirement: Plot biomass

`kb_predict_plot_biomass(weight, size, density, wetdry, carbon)` SHALL combine a weight, a size, and a density fit of the same species into the expected biomass per m² of each site-year in the density fit's data, for the `measure` chosen by a name-only argument: `"wet"` (the default, kg/m²), `"dry"` (kg/m², needing a wet/dry fit as `wetdry`), or `"carbon"` (g C/m², needing `wetdry` and a carbon fit as `carbon`). It SHALL return a `kb_predictions` object with one row per such site-year and columns `site`, `year`, `weight_support`, `size_support`, `estimate`, `lower`, and `upper`, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). `weight_support` and `size_support` SHALL give the data the weight or size fit has for the site-year: `"site-year"` where the site-year is in its data, else `"site, year"` where both its site and its year are, else `"site"` or `"year"` where only one is, else `"none"`.

Per draw, biomass SHALL be the site-year's expected density per m² times its mean plant weight: the expected weight at size averaged over the site-year's size distribution, truncated above at the largest size in the size fit's data. The name-only `n_plants` (default 100) SHALL set the number of plants averaged per draw. For a *Nereocystis* weight fit with the density effect, each site-year SHALL use its observed stipe density in the density fit's data. Per draw, dry biomass SHALL be wet biomass times the expected dry:wet ratio, and carbon biomass dry biomass times the expected carbon fraction, converted to grams.

Weight and size at a site-year SHALL be resolved as in the prediction verbs, with name-only `new_levels` (default `"sample"`) and `representative_site`. A `representative_site` SHALL be fitted in both the weight and size fits. A name-only `progress` (`"bar"`, the default, or `"none"`) SHALL control a console progress bar, and a `progress_dir` naming an existing directory SHALL receive a progress record that `kb_progress()` reads, as for the fits. The function SHALL error, naming the problem, when an argument is not a fit of the required model, a fit the `measure` needs is not supplied, the fits supplied differ in species, or they differ in their number of draws.

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

### Requirement: One prediction verb per model

Each model SHALL have one prediction verb, `kb_predict_<model>()`, returning a `kb_predictions` object whose `estimate`, `lower`, and `upper` columns summarise the posterior distribution of the expected response, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). For a model with grouping factors the verb SHALL take `new_data` and predict at its rows, in their order, or at the observed data when `new_data = NULL`. The returned object SHALL hold the input columns plus the summary columns. Predictions per group or over a predictor sequence SHALL be made by passing a grid from `kb_new_data()` as `new_data`.

- Weight: `kb_predict_weight(fit, new_data)` predicts expected weight (kg). `new_data` SHALL have the species predictor column (`diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*). New data SHALL use the predictor reference stored at fit time.
- Size: `kb_predict_size(fit, new_data)` predicts expected size, the mean of the size distribution: sub-bulb diameter (mm) for *Nereocystis*, and fronds at 1 m for *Macrocystis*, among plants with at least one. `new_data` needs no columns.
- Density: `kb_predict_density(fit, new_data)` predicts expected density, stipes (*Nereocystis*) or plants (*Macrocystis*) per m², in a response column named `stipes_m2` or `plants_m2`. It SHALL NOT read an `area_m2` column, so the estimate is per m² at the observed data too. For *Nereocystis* it includes the probability that a transect holds no stipes.
- Cover biomass: `kb_predict_cover_biomass(fit, new_data)` predicts the expected wet biomass (kg/m²) of a plot from its `canopy_area_m2`, `plot_area_m2`, and `tide_height_m`, which `new_data` SHALL carry.
- Wet/dry: `kb_predict_wetdry(fit)` predicts the expected dry:wet mass ratio, one row for the population of samples. The model has no grouping factors or predictor, so the verb takes no `new_data`; the same summary arguments apply.
- Carbon: `kb_predict_carbon(fit)` predicts the expected carbon fraction of dry mass, one row for the population of samples, on the same terms as wet/dry.

`predict()` on a fit SHALL return the same result as the model's verb with the same arguments.

#### Scenario: Predict at the observed data
- **WHEN** `kb_predict_weight(fit)`, `kb_predict_size(fit)`, or `kb_predict_cover_biomass(fit)` is called
- **THEN** it returns one prediction per observed row, whose `estimate` equals `augment(fit)$fitted`

#### Scenario: Density at the observed data is per square metre
- **WHEN** `kb_predict_density(fit)` is called
- **THEN** it returns one prediction per observed transect, whose `estimate` equals `augment(fit)$fitted` divided by the transect's `area_m2`, up to rounding

#### Scenario: Predict at supplied rows
- **WHEN** `new_data` carries the columns the model needs (the species predictor for weight, none for size or density, `canopy_area_m2`, `plot_area_m2`, and `tide_height_m` for cover biomass)
- **THEN** predictions are returned at exactly those rows, in their order

#### Scenario: Density ignores the transect area
- **WHEN** `kb_predict_density()` is called at the same site and year with `area_m2` of 10 and of 20
- **THEN** the two estimates are equal

#### Scenario: Zero cover predicts the floor
- **WHEN** `kb_predict_cover_biomass()` is called at `canopy_area_m2 = 0`
- **THEN** the prediction is the same for every site and year

#### Scenario: Group predictions come from a grid
- **WHEN** `kb_predict_size(fit, kb_new_data(fit, by = "site"))` is called
- **THEN** it returns one row per fitted site, and `kb_new_data(fit)` gives a single row for the typical site and year

#### Scenario: Wet/dry returns one population estimate
- **WHEN** `kb_predict_wetdry(fit)` is called
- **THEN** it returns one row whose `estimate` equals each value of `augment(fit)$fitted`

#### Scenario: Carbon returns one population estimate
- **WHEN** `kb_predict_carbon(fit)` is called
- **THEN** it returns one row whose `estimate` equals each value of `augment(fit)$fitted`

#### Scenario: predict() matches the verb
- **WHEN** `predict(fit, new_data)` and `kb_predict_<model>(fit, new_data)` are called with the same arguments
- **THEN** they return identical results

#### Scenario: A missing predictor errors
- **WHEN** weight `new_data` lacks the species predictor
- **THEN** it errors naming the correct column

### Requirement: Prediction grids

`kb_new_data(fit, by = NULL, ...)` SHALL return a data frame for use as `new_data` with a weight, size, density, or cover biomass fit: one row per level of the factors named in `by` (`NULL` for a single row with no grouping columns, `"site"`, `"year"`, or `c("site", "year")`, the last taking only the combinations in the fitted data), in the fit's level order. For a weight fit the rows SHALL be crossed with values of the species predictor, supplied as a named numeric vector of any length (`diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*) and defaulting to 30 evenly spaced values over the observed range, rounded to whole numbers for `fronds`; the predictor column SHALL take the input column's name. For a cover biomass fit the rows SHALL be crossed with values of tide-corrected cover, supplied as `cover` (proportions from 0 to 1) and defaulting to 30 evenly spaced values from 0 to 1, each row being a unit plot at zero tide height with the `canopy_area_m2`, `plot_area_m2`, and `tide_height_m` columns the prediction reads. The grid SHALL hold no `area_m2` column. It SHALL error, naming the valid values, for an unknown `by` value, a `cover` outside 0 to 1, a predictor argument the fit does not have (the other species' predictor, or any predictor for a size or density fit), or a fit with no grouping factors.

#### Scenario: Curves over a named predictor
- **WHEN** `kb_new_data(fit, by = "site", diameter_mm = c(20, 40))` is called on a *Nereocystis* weight fit
- **THEN** it returns two rows per fitted site, with `site` and `diameter_mm` columns

#### Scenario: A single predictor value
- **WHEN** `kb_new_data(fit, by = "site", diameter_mm = 50)` is called on a *Nereocystis* weight fit
- **THEN** it returns one row per fitted site, each at 50 mm

#### Scenario: Cover grids agree with survey rows
- **WHEN** `kb_predict_cover_biomass(fit, kb_new_data(fit, by = "site", cover = 0.5))` is called, and `kb_predict_cover_biomass()` at the same sites with `canopy_area_m2 = 50`, `plot_area_m2 = 100`, and `tide_height_m = 0`
- **THEN** the estimates are equal

#### Scenario: A default predictor sequence
- **WHEN** `kb_new_data(fit)` is called on a weight fit
- **THEN** it returns 30 rows spanning the observed range of the species predictor, with no grouping columns

#### Scenario: Site and year take observed combinations
- **WHEN** `kb_new_data(fit, by = c("site", "year"))` is called
- **THEN** it returns one row per site-year in the fitted data

#### Scenario: A wrong predictor argument errors
- **WHEN** `kb_new_data()` is given `fronds` for a *Nereocystis* weight fit, or any predictor for a size or density fit
- **THEN** it errors naming the predictor the fit has, or stating it has none

#### Scenario: A fit without groups errors
- **WHEN** `kb_new_data()` is called on a wet/dry or carbon fit
- **THEN** it errors stating the model has no grouping factors

### Requirement: New data are validated

`new_data` SHALL be validated before prediction: it SHALL be a data frame; for weight, *Nereocystis* `diameter_mm` SHALL be numeric, greater than 0, with no missing values, and *Macrocystis* `fronds` a positive whole number with no missing values; for density, an `area_m2` column, where present, SHALL be numeric, greater than 0, with no missing values; for cover biomass, `canopy_area_m2` (`>= 0`), `plot_area_m2` (> 0 and at least `canopy_area_m2`), and `tide_height_m` SHALL be present, numeric, with no missing values. Size and density `new_data` need no columns, and wet/dry and carbon take no `new_data`. An invalid value SHALL error with a message naming the column, pinned by `tests/testthat/_snaps/chk.md`.

#### Scenario: An impossible diameter errors
- **WHEN** weight `new_data` has a `diameter_mm` that is zero, negative, missing, or not numeric
- **THEN** prediction errors naming `diameter_mm`

#### Scenario: A fractional frond count errors
- **WHEN** weight `new_data` has a non-whole `fronds` value
- **THEN** prediction errors naming `fronds`

#### Scenario: Size and density new data need no columns
- **WHEN** `kb_predict_size()` or `kb_predict_density()` is called with a data frame of only `site`, or of no columns and `n` rows
- **THEN** it returns one prediction per row

#### Scenario: Cover new data need the survey columns
- **WHEN** `kb_predict_cover_biomass(fit, new_data)` is called with `new_data` lacking `tide_height_m`, or with a `canopy_area_m2` above its `plot_area_m2`
- **THEN** prediction errors naming the column

#### Scenario: An impossible area errors
- **WHEN** density `new_data` has an `area_m2` of zero, negative, missing, or not numeric
- **THEN** prediction errors naming `area_m2`

### Requirement: Site biomass

`kb_predict_site_biomass(fit, new_data, wetdry, carbon)` SHALL take a cover biomass fit and a required `new_data` of drone surveys and return the expected total biomass of each row, for the `measure` chosen by a name-only argument: `"wet"` (the default, kg), `"dry"` (kg, needing a wet/dry fit as `wetdry`), or `"carbon"` (kg C, needing `wetdry` and a carbon fit as `carbon`). `new_data` SHALL carry one row per drone survey of a site with `canopy_area_m2` (the canopy delineated within the site, `>= 0`), `tide_height_m`, `site`, and `year`, each with no missing values, and MAY carry `site_area_m2`, the area within the site boundary (`> 0` and at least `canopy_area_m2`). It SHALL return a `kb_predictions` object with the input columns, `cover_support`, `estimate`, `lower`, and `upper`, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). `cover_support` SHALL give the data the cover fit has for the row: `"site, year"` where both its site and its year are in the fit's data, else `"site"` or `"year"` where only one is, else `"none"`.

Per draw, a row's wet total SHALL be the expected biomass per m² of bed, the floor plus the canopy term at full cover with the row's site and year effects, times its tide-corrected canopy area, capped at `site_area_m2` where supplied. The floor SHALL apply over the canopy area only. No observation-level variation SHALL be added. Per draw, the dry total SHALL be the wet total times the expected dry:wet ratio, and the carbon total the dry total times the expected carbon fraction.

The name-only `sum_by` SHALL, when not `NULL`, sum the row totals on each draw within each combination of the named `new_data` columns before summarising, returning one row per combination with those columns, `estimate`, `lower`, and `upper`, ordered by the columns' factor levels or, for character columns, alphabetically; `character(0)` SHALL sum every row. Each `sum_by` column SHALL be character or factor with no missing values. It SHALL warn when a group holds more than one row for the same site and year, since their totals overlap.

Site and year SHALL be resolved as in the prediction verbs, with name-only `new_levels` (default `"sample"`) and `representative_site`; rows naming the same new site or year SHALL share one effect. The function SHALL error, naming the problem, when `new_data` is not supplied, `fit` is not a cover biomass fit, `wetdry` or `carbon` is not a fit of that model, a fit the `measure` needs is not supplied, the fits differ in species, they differ in their number of draws, or `sum_by` names a column `new_data` does not have or one that is not character or factor or has missing values.

#### Scenario: One total per survey
- **WHEN** `kb_predict_site_biomass(fit, new_data)` is called
- **THEN** it returns one row per row of `new_data`, in order, with a `cover_support` column

#### Scenario: The total is bed biomass times canopy area
- **WHEN** a row has a fitted site and year and zero tide height
- **THEN** each draw of its total equals the cover fit's `posterior_epred()` at a fully covered unit plot (`canopy_area_m2 = 1`, `plot_area_m2 = 1`, `tide_height_m = 0`) of that site and year, times the row's `canopy_area_m2`

#### Scenario: Totals scale with canopy area
- **WHEN** two rows differ only in `canopy_area_m2`, with neither capped by `site_area_m2`
- **THEN** the ratio of their totals equals the ratio of their canopy areas on every draw

#### Scenario: The site area caps the corrected canopy
- **WHEN** a row's tide-corrected canopy would exceed its `site_area_m2`
- **THEN** its total is the bed biomass per m² times `site_area_m2`, and without `site_area_m2` the canopy is not capped

#### Scenario: A canopy larger than its site errors
- **WHEN** a row's `canopy_area_m2` exceeds its `site_area_m2`, or `new_data` lacks `canopy_area_m2` or `tide_height_m`
- **THEN** it errors naming the column

#### Scenario: Dry and carbon are per-draw conversions of wet
- **WHEN** `measure = "dry"` or `measure = "carbon"` is requested with the fits it needs
- **THEN** each draw equals the wet total draw times the expected dry:wet ratio draw, and for carbon also times the expected carbon fraction draw

#### Scenario: Sums are taken on the draws
- **WHEN** `sum_by = "year"` is given
- **THEN** it returns one row per year whose draws are the sum of that year's row totals, so its `estimate` is the median of the summed draws rather than the sum of the row medians

#### Scenario: Groups follow factor levels
- **WHEN** `sum_by = "region"` names a factor column
- **THEN** the rows follow its level order, and a numeric or partly missing `region` errors naming the column

#### Scenario: Overlapping rows in a sum warn
- **WHEN** a `sum_by` group holds two rows with the same site and year
- **THEN** it warns that their totals overlap and still returns the sum

#### Scenario: An unseen site is sampled by default
- **WHEN** a row names a site absent from the cover fit's data
- **THEN** its `cover_support` is `"year"` or `"none"`, and its interval under the default `"sample"` is at least as wide as under `"average"`

#### Scenario: Mismatched or missing fits error
- **WHEN** `measure = "carbon"` is requested without `carbon`, or the fits differ in species or number of draws
- **THEN** it errors naming the problem

#### Scenario: Reproducible under a seed
- **WHEN** it is called twice after the same `set.seed()`
- **THEN** the results are identical

