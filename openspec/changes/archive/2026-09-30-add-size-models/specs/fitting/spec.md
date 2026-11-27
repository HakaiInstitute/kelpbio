## RENAMED Requirements

- FROM: `### Requirement: Fit a weight model`
- TO: `### Requirement: Fit a model`

## MODIFIED Requirements

### Requirement: Fit a model

`kb_fit_weight_nereo()`, `kb_fit_weight_macro()`, `kb_fit_size_nereo()`, and `kb_fit_size_macro()` SHALL fit the species' weight or size model and return a `kb_fit` object. Arguments SHALL be validated before sampling. Fitting SHALL need no Stan toolchain on the user's machine, and changing a prior's hyperparameters SHALL need no recompilation; a prior's family is fixed by the model.

#### Scenario: Returns a fit
- **WHEN** a fit function is called on valid data
- **THEN** it returns an object inheriting from `kb_fit`, the model class (`kb_fit_weight` or `kb_fit_size`), and the species class (e.g. `kb_fit_size_nereo`)

#### Scenario: Invalid arguments error before sampling
- **WHEN** a fit function is called with invalid data, an invalid sampler argument, or a prior of the wrong family
- **THEN** it errors with a `cli` message before any sampling, a family mismatch saying that a different family needs a different model

### Requirement: Input data

The required columns SHALL be, with `site` and `year` character or factor and no missing values in any required column:

- *Nereocystis* weight: `diameter` (mm, > 0), `weight` (kg, > 0), `site`, and `year`.
- *Macrocystis* weight: `fronds` (a positive whole number), `weight` (> 0), `site`, and `year`.
- *Nereocystis* size: `diameter` (maximum sub-bulb diameter, mm, > 0), `site`, and `year`.
- *Macrocystis* size: `fronds` (fronds at 1 m above the holdfast, a positive whole number), `site`, and `year`.

*Nereocystis* weight data MAY include `density`, the stipe density (stipes per m²) of the plant's site-year: numeric, `>= 0`, `NA` where not recorded, and at most one distinct value per site-year. Other columns SHALL be ignored. `kb_check_data_weight_nereo()`, `kb_check_data_weight_macro()`, `kb_check_data_size_nereo()`, and `kb_check_data_size_macro()` SHALL apply these checks, returning the data invisibly, and the fit functions SHALL apply them at entry.

#### Scenario: Valid data passes
- **WHEN** a data check is called on data meeting the requirements
- **THEN** it returns the data invisibly with no message

#### Scenario: A bad column errors naming it
- **WHEN** a required column is missing, of the wrong type, out of range, or contains `NA`
- **THEN** it errors with a message naming the column

#### Scenario: A zero frond count errors for size
- **WHEN** *Macrocystis* size data contain a plant with `fronds` of `0`
- **THEN** it errors naming `fronds`, since the model describes plants with at least one frond at 1 m

#### Scenario: Conflicting density within a site-year errors
- **WHEN** two rows of the same site-year carry different `density` values
- **THEN** it errors naming the site-year

#### Scenario: Density is optional
- **WHEN** *Nereocystis* weight data have no `density` column, or one of all `NA`
- **THEN** the data pass

### Requirement: The data determine which effects are fitted

The site:year effect SHALL be included when the data span more than one year and omitted otherwise, for every model. When no site was sampled in more than one year it SHALL be retained with a warning that the site and site:year effects cannot be interpreted separately.

The *Nereocystis* weight model's density effect SHALL be included when at least two distinct site-year densities are recorded, with density standardised by its mean and SD over the fitted plants. A row with `NA` takes its site-year's recorded value; site-years with no recorded density take the mean.

An omitted effect SHALL not be fitted, reported, or used in prediction (see summaries and predictions). Informational messages SHALL report an omitted site:year effect, a `density` column that yields no density effect, and the number of site-years without recorded density; none is issued when there is no `density` column, and all are suppressed by `progress = "none"`.

#### Scenario: Single-year data omit site:year
- **WHEN** the data contain one year
- **THEN** the fit has no site:year effect and, unless `progress = "none"`, a message says so

#### Scenario: Aliased design warns
- **WHEN** the data span several years but no site spans more than one
- **THEN** the site:year effect is retained and a warning is issued

#### Scenario: Density effect follows the recorded values
- **WHEN** *Nereocystis* weight data have no `density` column, a column of all `NA` or a single value, or at least two distinct recorded site-year values
- **THEN** the density effect is omitted silently, omitted with a message, or included, respectively

#### Scenario: Unrecorded site-years take the mean
- **WHEN** density is recorded for some site-years and not others
- **THEN** the unrecorded site-years enter at the mean density and a message gives their number

### Requirement: Priors

`kb_priors_weight_nereo()`, `kb_priors_weight_macro()`, `kb_priors_size_nereo()`, and `kb_priors_size_macro()` SHALL return a named list of prior objects, the defaults matching the analysis-project models (pinned by `tests/testthat/test-kb_priors_*.R`). The entries are:

- *Nereocystis* weight: `intercept`, `power`, `floor`, `density`, `sd_site`, `sd_year`, `sd_site_year`, and `sd_residual`.
- *Macrocystis* weight: `intercept`, `fronds`, `shape`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Nereocystis* size: `intercept`, `shape`, `sd_site`, `sd_year`, and `sd_site_year`.
- *Macrocystis* size: `intercept`, `dispersion`, `sd_site`, `sd_year`, and `sd_site_year`.

A list passed to `priors` SHALL override only the entries it contains. `kb_prior_normal()` and `kb_prior_exponential()` SHALL validate their hyperparameters and print as the family with its hyperparameters.

#### Scenario: A partial prior list keeps the other defaults
- **WHEN** a user changes one entry (e.g. `p$sd_site <- kb_prior_exponential(2)`) and fits with `priors = p`
- **THEN** that entry is used and the others keep their defaults

#### Scenario: Invalid hyperparameters error
- **WHEN** `kb_prior_normal(0, sd = -1)` or `kb_prior_exponential(rate = 0)` is called
- **THEN** it errors

### Requirement: Bundled example objects

The package SHALL ship simulated datasets `data_weight_sim_nereo`, `data_weight_sim_macro`, `data_size_sim_nereo`, and `data_size_sim_macro`, and small pre-fits `fit_weight_sim_nereo`, `fit_weight_sim_macro`, `fit_size_sim_nereo`, and `fit_size_sim_macro`, for examples and tests, not inference. The simulated *Nereocystis* weight data SHALL include a `density` column recorded for every site-year. Real survey data and inference-grade fits SHALL NOT be bundled; they belong in the companion package `kelpbiodata`.

#### Scenario: Bundled objects work with the package
- **WHEN** a bundled dataset is checked and a bundled fit is summarised or predicted from
- **THEN** the dataset passes its data check and the fit works with every method
