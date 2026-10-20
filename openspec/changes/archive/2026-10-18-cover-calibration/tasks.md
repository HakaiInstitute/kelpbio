## 1. Remove the density and Macrocystis size models (pure code)

- [x] 1.1 Delete `kb_fit_density_*()`, `kb_priors_density_*()`, `kb_check_data_density_*()`, `assemble_density_*_data()`, `kb_predict_density()`, `predict.kb_fit_density()`, and their tests and snapshots
- [x] 1.2 Delete `kb_fit_size_macro()`, `kb_priors_size_macro()`, `kb_check_data_size_macro()`, `assemble_size_macro_data()`, and their tests and snapshots
- [x] 1.3 Remove the rate-model offset: `meta$offset` and the `offset` argument of `new_kb_fit()` and every fit body, `R/offset.R`, the offset arguments of `data_linpred()` and `predict_rows()`, the offset in `.linpred_obs()`, the per-area division in `pp_check()`, and the rate response override in `summarise_predictions()`
- [x] 1.4 Remove the count families (`gamma_pois`, `gamma_pois_zi`, `gamma_pois_zt`, `R/gamma_pois_zt.R`) and the density and size macro methods of `.epred()`, `.linpred()`, `.obs_family()`, `.model_spec()`, `.chk_new_data()`, and `.grid_columns()`; update `tests/testthat/test-abort.R`'s generic sets
- [x] 1.5 Remove the density new-data checks (`.chk_new_data_density()`, `.vld_new_data_density()`), the density class from the grid-able classes and hint, and the density axis labels in `kb_plot_predictions()`
- [x] 1.6 Make `.plant_sizes()` a plain function for the *Nereocystis* size fit; delete `plot_biomass_grid()` and `kb_predict_plot_biomass()`

## 2. Survey and plant inputs (pure code)

- [x] 2.1 `.vld_`/`.chk_` pairs for the survey table (key, `Date`, derived and agreeing `year`, `survey_area_m2`, `plants`, drone columns all-or-none, canopy at most plot) and plant tables (key, size, `partial`)
- [x] 2.2 `kb_check_data_survey(data, plants = NULL)`, `kb_check_data_plants_nereo()`, `kb_check_data_plants_macro()` (the 1 m frond rule moves here); `column_units()` and `warn.R` for `survey_area_m2` and the searched-area-above-plot warning
- [x] 2.3 Rename `stipes` to `plants` throughout code, docs, and messages

## 3. Derived verbs (pure code, existing fits)

- [x] 3.1 Draws column on `kb_predictions`: summary from an `rvar` response column; remove the `kb_conf_level` attribute
- [x] 3.2 Shared derived-verb checks (`measure`, fits, species, draws) and one `sum_by` helper (per-draw sums, summed area, shared sampled levels, ordering)
- [x] 3.3 One internal, built from `mean_plant_weight()` and `.plant_sizes()`, giving draws of the mean plant weight for a set of site-years (shared sampled levels, `n_plants`, progress); `kb_predict_mean_weight()` summarises it with support columns
- [x] 3.4 `kb_predict_biomass_survey()`: tallied path (plants × the mean weight draws from 3.3) and census path (sum of plant weights, `partial` halves), zero surveys and their message, `per_area`, response names, `sum_by`
- [x] 3.5 `kb_predict_biomass_canopy()` from `kb_predict_site_biomass()`: dividing tide correction, `per_area`, draws column, `sum_by` overlap warning; delete the old name

## 4. Cover calibration model (install-gated)

- [x] 4.1 `inst/stan/cover_calibration.stan` (replacing `cover_biomass.stan`): censored Normal with `sd_residual`, `cv_residual`, and each survey's biomass SD; dividing tide correction with `tide_height_slope` bounded at 0.5; drop `error_scaling`; delete `density_*.stan` and `size_macro.stan`
- [x] 4.2 Rename the model to `cover_calibration`: `kb_fit_cover_calibration_*(data, priors, ...)`, `kb_priors_cover_calibration_*()`, `kb_check_data_cover_calibration_*()`, `kb_predict_cover_calibration()`, the class, `fit_cover_calibration_model()`, `assemble_cover_calibration_data()` (mean and SD from the `biomass_kg_m2` draws, zero flag)
- [x] 4.3 Drop `join_cover_biomass()`, `notify_cover_unmatched()`, `cover_log_sd()`, `cover_conf_level()`, `.chk_biomass_limits()`, `.chk_plot_biomass()`, and the cover fit's `conf_level`; leave out rows without drone cover with a message
- [x] 4.4 Censored Normal family file (`log_lik`, `res`, `ran`) and `.obs_family()`, `.epred()` (`mu`), `.linpred()`, `tide_corrected_canopy()`, `tide_corrected_cover()`, `pp_check()`, and `.model_spec()` for the calibration
- [x] 4.5 CHECKPOINT: `rstantools::rstan_config()`, `devtools::document()`, `devtools::install()`

## 5. Simulated data, pre-fits, and fixtures (MCMC, confirm before running)

- [x] 5.1 `data-raw/data_sim_nereo.R` and `data_sim_macro.R`: one truth per species simulating survey counts (tallied for *Nereocystis*, plant by plant for *Macrocystis*), several plots in one site-year, a survey with no plants, drone cover on a subset, and canopy tables; write `data_survey_sim_*`, `data_plants_sim_macro`, `data_canopy_sim_*`; delete the density, size macro, cover survey, and plot biomass datasets
- [x] 5.2 `scripts/build.R` and `tests/testthat/fixtures/make-fixtures.R`: drop density and size macro, rename cover to cover calibration
- [x] 5.3 Rebuild every pre-fit and fixture (`--fits`); delete `fit_density_sim_*`, `fit_size_sim_macro`, and their fixtures

## 6. Tests

- [x] 6.1 Tests mirroring each new or renamed file, including the scenarios in the delta specs; snapshot new messages and prints; leave `.new` snapshot files for review
- [x] 6.2 The bundled-objects tests: survey biomass and the calibration agree, and the data gaps hold

## 7. Docs, specs, and records

- [x] 7.1 Roxygen for every new and renamed function, `R/params.R`, `R/data.R`, `R/fits.R`, and `_pkgdown.yml`, following `STYLE.md`; define "plant" once in the survey and plant checks and `kb_predict_biomass_survey()`, and the two areas side by side
- [x] 7.2 Rewrite the Get started vignette `vignettes/kelpbio.Rmd` (terms, inputs, workflow, other uses), chunks off until implemented
- [x] 7.3 Turn on evaluation in `vignettes/kelpbio.Rmd`, check every chunk runs and its tables and plots read as the prose says; README gets the definition of "plant" and the peak-season scope (the full rewrite waits for the docs pass); update the demo scripts
- [x] 7.4 Update `decisions/prediction-engine.md`, `decisions/architecture.md`, `decisions/species-as-variant.md`, `decisions/parameter-naming.md`, and `decisions/intermediate-predictions.md`; update CLAUDE.md (analysis table, biomass line, `meta` list, column examples, the cover fit argument-order exception); delete `decisions/transect-calibration-plan.md`
- [x] 7.5 Check the specs and reader docs against the code, then `openspec archive cover-calibration --yes`
