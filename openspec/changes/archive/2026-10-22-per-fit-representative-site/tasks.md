## 1. Validation

- [x] 1.1 Add `.vld_representative_site_fits()` to `R/vld.R`: `NULL`, a character vector, or a named list whose names are a subset of the allowed fit names, each element `NULL` or character.
- [x] 1.2 Add its `.chk_` partner to `R/chk.R`, aborting via `cli` with the expected form (`list(weight = , size = )`), and naming `size` as not allowed with a size census; takes `call`.
- [x] 1.3 Tests in `test-vld.R` and `test-chk.R`, with error snapshots.

## 2. Per-fit resolution

- [x] 2.1 Add `representative_sites()` in `R/representative_sites.R`: resolves the argument to `list(weight = , size = )` (a character vector goes to both), with `test-representative_sites.R`.
- [x] 2.2 `kb_predict_mean_weight()`: check the shape, resolve, and run `.chk_representative_site()` per fit on its own element.
- [x] 2.3 `kb_predict_biomass_survey()`: the same; with a size census only the `weight` element is allowed.
- [x] 2.4 `mean_weight_draws()` and `census_biomass_draws()` take the resolved per-fit values in place of the shared vector; update `test-mean_weight_draws.R`.

## 3. Tests of the verbs

- [x] 3.1 `test-kb_predict_mean_weight.R`: a weight-only list on a site new to the weight fit and fitted in the size fit gives the representative site's weight effect and the row's own size effect; a character vector gives the same result as before.
- [x] 3.2 `test-kb_predict_biomass_survey.R`: a weight-only list in both the tallied and the census paths; `size` named with a size census errors (snapshot).

## 4. Documentation

- [x] 4.1 Roxygen for `representative_site` in the derived verbs (`R/params.R`): the character and list forms, one sentence each, per `STYLE.md`.
- [x] 4.2 An example of the weight-only list in `kb_predict_biomass_survey()`.
- [x] 4.3 `devtools::document()`; check the specs and reader docs against the code.

## 5. Archive

- [x] 5.1 Once CI passes, `openspec archive per-fit-representative-site --yes`.
