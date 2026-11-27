## MODIFIED Requirements

### Requirement: Errors for unsupported objects

A kelpbio function taking a fit (the generics `kb_model_describe()`, `kb_stancode()`, and `samples()`, the prediction verbs `kb_predict_weight()`, `kb_predict_size()`, `kb_predict_density()`, `kb_predict_wetdry()`, and `kb_predict_carbon()`, and `kb_new_data()`) called on an object it does not support SHALL error with a `cli` message naming the argument and the required class (`kb_fit`, or the model class such as `kb_fit_weight`, `kb_fit_size`, `kb_fit_density`, `kb_fit_wetdry`, or `kb_fit_carbon` for the prediction verbs) and pointing to the `kb_fit_*()` functions, attributed to the function the user called. Any method called on a fit whose model has no implementation for it SHALL error naming the object's class rather than return a value. kelpbio SHALL NOT add default methods to generics owned by other packages.

#### Scenario: A non-fit errors helpfully
- **WHEN** `kb_model_describe(1)` or `kb_predict_weight(1)` is called
- **THEN** it errors stating the required class and pointing to the fitting functions

#### Scenario: A fit of the other model errors
- **WHEN** `kb_predict_density()` is called on a weight or size fit, or `kb_predict_weight()` on a density fit
- **THEN** it errors stating the required model class

#### Scenario: A fit without methods fails loudly
- **WHEN** `log_lik()`, `residuals()`, `fitted()`, or `augment()` is called on a fit whose model has no methods
- **THEN** it errors rather than returning a value
