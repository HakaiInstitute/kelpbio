## 1. Pure pieces

- [x] 1.1 `kb_predictions` records `conf_level`; tests
- [x] 1.2 Stratified truncated size draws: Weibull (*Nereocystis*) and zero-truncated negative binomial (*Macrocystis*), inverse CDF over equal-probability strata up to the upper bound; tests against closed-form truncated means
- [x] 1.3 Upper size bound from the size fit's data (largest recorded size); observed site-year density from the density fit's data; tests
- [x] 1.4 Validation of the fits (model classes, the fits `measure` needs, shared species, equal draw counts, `representative_site` fitted in weight and size); `.vld_`/`.chk_` pairs and error snapshots

## 2. Composition

- [x] 2.1 Resolution of weight and size effects for the density-surveyed site-years (`new_levels`, `representative_site`); rows naming one new level share its sampled effect, in the shared resolver
- [x] 2.2 Mean plant weight per draw: expected weight at the drawn sizes (each weight model's `posterior_epred()` mean, honouring the *Nereocystis* form and density covariate), averaged over `n_plants`
- [x] 2.3 Expected density per m² per site-year from the density fit; biomass = density x mean weight; dry = wet x dry:wet ratio, carbon = dry x carbon fraction x 1000, per draw; summarise to a `kb_predictions` object with `weight_support`/`size_support`

## 3. Verb and tests

- [x] 3.1 `kb_predict_plot_biomass()` with roxygen; structure and invariant tests on the fixtures (one row per density-surveyed site-year, flags, `"sample"` at least as wide as `"average"`, seed reproducibility, errors)
- [x] 3.2 Numeric check against the analysis integration on the bundled fits (independent R computation from the draws), recorded in the PR, not snapshotted

## 4. Docs and archive

- [x] 4.1 `_pkgdown.yml`, demo section
- [x] 4.2 Check the specs and reader docs against the code; `openspec archive add-plot-biomass --yes`
