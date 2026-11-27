# data

## MODIFIED Requirements

### Requirement: Bundled weight dataset

The package SHALL ship `kb_data_weight`, the real Hakai Institute *Nereocystis luetkeana* allometry survey data (the data the coastwide weight model is fit to), with columns `diameter`, `weight`, `site`, `year`. It is prepared from the analysis project (Hakai-only records, maximum sub-bulb measurements, completeness and outlier screening; no day-of-year filter) and used in examples and as the coastwide model's training data. A small simulated dataset is retained in the test fixtures (not exported) for fast, stable internal tests.

#### Scenario: Dataset is available and valid
- **WHEN** `kb_data_weight` is loaded
- **THEN** it is a data frame with columns `diameter`, `weight`, `site`, `year` that passes `kb_check_data_weight()`
