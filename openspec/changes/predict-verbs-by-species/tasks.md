## 1. kb_predict_weight_by generic + species methods

- [x] 1.1 Rename the current `kb_predict_weight_by()` body to an internal `.kb_predict_weight_by(fit, by, predictor_values, new_levels, conf_level, estimate, sig_fig)` (unchanged logic).
- [x] 1.2 Add `kb_predict_weight_by <- function(fit, ...) UseMethod("kb_predict_weight_by")`.
- [x] 1.3 Add `kb_predict_weight_by.kb_fit_weight_nereo()` with a `diameter = NULL` formal, `rlang::check_dots_empty()`, delegating to `.kb_predict_weight_by()`.
- [x] 1.4 Add `kb_predict_weight_by.kb_fit_weight_macro()` with a `fronds = NULL` formal, delegating likewise.
- [x] 1.5 Add a wrong-species-argument check (`.chk_wrong_predictor()` in `R/chk.R`): each method aborts via `cli` naming the correct argument when it sees the other species' predictor (`fronds` on nereo, `diameter` on macro).

## 2. kb_predict_weight generic + species methods

- [x] 2.1 Rename the current `kb_predict_weight()` body to an internal `.kb_predict_weight()` (unchanged logic).
- [x] 2.2 Add `kb_predict_weight <- function(fit, ...) UseMethod("kb_predict_weight")` plus `kb_fit_weight_nereo` / `kb_fit_weight_macro` methods delegating to `.kb_predict_weight()` (signatures identical; `new_data` unchanged, no new predictor argument).

## 3. Documentation

- [x] 3.1 Document each verb as a generic topic covering shared conceptual details; `@describeIn` per-species method sections.
- [x] 3.2 Document the per-species methods with `@inheritParams params` for shared args plus `@param diameter` / `@param fronds`; removed all `predictor`-argument references.
- [ ] 3.3 `devtools::document()` to regenerate `man/` and `NAMESPACE` (new S3 method exports).

## 4. Reader docs and demo

- [x] 4.1 `vignettes/kelpbio.Rmd` calls the verbs with defaults only (no grid argument), so no change needed.
- [x] 4.2 Updated `scripts/demo-api-test.R`, `scripts/demo-weight-client.R`, and the `kb_plot_predictions` roxygen example to `diameter` / `fronds`. (`README` calls defaults only.)

## 5. Tests

- [x] 5.1 Updated `tests/testthat/test-kb_predict_weight_by.R` and `test-kb_plot_predictions.R` to `diameter` / `fronds`; added a macro `fronds`-sequence test.
- [x] 5.2 Added a test that the wrong-species predictor argument errors for each species.
- [ ] 5.3 Run `devtools::test()` green (no snapshot referenced `predictor`).

## 6. Spec sync and archive

- [ ] 6.1 Sync the `predictions` delta into `openspec/specs/predictions/spec.md`.
- [x] 6.2 Updated the `CLAUDE.md` argument-order note (`diameter`/`fronds`).
- [ ] 6.3 Archive the change.
