# Tasks

Order: pure helpers before install-gated Stan steps; MCMC checkpoints (marked **\[confirm\]**) need explicit sign-off before running.

## 1. Pure helpers (no recompile)

- [x] 1.1 `R/kb_priors_weight_macro.R` — default named prior list: `intercept =     kb_prior_normal(0, 2)`, `fronds = kb_prior_normal(1, 0.5)`, `shape =     kb_prior_exponential(0.1)`, `sd_site = kb_prior_exponential(1)`, `sd_year =     kb_prior_exponential(1)`, `sd_site_year = kb_prior_exponential(1)`. Mirror `kb_priors_weight_nereo()` structure and roxygen.
- [ ] 1.2 `R/vld.R` + `R/chk.R` — add `.vld_new_data_weight_macro()` (data frame with a `fronds` column) and its `.chk_` partner; broaden the `.chk_kb_fit_weight()` / `.chk_kb_fit()` hints to name both `kb_fit_weight_nereo` and `kb_fit_weight_macro`.
- [ ] 1.3 `R/kb_check_data_weight_macro.R` — required columns `fronds`, `weight`, `site`, `year`; `fronds` a positive whole number (count), `weight` numeric positive, `site`/`year` character-or-factor, no NAs; column-qualified cli messages. 1:1 test + snapshot.
- [ ] 1.4 `R/assemble_weight_macro_data.R` — map data + resolved macro priors to the Stan data block; add `weight_fronds_ref()` (geometric mean of observed `fronds`, fallback 5). Emit `nObs`, `nSite`, `nYear`, `site`, `year`, `fronds`, `weight`, `fronds_ref`, every `prior_*` scalar, `prior_only`, `site_year_on`. 1:1 test.
- [ ] 1.5 Add `meta$predictor` / `meta$response` to `new_kb_fit_weight()` inputs and set them from each wrapper (nereo: `"diameter"`/`"weight"`; macro: `"fronds"`/`"weight"`). No behaviour change for nereo output.

## 2. Prediction / linpred (pure, on fixture)

- [ ] 2.1 `R/weight_macro_linpred.R` — `.weight_macro_linpred()` returning the log-scale mean `bWeight + bSite + bFronds * log_fronds + bYear +     site_year_on * bSiteYear`; `.weight_macro_linpred_obs()`. Reuse the shared RE-resolution helpers, extended to a standalone `year` factor (`bYear`) and to a site intercept without a slope.
- [ ] 2.2 Species dispatch at the model-level entry points: `weight_data_linpred` / `weight_by_linpred` route to the nereo or macro builder on `meta$species`; `kb_predict_weight()` / `kb_predict_weight_by()` read `meta$predictor` for the `new_data` column check, grid variable, and valid `by` set (macro allows `"year"`; nereo does not).
- [ ] 2.3 `R/posterior_predict.R` — macro branch draws Gamma noise (`gamma_rng(alpha * fronds, alpha * fronds / eWeight)`); nereo unchanged.
- [ ] 2.4 `R/residuals.R` — macro branch computes Gamma deviance residuals from `shape`/`rate`; nereo unchanged.
- [ ] 2.5 `R/tidy.R` — macro term list (`bWeight`, `bFronds`, `alpha`, `sSite`, `sYear`, `sSiteYear`, and the per-level REs when `include_random_effects = TRUE`), branching on `meta$species`.
- [ ] 2.6 `R/summary.R` — `fit_descriptor()` macro branch: family string `"Gamma (shape proportional to fronds); response weight"`, fixed/random structure prose, group counts. `print`/`summary` header renders it.
- [ ] 2.7 `R/kb_plot_predictions.R` — axis label reads `meta$predictor`.

## 3. Stan source (install-gated)

