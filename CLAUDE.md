# CLAUDE.md — kelpbio

R package for Bayesian kelp biomass estimation. All exported functions use the `kb_` prefix.

## Key Reference Locations

| Resource | Path |
|----------|------|
| Analysis project (final models + Stan code) | `~/Analyses/poissonconsulting/hakai-kelp-biomass-25/` |
| Reference package architecture | `~/Code/poissonconsulting/bboutools/` |
| Package API design | `docs/package-design.md` |
| S3 generic inventory (which generic, from which package) | `docs/generics.md` |
| Prediction / derived-quantity engine (posterior `rvar`) | `docs/predictions.md` |
| Bayesian engine (rstan/rstantools) | `docs/bayesian-engine.md` |
| API design rationale + bboutools divergences | `docs/bboutools-api-review.md` |
| Testing strategy | `docs/testing-strategy.md` |
| Initial implementation scope | `docs/vertical-slice.md` |

When implementing any feature, read the corresponding analysis project script and Stan file first. The analysis project contains the final, validated model code that kelpbio adapts.

## Analysis Project Structure

The analysis project uses `embr`/`cmdstanr`. kelpbio re-implements the same models using `rstan`/`rstantools` (pre-compiled Stan, no cmdstan required at runtime). Key analysis scripts:

| Topic | Model script | Stan file |
|-------|-------------|-----------|
| Weight (allometric) | `models-weight-nereo.R` | `stan/nereo/weight/weight-nereo.stan` |
| Size (distribution) | `models-size-nereo.R` | `stan/nereo/size/size-nereo.stan` |
| Density | `models-density-nereo.R` | `stan/nereo/density/density-nereo.stan` |
| Blade fraction | `models-blade-frac-nereo.R` | `stan/nereo/blade/blade-frac-nereo.stan` |
| Wet/dry | `models-wetdry-nereo.R` | `stan/nereo/wetdry/wetdry-nereo.stan` |
| Carbon | `models-carbon-nereo.R` | `stan/nereo/carbon/carbon-nereo.stan` |

kelpbio works at **site-year resolution — no month dimension** (the analysis models' month effects are dropped). Biomass combines all six models via **size-integration** (`density × E_size[weight(diameter)] × ratios`), not `density × weight`; see `docs/package-design.md` §Derived Predictions. wetdry/carbon become intercept-only Beta (no REs) once month is dropped.

## Bayesian Engine

- **Backend**: `rstan` + `rstantools`. Stan models live in `inst/stan/` and are pre-compiled at `R CMD INSTALL` time.
- **No cmdstan**: users do not need `cmdstanr` or a separate Stan installation.
- **Sampling**: `rstan::sampling(stanmodels$<name>, data = stan_data, chains = 4, adapt_delta = 0.95, thin = nthin, ...)`
- **`devtools::load_all()` does not work** for Stan changes — always use `devtools::install()`.
- See `docs/bayesian-engine.md` for full details including Stan file conventions, priors-as-data pattern, and structural flags.

## Stan Model Adaptations (analysis project → kelpbio)

The analysis project Stan models require these adaptations for kelpbio:

1. **Priors as data** — analysis models hard-code priors; kelpbio passes all prior hyperparameters through the `data` block so users can adjust them via `kb_priors_*()`.
2. **Column naming** — analysis uses CamelCase (`SbulbMax`, `PlantW`, `Site`, `Year`); kelpbio uses snake_case (`diameter`, `weight`, `site`, `year`).

## OOP Pattern (S3, following bboutools)

```r
# Construction (internal only)
# Store EXTRACTED posterior draws, NOT the live stanfit (portable, small,
# rstan-version-robust; makes pre-fit models a non-special case).
fit <- list(draws = <posterior draws>, diagnostics = <sampler diag>, data = data, meta = meta)
class(fit) <- c("kb_fit_weight", "kb_fit")

# S3 methods dispatch to parent by default
augment.kb_fit    # all subclasses
tidy.kb_fit_weight  # subclass-specific
```

Access via `$`: `x$draws`, `x$data`, `x$meta`. `samples(x)` returns a `posterior` `draws_rvars` object. The live `stanfit` is discarded after fitting — see `docs/package-design.md` §Data & model storage. Single package (R-universe, not CRAN): demo + coastwide data + slim pre-fit models in `data/`; no companion data package.

**Prediction / derived-quantity engine.** Predictions, summaries, and the biomass composition are computed from the stored draws with the `posterior` `rvar` datatype (per-model prediction is plain `rvar` arithmetic); grids built with `newdata::xnew_data` (no `rescale`); `coef`/`tidy`/`glance`/`augment`/`samples`/diagnostics reconstructed from the draws via `posterior`. `docs/predictions.md` is the authoritative spec — read it before touching any `kb_predict_*`, summary, or biomass code.

## Package Conventions

- **Prefix**: all exported functions use `kb_`
- **Validation**: all exported function arguments validated with `chk`; user-facing messages via `cli`
- **Documentation**: roxygen2 with markdown; `@inheritParams` for shared parameters
- **Writing** (docs, README, vignettes, roxygen, PR/commit text): follow the writing style in `~/.claude/CLAUDE.md`; in particular no em-dashes or en-dashes (use hyphens, commas, or colons) and no mid-sentence bold for emphasis; concise technical register
- **File layout**: one function per file, file named after the function (`kb_fit_weight()` → `R/kb_fit_weight.R`). S3 methods grouped one file per generic, named after the generic (`R/print.R` holds all `print.*` methods, `R/tidy.R` all `tidy.*`, etc.). Internal helpers in clearly-named files, never a catch-all `utils.R`.
- **Testing**: testthat 3e; strict 1:1 test mirroring (`R/<name>.R` ↔ `tests/testthat/test-<name>.R`). Test the wrapper, not the model's numbers. Snapshot print methods + messages; NEVER snapshot MCMC numerics (test structure + invariants instead). Small pre-built fits in `tests/testthat/fixtures/` (built with `rstan::sampling(seed=)`, not `set.seed`); slow end-to-end fits `skip_on_cran()`. Factor pure logic (data/prior assembly) out of fit functions for MCMC-free testing. See `docs/testing-strategy.md`.
- **Code style**: tidyverse; no lubridate, reshape2, plyr, or data.table
- **No `library()` calls** in package code; use `@importFrom` or `pkg::fun()`
- **Do not run Stan MCMC** during a session without confirming first; fitting is slow
