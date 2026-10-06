# .chk_kb_fit_weight passes a fit through invisibly and errors on a non-fit

    Code
      .chk_kb_fit_weight(1)
    Condition
      Error:
      ! `1` must be a <kb_fit_weight> object.
      i Supported fits are created by the `kb_fit_weight_*()` functions.

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
      ! `no_diameter` must have a diameter_mm column.

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

# .chk_new_data_weight_nereo errors on a negative density

    Code
      .chk_new_data_weight_nereo(d)
    Condition
      Error in `.chk_density()`:
      ! Column `stipes_m2` of d must be greater than or equal to 0.

# .chk_new_data errors name the invalid predictor column

    Code
      .chk_new_data_weight_nereo(data.frame(diameter_mm = 0))
    Condition
      Error in `.chk_positive_measure()`:
      ! Column `diameter_mm` of data.frame(diameter_mm = 0) must be greater than 0.

---

    Code
      .chk_new_data_weight_nereo(data.frame(diameter_mm = "30"))
    Condition
      Error in `.chk_positive_measure()`:
      ! Column `diameter_mm` of data.frame(diameter_mm = "30") must be numeric.

---

    Code
      .chk_new_data_weight_nereo(data.frame(diameter_mm = NA_real_))
    Condition
      Error in `.chk_positive_measure()`:
      ! Column `diameter_mm` of data.frame(diameter_mm = NA_real_) must not have missing values.

---

    Code
      .chk_new_data_weight_macro(data.frame(fronds = 2.5))
    Condition
      Error in `.chk_frond_count()`:
      ! Column `fronds` of data.frame(fronds = 2.5) must be a whole number.

# .chk_new_data_density errors name the area column

    Code
      .chk_new_data_density(data.frame(site = "a"))
    Condition
      Error in `.chk_new_data_density()`:
      ! `data.frame(site = "a")` must have an area_m2 column.
      i Its rows predict the count on a transect of that area; use `kb_predict_density_by()` for density per m².

---

    Code
      .chk_new_data_density(data.frame(area_m2 = -1))
    Condition
      Error in `.chk_positive_measure()`:
      ! Column `area_m2` of data.frame(area_m2 = -1) must be greater than 0.

# .chk_same_species and .chk_same_ndraws name the fits

    Code
      .chk_same_species(list(weight = weight_fit, size = size_macro_fit))
    Condition
      Error:
      ! The fits must be of one species.
      i `weight` and `size` are "Nereocystis luetkeana" and "Macrocystis pyrifera".

---

    Code
      .chk_same_ndraws(list(weight = weight_fit, size = fit_size_sim_nereo))
    Condition
      Error:
      ! The fits must have the same number of posterior draws.
      i `weight` and `size` have 600 and 1500 draws.

