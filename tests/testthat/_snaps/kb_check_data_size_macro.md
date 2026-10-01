# missing, fractional, and zero frond counts error

    Code
      kb_check_data_size_macro(good[c("site", "year")])
    Condition
      Error in `kb_check_data_size_macro()`:
      ! `good[c("site", "year")]` must include 'fronds'.

---

    Code
      kb_check_data_size_macro(bad)
    Condition
      Error in `kb_check_data_size_macro()`:
      ! Column `fronds` of `bad` must be a whole numeric vector (integer vector or double equivalent).

---

    Code
      kb_check_data_size_macro(bad)
    Condition
      Error in `kb_check_data_size_macro()`:
      ! Column `fronds` of `bad` must be greater than 0, not 0.

