## 1. R layer (no Stan)

- [x] 1.1 `form = c("packard_floor", "power")` on `kb_fit_weight_nereo()` (a model descriptor after `priors`, before `...`; `rlang::arg_match()`), roxygen describing both forms
- [x] 1.2 `assemble_weight_nereo_data()` gains `floor_on` from the form; test the flag
- [x] 1.3 Terms omit `bFloor` and `meta$form` records the form; stub tests (no MCMC) for both forms and an invalid form
- [x] 1.4 `.linpred.kb_fit_weight_nereo` drops the floor for `"power"`; tests that the power mean is `log(alpha) + bPower * log(x)`
- [x] 1.5 `kb_model_describe()` notation and prose follow the form; snapshot the power-law block

## 2. Stan

- [x] 2.1 `weight_nereo.stan`: `int<lower=0, upper=1> floor_on` multiplying `bFloor`
- [x] 2.2 `rstantools::rstan_config()`, **`devtools::install()` checkpoint**
- [x] 2.3 One `skip_on_cran()` end-to-end power-law fit checking the draws and terms

## 3. Close out

- [x] 3.1 Refit `fit_weight_sim_nereo` and the fixture (the Stan data block changes); run the tests and leave snapshot changes for review
- [x] 3.2 Demo script: a power-law fit and a `loo::loo_compare()` against the default
- [x] 3.3 Check specs and roxygen against the code; `openspec archive add-weight-form --yes`
