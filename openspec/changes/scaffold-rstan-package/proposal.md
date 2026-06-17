## Why

kelpbio is at usethis template stage with no Bayesian engine: there is no `src/`, `inst/stan/`, `configure`, or `R/stanmodels.R`. Every model in the package depends on a working rstan/rstantools build, and that build (first compile 10-20 min, C++17 toolchain, version coupling, Apple-Silicon fragility) is the single highest-risk, slowest-feedback part of the whole package. It must be stood up and proven on its own before any `kb_` API is layered on top.

This is Change A of the weight-model vertical slice; it delivers the build infrastructure only, validated end-to-end with one real (simplified) Stan model as the compile smoke-test. See `docs/bayesian-engine.md` and `docs/vertical-slice.md`.

## What Changes

- Convert the package to an rstan/rstantools package via `rstantools::rstan_create_package(auto_config = TRUE)`: add `src/` (`Makevars`/`Makevars.win`), `configure`/`configure.win`, `R/stanmodels.R`, and the Stan-stack dependencies and `useDynLib` directives. **BREAKING** to the current template scaffold (rewrites `DESCRIPTION`/`NAMESPACE`).
- Reconcile the generated `DESCRIPTION`/`NAMESPACE` with the existing stub (keep author/ORCID; set real Title/Description/license; pin `rstan` and `StanHeaders (>= 2.32.0)`).
- Add `inst/stan/weight.stan` as the compile smoke-test: a site-intercept-only allometric model following the priors-as-data, `prior_only`, and marginal/typical conventions (the real Stan source the weight model will use; the `kb_` wrapper around it is deferred to Change B).
- Verify the build end-to-end: `devtools::install()` succeeds and `kelpbio::stanmodels$weight` is samplable via `rstan::sampling()`.
- Add a GitHub Actions R-CMD-check workflow (macOS/Linux/Windows) with package-library caching; record the first-install timing in `docs/bayesian-engine.md`.

## Capabilities

### New Capabilities
- `stan-engine`: the rstan/rstantools build contract — Stan source under `inst/stan/` is pre-compiled at `R CMD INSTALL` and exposed as `stanmodels$<name>`; a compiled model is samplable via `rstan::sampling()`; the package declares the full Stan stack and `useDynLib`.

### Modified Capabilities
<!-- none — openspec/specs/ is empty; this is the first capability -->

## Impact

- **Build system**: new `src/`, `configure`(+`.win`), `R/stanmodels.R`; `DESCRIPTION` gains Imports (Rcpp, RcppParallel, rstan, rstantools) and LinkingTo (BH, Rcpp, RcppEigen, RcppParallel, StanHeaders, rstan); `NAMESPACE` gains `useDynLib` + rstan imports.
- **Stan source**: new `inst/stan/weight.stan` (+ any `inst/stan/include/`).
- **Install**: first `R CMD INSTALL` becomes slow (10-20 min); `devtools::load_all()` will not pick up Stan changes (use `devtools::install()`).
- **CI**: new `.github/workflows` R-CMD-check across platforms.
- **Out of scope (Change B)**: all `kb_` user-facing functions (`kb_fit_weight`, `kb_check_data_weight`, priors API, predictions, plotting) and any bundled `data/` datasets.
