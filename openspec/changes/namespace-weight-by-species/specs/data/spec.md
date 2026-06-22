## MODIFIED Requirements

### Requirement: Validate weight model input data

`kb_check_data_weight_nereo(data)` SHALL check that `data` carries the columns required by the *Nereocystis luetkeana* weight model -- numeric `diameter` (> 0), numeric `weight` (> 0), and character-or-factor `site` and `year`, with no missing values -- returning the data invisibly on success and erroring via `chk`/`cli` otherwise.

#### Scenario: Valid data passes
- **WHEN** `kb_check_data_weight_nereo(data)` is called on data with the required columns and types
- **THEN** it returns `data` invisibly

#### Scenario: Missing or mistyped columns error
- **WHEN** a required column is absent, non-numeric where numeric is required, or not positive
- **THEN** it errors via `chk`/`cli`, naming the offending column

### Requirement: Bundled weight dataset

The package SHALL ship `data_weight_hakai_nereo`, the real Hakai Institute *Nereocystis luetkeana* allometry survey data (the data the coastwide weight model is fit to), with columns `diameter`, `weight`, `site`, `year`. It SHALL also ship `data_weight_sim_nereo`, a small simulated dataset with the same columns generated reproducibly from a fixed seed (for fast tests and runnable examples, not for inference), and `fit_weight_hakai_nereo`, a slim pre-fit `kb_fit_weight` model.

#### Scenario: Datasets are available under species-explicit names
- **WHEN** `data_weight_hakai_nereo`, `data_weight_sim_nereo`, or `fit_weight_hakai_nereo` is loaded
- **THEN** it is present with the documented columns / object class

#### Scenario: Pre-fit model records its species
- **WHEN** `fit_weight_hakai_nereo` is loaded
- **THEN** it is an object of class `c("kb_fit_weight", "kb_fit")` with `meta$species` equal to `"nereocystis"`
