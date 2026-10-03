## 1. Pure pieces

- [x] 1.1 Shared Beta helpers (log-likelihood, deviance, predictive draws over draws) used by wet/dry and carbon; wet/dry methods refactored onto them with unchanged results
- [x] 1.2 `kb_check_data_carbon_nereo()` / `_macro()` (`sample_mass_mg`, `carbon_mass_ug` numeric `> 0`, no `NA`, carbon fraction below 1; warning for fractions outside 0.10 to 0.50); tests and error snapshots
- [x] 1.3 `kb_priors_carbon_nereo()` / `_macro()` (`intercept` Normal(-0.8, 0.3), `precision` Exponential(0.001)); `assemble_carbon_data()`; `.vld_`/`.chk_kb_fit_carbon()`; tests

## 2. Stan model

- [x] 2.1 `inst/stan/carbon.stan` (Beta, `bCarbon`, `bPrecision`); `rstan_config()`, **`install()` checkpoint**; likelihood checked against `extras::log_lik_beta()` without sampling

## 3. Fit functions, methods, verb

- [x] 3.1 `kb_fit_carbon_nereo()` / `_macro()` over a shared internal body (`model = "carbon"`, `response = "carbon_fraction"`, no effects)
- [x] 3.2 `.linpred`, `.epred`, `.log_lik`, `.deviance`, `.add_noise`, `.chk_new_data`, `.fit_descriptor`, `kb_model_describe()` at `kb_fit_carbon`; model label "Carbon"
- [x] 3.3 `kb_predict_carbon()` and `predict.kb_fit_carbon()`; tests

## 4. Bundled data and fixtures (MCMC)

- [x] 4.1 `data-raw/data_carbon_sim_*.R` (mean and precision near the Hakai lab samples), docs
- [x] 4.2 `data-raw/fit_carbon_sim_*.R` pre-fits and carbon fixtures (`build.R --fits=carbon`)
- [x] 4.3 Run the tests; leave new snapshots for review

## 5. Docs and archive

- [x] 5.1 Roxygen, `_pkgdown.yml`, `build.R`/`make-fixtures.R` model list, demo section
- [x] 5.2 Check the specs and reader docs against the code; `openspec archive add-carbon-models --yes`
