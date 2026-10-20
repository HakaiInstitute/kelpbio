# errors name kb_check_data_cover_calibration_macro()

    Code
      kb_check_data_cover_calibration_macro(data[setdiff(names(data), "biomass_kg_m2")])
    Condition
      Error in `kb_check_data_cover_calibration_macro()`:
      ! `data[setdiff(names(data), "biomass_kg_m2")]` must have a biomass_kg_m2 column.
      i Use the output of `kb_predict_biomass_survey()` with its defaults: wet biomass per m², one row per survey.

