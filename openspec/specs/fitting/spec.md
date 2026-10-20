# fitting

## Purpose

Fitting a model: the input data and its checks, the priors, how the data determine
which effects are fitted, sampler control and progress, and what a fit object
holds. The exact model each fit function estimates (likelihood, mean, effects,
priors) is the one `kb_model_describe()` reports, pinned by
`tests/testthat/_snaps/kb_model_describe.md`.
## Requirements
### Requirement: Fit a model

`kb_fit_weight_nereo()`, `kb_fit_weight_macro()`, `kb_fit_size_nereo()`, `kb_fit_wetdry_nereo()`, `kb_fit_wetdry_macro()`, `kb_fit_carbon_nereo()`, `kb_fit_carbon_macro()`, `kb_fit_cover_calibration_nereo()`, and `kb_fit_cover_calibration_macro()` SHALL fit the species' weight, size, wet/dry, carbon, or cover calibration model and return a `kb_fit` object. Arguments SHALL be validated before sampling. Fitting SHALL need no Stan toolchain on the user's machine, and changing a prior's hyperparameters SHALL need no recompilation; a prior's family is fixed by the model.

#### Scenario: Returns a fit
- **WHEN** a fit function is called on valid data
- **THEN** it returns an object inheriting from `kb_fit`, the model class (`kb_fit_weight`, `kb_fit_size`, `kb_fit_wetdry`, `kb_fit_carbon`, or `kb_fit_cover_calibration`), and the species class (e.g. `kb_fit_cover_calibration_nereo`)

#### Scenario: Invalid arguments error before sampling
- **WHEN** a fit function is called with invalid data, an invalid sampler argument, or a prior of the wrong family
- **THEN** it errors with a `cli` message before any sampling, a family mismatch saying that a different family needs a different model

### Requirement: Input data

The required columns SHALL be, with `site` (and `year` where required) character or factor and no missing or infinite values in any required column. A column measured in a unit SHALL name the unit as a suffix (`_mm`, `_kg`, `_m2`); counts and grouping columns carry no suffix. "Plant" SHALL mean, for both species, one individual (sporophyte) identified by its holdfast. Weight, size, survey, and plant data are dated: `date` SHALL be of class `Date`, the year SHALL be the year of `date`, and a `year` column, if present, SHALL agree with it; the fits work at site-year resolution.

