## Context

The full API design is in `docs/package-design.md` (model catalogue); the testing approach is in `docs/testing-strategy.md`. The rstan engine comes from Change A, which shipped `weight.stan` as a site-intercept-only smoke-test to prove the engine. This change expands that Stan source to the full validated allometry (quadratic mean; site intercept, site slope, and site:year random effects; Student-t(4)) and adds the R surface on top. This doc captures only the mechanisms not already spelled out in the design docs.

## Goals / Non-Goals

**Goals:**
- End-to-end weight pipeline (validate → priors → fit → summarise → predict → plot) establishing the S3 architecture and conventions all later models reuse.
- Maximise MCMC-free testability: pure helpers carry the logic, one `rstan::sampling()` line is the only stochastic step, downstream methods test against a cached fixture.

**Non-Goals:**
- Other models (size, density, blade, wetdry, carbon), the biomass pipeline, and the pre-fit `kb_default_*` models.
- Any prior-family change or user-facing random-effect toggle (the family is fixed at compile time; the RE structure is fixed per `docs/package-design.md`).

## Decisions

- **Design for testability — factor the fit function.** `kb_fit_weight()` = `kb_check_data_weight()` → `resolve_priors()` → `assemble_stan_data()` → one `rstan::sampling()` call → `new_kb_fit_weight()` constructor. The first three and the constructor are pure and unit-tested without sampling (Layer 1); the sampling line is exercised by a few install-gated tests (Layer 3); everything downstream tests against a cached fixture (Layer 2).
- **(a) Draws, not stanfit.** The constructor runs `posterior::as_draws_*()` on the stanfit, keeps the parameters downstream methods need — the fixed effects `bWeight30`, `bDiameter`, `bDiameter2`; the SDs `sSite`, `sSiteDiameter`, `sSiteYear`, `sWeight`; the per-site `bSite` and `bSiteDiameter`; and the site-by-year `bSiteYear` (the per-site and site:year draws are kept so `by = "site"` / `by = c("site","year")` and `augment()` can use observed levels) — captures `rhat`/`ess`/divergences as plain numerics into `fit$diagnostics`, captures the Stan source into `fit$meta$stancode`, and lets the stanfit go out of scope. `fit = list(draws, diagnostics, data, meta)`, class `c("kb_fit_weight","kb_fit")`.
- **(b) Priors → data, pure.** Prior objects are tiny tagged lists (`kb_prior_normal(mean, sd)` → class `c("kb_prior_normal","kb_prior")`, etc.) validated at construction. `resolve_priors(priors, defaults)` NULL→defaults else merge keeping unspecified defaults; validate names ⊆ defaults, each entry's class == the default's class (family fixed at compile time → mismatch errors), hyperparameters in range. `assemble_stan_data()` maps the seven prior entries to the Stan data block — `intercept`→`prior_intercept_mu/sd`, `diameter`→`prior_diameter_mu/sd`, `diameter2`→`prior_diameter2_mu/sd`, `sd_site`→`prior_sd_site_rate`, `sd_site_diameter`→`prior_sd_site_diameter_rate`, `sd_site_year`→`prior_sd_site_year_rate`, `sd_residual`→`prior_sd_residual_rate` — plus `nObs`, `nSite`, `nYear`, integer `site` and `year`, `weight`, `log(diameter/30)`, and `prior_only`. (The Stan slope hyperparameter is renamed `prior_slope_*` → `prior_diameter_*` to match the prior-list key now that there are two diameter terms.)
- **(c) Predictions via the `posterior` `rvar` engine.** The prediction, summary, and biomass-composition engine is specified in full in `docs/predictions.md` (draws exposed as `rvar`s; per-model prediction is `rvar` arithmetic; grids built with `newdata::xnew_data`; no rescaling; `_samples()` attaches the draws to the grid as an `rvar` column; `coef`/`tidy`/`glance`/`augment`/`samples`/diagnostics reconstructed from the draws via `posterior`). Weight-specific points only: the three random effects span two grouping factors (site intercept + site slope keyed on `site`; site:year keyed on `site`, `year`), so a factor in `by` uses its observed effect, an omitted factor is drawn (`marginal`) or zeroed (`typical`); `by = NULL` marginal draws all three, `by = "site"` marginal draws only site:year, `by = c("site","year")` conditions on everything (so `marginal` there errors), and `by = "year"` is rejected (no year main effect), leaving the valid set `NULL` / `"site"` / `c("site","year")`. The summary `kb_predict_weight()` is the summariser over `kb_predict_weight_samples()` — one codepath.
- **(d) `kb_predictions` subclass.** `structure(tbl, class = c("kb_predictions", class(tibble)))` with attributes `kb_predictor`, `kb_group_vars`, `kb_response`(+units). `kb_plot_predictions()` resolves NULL `x`/`style`/`facet` from these; falls back / errors helpfully if dplyr strips them.
- **File layout.** One function per file named after it; S3 methods grouped one file per generic (`R/print.R`, `R/tidy.R`, …). Shared args via the `params.R` `@inheritParams` donor.

## Risks / Trade-offs

- Custom-attribute loss on `kb_predictions` after dplyr verbs → plot args `x`/`facet` are real overrides; error message points to them.
- `iter` means *saved* post-warmup draws (warmup defaults to match) → the wrapper translates to rstan's `iter`/`warmup`/`thin`; unit-test that `niters(fit)` matches.
- Bundled-data permission unconfirmed → `kb_data_weight` is simulated/anonymized in `data-raw/` until cleared.
- Snapshotting MCMC numerics → forbidden by the testing strategy; snapshot only prints/messages, assert numeric output by structure + invariants.
- Stan source change → the full `weight.stan` must be recompiled with `devtools::install()` (not `load_all()`), and the `weight_fit.rds` fixture must be rebuilt against the new model before the Layer-2 method tests are valid.
- Site:year is fully crossed in Stan (`matrix[nSite, nYear]`) → for sparse designs (a year unobserved at a site) the corresponding `bSiteYear` cell is identified only by its prior; this is acceptable (it is the marginal draw) but the simulated `kb_data_weight` should exercise both observed and missing site-year cells.

## Migration Plan

Additive; depends on Change A being applied (compiled `stanmodels$weight`). No rollback complexity beyond removing the new R files/data.

## Open Questions

- None blocking. (`kb_predict_size`-style standalone reporting and other models are out of slice scope.)
