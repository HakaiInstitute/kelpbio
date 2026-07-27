## 1. Metadata flag

- [x] 1.1 `new_kb_predictions()` gains `curve = FALSE`, stored as the `kb_curve` attribute
- [x] 1.2 `summarise_weight_predictions()` threads `curve` through; `kb_predict_weight()` sets `FALSE`, `kb_predict_weight_by()` sets `TRUE`

## 2. Plotting

- [x] 2.1 Remove the `style` and `facet` arguments from `kb_plot_predictions()`
- [x] 2.2 Derive style: ribbon iff `kb_curve && identical(x, predictor) && predictor_varies`, else pointrange
- [x] 2.3 Default `x` to the predictor when it varies, else the last grouping factor
- [x] 2.4 Facet by the remaining grouping variables (`setdiff(group_vars, x)`); the x variable is never a facet
- [x] 2.5 `autoplot` doc updated (drop `style`/`facet`)

## 3. Docs + specs + tests

- [x] 3.1 Roxygen on `kb_plot_predictions()` (style derivation, x default, facet rules, reference-diameter example)
- [x] 3.2 Delta specs (plotting, predictions); sync into `openspec/specs/`
- [x] 3.3 Tests updated/added (reference-diameter by site / site:year, scattered rows stay points, curve still ribbon); `document()`; suite green
