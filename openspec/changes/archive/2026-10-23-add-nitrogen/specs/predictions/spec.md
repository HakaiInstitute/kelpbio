## MODIFIED Requirements

### Requirement: Draws, likelihood, and priors

`posterior_epred()`, `posterior_linpred()`, and `posterior_predict()` SHALL return a draws-by-rows matrix for `new_data` (or the observed data), resolving groups as above. `posterior_epred()` SHALL give the expected response. Where that differs from the inverse link of the linear predictor, `posterior_linpred(transform = TRUE)` SHALL return the inverse link:

- *Nereocystis* weight, whose log weight is Normal: the expected weight is `exp(mu + sd_residual^2 / 2)`, above the median `exp(mu)`.

For the cover calibration, whose response is censored at zero, the expected biomass SHALL be the mean of the uncensored Normal, `mu`, the quantity totals over canopy use.

The prediction verbs, `fitted()`, and `augment()` SHALL summarise `posterior_epred()`. `posterior_predict()` SHALL add observation noise from the model's likelihood, so repeated calls differ unless a seed is set; for size it draws plant sizes; for wet/dry, carbon, and nitrogen it draws ratios or fractions between 0 and 1; for the cover calibration it draws biomass per m² of at least 0, each row's spread including its survey biomass SD, from a `biomass_sd_kg_m2` column or the SD of a `biomass_kg_m2` column of draws, and none when `new_data` has neither. `log_lik()` SHALL return the deterministic pointwise log-likelihood of the observed data, suitable for `loo::loo()`, and error for a fit with no observations. Each value SHALL be the log density of the recorded response on its recorded scale (weight in kg, diameter in mm, a ratio or fraction, or a survey's biomass per m², a survey with none taking the log probability of zero or less), including the Jacobian where the model's likelihood is stated on a transformed scale, so the pointwise log-likelihoods of two models of the same response are comparable. `log_lik()`, `residuals()`, and `posterior_predict()` SHALL use the same observation distribution, and it SHALL be the distribution of the fitted Stan model. `prior_summary()` SHALL return the priors used.

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

### Requirement: One prediction verb per model

Each model SHALL have one prediction verb, `kb_predict_<model>()`, returning a `kb_predictions` object whose `estimate`, `lower`, and `upper` columns summarise the posterior distribution of the expected response, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). For a model with grouping factors the verb SHALL take `new_data` and predict at its rows, in their order, or at the observed data when `new_data = NULL`. The returned object SHALL hold the input columns plus the summary columns and, when the rows have both `site` and `year` columns, a support column naming the data the fit has for each row's site and year (`weight_support`, `size_support`, or `cover_support`, with the values given under Mean weight and Canopy biomass), placed before the summary columns. Predictions per group or over a predictor sequence SHALL be made by passing a grid from `kb_new_data()` as `new_data`.

- Weight: `kb_predict_weight(fit, new_data)` predicts expected weight (kg). `new_data` SHALL have the species predictor column (`diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*). New data SHALL use the predictor reference stored at fit time.
- Size: `kb_predict_size(fit, new_data)` predicts expected size, the mean of the *Nereocystis* plant diameter distribution (mm). `new_data` needs no columns.
- Cover calibration: `kb_predict_cover_calibration(fit, new_data)` predicts the expected wet biomass per m² of a plot from its `canopy_area_m2`, `plot_area_m2`, and `canopy_tide_height_m`, which `new_data` SHALL carry.
- Wet/dry: `kb_predict_wetdry(fit)` predicts the expected dry:wet mass ratio, one row for the population of samples. The model has no grouping factors or predictor, so the verb takes no `new_data`; the same summary arguments apply.
- Carbon: `kb_predict_carbon(fit)` predicts the expected carbon fraction of dry mass, one row for the population of samples, on the same terms as wet/dry.
- Nitrogen: `kb_predict_nitrogen(fit)` predicts the expected nitrogen fraction of dry mass, one row for the population of samples, on the same terms as wet/dry.

`predict()` on a fit SHALL return the same result as the model's verb with the same arguments.

#### Scenario: Predict at the observed data
- **WHEN** `kb_predict_weight(fit)`, `kb_predict_size(fit)`, or `kb_predict_cover_calibration(fit)` is called
- **THEN** it returns one prediction per observed row, whose `estimate` equals `augment(fit)$fitted`

#### Scenario: Predict at supplied rows
- **WHEN** `new_data` carries the columns the model needs (the species predictor for weight, none for size, `canopy_area_m2`, `plot_area_m2`, and `canopy_tide_height_m` for the cover calibration)
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

#### Scenario: Rows with a site and a year carry their support
- **WHEN** `kb_predict_weight(fit, new_data)` is called with `new_data` holding `site` and `year`
- **THEN** each row has a `weight_support` naming the data the weight fit has for its site and year, and `new_data` without both columns gets no support column

### Requirement: Prediction grids

`kb_new_data(fit, by = NULL, ...)` SHALL return a data frame for use as `new_data` with a weight, size, or cover calibration fit: one row per level of the factors named in `by` (`NULL` for a single row with no grouping columns, `"site"`, `"year"`, or `c("site", "year")`, the last taking only the combinations in the fitted data), in the fit's level order. Levels of `site` or `year` not named in `by` MAY be supplied by name in `...` (character, factor, or numeric), and each SHALL be crossed with the rest of the grid; a level the fit has not seen SHALL be accepted and resolved at prediction as a new level. For a weight fit the rows SHALL be crossed with values of the species predictor, supplied as a named numeric vector of any length (`diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*) and defaulting to 30 evenly spaced values over the observed range, rounded to whole numbers for `fronds`; the predictor column SHALL take the input column's name. For a cover calibration fit the rows SHALL be crossed with values of tide-corrected cover, supplied as `cover` (proportions from 0 to 1) and defaulting to 30 evenly spaced values from 0 to 1, each row being a unit plot at zero tide height with the `canopy_area_m2`, `plot_area_m2`, and `canopy_tide_height_m` columns the prediction reads. It SHALL error, naming the valid values, for an unknown `by` value, a `cover` outside 0 to 1, a predictor value the model's data could not hold (a missing, infinite, or non-positive diameter, or fronds that are not a positive whole number), an argument in `...` that is neither the fit's predictor nor `site` or `year` (such as the other species' predictor, or any predictor for a size fit), a grouping factor both named in `by` and given values, missing grouping values, or a fit with no grouping factors.

