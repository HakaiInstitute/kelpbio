## 0. Stan source — full weight model (install-gated)

- [x] 0.1 Rewrite `inst/stan/weight.stan` to the full model: add `bDiameter2`; the site slope RE (`sSiteDiameter`, `z_bSiteDiameter`, `bSiteDiameter`); the site:year RE (`sSiteYear`, `z_bSiteYear` as `matrix[nSite, nYear]`, `bSiteYear`); add `nYear` and `year` to the data block; add the prior hyperparameters `prior_diameter2_mu/sd`, `prior_sd_site_diameter_rate`, `prior_sd_site_year_rate` and rename `prior_slope_*` → `prior_diameter_*`; expand the `typical`/`marginal` generated quantities to draw all three random effects. Keep the `prior_only` guard and `nObs == 0` support.
- [ ] 0.2 **Checkpoint:** `devtools::install()` to recompile (`load_all()` does not pick up Stan changes; first compile is slow). Confirm `rstan::sampling(stanmodels$weight, ...)` returns a stanfit exposing the new parameters.

## 1. Dependencies and shared scaffolding

- [x] 1.1 Add Imports to `DESCRIPTION`: chk, cli, rlang, posterior, newdata, generics, universals, ggplot2, tibble, dplyr
- [x] 1.2 Set up `R/params.R` as the `@inheritParams` donor for shared args (`data`, `species`, `priors`, `prior_only`, `chains`, `iter`, `nthin`, `cores`, `quiet`, `conf_level`, `estimate`, `sig_fig`, `by`, `uncertainty`)
- [x] 1.3 Re-export the broom/universals generics (`tidy`, `glance`, `augment`, `converged`, `samples`, `rhat`, `ess`, `nobs`, `nchains`, `niters`, `npars`, `nterms`, `pars`)

## 2. Data (pure)

- [x] 2.1 `R/kb_check_data_weight.R` — chk validation of `diameter`, `weight`, `site`, `year` (+ cli errors); 1:1 test with snapshot of the cli messages
- [x] 2.2 `data-raw/kb_data_weight.R` — build a small simulated/anonymized dataset spanning multiple sites and years (include at least one missing site-year cell to exercise the marginal path); `usethis::use_data(kb_data_weight)`; test it passes `kb_check_data_weight()`

## 3. Priors (pure)

- [x] 3.1 `R/kb_prior_normal.R`, `R/kb_prior_exponential.R` — constructors + chk validation + print methods (snapshot prints)
- [x] 3.2 `R/kb_priors_weight.R` — named default list (`intercept` = `normal(0,2)`, `diameter` = `normal(2,1)`, `diameter2` = `normal(0,0.5)`, `sd_site`/`sd_site_diameter`/`sd_site_year`/`sd_residual` = `exponential(1)`); tests for structure/defaults

## 4. Prior + data assembly (pure — highest bug density)

- [x] 4.1 `R/resolve_priors.R` — merge overrides into defaults; validate names ⊆ defaults, family match (class equality), hyperparameter ranges; cli on mismatch; full unit tests
- [x] 4.2 `R/assemble_stan_data.R` — map the seven resolved priors + data to the Stan data list (all `prior_*` hyperparameters, `nObs`, `nSite`, `nYear`, integer `site` and `year`, `weight`, `log(diameter/30)`, `prior_only`); unit tests including `nObs == 0` and a missing site-year cell

## 5. Fitting (install-gated)

- [x] 5.1 `R/kb_fit_weight.R` — wire pure helpers + single `rstan::sampling()` (translate `iter`/warmup/`nthin`, `cores` parallel, `quiet`); `new_kb_fit_weight()` constructor that extracts draws via `posterior` (keep `bWeight30`, `bDiameter`, `bDiameter2`, `sSite`, `sSiteDiameter`, `sSiteYear`, `sWeight`, `bSite`, `bSiteDiameter`, `bSiteYear`), captures diagnostics + stancode, discards the stanfit; returns `c("kb_fit_weight","kb_fit")`
- [x] 5.2 Layer-3 test (`skip_on_cran`): a real fit on tiny data returns a correctly-structured object (classes, draws present, stanfit absent); a `prior_only = TRUE` fit ignores the data

## 6. Test fixtures

- [x] 6.1 `tests/testthat/fixtures/make-fixtures.R` — build a tiny seeded `weight_fit.rds` via `rstan::sampling(seed = ...)` against the full model (multiple sites and years so `by = "site"`/`c("site","year")` are exercised); header documents: requires `devtools::install()`, re-run on Stan change
- [x] 6.2 `tests/testthat/helper-fixtures.R` — load the fixture(s) and any custom expectations

## 7. Summaries and diagnostics (on fixture)

- [ ] 7.1 `R/samples.R` (returns a `posterior` `draws_rvars`) + `R/accessors.R` (`rhat`/`ess`/`nobs`/`nchains`/`niters`/`npars`/`nterms`/`pars`, computed from the stored draws via `posterior`) + `R/kb_stancode.R`
- [ ] 7.2 `R/tidy.R`, `R/coef.R`, `R/glance.R` (thresholds `rhat`/`ess`), `R/converged.R`
- [ ] 7.3 `R/augment.R` (`.fitted`/`.resid`/`.lower`/`.upper`, full precision) and `R/print.R` (stable metadata, snapshot)
- [ ] 7.4 Tests: structure + invariants for numeric output; snapshot prints/messages only

## 8. Predictions (on fixture)

- [ ] 8.1 `R/kb_predictions.R` — `kb_predictions` subclass constructor + metadata attributes + `print` method
- [ ] 8.2 `R/kb_predict_weight.R` — `posterior` `rvar` typical/marginal computation over the three random effects (site intercept, site slope, site:year) per `docs/predictions.md`: observed-level (index the effect `rvar`) for factors in `by`, `rvar_rng` hyperprior draw under `marginal` / zero under `typical` for omitted factors; `by`/`uncertainty` axes (arg_match) with the valid set `NULL`/`"site"`/`c("site","year")`; reject `by = "year"` (no year main effect) and the marginal-requires-omitted-RE guard (`by = c("site","year")` under marginal errors); auto-sequence via `newdata::xnew_data` when `new_data = NULL` (fixed `log(diameter/30)` transform, no rescale); `kb_predict_weight_samples()` returns the grid tibble with a `.prediction` `rvar` column; the summary is `median` + `conf_level` interval over that column (one codepath)
- [ ] 8.3 Tests (invariants): lower ≤ estimate ≤ upper; weight > 0; marginal width ≥ typical (for `by = NULL` and `by = "site"`); wider `conf_level` → wider interval; `by = "site"` yields one curve per site and `c("site","year")` one per site-year; `by = c("site","year")` + marginal errors; `by = "year"` errors; `new_data = NULL` spans observed range; `kb_predictions` metadata present

## 9. Plotting (on fixture)

- [ ] 9.1 `R/kb_plot_predictions.R` — ggplot from `kb_predictions`; ribbon for continuous predictor; metadata-driven `x`/`style`/`facet` with overrides + graceful fallback; optional `observed` overlay
- [ ] 9.2 Tests: structure assertions (ggplot class, layers, mappings) + a sparse `vdiffr` doppelganger

## 10. Documentation and check

- [ ] 10.1 roxygen for all exports (plain-language `marginal`/`typical`); a prior-predictive example (`prior_only = TRUE` → predict → plot)
- [ ] 10.2 `devtools::document()`; `R CMD check` clean; confirm 1:1 test mirroring
