## MODIFIED Requirements

### Requirement: The data determine which effects are fitted

The site:year effect SHALL be included for every model with a site:year effect (weight and size; wet/dry, carbon, and nitrogen have no random effects, and the cover calibration has site and year effects but never a site:year effect), whatever years and sites the data cover. When no site was sampled in more than one year, which includes data from a single year, or no year had more than one site sampled, it SHALL be retained with a warning naming the main effect (site, year, or both) from which the site:year effect cannot be separated.

The cover calibration SHALL include a presence part, for either species, when a survey it fits has a biomass of zero (no plants counted), and SHALL omit it otherwise. With the presence part, the probability that a survey holds plants SHALL be logit-linear in the plot's percent tide-corrected cover, and a survey's biomass SHALL follow the Gamma only where plants are present. The fit SHALL warn when every survey with no plants has a percent cover, before tide correction, at or below that of every survey with plants (ties included), saying that the presence slope then follows its prior and suggesting a tighter one; the warning SHALL NOT stop the fit. Data in which no survey with drone cover has plants SHALL error. A `prior_only` fit SHALL neither warn nor error on these grounds. The message is pinned by `tests/testthat/_snaps/warn.md`.

An omitted effect SHALL not be reported or used in prediction (see summaries and predictions).

#### Scenario: Single-year data fit site:year with a warning
- **WHEN** the data contain one year and more than one site
- **THEN** the fit has a site:year effect and a warning names the site effect

#### Scenario: One site in one year warns of both effects
- **WHEN** the data contain one site and one year
- **THEN** the fit has a site:year effect and a warning names the site and year effects

#### Scenario: Aliased design warns
- **WHEN** the data span several years but no site spans more than one
- **THEN** the site:year effect is retained and a warning names the site effect

#### Scenario: One site over several years warns
- **WHEN** the data span several years but every year has a single site
- **THEN** the site:year effect is retained and a warning names the year effect

#### Scenario: The cover calibration never fits site:year
- **WHEN** a cover calibration model is fitted to data spanning several years, including several plots in one site-year
- **THEN** the fit has site and year effects, no site:year effect, and no site:year message or warning

#### Scenario: An empty survey adds the presence part
- **WHEN** a cover calibration model of either species is fitted to data holding a survey with no plants
- **THEN** the fit has the presence parameters, and without such a survey it has none

#### Scenario: Separated empty surveys warn
- **WHEN** every survey with no plants has a percent canopy cover at or below every survey with plants
- **THEN** the fit warns that the presence slope follows its prior

### Requirement: Priors

`kb_priors_weight_nereo()`, `kb_priors_weight_macro()`, `kb_priors_size_nereo()`, `kb_priors_wetdry_nereo()`, `kb_priors_wetdry_macro()`, `kb_priors_carbon_nereo()`, `kb_priors_carbon_macro()`, `kb_priors_nitrogen_nereo()`, `kb_priors_nitrogen_macro()`, `kb_priors_cover_calibration_nereo()`, and `kb_priors_cover_calibration_macro()` SHALL return a named list of prior objects, the defaults pinned by `tests/testthat/test-kb_priors_*.R`. Each entry SHALL be named after the parameter it sets, the same name that parameter has in `tidy()`, `coef()`, `summary()`, and `kb_model_describe()`. The entries are:

- *Nereocystis* weight: `intercept`, `diameter_power`, `weight_floor`, `sd_site`, `sd_year`, `sd_site_year`, and `sd_residual`.
- *Macrocystis* weight: `intercept`, `fronds_slope`, `shape`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Nereocystis* size: `intercept`, `shape`, `sd_site`, `sd_year`, and `sd_site_year`.
- Wet/dry, carbon, and nitrogen, both species: `intercept` and `precision`.
- Cover calibration, both species: `cover_slope` (lognormal), `biomass_floor`, `tide_height_slope`, `cv_residual`, `presence_intercept`, `presence_cover_slope`, `sd_site`, and `sd_year`; the presence entries apply only when the fit has a presence part.

