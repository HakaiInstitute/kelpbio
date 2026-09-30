# fitting

## Purpose

Fitting a model: the input data and its checks, the priors, how the data determine
which effects are fitted, sampler control and progress, and what a fit object
holds. The exact model each fit function estimates (likelihood, mean, effects,
priors) is the one `kb_model_describe()` reports, pinned by
`tests/testthat/_snaps/kb_model_describe.md`.
## Requirements
### Requirement: Fit a weight model

`kb_fit_weight_nereo()` and `kb_fit_weight_macro()` SHALL fit the species' weight model and return a `kb_fit` object. Arguments SHALL be validated before sampling. Fitting SHALL need no Stan toolchain on the user's machine, and changing a prior's hyperparameters SHALL need no recompilation; a prior's family is fixed by the model.

#### Scenario: Returns a fit
- **WHEN** a fit function is called on valid data
- **THEN** it returns an object inheriting from `kb_fit`, `kb_fit_weight`, and the species class (`kb_fit_weight_nereo` or `kb_fit_weight_macro`)

#### Scenario: Invalid arguments error before sampling
- **WHEN** a fit function is called with invalid data, an invalid sampler argument, or a prior of the wrong family
- **THEN** it errors with a `cli` message before any sampling, a family mismatch saying that a different family needs a different model

### Requirement: Input data

The required columns SHALL be `diameter` (mm, > 0), `weight` (kg, > 0), `site`, and `year` for *Nereocystis*, and `fronds` (a positive whole number), `weight` (> 0), `site`, and `year` for *Macrocystis*, with `site` and `year` character or factor and no missing values. *Nereocystis* data MAY include `density`, the stipe density (stipes per m²) of the plant's site-year: numeric, `>= 0`, `NA` where not recorded, and at most one distinct value per site-year. `kb_check_data_weight_nereo()` and `kb_check_data_weight_macro()` SHALL apply these checks, returning the data invisibly, and the fit functions SHALL apply them at entry.

#### Scenario: Valid data passes
- **WHEN** a data check is called on data meeting the requirements
- **THEN** it returns the data invisibly with no message

#### Scenario: A bad column errors naming it
- **WHEN** a required column is missing, of the wrong type, out of range, or contains `NA`
- **THEN** it errors with a message naming the column

#### Scenario: Conflicting density within a site-year errors
- **WHEN** two rows of the same site-year carry different `density` values
- **THEN** it errors naming the site-year

#### Scenario: Density is optional
- **WHEN** *Nereocystis* data have no `density` column, or one of all `NA`
- **THEN** the data pass

### Requirement: The data determine which effects are fitted

The site:year effect SHALL be included when the data span more than one year and omitted otherwise. When no site was sampled in more than one year it SHALL be retained with a warning that the site and site:year effects cannot be interpreted separately.

The *Nereocystis* density effect SHALL be included when at least two distinct site-year densities are recorded, with density standardised by its mean and SD over the fitted plants. A row with `NA` takes its site-year's recorded value; site-years with no recorded density take the mean.

An omitted effect SHALL not be fitted, reported, or used in prediction (see summaries and predictions). Informational messages SHALL report an omitted site:year effect, a `density` column that yields no density effect, and the number of site-years without recorded density; none is issued when there is no `density` column, and all are suppressed by `progress = "none"`.

#### Scenario: Single-year data omit site:year
- **WHEN** the data contain one year
- **THEN** the fit has no site:year effect and, unless `progress = "none"`, a message says so

#### Scenario: Aliased design warns
- **WHEN** the data span several years but no site spans more than one
- **THEN** the site:year effect is retained and a warning is issued

#### Scenario: Density effect follows the recorded values
- **WHEN** *Nereocystis* data have no `density` column, a column of all `NA` or a single value, or at least two distinct recorded site-year values
- **THEN** the density effect is omitted silently, omitted with a message, or included, respectively

#### Scenario: Unrecorded site-years take the mean
- **WHEN** density is recorded for some site-years and not others
- **THEN** the unrecorded site-years enter at the mean density and a message gives their number

### Requirement: Priors

`kb_priors_weight_nereo()` and `kb_priors_weight_macro()` SHALL return a named list of prior objects, the defaults matching the analysis-project models (pinned by `tests/testthat/test-kb_priors_weight_*.R`). The *Nereocystis* entries are `intercept`, `power`, `floor`, `density`, `sd_site`, `sd_year`, `sd_site_year`, and `sd_residual`; the *Macrocystis* entries are `intercept`, `fronds`, `shape`, `sd_site`, `sd_year`, and `sd_site_year`. A list passed to `priors` SHALL override only the entries it contains. `kb_prior_normal()` and `kb_prior_exponential()` SHALL validate their hyperparameters and print as the family with its hyperparameters.

