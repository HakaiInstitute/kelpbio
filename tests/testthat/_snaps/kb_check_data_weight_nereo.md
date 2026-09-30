# missing, mistyped, and impossible values error

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

# an optional density column is validated

    Code
      kb_check_data_weight_nereo(bad)
    Condition
      Error in `.chk_density()`:
      ! Column `density` of `bad` must be greater than or equal to 0.

---

    Code
      kb_check_data_weight_nereo(bad)
    Condition
      Error in `.chk_density()`:
      ! Column `density` of `bad` must be numeric.

---

    Code
      kb_check_data_weight_nereo(bad)
    Condition
      Error in `.chk_density_site_year()`:
      ! Column `density` of `bad` must have one value per site-year.
      x Conflicting values in site-year "a:2020".

