# data without biomass draws errors, pointing to kb_predict_biomass_in_situ()

    Code
      kb_check_data_cover_calibration_nereo(data[setdiff(names(data), "biomass_kg_m2")])
    Condition
      Error in `kb_check_data_cover_calibration_nereo()`:
      ! `data[setdiff(names(data), "biomass_kg_m2")]` must have a biomass_kg_m2 column.
      i Use the output of `kb_predict_biomass_in_situ()` with its defaults: wet biomass per m², one row per survey.

---

    Code
      kb_check_data_cover_calibration_nereo(data)
    Condition
      Error in `kb_check_data_cover_calibration_nereo()`:
      ! Column `biomass_kg_m2` of `data` must be a column of draws.
      i Use the output of `kb_predict_biomass_in_situ()` with its defaults: wet biomass per m², one row per survey.

