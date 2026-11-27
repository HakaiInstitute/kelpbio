No Stan change, so no `rstan_config()`. The fit structure changes for every model
with random effects, so section 4 rebuilds those pre-fits and fixtures (MCMC:
confirm with the user before running).

## 1. Package code (no refit)

- [x] 1.1 `#' @importFrom posterior rvar` in `R/kelpbio-package.R`; `devtools::document()`; test that `posterior` is among kelpbio's namespace imports
- [x] 1.2 `warn_group_names()`, like `warn_implausible_units()`: the data checks warn naming `site` or `year` and the values containing `,`, `[`, or `]`; message snapshot; no warning for spaces
- [x] 1.3 `new_kb_fit()` rebuilds `bSite`, `bYear`, and `bSiteYear` with `dimnames` from `meta$site_levels` and `meta$year_levels` (only those present in the draws), and the diagnostics summary is computed after; confirm the level order matches the Stan indices in every `assemble_*_data()`
- [x] 1.4 Tests for 1.3 on constructed draws and a relabelled fixture (no sampling): named indexing, positional indexing unchanged, `as_draws_df()` names, `tidy(include_random_effects = TRUE)` terms

## 2. Simulation scripts

- [x] 2.1 Invented site names, ten per species, snake_case single tokens, checked against the Hakai Institute site list (analysis project biomass tables) so none matches or contains a real site
- [x] 2.2 `data-raw/data_sim_macro.R`: availability table; truth with production means and moderate SDs; weight, size, density observations; true plot biomass by numerical integration over the size distribution; drone surveys and in situ plot biomass; report composed plot biomass quantiles and clipped-cover count
- [x] 2.3 `data-raw/data_sim_nereo.R`: as 2.2, with the site-year stipe density observed in the density data as the weight data's `stipes_m2` and the Weibull size distribution
- [x] 2.4 Remove the per-object `data-raw/data_{weight,size,density,cover_biomass}_sim_*.R` scripts; point the `fit_*_sim_*.R` script headers at the new scripts
- [x] 2.5 Run both scripts; check composed plot biomass quantiles against production (*Macrocystis* median about 2.7, *Nereocystis* about 1 kg/m²) and that every dataset passes its data check without warnings

## 3. Names in code, tests, and docs

- [x] 3.1 Replace `site1`-style names: tests look sites up from the fixture (`fitted_sites()` helper) or by level position, so they hold for either species; fixture subsets take each dataset's first four sites; examples, demo scripts, and README/vignette calls use the invented names
- [x] 3.2 Dataset roxygen (`R/data_*.R`): sites, years, availability, and the shared truth, for a first-time reader; `devtools::document()`

## 4. Rebuild fits (MCMC, confirm first)

- [x] 4.1 `pkgbuild::clean_dll()`, then `Rscript scripts/build.R --fits=weight,size,density,cover_biomass`
- [x] 4.2 Check every rebuilt pre-fit and fixture converges by its own thresholds, as before

## 5. Tests and archive

- [x] 5.1 Test the "Composed and in situ plot biomass agree" and "Data sources have gaps" scenarios on the bundled objects
- [x] 5.2 Run the tests; leave changed snapshots as `.new` files for review
- [x] 5.3 After the snapshot review: re-knit README.md (done once already), check specs and reader docs against the code, and `openspec archive realistic-sim-data --yes`
