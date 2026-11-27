## RENAMED Requirements

- FROM: `### Requirement: Survey biomass`
- TO: `### Requirement: In situ survey biomass`

## MODIFIED Requirements

### Requirement: Groups are resolved per row

A row whose `site`, `year`, or site-year is a fitted level SHALL be conditioned on that level's estimated effect. A new level or an absent grouping column SHALL be handled by `new_levels`: `"average"` sets it to zero (the typical group), and `"sample"` draws a new effect from its estimated distribution. Rows naming the same new site, year, or site-year SHALL share one sampled effect, since they are one group; rows whose grouping column is absent SHALL each draw their own. The default SHALL be `"average"` for every model's prediction verb, `predict()`, and the `posterior_*()` generics, and `"sample"` for the derived verbs `kb_predict_mean_weight()`, `kb_predict_biomass_in_situ()`, and `kb_predict_biomass_canopy()`, whose rows are particular site-years. A new level SHALL NOT error. A `year` column of `new_data`, including the canopy rows of `kb_predict_biomass_canopy()`, MAY be numeric whole numbers, matched to the fitted years as character, as in the fitting input data. A missing value in a `site` or `year` column of `new_data` SHALL error, naming the column; a new level is requested by naming it or by leaving out the column. `new_data` with no rows, or with an infinite value in a column the prediction reads, SHALL error. `representative_site` SHALL instead give a new or absent site the estimated site effect of the named fitted site(s), averaged per draw when several are named, and, in a fitted year, their estimated site:year effect for that year, averaged per draw over the named sites observed in that year; a site:year effect none of them has SHALL follow `new_levels`; a name not in the fit SHALL error listing the fitted sites. An effect the fit omitted SHALL contribute nothing, under any `new_levels`.

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

#### Scenario: A numeric year matches a fitted year
- **WHEN** `new_data` gives `year = 2021` for a fit whose data include year `"2021"`
- **THEN** the prediction equals the same call with `year = "2021"`

### Requirement: Plot predictions

`kb_plot_predictions(predictions)` SHALL return a `ggplot` built from a `kb_predictions` object, never from a fit, and `autoplot()` on a `kb_predictions` object SHALL return the same plot. Predictions made at a `kb_new_data()` grid over a varying predictor SHALL be drawn as a line with a compatibility-interval ribbon; otherwise predictions SHALL be drawn as point ranges. The x-axis variable SHALL default from the prediction's metadata and be overridable through `x`; the remaining grouping variables SHALL be faceted, the x-axis variable never. `max_facets` SHALL cap the panels drawn with a warning giving how many were shown. The plot SHALL draw only the predictions; raw data are not overlaid, and a user can add them as a layer. `log_axis` SHALL default to `"none"` for every prediction, giving linear axes with the y-axis extended to zero; `"y"` SHALL log-scale the y-axis without extending it to zero, and `"xy"` SHALL log-scale both axes. Numeric axes SHALL label ticks as plain numbers with thousands separators, never in scientific notation, and log-scaled axes SHALL add "log scale" to the axis title (e.g. "Wet weight (kg, log scale)"). A log axis SHALL error when any value it shows (the estimate and limits on y, the x-axis variable on x) is not positive, and `"xy"` SHALL error when the x-axis variable is not numeric. Axis titles SHALL be descriptive and, for a quantity with a unit, give the unit in parentheses (e.g. "Sub-bulb diameter (mm)", "Wet weight (kg)", "Wet biomass (kg/m²)"). The plot SHALL set no theme, so the active theme applies. When the prediction's metadata has been stripped, it SHALL error asking for `x`.

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

### Requirement: Derived verbs share their arguments and output

