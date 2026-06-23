## Context

The full API design is in `docs/package-design.md`; the slice scope is in `docs/vertical-slice.md`; the testing approach is in `docs/testing-strategy.md`. The rstan engine and compiled `stanmodels$weight` come from Change A. This change adds R code only — no Stan source changes. This doc captures only the mechanisms not already spelled out in the design docs.

## Goals / Non-Goals

**Goals:**
- End-to-end weight pipeline (validate → priors → fit → summarise → predict → plot) establishing the S3 architecture and conventions all later models reuse.
- Maximise MCMC-free testability: pure helpers carry the logic, one `rstan::sampling()` line is the only stochastic step, downstream methods test against a cached fixture.

**Non-Goals:**
- Any Stan source change (Change A owns `weight.stan`).
- Other models, the biomass pipeline, pre-fit `kb_default_*` models, the full weight model (quadratic / site:diameter / site:year).

## Decisions

- **Design for testability — factor the fit function.** `kb_fit_weight()` = `kb_check_data_weight()` → `resolve_priors()` → `assemble_stan_data()` → one `rstan::sampling()` call → `new_kb_fit_weight()` constructor. The first three and the constructor are pure and unit-tested without sampling (Layer 1); the sampling line is exercised by a few install-gated tests (Layer 3); everything downstream tests against a cached fixture (Layer 2).
- **(a) Draws, not stanfit.** The constructor runs `posterior::as_draws_*()` on the stanfit, keeps the parameters downstream methods need (`bWeight30`, `bDiameter`, `sSite`, `sWeight`, and per-site `bSite` — kept so `by = "site"` and `augment()` work), captures `rhat`/`ess`/divergences as plain numerics into `fit$diagnostics`, captures the Stan source into `fit$meta$stancode`, and lets the stanfit go out of scope. `fit = list(draws, diagnostics, data, meta)`, class `c("kb_fit_weight","kb_fit")`.
- **(b) Priors → data, pure.** Prior objects are tiny tagged lists (`kb_prior_normal(mean, sd)` → class `c("kb_prior_normal","kb_prior")`, etc.) validated at construction. `resolve_priors(priors, defaults)` NULL→defaults else merge keeping unspecified defaults; validate names ⊆ defaults, each entry's class == the default's class (family fixed at compile time → mismatch errors), hyperparameters in range. `assemble_stan_data()` maps `intercept`→`prior_intercept_mu/sd`, `diameter`→`prior_slope_mu/sd`, `sd_site`→`prior_sd_site_rate`, `sd_residual`→`prior_sd_residual_rate`, plus `nObs`, `nsite`, integer `site`, `weight`, `log(diameter/30)`, and `prior_only`.
- **(c) Predictions reconstructed R-side from draws.** The in-Stan generated quantities only cover the observed grid; arbitrary `new_data` curves are computed in R from the parameter draws. Per draw: `lp = bWeight30 + bDiameter * log(d/30)`. `typical` = `exp(lp)` (REs zeroed, the population-average mean curve). `marginal` (`by = NULL`) = `exp(lp + rnorm(0, sSite))` per draw (mirrors `normal_rng(0, sSite)`), wider by construction. `by = "site"` indexes the stored `bSite` draws (no draw). Enforce: `marginal` requires `by` to omit a random-effect factor — in the slice (only `site` exists) marginal is valid only with `by = NULL`. `kb_predict_weight_samples()` returns the `[draws × grid]` matrix as a draws container; `kb_predict_weight()` is the summariser over it (median + conf_level interval, rounded to `sig_fig`) — one codepath.
- **(d) `kb_predictions` subclass.** `structure(tbl, class = c("kb_predictions", class(tibble)))` with attributes `kb_predictor`, `kb_group_vars`, `kb_response`(+units). `kb_plot_predictions()` resolves NULL `x`/`style`/`facet` from these; falls back / errors helpfully if dplyr strips them.
- **File layout.** One function per file named after it; S3 methods grouped one file per generic (`R/print.R`, `R/tidy.R`, …). Shared args via the `params.R` `@inheritParams` donor.

## Risks / Trade-offs

- Custom-attribute loss on `kb_predictions` after dplyr verbs → plot args `x`/`facet` are real overrides; error message points to them.
- `iter` means *saved* post-warmup draws (warmup defaults to match) → the wrapper translates to rstan's `iter`/`warmup`/`thin`; unit-test that `niters(fit)` matches.
- Bundled-data permission unconfirmed → `kb_data_weight` is simulated/anonymized in `data-raw/` until cleared.
- Snapshotting MCMC numerics → forbidden by the testing strategy; snapshot only prints/messages, assert numeric output by structure + invariants.

## Migration Plan

Additive; depends on Change A being applied (compiled `stanmodels$weight`). No rollback complexity beyond removing the new R files/data.

## Open Questions

- None blocking. (`kb_predict_size`-style standalone reporting and other models are out of slice scope.)
