# missing columns, bad counts, and bad areas error

    Code
      kb_check_data_density_nereo(good[c("area_m2", "site", "year")])
    Condition
      Error in `kb_check_data_density_nereo()`:
      ! `good[c("area_m2", "site", "year")]` must include 'stipes'.

---

    Code
      kb_check_data_density_nereo(bad)
    Condition
      Error in `kb_check_data_density_nereo()`:
      ! Column `stipes` of `bad` must be a whole numeric vector (integer vector or double equivalent).

---

    Code
      kb_check_data_density_nereo(bad)
    Condition
      Error in `kb_check_data_density_nereo()`:
      ! Column `stipes` of `bad` must be greater than or equal to 0, not -1.

---

    Code
      kb_check_data_density_nereo(bad)
    Condition
      Error in `kb_check_data_density_nereo()`:
      ! Column `area_m2` of `bad` must be greater than 0, not 0.

