# missing, mistyped, and impossible values error via cli

    Code
      kb_check_data_weight(good[c("weight", "site", "year")])
    Condition
      Error in `kb_check_data_weight()`:
      ! Good[c("weight", "site", "year")] must include 'diameter'.

---

    Code
      kb_check_data_weight(bad_type)
    Condition
      Error in `kb_check_data_weight()`:
      ! Column `diameter` of bad_type must be numeric.

---

    Code
      kb_check_data_weight(bad_value)
    Condition
      Error in `kb_check_data_weight()`:
      ! Column `weight` of bad_value must be greater than 0, not -1.

