# missing, mistyped, and impossible values error

    Code
      kb_check_data_weight_nereo(good[c("weight_kg", "site", "year")])
    Condition
      Error in `kb_check_data_weight_nereo()`:
      ! `good[c("weight_kg", "site", "year")]` must include 'diameter_mm'.

---

    Code
      kb_check_data_weight_nereo(bad_type)
    Condition
      Error in `kb_check_data_weight_nereo()`:
      ! Column `diameter_mm` of `bad_type` must be numeric.

---

    Code
      kb_check_data_weight_nereo(bad_value)
    Condition
      Error in `kb_check_data_weight_nereo()`:
      ! Column `weight_kg` of `bad_value` must be greater than 0, not -1.

