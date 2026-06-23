## Why

With the rstan/rstantools engine and the compiled `stanmodels$weight` in place (Change A `scaffold-rstan-package`), kelpbio needs its first end-to-end user-facing pipeline. This change delivers the full weight-model vertical slice — data validation, structured priors, fitting, model summaries/diagnostics, predictions, and plotting — establishing the package's S3 architecture and conventions that every later model will reuse. See `docs/package-design.md`, `docs/vertical-slice.md`, and `docs/testing-strategy.md`.

## What Changes

- Add `kb_check_data_weight()` (chk validation of `diameter`, `weight`, `site`, `year`) and bundle a small `kb_data_weight` dataset (simulated/anonymized until data permission is confirmed).
- Add the structured prior surface: `kb_prior_normal()` / `kb_prior_exponential()` constructors (self-validating, self-printing) and `kb_priors_weight()` returning the named default prior list.
- Add `kb_fit_weight()`: fits `stanmodels$weight`, supports `prior_only` and zero-observation fits, and returns a `c("kb_fit_weight", "kb_fit")` object that stores **extracted posterior draws (not the stanfit)** + diagnostics + data + meta.
- Add the model-summary surface as S3 methods on `kb_fit`: `print`, `tidy`, `glance`, `augment`, `converged`, `samples`, `coef`; the `universals` accessors (`rhat`, `ess`, `nobs`, `nchains`, `niters`, `npars`, `nterms`, `pars`); and `kb_stancode()`.
- Add `kb_predict_weight()` and `kb_predict_weight_samples()` — allometric curves over `new_data` (auto-sequence when NULL) with the `by` and `uncertainty = c("marginal","typical")` axes, computed R-side from the stored draws; the summary returns a `kb_predictions` tibble subclass carrying column-role metadata.
- Add `kb_plot_predictions()` — a composable ggplot built from a `kb_predictions` object (ribbon for the continuous predictor), inferring x/style/facet from metadata, with an optional `observed` overlay.
- Establish the testthat fixture workflow (`tests/testthat/fixtures/make-fixtures.R` + `helper-fixtures.R`) so downstream methods are tested without re-sampling.

## Capabilities

### New Capabilities
- `data`: weight-data validation (`kb_check_data_weight`) and the bundled `kb_data_weight` dataset contract.
- `priors`: structured prior objects (`kb_prior_normal`, `kb_prior_exponential`) and the weight default priors (`kb_priors_weight`).
- `fitting`: `kb_fit_weight()` — the fit contract, the draws-not-stanfit `kb_fit` object, `prior_only`/zero-obs support, and the sampler arguments.
- `summaries`: S3 model-summary and diagnostic surface over `kb_fit` (broom generics, `converged`/`samples`, accessors, `kb_stancode`).
- `predictions`: `kb_predict_weight()` / `kb_predict_weight_samples()` and the `kb_predictions` object (the `by`/`uncertainty`/`new_data` behavior, computed R-side from draws).
- `plotting`: `kb_plot_predictions()` — metadata-driven ggplot from a `kb_predictions` object.

### Modified Capabilities
<!-- none — stan-engine (Change A) ships the complete weight.stan, including the
     typical/marginal generated quantities; this change adds R code only and does
     not modify the Stan source. -->

## Impact

- **New R files** (one function per file; S3 methods grouped per generic): `R/kb_check_data_weight.R`, `R/kb_prior_normal.R`, `R/kb_prior_exponential.R`, `R/kb_priors_weight.R`, `R/kb_fit_weight.R`, `R/print.R`, `R/tidy.R`, `R/glance.R`, `R/augment.R`, `R/coef.R`, `R/converged.R`, `R/samples.R`, `R/accessors.R`, `R/kb_stancode.R`, `R/kb_predict_weight.R`, `R/kb_predictions.R`, `R/kb_plot_predictions.R`, plus internal helpers `R/resolve_priors.R`, `R/assemble_stan_data.R`, and the `params.R` `@inheritParams` donor.
- **DESCRIPTION** gains Imports: chk, cli, rlang, posterior, generics, universals, ggplot2, tibble, dplyr (and the existing rstan stack).
- **Data**: new `data/kb_data_weight.rda` + `data-raw/kb_data_weight.R`.
- **Tests**: 1:1 mirrored test files; `tests/testthat/fixtures/` with `make-fixtures.R` + a committed slim `weight_fit.rds`; `helper-fixtures.R`.
- **Docs**: roxygen for all exports (plain-language `marginal`/`typical`); a prior-predictive example.
- **Out of scope**: all other models (size, density, blade, wetdry, carbon), the biomass pipeline, pre-fit `kb_default_*` models, and any Stan source changes.
