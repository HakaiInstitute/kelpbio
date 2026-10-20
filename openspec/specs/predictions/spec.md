# predictions

## Purpose

Predicting from a fit: the prediction verb of each model and the grids built for
it, how groups and optional inputs are resolved per row, the rstantools draw
generics, survey biomass, totals over mapped canopy, and plotting predictions.
## Requirements
### Requirement: Groups are resolved per row

A row whose `site`, `year`, or site-year is a fitted level SHALL be conditioned on that level's estimated effect. A new level or an absent grouping column SHALL be handled by `new_levels`: `"average"` sets it to zero (the typical group), and `"sample"` draws a new effect from its estimated distribution. Rows naming the same new site, year, or site-year SHALL share one sampled effect, since they are one group; rows whose grouping column is absent SHALL each draw their own. The default SHALL be `"average"` for every model's prediction verb, `predict()`, and the `posterior_*()` generics, and `"sample"` for the derived verbs `kb_predict_mean_weight()`, `kb_predict_biomass_survey()`, and `kb_predict_biomass_canopy()`, whose rows are particular site-years. A new level SHALL NOT error. A missing value in a `site` or `year` column of `new_data` SHALL error, naming the column; a new level is requested by naming it or by leaving out the column. `new_data` with no rows, or with an infinite value in a column the prediction reads, SHALL error. `representative_site` SHALL instead give a new or absent site the estimated site effect of the named fitted site(s), averaged per draw when several are named, and, in a fitted year, their estimated site:year effect for that year, averaged per draw over the named sites observed in that year; a site:year effect none of them has SHALL follow `new_levels`; a name not in the fit SHALL error listing the fitted sites. An effect the fit omitted SHALL contribute nothing, under any `new_levels`.

#### Scenario: New levels are sampled or averaged
- **WHEN** `new_data` holds a site the fit never saw
- **THEN** the prediction does not error; `"sample"` gives an interval at least as wide as `"average"`

#### Scenario: A missing site or year errors
- **WHEN** `new_data` has a `site` or `year` column with a missing value
- **THEN** the prediction errors naming the column and pointing to a named new level or an absent column

#### Scenario: The default is the typical group
- **WHEN** a model's prediction verb or `posterior_epred()` is called without `new_levels` on rows with no `site` or `year` column
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

#### Scenario: A representative site stands in for a new site in a year it was observed
- **WHEN** a new site is predicted in year `y` with `representative_site = s`, where site `s` was observed in `y`
- **THEN** the prediction equals predicting site `s` in year `y`, under either `new_levels`

### Requirement: Draws, likelihood, and priors

`posterior_epred()`, `posterior_linpred()`, and `posterior_predict()` SHALL return a draws-by-rows matrix for `new_data` (or the observed data), resolving groups as above. `posterior_epred()` SHALL give the expected response. Where that differs from the inverse link of the linear predictor, `posterior_linpred(transform = TRUE)` SHALL return the inverse link:

- *Nereocystis* weight, whose log weight is Normal: the expected weight is `exp(mu + sd_residual^2 / 2)`, above the median `exp(mu)`.

For the cover calibration, whose response is censored at zero, the expected biomass SHALL be the mean of the uncensored Normal, `mu`, the quantity totals over canopy use.

