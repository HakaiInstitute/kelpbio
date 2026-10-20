# mismatched and missing inputs error

    Code
      kb_predict_mean_weight(weight_nereo_fit, size_nereo_fit, measure = "dry")
    Condition
      Error in `kb_predict_mean_weight()`:
      ! `wetdry` is required for dry biomass.

# a size fit without observed data errors

    Code
      kb_predict_mean_weight(weight_nereo_fit, size)
    Condition
      Error in `kb_predict_mean_weight()`:
      ! A zero-observation fit has no observed data.
      i `size` must be fitted to observed plant sizes.

# representative_site must be fitted in both fits

    Code
      kb_predict_mean_weight(weight_nereo_fit, size, representative_site = "heron_reef")
    Condition
      Error in `kb_predict_mean_weight()`:
      ! Invalid `representative_site` value: "heron_reef".
      i Available sites: "otter_cove", "gull_rock", and "cedar_bay".

