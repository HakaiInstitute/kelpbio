# errors from the shared checks name the prediction verb

    Code
      kb_predict_weight(weight_nereo_fit, data.frame(site = "a"))
    Condition
      Error in `kb_predict_weight()`:
      ! `new_data` must have a diameter_mm column.
    Code
      kb_predict_weight(weight_nereo_fit, conf_level = 2)
    Condition
      Error in `kb_predict_weight()`:
      ! `conf_level` must be between 0 and 1, not 2.
    Code
      kb_predict_size(size_nereo_fit, new_levels = "bogus")
    Condition
      Error in `kb_predict_size()`:
      ! `new_levels` must be one of "average" or "sample", not "bogus".
    Code
      kb_predict_size(size_nereo_fit, representative_site = "bogus")
    Condition
      Error in `kb_predict_size()`:
      ! Invalid `representative_site` value: "bogus".
      i Available sites: "otter_cove", "gull_rock", "cedar_bay", and "heron_reef".

# a zero-observation fit names the function called

    Code
      posterior_epred(fit0)
    Condition
      Error in `posterior_epred()`:
      ! A zero-observation fit has no observed data.
      i Supply `new_data`, or fit the model to data.
    Code
      residuals(fit0)
    Condition
      Error in `residuals()`:
      ! A zero-observation fit has no observed data.
    Code
      log_lik(fit0)
    Condition
      Error in `log_lik()`:
      ! A zero-observation fit has no observed data.