`kb_predict_mean_weight()`, `kb_predict_biomass_in_situ()`, and `kb_predict_biomass_canopy()` SHALL return a `kb_predictions` object holding the input rows' columns, the summary columns `estimate`, `lower`, and `upper` (with `conf_level`, `estimate`, and `sig_fig` as for the prediction verbs), and the response as a `posterior` `rvar` column of draws named for it, whose summary the summary columns are. Each SHALL take optional `wetdry` and `carbon` fits and a name-only `measure`: `"wet"` (the default), `"dry"` (needing `wetdry`), or `"carbon"` (needing `wetdry` and `carbon`); per draw, dry is wet times the expected dry:wet ratio and carbon is dry times the expected carbon fraction. The measure SHALL never be inferred from the fits supplied. Each SHALL take name-only `new_levels` (default `"sample"`) and `representative_site`, resolved as in "Groups are resolved per row". A character `representative_site` SHALL apply to every fit with site effects. `kb_predict_mean_weight()` and `kb_predict_biomass_in_situ()` SHALL also take a list named by their fit arguments `weight` and `size`, each element giving the representative sites for that fit, and an element left out or `NULL` following `new_levels` for that fit; a list that is unnamed, or names anything else, SHALL error showing the expected form. Each SHALL error, naming the problem, when an argument is not a fit of the required model, a fit the `measure` needs is not supplied, the fits supplied differ in species, or they differ in their number of draws. Results SHALL be reproducible under `set.seed()`.

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

### Requirement: Pooling over groups

`kb_predict_biomass_in_situ()` and `kb_predict_biomass_canopy()` SHALL take a name-only `pool_by`. With `NULL` (the default) they SHALL return one row per input row with the support columns. With a character vector of input columns they SHALL return one row per combination of those columns present, with those columns, the support columns when the columns include both `site` and `year` (every row of such a group shares one site and year, so one support), the summary columns, and the response column, ordered by the columns' factor levels or, for character columns, alphabetically ignoring case; `character(0)` SHALL give one row for all rows. On each draw, biomass SHALL be summed in kg within each group and, for survey biomass with `per_area = TRUE`, divided by the group's summed `survey_area_m2`. Each `pool_by` column SHALL be character or factor with no missing values; another column, or one the input does not have, SHALL error naming it. A sampled new site or year effect SHALL be shared by every row of that level, so a sum carries the among-site variation once per site.

#### Scenario: Sums are taken on the draws
- **WHEN** `pool_by = "year"` is given
- **THEN** it returns one row per year whose draws are the sum of that year's row draws, so its `estimate` is the median of the summed draws rather than the sum of the row medians

#### Scenario: Per-area sums divide by the summed area
- **WHEN** survey biomass is summed with `pool_by = c("site", "year")` and `per_area = TRUE`
- **THEN** each draw is the site-year's total kg over its summed `survey_area_m2`

#### Scenario: Groups follow factor levels
- **WHEN** `pool_by = "region"` names a factor column
- **THEN** the rows follow its level order, and a numeric or partly missing `region` errors naming the column

#### Scenario: Site-year pools keep their support
- **WHEN** `pool_by = c("site", "year")` is given
- **THEN** each row keeps the support columns of its site-year, and `pool_by = "year"` returns none

### Requirement: In situ survey biomass

`kb_predict_biomass_in_situ(weight, size, survey, wetdry = NULL, carbon = NULL, ...)` SHALL return the biomass of the surveyed area of each in situ survey. `size` SHALL be a size fit of the weight fit's species, when plants were tallied, or a size census (see the fitting input data), when every counted plant was measured. Per draw, a survey's biomass in kg SHALL be its tallied `plants` times its site-year's mean plant weight (as `kb_predict_mean_weight()`), or the sum over its size census rows, joined by `survey_id`, of the expected weight at each plant's size in the survey's site-year, half for a `partial` plant. A survey with no plants SHALL have zero biomass on every draw; when its size census rows are absent, a message SHALL list such surveys by `survey_id` (suppressed by `progress = "none"`). The name-only `per_area` (default `TRUE`) SHALL divide by `survey_area_m2`, giving biomass per m² of the surveyed area; `FALSE` SHALL give kg in the surveyed area. The response column SHALL be named for the measure and scale: `biomass_kg_m2`, `dry_biomass_kg_m2`, or `carbon_biomass_g_m2` per m², and `biomass_kg`, `dry_biomass_kg`, or `carbon_biomass_kg` in total. Each row SHALL carry the survey's `survey_id`, `site`, and `year`, and `weight_support`, and with a size fit `size_support`. `n_plants`, `progress`, and `progress_dir` SHALL apply with a size fit; `n_plants` supplied with a size census SHALL error. Each site in a character `representative_site` SHALL be fitted in the weight fit, and in the size fit when one is given; each site in a list element SHALL be fitted in the fit it names. A list naming `size` with a size census SHALL error.

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
