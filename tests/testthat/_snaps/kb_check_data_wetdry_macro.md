# missing columns, bad masses, and a dry mass not below the wet mass error

    Code
      kb_check_data_wetdry_macro(good["wet_mass_g"])
    Condition
      Error in `kb_check_data_wetdry_macro()`:
      ! `good["wet_mass_g"]` must include 'dry_mass_g'.

---

    Code
      kb_check_data_wetdry_macro(bad)
    Condition
      Error in `kb_check_data_wetdry_macro()`:
      ! Column `dry_mass_g` of `bad` must be greater than 0, not 0.

---

    Code
      kb_check_data_wetdry_macro(bad)
    Condition
      Error in `kb_check_data_wetdry_macro()`:
      ! Column `dry_mass_g` of `bad` must be less than wet_mass_g.