#### Scenario: Curves over a named predictor
- **WHEN** `kb_new_data(fit, by = "site", diameter_mm = c(20, 40))` is called on a *Nereocystis* weight fit
- **THEN** it returns two rows per fitted site, with `site` and `diameter_mm` columns

#### Scenario: A single predictor value
- **WHEN** `kb_new_data(fit, by = "site", diameter_mm = 50)` is called on a *Nereocystis* weight fit
- **THEN** it returns one row per fitted site, each at 50 mm

#### Scenario: Cover grids agree with survey rows
- **WHEN** `kb_predict_cover_calibration(fit, kb_new_data(fit, by = "site", cover = 0.5))` is called, and `kb_predict_cover_calibration()` at the same sites with `canopy_area_m2 = 50`, `plot_area_m2 = 100`, and `canopy_tide_height_m = 0`
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
- **WHEN** `kb_new_data()` is called on a wet/dry, carbon, or nitrogen fit
- **THEN** it errors stating the model has no grouping factors

### Requirement: New data are validated

`new_data` SHALL be validated before prediction: it SHALL be a data frame; for weight, *Nereocystis* `diameter_mm` SHALL be numeric, greater than 0, with no missing values, and *Macrocystis* `fronds` a positive whole number with no missing values; for the cover calibration, `canopy_area_m2` (`>= 0`), `plot_area_m2` (> 0 and at least `canopy_area_m2`), and `canopy_tide_height_m` SHALL be present, numeric, with no missing values. Size `new_data` needs no columns, and wet/dry, carbon, and nitrogen take no `new_data`. An invalid value SHALL error with a message naming the column, pinned by `tests/testthat/_snaps/chk.md`.

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
- **WHEN** `kb_predict_cover_calibration(fit, new_data)` is called with `new_data` lacking `canopy_tide_height_m`, or with a `canopy_area_m2` above its `plot_area_m2`
- **THEN** prediction errors naming the column

### Requirement: Derived verbs share their arguments and output

`kb_predict_mean_weight()`, `kb_predict_biomass_in_situ()`, and `kb_predict_biomass_canopy()` SHALL return a `kb_predictions` object holding the input rows' columns, the summary columns `estimate`, `lower`, and `upper` (with `conf_level`, `estimate`, and `sig_fig` as for the prediction verbs), and the response as a `posterior` `rvar` column of draws named for it, whose summary the summary columns are. Each SHALL take optional `wetdry`, `carbon`, and `nitrogen` fits and a name-only `measure`: `"wet"` (the default), `"dry"` (needing `wetdry`), `"carbon"` (needing `wetdry` and `carbon`), or `"nitrogen"` (needing `wetdry` and `nitrogen`); per draw, dry is wet times the expected dry:wet ratio carbon is dry times the expected carbon fraction, and nitrogen is dry times the expected nitrogen fraction. The measure SHALL never be inferred from the fits supplied. Each SHALL take name-only `new_levels` (default `"sample"`) and `representative_site`, resolved as in "Groups are resolved per row". A character `representative_site` SHALL apply to every fit with site effects. `kb_predict_mean_weight()` and `kb_predict_biomass_in_situ()` SHALL also take a list named by their fit arguments `weight` and `size`, each element giving the representative sites for that fit, and an element left out or `NULL` following `new_levels` for that fit; a list that is unnamed, or names anything else, SHALL error showing the expected form. Each SHALL error, naming the problem, when an argument is not a fit of the required model, a fit the `measure` needs is not supplied, the fits supplied differ in species, or they differ in their number of draws. Results SHALL be reproducible under `set.seed()`.

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

