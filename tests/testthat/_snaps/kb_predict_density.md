# a by argument is redirected to kb_new_data()

    Code
      kb_predict_density(density_nereo_fit, by = "site")
    Condition
      Error in `kb_predict_density()`:
      ! `kb_predict_density()` predicts at the rows of `new_data`; it has no `by` argument.
      i For predictions by group, use `kb_predict_density(fit, kb_new_data(fit, by = "site"))`.