The prediction verbs, `fitted()`, and `augment()` SHALL summarise `posterior_epred()`. `posterior_predict()` SHALL add observation noise from the model's likelihood, so repeated calls differ unless a seed is set; for size it draws plant sizes; for wet/dry and carbon it draws ratios or fractions between 0 and 1; for the cover calibration it draws biomass per m² of at least 0, each row's spread including its survey biomass SD, from a `biomass_sd_kg_m2` column or the SD of a `biomass_kg_m2` column of draws, and none when `new_data` has neither. `log_lik()` SHALL return the deterministic pointwise log-likelihood of the observed data, suitable for `loo::loo()`, and error for a fit with no observations. Each value SHALL be the log density of the recorded response on its recorded scale (weight in kg, diameter in mm, a ratio or fraction, or a survey's biomass per m², a survey with none taking the log probability of zero or less), including the Jacobian where the model's likelihood is stated on a transformed scale, so the pointwise log-likelihoods of two models of the same response are comparable. `log_lik()`, `residuals()`, and `posterior_predict()` SHALL use the same observation distribution, and it SHALL be the distribution of the fitted Stan model. `prior_summary()` SHALL return the priors used.

#### Scenario: Expected weight exceeds the median for Nereocystis
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Nereocystis* weight rows
- **THEN** each draw of the former equals the latter times `exp(sd_residual^2 / 2)`

#### Scenario: Calibration replicates are never negative
- **WHEN** `posterior_predict()` is called on a cover calibration fit
- **THEN** every draw is at least 0

#### Scenario: Calibration replicates without a survey biomass SD
- **WHEN** `posterior_predict()` is called on a cover calibration fit with `new_data` lacking `biomass_sd_kg_m2` and `biomass_kg_m2`
- **THEN** it returns draws whose spread is the residual alone, narrower than with a `biomass_sd_kg_m2` column

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

`kb_plot_predictions(predictions)` SHALL return a `ggplot` built from a `kb_predictions` object, never from a fit, and `autoplot()` on a `kb_predictions` object SHALL return the same plot. Predictions made at a `kb_new_data()` grid over a varying predictor SHALL be drawn as a line with a compatibility-interval ribbon; otherwise predictions SHALL be drawn as point ranges. The x-axis variable SHALL default from the prediction's metadata and be overridable through `x`; the remaining grouping variables SHALL be faceted, the x-axis variable never. `max_facets` SHALL cap the panels drawn with a warning giving how many were shown. The plot SHALL draw only the predictions; raw data are not overlaid, and a user can add them as a layer. `log_axis` SHALL default to `"none"` for every prediction, giving linear axes with the y-axis extended to zero; `"y"` SHALL log-scale the y-axis without extending it to zero, and `"xy"` SHALL log-scale both axes. Log-scaled axes SHALL label ticks as plain numbers and add "log scale" to the axis title (e.g. "Wet weight (kg, log scale)"). A log axis SHALL error when any value it shows (the estimate and limits on y, the x-axis variable on x) is not positive, and `"xy"` SHALL error when the x-axis variable is not numeric. Axis titles SHALL be descriptive and, for a quantity with a unit, give the unit in parentheses (e.g. "Sub-bulb diameter (mm)", "Wet weight (kg)", "Wet biomass (kg/m²)"). When the prediction's metadata has been stripped, it SHALL error asking for `x`.

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

#### Scenario: Survey biomass by site-year
- **WHEN** `kb_predict_biomass_survey()` output summed with `pool_by = c("site", "year")` is plotted
- **THEN** point ranges are drawn with year on the x-axis and site faceted, and the y-axis is titled "Wet biomass (kg/m²)"

#### Scenario: Too many facets
- **WHEN** a prediction has more groups than `max_facets`
- **THEN** only `max_facets` panels are drawn and a warning reports how many were shown

#### Scenario: Raw data can be added as a layer
- **WHEN** a weight curve plot gets `+ geom_point(aes(diameter_mm, weight_kg), data = fit$data)`
- **THEN** the plot builds with the raw data drawn over the curve

#### Scenario: Log y-axis
- **WHEN** mean weight by site is plotted with `log_axis = "y"`
- **THEN** the y-axis is log-scaled, does not extend to zero, and is titled with "log scale"

#### Scenario: Log-log curve
- **WHEN** a weight curve is plotted with `log_axis = "xy"`
- **THEN** both axes are log-scaled

#### Scenario: Log axis over non-positive values
- **WHEN** a cover curve at the default `kb_new_data()` grid, which starts at zero cover, is plotted with `log_axis = "xy"`, or survey biomass including a survey with no plants is plotted with `log_axis = "y"`
- **THEN** it errors naming the variable that is not positive

#### Scenario: Log x-axis over groups
- **WHEN** mean weight by site is plotted with `log_axis = "xy"`
- **THEN** it errors because the x-axis is not numeric

### Requirement: Values far outside the fitted range are flagged

Prediction SHALL warn when supplied values of the species predictor lie below half the fitted minimum or above twice the fitted maximum, naming the column, the fitted range, and the column's expected unit where it has one. This applies to any `new_data`, including a grid from `kb_new_data()` with supplied predictor values. The warning SHALL NOT stop the prediction. The message is pinned by `tests/testthat/_snaps/warn.md`.

#### Scenario: Diameter in centimetres at prediction is flagged
- **WHEN** `new_data` gives `diameter_mm` in centimetres to a fit made in millimetres
- **THEN** a warning names `diameter_mm` and the fitted range, and predictions are still returned

#### Scenario: Values within the fitted range raise no warning
- **WHEN** supplied values lie within twice the fitted range
- **THEN** no warning is issued

### Requirement: One prediction verb per model

Each model SHALL have one prediction verb, `kb_predict_<model>()`, returning a `kb_predictions` object whose `estimate`, `lower`, and `upper` columns summarise the posterior distribution of the expected response, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). For a model with grouping factors the verb SHALL take `new_data` and predict at its rows, in their order, or at the observed data when `new_data = NULL`. The returned object SHALL hold the input columns plus the summary columns. Predictions per group or over a predictor sequence SHALL be made by passing a grid from `kb_new_data()` as `new_data`.

