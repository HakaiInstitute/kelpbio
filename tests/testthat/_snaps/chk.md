# .chk_kb_fit_weight passes a fit through invisibly and errors on a non-fit

    Code
      .chk_kb_fit_weight(1)
    Condition
      Error:
      ! `1` must be a <kb_fit_weight> object.
      i Create one with a `kb_fit_weight_*()` fitting function.

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

# .chk_progress passes a valid mode through invisibly and errors otherwise

    Code
      .chk_progress("loud")
    Condition
      Error in `.chk_progress()`:
      ! `"loud"` must be one of "bar", "verbose", or "none".

# .chk_progress_dir accepts NULL/an existing directory and errors otherwise

    Code
      .chk_progress_dir(missing_dir)
    Condition
      Error in `.chk_progress_dir()`:
      ! `missing_dir` must be a path to an existing directory, or `NULL`.

---

    Code
      .chk_progress_dir(1)
    Condition
      Error in `.chk_progress_dir()`:
      ! `1` must be a directory path or `NULL`.

# .chk_representative_site passes NULL/known sites and errors on unknown

    Code
      .chk_representative_site(weight_fit, "not_a_site")
    Condition
      Error in `.chk_representative_site()`:
      ! Invalid `representative_site` value: "not_a_site".
      i Available sites: "site1", "site2", "site3", and "site4".