- [ ] 3.1 `inst/stan/weight_macro.stan` — data (`nObs >= 0`, `nSite`, `nYear`, `site[]`, `year[]`, `fronds[]`, `weight[]`, `fronds_ref`; prior hyperparameters `prior_intercept_mu/sd`, `prior_fronds_mu/sd`, `prior_shape_rate`, `prior_sd_site_rate`, `prior_sd_year_rate`, `prior_sd_site_year_rate`; flags `prior_only`, `site_year_on`); transformed data `log_fronds = log(fronds) - log(fronds_ref)`; parameters `bWeight`, `bFronds`, `alpha`, `sSite`, `sYear`, `sSiteYear`, non-centred `z_bSite`, `z_bYear`, `z_bSiteYear`; transformed parameters scale the REs and define `log_eWeight` once, `eWeight = exp(log_eWeight)`; model normal + exponential priors, `std_normal()` z's, `weight ~ gamma(alpha .* fronds,     alpha .* fronds ./ eWeight)` guarded by `prior_only`; generated quantities `log_lik[i] = gamma_lpdf(...)` and `yrep[i] = gamma_rng(...)`, no-ops when `nObs == 0`.
- [ ] 3.2 **\[confirm\] Checkpoint:** `rstantools::rstan_config()` then `devtools::install()`; confirm `stanmodels$weight_macro` samples and exposes the parameters plus `log_lik` / `yrep`. `stanmodels` is now `c("weight_nereo", "weight_macro")`.
- [ ] 3.3 `R/kb_fit_weight_macro.R` — thin wrapper over `fit_stan()`: `kb_check_data_weight_macro()` -\> `kb_priors_weight_macro()` (resolve) -\> `assemble_weight_macro_data()` -\> `fit_stan(stanmodels$weight_macro, ...)` -\> `new_kb_fit_weight()` with macro `param_vars`, `gq_vars`, and `meta_extra` (`fronds_ref`, `predictor`, `response`, `site_year_on`, no `nu`, `species = "macrocystis"`). Class `c("kb_fit_weight", "kb_fit")`.

## 4. Data and fixtures (install-gated, MCMC)

- [ ] 4.1 `data-raw/data_weight_sim_macro.R` — simulate the macro structure (Gamma, log-linear log-fronds, site intercept + year + site:year, one missing site-year cell), `usethis::use_data()`.
- [ ] 4.2 `R/data_weight_sim_macro.R` — roxygen data-doc stub.
- [ ] 4.3 **\[confirm\]** `data-raw/fit_weight_sim_macro.R` — downsample + `kb_fit_weight_macro()` + `usethis::use_data()`; `R/fit_weight_sim_macro.R` doc stub.
- [ ] 4.4 **\[confirm\]** `tests/testthat/fixtures/make-sim-data.R` + `make-fixtures.R` — build `sim_weight_macro.rds` and `weight_macro_fit.rds` (`rstan::sampling(seed = )`); update `helper-fixtures.R`.

## 5. Tests

- [ ] 5.1 1:1 test files for every new `R/` file (`test-kb_fit_weight_macro.R`, `test-kb_priors_weight_macro.R`, `test-kb_check_data_weight_macro.R`, `test-assemble_weight_macro_data.R`, `test-weight_macro_linpred.R`, `test-data_weight_sim_macro.R`, `test-fit_weight_sim_macro.R`).
- [ ] 5.2 Extend the shared method tests with the macro fixture: `tidy` macro term list; `residuals` Gamma; `posterior_predict` positive draws; `posterior_epred`/`augment` agree at observed data; `by = "year"` accepted for macro and rejected for nereo; `print`/`summary` Gamma family snapshot; `kb_predict_weight` uses the `fronds` predictor.
- [ ] 5.3 `test-stanmodels.R` — add a macro `weight_stan_data()` + `stanmodels$weight_macro` sample (`skip_on_cran`).

## 6. Docs, specs, check

- [ ] 6.1 roxygen for all new exports (`@inheritParams` where shared); update README and the Get started vignette with a macro worked example against the bundled `fit_weight_sim_macro`.
- [ ] 6.2 `_pkgdown.yml` — add `kb_fit_weight_macro`, `kb_priors_weight_macro`, `kb_check_data_weight_macro`, `data_weight_sim_macro`, `fit_weight_sim_macro` to the reference index.
- [ ] 6.3 Sync the delta specs into `openspec/specs/` (fitting, priors, data, stan-engine, predictions, summaries, plotting, website); NEWS entry.
- [ ] 6.4 `devtools::document()`; drift check (specs vs code, reader docs vs code); `KELPBIO_FULL_CHECK=true Rscript scripts/build.R` clean; confirm 1:1 test mirroring.
- [ ] 6.5 Archive the change once CI is green and specs are synced.