- Weight: `kb_predict_weight(fit, new_data)` predicts expected weight (kg). `new_data` SHALL have the species predictor column (`diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*). New data SHALL use the predictor reference stored at fit time.
- Size: `kb_predict_size(fit, new_data)` predicts expected size, the mean of the *Nereocystis* sub-bulb diameter distribution (mm). `new_data` needs no columns.
- Cover calibration: `kb_predict_cover_calibration(fit, new_data)` predicts the expected wet biomass per m² of a plot from its `canopy_area_m2`, `plot_area_m2`, and `tide_height_m`, which `new_data` SHALL carry.
- Wet/dry: `kb_predict_wetdry(fit)` predicts the expected dry:wet mass ratio, one row for the population of samples. The model has no grouping factors or predictor, so the verb takes no `new_data`; the same summary arguments apply.
- Carbon: `kb_predict_carbon(fit)` predicts the expected carbon fraction of dry mass, one row for the population of samples, on the same terms as wet/dry.

`predict()` on a fit SHALL return the same result as the model's verb with the same arguments.

#### Scenario: Predict at the observed data
- **WHEN** `kb_predict_weight(fit)`, `kb_predict_size(fit)`, or `kb_predict_cover_calibration(fit)` is called
- **THEN** it returns one prediction per observed row, whose `estimate` equals `augment(fit)$fitted`

#### Scenario: Predict at supplied rows
- **WHEN** `new_data` carries the columns the model needs (the species predictor for weight, none for size, `canopy_area_m2`, `plot_area_m2`, and `tide_height_m` for the cover calibration)
- **THEN** predictions are returned at exactly those rows, in their order

#### Scenario: Zero cover predicts the floor
- **WHEN** `kb_predict_cover_calibration()` is called at `canopy_area_m2 = 0`
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

`kb_new_data(fit, by = NULL, ...)` SHALL return a data frame for use as `new_data` with a weight, size, or cover calibration fit: one row per level of the factors named in `by` (`NULL` for a single row with no grouping columns, `"site"`, `"year"`, or `c("site", "year")`, the last taking only the combinations in the fitted data), in the fit's level order. Levels of `site` or `year` not named in `by` MAY be supplied by name in `...` (character, factor, or numeric), and each SHALL be crossed with the rest of the grid; a level the fit has not seen SHALL be accepted and resolved at prediction as a new level. For a weight fit the rows SHALL be crossed with values of the species predictor, supplied as a named numeric vector of any length (`diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*) and defaulting to 30 evenly spaced values over the observed range, rounded to whole numbers for `fronds`; the predictor column SHALL take the input column's name. For a cover calibration fit the rows SHALL be crossed with values of tide-corrected cover, supplied as `cover` (proportions from 0 to 1) and defaulting to 30 evenly spaced values from 0 to 1, each row being a unit plot at zero tide height with the `canopy_area_m2`, `plot_area_m2`, and `tide_height_m` columns the prediction reads. It SHALL error, naming the valid values, for an unknown `by` value, a `cover` outside 0 to 1, a predictor value the model's data could not hold (a missing, infinite, or non-positive diameter, or fronds that are not a positive whole number), an argument in `...` that is neither the fit's predictor nor `site` or `year` (such as the other species' predictor, or any predictor for a size fit), a grouping factor both named in `by` and given values, missing grouping values, or a fit with no grouping factors.

#### Scenario: Curves over a named predictor
- **WHEN** `kb_new_data(fit, by = "site", diameter_mm = c(20, 40))` is called on a *Nereocystis* weight fit
- **THEN** it returns two rows per fitted site, with `site` and `diameter_mm` columns

