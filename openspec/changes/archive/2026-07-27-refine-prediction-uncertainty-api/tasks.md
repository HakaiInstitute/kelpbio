## 1. Engine (per-row resolution)

- [x] 1.1 Rework `.weight_linpred()` to resolve conditioning per row, per factor (known→condition, new/absent→`new_levels`) via `resolve_re1()`/`resolve_re2()`
- [x] 1.2 `match_levels` removed; unknown levels no longer error
- [x] 1.3 Split grid building into `build_data_grid()` (new-data / observed) and `build_by_grid()` (diameter sequence × by levels); orchestrators `weight_data_linpred()` / `weight_by_linpred()`
- [x] 1.4 `validate_by_weight()` keeps the invalid-factor and year-alone checks; drops the sample+full-by error

## 2. Two verbs + predict

- [x] 2.1 `kb_predict_weight()` reworked to the new-data verb (no `by`; `new_data = NULL` → observed)
- [x] 2.2 `kb_predict_weight_by()` added (by-driven curve; optional `diameter`); shared `summarise_weight_predictions()`
- [x] 2.3 `predict.kb_fit_weight()` wraps `kb_predict_weight()` (no `by`)

## 3. Generics + augment

- [x] 3.1 `posterior_epred/linpred/predict` route through `weight_data_linpred()`; per-row resolution; `new_levels` default `"sample"`; `posterior_predict(NULL)`→yrep
- [x] 3.2 `augment()` unchanged (diagnostics)

## 4. Review fixes

- [x] 4.1 `kb_fit_weight()`: `nthin` default 1; `open_progress = FALSE`
- [x] 4.2 `kb_plot_predictions()`: `max_facets` cap with `cli` warning

## 5. Data

- [x] 5.1 `kb_data_weight` rebuilt from real Hakai `data_submax` (no doy filter)
- [x] 5.2 Simulated set moved to `tests/testthat/fixtures/make-sim-data.R` → `sim_weight`; fixture/fit tests use it; existing `weight_fit.rds` stays valid

## 6. Docs

- [x] 6.1 `params.R` (`by`, `new_levels`), roxygen on both verbs + generics; `max_facets` doc
- [x] 6.2 `decisions/prediction-engine.md` cross-model contract
- [x] 6.3 `scripts/demo-weight-prediction.R` rewritten to the new API

## 7. Specs + tests

- [x] 7.1 Delta specs (predictions, fitting, plotting, data); sync into `openspec/specs/`
- [x] 7.2 Tests updated/added (per-row resolution, new/mixed sites, `_by` verb, facet cap); `document()`; full suite green
