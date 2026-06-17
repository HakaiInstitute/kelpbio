## ADDED Requirements

### Requirement: Validate weight model input data

`kb_check_data_weight(data)` SHALL validate that `data` contains the columns required to fit the weight model, with appropriate types, returning the data invisibly on success and erroring via `cli` on failure.

#### Scenario: Valid data passes
- **WHEN** `kb_check_data_weight()` is called with a data frame containing numeric `diameter` (> 0), numeric `weight` (> 0), and factor/character `site` and `year`
- **THEN** it returns the data invisibly and emits no error

#### Scenario: Missing required column errors
- **WHEN** the data frame is missing one of `diameter`, `weight`, `site`, `year`
- **THEN** it errors with a `cli` message naming the missing column(s)

#### Scenario: Wrong type or impossible value errors
- **WHEN** `diameter` or `weight` is non-numeric or contains values `<= 0`
- **THEN** it errors with an informative `cli` message identifying the offending column

### Requirement: Bundled weight dataset

The package SHALL ship `kb_data_weight`, a small dataset with columns `diameter`, `weight`, `site`, `year`, usable in examples and tests.

#### Scenario: Dataset is available and valid
- **WHEN** `kb_data_weight` is loaded
- **THEN** it is a data frame that passes `kb_check_data_weight()`
