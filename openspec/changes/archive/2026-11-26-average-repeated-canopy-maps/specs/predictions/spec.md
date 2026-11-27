## MODIFIED Requirements

### Requirement: Pooling over groups

`kb_predict_biomass_in_situ()` and `kb_predict_biomass_canopy()` SHALL take a name-only `pool_by`. With `NULL` (the default) they SHALL return one row per input row with the support columns. With a character vector of input columns they SHALL return one row per combination of those columns present, with those columns, the support columns when the columns include both `site` and `year` (every row of such a group shares one site and year, so one support), the summary columns, and the response column, ordered by the columns' factor levels or, for character columns, alphabetically ignoring case; `character(0)` SHALL give one row for all rows. On each draw, survey biomass SHALL be summed in kg within each group and, with `per_area = TRUE`, divided by the group's summed `survey_area_m2`, so each survey is weighted by its area; surveys SHALL be summed as separate areas, so with `per_area = FALSE` a plot surveyed more than once counts once per survey. On each draw, canopy biomass SHALL be averaged over the rows of each site-year within a group, then summed in kg across the group's site-years, so a group counts each site-year's bed once; a group with one row per site-year SHALL equal the sum of its rows. Each `pool_by` column SHALL be character or factor with no missing values; another column, or one the input does not have, SHALL error naming it. A sampled new site or year effect SHALL be shared by every row of that level, so a sum carries the among-site variation once per site.

#### Scenario: Sums are taken on the draws
- **WHEN** `pool_by = "year"` is given
- **THEN** it returns one row per year whose draws are the sum of that year's survey draws, or of its site-years' canopy draws, so its `estimate` is the median of the summed draws rather than the sum of the row medians

#### Scenario: Per-area sums divide by the summed area
- **WHEN** survey biomass is summed with `pool_by = c("site", "year")` and `per_area = TRUE`
- **THEN** each draw is the site-year's total kg over its summed `survey_area_m2`

#### Scenario: Repeated canopy maps are averaged
- **WHEN** canopy biomass with two maps of one site-year is pooled with `pool_by = c("site", "year")`, and with `pool_by = "year"`
- **THEN** that site-year's draws are the mean of its two maps' draws, and its year's draws are that mean plus the other site-years' totals

#### Scenario: A group key that separates maps keeps them apart
- **WHEN** canopy biomass is pooled by `site`, `year`, and a column that differs between the maps of a site-year
- **THEN** each map is its own row, with the draws of its unpooled total

#### Scenario: Groups follow factor levels
- **WHEN** `pool_by = "region"` names a factor column
- **THEN** the rows follow its level order, and a numeric or partly missing `region` errors naming the column

#### Scenario: Site-year pools keep their support
- **WHEN** `pool_by = c("site", "year")` is given
- **THEN** each row keeps the support columns of its site-year, and `pool_by = "year"` returns none

### Requirement: Canopy biomass

`kb_predict_biomass_canopy(fit, new_data, wetdry = NULL, carbon = NULL, nitrogen = NULL, ...)` SHALL take a cover calibration fit and a required `new_data` with one row per map of a site's canopy, each covering the whole site (a site-year MAY have several, such as from imagery weeks apart), with `canopy_area_m2` (`>= 0`), `canopy_tide_height_m`, `site`, `year`, and `classified_area_m2`, the water area within the site that the canopy classification covered, including water where no canopy was found (`> 0` and at least `canopy_area_m2`), each with no missing values. Per draw, a row's wet total SHALL be the expected biomass per m² of bed, the floor plus the canopy term at full cover with the row's site and year effects, times its tide-corrected canopy area: the canopy divided by one minus the tide slope times the tide height, capped at `classified_area_m2`. A row with no canopy SHALL have no corrected canopy at any tide height. The floor SHALL apply over the canopy area only. No observation-level variation SHALL be added. The response column SHALL be `biomass_kg`, `dry_biomass_kg`, `carbon_biomass_kg`, or `nitrogen_biomass_kg`. Each row SHALL carry `cover_support`: `"site, year"` where both its site and its year are in the fit's data, else `"site"` or `"year"` where only one is, else `"none"`. `kb_predict_biomass_canopy()` and `kb_check_data_survey_canopy()` SHALL warn when the largest `classified_area_m2` among the maps of a site-year is more than 1.5 times the smallest, naming the site-years and saying that each map should cover the whole site; the warning SHALL NOT stop the check or the prediction. The message is pinned by `tests/testthat/_snaps/warn.md`.

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
- **WHEN** a row's tide-corrected canopy would exceed its `classified_area_m2`
- **THEN** that draw of its total is the bed biomass per m² times `classified_area_m2`

