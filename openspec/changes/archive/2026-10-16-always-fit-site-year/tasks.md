## 1. Fitting layer

- [x] 1.1 Reduce `site_year_structure()` to the aliasing check (renamed `site_year_aliasing()`), returning the aliased main effects only; single-year data alias with site, and with year too when there is one site
- [x] 1.2 Drop the omission message from `notify_site_year()`, keeping the aliasing warning
- [x] 1.3 In the six weight, size, and density `kb_fit_*()` functions, stop passing a site:year switch to data assembly and parameter selection, and record the site:year effect as present in the fit
- [x] 1.4 Remove the `site_year_on` argument from the six `assemble_*_data()` helpers and `site_year_off()` from `R/fit_parameters.R` if nothing else uses it; keep the R-side site:year record that the cover biomass models set to absent
- [x] 1.5 Update the roxygen of the six fit functions (the "site:year effect is set from the data" paragraph) and `kb_model_describe()` (the dropped-effect example); run `devtools::document()`

## 2. Tests (MCMC-free)

- [x] 2.1 Replace the single-year omission tests in `test-site_year_structure.R` and the six `test-kb_fit_*.R` files with single-year aliasing-warning tests, including one site in one year naming both effects
- [x] 2.2 Update the `test-assemble_*_data.R` tests for the removed argument
- [x] 2.3 Keep the omitted-site:year tests in `test-linpred.R`, `test-summary.R`, `test-kb_model_describe.R`, and `test-structural_flags.R` working through the cover biomass path or a fit without the effect, since prediction and summary code still handle a model with none

## 3. Stan models

- [x] 3.1 Remove the `site_year_on` data flag from `weight_nereo`, `weight_macro`, `size_nereo`, `size_macro`, `density_nereo`, and `density_macro`, adding the site:year term unconditionally
- [x] 3.2 Run `rstantools::rstan_config()`, then `devtools::install()` (checkpoint: Stan edits are not picked up by `load_all()`)

## 4. Pre-fits and fixtures

- [x] 4.1 Rebuild with `Rscript scripts/build.R --fits=weight,size,density` (confirm with the user before running; MCMC)
- [x] 4.2 Run the tests; report snapshot changes (Stan code in `kb_stancode()`, `kb_model_describe()`, print) and leave the `.new` files for review, without accepting them

## 5. Evidence and close-out

- [x] 5.1 Keep the simulation scripts and outputs out of the package history (git-ignored side analysis)
- [x] 5.2 Check the specs and reader docs against the code, then `openspec archive always-fit-site-year --yes`
