## 1. Warning

- [x] 1.1 In `R/warn.R`, replace `warn_tide_cap()`, `tide_cap_share()`, and `tide_cap_prior_share()` with one warning for rows with positive canopy and `canopy_tide_height_m` above 2 m, taking the row noun (survey or row) and naming the column and the 2 m threshold
- [x] 1.2 Call it in `R/fit_cover_calibration_model.R` (surveys), `R/kb_predict_cover_calibration.R` (when `new_data` is given), and `R/kb_predict_biomass_canopy.R` (rows)
- [x] 1.3 Update `TIDE_SLOPE_UPPER` and `R/tide.R` comments that refer to the warning, keeping the cap's comment for code readers

## 1b. Tide slope bound

- [x] 1b.1 Remove the upper bound on `tide_height_slope` in `inst/stan/cover_calibration.stan`, its data field and `TIDE_SLOPE_UPPER`, and render the prior as `T[0, ]` in `kb_model_describe()`
- [x] 1b.2 `rstantools::rstan_config()`, `devtools::install()` (install checkpoint), then `Rscript scripts/build.R --fits=cover_calibration`

## 2. Tests

- [x] 2.1 In `tests/testthat/test-warn.R`, replace the tide-limit and share tests with tests of the new warning: rows above 2 m with canopy warn, rows at 2 m, below, negative, or without canopy do not
- [x] 2.2 Update tide tests in the fit and prediction test files to the 2 m trigger (3.5 m and 5 m warn, 2 m does not), and replace the full-cover-past-the-limit expectation with a finiteness expectation
- [x] 2.3 Run `Rscript scripts/build.R`; report the `_snaps/warn.md` and `kb_model_describe` snapshot diffs and leave the `.new` files for review

## 3. Reader docs

- [x] 3.1 `vignettes/methods.Rmd`: replace the tide-limit paragraph with one sentence (correct to zero tide with the Timmer et al. 2024 slope, capped, fly at 2 m or below, warning above) and drop the past-the-limit clause from the formula text
- [x] 3.2 Roxygen of `kb_fit_cover_calibration_nereo()` and `kb_fit_cover_calibration_macro()`: state the 2 m warning in place of the tide-limit one
- [x] 3.3 `R/kb_model_describe.R`: drop the past-the-limit clause from the centering line and the prose
- [x] 3.4 Search reader docs for remaining "tide limit" or "one over the slope" wording (`grep -rn -i "tide limit"` over `R/`, `vignettes/`, `README.Rmd`, `openspec/specs/`)

## 4. Close

- [x] 4.1 `openspec validate simplify-tide-warning --strict`
- [x] 4.2 Archive with `openspec archive simplify-tide-warning --yes` before review of the `dev` to `main` pull request