#### Scenario: Representative sites per fit
- **WHEN** `kb_predict_mean_weight()` is called with `representative_site = list(weight = s)`, where `s` is fitted in the weight fit only, on a site new to the weight fit and fitted in the size fit
- **THEN** it does not error, the weight fit's site effect is that of `s`, and the size fit's site effect is the row's own fitted site

#### Scenario: A malformed per-fit list errors
- **WHEN** `representative_site` is an unnamed list or names an element other than `weight` or `size`
- **THEN** it errors showing the expected form

### Requirement: Mean weight

`kb_predict_mean_weight(weight, size, new_data = NULL, wetdry = NULL, carbon = NULL, nitrogen = NULL, ...)` SHALL take a weight and a size fit of the same species and return the expected weight per plant of each row's site-year: the expected weight at size averaged over the site-year's size distribution, truncated above at the largest size in the size fit's data. With `new_data = NULL` the rows SHALL be the site-years in the size fit's data; `new_data` with `site` and `year` columns, or a `kb_new_data()` grid from the size fit, SHALL give other rows. Its response SHALL be wet or dry weight in kg, or carbon or nitrogen in g, per plant. It SHALL add `weight_support` and `size_support`: `"site-year"` where the site-year is in the fit's data, else `"site, year"` where both its site and its year are, else `"site"` or `"year"` where only one is, else `"none"`. The name-only `n_plants` (default 100) SHALL set the sizes averaged per draw, `progress` SHALL be `"bar"` or `"none"`, and `progress_dir` SHALL behave as for the fits. It SHALL take no `pool_by`. Each site in a character `representative_site` SHALL be fitted in both fits, and each site in a list element in the fit it names. It SHALL error when the size fit has no observed data.

#### Scenario: One row per sized site-year by default
- **WHEN** `kb_predict_mean_weight(weight, size)` is called
- **THEN** it returns one row per site-year in the size fit's data with `weight_support` and `size_support`

#### Scenario: Mean weight averages the curve over sizes
- **WHEN** a site-year's site and year effects are observed in both fits
- **THEN** each draw equals the mean expected weight over its truncated size distribution, within the integration error of `n_plants`

#### Scenario: Grids give typical years
- **WHEN** it is called with `kb_new_data(size, by = "site")` and `new_levels = "average"`
- **THEN** it returns one row per fitted site at the typical year

### Requirement: Canopy biomass

`kb_predict_biomass_canopy(fit, new_data, wetdry = NULL, carbon = NULL, nitrogen = NULL, ...)` SHALL take a cover calibration fit and a required `new_data` with one row per map of a site's canopy (a site-year MAY have several, such as from imagery weeks apart), with `canopy_area_m2` (`>= 0`), `canopy_tide_height_m`, `site`, `year`, and `classified_area_m2`, the water area within the site that the canopy classification covered, including water where no canopy was found (`> 0` and at least `canopy_area_m2`), each with no missing values. Per draw, a row's wet total SHALL be the expected biomass per m² of bed, the floor plus the canopy term at full cover with the row's site and year effects, times its tide-corrected canopy area: the canopy divided by one minus the tide slope times the tide height, capped at `classified_area_m2`, and equal to `classified_area_m2` where the canopy is positive and the tide height is at or above one over the tide slope. A row with no canopy SHALL have no corrected canopy at any tide height. The floor SHALL apply over the canopy area only. No observation-level variation SHALL be added. The response column SHALL be `biomass_kg`, `dry_biomass_kg`, `carbon_biomass_kg`, or `nitrogen_biomass_kg`. Each row SHALL carry `cover_support`: `"site, year"` where both its site and its year are in the fit's data, else `"site"` or `"year"` where only one is, else `"none"`. Within a `pool_by` group, more than one row for the same site and year SHALL warn that their totals overlap.

