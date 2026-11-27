## MODIFIED Requirements

### Requirement: One prediction verb per model

Each model SHALL have one prediction verb, `kb_predict_<model>()`, returning a `kb_predictions` object whose `estimate`, `lower`, and `upper` columns summarise the posterior distribution of the expected response, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). For a model with grouping factors the verb SHALL take `new_data` and predict at its rows, in their order, or at the observed data when `new_data = NULL`. The returned object SHALL hold the input columns plus the summary columns and, when the rows have both `site` and `year` columns, a support column naming the data the fit has for each row's site and year (`weight_support`, `size_support`, or `cover_support`, with the values given under Mean weight and Canopy biomass), placed before the summary columns. Predictions per group or over a predictor sequence SHALL be made by passing a grid from `kb_new_data()` as `new_data`.

- Weight: `kb_predict_weight(fit, new_data)` predicts expected weight (kg). `new_data` SHALL have the species predictor column (`diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*). New data SHALL use the predictor reference stored at fit time.
- Size: `kb_predict_size(fit, new_data)` predicts expected size, the mean of the *Nereocystis* sub-bulb diameter distribution (mm). `new_data` needs no columns.
- Cover calibration: `kb_predict_cover_calibration(fit, new_data)` predicts the expected wet biomass per m² of a plot from its `canopy_area_m2`, `plot_area_m2`, and `canopy_tide_height_m`, which `new_data` SHALL carry.
- Wet/dry: `kb_predict_wetdry(fit)` predicts the expected dry:wet mass ratio, one row for the population of samples. The model has no grouping factors or predictor, so the verb takes no `new_data`; the same summary arguments apply.
- Carbon: `kb_predict_carbon(fit)` predicts the expected carbon fraction of dry mass, one row for the population of samples, on the same terms as wet/dry.

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
- **WHEN** `kb_new_data()` is called on a wet/dry or carbon fit
- **THEN** it errors stating the model has no grouping factors

### Requirement: New data are validated

`new_data` SHALL be validated before prediction: it SHALL be a data frame; for weight, *Nereocystis* `diameter_mm` SHALL be numeric, greater than 0, with no missing values, and *Macrocystis* `fronds` a positive whole number with no missing values; for the cover calibration, `canopy_area_m2` (`>= 0`), `plot_area_m2` (> 0 and at least `canopy_area_m2`), and `canopy_tide_height_m` SHALL be present, numeric, with no missing values. Size `new_data` needs no columns, and wet/dry and carbon take no `new_data`. An invalid value SHALL error with a message naming the column, pinned by `tests/testthat/_snaps/chk.md`.

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

### Requirement: Canopy biomass

`kb_predict_biomass_canopy(fit, new_data, wetdry = NULL, carbon = NULL, ...)` SHALL take a cover calibration fit and a required `new_data` with one row per map of a site's canopy (a site-year MAY have several, such as from imagery weeks apart), with `canopy_area_m2` (`>= 0`), `canopy_tide_height_m`, `site`, `year`, and `classified_area_m2`, the water area within the site that the canopy classification covered, including water where no canopy was found (`> 0` and at least `canopy_area_m2`), each with no missing values. Per draw, a row's wet total SHALL be the expected biomass per m² of bed, the floor plus the canopy term at full cover with the row's site and year effects, times its tide-corrected canopy area: the canopy divided by one minus the tide slope times the tide height, capped at `classified_area_m2`, and equal to `classified_area_m2` where the canopy is positive and the tide height is at or above one over the tide slope. A row with no canopy SHALL have no corrected canopy at any tide height. The floor SHALL apply over the canopy area only. No observation-level variation SHALL be added. The response column SHALL be `biomass_kg`, `dry_biomass_kg`, or `carbon_biomass_kg`. Each row SHALL carry `cover_support`: `"site, year"` where both its site and its year are in the fit's data, else `"site"` or `"year"` where only one is, else `"none"`. Within a `pool_by` group, more than one row for the same site and year SHALL warn that their totals overlap.

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
- **WHEN** a row has `canopy_tide_height_m` of 0, as for canopy already corrected for tide
- **THEN** its corrected canopy equals its `canopy_area_m2`, capped at the plot area or `classified_area_m2`, on every draw

#### Scenario: A negative tide height shrinks the corrected canopy
- **WHEN** a row has a negative tide height
- **THEN** its tide-corrected canopy is smaller than its `canopy_area_m2` on every draw with a positive tide slope, and no tide warning is issued