#### Scenario: A partial prior list keeps the other defaults
- **WHEN** a user changes one entry (e.g. `p$sd_site <- kb_prior_exponential(2)`) and fits with `priors = p`
- **THEN** that entry is used and the others keep their defaults

#### Scenario: Invalid hyperparameters error
- **WHEN** `kb_prior_normal(0, sd = -1)` or `kb_prior_exponential(rate = 0)` is called
- **THEN** it errors

### Requirement: Sampler control and progress

The fit functions SHALL take `chains` (default 4), `niters` (saved post-warmup draws per chain, default 1000; warmup matches), `nthin` (default 1), `cores`, `seed`, `progress`, and `progress_dir`, passing other arguments to `rstan::sampling()`. The sampler SHALL use `adapt_delta = 0.95` unless a `control` list overrides it; a supplied `control` is merged over the default. `cores = NULL` SHALL use `getOption("mc.cores")`, falling back to `chains`, capped at the available cores. A fit SHALL be reproducible from `seed`, or from a preceding `set.seed()` when `seed` is `NULL`. No HTML viewer SHALL open.

`progress` SHALL be one of `"bar"` (default, a progress bar with rstan's output suppressed), `"verbose"` (rstan's per-iteration output and warnings), or `"none"` (silent). It SHALL change only console output, never the draws. When `progress_dir` names an existing directory, the fit SHALL write a progress record there under any `progress` mode, and `kb_fit_progress(progress_dir)` SHALL return the completed fraction in `[0, 1]` from another R process: `0` before sampling starts, `1` once complete, and no error mid-write. kelpbio SHALL NOT delete a caller's `progress_dir`.

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
- **WHEN** a fit writes to `progress_dir` and `kb_fit_progress(progress_dir)` is called during and after it
- **THEN** it returns the completed fraction, reaching `1` when the fit finishes

### Requirement: The fit object

A fit SHALL store posterior draws, sampler diagnostics, the input data, and the fit's settings, and SHALL NOT keep the `stanfit` or any per-observation quantity, so its size depends on the number of draws, not observations. Every summary, diagnostic, and prediction SHALL work from a stored fit. A fit with `prior_only = TRUE` SHALL sample from the priors alone and accept zero-row data. A diagnostic rate with no draws behind it SHALL be `NA`, not zero.

#### Scenario: A stored fit is self-contained
- **WHEN** a fit is saved, reloaded in a new session, and summarised or predicted from
- **THEN** every method works without refitting

#### Scenario: Prior-only fits ignore the data
- **WHEN** `prior_only = TRUE`, including with zero-row data
- **THEN** the draws reflect the priors only

### Requirement: Bundled example objects

The package SHALL ship simulated datasets `data_weight_sim_nereo` and `data_weight_sim_macro` and small pre-fits `fit_weight_sim_nereo` and `fit_weight_sim_macro`, for examples and tests, not inference. The simulated *Nereocystis* data SHALL include a `density` column recorded for every site-year. Real survey data and inference-grade fits SHALL NOT be bundled; they belong in the companion package `kelpbiodata`.

#### Scenario: Bundled objects work with the package
- **WHEN** a bundled dataset is checked and a bundled fit is summarised or predicted from
- **THEN** the dataset passes its data check and the fit works with every method

### Requirement: Implausible units are flagged

The data checks, and so the fit functions, SHALL warn when a column's median is implausible for its expected unit: `diameter` below 10 or above 200 (millimetres), `weight` above 100 (kilograms), or `density` above 100 (stipes per m²). The warning SHALL name the column, its median, and the expected unit, and SHALL NOT stop the check or the fit. The message is pinned by `tests/testthat/_snaps/warn_implausible_units.md`.

#### Scenario: Diameter in centimetres is flagged
- **WHEN** *Nereocystis* data have `diameter` in centimetres (median about 3)
- **THEN** a warning names `diameter`, its median, and millimetres, and the data still pass

#### Scenario: Weight in grams is flagged
- **WHEN** either species' data have `weight` in grams
- **THEN** a warning names `weight`, its median, and kilograms

#### Scenario: Plausible data raise no warning
- **WHEN** the columns are in the expected units
- **THEN** no unit warning is issued