#### Scenario: A single predictor value
- **WHEN** `kb_new_data(fit, by = "site", diameter_mm = 50)` is called on a *Nereocystis* weight fit
- **THEN** it returns one row per fitted site, each at 50 mm

#### Scenario: Cover grids agree with survey rows
- **WHEN** `kb_predict_cover_calibration(fit, kb_new_data(fit, by = "site", cover = 0.5))` is called, and `kb_predict_cover_calibration()` at the same sites with `canopy_area_m2 = 50`, `plot_area_m2 = 100`, and `tide_height_m = 0`
- **THEN** the estimates are equal

#### Scenario: A default predictor sequence
- **WHEN** `kb_new_data(fit)` is called on a weight fit
- **THEN** it returns 30 rows spanning the observed range of the species predictor, with no grouping columns

#### Scenario: Site and year take observed combinations
- **WHEN** `kb_new_data(fit, by = c("site", "year"))` is called
- **THEN** it returns one row per site-year in the fitted data

#### Scenario: Supplied levels are crossed into the grid
- **WHEN** `kb_new_data(fit, by = "site", diameter_mm = 40, year = 2021)` is called on a *Nereocystis* weight fit
- **THEN** it returns one row per fitted site, each in 2021 at 40 mm

#### Scenario: A wrong predictor argument errors
- **WHEN** `kb_new_data()` is given `fronds` for a *Nereocystis* weight fit, any predictor for a size fit, or `year` together with `by = "year"`
- **THEN** it errors naming the columns the grid can take, or the conflict

#### Scenario: A fit without groups errors
- **WHEN** `kb_new_data()` is called on a wet/dry or carbon fit
- **THEN** it errors stating the model has no grouping factors

### Requirement: New data are validated

`new_data` SHALL be validated before prediction: it SHALL be a data frame; for weight, *Nereocystis* `diameter_mm` SHALL be numeric, greater than 0, with no missing values, and *Macrocystis* `fronds` a positive whole number with no missing values; for the cover calibration, `canopy_area_m2` (`>= 0`), `plot_area_m2` (> 0 and at least `canopy_area_m2`), and `tide_height_m` SHALL be present, numeric, with no missing values. Size `new_data` needs no columns, and wet/dry and carbon take no `new_data`. An invalid value SHALL error with a message naming the column, pinned by `tests/testthat/_snaps/chk.md`.

#### Scenario: An impossible diameter errors
- **WHEN** weight `new_data` has a `diameter_mm` that is zero, negative, missing, or not numeric
- **THEN** prediction errors naming `diameter_mm`

#### Scenario: A fractional frond count errors
- **WHEN** weight `new_data` has a non-whole `fronds` value
- **THEN** prediction errors naming `fronds`

#### Scenario: Size new data need no columns
- **WHEN** `kb_predict_size()` is called with a data frame of only `site`, or of no columns and `n` rows
- **THEN** it returns one prediction per row

#### Scenario: Cover new data need the plot columns
- **WHEN** `kb_predict_cover_calibration(fit, new_data)` is called with `new_data` lacking `tide_height_m`, or with a `canopy_area_m2` above its `plot_area_m2`
- **THEN** prediction errors naming the column

### Requirement: Derived verbs share their arguments and output

`kb_predict_mean_weight()`, `kb_predict_biomass_survey()`, and `kb_predict_biomass_canopy()` SHALL return a `kb_predictions` object holding the input rows' columns, the summary columns `estimate`, `lower`, and `upper` (with `conf_level`, `estimate`, and `sig_fig` as for the prediction verbs), and the response as a `posterior` `rvar` column of draws named for it, whose summary the summary columns are. Each SHALL take optional `wetdry` and `carbon` fits and a name-only `measure`: `"wet"` (the default), `"dry"` (needing `wetdry`), or `"carbon"` (needing `wetdry` and `carbon`); per draw, dry is wet times the expected dry:wet ratio and carbon is dry times the expected carbon fraction. The measure SHALL never be inferred from the fits supplied. Each SHALL take name-only `new_levels` (default `"sample"`) and `representative_site`, resolved as in "Groups are resolved per row". Each SHALL error, naming the problem, when an argument is not a fit of the required model, a fit the `measure` needs is not supplied, the fits supplied differ in species, or they differ in their number of draws. Results SHALL be reproducible under `set.seed()`.

