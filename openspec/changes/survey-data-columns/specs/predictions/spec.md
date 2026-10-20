## MODIFIED Requirements

### Requirement: Groups are resolved per row

A row whose `site`, `year`, or site-year is a fitted level SHALL be conditioned on that level's estimated effect. A new level or an absent grouping column SHALL be handled by `new_levels`: `"average"` sets it to zero (the typical group), and `"sample"` draws a new effect from its estimated distribution. Rows naming the same new site, year, or site-year SHALL share one sampled effect, since they are one group; rows whose grouping column is absent SHALL each draw their own. The default SHALL be `"average"` for every model's prediction verb, `predict()`, and the `posterior_*()` generics, and `"sample"` for the derived verbs `kb_predict_mean_weight()`, `kb_predict_biomass_survey()`, and `kb_predict_biomass_canopy()`, whose rows are particular site-years. A new level SHALL NOT error. A `year` column of `new_data`, including the canopy rows of `kb_predict_biomass_canopy()`, MAY be numeric whole numbers, matched to the fitted years as character, as in the fitting input data. A missing value in a `site` or `year` column of `new_data` SHALL error, naming the column; a new level is requested by naming it or by leaving out the column. `new_data` with no rows, or with an infinite value in a column the prediction reads, SHALL error. `representative_site` SHALL instead give a new or absent site the estimated site effect of the named fitted site(s), averaged per draw when several are named, and, in a fitted year, their estimated site:year effect for that year, averaged per draw over the named sites observed in that year; a site:year effect none of them has SHALL follow `new_levels`; a name not in the fit SHALL error listing the fitted sites. An effect the fit omitted SHALL contribute nothing, under any `new_levels`.

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

### Requirement: Survey biomass

`kb_predict_biomass_survey(weight, size, survey, wetdry = NULL, carbon = NULL, ...)` SHALL return the biomass of the surveyed area of each in situ survey. `size` SHALL be a size fit of the weight fit's species, when plants were tallied, or a size census (see the fitting input data), when every counted plant was measured. Per draw, a survey's biomass in kg SHALL be its tallied `plants` times its site-year's mean plant weight (as `kb_predict_mean_weight()`), or the sum over its size census rows, joined by `survey_id`, of the expected weight at each plant's size in the survey's site-year, half for a `partial` plant. A survey with no plants SHALL have zero biomass on every draw; when its size census rows are absent, a message SHALL list such surveys by `survey_id` (suppressed by `progress = "none"`). The name-only `per_area` (default `TRUE`) SHALL divide by `survey_area_m2`, giving biomass per m² of the surveyed area; `FALSE` SHALL give kg in the surveyed area. The response column SHALL be named for the measure and scale: `biomass_kg_m2`, `dry_biomass_kg_m2`, or `carbon_biomass_g_m2` per m², and `biomass_kg`, `dry_biomass_kg`, or `carbon_biomass_kg` in total. Each row SHALL carry the survey's `survey_id`, `site`, and `year`, and `weight_support`, and with a size fit `size_support`. `n_plants`, `progress`, and `progress_dir` SHALL apply with a size fit; `n_plants` supplied with a size census SHALL error. A `representative_site` SHALL be fitted in the weight fit, and in the size fit when one is given.

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
