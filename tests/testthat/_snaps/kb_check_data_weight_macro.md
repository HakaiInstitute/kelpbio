# missing, mistyped, and impossible values error

    Code
      kb_check_data_weight_macro(good[c("weight", "site", "year")])
    Condition
      Error in `kb_check_data_weight_macro()`:
      ! `good[c("weight", "site", "year")]` must include 'fronds'.

---

    Code
      kb_check_data_weight_macro(bad_type)
    Condition
      Error in `kb_check_data_weight_macro()`:
      ! Column `fronds` of `bad_type` must be numeric.

---

    Code
      kb_check_data_weight_macro(bad_value)
    Condition
      Error in `kb_check_data_weight_macro()`:
      ! Column `weight` of `bad_value` must be greater than 0, not -1.

---

    Code
      kb_check_data_weight_macro(frac_fronds)
    Condition
      Error in `kb_check_data_weight_macro()`:
      ! Column `fronds` of `frac_fronds` must be a whole numeric vector (integer vector or double equivalent).

