## 1. Model

- [x] 1.1 `inst/stan/nitrogen.stan`, `assemble_nitrogen_data()`, `nitrogen_fraction()`, the data check, priors, and fits for both species, mirroring carbon.
- [x] 1.2 The internal methods (`.linpred`, `.epred`, `.obs_family`, `.chk_new_data`, `.model_spec`), `predict()`, `kb_predict_nitrogen()`, and the plausibility warning.

## 2. Derived measure

- [x] 2.1 `nitrogen` and `measure = "nitrogen"` in the three derived verbs, `measure_factor()`, `derived_response()`, the measure checks, and the plot labels.

## 3. Data, fits, docs, tests

- [x] 3.1 Simulated datasets; pre-fit and fixture scripts; `_pkgdown.yml`; roxygen.
- [x] 3.2 Tests mirroring carbon, and nitrogen cases in the shared tests.
- [x] 3.3 `rstantools::rstan_config()`; `Rscript scripts/build.R --fits=nitrogen`; rebuild once more so the install has the pre-fits; review snapshots.
- [x] 3.4 `openspec archive add-nitrogen --yes`.
