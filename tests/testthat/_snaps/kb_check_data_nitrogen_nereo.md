# a missing column, a zero mass, and nitrogen above the sample mass error

    Code
      kb_check_data_nitrogen_nereo(good["sample_mass_mg"])
    Condition
      Error in `kb_check_data_nitrogen_nereo()`:
      ! `good["sample_mass_mg"]` must include 'nitrogen_mass_ug'.

---

    Code
      kb_check_data_nitrogen_nereo(bad)
    Condition
      Error in `kb_check_data_nitrogen_nereo()`:
      ! Column `nitrogen_mass_ug` of `bad` must be greater than 0, not 0.

---

    Code
      kb_check_data_nitrogen_nereo(bad)
    Condition
      Error in `kb_check_data_nitrogen_nereo()`:
      ! Column `nitrogen_mass_ug` of `bad` must be less than the sample mass.
      i Check that nitrogen_mass_ug is in micrograms and sample_mass_mg in milligrams.

