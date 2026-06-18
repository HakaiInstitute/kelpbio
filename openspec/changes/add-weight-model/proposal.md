## Why

With the rstan/rstantools engine and the compiled `stanmodels$weight` in place (Change A `scaffold-rstan-package`), kelpbio needs its first end-to-end user-facing pipeline. This change delivers the full weight model end to end -- data validation, structured priors, fitting, model summaries/diagnostics, predictions, and plotting -- establishing the package's S3 architecture and conventions that every later model will reuse. The model is the validated analysis-project allometry: a quadratic log-diameter mean with site intercept, site slope, and site:year random effects under a Student-t(4) likelihood (it supersedes the site-intercept-only smoke-test that Change A shipped to prove the engine). See `docs/package-design.md` (model catalogue), `docs/vertical-slice.md`, and `docs/testing-strategy.md`.

## What Changes

- Expand `inst/stan/weight.stan` from the site-intercept-only smoke-test to the full allometric model: add `bDiameter2` (quadratic log-diameter term), the site slope random effect (`bSiteDiameter`/`sSiteDiameter`), and the site:year random effect (`bSiteYear`/`sSiteYear`, which reintroduces the `year` dimension), keeping priors-as-data, the `prior_only`/zero-obs guards, and the `typical`/`marginal` generated quantities (now drawing all three random effects).
- Add `kb_check_data_weight()` (chk validation of `diameter`, `weight`, `site`, `year`) and bundle a small `kb_data_weight` dataset (simulated/anonymized until data permission is confirmed).
- Add the structured prior surface: `kb_prior_normal()` / `kb_prior_exponential()` constructors (self-validating, self-printing) and `kb_priors_weight()` returning the named default prior list -- now seven entries: `intercept`, `diameter`, `diameter2`, `sd_site`, `sd_site_diameter`, `sd_site_year`, `sd_residual`.
- Add `kb_fit_weight()`: fits `stanmodels$weight`, supports `prior_only` and zero-observation fits, and returns a `c("kb_fit_weight", "kb_fit")` object that stores **extracted posterior draws (not the stanfit)** + diagnostics + data + meta.
- Add the model-summary surface as S3 methods on `kb_fit`: `print`, `tidy`, `glance`, `augment`, `converged`, `samples`, `coef`; the `universals` accessors (`rhat`, `ess`, `nobs`, `nchains`, `niters`, `npars`, `nterms`, `pars`); and `kb_stancode()`.
- Add `kb_predict_weight()` and `kb_predict_weight_samples()` — allometric curves over `new_data` (auto-sequence when NULL) with the `by` and `uncertainty = c("marginal","typical")` axes, computed R-side from the stored draws; the summary returns a `kb_predictions` tibble subclass carrying column-role metadata. With three random effects across two grouping factors, the available `by` values are `NULL`, `"site"`, and `c("site","year")`, and `marginal` draws whichever of site intercept, site slope, and site:year `by` does not condition on.
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
- `stan-engine`: `inst/stan/weight.stan` is expanded from the site-intercept-only smoke-test (shipped by Change A to prove the engine) to the full allometric model -- new parameters (`bDiameter2`, `sSiteDiameter`, `sSiteYear`, and the `bSiteDiameter`/`bSiteYear` random effects), the `year` index in the data block, the additional prior hyperparameters, and the expanded `typical`/`marginal` generated quantities.

## Impact

- **New R files** (one function per file; S3 methods grouped per generic): `R/kb_check_data_weight.R`, `R/kb_prior_normal.R`, `R/kb_prior_exponential.R`, `R/kb_priors_weight.R`, `R/kb_fit_weight.R`, `R/print.R`, `R/tidy.R`, `R/glance.R`, `R/augment.R`, `R/coef.R`, `R/converged.R`, `R/samples.R`, `R/accessors.R`, `R/kb_stancode.R`, `R/kb_predict_weight.R`, `R/kb_predictions.R`, `R/kb_plot_predictions.R`, plus internal helpers `R/resolve_priors.R`, `R/assemble_stan_data.R`, and the `params.R` `@inheritParams` donor.
- **DESCRIPTION** gains Imports: chk, cli, rlang, posterior, generics, universals, ggplot2, tibble, dplyr (and the existing rstan stack).
- **Data**: new `data/kb_data_weight.rda` + `data-raw/kb_data_weight.R`.
- **Tests**: 1:1 mirrored test files; `tests/testthat/fixtures/` with `make-fixtures.R` + a committed slim `weight_fit.rds`; `helper-fixtures.R`.
- **Docs**: roxygen for all exports (plain-language `marginal`/`typical`); a prior-predictive example.
- **Stan source**: `inst/stan/weight.stan` rewritten to the full model (requires `devtools::install()` to recompile; `load_all()` does not pick up Stan changes).
- **Out of scope**: all other models (size, density, blade, wetdry, carbon), the biomass pipeline, and the pre-fit `kb_default_*` models.