#### Scenario: Draws travel with the summary
- **WHEN** a derived verb is called
- **THEN** its response column holds one `rvar` per row, whose summary by the `estimate` function and its quantiles at `conf_level` are the row's `estimate`, `lower`, and `upper`, up to rounding

#### Scenario: Dry and carbon are per-draw conversions of wet
- **WHEN** `measure = "dry"` or `measure = "carbon"` is requested with the fits it needs
- **THEN** each draw equals the wet draw times the expected dry:wet ratio draw, and for carbon also times the expected carbon fraction draw, converted to the verb's carbon unit

#### Scenario: A missing conversion fit errors
- **WHEN** `measure = "carbon"` is requested without a `carbon` fit, or `"dry"` without a `wetdry` fit
- **THEN** it errors naming the missing argument

#### Scenario: Mismatched fits error
- **WHEN** the fits differ in species, a fit is of the wrong model, or the fits differ in their number of draws
- **THEN** it errors naming the mismatch

#### Scenario: Reproducible under a seed
- **WHEN** a derived verb is called twice after the same `set.seed()`
- **THEN** the results are identical

### Requirement: Pooling over groups

`kb_predict_biomass_survey()` and `kb_predict_biomass_canopy()` SHALL take a name-only `pool_by`. With `NULL` (the default) they SHALL return one row per input row with the support columns. With a character vector of input columns they SHALL return one row per combination of those columns present, with those columns, the summary columns, and the response column, ordered by the columns' factor levels or, for character columns, alphabetically ignoring case; `character(0)` SHALL give one row for all rows. On each draw, biomass SHALL be summed in kg within each group and, for survey biomass with `per_area = TRUE`, divided by the group's summed `survey_area_m2`. Each `pool_by` column SHALL be character or factor with no missing values; another column, or one the input does not have, SHALL error naming it. A sampled new site or year effect SHALL be shared by every row of that level, so a sum carries the among-site variation once per site.

#### Scenario: Sums are taken on the draws
- **WHEN** `pool_by = "year"` is given
- **THEN** it returns one row per year whose draws are the sum of that year's row draws, so its `estimate` is the median of the summed draws rather than the sum of the row medians

#### Scenario: Per-area sums divide by the summed area
- **WHEN** survey biomass is summed with `pool_by = c("site", "year")` and `per_area = TRUE`
- **THEN** each draw is the site-year's total kg over its summed `survey_area_m2`

#### Scenario: Groups follow factor levels
- **WHEN** `pool_by = "region"` names a factor column
- **THEN** the rows follow its level order, and a numeric or partly missing `region` errors naming the column

### Requirement: Mean weight

`kb_predict_mean_weight(weight, size, new_data = NULL, wetdry = NULL, carbon = NULL, ...)` SHALL take a weight and a size fit of the same species and return the expected weight per plant of each row's site-year: the expected weight at size averaged over the site-year's size distribution, truncated above at the largest size in the size fit's data. With `new_data = NULL` the rows SHALL be the site-years in the size fit's data; `new_data` with `site` and `year` columns, or a `kb_new_data()` grid from the size fit, SHALL give other rows. Its response SHALL be wet or dry weight in kg, or carbon in g C, per plant. It SHALL add `weight_support` and `size_support`: `"site-year"` where the site-year is in the fit's data, else `"site, year"` where both its site and its year are, else `"site"` or `"year"` where only one is, else `"none"`. The name-only `n_plants` (default 100) SHALL set the sizes averaged per draw, `progress` SHALL be `"bar"` or `"none"`, and `progress_dir` SHALL behave as for the fits. It SHALL take no `pool_by`. A `representative_site` SHALL be fitted in both fits. It SHALL error when the size fit has no observed data.

#### Scenario: One row per sized site-year by default
- **WHEN** `kb_predict_mean_weight(weight, size)` is called
- **THEN** it returns one row per site-year in the size fit's data with `weight_support` and `size_support`

#### Scenario: Mean weight averages the curve over sizes
- **WHEN** a site-year's site and year effects are observed in both fits
- **THEN** each draw equals the mean expected weight over its truncated size distribution, within the integration error of `n_plants`

