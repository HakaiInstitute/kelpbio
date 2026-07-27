# data

## MODIFIED Requirements

### Requirement: Bundled weight dataset

The package SHALL ship `data_weight_sim_nereo`, a small simulated *Nereocystis luetkeana* weight dataset with columns `diameter`, `weight`, `site`, `year`, generated reproducibly from a fixed seed. It is intended for fast tests and runnable examples, not for inference.

The package SHALL also ship `fit_weight_sim_nereo`, a slim pre-fit `kb_fit_weight` object fitted to `data_weight_sim_nereo` with a reduced number of chains and draws. It is intended for runnable examples and tests, not for inference.

The package SHALL NOT bundle the real Hakai Institute survey data or an inference-grade fit. Those belong in a separate companion data package (`kelpbiodata`); the code package ships only simulated fixtures.

#### Scenario: Simulated dataset is available and valid
- **WHEN** `data_weight_sim_nereo` is loaded
- **THEN** it is a data frame with columns `diameter`, `weight`, `site`, `year` that passes `kb_check_data_weight_nereo()`

#### Scenario: Example fit is available
- **WHEN** `fit_weight_sim_nereo` is loaded
- **THEN** it is an object of class `c("kb_fit_weight", "kb_fit")` that the `kb_fit` accessors, S3 methods, and `kb_predict_weight*()` functions operate on

#### Scenario: Real Hakai data is not bundled
- **WHEN** the package's bundled data is enumerated
- **THEN** it contains no real Hakai survey dataset and no inference-grade fit (these live in the companion data package)
