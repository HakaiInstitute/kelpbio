## 1. Rename the fit object (no refit)

- [x] 1.1 Re-save `data/fit_weight_hakai_nereo.rda` as `data/fit_weight_sim_nereo.rda` from the existing object (no MCMC); delete the old `.rda`.
- [x] 1.2 Rename `R/`, `man/`, `data-raw/`, and `tests/testthat/` fit files to `*_sim_nereo` and update their content.

## 2. Remove the real Hakai data

- [x] 2.1 Delete `data/`, `R/`, `man/`, `data-raw/`, and `tests/testthat/` files for `data_weight_hakai_nereo`.

## 3. Repoint references

- [x] 3.1 Swap `fit_weight_hakai_nereo` -> `fit_weight_sim_nereo` and `data_weight_hakai_nereo` -> `data_weight_sim_nereo` across R `@examples`, `man/`, both demo scripts, and the vignette; drop dangling `@family` links; rewrite the sim doc `@seealso`; fix stale demo prose.

## 4. Spec

- [x] 4.1 MODIFY the `data` spec "Bundled weight dataset" requirement (this delta) and sync into `openspec/specs/data/spec.md`; fix the stale `data_weight_hakai_nereo` example reference in `openspec/specs/plotting/spec.md`.

## 5. Verify

- [x] 5.1 `grep` shows no `hakai_nereo` in `R/`, `man/`, `scripts/`, `tests/`, `vignettes/`, `data-raw/`; `devtools::load_all()` + run the data/fit/predict tests.
