# errors from the shared checks name the prediction verb

    Code
      kb_predict_weight(weight_nereo_fit, data.frame(site = "a"))
    Condition
      Error in `kb_predict_weight()`:
      ! `new_data` must include 'diameter_mm'.
    Code
      kb_predict_weight(weight_nereo_fit, conf_level = 2)
    Condition
      Error in `kb_predict_weight()`:
      ! `conf_level` must be between 0 and 1 exclusive, not 2.
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

