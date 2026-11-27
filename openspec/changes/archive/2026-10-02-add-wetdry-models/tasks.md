## 1. Data checks and priors (pure, no Stan)

- [x] 1.1 `kb_check_data_wetdry_nereo()` and `kb_check_data_wetdry_macro()` (`wet_mass_g`, `dry_mass_g` numeric `> 0`, no `NA`, `dry_mass_g < wet_mass_g`); roxygen states one row per sample and what each column measures; tests and error snapshots
- [x] 1.2 `column_units` gains `wet_mass_g` / `dry_mass_g = "grams"`; `warn_implausible_units()` limits `c(-Inf, 1000)` for both; tests and snapshot
- [x] 1.3 `kb_priors_wetdry_nereo()` / `_macro()` (`intercept` Normal(0, 2), `precision` Exponential(0.01)); tests pin the defaults
- [x] 1.4 `assemble_wetdry_data()` shared by both species (ratio, zero-row support, `prior_only`, priors as data); tests
- [x] 1.5 `.vld_kb_fit_wetdry()` / `.chk_kb_fit_wetdry()`; `.chk_new_data.kb_fit_wetdry` (any data frame, reusing the size check); tests

## 2. Stan model

- [x] 2.1 `inst/stan/wetdry.stan`: Beta on the ratio, `bDryWet` (logit mean), `bPrecision`, vectorised, no generated quantities
- [x] 2.2 `rstantools::rstan_config()`, then `devtools::document()` and **`devtools::install()` checkpoint**; confirm `stanmodels$wetdry` (`test-stanmodels.R`); check the Stan likelihood against `extras::log_lik_beta()` via `log_prob()` without sampling

## 3. Fit functions

- [x] 3.1 `kb_fit_wetdry_nereo()` and `kb_fit_wetdry_macro()` (`model = "wetdry"`, `offset = NULL`, no predictor, `response = "dry_wet_ratio"`, terms `bDryWet`, `bPrecision`, no random effects, no site:year structure)
- [x] 3.2 Structure tests without MCMC; one `skip_on_cran()` end-to-end fit per species (confirm before running)

## 4. Methods (internal generics, `kb_fit_wetdry` tier)

- [x] 4.1 `.linpred.kb_fit_wetdry` (`bDryWet` repeated over grid rows) and `.epred.kb_fit_wetdry` (`inv_logit(lp)`, the Beta mean), rvar and matrix input
- [x] 4.2 `.log_lik`, `.deviance`, `.add_noise` via `extras` `*_beta()` over `.per_draw()`, on `dry_mass_g / wet_mass_g`
- [x] 4.3 `.fit_descriptor.kb_fit_wetdry` (no predictor); `kb_model_describe()` method with `.model_spec_wetdry()` (notation and prose with no random-effects block)
- [x] 4.4 Check `kb_model_describe()` rendering, `print()`, `summary()`, `tidy()`, `glance()`, and `converged()` with no random effects or groups; method tests use wet/dry fixtures

## 5. Prediction verb

- [x] 5.1 `kb_predict_wetdry()` (generic + `kb_fit_wetdry` method; one row from a one-row grid; summary arguments only), `predict.kb_fit_wetdry()`
- [x] 5.2 Tests: one row, estimate equals `augment()$fitted`, wrong-model errors, `kb_plot_predictions()` errors on it

## 6. Bundled data and fixtures (MCMC, confirm first)

- [x] 6.1 `data-raw/data_wetdry_sim_nereo.R` / `_macro.R` simulated from the model (mean ratio and precision close to the Hakai lab data, wet masses in g); documented in `R/data_wetdry_sim_*.R`
- [x] 6.2 `data-raw/fit_wetdry_sim_*.R` slim pre-fits, documented; fixtures in `make-fixtures.R`; `scripts/build.R --fits` covers them
- [x] 6.3 Run the tests and leave new snapshots for review; do not accept

## 7. Docs and archive

- [x] 7.1 Roxygen for every new export; `_pkgdown.yml`; `scripts/demo-api-test.R` wet/dry section (README and vignette deferred)
- [x] 7.2 Update `decisions/species-as-variant.md` (a shared Stan file for structurally identical species) and check the specs and reader docs against the code
- [x] 7.3 `openspec archive add-wetdry-models --yes` in the same PR
