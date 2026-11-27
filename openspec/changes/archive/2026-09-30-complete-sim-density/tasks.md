## 1. Data

- [x] 1.1 Drop the unrecorded site-years from `data-raw/data_weight_sim_nereo.R` and its documentation
- [x] 1.2 Rebuild `data_weight_sim_nereo` (no MCMC)

## 2. Fits (MCMC, confirm first)

- [x] 2.1 Refit `fit_weight_sim_nereo` and `tests/testthat/fixtures/weight_fit.rds` (`Rscript scripts/build.R --fits`)

## 3. Tests and docs

- [x] 3.1 Tests that relied on an unrecorded site-year in the fixture construct one instead; the dataset test checks density is complete
- [x] 3.2 `scripts/demo-api-test.R` shows density in the main section
- [x] 3.3 Run the tests and leave any snapshot changes for review
- [x] 3.4 `openspec archive complete-sim-density --yes`
