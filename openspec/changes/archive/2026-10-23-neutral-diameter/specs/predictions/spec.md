## MODIFIED Requirements

### Requirement: Plot predictions

`kb_plot_predictions(predictions)` SHALL return a `ggplot` built from a `kb_predictions` object, never from a fit, and `autoplot()` on a `kb_predictions` object SHALL return the same plot. Predictions made at a `kb_new_data()` grid over a varying predictor SHALL be drawn as a line with a compatibility-interval ribbon; otherwise predictions SHALL be drawn as point ranges. The x-axis variable SHALL default from the prediction's metadata and be overridable through `x`; the remaining grouping variables SHALL be faceted, the x-axis variable never. `max_facets` SHALL cap the panels drawn with a warning giving how many were shown. The plot SHALL draw only the predictions; raw data are not overlaid, and a user can add them as a layer. `log_axis` SHALL default to `"none"` for every prediction, giving linear axes with the y-axis extended to zero; `"y"` SHALL log-scale the y-axis without extending it to zero, and `"xy"` SHALL log-scale both axes. Numeric axes SHALL label ticks as plain numbers with thousands separators, never in scientific notation, and log-scaled axes SHALL add "log scale" to the axis title (e.g. "Wet weight (kg, log scale)"). A log axis SHALL error when any value it shows (the estimate and limits on y, the x-axis variable on x) is not positive, and `"xy"` SHALL error when the x-axis variable is not numeric. Axis titles SHALL be descriptive and, for a quantity with a unit, give the unit in parentheses (e.g. "Diameter (mm)", "Wet weight (kg)", "Wet biomass (kg/m²)"). The plot SHALL set no theme, so the active theme applies. When the prediction's metadata has been stripped, it SHALL error asking for `x`.

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
- **WHEN** `kb_predict_biomass_in_situ()` output summed with `pool_by = c("site", "year")` is plotted
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

#### Scenario: Large totals are labelled in full
- **WHEN** canopy biomass totals of hundreds of thousands of kilograms are plotted on linear axes
- **THEN** the y-axis ticks read as plain numbers such as "200,000", not "2e+05"

### Requirement: One prediction verb per model

Each model SHALL have one prediction verb, `kb_predict_<model>()`, returning a `kb_predictions` object whose `estimate`, `lower`, and `upper` columns summarise the posterior distribution of the expected response, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). For a model with grouping factors the verb SHALL take `new_data` and predict at its rows, in their order, or at the observed data when `new_data = NULL`. The returned object SHALL hold the input columns plus the summary columns and, when the rows have both `site` and `year` columns, a support column naming the data the fit has for each row's site and year (`weight_support`, `size_support`, or `cover_support`, with the values given under Mean weight and Canopy biomass), placed before the summary columns. Predictions per group or over a predictor sequence SHALL be made by passing a grid from `kb_new_data()` as `new_data`.

- Weight: `kb_predict_weight(fit, new_data)` predicts expected weight (kg). `new_data` SHALL have the species predictor column (`diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*). New data SHALL use the predictor reference stored at fit time.
- Size: `kb_predict_size(fit, new_data)` predicts expected size, the mean of the *Nereocystis* plant diameter distribution (mm). `new_data` needs no columns.
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
