## Why

The weight model is species-explicit and the fitting engine is species-agnostic after `namespace-weight-by-species` and `add-weight-model`, but only *Nereocystis luetkeana* (nereo) is implemented. `decisions/species-as-variant.md` prescribes that a second species is additive: a new `.stan`, a new fit wrapper, its own priors and data validator, and a per-species linear-predictor builder, with the model-level methods branching on `meta$species` only where the linear predictor or likelihood genuinely differ. This change lands *Macrocystis pyrifera* (macro) as that second species for the weight model.

The macro weight model is structurally different from nereo (this is why species is a variant, not a data argument). Nereo is Student-t on a quadratic in centred log-diameter with a site intercept, a site slope, and a site:year effect. Macro is a Gamma GLM: the response is calibrated against a frond count rather than a sub-bulb diameter, the mean is log-linear in centred log-fronds (no quadratic, no site slope), the model carries a standalone year main effect in addition to site and site:year, and dispersion comes from a per-frond Gamma shape (`alpha`) whose compound-sum structure (`shape = alpha * fronds`) reproduces size-dependent heteroscedasticity rather than a residual SD. See `design.md` for the full nereo-vs-macro diff and the note that the committed analysis Stan (`stan/macro/weight/weight-macro.stan`), not the analysis design doc, is the source of truth for the ported model.

## What Changes

- New `inst/stan/weight_macro.stan` (Gamma likelihood; mean `exp(bWeight + bSite + bFronds * log_fronds + bYear + site_year_on * bSiteYear)`; shape `alpha * fronds`, rate `shape / eWeight`; priors-as-data; `prior_only` guard; `log_lik` and `yrep` generated quantities). `stanmodels` grows to `c("weight_nereo", "weight_macro")`.
- New public fit function `kb_fit_weight_macro(data, priors, prior_only, chains, niters, nthin, cores, progress, ...)` delegating mechanics to the shared `fit_stan()` engine and returning class `c("kb_fit_weight", "kb_fit")` with `meta$species = "macrocystis"`.
- New `kb_priors_weight_macro()` (entries `intercept`, `fronds`, `shape`, `sd_site`, `sd_year`, `sd_site_year`) and `kb_check_data_weight_macro()` (required columns `fronds`, `weight`, `site`, `year`; `fronds` a positive whole number, `weight` positive).
- New internal `.weight_macro_linpred()` (log-scale mean builder, sibling of `.weight_nereo_linpred()`). The model-level linpred entry points, the `posterior_*` generics, `kb_predict_weight()`/`kb_predict_weight_by()`, `tidy`, `residuals`, and the summary descriptor branch on `meta$species`.
- Bundled simulated macro objects: `data_weight_sim_macro`, `fit_weight_sim_macro`; matching test fixtures.
- The predictor column name enters the package as `fronds`; the response stays `weight` (shared with nereo for the biomass composition).

## Capabilities

### New Capabilities

<!-- none: this extends existing capabilities with a second species -->

### Modified Capabilities

- `fitting`: adds `kb_fit_weight_macro()` (Gamma, log-fronds linear, year main effect), sharing the `kb_fit_weight`/`kb_fit` object contract.
- `priors`: adds `kb_priors_weight_macro()` with the macro parameter set.
- `data`: adds `kb_check_data_weight_macro()` and the bundled `data_weight_sim_macro` / `fit_weight_sim_macro` objects.
- `stan-engine`: adds `inst/stan/weight_macro.stan`; `stanmodels` exposes `weight_macro`.
- `predictions`: the linpred, `posterior_*` generics, and `kb_predict_weight`/`kb_predict_weight_by` dispatch on `meta$species`; macro uses the `fronds` predictor, exposes `by = "year"` (a real year main effect exists), and `posterior_predict` adds Gamma observation noise.
- `summaries`: `tidy`, `residuals`, and the summary/print descriptor branch on `meta$species` (macro term list, Gamma deviance residuals, Gamma family string).
- `plotting`: axis labelling reads the predictor name from the fit (`fronds` for macro).
- `website`: `_pkgdown.yml` lists the new macro reference topics.

## Impact

- New `R/kb_fit_weight_macro.R`, `R/kb_priors_weight_macro.R`, `R/kb_check_data_weight_macro.R`, `R/assemble_weight_macro_data.R`, `R/weight_macro_linpred.R`, `R/data_weight_sim_macro.R`, `R/fit_weight_sim_macro.R`, and their 1:1 test files.
- `inst/stan/weight_macro.stan` triggers an rstantools recompile (`devtools::install()`); `R/stanmodels.R` and `src/stanExports_*` regenerated.
- Species branches added to `R/weight_nereo_linpred.R` entry points (or a small dispatch shim), `R/tidy.R`, `R/residuals.R`, `R/posterior_predict.R`, `R/summary.R` (`fit_descriptor`), and `R/kb_predict_weight*.R` (predictor name, `by = "year"` validity). `meta$predictor` / `meta$response` added to both species so grid/label code stays species-agnostic.
- `.chk_kb_fit_weight()` / `.chk_kb_fit()` hints broadened to name both fit functions. `.vld_/.chk_new_data_weight_macro` added.
- New `data-raw/` scripts and bundled `.rda`; new fixtures and `make-fixtures.R` / `make-sim-data.R` / `helper-fixtures.R` updates.
- Specs, README, vignette, `_pkgdown.yml`, and demos updated; snapshots for print/summary/check extended with the macro fit.

## Non-goals

- The other five models (size, density, blade, wetdry, carbon), for either species.
- The coastwide pre-fit macro weight object shipped in `kelpbiodata`; this change ships only the slim simulated `fit_weight_sim_macro`.
- The biomass composition (`kb_predict_biomass()`), which requires all six macro fits.
- Any change to nereo model behaviour or the shared fit-object contract; the nereo touches are additive metadata (`meta$predictor`/`meta$response`) and the species branches, which leave existing nereo output unchanged.