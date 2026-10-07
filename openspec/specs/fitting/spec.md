# fitting

## Purpose

Fitting a model: the input data and its checks, the priors, how the data determine
which effects are fitted, sampler control and progress, and what a fit object
holds. The exact model each fit function estimates (likelihood, mean, effects,
priors) is the one `kb_model_describe()` reports, pinned by
`tests/testthat/_snaps/kb_model_describe.md`.
## Requirements
### Requirement: Fit a model

`kb_fit_weight_nereo()`, `kb_fit_weight_macro()`, `kb_fit_size_nereo()`, `kb_fit_size_macro()`, `kb_fit_density_nereo()`, `kb_fit_density_macro()`, `kb_fit_wetdry_nereo()`, `kb_fit_wetdry_macro()`, `kb_fit_carbon_nereo()`, `kb_fit_carbon_macro()`, `kb_fit_cover_biomass_nereo()`, and `kb_fit_cover_biomass_macro()` SHALL fit the species' weight, size, density, wet/dry, carbon, or cover biomass model and return a `kb_fit` object. Arguments SHALL be validated before sampling. Fitting SHALL need no Stan toolchain on the user's machine, and changing a prior's hyperparameters SHALL need no recompilation; a prior's family is fixed by the model.

#### Scenario: Returns a fit
- **WHEN** a fit function is called on valid data
- **THEN** it returns an object inheriting from `kb_fit`, the model class (`kb_fit_weight`, `kb_fit_size`, `kb_fit_density`, `kb_fit_wetdry`, `kb_fit_carbon`, or `kb_fit_cover_biomass`), and the species class (e.g. `kb_fit_density_nereo`)

#### Scenario: Invalid arguments error before sampling
- **WHEN** a fit function is called with invalid data, an invalid sampler argument, or a prior of the wrong family
- **THEN** it errors with a `cli` message before any sampling, a family mismatch saying that a different family needs a different model

### Requirement: Input data

The required columns SHALL be, with `site` and `year` (where required) character or factor and no missing values in any required column. A column measured in a unit SHALL name the unit as a suffix (`_mm`, `_kg`, `_m2`); counts and grouping columns carry no suffix.

- *Nereocystis* weight: `diameter_mm` (sub-bulb diameter, mm, > 0), `weight_kg` (kg, > 0), `site`, and `year`.
- *Macrocystis* weight: `fronds` (a positive whole number), `weight_kg` (kg, > 0), `site`, and `year`.
- *Nereocystis* size: `diameter_mm` (maximum sub-bulb diameter, mm, > 0), `site`, and `year`.
- *Macrocystis* size: `fronds` (fronds at 1 m above the holdfast, a positive whole number), `site`, and `year`.
- *Nereocystis* density: `stipes` (stipes counted on a transect, a whole number `>= 0`), `area_m2` (area surveyed, m², > 0), `site`, and `year`.
- *Macrocystis* density: `plants` (plants counted on a transect, a whole number `>= 0`), `area_m2` (area surveyed, m², > 0), `site`, and `year`.
- Wet/dry, both species: `wet_mass_g` (wet mass of a sample, g, > 0) and `dry_mass_g` (its dry mass, g, > 0 and less than `wet_mass_g`). A warning SHALL give the number of samples whose dry:wet ratio lies outside 0.02 to 0.5, the plausible range for kelp tissue, and those samples SHALL be kept.
- Carbon, both species: `sample_mass_mg` (mass of a dried sample, mg, > 0) and `carbon_mass_ug` (carbon measured in it, µg, > 0), the carbon fraction `carbon_mass_ug / 1000 / sample_mass_mg` being less than 1. A warning SHALL give the number of samples whose carbon fraction lies outside 0.10 to 0.50, the plausible range for kelp tissue, and those samples SHALL be kept.
- Cover biomass, both species: `data` holds the drone surveys, `canopy_area_m2` (canopy delineated in the plot, m², `>= 0`), `plot_area_m2` (plot area, m², > 0 and at least `canopy_area_m2`), `tide_height_m` (tide height at the survey, m, chart datum), `site`, and `year`, and no `estimate`, `lower`, or `upper` column. The in situ wet biomass (kg/m²) is a separate data frame, the fit functions' required second argument `biomass` (before `priors`): `site` and `year`, one row per site-year, and `estimate` (> 0) with its compatibility limits `lower` and `upper` (`0 < lower <= estimate <= upper`, `lower < upper`), the columns of a `kb_predictions` object, so a biomass prediction passes in unchanged. Each survey SHALL be paired with the biomass of its site-year. Surveys with none SHALL be dropped with a message giving their number and site-years (suppressed by `progress = "none"`), and the fit SHALL error when no survey is paired. The level of the limits SHALL be the one a `kb_predictions` object records, else the name-only `conf_level`, else 0.95; a `conf_level` that contradicts the recorded level SHALL error.

