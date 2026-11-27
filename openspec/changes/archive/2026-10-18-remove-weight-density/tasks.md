## 1. Pure code

- [x] 1.1 Remove `R/density_structure.R`, `R/standardised_density.R`, and their tests and snapshots
- [x] 1.2 `kb_check_data_weight_nereo()`, `.vld_`/`.chk_` new-data checks, `column_units()`, `warn.R`: drop `stipes_m2`
- [x] 1.3 `kb_priors_weight_nereo()`: drop `density_slope`
- [x] 1.4 `.linpred.kb_fit_weight_nereo()`, prediction paths, `kb_new_data()`, `structural_flags.R`: drop the density term and flag
- [x] 1.5 `kb_predict_plot_biomass()`, `plot_biomass_grid()`, `mean_plant_weight()`: drop the observed density passed to the weight fit
- [x] 1.6 `kb_model_describe()`: drop the density term, standardisation, and prose

## 2. Stan model (install-gated)

- [x] 2.1 `inst/stan/weight_nereo.stan`: drop `density`, `density_on`, `density_slope`, and its prior fields
- [x] 2.2 `assemble_weight_nereo_data()`, `kb_fit_weight_nereo()`: drop the density data, flag, meta fields, and messages
- [x] 2.3 CHECKPOINT: `rstantools::rstan_config()`, `devtools::document()`, `devtools::install()`

## 3. Data and fits (MCMC, confirm before running)

- [x] 3.1 `data-raw/data_sim_nereo.R`: drop `stipes_m2` from the weight data and the density effect from the simulated weights; regenerate
- [x] 3.2 Rebuild the *Nereocystis* weight pre-fit and fixture (`--fits=weight`) and the objects composed from them

## 4. Tests and docs

- [x] 4.1 Remove density cases from the tests; run the suite and leave `.new` snapshots for review
- [x] 4.2 Roxygen, README, vignette, `decisions/`, `CLAUDE.md`, demo scripts: remove density covariate references
- [x] 4.3 Drift check (specs vs code, reader docs vs code), then archive the change in this PR
