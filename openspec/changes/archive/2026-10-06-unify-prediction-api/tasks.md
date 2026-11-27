No Stan or fit-structure change: no `rstan_config()`, `devtools::install()`
checkpoint, or `--fits` rebuild is needed.

## 1. Internal simplification (no behaviour change)

- [x] 1.1 `.epred()` takes only `rvar`s: `posterior_epred()` and `posterior_linpred()` call it before `draws_of()`; drop the `is_rvar()` branches and the `plogis()` note in `R/epred.R`
- [x] 1.2 Remove the `kb_predictor_units` / `kb_response_units` attributes from `new_kb_predictions()`, and their branches in `kb_plot_predictions()` and `kb_axis_label()`
- [x] 1.3 Turn `kb_predict_weight()`, `kb_predict_size()`, `kb_predict_density()`, `kb_predict_wetdry()`, and `kb_predict_carbon()` into plain functions that check the fit class; error snapshots unchanged

## 2. Grid builder

- [x] 2.1 `kb_new_data(fit, by = NULL, ...)` in `R/kb_new_data.R`, built on `build_by_grid()` and `validate_by()` (a default `fronds` sequence takes whole numbers); the species predictor from a named `...` argument checked against the fit's predictor (replacing `.chk_wrong_predictor()`); no `area_m2`; marks the grid as a curve when it has a predictor sequence; errors for wet/dry and carbon fits
- [x] 2.2 Tests: rows per `by`, level order, default and supplied predictor sequences, out-of-range warning, wrong-predictor and no-groups errors (snapshots)

## 3. Verbs

- [x] 3.1 `new_levels` default `"average"` in every verb, `predict()`, `kb_predict_plot_biomass()`, and the `posterior_*()` generics; roxygen points unseen sites to `"sample"`
- [x] 3.2 `kb_predict_density()` sets the transect area to 1 m² on any `new_data` (and the observed data), names its response `stipes_m2` / `plants_m2`; the draw generics default a missing `area_m2` to 1 m²; `.chk_new_data()` for density validates `area_m2` only when present
- [x] 3.3 The summariser carries the grid's curve mark into the `kb_predictions` object, replacing the `curve` argument; `kb_plot_predictions()` reads it
- [x] 3.4 Redirecting error for `by =` and for a character `new_data`, showing the `kb_new_data()` call (snapshot)
- [x] 3.5 Remove `kb_predict_weight_by()`, `kb_predict_size_by()`, `kb_predict_density_by()`, `by_linpred()`, and their tests; port their test cases to the verbs with `kb_new_data()`
- [x] 3.6 `predict()` methods forward to the verbs with the new defaults
- [x] 3.7 Verb tests: observed-data equality with `augment()` (density divided by `area_m2`), density ignores `area_m2`, `predict()` equals the verb, the default equals `"average"`

## 4. Docs and archive

- [x] 4.1 Roxygen for every verb with the same three examples (observed data, `kb_new_data()` by site, own rows); `kb_plot_predictions()` examples; `devtools::document()` before install so NAMESPACE drops the removed exports
- [x] 4.2 `scripts/demo-api-test.R`: move every `_by` call (including the plotting and functional-form sections) to `kb_new_data()`, add density per m² versus transect counts from `posterior_predict()`, and a section contrasting `new_levels = "average"` (the typical site, deterministic, the new default) with `"sample"` (a new site with between-site variation, wider and seed-dependent) on the same new-site rows and on a `kb_new_data()` grid, plotted side by side; drop the explicit `new_levels = "average"` calls that are now the default
- [x] 4.3 `_pkgdown.yml`; `scripts/demo-weight-client.R`; the README and vignette calls to the removed verbs (full pass deferred)
- [x] 4.4 Rewrite the "Cross-model prediction contract" and offset paragraphs of `decisions/prediction-engine.md`
- [x] 4.5 Check the specs and reader docs against the code; `openspec archive unify-prediction-api --yes`
- [x] 4.6 Note for kelpbioshiny (separate repo): `_by` calls in `R/data.R` and the mocks in `R/mock-kelpbio.R` move to `kb_new_data()`
