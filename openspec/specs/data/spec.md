# data

## Purpose

Validating weight-model input data and the bundled example data and fit objects.
## Requirements
### Requirement: Validate weight model input data

`kb_check_data_weight_nereo(data)` SHALL validate that `data` contains the columns required to fit the weight model, with appropriate types and values, returning the data invisibly on success and erroring on failure. Units are the user's choice: the model centres log-diameter at the geometric mean of the observed diameter, so the diameter unit does not affect the fit or predictions, and weight is returned in whatever unit it was supplied in (prediction data must use the same units as the fitted data). It SHALL use `chk` validators following the `bboudata` conventions (e.g. `chk::chk_superset` for required columns, `chk::chk_character_or_factor` for `site`/`year`, `chk::chk_numeric` plus a positivity check for `diameter`/`weight`, and `chk::chk_not_any_na`), with column-qualified messages.

#### Scenario: Valid data passes
- **WHEN** `kb_check_data_weight_nereo()` is called with a data frame containing numeric `diameter` (> 0), numeric `weight` (> 0), and factor/character `site` and `year`, with no missing values
- **THEN** it returns the data invisibly and emits no error

#### Scenario: Missing required column errors
- **WHEN** the data frame is missing one of `diameter`, `weight`, `site`, `year`
- **THEN** it errors via `chk` with a message naming the missing column(s)

#### Scenario: Wrong type or impossible value errors
- **WHEN** `diameter` or `weight` is non-numeric or contains values `<= 0`
- **THEN** it errors via `chk` with a column-qualified message identifying the offending column

#### Scenario: Missing values error
- **WHEN** any required column contains `NA`
- **THEN** it errors via `chk::chk_not_any_na` naming the column

### Requirement: Bundled weight dataset

The package SHALL ship `data_weight_sim_nereo`, a small simulated *Nereocystis luetkeana* weight dataset with columns `diameter`, `weight`, `site`, `year`, generated reproducibly from a fixed seed. It is intended for fast tests and runnable examples, not for inference.

The package SHALL also ship `fit_weight_sim_nereo`, a slim pre-fit `kb_fit_weight` object fitted to `data_weight_sim_nereo` with a reduced number of chains and draws. It is intended for runnable examples and tests, not for inference.

The package SHALL NOT bundle the real Hakai Institute survey data or an inference-grade fit. Those belong in a separate companion data package (`kelpbiodata`); the code package ships only simulated fixtures.

#### Scenario: Simulated dataset is available and valid
- **WHEN** `data_weight_sim_nereo` is loaded
- **THEN** it is a data frame with columns `diameter`, `weight`, `site`, `year` that passes `kb_check_data_weight_nereo()`

#### Scenario: Example fit is available
- **WHEN** `fit_weight_sim_nereo` is loaded
- **THEN** it is an object of class `c("kb_fit_weight_nereo", "kb_fit_weight", "kb_fit")` that the `kb_fit` accessors, S3 methods, and `kb_predict_weight*()` functions operate on

#### Scenario: Real Hakai data is not bundled
- **WHEN** the package's bundled data is enumerated
- **THEN** it contains no real Hakai survey dataset and no inference-grade fit (these live in the companion data package)

### Requirement: Validate Macrocystis weight model input data

`kb_check_data_weight_macro(data)` SHALL validate macro weight input data and
return it invisibly. The required columns are `fronds`, `weight`, `site`, and
`year`. `fronds` SHALL be a positive whole number (a frond count), `weight` SHALL
be numeric and positive, and `site` / `year` SHALL be character or factor. No
required column may contain `NA`. It SHALL use `chk` validators, which abort with
column-qualified messages on failure.

#### Scenario: Accepts valid macro data
- **WHEN** `kb_check_data_weight_macro()` is given a data frame with positive
  whole-number `fronds`, positive `weight`, and character/factor `site`/`year`
- **THEN** it returns the data invisibly

#### Scenario: Rejects a missing or malformed column
- **WHEN** the `fronds` column is absent, non-positive, or not whole-numbered
- **THEN** it errors via `chk` with a column-qualified message naming the
  `fronds` column and the requirement it failed

### Requirement: Bundled Macrocystis weight objects

The package SHALL bundle a simulated macro weight dataset `data_weight_sim_macro`
(columns `fronds`, `weight`, `site`, `year`, spanning multiple sites and years
including a missing site-year cell, all rows valid) and a slim pre-fit
`fit_weight_sim_macro` (a `kb_fit_weight` object with `meta$species =
"macrocystis"`) fit from it. Both SHALL be simulated only; the coastwide macro
weight fit ships in the companion `kelpbiodata` package.

#### Scenario: Bundled objects load with the documented structure
- **WHEN** `data_weight_sim_macro` and `fit_weight_sim_macro` are loaded
- **THEN** the dataset has columns `fronds`, `weight`, `site`, `year`, and the
  fit is a `c("kb_fit_weight_macro", "kb_fit_weight", "kb_fit")` object with `meta$species` equal to
  `"macrocystis"`

