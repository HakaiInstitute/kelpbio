# missing columns, bad counts, and bad areas error

    Code
      kb_check_data_density_macro(good[c("area_m2", "site", "year")])
    Condition
      Error in `kb_check_data_density_macro()`:
      ! `good[c("area_m2", "site", "year")]` must include 'plants'.

---

    Code
      kb_check_data_density_macro(bad)
    Condition
      Error in `kb_check_data_density_macro()`:
      ! Column `plants` of `bad` must be a whole numeric vector (integer vector or double equivalent).

---

    Code
      kb_check_data_density_macro(bad)
    Condition
      Error in `kb_check_data_density_macro()`:
      ! Column `plants` of `bad` must be greater than or equal to 0, not -1.

---

    Code
      kb_check_data_density_macro(bad)
    Condition
      Error in `kb_check_data_density_macro()`:
      ! Column `area_m2` of `bad` must be greater than 0, not 0.

