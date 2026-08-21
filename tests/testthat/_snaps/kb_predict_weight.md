# representative_site rejects sites not in the fit

    Code
      kb_predict_weight(weight_fit, nd, representative_site = "not_a_site")
    Condition
      Error in `.chk_representative_site()`:
      ! Invalid `representative_site` value: "not_a_site".
      i Available sites: "site1", "site2", "site3", and "site4".

# kb_predict_weight errors on an object that is not a weight fit

    Code
      kb_predict_weight(1)
    Condition
      Error in `kb_predict_weight()`:
      ! `fit` must be a <kb_fit_weight> object.
      i Supported fits are created by the `kb_fit_weight_*()` functions.

# kb_predict_weight errors on a weight fit with no species method

    Code
      kb_predict_weight(fake)
    Condition
      Error in `kb_predict_weight()`:
      ! `kb_predict_weight()` has no method for `fit`, a <kb_fit_weight_other> object.
      i Supported fits are created by `kb_fit_weight_macro()` and `kb_fit_weight_nereo()`.

