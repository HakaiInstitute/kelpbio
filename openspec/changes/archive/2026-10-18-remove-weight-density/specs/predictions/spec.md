## MODIFIED Requirements

### Requirement: Groups are resolved per row

A row whose `site`, `year`, or site-year is a fitted level SHALL be conditioned on that level's estimated effect. A new level or an absent grouping column SHALL be handled by `new_levels`: `"average"` sets it to zero (the typical group), and `"sample"` draws a new effect from its estimated distribution. Rows naming the same new site, year, or site-year SHALL share one sampled effect, since they are one group; rows whose grouping column is absent SHALL each draw their own. The default SHALL be `"average"` for every prediction verb, `predict()`, and the `posterior_*()` generics, and `"sample"` for `kb_predict_plot_biomass()` and `kb_predict_site_biomass()`, whose rows are particular surveyed site-years. A new level SHALL NOT error. A missing value in a `site` or `year` column of `new_data` SHALL error, naming the column; a new level is requested by naming it or by leaving out the column. `new_data` with no rows, or with an infinite value in a column the prediction reads, SHALL error. `representative_site` SHALL instead give a new or absent site the estimated site effect of the named fitted site(s), averaged per draw when several are named, and, in a fitted year, their estimated site:year effect for that year, averaged per draw over the named sites observed in that year; a site:year effect none of them has SHALL follow `new_levels`; a name not in the fit SHALL error listing the fitted sites. An effect the fit omitted SHALL contribute nothing, under any `new_levels`.

#### Scenario: New levels are sampled or averaged
- **WHEN** `new_data` holds a site the fit never saw
- **THEN** the prediction does not error; `"sample"` gives an interval at least as wide as `"average"`

#### Scenario: A missing site or year errors
- **WHEN** `new_data` has a `site` or `year` column with a missing value
- **THEN** the prediction errors naming the column and pointing to a named new level or an absent column

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
- **WHEN** a new site is predicted in year `y` with `representative_site = s`, where site `s` was observed in `y`
- **THEN** the prediction equals predicting site `s` in year `y`, under either `new_levels`

### Requirement: Draws, likelihood, and priors

`posterior_epred()`, `posterior_linpred()`, and `posterior_predict()` SHALL return a draws-by-rows matrix for `new_data` (or the observed data), resolving groups as above. For a density fit, each row SHALL be a transect of its `area_m2`, or of 1 m² when `new_data` has no `area_m2` column, and the observed data SHALL use their recorded areas. `posterior_epred()` SHALL give the expected response. Where that differs from the inverse link of the linear predictor, `posterior_linpred(transform = TRUE)` SHALL return the inverse link:

- *Nereocystis* weight, whose log weight is Normal: the expected weight is `exp(mu + sd_residual^2 / 2)`, above the median `exp(mu)`.
- *Macrocystis* size, whose frond count is a zero-truncated negative binomial: the expected count is the truncated mean, above the untruncated mean `exp(mu)`.
- *Nereocystis* density, whose stipe count is a zero-inflated negative binomial: the expected count is `(1 - zi) * exp(mu)`, below the mean of an occupied transect, `exp(mu)`, where `zi` is the probability that a transect is unoccupied (a structural zero).

For cover biomass, whose residual is the in situ estimation error rather than variation in biomass, the expected biomass is the inverse link, `exp(mu)`.

The prediction verbs, `fitted()`, and `augment()` SHALL summarise `posterior_epred()`; the density verb at 1 m². `posterior_predict()` SHALL add observation noise from the model's likelihood, so repeated calls differ unless a seed is set; for size it draws plant sizes, and *Macrocystis* draws are whole numbers of at least 1; for density it draws transect counts, whole numbers of at least 0; for wet/dry and carbon it draws ratios or fractions between 0 and 1; for cover biomass it draws positive in situ biomass estimates, with each row's precision taken from its `lower` and `upper`, which `new_data` SHALL then carry. `log_lik()` SHALL return the deterministic pointwise log-likelihood of the observed data, suitable for `loo::loo()`, and error for a fit with no observations. Each value SHALL be the log density of the recorded response on its recorded scale (weight in kg, diameter in mm, a count, a ratio or fraction, or an in situ biomass estimate), including the Jacobian where the model's likelihood is stated on a transformed scale, so the pointwise log-likelihoods of two models of the same response are comparable. `log_lik()`, `residuals()`, and `posterior_predict()` SHALL use the same observation distribution, and it SHALL be the distribution of the fitted Stan model. `prior_summary()` SHALL return the priors used.

#### Scenario: Expected weight exceeds the median for Nereocystis
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Nereocystis* weight rows
- **THEN** each draw of the former equals the latter times `exp(sd_residual^2 / 2)`

