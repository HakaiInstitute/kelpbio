No Stan or fit-structure change: no `rstan_config()`, `devtools::install()`
checkpoint, or `--fits` rebuild is needed.

## 1. Stan agreement guard (against the current code)

- [x] 1.1 Test helper that captures a fixture's Stan data by re-running its fit function with the sampler mocked, builds `chains = 0` stanfits with and without `prior_only`, and returns `lp_full - lp_prior` at a few random unconstrained parameter values via `rstan::log_prob()`, with a copy of the fit whose draws are those values from `rstan::constrain_pars()`
- [x] 1.2 In `test-log_lik.R`, for every fixture, check `rowSums(log_lik(fit)) - (lp_full - lp_prior)` is constant across draws; `skip_on_cran()`. Run it against the current code first so it guards the refactor

## 2. Family functions

- [x] 2.1 `ran_weibull()` in `R/weibull.R` and `ran_beta()` in `R/beta.R`, in the extras parameterisation, with tests
- [x] 2.2 `.family_fun(type, family)` in `R/obs_family.R`: an explicit table of `log_lik`, `res`, and `ran` for `lnorm`, `gamma`, `weibull`, `gamma_pois`, `gamma_pois_zi`, `gamma_pois_zt`, and `beta`; errors for an unknown family

## 3. Observation family

- [x] 3.1 `.obs_family()` generic with an aborting `.default`, and one method per model (wet/dry and carbon through one Beta-mean helper); cover biomass checks the grid's `lower` and `upper`
- [x] 3.2 `log_lik.kb_fit()`, `residuals.kb_fit()`, `augment.kb_fit()`, and `posterior_predict.kb_fit()` evaluate the family through `.per_draw()`
- [x] 3.3 Remove `.log_lik()`, `.deviance()`, `.add_noise()`, and their methods and Beta-mean helpers; update the aborting set in `test-abort.R`
- [x] 3.4 Tests in `test-obs_family.R`: every model's family resolves in the table, and each parameter from `pars()` has length 1 or N
- [x] 3.5 Port the per-model tests: likelihood and residual tests compare against the current values (the *Nereocystis* weight likelihood minus `log(weight_kg)`); predictive tests check support and reproducibility under a seed, not fixed values
- [x] 3.6 Run the tests; leave any changed snapshots (the abort snapshot) as `.new` files for review

## 4. Docs and archive

- [x] 4.1 `log_lik()` roxygen: values are the log density of the recorded response
- [x] 4.2 `decisions/architecture.md`, `decisions/species-as-variant.md`, and the fit-object section of `CLAUDE.md`: `.obs_family` in place of `.log_lik`, `.deviance`, and `.add_noise`
- [x] 4.3 Check the specs and reader docs against the code; `openspec archive unify-observation-family --yes`
