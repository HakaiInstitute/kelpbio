## MODIFIED Requirements

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

The package SHALL ship `data_weight_hakai_nereo`, the real Hakai Institute *Nereocystis luetkeana* allometry survey data (the data the coastwide weight model is fit to), with columns `diameter`, `weight`, `site`, `year`. It SHALL also ship `data_weight_sim_nereo`, a small simulated dataset with the same columns generated reproducibly from a fixed seed (for fast tests and runnable examples, not for inference), and `fit_weight_hakai_nereo`, a slim pre-fit `kb_fit_weight` model.

#### Scenario: Datasets are available under species-explicit names
- **WHEN** `data_weight_hakai_nereo`, `data_weight_sim_nereo`, or `fit_weight_hakai_nereo` is loaded
- **THEN** it is present with the documented columns / object class

#### Scenario: Pre-fit model records its species
- **WHEN** `fit_weight_hakai_nereo` is loaded
- **THEN** it is an object of class `c("kb_fit_weight", "kb_fit")` with `meta$species` equal to `"nereocystis"`
