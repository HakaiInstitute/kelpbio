> Note: tasks 0-10 were implemented against the original (broom-flavoured, rvar-`_samples`) design.
> This change realigns the surface to the `generics`/`stats`/`base`/`universals`/`rstantools` generics
> and the house vocabulary (see `docs/generics.md`). Items reopened below (`[ ]`) need rework; pure
> helpers unaffected by the realignment stay `[x]`.

## 0. Stan source — full weight model (install-gated)

- [x] 0.1 `inst/stan/weight.stan`: define the mean `log_eWeight` **once** in `transformed parameters`; replace the dead `typical`/`marginal` generated quantities with `log_lik[i] = student_t_lpdf(log_weight[i] | nu, log_eWeight[i], sWeight)` and `yrep[i] = exp(student_t_rng(nu, log_eWeight[i], sWeight))` (both reuse `log_eWeight`; loops are no-ops when `nObs == 0`). Keep priors-as-data, the `prior_only` guard, and all parameters.
- [x] 0.2 **Checkpoint:** `devtools::install()` to recompile; confirm `rstan::sampling(stanmodels$weight, ...)` returns a stanfit exposing the parameters plus `log_lik` and `yrep`.

## 1. Dependencies and shared scaffolding

- [x] 1.1 `DESCRIPTION` Imports: add `rstantools`; keep chk, cli, rlang, posterior, newdata, generics, universals, ggplot2, tibble, dplyr. Add `loo` and `bayesplot` to Suggests (for the `loo`/`pp_check` examples).
- [x] 1.2 `R/params.R` donor: rename `iter` → `niters`; ensure `estimate`, `sig_fig`, `conf_level`, `by`, `uncertainty`, `rhat`, `esr`, `include_random_effects` are documented.
- [x] 1.3 Re-export generics: `generics` (`tidy`/`glance`/`augment`), `universals` (`converged`/`rhat`/`esr`/`npars`/`nterms`/`nchains`/`niters`/`pars`/`estimates`), `rstantools` (`posterior_epred`/`posterior_linpred`/`posterior_predict`/`log_lik`/`prior_summary`), `ggplot2` (`autoplot`); kelpbio's own `samples`. Drop the bespoke `ess` generic (use `universals::esr`).

## 2. Data (pure)

- [x] 2.1 `R/kb_check_data_weight.R` — rewrite with `chk` validators (bboudata conventions): `chk_superset` for columns, `chk_character_or_factor` for `site`/`year`, `chk_numeric` + positivity for `diameter`/`weight`, `chk_not_any_na`; column-qualified messages. Update test (snapshot the chk errors).
- [x] 2.2 `data-raw/kb_data_weight.R` — simulated dataset spanning sites/years incl. a missing site-year cell (still valid).

## 3. Priors (pure) — unchanged

- [x] 3.1 `R/kb_prior_normal.R`, `R/kb_prior_exponential.R` — constructors + chk + print.
- [x] 3.2 `R/kb_priors_weight.R` — named default list.

## 4. Prior + data assembly (pure) — unchanged

- [x] 4.1 `R/resolve_priors.R`
- [x] 4.2 `R/assemble_stan_data.R`

## 5. Fitting (install-gated)

- [x] 5.1 `R/kb_fit_weight.R` — rename `iter` → `niters` (saved draws/chain; translate to rstan `iter`/`warmup`/`thin`); `quiet = FALSE` default that shows sampling progress (`refresh`) but suppresses other Stan messages and the HMC diagnostic warnings via a local `withCallingHandlers` (no global option). `new_kb_fit_weight()` additionally keeps the `log_lik` and `yrep` draws.
- [x] 5.2 Layer-3 test (`skip_on_cran`): correctly-structured object incl. `log_lik`/`yrep` draws; `niters(fit)` equals `niters`; `prior_only = TRUE` ignores data.

## 6. Test fixtures