#### Scenario: Expected frond count exceeds the untruncated mean
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Macrocystis* size rows
- **THEN** each draw of the former is greater than the latter and at least 1

#### Scenario: Expected stipe count includes zero inflation
- **WHEN** `posterior_epred()` and `posterior_linpred(transform = TRUE)` are called on the same *Nereocystis* density rows
- **THEN** each draw of the former equals the latter times one minus that draw's zero-inflation probability

#### Scenario: Expected counts scale with area
- **WHEN** `posterior_epred()` is called on a density fit at the same site and year with `area_m2` of 10 and of 20
- **THEN** each draw of the second is twice the first

#### Scenario: Density draws default to one square metre
- **WHEN** `posterior_epred()` is called on a density fit with `new_data` lacking `area_m2`
- **THEN** it equals the same call with `area_m2 = 1`, and its summary equals `kb_predict_density()` at those rows

#### Scenario: Cover predictive draws need the in situ limits
- **WHEN** `posterior_predict()` is called on a cover biomass fit with `new_data` lacking `lower` or `upper`
- **THEN** it errors naming the missing columns

#### Scenario: Predictive draws are reproducible under a seed
- **WHEN** `posterior_predict()` is called twice after the same `set.seed()`
- **THEN** it returns identical draws

#### Scenario: Log-likelihood is on the recorded scale
- **WHEN** `log_lik()` is called on a *Nereocystis* weight fit
- **THEN** each value equals the log density of the Normal on log weight minus the log of that row's `weight_kg`

#### Scenario: Log-likelihood agrees with the Stan model
- **WHEN** `log_lik()` is summed over the observed rows for each draw of any fit
- **THEN** it differs from the Stan model's log density with the likelihood, minus the same log density without it, by an amount that is the same for every draw

### Requirement: Values far outside the fitted range are flagged

Prediction SHALL warn when supplied values of the species predictor lie below half the fitted minimum or above twice the fitted maximum, naming the column, the fitted range, and the column's expected unit where it has one. This applies to any `new_data`, including a grid from `kb_new_data()` with supplied predictor values. The warning SHALL NOT stop the prediction. The message is pinned by `tests/testthat/_snaps/warn.md`.

#### Scenario: Diameter in centimetres at prediction is flagged
- **WHEN** `new_data` gives `diameter_mm` in centimetres to a fit made in millimetres
- **THEN** a warning names `diameter_mm` and the fitted range, and predictions are still returned

#### Scenario: Values within the fitted range raise no warning
- **WHEN** supplied values lie within twice the fitted range
- **THEN** no warning is issued

### Requirement: Plot biomass

`kb_predict_plot_biomass(weight, size, density, wetdry, carbon)` SHALL combine a weight, a size, and a density fit of the same species into the expected biomass per m² of each site-year in the density fit's data, for the `measure` chosen by a name-only argument: `"wet"` (the default, kg/m²), `"dry"` (kg/m², needing a wet/dry fit as `wetdry`), or `"carbon"` (g C/m², needing `wetdry` and a carbon fit as `carbon`). It SHALL return a `kb_predictions` object with one row per such site-year and columns `site`, `year`, `weight_support`, `size_support`, `estimate`, `lower`, and `upper`, using `conf_level` (default 0.95), `estimate` (default `median`), and `sig_fig` (default 3). `weight_support` and `size_support` SHALL give the data the weight or size fit has for the site-year: `"site-year"` where the site-year is in its data, else `"site, year"` where both its site and its year are, else `"site"` or `"year"` where only one is, else `"none"`.

Per draw, biomass SHALL be the site-year's expected density per m² times its mean plant weight: the expected weight at size averaged over the site-year's size distribution, truncated above at the largest size in the size fit's data. The name-only `n_plants` (default 100) SHALL set the number of plants averaged per draw. Per draw, dry biomass SHALL be wet biomass times the expected dry:wet ratio, and carbon biomass dry biomass times the expected carbon fraction, converted to grams.

Weight and size at a site-year SHALL be resolved as in the prediction verbs, with name-only `new_levels` (default `"sample"`) and `representative_site`. A `representative_site` SHALL be fitted in both the weight and size fits. A name-only `progress` (`"bar"`, the default, or `"none"`) SHALL control a console progress bar, and a `progress_dir` naming an existing directory SHALL receive a progress record that `kb_progress()` reads, as for the fits. The function SHALL error, naming the problem, when an argument is not a fit of the required model, a fit the `measure` needs is not supplied, the fits supplied differ in species, they differ in their number of draws, or the density or size fit has no observed data.

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

## REMOVED Requirements

### Requirement: Density is resolved per row

**Reason**: The *Nereocystis* weight model no longer has a density effect, so there is no density to resolve.

**Migration**: None needed. A `stipes_m2` column in `new_data` is ignored.
