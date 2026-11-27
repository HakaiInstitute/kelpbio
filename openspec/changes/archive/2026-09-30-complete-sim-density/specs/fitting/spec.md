## MODIFIED Requirements

### Requirement: Bundled example objects

The package SHALL ship simulated datasets `data_weight_sim_nereo` and `data_weight_sim_macro` and small pre-fits `fit_weight_sim_nereo` and `fit_weight_sim_macro`, for examples and tests, not inference. The simulated *Nereocystis* data SHALL include a `density` column recorded for every site-year. Real survey data and inference-grade fits SHALL NOT be bundled; they belong in the companion package `kelpbiodata`.

#### Scenario: Bundled objects work with the package
- **WHEN** a bundled dataset is checked and a bundled fit is summarised or predicted from
- **THEN** the dataset passes its data check and the fit works with every method
