## 1. Pure density helpers

- [x] 1.1 `R/density_structure.R`: `density_structure(data)` returning the per site-year recorded density (named, keyed `"site:year"`), `on`, `mean`, `sd` (over rows with a recorded site-year value), and the count of unrecorded site-years; plus `notify_density()` for the two informational messages (suppressed by `progress = "none"`, silent when there is no `density` column)
- [x] 1.2 `R/standardised_density.R`: `standardised_density(grid, on, mean, sd, levels)` applying the supplied, then recorded, then mean rule; returns 0 where the rule falls through, and a zero vector when `on` is `FALSE`
- [x] 1.3 `kb_check_data_weight_nereo()`: optional `density` column (numeric, `NA` allowed, `>= 0`, at most one distinct non-missing value per site-year, naming a conflicting site-year)
- [x] 1.4 `.vld_new_data_weight_nereo()` / `.chk_new_data_weight_nereo()`: validate an optional `density` column in `new_data` (numeric, `>= 0`, `NA` allowed)
- [x] 1.5 `kb_priors_weight_nereo()`: add `density = kb_prior_normal(0, 0.5)`

## 2. Stan model (install-gated)

- [x] 2.1 `inst/stan/weight_nereo.stan`: `density_on` flag, standardised `density` data vector, `prior_density_mu`/`prior_density_sd`, `bDensity` parameter, `density_on * bDensity * density` in `log_alpha`
- [x] 2.2 `assemble_weight_nereo_data()`: pass `density` (via `standardised_density()`), `density_on`, and the density prior fields
- [x] 2.3 CHECKPOINT: `devtools::document()`, `rstantools::rstan_config()`, `devtools::install()`

## 3. Fitting and prediction

- [x] 3.1 `kb_fit_weight_nereo()`: call `density_structure()` / `notify_density()`, add `bDensity` to `param_vars` and (when on) `meta$terms$fixed`, record `density_on`, `density_mean`, `density_sd`, `density_levels` in `meta_extra`
- [x] 3.2 `.linpred.kb_fit_weight_nereo()`: add `draws$bDensity * standardised_density(...)` to `log_alpha` when `meta$density_on` is `TRUE` (missing flag read as `FALSE`)
- [x] 3.3 `kb_model_describe()`: density term, standardisation line with the stored mean and SD, `bDensity` prior, and a prose sentence, all only when on

## 4. Data and fits (MCMC, confirm before running)

- [x] 4.1 `data-raw/data_weight_sim_nereo.R`: site-year density (lognormal), true effect near the analysis estimate per SD, a few site-years recorded as `NA`; regenerate `data_weight_sim_nereo`
- [x] 4.2 Rebuild `fit_weight_sim_nereo` and the nereo test fixture (the macro objects are unchanged)

## 5. Tests

- [x] 5.1 `test-density_structure.R`, `test-standardised_density.R`: on/off cases, partial NA, single value, row NA inside a recorded site-year, resolution order
- [x] 5.2 `test-kb_check_data_weight_nereo.R`: optional column, negative value, conflicting site-year
- [x] 5.3 `test-assemble_weight_nereo_data.R`, `test-kb_priors_weight_nereo.R`, `test-stanmodels.R`: new data fields and prior entry
- [x] 5.4 `test-kb_fit_weight_nereo.R`: messages and `meta` fields (MCMC-free where possible via the helpers)
- [x] 5.5 `test-linpred.R`: density shifts `log(alpha)` by `bDensity * standardised density`; ignored when off; fitted site-year uses its recorded value; unknown site-year uses the mean
- [x] 5.6 `test-tidy.R`, `test-kb_model_describe.R`: `bDensity` present only when on; run the suite and leave `.new` snapshots for review

## 6. Docs and completion

- [x] 6.1 Roxygen: `kb_fit_weight_nereo()` (density term, optional column), `kb_check_data_weight_nereo()`, `kb_priors_weight_nereo()`, `kb_predict_weight()` / `kb_predict_weight_by()` `new_data` and curve density, `data_weight_sim_nereo`
- [x] 6.2 Vignette and README: mention the optional density column
- [x] 6.3 `decisions/architecture.md`: add density to the weight model description
- [ ] 6.4 Drift check (specs vs code, reader docs vs code), then archive the change in this PR
