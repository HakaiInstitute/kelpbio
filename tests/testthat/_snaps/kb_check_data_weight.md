# missing, mistyped, and impossible values error via cli

    Code
      kb_check_data_weight(good[c("weight_kg", "site", "year")])
    Condition
      Error in `kb_check_data_weight()`:
      ! Good[c("weight_kg", "site", "year")] must include 'diameter_mm'.

---

    Code
      kb_check_data_weight(bad_type)
    Condition
      Error in `kb_check_data_weight()`:
      ! Column `diameter_mm` of bad_type must be numeric.

---

    Code
      kb_check_data_weight(bad_value)
    Condition
      Error in `kb_check_data_weight()`:
      ! Column `weight_kg` of bad_value must be greater than 0, not -1.

