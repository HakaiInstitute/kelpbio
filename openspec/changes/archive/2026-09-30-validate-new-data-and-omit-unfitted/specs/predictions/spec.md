## ADDED Requirements

### Requirement: New data predictor values are validated

`new_data` SHALL be validated before prediction: *Nereocystis* `diameter` numeric, greater than 0, with no missing values; *Macrocystis* `fronds` a positive whole number with no missing values. An invalid value SHALL error with a message naming the column, pinned by `tests/testthat/_snaps/chk.md`.

#### Scenario: An impossible diameter errors
- **WHEN** `new_data` has a `diameter` that is zero, negative, missing, or not numeric
- **THEN** prediction errors naming `diameter`

#### Scenario: A fractional frond count errors
- **WHEN** `new_data` has a non-whole `fronds` value
- **THEN** prediction errors naming `fronds`