*Nereocystis* weight data MAY include `stipes_m2`, the stipe density (stipes per m²) of the plant's site-year: numeric, `>= 0`, `NA` where not recorded, and at most one distinct value per site-year. Other columns SHALL be ignored. `kb_check_data_weight_nereo()`, `kb_check_data_weight_macro()`, `kb_check_data_size_nereo()`, `kb_check_data_size_macro()`, `kb_check_data_density_nereo()`, `kb_check_data_density_macro()`, `kb_check_data_wetdry_nereo()`, `kb_check_data_wetdry_macro()`, `kb_check_data_carbon_nereo()`, `kb_check_data_carbon_macro()`, `kb_check_data_cover_biomass_nereo()`, and `kb_check_data_cover_biomass_macro()` SHALL apply these checks, returning the data invisibly, and the fit functions SHALL apply them at entry. The cover biomass checks SHALL also check `biomass` when it is supplied.

#### Scenario: Valid data passes
- **WHEN** a data check is called on data meeting the requirements
- **THEN** it returns the data invisibly with no message

#### Scenario: A bad column errors naming it
- **WHEN** a required column is missing, of the wrong type, out of range, or contains `NA`
- **THEN** it errors with a message naming the column

#### Scenario: An unsuffixed column name is missing
- **WHEN** *Nereocystis* weight data have `diameter` and `weight` but not `diameter_mm` and `weight_kg`
- **THEN** it errors naming the missing `diameter_mm` column

#### Scenario: A zero frond count errors for size
- **WHEN** *Macrocystis* size data contain a plant with `fronds` of `0`
- **THEN** it errors naming `fronds`, since the model describes plants with at least one frond at 1 m

#### Scenario: Zero counts are valid for density
- **WHEN** density data contain a transect with a count of `0`
- **THEN** the data pass

#### Scenario: A non-positive area errors
- **WHEN** density data contain an `area_m2` of `0` or less
- **THEN** it errors naming `area_m2`

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

#### Scenario: Zero canopy is valid for cover biomass
- **WHEN** cover biomass data contain a survey with `canopy_area_m2` of `0`
- **THEN** the data pass

#### Scenario: Canopy larger than its plot errors
- **WHEN** cover biomass data contain a survey whose `canopy_area_m2` exceeds its `plot_area_m2`
- **THEN** it errors naming `canopy_area_m2`

#### Scenario: Limits that do not bracket the estimate error
- **WHEN** cover biomass `biomass` contains a site-year whose `lower` exceeds `estimate`, whose `upper` is below it, or whose `lower` equals `upper`
- **THEN** it errors naming the offending limit

#### Scenario: Repeated site-years in the biomass error
- **WHEN** cover biomass `biomass` has two rows for one site-year
- **THEN** it errors naming the site-year

#### Scenario: A biomass prediction passes straight in
- **WHEN** `biomass` is a `kb_predictions` object with `site` and `year` columns
- **THEN** the fit pairs it with the surveys and uses the interval level it records

#### Scenario: Surveys without biomass are dropped
- **WHEN** some surveys' site-years have no row in `biomass`
- **THEN** those surveys are not fitted, and a message gives their number and site-years

#### Scenario: Conflicting density within a site-year errors
- **WHEN** two rows of the same site-year carry different `stipes_m2` values
- **THEN** it errors naming the site-year

