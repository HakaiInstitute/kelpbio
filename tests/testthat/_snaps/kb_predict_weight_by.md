# kb_predict_weight_by errors on an object that is not a weight fit

    Code
      kb_predict_weight_by(1)
    Condition
      Error in `kb_predict_weight_by()`:
      ! `fit` must be a <kb_fit_weight> object.
      i Create one with a `kb_fit_weight_*()` fitting function.

# kb_predict_weight_by errors on a weight fit with no species method

    Code
      kb_predict_weight_by(fake)
    Condition
      Error in `kb_predict_weight_by()`:
      ! `kb_predict_weight_by()` has no method for `fit`, a <kb_fit_weight_other> object.
      i Supported fits are created by `kb_fit_weight_macro()` and `kb_fit_weight_nereo()`.

