## 1. Pure helpers

- [x] 1.1 `log_lik_`/`res_`/`ran_hurdle_gamma()` in `distributions.R`, with the Bernoulli terms on the log-odds scale; remove the censored Normal helpers
- [x] 1.2 `survey_weight_cv()` in place of `survey_biomass_sd()`; `presence_logit()`; `.presence_on()`
- [x] 1.3 Cover family: Gamma, or hurdle Gamma with the presence part
- [x] 1.4 `.epred()` takes the grid; the cover method multiplies by the presence probability; canopy totals use `mu`
- [x] 1.5 `warn_presence_separation()`; `.chk_occupied_survey()` errors when no covered survey has plants
- [x] 1.6 Priors: drop `sd_residual`, add `presence_intercept` and `presence_cover_slope`, widen the *Nereocystis* floor prior
- [x] 1.7 Model description, roxygen, demo script, `decisions/parameter-naming.md`

## 2. Stan (install-gated)

- [x] 2.1 `inst/stan/cover_calibration.stan`: Gamma with CV, presence part behind `presence_on`
- [x] 2.2 Data assembly passes `weight_cv` and `presence_on`; the fit sets the flag from the data and drops the presence terms when off
- [x] 2.3 `Rscript scripts/build.R --fits=cover_calibration` (`rstan_config()`, `devtools::install()`, refit of the pre-fits and fixtures, tests)

## 3. Data

- [x] 3.1 `data_in_situ_sim_nereo`: the empty survey's plot gets 5% cover, above the lowest occupied plots

## 4. Done

- [x] 4.1 Tests pass; snapshot diffs reported for review
- [x] 4.2 `jarl check .`
- [x] 4.3 Archive the change
