# .abort_no_method names the generic, the class, and the constructors

    Code
      .abort_no_method("kb_predict_weight", fake)
    Condition
      Error:
      ! `kb_predict_weight()` has no method for `fake`, a <kb_fit_weight_other> object.
      i Supported fits are created by `kb_fit_weight_macro()` and `kb_fit_weight_nereo()`.

# .abort_no_method falls back to the name pattern when no constructor applies

    Code
      .abort_no_method("kb_stancode", structure(list(), class = "kb_fit_other"))
    Condition
      Error:
      ! `kb_stancode()` has no method for `structure(list(), class = "kb_fit_other")`, a <kb_fit_other> object.
      i Create one with a `kb_fit_*()` fitting function.