#### Scenario: Density is optional
- **WHEN** *Nereocystis* weight data have no `stipes_m2` column, or one of all `NA`
- **THEN** the data pass

### Requirement: The data determine which effects are fitted

The site:year effect SHALL be included when the data span more than one year and omitted otherwise, for every model with a site:year effect (weight, size, and density; wet/dry and carbon have no random effects, and cover biomass has site and year effects but never a site:year effect). When no site was sampled in more than one year, or no year had more than one site sampled, it SHALL be retained with a warning naming the main effect (site, year, or both) from which the site:year effect cannot be separated.

The *Nereocystis* weight model's density effect SHALL be included when at least two distinct site-year values of `stipes_m2` are recorded, with density standardised by its mean and SD over the fitted plants. A row with `NA` takes its site-year's recorded value; site-years with no recorded density take the mean.

An omitted effect SHALL not be fitted, reported, or used in prediction (see summaries and predictions). Informational messages SHALL report an omitted site:year effect, a `stipes_m2` column that yields no density effect, and the number of site-years without recorded density; none is issued when there is no `stipes_m2` column, and all are suppressed by `progress = "none"`.

#### Scenario: Single-year data omit site:year
- **WHEN** the data contain one year
- **THEN** the fit has no site:year effect and, unless `progress = "none"`, a message says so

#### Scenario: Aliased design warns
- **WHEN** the data span several years but no site spans more than one
- **THEN** the site:year effect is retained and a warning names the site effect

#### Scenario: One site over several years warns
- **WHEN** the data span several years but every year has a single site
- **THEN** the site:year effect is retained and a warning names the year effect

#### Scenario: Cover biomass never fits site:year
- **WHEN** a cover biomass model is fitted to data spanning several years
- **THEN** the fit has site and year effects, no site:year effect, and no site:year message or warning

#### Scenario: Density effect follows the recorded values
- **WHEN** *Nereocystis* weight data have no `stipes_m2` column, a column of all `NA` or a single value, or at least two distinct recorded site-year values
- **THEN** the density effect is omitted silently, omitted with a message, or included, respectively

#### Scenario: Unrecorded site-years take the mean
- **WHEN** density is recorded for some site-years and not others
- **THEN** the unrecorded site-years enter at the mean density and a message gives their number

### Requirement: Priors

`kb_priors_weight_nereo()`, `kb_priors_weight_macro()`, `kb_priors_size_nereo()`, `kb_priors_size_macro()`, `kb_priors_density_nereo()`, `kb_priors_density_macro()`, `kb_priors_wetdry_nereo()`, `kb_priors_wetdry_macro()`, `kb_priors_carbon_nereo()`, `kb_priors_carbon_macro()`, `kb_priors_cover_biomass_nereo()`, and `kb_priors_cover_biomass_macro()` SHALL return a named list of prior objects, the defaults pinned by `tests/testthat/test-kb_priors_*.R`. The weight, size, wet/dry, carbon, and cover defaults match the analysis-project models; the density defaults are weakly informative round values. Each entry SHALL be named after the parameter it sets, the same name that parameter has in `tidy()`, `coef()`, `summary()`, and `kb_model_describe()`. The entries are:

- *Nereocystis* weight: `intercept`, `diameter_power`, `weight_floor`, `density_slope`, `sd_site`, `sd_year`, `sd_site_year`, and `sd_residual`.
- *Macrocystis* weight: `intercept`, `fronds_slope`, `shape`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Nereocystis* size: `intercept`, `shape`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Macrocystis* size: `intercept`, `dispersion`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Nereocystis* density: `intercept`, `logit_zero_inflation`, `dispersion`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Macrocystis* density: `intercept`, `dispersion`, `sd_site`, `sd_year`, and `sd_site_year`.
- Wet/dry and carbon, both species: `intercept` and `precision`.
- Cover biomass, both species: `cover_slope` (lognormal), `biomass_floor`, `tide_height_slope`, `error_scaling`, `sd_site`, and `sd_year`.

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