#### Scenario: Missing or inconsistent columns error
- **WHEN** a row's `canopy_area_m2` exceeds its `classified_area_m2`, or `new_data` lacks `canopy_area_m2`, `canopy_tide_height_m`, or `classified_area_m2`
- **THEN** it errors naming the column

#### Scenario: Maps of a site-year covering different areas warn
- **WHEN** two maps of one site-year have `classified_area_m2` of 1000 and 2000
- **THEN** `kb_predict_biomass_canopy()` and `kb_check_data_survey_canopy()` warn naming that site-year, and still return their result

#### Scenario: Repeated maps of a site-year do not warn
- **WHEN** two maps of one site-year have the same `classified_area_m2` and are pooled by year
- **THEN** no warning is given

#### Scenario: An unseen site is sampled by default
- **WHEN** a row names a site absent from the calibration fit's data
- **THEN** its `cover_support` is `"year"` or `"none"`, and its interval under the default `"sample"` is at least as wide as under `"average"`


### Requirement: Plot predictions

`kb_plot_predictions(predictions)` SHALL return a `ggplot` built from a `kb_predictions` object, never from a fit, and `autoplot()` on a `kb_predictions` object SHALL return the same plot. Predictions made at a `kb_new_data()` grid over a varying predictor SHALL be drawn as a line with a compatibility-interval ribbon; otherwise predictions SHALL be drawn as point ranges. `geom = "bar"` SHALL instead draw those predictions as columns from zero with the compatibility interval as a line, rows that share an x value within a panel side by side, each with its own interval, and a row alone at its x value at full width, and SHALL error for predictions drawn as a curve and with a log axis; the default, `"pointrange"`, SHALL leave every plot as it is without the argument. The x-axis variable SHALL default from the prediction's metadata and be overridable through `x`; the remaining grouping variables SHALL be faceted, the x-axis variable never. `max_facets` SHALL cap the panels drawn with a warning giving how many were shown. The plot SHALL draw only the predictions; raw data are not overlaid, and a user can add them as a layer. `log_axis` SHALL default to `"none"` for every prediction, giving linear axes with the y-axis extended to zero; `"y"` SHALL log-scale the y-axis without extending it to zero, and `"xy"` SHALL log-scale both axes. Numeric axes SHALL label ticks as plain numbers with thousands separators, never in scientific notation, and log-scaled axes SHALL add "log scale" to the axis title (e.g. "Wet weight (kg, log scale)"). A log axis SHALL error when any value it shows (the estimate and limits on y, the x-axis variable on x) is not positive, and `"xy"` SHALL error when the x-axis variable is not numeric. Axis titles SHALL be descriptive and, for a quantity with a unit, give the unit in parentheses (e.g. "Diameter (mm)", "Wet weight (kg)", "Wet biomass (kg/m²)"). The plot SHALL set no theme, so the active theme applies. When the prediction's metadata has been stripped, it SHALL error asking for `x`.

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

#### Scenario: Columns sharing an x value are placed side by side
- **WHEN** unpooled canopy biomass with several maps of one site-year, or unpooled survey biomass with several surveys of one site-year, is plotted with `geom = "bar"`
- **THEN** those rows are drawn as adjacent columns at that x value, each with its own interval, and rows alone at their x value are full width (pinned by the `kb_plot_predictions` vdiffr snapshots)

#### Scenario: Columns for a curve or on a log axis
- **WHEN** a weight curve is plotted with `geom = "bar"`, or mean weight by site with `geom = "bar"` and `log_axis = "y"`
- **THEN** it errors, pointing to `geom = "pointrange"` or `log_axis = "none"`
