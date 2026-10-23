## MODIFIED Requirements

### Requirement: Derived verbs share their arguments and output

`kb_predict_mean_weight()`, `kb_predict_biomass_survey()`, and `kb_predict_biomass_canopy()` SHALL return a `kb_predictions` object holding the input rows' columns, the summary columns `estimate`, `lower`, and `upper` (with `conf_level`, `estimate`, and `sig_fig` as for the prediction verbs), and the response as a `posterior` `rvar` column of draws named for it, whose summary the summary columns are. Each SHALL take optional `wetdry` and `carbon` fits and a name-only `measure`: `"wet"` (the default), `"dry"` (needing `wetdry`), or `"carbon"` (needing `wetdry` and `carbon`); per draw, dry is wet times the expected dry:wet ratio and carbon is dry times the expected carbon fraction. The measure SHALL never be inferred from the fits supplied. Each SHALL take name-only `new_levels` (default `"sample"`) and `representative_site`, resolved as in "Groups are resolved per row". A character `representative_site` SHALL apply to every fit with site effects. `kb_predict_mean_weight()` and `kb_predict_biomass_survey()` SHALL also take a list named by their fit arguments `weight` and `size`, each element giving the representative sites for that fit, and an element left out or `NULL` following `new_levels` for that fit; a list that is unnamed, or names anything else, SHALL error showing the expected form. Each SHALL error, naming the problem, when an argument is not a fit of the required model, a fit the `measure` needs is not supplied, the fits supplied differ in species, or they differ in their number of draws. Results SHALL be reproducible under `set.seed()`.

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

`kb_predict_mean_weight(weight, size, new_data = NULL, wetdry = NULL, carbon = NULL, ...)` SHALL take a weight and a size fit of the same species and return the expected weight per plant of each row's site-year: the expected weight at size averaged over the site-year's size distribution, truncated above at the largest size in the size fit's data. With `new_data = NULL` the rows SHALL be the site-years in the size fit's data; `new_data` with `site` and `year` columns, or a `kb_new_data()` grid from the size fit, SHALL give other rows. Its response SHALL be wet or dry weight in kg, or carbon in g C, per plant. It SHALL add `weight_support` and `size_support`: `"site-year"` where the site-year is in the fit's data, else `"site, year"` where both its site and its year are, else `"site"` or `"year"` where only one is, else `"none"`. The name-only `n_plants` (default 100) SHALL set the sizes averaged per draw, `progress` SHALL be `"bar"` or `"none"`, and `progress_dir` SHALL behave as for the fits. It SHALL take no `pool_by`. Each site in a character `representative_site` SHALL be fitted in both fits, and each site in a list element in the fit it names. It SHALL error when the size fit has no observed data.

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

`kb_predict_biomass_survey(weight, size, survey, wetdry = NULL, carbon = NULL, ...)` SHALL return the biomass of the surveyed area of each in situ survey. `size` SHALL be a size fit of the weight fit's species, when plants were tallied, or a size census (see the fitting input data), when every counted plant was measured. Per draw, a survey's biomass in kg SHALL be its tallied `plants` times its site-year's mean plant weight (as `kb_predict_mean_weight()`), or the sum over its size census rows, joined by `survey_id`, of the expected weight at each plant's size in the survey's site-year, half for a `partial` plant. A survey with no plants SHALL have zero biomass on every draw; when its size census rows are absent, a message SHALL list such surveys by `survey_id` (suppressed by `progress = "none"`). The name-only `per_area` (default `TRUE`) SHALL divide by `survey_area_m2`, giving biomass per m² of the surveyed area; `FALSE` SHALL give kg in the surveyed area. The response column SHALL be named for the measure and scale: `biomass_kg_m2`, `dry_biomass_kg_m2`, or `carbon_biomass_g_m2` per m², and `biomass_kg`, `dry_biomass_kg`, or `carbon_biomass_kg` in total. Each row SHALL carry the survey's `survey_id`, `site`, and `year`, and `weight_support`, and with a size fit `size_support`. `n_plants`, `progress`, and `progress_dir` SHALL apply with a size fit; `n_plants` supplied with a size census SHALL error. Each site in a character `representative_site` SHALL be fitted in the weight fit, and in the size fit when one is given; each site in a list element SHALL be fitted in the fit it names. A list naming `size` with a size census SHALL error.

#### Scenario: One row per survey
- **WHEN** `kb_predict_biomass_survey(weight, size, survey)` is called
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

