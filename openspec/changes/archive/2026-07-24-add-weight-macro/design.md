## Context

This change adds the second species to the weight model. The cross-cutting rationale (why species is a structural variant, why per-function + per-`.stan`, why the S3 class stays model-level and methods branch on `meta$species`) lives in `decisions/species-as-variant.md`. The `namespace-weight-by-species` change already split out the species-agnostic engine (`fit_stan()`), made the nereo surface species-explicit, and named the nereo builder `.weight_nereo_linpred()` so `.weight_macro_linpred()` is the obvious sibling. This file captures the rationale specific to porting the macro model and to the species branches it forces.

## Source of truth: committed Stan, not the design doc

The analysis project holds both a design doc (`docs/weight-macro-model-design.md`, Student-t on log-weight with a quadratic and a random site slope) and a committed, fitted model (`stan/macro/weight/weight-macro.stan` + `models-weight-macro.R`, a Gamma GLM). They disagree: the analyst evolved the model from the doc toward a mechanistic Gamma compound-sum form. The committed Stan is what was fit and validated, so it is the source of truth for this port. The doc is stale for the "Model Specification" section only; its motivation (frond count is the universally measured field variable for Macrocystis, so weight is calibrated against frond count rather than reconstructed from length) still holds.

## Nereo vs macro (what the port must change)

| Aspect | nereo (implemented) | macro (this change) |
|------------------------|------------------------|------------------------|
| Predictor | `diameter` (mm), centred `log(diameter) - log(diameter_ref)` | `fronds` (count), centred `log(fronds) - log(fronds_ref)` |
| Response | `weight` (kg), modelled on log scale | `weight` (kg), modelled on natural scale |
| Likelihood | Student-t(nu = 4) on log-weight, residual SD `sWeight` | Gamma, `shape = alpha * fronds`, `rate = shape / eWeight` |
| Mean form | quadratic, with random site slope | log-linear, no quadratic, no site slope |
| Fixed effects | `bWeight`, `bDiameter`, `bDiameter2` | `bWeight`, `bFronds` |
| Random effects | `bSite`, `bSiteDiameter`, `bSiteYear` | `bSite`, `bYear`, `bSiteYear` |
| Dispersion | `sWeight ~ Exp(1)` | `alpha ~ Exp(0.1)` (per-frond Gamma shape) |
| Slope prior | `bDiameter ~ N(2, 1)` | `bFronds ~ N(1, 0.5)` |
| gq draw | `exp(student_t_rng(nu, mean, sWeight))` | `gamma_rng(shape, rate)` |

## Decisions specific to this change

### Keep the year main effect

Macro keeps the committed model's standalone `bYear` main effect (`sYear ~ Exp(1)`) in addition to site and site:year. This departs from the nereo weight model, which deliberately omits a year main effect because at site-year resolution a shared annual shift is confounded with within-season survey date (`decisions/`/project memory). The departure is intentional: the macro model was fit and validated with `bYear` in the analysis project, and porting the validated model verbatim takes precedence over cross-species uniformity of the random-effect set. The user-visible consequence is that `by = "year"` is a valid grouping for `kb_predict_weight_by()` on a macro fit (a year main effect exists to condition on), whereas it errors for nereo. This is the one place the two species diverge in the prediction API surface, and the `by = "year"` error message is therefore species-specific.

### Predictor is `fronds`; response stays `weight`

The kelpbio macro predictor column is `fronds` (a positive whole count; the analysis `fronds_1m` = distinct fronds \>= 1 m with recorded biomass). The `1m` protocol detail lives in the roxygen/data docs, not the column name, matching nereo's plain `diameter`. The response column stays `weight` (identical to nereo) so the eventual biomass composition and the shared summariser need no per-species response name.

To keep the model-level prediction and plotting code species-agnostic, the fit `meta` gains `predictor` (`"diameter"` / `"fronds"`) and `response` (`"weight"`), set by each wrapper. Grid building (`kb_predict_weight_by()` diameter/fronds sequence), the `new_data` column check, and the plot axis label read `meta$predictor` instead of hard-coding `"diameter"`. This is the only nereo touch that changes nereo internals, and it is invisible in nereo output.