The fit functions SHALL take `chains` (default 4), `niters` (saved post-warmup draws per chain, default 1000; warmup matches), `nthin` (default 1), `cores`, `seed`, `progress`, and `progress_dir`, passing other arguments to `rstan::sampling()`. The sampler SHALL use `adapt_delta = 0.95` unless a `control` list overrides it; a supplied `control` is merged over the default. `cores = NULL` SHALL use `getOption("mc.cores")`, falling back to `chains`, capped at the available cores. A fit SHALL be reproducible from `seed`, or from a preceding `set.seed()` when `seed` is `NULL`. No HTML viewer SHALL open.

`progress` SHALL be one of `"bar"` (default, a progress bar with rstan's output suppressed), `"verbose"` (rstan's per-iteration output and warnings), or `"none"` (silent). It SHALL change only console output, never the draws. When `progress_dir` names an existing directory, the fit SHALL write a progress record there under any `progress` mode, and `kb_progress(progress_dir)` SHALL return the completed fraction in `[0, 1]` from another R process: `0` before sampling starts, `1` once complete, and no error mid-write. kelpbio SHALL NOT delete a caller's `progress_dir`.

#### Scenario: niters counts saved draws
- **WHEN** a fit uses `niters = 1000` and `nthin = 2`
- **THEN** `niters(fit)` is `1000`

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

A fit SHALL store posterior draws, sampler diagnostics, the input data, and the fit's settings, and SHALL NOT keep the `stanfit` or any per-observation quantity, so its size depends on the number of draws, not observations. Every summary, diagnostic, and prediction SHALL work from a stored fit. A fit with `prior_only = TRUE` SHALL sample from the priors alone and accept zero-row data. A diagnostic rate with no draws behind it SHALL be `NA`, not zero.

The draws SHALL be a `posterior` `draws_rvars` object that works with `posterior` and the tools built on it as soon as kelpbio is attached, including for a bundled pre-fit or a fit read back in a new session. Per-level group effects SHALL be labelled by their levels: site effects by site, year effects by year, and site:year effects by site and year, so they can be indexed by name as well as by position.

#### Scenario: A stored fit is self-contained
- **WHEN** a fit is saved, reloaded in a new session, and summarised or predicted from
- **THEN** every method works without refitting

#### Scenario: Prior-only fits ignore the data
- **WHEN** `prior_only = TRUE`, including with zero-row data
- **THEN** the draws reflect the priors only

#### Scenario: Draws work on load
- **WHEN** kelpbio is attached in a new session and a bundled pre-fit's draws are printed before any other kelpbio function is called
- **THEN** each parameter prints its draws summary, and has the length of its number of levels

#### Scenario: Group effects are labelled by level
- **WHEN** the site effects of a fit are indexed by a site name, or its draws are converted with `posterior::as_draws_df()`
- **THEN** the effect for that site is returned, and the variables are named `site_effect[<site>]` and `site_year_effect[<site>,<year>]`

### Requirement: Bundled example objects

The package SHALL ship simulated datasets `data_weight_sim_nereo`, `data_weight_sim_macro`, `data_size_sim_nereo`, `data_size_sim_macro`, `data_density_sim_nereo`, `data_density_sim_macro`, `data_wetdry_sim_nereo`, `data_wetdry_sim_macro`, `data_carbon_sim_nereo`, `data_carbon_sim_macro`, `data_cover_biomass_sim_nereo`, `data_cover_biomass_sim_macro`, `data_plot_biomass_sim_nereo`, and `data_plot_biomass_sim_macro`, and small pre-fits `fit_weight_sim_nereo`, `fit_weight_sim_macro`, `fit_size_sim_nereo`, `fit_size_sim_macro`, `fit_density_sim_nereo`, `fit_density_sim_macro`, `fit_wetdry_sim_nereo`, `fit_wetdry_sim_macro`, `fit_carbon_sim_nereo`, `fit_carbon_sim_macro`, `fit_cover_biomass_sim_nereo`, and `fit_cover_biomass_sim_macro`, for examples and tests, not inference. The bundled datasets and the data stored in the pre-fits SHALL use the input column names above. Real survey data and inference-grade fits SHALL NOT be bundled; they belong in the companion package `kelpbiodata`.

