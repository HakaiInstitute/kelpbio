# .chk_kb_fit_weight errors on a non-fit

    Code
      .chk_kb_fit_weight(bad)
    Condition
      Error in `.chk_kb_fit_weight()`:
      ! `bad` must be a <kb_fit_weight> object.
      i See `kb_fit_weight_nereo()`.

# .chk_new_data_weight_nereo errors on a non-data-frame or missing diameter

    Code
      .chk_new_data_weight_nereo(not_df)
    Condition
      Error in `.chk_new_data_weight_nereo()`:
      ! `not_df` must be a data frame.

---

    Code
      .chk_new_data_weight_nereo(no_diameter)
    Condition
      Error in `.chk_new_data_weight_nereo()`:
      ! `no_diameter` must have a diameter column.