### Reference centring: geometric mean of fronds

Following the nereo `diameter_ref` treatment, macro centres log-fronds at the geometric mean of the observed `fronds`, passed to Stan as `fronds_ref` and stored in `meta$fronds_ref`, with a fallback of 5 (the analysis reference and the macro median) for empty / prior-only data. Centring decorrelates the intercept and slope; storing the fit-time reference makes new-data predictions use the same transform.

### Linpred returns the log-scale mean for both species

`.weight_macro_linpred()` returns `log(eWeight)` (the linear predictor on the log scale), the same contract as `.weight_nereo_linpred()`. This lets the shared faces reuse the nereo path: `posterior_linpred()` returns the log-scale mean and `posterior_epred()` exponentiates. For macro the exponential is exact (`E[weight] = eWeight = exp(linpred)` for the Gamma mean); for nereo it remains the existing median-of-log-normal treatment. Only the pieces that are genuinely Gamma-specific escape this shared path:

- `posterior_predict()` observation noise: macro draws `gamma_rng(alpha * fronds, alpha * fronds / eWeight)` (needs `fronds` and `alpha` per row), where nereo adds Student-t noise. Branches on `meta$species`.
- `residuals()`: macro uses Gamma deviance residuals (`extras::res_gamma`-equivalent from `shape`/`rate`), nereo uses Student-t. Branches on `meta$species`.
- `log_lik()`: unchanged, read from the stored Stan `log_lik` (already species-agnostic).

### Random-effect resolution: standalone year

Nereo's linpred helpers resolve a site RE (intercept + slope) and a site:year RE. Macro adds a standalone year RE (`bYear`) that the `new_levels` / `representative_site` machinery must handle as a third factor: conditioned on its estimate for a known year, drawn from `Normal(0, sYear)` under `new_levels = "sample"`, held at zero under `"average"`, for `kb_predict_weight_by()`; resolved per row for the `posterior_*` generics. `representative_site` for macro borrows only the `bSite` intercept (macro has no site slope), a natural consequence of the effect set, not a special case.

### Constructor and metadata

`new_kb_fit_weight()` stays model-level and species-agnostic. Macro passes its own `meta_extra` (`fronds_ref`, `predictor = "fronds"`, `response = "weight"`, `site_year_on`, no `nu`) and its own `param_vars` (`bWeight`, `bFronds`, `alpha`, `sSite`, `sYear`, `sSiteYear`, `bSite`, `bYear`, `bSiteYear`); `gq_vars` stays `c("log_lik", "yrep")`. The Gamma shape `alpha` is a sampled parameter, not metadata.

### No coastwide pre-fit here

Consistent with nereo and `openspec/config.yaml`, kelpbio ships only the simulated `data_weight_sim_macro` and a slim simulated `fit_weight_sim_macro`. The real coastwide macro weight fit ships in `kelpbiodata`. The simulated data generator reproduces the macro structure (Gamma compound-sum, log-linear log-fronds, site + year + site:year), so the bundled fit and fixtures exercise the full macro path without any confidential data.

## Testing approach

Mirror the nereo test set 1:1 for the new files. Test the wrapper and the species dispatch, not the MCMC numbers: assert the fit object structure and `meta$species`, that the macro term list appears in `tidy()`, that `posterior_predict()` returns positive Gamma draws, that `by = "year"` is accepted for macro and rejected for nereo, and that `posterior_epred`/`augment` agree at the observed data. Snapshot only the print/summary header (Gamma family string) and the `kb_check_data_weight_macro()` cli errors. The small pre-built macro fixture is built with `rstan::sampling(seed = )`; slow end-to-end fits use `skip_on_cran()`.

## Build checkpoints

The `.stan` addition is install-gated: `rstantools::rstan_config()` then `devtools::install()` recompiles and regenerates `R/stanmodels.R` / `src/stanExports_*`. `devtools::load_all()` does not pick up the new model. Two MCMC checkpoints (the recompile smoke test and building the bundled fit / fixture) need explicit confirmation before running, per the project rule not to run Stan sampling unprompted.