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
      ! Column `fronds` of `bad` must be at least 1.
      i The model describes plants with at least one frond reaching 1 m above the holdfast.
      i Remove plants with 0 fronds, and leave them out of the density counts too.

---

    Code
      kb_check_data_size_macro(bad)
    Condition
      Error in `kb_check_data_size_macro()`:
      ! Column `fronds` of `bad` must be at least 1.
      i The model describes plants with at least one frond reaching 1 m above the holdfast.
      i Remove plants with 0 fronds, and leave them out of the density counts too.

