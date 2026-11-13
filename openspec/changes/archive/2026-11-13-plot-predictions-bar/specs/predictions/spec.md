## MODIFIED Requirements

### Requirement: Plot predictions

`kb_plot_predictions(predictions)` SHALL return a `ggplot` built from a `kb_predictions` object, never from a fit, and `autoplot()` on a `kb_predictions` object SHALL return the same plot. Predictions made at a `kb_new_data()` grid over a varying predictor SHALL be drawn as a line with a compatibility-interval ribbon; otherwise predictions SHALL be drawn as point ranges. `geom = "bar"` SHALL instead draw those predictions as columns from zero with the compatibility interval as a line, and SHALL error for predictions drawn as a curve and with a log axis; the default, `"pointrange"`, SHALL leave every plot as it is without the argument. The x-axis variable SHALL default from the prediction's metadata and be overridable through `x`; the remaining grouping variables SHALL be faceted, the x-axis variable never. `max_facets` SHALL cap the panels drawn with a warning giving how many were shown. The plot SHALL draw only the predictions; raw data are not overlaid, and a user can add them as a layer. `log_axis` SHALL default to `"none"` for every prediction, giving linear axes with the y-axis extended to zero; `"y"` SHALL log-scale the y-axis without extending it to zero, and `"xy"` SHALL log-scale both axes. Numeric axes SHALL label ticks as plain numbers with thousands separators, never in scientific notation, and log-scaled axes SHALL add "log scale" to the axis title (e.g. "Wet weight (kg, log scale)"). A log axis SHALL error when any value it shows (the estimate and limits on y, the x-axis variable on x) is not positive, and `"xy"` SHALL error when the x-axis variable is not numeric. Axis titles SHALL be descriptive and, for a quantity with a unit, give the unit in parentheses (e.g. "Diameter (mm)", "Wet weight (kg)", "Wet biomass (kg/m²)"). The plot SHALL set no theme, so the active theme applies. When the prediction's metadata has been stripped, it SHALL error asking for `x`.

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

#### Scenario: Biomass by year as columns
- **WHEN** canopy biomass summed with `pool_by = "year"`, or survey biomass summed by site and year, is plotted with `geom = "bar"`
- **THEN** a column from zero is drawn per year with its compatibility interval, faceted by site where site is a grouping variable

#### Scenario: Columns for a curve or on a log axis
- **WHEN** a weight curve is plotted with `geom = "bar"`, or mean weight by site with `geom = "bar"` and `log_axis = "y"`
- **THEN** it errors, pointing to `geom = "pointrange"` or `log_axis = "none"`
