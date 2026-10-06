## 1. Pure pieces

- [x] 1.1 `cover_log_sd()` (log-scale SD from `lower`, `upper`, and the interval level); tests
- [x] 1.2 `kb_check_data_cover_biomass_nereo()` / `_macro()` (survey columns, `estimate`/`lower`/`upper` bracketing, canopy within plot); `plot_area_m2` and `tide_height_m` unit limits; tests and error snapshots
- [x] 1.3 `kb_priors_cover_biomass_nereo()` / `_macro()`; `assemble_cover_biomass_data()`; `.vld_`/`.chk_kb_fit_cover_biomass()`; `.chk_new_data.kb_fit_cover_biomass()`; tests
- [x] 1.4 `.add_noise()` gains the prediction rows; existing methods ignore them

## 2. Stan model

- [x] 2.1 `inst/stan/cover_biomass.stan` (floor plus canopy term on tide-corrected cover, site and year effects, normal on log biomass with scaled per-row SD); `rstan_config()`, **`install()` checkpoint**; likelihood checked against the R-side `.log_lik` without sampling

## 3. Fit functions, methods, verbs

- [x] 3.1 `kb_fit_cover_biomass_nereo()` / `_macro()` over a shared internal body (`model = "cover_biomass"`, `conf_level` name-only, `site_year_on = FALSE`)
- [x] 3.2 `.linpred`, `.epred`, `.log_lik`, `.deviance`, `.add_noise`, `.fit_descriptor`, `kb_model_describe()` at `kb_fit_cover_biomass`
- [x] 3.3 `kb_predict_cover_biomass()`, `kb_predict_cover_biomass_by()`, and `predict.kb_fit_cover_biomass()`; axis labels; tests

## 4. Bundled data and fixtures (MCMC)

- [x] 4.1 `data-raw/data_cover_biomass_sim_*.R` (parameters near the analysis production fits), docs
- [x] 4.2 `data-raw/fit_cover_biomass_sim_*.R` pre-fits and cover fixtures (`build.R --fits=cover_biomass`)
- [x] 4.3 Run the tests; leave new snapshots for review

## 5. Docs and archive

- [x] 5.1 Roxygen, `_pkgdown.yml`, `build.R`/`make-fixtures.R`/tasks.json model list, demo section
- [x] 5.2 Check the specs and reader docs against the code; `openspec archive add-cover biomass models --yes`
