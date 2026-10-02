## 1. Data checks and priors (pure, no Stan)

- [x] 1.1 `kb_check_data_density_nereo()` (`stipes`, `area_m2`, `site`, `year`) and `kb_check_data_density_macro()` (`plants`, `area_m2`, `site`, `year`): counts whole numbers `>= 0`, `area_m2` numeric `> 0`, no `NA`; roxygen states one row per transect and what each column measures; tests and error snapshots
- [x] 1.2 `column_units` gains `area_m2 = "square metres"`; `warn_implausible_units()` limits `area_m2 = c(1, 5000)`; tests and snapshot
- [x] 1.3 `kb_priors_density_nereo()` (`intercept` Normal(0, 2), `zero_inflation` Normal(0, 2), `dispersion` Exponential(1), `sd_*` Exponential(1)) and `kb_priors_density_macro()` (same without `zero_inflation`); tests pin the defaults
- [x] 1.4 `assemble_density_nereo_data()` and `assemble_density_macro_data()` (counts, `area_m2`, zero-row support, `site_year_on`, `prior_only`, priors as data); tests
- [x] 1.5 `.vld_kb_fit_density()` / `.chk_kb_fit_density()`; `.vld_new_data_density()` / `.chk_new_data_density()` (a data frame with `area_m2` numeric `> 0`, no `NA`; the missing-column message points to `kb_predict_density_by()`); tests

## 2. Stan models

- [x] 2.1 `inst/stan/density_nereo.stan`: zero-inflated negative binomial, `log_area` in transformed data, zero / non-zero index split, `bStipes` + site + year + gated site:year, `bZeroInflation` (logit), `bDispersion` (`phi = 1 / bDispersion`), vectorised local mean, no generated quantities
- [x] 2.2 `inst/stan/density_macro.stan`: negative binomial, same structure without zero inflation, intercept `bPlants`
- [x] 2.3 `rstantools::rstan_config()`, then `devtools::document()` and **`devtools::install()` checkpoint**; confirm `stanmodels$density_nereo` / `density_macro` exist (`test-stanmodels.R`)

## 3. Fit functions

- [x] 3.1 `kb_fit_density_nereo()` and `kb_fit_density_macro()` mirroring the size fit functions (`model = "density"`, `offset = "area_m2"`, `predictor = NULL`, `response = "stipes"` / `"plants"`, terms gated by `site_year_on`)
- [x] 3.2 Structure tests without MCMC where possible; one `skip_on_cran()` end-to-end fit per species (confirm before running)

## 4. Methods (internal generics)

- [x] 4.1 `.linpred.kb_fit_density_nereo` / `_macro` over the shared intercept-plus-effects body (rename `.linpred_size()` to a model-neutral name if shared)
- [x] 4.2 `.epred.kb_fit_density` (`exp(lp)`) and `.epred.kb_fit_density_nereo` (`(1 - zi) * exp(lp)`; `expectation = FALSE` gives `exp(lp)`), rvar and matrix input
- [x] 4.3 `.log_lik`, `.deviance`, `.add_noise` for both species via `extras` `*_gamma_pois_zi()` / `*_gamma_pois()` over `.per_draw()`
- [x] 4.4 `.chk_new_data.kb_fit_density`, `.fit_descriptor.kb_fit_density` (no predictor, group counts)
- [x] 4.5 `kb_model_describe()` methods with `.model_spec_density_nereo()` / `_macro()` (notation with `log(area_m2)`, prose; omitted site:year dropped)
- [x] 4.6 Update `tests/testthat/test-abort.R` generic sets if needed; method tests use density fixtures, including an offset check (`fitted()` scales with `area_m2`)

## 5. Prediction verbs and plotting

- [x] 5.1 `kb_predict_density()` (generic + `kb_fit_density` method over `data_linpred()`), `kb_predict_density_by()` (over `by_linpred()`; response `stipes_m2` / `plants_m2`, `area_m2` column dropped), `predict.kb_fit_density()`
- [x] 5.2 `kb_axis_label()` entries for `stipes`, `plants`, `stipes_m2` ("Stipe density"), `plants_m2` ("Plant density"), with units; plot snapshot (vdiffr) for density by site
- [x] 5.3 Tests: estimate equals `augment()$fitted`; `_by` equals the row-wise verb at `area_m2 = 1`; expected count doubles with area; `"sample"` vs `"average"` widths; missing-area and wrong-model errors

## 6. Bundled data and fixtures (MCMC, confirm first)

- [x] 6.1 `data-raw/data_density_sim_nereo.R` (about 20% zeros), `data-raw/data_density_sim_macro.R`, simulated from the model structure (several sites and years, about 4 transects per site-year, areas 20 to 120 m²); documented in `R/data_density_sim_*.R`
- [x] 6.2 `data-raw/fit_density_sim_*.R` slim pre-fits, documented in `R/fit_density_sim_*.R`; fixtures in `tests/testthat/fixtures/make-fixtures.R`; `scripts/build.R --fits` covers them
- [x] 6.3 Run the tests and leave new snapshots (`print`, `summary`, `kb_model_describe`, `chk`, `warn_implausible_units`, plots) for review; do not accept

## 7. Docs and archive

- [x] 7.1 Roxygen for every new export (`@inheritParams params`, `@family`); `_pkgdown.yml` sections; `scripts/demo-api-test.R` density section (README and vignette deferred until all sub-models are in)
- [x] 7.2 Check the specs and reader docs against the code; update `decisions/prediction-engine.md` where it describes the offset as planned
- [x] 7.3 `openspec archive add-density-models --yes` in the same PR