#### Scenario: One total per row
- **WHEN** `kb_predict_biomass_canopy(fit, new_data)` is called
- **THEN** it returns one row per row of `new_data`, in order, with a `cover_support` column and the response column `biomass_kg`

#### Scenario: The total is bed biomass times canopy area
- **WHEN** a row has a fitted site and year and zero tide height
- **THEN** each draw of its total equals the calibration fit's `posterior_epred()` at a fully covered unit plot (`canopy_area_m2 = 1`, `plot_area_m2 = 1`, `canopy_tide_height_m = 0`) of that site and year, times the row's `canopy_area_m2`

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
- **WHEN** a row's `canopy_area_m2` exceeds its `classified_area_m2`, or `new_data` lacks `canopy_area_m2`, `canopy_tide_height_m`, or `classified_area_m2`
- **THEN** it errors naming the column

#### Scenario: Overlapping rows in a sum warn
- **WHEN** a `pool_by` group holds two rows with the same site and year
- **THEN** it warns that their totals overlap and still returns the sum

#### Scenario: An unseen site is sampled by default
- **WHEN** a row names a site absent from the calibration fit's data
- **THEN** its `cover_support` is `"year"` or `"none"`, and its interval under the default `"sample"` is at least as wide as under `"average"`

### Requirement: In situ survey biomass

`kb_predict_biomass_in_situ(weight, size, survey, wetdry = NULL, carbon = NULL, nitrogen = NULL, ...)` SHALL return the biomass of the surveyed area of each in situ survey. `size` SHALL be a size fit of the weight fit's species, when plants were tallied, or a size census (see the fitting input data), when every counted plant was measured. Per draw, a survey's biomass in kg SHALL be its tallied `plants` times its site-year's mean plant weight (as `kb_predict_mean_weight()`), or the sum over its size census rows, joined by `survey_id`, of the expected weight at each plant's size in the survey's site-year, half for a `partial` plant. A survey with no plants SHALL have zero biomass on every draw; when its size census rows are absent, a message SHALL list such surveys by `survey_id` (suppressed by `progress = "none"`). The name-only `per_area` (default `TRUE`) SHALL divide by `survey_area_m2`, giving biomass per m² of the surveyed area; `FALSE` SHALL give kg in the surveyed area. The response column SHALL be named for the measure and scale: `biomass_kg_m2`, `dry_biomass_kg_m2`, `carbon_biomass_g_m2`, or `nitrogen_biomass_g_m2` per m², and `biomass_kg`, `dry_biomass_kg`, `carbon_biomass_kg`, or `nitrogen_biomass_kg` in total. Each row SHALL carry the survey's `survey_id`, `site`, and `year`, and `weight_support`, and with a size fit `size_support`. `n_plants`, `progress`, and `progress_dir` SHALL apply with a size fit; `n_plants` supplied with a size census SHALL error. Each site in a character `representative_site` SHALL be fitted in the weight fit, and in the size fit when one is given; each site in a list element SHALL be fitted in the fit it names. A list naming `size` with a size census SHALL error.

#### Scenario: One row per survey
- **WHEN** `kb_predict_biomass_in_situ(weight, size, survey)` is called
- **THEN** it returns one row per row of `survey`, in order, with its `survey_id` and the response column `biomass_kg_m2`

#### Scenario: Tallied biomass is plants times mean weight
- **WHEN** sizes come from a size fit
- **THEN** each draw of a survey's biomass per m² equals its `plants` times the site-year's mean plant weight draw, over its `survey_area_m2`

#### Scenario: Census biomass sums the plants
- **WHEN** sizes come from a size census
- **THEN** each draw of a survey's total equals the sum of the expected weights of the plants with its `survey_id`, half for each `partial` plant

#### Scenario: An empty size census gives zero biomass
- **WHEN** the size census has no rows
- **THEN** every survey's biomass is zero on every draw and a message lists the surveys

#### Scenario: A survey table with no rows errors
- **WHEN** `survey` has no rows
- **THEN** it errors naming `survey`

#### Scenario: Several surveys in a site-year
- **WHEN** `survey` holds three surveys in one site-year, two of them on the same day
- **THEN** it returns three rows sharing that site-year's weight draws

#### Scenario: A survey with no size census rows is zero
- **WHEN** a survey has no rows in the size census
- **THEN** its biomass is zero on every draw and a message lists its `survey_id`

#### Scenario: Totals scale by the surveyed area
- **WHEN** it is called with `per_area = FALSE`
- **THEN** each draw equals the per-m² draw times the row's `survey_area_m2`, in a column named `biomass_kg`

#### Scenario: A size representative with a size census errors
- **WHEN** `size` is a size census and `representative_site` is a list naming `size`
- **THEN** it errors naming `representative_site`
