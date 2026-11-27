# errors from ... name kb_new_data()

    Code
      kb_new_data(weight_nereo_fit, by = "year", year = 2021)
    Condition
      Error in `kb_new_data()`:
      ! `year` is named in `by` and given values.
      i `by` takes every fitted level; values in `...` take the levels supplied.

---

    Code
      kb_new_data(weight_nereo_fit, month = 3)
    Condition
      Error in `kb_new_data()`:
      ! A nereocystis <kb_fit_weight> grid has no column `month`.
      i Supply the predictor `diameter_mm`, or values for `site` or `year`.

