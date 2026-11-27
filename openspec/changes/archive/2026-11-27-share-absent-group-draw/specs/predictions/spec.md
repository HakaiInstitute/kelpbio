## MODIFIED Requirements

### Requirement: Groups are resolved per row

A row whose `site`, `year`, or site-year is a fitted level SHALL be conditioned on that level's estimated effect. A new level SHALL be handled by `new_levels`: `"average"` sets its effect to zero (the typical group), and `"sample"` draws a new effect from its estimated distribution. Rows naming the same new site, year, or site-year SHALL share one sampled effect, since they are one group. An absent `site` or `year` column SHALL be one new level shared by every row, so the rows equal the same rows with that column naming one new level, and rows of one site without a `year` column share one new site-year; independent new levels are requested by naming them separately. The default SHALL be `"average"` for every model's prediction verb, `predict()`, and the `posterior_*()` generics, and `"sample"` for the derived verbs `kb_predict_mean_weight()`, `kb_predict_biomass_in_situ()`, and `kb_predict_biomass_canopy()`, whose rows are particular site-years. A new level SHALL NOT error. A `year` column of `new_data`, including the canopy rows of `kb_predict_biomass_canopy()`, MAY be numeric whole numbers, matched to the fitted years as character, as in the fitting input data. A missing value in a `site` or `year` column of `new_data` SHALL error, naming the column and suggesting a name such as `"new"` or leaving out the column. `new_data` with no rows, or with an infinite value in a column the prediction reads, SHALL error. `representative_site` SHALL instead give a new or absent site the estimated site effect of the named fitted site(s), averaged per draw when several are named, and, in a fitted year, their estimated site:year effect for that year, averaged per draw over the named sites observed in that year; a site:year effect none of them has SHALL follow `new_levels`; a name not in the fit SHALL error listing the fitted sites. An effect the fit omitted SHALL contribute nothing, under any `new_levels`.

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

#### Scenario: An absent column is one shared new level
- **WHEN** `posterior_epred()` is called under `new_levels = "sample"` on a weight curve for one fitted site with no `year` column, and under the same seed on the same rows with `year = "new"`
- **THEN** the two calls return identical draws, so the group effect is constant along the curve within each draw

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