For each species, the weight, size, density, cover survey, and in situ plot biomass datasets SHALL be simulated from one set of true site-year values, with parameter values near those estimated from the Hakai Institute surveys, so that plot biomass composed from the bundled weight, size, and density fits is of realistic magnitude and agrees with the bundled in situ plot biomass at the same site-years. The in situ plot biomass SHALL be the true plot biomass with estimation error. The sites SHALL have invented names that match no real survey site. The data sources SHALL cover different site-years, as in field programmes: density at most site-years, size at most of those, weight at a subset that includes sites never harvested, and drone surveys at a subset, each paired with in situ plot biomass. Every harvested *Nereocystis* site-year SHALL be density-surveyed, and its weight data SHALL carry that site-year's `stipes_m2`.

#### Scenario: Bundled objects work with the package
- **WHEN** a bundled dataset is checked and a bundled fit is summarised or predicted from
- **THEN** the dataset passes its data check and the fit works with every method

#### Scenario: Composed and in situ plot biomass agree
- **WHEN** `kb_predict_plot_biomass()` is called with a species' bundled weight, size, and density fits
- **THEN** at the site-years in that species' bundled in situ plot biomass, the median ratio of its estimates to the in situ estimates lies between 0.5 and 2

#### Scenario: Data sources have gaps
- **WHEN** the site-years of a species' bundled weight, size, density, and cover survey datasets are compared
- **THEN** weight covers fewer site-years than density, at least one density-surveyed site has no weight data, size misses at least one density-surveyed site-year, and every cover survey site-year has an in situ plot biomass

### Requirement: Implausible units are flagged

The data checks, and so the fit functions, SHALL warn when a column's median is implausible for the unit its name states: `diameter_mm` below 10 or above 200 (millimetres), `weight_kg` above 100 (kilograms), `stipes_m2` above 100 (stipes per m²), `area_m2` below 1 or above 5000 (square metres), `plot_area_m2` below 1 or above 1,000,000 (square metres), `tide_height_m` below -1 or above 5 (metres), or `wet_mass_g` or `dry_mass_g` above 1000 (grams). The warning SHALL name the column, its median, and the expected unit, and SHALL NOT stop the check or the fit. The message is pinned by `tests/testthat/_snaps/warn.md`.

#### Scenario: Diameter in centimetres is flagged
- **WHEN** *Nereocystis* data have `diameter_mm` in centimetres (median about 3)
- **THEN** a warning names `diameter_mm`, its median, and millimetres, and the data still pass

#### Scenario: Weight in grams is flagged
- **WHEN** either species' data have `weight_kg` in grams
- **THEN** a warning names `weight_kg`, its median, and kilograms

#### Scenario: Area in square centimetres is flagged
- **WHEN** density data have `area_m2` in square centimetres (median about 400,000)
- **THEN** a warning names `area_m2`, its median, and square metres, and the data still pass

#### Scenario: Tide height in centimetres is flagged
- **WHEN** cover biomass data have `tide_height_m` in centimetres (median about 60)
- **THEN** a warning names `tide_height_m`, its median, and metres, and the data still pass

#### Scenario: Sample masses in milligrams are flagged
- **WHEN** wet/dry data have `wet_mass_g` in milligrams (median about 4000)
- **THEN** a warning names `wet_mass_g`, its median, and grams, and the data still pass

#### Scenario: Plausible data raise no warning
- **WHEN** the columns are in the expected units
- **THEN** no unit warning is issued

### Requirement: Weight functional form

`kb_fit_weight_nereo()` SHALL take `form`, a string naming the mean function of weight in diameter: `"packard_floor"` (the default), a three-parameter power function with a size-independent weight floor, or `"power"`, a power law with no floor. Both forms SHALL share the likelihood, random effects, optional density effect, and prior list. An invalid `form` SHALL error before sampling, listing the available forms. The fit SHALL record its form, and every prediction, likelihood, and residual SHALL use it.

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