#### Scenario: Grids give typical years
- **WHEN** it is called with `kb_new_data(size, by = "site")` and `new_levels = "average"`
- **THEN** it returns one row per fitted site at the typical year

### Requirement: Survey biomass

`kb_predict_biomass_survey(weight, size, survey, wetdry = NULL, carbon = NULL, ...)` SHALL return the biomass of the surveyed area of each in situ survey. `size` SHALL be a size fit of the weight fit's species, when plants were tallied, or a table of every counted plant (see the fitting input data), when every plant was measured. Per draw, a survey's biomass in kg SHALL be its tallied `plants` times its site-year's mean plant weight (as `kb_predict_mean_weight()`), or the sum over its plant rows of the expected weight at each plant's size, half for a `partial` plant. A survey with no plants SHALL have zero biomass on every draw; when its plant rows are absent, a message SHALL list such surveys (suppressed by `progress = "none"`). The name-only `per_area` (default `TRUE`) SHALL divide by `survey_area_m2`, giving biomass per m² of the surveyed area; `FALSE` SHALL give kg in the surveyed area. The response column SHALL be named for the measure and scale: `biomass_kg_m2`, `dry_biomass_kg_m2`, or `carbon_biomass_g_m2` per m², and `biomass_kg`, `dry_biomass_kg`, or `carbon_biomass_kg` in total. Each row SHALL carry `year`, derived from `date`, and `weight_support`, and with a size fit `size_support`. `n_plants`, `progress`, and `progress_dir` SHALL apply with a size fit; `n_plants` supplied with a plant table SHALL error. A `representative_site` SHALL be fitted in the weight fit, and in the size fit when one is given.

#### Scenario: One row per survey
- **WHEN** `kb_predict_biomass_survey(weight, size, survey)` is called
- **THEN** it returns one row per row of `survey`, in order, with the response column `biomass_kg_m2`

#### Scenario: Tallied biomass is plants times mean weight
- **WHEN** sizes come from a size fit
- **THEN** each draw of a survey's biomass per m² equals its `plants` times the site-year's mean plant weight draw, over its `survey_area_m2`

#### Scenario: Census biomass sums the plants
- **WHEN** sizes come from a plant table
- **THEN** each draw of a survey's total equals the sum of its plants' expected weights, half for each `partial` plant

#### Scenario: An empty plant table gives zero biomass
- **WHEN** the plant table has no rows
- **THEN** every survey's biomass is zero on every draw and a message lists the surveys

#### Scenario: A survey table with no rows errors
- **WHEN** `survey` has no rows
- **THEN** it errors naming `survey`

#### Scenario: Several plots and surveys in a site-year
- **WHEN** `survey` holds two plots in one site-year, one surveyed twice
- **THEN** it returns three rows sharing that site-year's weight draws

#### Scenario: A survey with no plant rows is zero
- **WHEN** a survey has no rows in the plant table
- **THEN** its biomass is zero on every draw and a message lists it

#### Scenario: Totals scale by the surveyed area
- **WHEN** it is called with `per_area = FALSE`
- **THEN** each draw equals the per-m² draw times the row's `survey_area_m2`, in a column named `biomass_kg`

### Requirement: Canopy biomass

`kb_predict_biomass_canopy(fit, new_data, wetdry = NULL, carbon = NULL, ...)` SHALL take a cover calibration fit and a required `new_data` with one row per map of a site's canopy (a site-year MAY have several, such as flights weeks apart), with `canopy_area_m2` (`>= 0`), `tide_height_m`, `site`, `year`, and `classified_area_m2`, the water area within the site that the canopy classification covered, including water where no canopy was found (`> 0` and at least `canopy_area_m2`), each with no missing values. Per draw, a row's wet total SHALL be the expected biomass per m² of bed, the floor plus the canopy term at full cover with the row's site and year effects, times its tide-corrected canopy area: the canopy divided by one minus the tide slope times the tide height, capped at `classified_area_m2`, and equal to `classified_area_m2` where the canopy is positive and the tide height is at or above one over the tide slope. A row with no canopy SHALL have no corrected canopy at any tide height. The floor SHALL apply over the canopy area only. No observation-level variation SHALL be added. The response column SHALL be `biomass_kg`, `dry_biomass_kg`, or `carbon_biomass_kg`. Each row SHALL carry `cover_support`: `"site, year"` where both its site and its year are in the fit's data, else `"site"` or `"year"` where only one is, else `"none"`. Within a `pool_by` group, more than one row for the same site and year SHALL warn that their totals overlap.