A list passed to `priors` SHALL override only the entries it contains. `kb_prior_normal()`, `kb_prior_exponential()`, and `kb_prior_lognormal()` SHALL validate their hyperparameters and print as the family with its hyperparameters.

#### Scenario: A partial prior list keeps the other defaults
- **WHEN** a user changes one entry (e.g. `p$sd_site <- kb_prior_exponential(2)`) and fits with `priors = p`
- **THEN** that entry is used and the others keep their defaults

#### Scenario: A summary term names its prior entry
- **WHEN** `tidy(fit)` reports a parameter
- **THEN** its `term` is the name of the entry in the model's `kb_priors_*()` list that sets its prior

#### Scenario: Invalid hyperparameters error
- **WHEN** `kb_prior_normal(0, sd = -1)`, `kb_prior_exponential(rate = 0)`, or `kb_prior_lognormal(0, sdlog = 0)` is called
- **THEN** it errors

### Requirement: Bundled example objects

The package SHALL ship simulated datasets `data_weight_sim_nereo`, `data_weight_sim_macro`, `data_size_sample_sim_nereo`, `data_wetdry_sim_nereo`, `data_wetdry_sim_macro`, `data_carbon_sim_nereo`, `data_carbon_sim_macro`, `data_nitrogen_sim_nereo`, `data_nitrogen_sim_macro`, `data_in_situ_sim_nereo`, `data_in_situ_sim_macro`, `data_size_census_sim_macro`, `data_canopy_sim_nereo`, and `data_canopy_sim_macro`, and small pre-fits `fit_weight_sim_nereo`, `fit_weight_sim_macro`, `fit_size_sim_nereo`, `fit_wetdry_sim_nereo`, `fit_wetdry_sim_macro`, `fit_carbon_sim_nereo`, `fit_carbon_sim_macro`, `fit_nitrogen_sim_nereo`, `fit_nitrogen_sim_macro`, `fit_cover_calibration_sim_nereo`, and `fit_cover_calibration_sim_macro`, for examples and tests, not inference. The bundled datasets and the data stored in the pre-fits SHALL use the input column names above. Real survey data and inference-grade fits SHALL NOT be bundled; they belong in the companion package `kelpbiodata`.

For each species, the weight, size, survey, and canopy datasets SHALL be simulated from one set of true site-year values, with parameter values near those estimated from the Hakai Institute surveys, so that survey biomass from the bundled fits is of realistic magnitude and agrees with the bundled cover calibration. *Nereocystis* surveys SHALL carry tallied `plants`, with sizes from `data_size_sample_sim_nereo`; *Macrocystis* surveys SHALL have their plants in `data_size_census_sim_macro`. The sites SHALL have invented names that match no real survey site. The data sources SHALL cover different site-years, as in field programmes: surveys at most site-years, size at most of those, weight at a subset that includes sites never harvested, and drone cover on a subset of surveys, with at least one site-year holding more than one survey and at least one survey with no plants. A *Nereocystis* survey with no plants SHALL have drone cover above that of the lowest-cover survey with plants, so the bundled calibration estimates its presence part from the data.

#### Scenario: Bundled objects work with the package
- **WHEN** a bundled dataset is checked and a bundled fit is summarised or predicted from
- **THEN** the dataset passes its data check and the fit works with every method

#### Scenario: Survey biomass and the calibration agree
- **WHEN** `kb_predict_biomass_in_situ()` is called with a species' bundled fits and survey data
- **THEN** at the surveys with drone cover, the median ratio of `kb_predict_cover_calibration()` from the bundled calibration fit to the survey biomass estimates lies between 0.5 and 2

#### Scenario: Data sources have gaps
- **WHEN** the site-years of a species' bundled weight, size, and survey datasets are compared
- **THEN** weight covers fewer site-years than the surveys, at least one surveyed site has no weight data, *Nereocystis* size misses at least one surveyed site-year, only some surveys have drone cover, and at least one survey has no plants