- [x] 6.1 Rebuild `tests/testthat/fixtures/weight_fit.rds` against the recompiled model (now carrying `log_lik`/`yrep`).
- [x] 6.2 `tests/testthat/helper-fixtures.R`

## 7. Summaries and diagnostics (on fixture)

- [x] 7.1 `R/summarise.R` — shared draws-summariser producing `term`/`estimate`/`lower`/`upper` (empirical `quantile2`, `estimate` fn, `sig_fig` rounding). `R/samples.R` + `R/accessors.R` (`rhat`, **`esr`** = `ess_bulk/ndraws`, `nobs`, `nchains`, `niters`, `npars`, `nterms`, `pars`, `estimates`) + `R/kb_stancode.R`.
- [x] 7.2 `R/tidy.R` (`term`/`estimate`/`lower`/`upper`; args `conf_level`/`estimate`/`sig_fig`/`include_random_effects`), `R/coef.R` (pure wrapper on `tidy`), `R/glance.R` (columns `n,K,nchains,niters,nthin,ess,rhat,converged`), `R/converged.R` (`rhat`/`esr` thresholds, defaults `1.05`/`0.1`).
- [x] 7.3 `R/augment.R` (`fitted`/`residual`/`lower`/`upper`, no dot prefix, full precision, via `.weight_linpred`), `R/print.R` (stable metadata, snapshot), `R/summary.R` (classed `summary_kb_fit` + print).
- [x] 7.4 Tests: structure + invariants; snapshot prints/messages only; assert house column names.

## 8. Prediction engine + generics (on fixture)

- [x] 8.1 `R/weight_linpred.R` — internal `.weight_linpred(fit, newdata, by, uncertainty)` returning an `rvar` (log scale): observed-level for factors in `by`, `rvar_rng` hyperprior draw (`marginal`) / zero (`typical`) for omitted factors; valid `by` set `NULL`/`"site"`/`c("site","year")`; reject `by = "year"`; marginal-requires-omitted-RE guard; `newdata::xnew_data` when `new_data = NULL` (fixed `log(diameter/30)`, no rescale).
- [x] 8.2 `R/posterior_linpred.R`/`R/posterior_epred.R`/`R/posterior_predict.R`/`R/log_lik.R`/`R/prior_summary.R` — thin faces over `.weight_linpred` (matrix `D x N`); `posterior_predict` adds Student-t noise and returns stored `yrep` when `newdata = NULL`; `log_lik` returns the stored pointwise matrix.
- [x] 8.3 `R/kb_predictions.R` (subclass + metadata attrs + print) and `R/kb_predict_weight.R` (summariser over `posterior_epred`; `kb_predictions` with `estimate`/`lower`/`upper`). Remove `kb_predict_weight_samples()`. `R/predict.R` — `predict.kb_fit_weight` wraps `kb_predict_weight`.
- [x] 8.4 Tests (invariants): lower ≤ estimate ≤ upper; weight > 0; marginal width ≥ typical; wider `conf_level` → wider interval; `by = "site"` one curve per site, `c("site","year")` one per site-year; marginal + `c("site","year")` errors; `by = "year"` errors; `new_data = NULL` spans observed range; `posterior_epred`/`posterior_predict` return `D x N`; `log_lik` feeds `loo::loo`.

## 9. Plotting (on fixture)

- [x] 9.1 `R/kb_plot_predictions.R` (unchanged contract) + `R/autoplot.R` — `autoplot.kb_predictions` wraps it (dispatch on the data frame, never a fit).
- [x] 9.2 Tests: structure assertions + sparse `vdiffr`; `autoplot` equals `kb_plot_predictions`.

## 10. Documentation and check

- [x] 10.1 roxygen for all exports (plain-language `marginal`/`typical`); a prior-predictive example; a `pp_check`/`loo` demonstration in a vignette; ensure `docs/generics.md` matches the implemented surface.
- [x] 10.2 `devtools::document()`; `R CMD check` clean; confirm 1:1 test mirroring.
