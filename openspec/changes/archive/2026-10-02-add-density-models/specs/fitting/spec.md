## MODIFIED Requirements

### Requirement: Fit a model

`kb_fit_weight_nereo()`, `kb_fit_weight_macro()`, `kb_fit_size_nereo()`, `kb_fit_size_macro()`, `kb_fit_density_nereo()`, and `kb_fit_density_macro()` SHALL fit the species' weight, size, or density model and return a `kb_fit` object. Arguments SHALL be validated before sampling. Fitting SHALL need no Stan toolchain on the user's machine, and changing a prior's hyperparameters SHALL need no recompilation; a prior's family is fixed by the model.

#### Scenario: Returns a fit
- **WHEN** a fit function is called on valid data
- **THEN** it returns an object inheriting from `kb_fit`, the model class (`kb_fit_weight`, `kb_fit_size`, or `kb_fit_density`), and the species class (e.g. `kb_fit_density_nereo`)

#### Scenario: Invalid arguments error before sampling
- **WHEN** a fit function is called with invalid data, an invalid sampler argument, or a prior of the wrong family
- **THEN** it errors with a `cli` message before any sampling, a family mismatch saying that a different family needs a different model

### Requirement: Input data

The required columns SHALL be, with `site` and `year` character or factor and no missing values in any required column. A column measured in a unit SHALL name the unit as a suffix (`_mm`, `_kg`, `_m2`); counts and grouping columns carry no suffix.

- *Nereocystis* weight: `diameter_mm` (sub-bulb diameter, mm, > 0), `weight_kg` (kg, > 0), `site`, and `year`.
- *Macrocystis* weight: `fronds` (a positive whole number), `weight_kg` (kg, > 0), `site`, and `year`.
- *Nereocystis* size: `diameter_mm` (maximum sub-bulb diameter, mm, > 0), `site`, and `year`.
- *Macrocystis* size: `fronds` (fronds at 1 m above the holdfast, a positive whole number), `site`, and `year`.
- *Nereocystis* density: `stipes` (stipes counted on a transect, a whole number `>= 0`), `area_m2` (area surveyed, m², > 0), `site`, and `year`.
- *Macrocystis* density: `plants` (plants counted on a transect, a whole number `>= 0`), `area_m2` (area surveyed, m², > 0), `site`, and `year`.

*Nereocystis* weight data MAY include `stipes_m2`, the stipe density (stipes per m²) of the plant's site-year: numeric, `>= 0`, `NA` where not recorded, and at most one distinct value per site-year. Other columns SHALL be ignored. `kb_check_data_weight_nereo()`, `kb_check_data_weight_macro()`, `kb_check_data_size_nereo()`, `kb_check_data_size_macro()`, `kb_check_data_density_nereo()`, and `kb_check_data_density_macro()` SHALL apply these checks, returning the data invisibly, and the fit functions SHALL apply them at entry.

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

#### Scenario: Conflicting density within a site-year errors
- **WHEN** two rows of the same site-year carry different `stipes_m2` values
- **THEN** it errors naming the site-year

#### Scenario: Density is optional
- **WHEN** *Nereocystis* weight data have no `stipes_m2` column, or one of all `NA`
- **THEN** the data pass

### Requirement: Priors

`kb_priors_weight_nereo()`, `kb_priors_weight_macro()`, `kb_priors_size_nereo()`, `kb_priors_size_macro()`, `kb_priors_density_nereo()`, and `kb_priors_density_macro()` SHALL return a named list of prior objects, the defaults pinned by `tests/testthat/test-kb_priors_*.R`. The weight and size defaults match the analysis-project models; the density defaults are weakly informative round values. The entries are:

- *Nereocystis* weight: `intercept`, `power`, `floor`, `density`, `sd_site`, `sd_year`, `sd_site_year`, and `sd_residual`.
- *Macrocystis* weight: `intercept`, `fronds`, `shape`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Nereocystis* size: `intercept`, `shape`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Macrocystis* size: `intercept`, `dispersion`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Nereocystis* density: `intercept`, `zero_inflation`, `dispersion`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Macrocystis* density: `intercept`, `dispersion`, `sd_site`, `sd_year`, and `sd_site_year`.

A list passed to `priors` SHALL override only the entries it contains. `kb_prior_normal()` and `kb_prior_exponential()` SHALL validate their hyperparameters and print as the family with its hyperparameters.

#### Scenario: A partial prior list keeps the other defaults
- **WHEN** a user changes one entry (e.g. `p$sd_site <- kb_prior_exponential(2)`) and fits with `priors = p`
- **THEN** that entry is used and the others keep their defaults

#### Scenario: Invalid hyperparameters error
- **WHEN** `kb_prior_normal(0, sd = -1)` or `kb_prior_exponential(rate = 0)` is called
- **THEN** it errors

### Requirement: Bundled example objects

The package SHALL ship simulated datasets `data_weight_sim_nereo`, `data_weight_sim_macro`, `data_size_sim_nereo`, `data_size_sim_macro`, `data_density_sim_nereo`, and `data_density_sim_macro`, and small pre-fits `fit_weight_sim_nereo`, `fit_weight_sim_macro`, `fit_size_sim_nereo`, `fit_size_sim_macro`, `fit_density_sim_nereo`, and `fit_density_sim_macro`, for examples and tests, not inference. The bundled datasets and the data stored in the pre-fits SHALL use the input column names above. The simulated *Nereocystis* weight data SHALL include a `stipes_m2` column recorded for every site-year. Real survey data and inference-grade fits SHALL NOT be bundled; they belong in the companion package `kelpbiodata`.

#### Scenario: Bundled objects work with the package
- **WHEN** a bundled dataset is checked and a bundled fit is summarised or predicted from
- **THEN** the dataset passes its data check and the fit works with every method

### Requirement: Implausible units are flagged

The data checks, and so the fit functions, SHALL warn when a column's median is implausible for the unit its name states: `diameter_mm` below 10 or above 200 (millimetres), `weight_kg` above 100 (kilograms), `stipes_m2` above 100 (stipes per m²), or `area_m2` below 1 or above 5000 (square metres). The warning SHALL name the column, its median, and the expected unit, and SHALL NOT stop the check or the fit. The message is pinned by `tests/testthat/_snaps/warn_implausible_units.md`.

#### Scenario: Diameter in centimetres is flagged
- **WHEN** *Nereocystis* data have `diameter_mm` in centimetres (median about 3)
- **THEN** a warning names `diameter_mm`, its median, and millimetres, and the data still pass

#### Scenario: Weight in grams is flagged
- **WHEN** either species' data have `weight_kg` in grams
- **THEN** a warning names `weight_kg`, its median, and kilograms

#### Scenario: Area in square centimetres is flagged
- **WHEN** density data have `area_m2` in square centimetres (median about 400,000)
- **THEN** a warning names `area_m2`, its median, and square metres, and the data still pass

#### Scenario: Plausible data raise no warning
- **WHEN** the columns are in the expected units
- **THEN** no unit warning is issued
