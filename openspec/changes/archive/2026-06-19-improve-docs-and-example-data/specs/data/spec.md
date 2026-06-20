## MODIFIED Requirements

### Requirement: Bundled weight dataset

The package SHALL ship `data_weight_hakai`, the real Hakai Institute *Nereocystis luetkeana* allometry survey data (the data the coastwide weight model is fit to), with columns `diameter`, `weight`, `site`, `year`. It is prepared from the analysis project (Hakai-only records, maximum sub-bulb measurements, completeness and outlier screening; no day-of-year filter).

The package SHALL also ship `data_weight_sim`, a small simulated dataset with the same columns (`diameter`, `weight`, `site`, `year`), generated reproducibly from a fixed seed. It is intended for fast tests and runnable examples, not for inference.

The package SHALL also ship `fit_weight`, a slim pre-fit `kb_fit_weight` object fitted to `data_weight_sim` with a reduced number of chains and draws. It is intended for runnable examples and tests, not for inference.

#### Scenario: Hakai dataset is available and valid
- **WHEN** `data_weight_hakai` is loaded
- **THEN** it is a data frame with columns `diameter`, `weight`, `site`, `year` that passes `kb_check_data_weight()`

#### Scenario: Simulated dataset is available and valid
- **WHEN** `data_weight_sim` is loaded
- **THEN** it is a data frame with columns `diameter`, `weight`, `site`, `year` that passes `kb_check_data_weight()`

#### Scenario: Example fit is available
- **WHEN** `fit_weight` is loaded
- **THEN** it is an object of class `c("kb_fit_weight", "kb_fit")` that the `kb_fit` accessors, S3 methods, and `kb_predict_weight*()` functions operate on
