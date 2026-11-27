No Stan, data, or fit-object changes: no `rstan_config()`, `install()`, or
`--fits`. `load_all()` is sufficient throughout.

## 1. Log prior

- [x] 1.1 Add an internal `log_prior()` summing, per draw, each fitted term's prior (`meta$priors[[term]]`) at its draws, with the density chosen by prior class (Normal, Exponential, lognormal)
- [x] 1.2 Test it against hand-computed sums, including the lognormal cover slope and an omitted term, and that every fitted term of every model has a prior entry of its name

## 2. priorsense integration

- [x] 2.1 Add priorsense to Suggests
- [x] 2.2 Add `create_priorsense_data.kb_fit()` registered with `@exportS3Method priorsense::create_priorsense_data`: fitted-term draws, the log prior, and `log_lik()` as a draws array with the fit's chains
- [x] 2.3 Add the `.vld_sensitivity_fit()` / `.chk_sensitivity_fit()` pair refusing prior-only and zero-observation fits
- [x] 2.4 Test (skip if priorsense absent) that `powerscale_sensitivity()` and a plot function run on a fixture of each model

## 3. `kb_sensitivity()`

- [x] 3.1 Add `R/kb_sensitivity.R`: `check_dots_empty()`, `.chk_kb_fit()`, threshold validation, `rlang::check_installed("priorsense")`, the sensitivity-fit check, then columns `term`, `prior_cjs`, `likelihood_cjs`, `weak_prior`, `strong_data`
- [x] 3.2 Roxygen for a first-time reader: one-line description, `@details` on the flag combinations and that each term is its prior entry, `@return`, example on a bundled pre-fit
- [x] 3.3 Add `tests/testthat/test-kb_sensitivity.R`: structure for every model, terms are prior entries, agreement with `powerscale_sensitivity()`, thresholds, omitted effects, error snapshots

## 4. Docs and archive

- [x] 4.1 Add `kb_sensitivity` and `create_priorsense_data.kb_fit` to `_pkgdown.yml`; add calls to the demo script
- [x] 4.2 `devtools::document()`; run the full test suite; report new snapshot files for review
- [x] 4.3 Check the delta spec and roxygen against the code; archive the change
