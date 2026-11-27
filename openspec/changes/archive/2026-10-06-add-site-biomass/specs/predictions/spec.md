## ADDED Requirements

### Requirement: Site biomass

`kb_predict_site_biomass(fit, new_data, wetdry, carbon)` SHALL take a cover biomass fit and a required `new_data` of drone surveys and return the expected total biomass of each row, for the `measure` chosen by a name-only argument: `"wet"` (the default, kg), `"dry"` (kg, needing a wet/dry fit as `wetdry`), or `"carbon"` (kg C, needing `wetdry` and a carbon fit as `carbon`). `new_data` SHALL carry one row per drone survey of a site with `canopy_area_m2` (the canopy delineated within the site, `>= 0`), `tide_height_m`, `site`, and `year`, each with no missing values, and MAY carry `site_area_m2`, the area within the site boundary (`> 0` and at least `canopy_area_m2`). It SHALL return a `kb_predictions` object with the input columns, `cover_support`, `estimate`, `lower`, and `upper`, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). `cover_support` SHALL give the data the cover fit has for the row: `"site, year"` where both its site and its year are in the fit's data, else `"site"` or `"year"` where only one is, else `"none"`.

Per draw, a row's wet total SHALL be the expected biomass per m² of bed, the floor plus the canopy term at full cover with the row's site and year effects, times its tide-corrected canopy area, capped at `site_area_m2` where supplied. The floor SHALL apply over the canopy area only. No observation-level variation SHALL be added. Per draw, the dry total SHALL be the wet total times the expected dry:wet ratio, and the carbon total the dry total times the expected carbon fraction.

The name-only `sum_by` SHALL, when not `NULL`, sum the row totals on each draw within each combination of the named `new_data` columns before summarising, returning one row per combination with those columns, `estimate`, `lower`, and `upper`, ordered by the columns' factor levels or, for character columns, alphabetically; `character(0)` SHALL sum every row. Each `sum_by` column SHALL be character or factor with no missing values. It SHALL warn when a group holds more than one row for the same site and year, since their totals overlap.

Site and year SHALL be resolved as in the prediction verbs, with name-only `new_levels` (default `"sample"`) and `representative_site`; rows naming the same new site or year SHALL share one effect. The function SHALL error, naming the problem, when `new_data` is not supplied, `fit` is not a cover biomass fit, `wetdry` or `carbon` is not a fit of that model, a fit the `measure` needs is not supplied, the fits differ in species, they differ in their number of draws, or `sum_by` names a column `new_data` does not have or one that is not character or factor or has missing values.

#### Scenario: One total per survey
- **WHEN** `kb_predict_site_biomass(fit, new_data)` is called
- **THEN** it returns one row per row of `new_data`, in order, with a `cover_support` column

#### Scenario: The total is bed biomass times canopy area
- **WHEN** a row has a fitted site and year and zero tide height
- **THEN** each draw of its total equals the cover fit's `posterior_epred()` at a fully covered unit plot (`canopy_area_m2 = 1`, `plot_area_m2 = 1`, `tide_height_m = 0`) of that site and year, times the row's `canopy_area_m2`

#### Scenario: Totals scale with canopy area
- **WHEN** two rows differ only in `canopy_area_m2`, with neither capped by `site_area_m2`
- **THEN** the ratio of their totals equals the ratio of their canopy areas on every draw

#### Scenario: The site area caps the corrected canopy
- **WHEN** a row's tide-corrected canopy would exceed its `site_area_m2`
- **THEN** its total is the bed biomass per m² times `site_area_m2`, and without `site_area_m2` the canopy is not capped

#### Scenario: A canopy larger than its site errors
- **WHEN** a row's `canopy_area_m2` exceeds its `site_area_m2`, or `new_data` lacks `canopy_area_m2` or `tide_height_m`
- **THEN** it errors naming the column

#### Scenario: Dry and carbon are per-draw conversions of wet
- **WHEN** `measure = "dry"` or `measure = "carbon"` is requested with the fits it needs
- **THEN** each draw equals the wet total draw times the expected dry:wet ratio draw, and for carbon also times the expected carbon fraction draw

#### Scenario: Sums are taken on the draws
- **WHEN** `sum_by = "year"` is given
- **THEN** it returns one row per year whose draws are the sum of that year's row totals, so its `estimate` is the median of the summed draws rather than the sum of the row medians

#### Scenario: Groups follow factor levels
- **WHEN** `sum_by = "region"` names a factor column
- **THEN** the rows follow its level order, and a numeric or partly missing `region` errors naming the column

#### Scenario: Overlapping rows in a sum warn
- **WHEN** a `sum_by` group holds two rows with the same site and year
- **THEN** it warns that their totals overlap and still returns the sum

#### Scenario: An unseen site is sampled by default
- **WHEN** a row names a site absent from the cover fit's data
- **THEN** its `cover_support` is `"year"` or `"none"`, and its interval under the default `"sample"` is at least as wide as under `"average"`

#### Scenario: Mismatched or missing fits error
- **WHEN** `measure = "carbon"` is requested without `carbon`, or the fits differ in species or number of draws
- **THEN** it errors naming the problem

#### Scenario: Reproducible under a seed
- **WHEN** it is called twice after the same `set.seed()`
- **THEN** the results are identical

## MODIFIED Requirements

### Requirement: Groups are resolved per row

A row whose `site`, `year`, or site-year is a fitted level SHALL be conditioned on that level's estimated effect. A new level or an absent grouping column SHALL be handled by `new_levels`: `"average"` sets it to zero (the typical group), and `"sample"` draws a new effect from its estimated distribution. Rows naming the same new site, year, or site-year SHALL share one sampled effect, since they are one group; rows whose grouping column is absent SHALL each draw their own. The default SHALL be `"average"` for every prediction verb, `predict()`, and the `posterior_*()` generics, and `"sample"` for `kb_predict_plot_biomass()` and `kb_predict_site_biomass()`, whose rows are particular surveyed site-years. A new level SHALL NOT error. `representative_site` SHALL instead give a new or absent site the estimated site effect of the named fitted site(s), averaged per draw when several are named, while site:year still follows `new_levels`; a name not in the fit SHALL error listing the fitted sites. An effect the fit omitted SHALL contribute nothing, under any `new_levels`.

#### Scenario: New levels are sampled or averaged
- **WHEN** `new_data` holds a site the fit never saw
- **THEN** the prediction does not error; `"sample"` gives an interval at least as wide as `"average"`

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
