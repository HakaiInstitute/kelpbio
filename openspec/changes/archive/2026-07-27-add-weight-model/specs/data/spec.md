## ADDED Requirements

### Requirement: Validate weight model input data

`kb_check_data_weight(data)` SHALL validate that `data` contains the columns required to fit the weight model, with appropriate types and values, returning the data invisibly on success and erroring on failure. Units are the user's choice: the model centres log-diameter at the geometric mean of the observed diameter, so the diameter unit does not affect the fit or predictions, and weight is returned in whatever unit it was supplied in. It SHALL use `chk` validators following the `bboudata` conventions (e.g. `chk::chk_superset` for required columns, `chk::chk_character_or_factor` for `site`/`year`, `chk::chk_numeric` plus a positivity check for `diameter`/`weight`, and `chk::chk_not_any_na`), with column-qualified messages.

#### Scenario: Valid data passes
- **WHEN** `kb_check_data_weight()` is called with a data frame containing numeric `diameter` (> 0), numeric `weight` (> 0), and factor/character `site` and `year`, with no missing values
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

The package SHALL ship `kb_data_weight`, a small dataset with columns `diameter`, `weight`, `site`, `year`, usable in examples and tests.

#### Scenario: Dataset is available and valid
- **WHEN** `kb_data_weight` is loaded
- **THEN** it is a data frame that passes `kb_check_data_weight()`
