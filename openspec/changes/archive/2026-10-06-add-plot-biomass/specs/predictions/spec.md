## ADDED Requirements

### Requirement: Plot biomass

`kb_predict_plot_biomass(weight, size, density, wetdry, carbon)` SHALL combine a weight, a size, and a density fit of the same species into the expected biomass per m² of each site-year in the density fit's data, for the `measure` chosen by a name-only argument: `"wet"` (the default, kg/m²), `"dry"` (kg/m², needing a wet/dry fit as `wetdry`), or `"carbon"` (g C/m², needing `wetdry` and a carbon fit as `carbon`). It SHALL return a `kb_predictions` object with one row per such site-year and columns `site`, `year`, `weight_support`, `size_support`, `estimate`, `lower`, and `upper`, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). `weight_support` and `size_support` SHALL give the data the weight or size fit has for the site-year: `"site-year"` where the site-year is in its data, else `"site, year"` where both its site and its year are, else `"site"` or `"year"` where only one is, else `"none"`.

Per draw, biomass SHALL be the site-year's expected density per m² times its mean plant weight: the expected weight at size averaged over the site-year's size distribution, truncated above at the largest size in the size fit's data. The name-only `n_plants` (default 100) SHALL set the number of plants averaged per draw. For a *Nereocystis* weight fit with the density effect, each site-year SHALL use its observed stipe density in the density fit's data. Per draw, dry biomass SHALL be wet biomass times the expected dry:wet ratio, and carbon biomass dry biomass times the expected carbon fraction, converted to grams.

Weight and size at a site-year SHALL be resolved as in the row-wise verbs, with name-only `new_levels` (default `"sample"`) and `representative_site`. A `representative_site` SHALL be fitted in both the weight and size fits. A name-only `progress` (`"bar"`, the default, or `"none"`) SHALL control a console progress bar, and a `progress_dir` naming an existing directory SHALL receive a progress record that `kb_progress()` reads, as for the fits. The function SHALL error, naming the problem, when an argument is not a fit of the required model, a fit the `measure` needs is not supplied, the fits supplied differ in species, or they differ in their number of draws.

#### Scenario: One row per density-surveyed site-year
- **WHEN** `kb_predict_plot_biomass(weight, size, density)` is called on fits of one species
- **THEN** it returns one row for each site-year in the density fit's data, and no other

#### Scenario: Biomass is density times mean plant weight
- **WHEN** the fits' site and year effects are all observed for a site-year
- **THEN** each draw of its biomass equals that site-year's expected density per m² times the mean expected weight over its truncated size distribution, within the integration error of `n_plants`

#### Scenario: Dry and carbon are per-draw conversions of wet
- **WHEN** `measure = "dry"` or `measure = "carbon"` is requested with the fits it needs
- **THEN** each draw equals the wet biomass draw times the expected dry:wet ratio draw, and for carbon also times the expected carbon fraction draw and 1000

#### Scenario: A missing conversion fit errors
- **WHEN** `measure = "carbon"` is requested without a `carbon` fit, or `"dry"` without a `wetdry` fit
- **THEN** it errors naming the missing argument

#### Scenario: The data support of weight and size is reported
- **WHEN** a density-surveyed site-year is absent from the weight or size fit's data
- **THEN** it still returns a row, with `weight_support` or `size_support` naming the data the fit does have for it (`"site, year"`, `"site"`, `"year"`, or `"none"`)

#### Scenario: Averaging narrows an unseen site's interval
- **WHEN** a density-surveyed site is absent from the weight and size fits
- **THEN** its interval under `new_levels = "sample"` is at least as wide as under `"average"`

#### Scenario: Mismatched fits error
- **WHEN** the fits differ in species, a fit is of the wrong model, or the fits differ in their number of draws
- **THEN** it errors naming the mismatch

#### Scenario: Progress can be polled
- **WHEN** it is called with `progress_dir` and `kb_progress(progress_dir)` is called during and after it
- **THEN** it returns the completed fraction, reaching `1` when the prediction finishes

#### Scenario: Reproducible under a seed
- **WHEN** it is called twice after the same `set.seed()`
- **THEN** the results are identical

### Requirement: Predictions record their interval level

Every `kb_predictions` object SHALL record the `conf_level` its `lower` and `upper` columns were computed at.

#### Scenario: The level travels with the prediction
- **WHEN** a prediction verb is called with `conf_level = 0.9`
- **THEN** the returned object records 0.9 as its interval level

## MODIFIED Requirements

### Requirement: Groups are resolved per row

A row whose `site`, `year`, or site-year is a fitted level SHALL be conditioned on that level's estimated effect. A new level or an absent grouping column SHALL be handled by `new_levels`: `"sample"` draws a new effect from its estimated distribution, and `"average"` sets it to zero (the typical group). Rows naming the same new site, year, or site-year SHALL share one sampled effect, since they are one group; rows whose grouping column is absent SHALL each draw their own. The default SHALL be `"sample"` for the row-wise verbs (`kb_predict_weight()`, `kb_predict_size()`, `kb_predict_density()`), `kb_predict_plot_biomass()`, and the `posterior_*()` generics, and `"average"` for the `_by` verbs. A new level SHALL NOT error. `representative_site` SHALL instead give a new or absent site the estimated site effect of the named fitted site(s), averaged per draw when several are named, while site:year still follows `new_levels`; a name not in the fit SHALL error listing the fitted sites. An effect the fit omitted SHALL contribute nothing, under any `new_levels`.

#### Scenario: New levels are sampled or averaged
- **WHEN** `new_data` holds a site the fit never saw
- **THEN** the prediction does not error; `"sample"` gives an interval at least as wide as `"average"`

#### Scenario: Rows naming one new level share its effect
- **WHEN** `posterior_epred()` is called with two rows naming the same new site and a fitted year, under `new_levels = "sample"`
- **THEN** the two rows' draws are identical where their other inputs are

#### Scenario: A representative site stands in for a new site
- **WHEN** a new site is predicted with `representative_site = s` and `new_levels = "average"` and no `year` column
- **THEN** the prediction equals predicting fitted site `s` with the same other inputs

#### Scenario: An omitted site:year effect adds nothing
- **WHEN** the fit omitted the site:year effect
- **THEN** `new_levels = "sample"` adds no site:year variation
