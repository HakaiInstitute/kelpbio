# missing, mistyped, and impossible values error via cli

    Code
      kb_check_data_weight(good[c("weight", "site", "year")])
    Condition
      Error in `kb_check_data_weight()`:
      ! `data` is missing required column: diameter.

---

    Code
      kb_check_data_weight(bad_type)
    Condition
      Error in `kb_check_data_weight()`:
      ! Column diameter must be numeric, not a string.

---

    Code
      kb_check_data_weight(bad_value)
    Condition
      Error in `kb_check_data_weight()`:
      ! Column weight must be positive (> 0).

