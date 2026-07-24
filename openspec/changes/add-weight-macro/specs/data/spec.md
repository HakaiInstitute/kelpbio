## ADDED Requirements

### Requirement: Validate Macrocystis weight model input data

`kb_check_data_weight_macro(data)` SHALL validate macro weight input data and
return it invisibly. The required columns are `fronds`, `weight`, `site`, and
`year`. `fronds` SHALL be a positive whole number (a frond count), `weight` SHALL
be numeric and positive, and `site` / `year` SHALL be character or factor. No
required column may contain `NA`. Failures SHALL abort with a column-qualified
`cli` message.

#### Scenario: Accepts valid macro data
- **WHEN** `kb_check_data_weight_macro()` is given a data frame with positive
  whole-number `fronds`, positive `weight`, and character/factor `site`/`year`
- **THEN** it returns the data invisibly

#### Scenario: Rejects a missing or malformed column
- **WHEN** the `fronds` column is absent, non-positive, or not whole-numbered
- **THEN** it aborts with a `cli` message naming the `fronds` column and the
  requirement it failed

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
  fit is a `c("kb_fit_weight", "kb_fit")` object with `meta$species` equal to
  `"macrocystis"`
