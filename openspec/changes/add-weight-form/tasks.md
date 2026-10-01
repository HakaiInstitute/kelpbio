## 1. R layer (no Stan)

- [ ] 1.1 `form = c("packard", "power")` on `kb_fit_weight_nereo()` (detail argument after `...`, `rlang::arg_match()`), roxygen describing both forms
- [ ] 1.2 `assemble_weight_nereo_data()` gains `floor_on` from the form; test the flag
- [ ] 1.3 Terms omit `bFloor` and `meta$form` records the form; stub tests (no MCMC) for both forms and an invalid form
- [ ] 1.4 `.linpred.kb_fit_weight_nereo` drops the floor for `"power"`; tests that the power mean is `log(alpha) + bPower * log(x)`
- [ ] 1.5 `kb_model_describe()` notation and prose follow the form; snapshot the power-law block

## 2. Stan

- [ ] 2.1 `weight_nereo.stan`: `int<lower=0, upper=1> floor_on` multiplying `bFloor`
- [ ] 2.2 `rstantools::rstan_config()`, **`devtools::install()` checkpoint**
- [ ] 2.3 One `skip_on_cran()` end-to-end power-law fit checking the draws and terms

## 3. Close out

- [ ] 3.1 Refit `fit_weight_sim_nereo` and the fixture (the Stan data block changes); run the tests and leave snapshot changes for review
- [ ] 3.2 Demo script: a power-law fit and a `loo::loo_compare()` against the default
- [ ] 3.3 Check specs and roxygen against the code; `openspec archive add-weight-form --yes`
