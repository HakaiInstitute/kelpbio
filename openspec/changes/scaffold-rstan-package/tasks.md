## 1. rstantools scaffold

- [ ] 1.1 Commit current package state (clean rollback point before the scaffold rewrite)
- [ ] 1.2 Run `rstantools::rstan_create_package(auto_config = TRUE)` over the existing package directory
- [ ] 1.3 Reconcile generated `DESCRIPTION` with the existing stub: keep the author/ORCID, set a real Title + Description, set a license (`usethis::use_*_license()`)
- [ ] 1.4 Confirm `DESCRIPTION` Imports (Rcpp, RcppParallel, rstan, rstantools) and LinkingTo (BH, Rcpp, RcppEigen, RcppParallel, StanHeaders, rstan); pin `rstan (>= 2.32.0)` and `StanHeaders (>= 2.32.0)`
- [ ] 1.5 Confirm `NAMESPACE`/`R/kelpbio-package.R` has `useDynLib(kelpbio, .registration = TRUE)` and the required rstan imports
- [ ] 1.6 Verify generated build files exist and are executable: `configure`, `configure.win`, `src/Makevars`, `src/Makevars.win`, `R/stanmodels.R`
- [ ] 1.7 Commit the reconciled scaffold

## 2. Weight smoke-test Stan model

- [ ] 2.1 Write `inst/stan/weight.stan`: site-intercept-only allometric model — `data` block with `int<lower=0> nObs`, `nsite`, `site[]`, `weight[]`, `diameter[]` (or precomputed `log_diameter`), priors-as-data (`prior_intercept_mu/sd`, `prior_slope_mu/sd`, `prior_sd_site_rate`, `prior_sd_residual_rate`), and `int<lower=0,upper=1> prior_only`
- [ ] 2.2 Parameters/transformed parameters: `bWeight30`, `bDiameter`, `sSite`, `sWeight`, non-centered `z_bSite`; `bSite = z_bSite * sSite`; linear predictor `bWeight30 + bSite[site] + bDiameter * log(diameter/30)`
- [ ] 2.3 Model block: priors from the data hyperparameters; Student-t(df=4) likelihood guarded by `if (!prior_only)` (no-op when `nObs == 0`)
- [ ] 2.4 `generated quantities`: `typical` (REs zeroed) and `marginal` (`normal_rng(0, sSite)`) terms on the observed grid
- [ ] 2.5 Confirm filename/convention rules (snake_case, no dashes/spaces/leading digits)

## 3. Build and smoke-test (install checkpoint — NOT load_all)

- [ ] 3.1 `devtools::install()` succeeds (budget 10-20 min first compile)
- [ ] 3.2 Confirm `kelpbio::stanmodels$weight` loads as a compiled `stanmodel`
- [ ] 3.3 Smoke-test: `rstan::sampling(kelpbio::stanmodels$weight, data = <minimal valid list>)` returns a `stanfit` with `bWeight30`, `bDiameter`, `sSite`, `sWeight`, `bSite`
- [ ] 3.4 Smoke-test prior-only path: a fit with `prior_only = 1` (and `nObs = 0`) samples without error
- [ ] 3.5 Add a `skip_on_cran()` testthat test under `tests/testthat/` that asserts `stanmodels$weight` exists and samples (structure only — no MCMC-number assertions)

## 4. CI and docs

- [ ] 4.1 Add `.github/workflows/R-CMD-check.yaml` (macOS/Linux/Windows) using `r-lib/actions/setup-r-dependencies@v2` + `check-r-package@v2`, with package-library caching keyed on the DESCRIPTION hash
- [ ] 4.2 Confirm CI is green on all three platforms
- [ ] 4.3 Record the actual first-install timing in `docs/bayesian-engine.md` (§11)
- [ ] 4.4 Add platform/install notes to README (C++17 toolchain, rstan getting-started link, `devtools::install()` not `load_all()` for Stan changes)
