# missing, mistyped, and impossible values error

    Code
      kb_check_data_size_nereo(good[c("site", "year")])
    Condition
      Error in `kb_check_data_size_nereo()`:
      ! `good[c("site", "year")]` must include 'diameter'.

---

    Code
      kb_check_data_size_nereo(bad)
    Condition
      Error in `kb_check_data_size_nereo()`:
      ! Column `diameter` of `bad` must be greater than 0, not -1.