#### Scenario: One total per row
- **WHEN** `kb_predict_biomass_canopy(fit, new_data)` is called
- **THEN** it returns one row per row of `new_data`, in order, with a `cover_support` column and the response column `biomass_kg`

#### Scenario: The total is bed biomass times canopy area
- **WHEN** a row has a fitted site and year and zero tide height
- **THEN** each draw of its total equals the calibration fit's `posterior_epred()` at a fully covered unit plot (`canopy_area_m2 = 1`, `plot_area_m2 = 1`, `tide_height_m = 0`) of that site and year, times the row's `canopy_area_m2`

#### Scenario: Totals scale with canopy area
- **WHEN** two rows differ only in `canopy_area_m2`, with neither capped by `classified_area_m2`
- **THEN** the ratio of their totals equals the ratio of their canopy areas on every draw

#### Scenario: The tide correction divides the canopy
- **WHEN** a row has tide height `t` and its tide-corrected canopy is below `classified_area_m2` on every draw
- **THEN** each draw of its total equals the same row at zero tide height with its canopy divided by one minus that draw's tide slope times `t`

#### Scenario: The classified area caps the corrected canopy
- **WHEN** a row's tide-corrected canopy would exceed its `classified_area_m2`, or its tide height is at or above one over a draw's tide slope
- **THEN** that draw of its total is the bed biomass per m² times `classified_area_m2`

#### Scenario: Missing or inconsistent columns error
- **WHEN** a row's `canopy_area_m2` exceeds its `classified_area_m2`, or `new_data` lacks `canopy_area_m2`, `tide_height_m`, or `classified_area_m2`
- **THEN** it errors naming the column

#### Scenario: Overlapping rows in a sum warn
- **WHEN** a `pool_by` group holds two rows with the same site and year
- **THEN** it warns that their totals overlap and still returns the sum

#### Scenario: An unseen site is sampled by default
- **WHEN** a row names a site absent from the calibration fit's data
- **THEN** its `cover_support` is `"year"` or `"none"`, and its interval under the default `"sample"` is at least as wide as under `"average"`

### Requirement: The tide correction is bounded

Every prediction from a cover calibration fit (`kb_predict_cover_calibration()`, `kb_predict_biomass_canopy()`, `predict()`, and the `posterior_*()` generics) SHALL be finite at any finite tide height. Where a row with positive canopy has a tide height at or above one over a draw's tide slope, that draw SHALL use full cover for a plot and the classified area for canopy totals; a row with no canopy SHALL keep zero cover and zero canopy. `kb_predict_cover_calibration()` and `kb_predict_biomass_canopy()` SHALL warn when a row of `new_data` with positive canopy is past one over the tide slope on more than 5% of draws, giving the number of such rows and saying that there the corrected canopy is the cap rather than the canopy measured.

#### Scenario: High tides give finite, non-negative predictions
- **WHEN** `kb_predict_cover_calibration()` or `kb_predict_biomass_canopy()` is called at tide heights of 0, 2, 3.5, and 5 m
- **THEN** every draw is finite and non-negative, and the rows past the tide limit on more than 5% of draws warn

#### Scenario: A plot past the tide limit is fully covered
- **WHEN** a row's tide height is at or above one over a draw's tide slope
- **THEN** that draw of `kb_predict_cover_calibration()` equals the same row with `canopy_area_m2` equal to `plot_area_m2` at zero tide height

#### Scenario: No canopy stays zero at any tide
- **WHEN** a row has `canopy_area_m2` of 0 and a tide height above one over every draw's tide slope
- **THEN** its corrected canopy and canopy total are zero on every draw

#### Scenario: Canopy at zero tide height is used as given
- **WHEN** a row has `tide_height_m` of 0, as for canopy already corrected for tide
- **THEN** its corrected canopy equals its `canopy_area_m2`, capped at the plot area or `classified_area_m2`, on every draw

#### Scenario: A negative tide height shrinks the corrected canopy
- **WHEN** a row has a negative tide height
- **THEN** its tide-corrected canopy is smaller than its `canopy_area_m2` on every draw with a positive tide slope, and no tide warning is issued

