## MODIFIED Requirements

### Requirement: Groups are resolved per row

A row whose `site`, `year`, or site-year is a fitted level SHALL be conditioned on that level's estimated effect. A new level or an absent grouping column SHALL be handled by `new_levels`: `"average"` sets it to zero (the typical group), and `"sample"` draws a new effect from its estimated distribution. Rows naming the same new site, year, or site-year SHALL share one sampled effect, since they are one group; rows whose grouping column is absent SHALL each draw their own. The default SHALL be `"average"` for every prediction verb, `predict()`, and the `posterior_*()` generics, and `"sample"` for `kb_predict_plot_biomass()` and `kb_predict_site_biomass()`, whose rows are particular surveyed site-years. A new level SHALL NOT error. A missing value in a `site` or `year` column of `new_data` SHALL error, naming the column; a new level is requested by naming it or by leaving out the column. A `year` column of `new_data`, for every prediction verb, `predict()`, the `posterior_*()` generics, and `kb_predict_site_biomass()`, MAY be character, factor, or whole-number numeric; a numeric year SHALL name the level of the same digits and SHALL be returned as a factor, and a year that is not a whole number SHALL error naming the column, as SHALL such a year given to `kb_new_data()`. `new_data` with no rows, or with an infinite value in a column the prediction reads, SHALL error. `representative_site` SHALL instead give a new or absent site the estimated site effect of the named fitted site(s), averaged per draw when several are named, and, in a fitted year, their estimated site:year effect for that year, averaged per draw over the named sites observed in that year; a site:year effect none of them has SHALL follow `new_levels`; a name not in the fit SHALL error listing the fitted sites. An effect the fit omitted SHALL contribute nothing, under any `new_levels`.

#### Scenario: New levels are sampled or averaged
- **WHEN** `new_data` holds a site the fit never saw
- **THEN** the prediction does not error; `"sample"` gives an interval at least as wide as `"average"`

#### Scenario: A missing site or year errors
- **WHEN** `new_data` has a `site` or `year` column with a missing value
- **THEN** the prediction errors naming the column and pointing to a named new level or an absent column

#### Scenario: A numeric year names a fitted level
- **WHEN** `new_data` gives a fitted year as a number, such as 2020 for the fitted level `"2020"`
- **THEN** the prediction equals the one made with the character year, and the returned `year` column is a factor

#### Scenario: A fractional year errors
- **WHEN** `new_data` or `kb_new_data()` is given a `year` such as 2020.5
- **THEN** it errors naming the column

#### Scenario: The default is the typical group
- **WHEN** a prediction verb or `posterior_epred()` is called without `new_levels` on rows with no `site` or `year` column
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
- **WHEN** a new site is predicted in year `y` with `representative_site = s`, where site `s` was observed in `y`, with the same `stipes_m2` as site `s` in `y`
- **THEN** the prediction equals predicting site `s` in year `y`, under either `new_levels`
