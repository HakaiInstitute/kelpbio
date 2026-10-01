## 1. Likelihood helpers (pure, no Stan)

- [x] 1.1 Internal Weibull helpers (`weibull_scale()`, `log_lik_weibull()`, `res_weibull()` signed against the scale) on `stats`; tests against numerical saturation and the Exp(1) identity
- [x] 1.2 Internal zero-truncated negative binomial helpers (`log_lik_gamma_pois_zt()`, `mean_gamma_pois_zt()`, `ran_gamma_pois_zt()` by inverse CDF, `res_gamma_pois_zt()` with the saturated mean by bisection once per distinct count); tests (probabilities sum to 1, truncated mean, draws, numerical saturation, residual 0 at the truncated mean)
- [x] 1.3 Draft follow-up issues for the user to file: extras (add Weibull functions; simplify #113 to root-finding), kelpbio (migrate to extras), analysis project (sign `res_weibull()` against the scale)

## 2. Data checks and priors (pure, no Stan)

- [x] 2.1 `kb_check_data_size_nereo()` (`diameter`: maximum sub-bulb diameter, `site`, `year`) and `kb_check_data_size_macro()` (`fronds`: fronds reaching 1 m above the holdfast, a positive whole number, `site`, `year`), with roxygen stating what each column measures,, reusing the weight checks' `chk` calls and `warn_implausible_units()`; tests and error snapshots
- [x] 2.2 `kb_priors_size_nereo()` (`intercept` Normal(0, 2), `shape` Exponential(0.1), `sd_*` Exponential(1)) and `kb_priors_size_macro()` (`intercept` Normal(0, 2), `dispersion` Exponential(1), `sd_*` Exponential(1)); tests pin the defaults
- [x] 2.3 `assemble_size_nereo_data()` and `assemble_size_macro_data()` (zero-row support, `site_year_on`, `prior_only`, priors as data); tests
- [x] 2.4 `.vld_kb_fit_size()` / `.chk_kb_fit_size()`; `.vld_new_data_size()` / `.chk_new_data_size()` (a data frame); tests

## 3. Stan models

- [x] 3.1 `inst/stan/size_nereo.stan`: Weibull, mean-parameterised, scalar `bShape`, `bDiameter` + site + year + gated site:year, vectorised local mean, no generated quantities
- [x] 3.2 `inst/stan/size_macro.stan`: zero-truncated negative binomial with `phi = 1 / bDispersion`, `bFronds` intercept, same effect structure
- [x] 3.3 `rstantools::rstan_config()`, then `devtools::document()` and **`devtools::install()` checkpoint**; confirm `stanmodels$size_nereo` / `size_macro` exist (`test-stanmodels.R`)

## 4. Fit functions

- [x] 4.1 `kb_fit_size_nereo()` and `kb_fit_size_macro()` mirroring the weight fit functions (sampler checks, `site_year_structure()` + notify, `resolve_priors()`, `fit_stan()`, `new_kb_fit()` with `model = "size"`, `offset = NULL`, `predictor = NULL`, `response = "diameter"` / `"fronds"`, terms gated by `site_year_on`)
- [x] 4.2 Structure tests without MCMC where possible; one `skip_on_cran()` end-to-end fit per species (confirm before running)

## 5. Methods (internal generics)

- [x] 5.1 `.linpred.kb_fit_size_nereo` / `_macro` (`bDiameter` / `bFronds` + resolved site, year, site:year) in `R/linpred.R`
- [x] 5.2 `.epred.kb_fit_size` (`exp(lp)`) and `.epred.kb_fit_size_macro` (truncated mean; `expectation = FALSE` gives `exp(lp)`), handling rvar and matrix input
- [x] 5.3 `.log_lik`, `.deviance`, `.add_noise` for both species: wrapping the helpers from section 1 over `.per_draw()`
- [x] 5.4 `.chk_new_data.kb_fit_size_*`, `.fit_descriptor.kb_fit_size` (no predictor, group counts)
- [x] 5.5 `kb_model_describe()` methods with `.model_spec_size_nereo()` / `.model_spec_size_macro()` (notation + prose, omitted site:year dropped)
- [x] 5.6 Update `tests/testthat/test-abort.R` generic sets if needed; method tests use size fixtures

## 6. Prediction verbs and plotting

- [x] 6.1 `kb_predict_size()` (generic + species methods + shared body over `data_linpred()`), `kb_predict_size_by()` (over `by_linpred()` with no predictor), `predict.kb_fit_size()`
- [x] 6.2 `kb_plot_predictions()`: size predictions plot as point ranges by group; plot snapshot (vdiffr) for size by site
- [x] 6.3 Tests: estimate equals `augment()$fitted`, one row per group, zero-column `new_data`, representative site, `"sample"` vs `"average"` widths, wrong-model errors

## 7. Bundled data and fixtures (MCMC, confirm first)

- [x] 7.1 `data-raw/data_size_sim_nereo.R`, `data-raw/data_size_sim_macro.R` simulated from the model structure (several sites and years); documented in `R/data_size_sim_*.R`
- [x] 7.2 `data-raw/fit_size_sim_*.R` slim pre-fits, documented in `R/fit_size_sim_*.R`; fixtures in `tests/testthat/fixtures/make-fixtures.R`; `scripts/build.R --fits` covers them
- [x] 7.3 Run the tests and leave new snapshots (`print`, `summary`, `kb_model_describe`, `chk`, plots) for review; do not accept

## 8. Docs and archive

- [x] 8.1 Roxygen for every new export (`@inheritParams params`, `@family`); `_pkgdown.yml` sections (README and vignette deferred until all sub-models are in)
- [x] 8.2 Check the specs and reader docs against the code; update `decisions/prediction-engine.md` where it says the size model "needs its own pass"
- [x] 8.3 `openspec archive add-size-models --yes` in the same PR