- *Nereocystis* weight: `diameter_mm` (sub-bulb diameter, mm, > 0), `weight_kg` (kg, > 0), `site`, and `date`.
- *Macrocystis* weight: `fronds` (fronds at 1 m above the holdfast, a positive whole number), `weight_kg` (kg, > 0), `site`, and `date`.
- *Nereocystis* size: `diameter_mm` (maximum sub-bulb diameter, mm, > 0), `site`, and `date`, and optionally `plot_id` (character or factor, not used by the model).
- Wet/dry, both species: `wet_mass_g` (wet mass of a sample, g, > 0) and `dry_mass_g` (its dry mass, g, > 0 and less than `wet_mass_g`). A warning SHALL give the number of samples whose dry:wet ratio lies outside 0.02 to 0.5, the plausible range for kelp tissue, and those samples SHALL be kept.
- Carbon, both species: `sample_mass_mg` (mass of a dried sample, mg, > 0) and `carbon_mass_ug` (carbon measured in it, µg, > 0), the carbon fraction `carbon_mass_ug / 1000 / sample_mass_mg` being less than 1. A warning SHALL give the number of samples whose carbon fraction lies outside 0.10 to 0.50, the plausible range for kelp tissue, and those samples SHALL be kept.
- In situ surveys, both species: one row per survey of a plot, with `site`, `plot_id` (character or factor, identifying the plot within its site), `date` (class `Date`), and `survey_area_m2` (the surveyed area, m², > 0). `year` SHALL be the year of `date`; a `year` column, if present, SHALL agree with it. `plants` (plants counted, a number `>= 0`) SHALL be present when sizes come from a size fit and absent when they come from a plant table. `plot_area_m2` (the plot polygon, m², > 0), `canopy_area_m2` (drone canopy delineated in the plot, m², `>= 0` and at most `plot_area_m2`), and `tide_height_m` (tide height at the flight, m, chart datum) MAY be present; on each row all three SHALL be given or all three missing. Each `site`, `plot_id`, and `date` SHALL appear once.
- Counted plants (a census): one row per counted plant, with `site`, `plot_id`, and `date` matching a survey row, the size (`diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*, a positive whole number), and optionally `partial` (logical, no missing values; `TRUE` counts the plant as half).
- Cover calibration, both species: `data` is the output of `kb_predict_biomass_survey()` at its default `pool_by`, wet biomass per m², each survey with drone cover entering as one observation. It SHALL carry `site`, `year`, `plot_area_m2`, `canopy_area_m2`, `tide_height_m`, and the `biomass_kg_m2` column of draws. Rows without drone cover SHALL be left out with a message giving their number (suppressed by `progress = "none"`), and the fit SHALL error when no row has drone cover. Data lacking `biomass_kg_m2` (dry or carbon biomass, or total biomass) or a column of draws in it, or lacking the survey columns (summed output), SHALL error naming the missing columns and pointing to `kb_predict_biomass_survey()` with its defaults.

Other columns SHALL be ignored. `kb_check_data_weight_nereo()`, `kb_check_data_weight_macro()`, `kb_check_data_size_nereo()`, `kb_check_data_wetdry_nereo()`, `kb_check_data_wetdry_macro()`, `kb_check_data_carbon_nereo()`, `kb_check_data_carbon_macro()`, `kb_check_data_cover_calibration_nereo()`, and `kb_check_data_cover_calibration_macro()` SHALL apply these checks, returning the data invisibly, and the fit functions SHALL apply them at entry. `kb_check_data_survey(data, plants = NULL)` SHALL check a survey table, and with `plants` also the plant table, the join, and the absence of a `plants` column; `kb_check_data_plants_nereo()` and `kb_check_data_plants_macro()` SHALL check a plant table alone.

#### Scenario: Valid data passes
- **WHEN** a data check is called on data meeting the requirements
- **THEN** it returns the data invisibly with no message

#### Scenario: A bad column errors naming it
- **WHEN** a required column is missing, of the wrong type, out of range, or contains `NA`
- **THEN** it errors with a message naming the column

#### Scenario: An unsuffixed column name is missing
- **WHEN** *Nereocystis* weight data have `diameter` and `weight` but not `diameter_mm` and `weight_kg`
- **THEN** it errors naming the missing `diameter_mm` column

#### Scenario: A zero frond count errors for counted plants
- **WHEN** *Macrocystis* plant data contain a plant with `fronds` of `0`
- **THEN** it errors naming `fronds`, since the model describes plants with at least one frond at 1 m

#### Scenario: Weight data take a date
- **WHEN** *Nereocystis* weight data have `site` and `date` and no `year`
- **THEN** they pass, and the fit's site-years are the sites and the years of the dates

#### Scenario: A date given as text errors
- **WHEN** survey data have `date` as character strings
- **THEN** it errors naming `date` and pointing to `as.Date()`

#### Scenario: A year contradicting the date errors
- **WHEN** survey data have a `year` that differs from the year of `date` on some row
- **THEN** it errors naming `year`

#### Scenario: Zero plants are valid for a tallied survey
- **WHEN** survey data contain a survey with `plants` of `0`
- **THEN** the data pass

#### Scenario: A tally with a plant table errors
- **WHEN** `kb_check_data_survey(data, plants)` is called with a `data` holding a `plants` column
- **THEN** it errors stating that counts come from the plant rows

#### Scenario: A plant with no survey errors
- **WHEN** a plant row's `site`, `plot_id`, and `date` match no survey row
- **THEN** it errors naming the unmatched keys

#### Scenario: Partial drone columns error
- **WHEN** a survey row has `canopy_area_m2` but a missing `tide_height_m` or `plot_area_m2`
- **THEN** it errors naming the missing column

#### Scenario: Canopy larger than its plot errors
- **WHEN** a survey row's `canopy_area_m2` exceeds its `plot_area_m2`
- **THEN** it errors naming `canopy_area_m2`

#### Scenario: A surveyed area above the plot area warns
- **WHEN** a survey row's `survey_area_m2` exceeds its `plot_area_m2`
- **THEN** a warning names both columns, and the data still pass

#### Scenario: A repeated survey errors
- **WHEN** survey data have two rows with the same `site`, `plot_id`, and `date`
- **THEN** it errors naming the repeated keys

#### Scenario: A dry mass not below the wet mass errors
- **WHEN** wet/dry data contain a sample whose `dry_mass_g` is greater than or equal to its `wet_mass_g`
- **THEN** it errors naming `dry_mass_g`

#### Scenario: An implausible dry:wet ratio warns
- **WHEN** a sample's dry:wet ratio lies outside 0.02 to 0.5
- **THEN** a warning gives the number of such samples, and the data still pass with every sample kept

#### Scenario: Carbon above the sample mass errors
- **WHEN** carbon data have a `carbon_mass_ug` above `sample_mass_mg` once converted to milligrams, as a sample mass in grams produces
- **THEN** it errors naming `carbon_mass_ug` and the expected units

#### Scenario: An implausible carbon fraction warns
- **WHEN** a sample's carbon fraction lies outside 0.10 to 0.50
- **THEN** a warning gives the number of such samples, and the data still pass with every sample kept

#### Scenario: Survey biomass passes straight into the calibration
- **WHEN** `kb_fit_cover_calibration_nereo()` is given `kb_predict_biomass_survey()` output with its defaults
- **THEN** it fits the rows with drone cover, and the fit stores each survey's biomass as the mean (`biomass_kg_m2`) and SD (`biomass_sd_kg_m2`) of its draws, not the draws

#### Scenario: Rows without drone cover are left out
- **WHEN** some rows of the calibration data have missing drone columns
- **THEN** those rows are not fitted, and a message gives their number

#### Scenario: Dry or summed biomass errors
- **WHEN** the calibration data are `kb_predict_biomass_survey()` output with `measure = "dry"`, `per_area = FALSE`, or a `pool_by`
- **THEN** it errors naming the missing columns (`biomass_kg_m2`, or the survey's drone columns) and pointing to the defaults

#### Scenario: Zero canopy is valid for the calibration
- **WHEN** the calibration data contain a survey with `canopy_area_m2` of `0`
- **THEN** the data pass

### Requirement: The data determine which effects are fitted

The site:year effect SHALL be included for every model with a site:year effect (weight and size; wet/dry and carbon have no random effects, and the cover calibration has site and year effects but never a site:year effect), whatever years and sites the data cover. When no site was sampled in more than one year, which includes data from a single year, or no year had more than one site sampled, it SHALL be retained with a warning naming the main effect (site, year, or both) from which the site:year effect cannot be separated.

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

### Requirement: Priors

`kb_priors_weight_nereo()`, `kb_priors_weight_macro()`, `kb_priors_size_nereo()`, `kb_priors_wetdry_nereo()`, `kb_priors_wetdry_macro()`, `kb_priors_carbon_nereo()`, `kb_priors_carbon_macro()`, `kb_priors_cover_calibration_nereo()`, and `kb_priors_cover_calibration_macro()` SHALL return a named list of prior objects, the defaults pinned by `tests/testthat/test-kb_priors_*.R`. Each entry SHALL be named after the parameter it sets, the same name that parameter has in `tidy()`, `coef()`, `summary()`, and `kb_model_describe()`. The entries are:

- *Nereocystis* weight: `intercept`, `diameter_power`, `weight_floor`, `sd_site`, `sd_year`, `sd_site_year`, and `sd_residual`.
- *Macrocystis* weight: `intercept`, `fronds_slope`, `shape`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Nereocystis* size: `intercept`, `shape`, `sd_site`, `sd_year`, and `sd_site_year`.
- Wet/dry and carbon, both species: `intercept` and `precision`.
- Cover calibration, both species: `cover_slope` (lognormal), `biomass_floor`, `tide_height_slope`, `sd_residual`, `cv_residual`, `sd_site`, and `sd_year`.

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

### Requirement: Sampler control and progress

The fit functions SHALL take `chains` (default 4), `niters` (saved post-warmup draws per chain, default 1000; warmup matches), `nthin` (default 1), `cores`, `seed`, `progress`, and `progress_dir`, passing other named arguments to `rstan::sampling()`; an unnamed argument SHALL error. The sampler SHALL use `adapt_delta = 0.95` unless a `control` list overrides it; a supplied `control` is merged over the default. `cores = NULL` SHALL use `getOption("mc.cores")`, falling back to `chains`, capped at the available cores. A fit SHALL be reproducible from `seed`, or from a preceding `set.seed()` when `seed` is `NULL`. No HTML viewer SHALL open.

`progress` SHALL be one of `"bar"` (default, a progress bar with rstan's output suppressed), `"verbose"` (rstan's per-iteration output and warnings), or `"none"` (silent). It SHALL change only console output, never the draws. When `progress_dir` names an existing directory, the fit SHALL write a progress record there under any `progress` mode, and `kb_progress(progress_dir)` SHALL return the completed fraction in `[0, 1]` from another R process: `0` before sampling starts, `1` once complete, and no error mid-write. kelpbio SHALL NOT delete a caller's `progress_dir`.

#### Scenario: niters counts saved draws
- **WHEN** a fit uses `niters = 1000` and `nthin = 2`
- **THEN** `niterations(fit)` is `1000`

#### Scenario: control is merged over the default
- **WHEN** a fit is called with `control = list(max_treedepth = 12)`
- **THEN** it samples with `max_treedepth = 12` and `adapt_delta = 0.95`

#### Scenario: progress changes only output
- **WHEN** the same model is fitted with the same `seed` and different `progress` values
- **THEN** the draws are identical

#### Scenario: Progress can be polled from another process
- **WHEN** a fit writes to `progress_dir` and `kb_progress(progress_dir)` is called during and after it
- **THEN** it returns the completed fraction, reaching `1` when the fit finishes

### Requirement: The fit object

A fit SHALL store posterior draws, sampler diagnostics, the input data, and the fit's settings, and SHALL NOT keep the `stanfit` or any per-observation quantity, so its size depends on the number of draws, not observations. Every summary, diagnostic, and prediction SHALL work from a stored fit. A fit with `prior_only = TRUE` SHALL sample from the priors alone and accept zero-row data; with `prior_only = FALSE`, zero-row data SHALL error before sampling. A diagnostic rate with no draws behind it SHALL be `NA`, not zero.

The draws SHALL be a `posterior` `draws_rvars` object that works with `posterior` and the tools built on it as soon as kelpbio is attached, including for a bundled pre-fit or a fit read back in a new session. Per-level group effects SHALL be labelled by their levels: site effects by site, year effects by year, and site:year effects by site and year, so they can be indexed by name as well as by position.

#### Scenario: A stored fit is self-contained
- **WHEN** a fit is saved, reloaded in a new session, and summarised or predicted from
- **THEN** every method works without refitting

#### Scenario: Prior-only fits ignore the data
- **WHEN** `prior_only = TRUE`, including with zero-row data
- **THEN** the draws reflect the priors only

#### Scenario: Zero-row data need prior_only
- **WHEN** a fit function is called with zero-row data and `prior_only = FALSE`
- **THEN** it errors before sampling, pointing to `prior_only = TRUE`

#### Scenario: Draws work on load
- **WHEN** kelpbio is attached in a new session and a bundled pre-fit's draws are printed before any other kelpbio function is called
- **THEN** each parameter prints its draws summary, and has the length of its number of levels

#### Scenario: Group effects are labelled by level
- **WHEN** the site effects of a fit are indexed by a site name, or its draws are converted with `posterior::as_draws_df()`
- **THEN** the effect for that site is returned, and the variables are named `site_effect[<site>]` and `site_year_effect[<site>,<year>]`

### Requirement: Bundled example objects

The package SHALL ship simulated datasets `data_weight_sim_nereo`, `data_weight_sim_macro`, `data_size_sim_nereo`, `data_wetdry_sim_nereo`, `data_wetdry_sim_macro`, `data_carbon_sim_nereo`, `data_carbon_sim_macro`, `data_survey_sim_nereo`, `data_survey_sim_macro`, `data_plants_sim_macro`, `data_canopy_sim_nereo`, and `data_canopy_sim_macro`, and small pre-fits `fit_weight_sim_nereo`, `fit_weight_sim_macro`, `fit_size_sim_nereo`, `fit_wetdry_sim_nereo`, `fit_wetdry_sim_macro`, `fit_carbon_sim_nereo`, `fit_carbon_sim_macro`, `fit_cover_calibration_sim_nereo`, and `fit_cover_calibration_sim_macro`, for examples and tests, not inference. The bundled datasets and the data stored in the pre-fits SHALL use the input column names above. Real survey data and inference-grade fits SHALL NOT be bundled; they belong in the companion package `kelpbiodata`.

For each species, the weight, size, survey, plant, and canopy datasets SHALL be simulated from one set of true site-year values, with parameter values near those estimated from the Hakai Institute surveys, so that survey biomass from the bundled fits is of realistic magnitude and agrees with the bundled cover calibration. *Nereocystis* surveys SHALL carry tallied `plants`; *Macrocystis* surveys SHALL have their plants in `data_plants_sim_macro`. The sites SHALL have invented names that match no real survey site. The data sources SHALL cover different site-years, as in field programmes: surveys at most site-years, size at most of those, weight at a subset that includes sites never harvested, and drone cover on a subset of surveys, with at least one site-year holding more than one plot and at least one survey with no plants.

#### Scenario: Bundled objects work with the package
- **WHEN** a bundled dataset is checked and a bundled fit is summarised or predicted from
- **THEN** the dataset passes its data check and the fit works with every method

#### Scenario: Survey biomass and the calibration agree
- **WHEN** `kb_predict_biomass_survey()` is called with a species' bundled fits and survey data
- **THEN** at the surveys with drone cover, the median ratio of `kb_predict_cover_calibration()` from the bundled calibration fit to the survey biomass estimates lies between 0.5 and 2

#### Scenario: Data sources have gaps
- **WHEN** the site-years of a species' bundled weight, size, and survey datasets are compared
- **THEN** weight covers fewer site-years than the surveys, at least one surveyed site has no weight data, *Nereocystis* size misses at least one surveyed site-year, only some surveys have drone cover, and at least one survey has no plants

### Requirement: Implausible units are flagged

The data checks, and so the fit functions, and `kb_predict_biomass_canopy()` on its `new_data`, SHALL warn when a column's median is implausible for the unit its name states: `diameter_mm` below 10 or above 200 (millimetres), `weight_kg` above 100 (kilograms), `survey_area_m2` below 1 or above 5000 (square metres), `plot_area_m2` below 1 or above 1,000,000 (square metres), `site_area_m2` below 10 or above 1,000,000,000 (square metres), `tide_height_m` below -1 or above 5 (metres), or `wet_mass_g` or `dry_mass_g` above 1000 (grams). The warning SHALL name the column, its median, and the expected unit, and SHALL NOT stop the check or the fit. The message is pinned by `tests/testthat/_snaps/warn.md`.

#### Scenario: Diameter in centimetres is flagged
- **WHEN** *Nereocystis* data have `diameter_mm` in centimetres (median about 3)
- **THEN** a warning names `diameter_mm`, its median, and millimetres, and the data still pass

#### Scenario: Weight in grams is flagged
- **WHEN** either species' data have `weight_kg` in grams
- **THEN** a warning names `weight_kg`, its median, and kilograms

#### Scenario: Area in square centimetres is flagged
- **WHEN** survey data have `survey_area_m2` in square centimetres (median about 400,000)
- **THEN** a warning names `survey_area_m2`, its median, and square metres, and the data still pass

#### Scenario: Tide height in centimetres is flagged
- **WHEN** survey data have `tide_height_m` in centimetres (median about 60)
- **THEN** a warning names `tide_height_m`, its median, and metres, and the data still pass

#### Scenario: Sample masses in milligrams are flagged
- **WHEN** wet/dry data have `wet_mass_g` in milligrams (median about 4000)
- **THEN** a warning names `wet_mass_g`, its median, and grams, and the data still pass

#### Scenario: Plausible data raise no warning
- **WHEN** the columns are in the expected units
- **THEN** no unit warning is issued

### Requirement: Weight functional form

`kb_fit_weight_nereo()` SHALL take `form`, a string naming the mean function of weight in diameter: `"packard_floor"` (the default), a three-parameter power function with a size-independent weight floor, or `"power"`, a power law with no floor. Both forms SHALL share the likelihood, random effects, and prior list. An invalid `form` SHALL error before sampling, listing the available forms. The fit SHALL record its form, and every prediction, likelihood, and residual SHALL use it.

#### Scenario: The default is the Packard form
- **WHEN** `kb_fit_weight_nereo(data)` is called
- **THEN** the fit uses the three-parameter power function and estimates the weight floor

#### Scenario: A power-law fit has no floor
- **WHEN** `kb_fit_weight_nereo(data, form = "power")` is called
- **THEN** the weight floor is not estimated, and expected weight is proportional to a power of diameter

#### Scenario: An unknown form errors
- **WHEN** `kb_fit_weight_nereo(data, form = "cubic")` is called
- **THEN** it errors before sampling, naming `"packard_floor"` and `"power"`

### Requirement: Ambiguous group names are flagged

The data checks, and so the fit functions, SHALL warn when a `site` or `year` value contains `,`, `[`, or `]`, since flattened parameter names such as `site_year_effect[<site>,<year>]` then cannot be parsed back into their levels. The warning SHALL name the column and the offending values, and SHALL NOT stop the check or the fit.

#### Scenario: A site name with a comma warns
- **WHEN** data have a site named `"North Reef, inner"`
- **THEN** a warning names `site` and that value, and the data still pass

#### Scenario: Plain names raise no warning
- **WHEN** the site and year values contain none of `,`, `[`, or `]`, including names with spaces
- **THEN** no group-name warning is issued
