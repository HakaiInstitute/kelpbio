# missing, mistyped, and impossible values error via cli

    Code
      kb_check_data_weight_nereo(good[c("weight", "site", "year")])
    Condition
      Error in `kb_check_data_weight_nereo()`:
      ! `good[c("weight", "site", "year")]` must include 'diameter'.

---

    Code
      kb_check_data_weight_nereo(bad_type)
    Condition
      Error in `kb_check_data_weight_nereo()`:
      ! Column `diameter` of `bad_type` must be numeric.

---

    Code
      kb_check_data_weight_nereo(bad_value)
    Condition
      Error in `kb_check_data_weight_nereo()`:
      ! Column `weight` of `bad_value` must be greater than 0, not -1.

