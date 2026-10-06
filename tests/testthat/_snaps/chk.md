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

# .chk_kb_fit_grouped errors for a non-fit and a model without groups

    Code
      .chk_kb_fit_grouped(wetdry_nereo_fit)
    Condition
      Error:
      ! `wetdry_nereo_fit` is a <kb_fit_wetdry_nereo> object, whose model has no grouping factors.
      i Grids are built for weight, size, and density fits.

# .chk_grid_predictor accepts the fit's predictor and rejects others

    Code
      .chk_grid_predictor(weight_fit, list(fronds = 3))
    Condition
      Error:
      ! `fronds` is not the predictor of a nereocystis fit.
      i Use `diameter_mm` to supply the predictor values.

---

    Code
      .chk_grid_predictor(weight_macro_fit, list(diameter_mm = 30))
    Condition
      Error:
      ! `diameter_mm` is not the predictor of a macrocystis fit.
      i Use `fronds` to supply the predictor values.

---

    Code
      .chk_grid_predictor(weight_fit, list(30))
    Condition
      Error:
      ! Predictor values in `...` must be named.
      i Use `diameter_mm` to supply the predictor values.

---

    Code
      .chk_grid_predictor(size_nereo_fit, list(diameter_mm = 30))
    Condition
      Error:
      ! A <kb_fit_size_nereo> fit has no predictor, so `...` must be empty.

---

    Code
      .chk_grid_predictor(weight_fit, twice)
    Condition
      Error:
      ! Supply `diameter_mm` once.

---

    Code
      .chk_grid_predictor(weight_fit, list(diameter_mm = "a"))
    Condition
      Error in `.chk_grid_predictor()`:
      ! Diameter_mm must be numeric.

# .chk_by_habit redirects a by argument to kb_new_data()

    Code
      .chk_by_habit(NULL, by = "site", verb = "kb_predict_density")
    Condition
      Error:
      ! `kb_predict_density()` predicts at the rows of `new_data`; it has no `by` argument.
      i For predictions by group, use `kb_predict_density(fit, kb_new_data(fit, by = "site"))`.

---

    Code
      .chk_by_habit(c("site", "year"), verb = "kb_predict_size")
    Condition
      Error:
      ! `kb_predict_size()` predicts at the rows of `new_data`; it has no `by` argument.
      i For predictions by group, use `kb_predict_size(fit, kb_new_data(fit, by = c("site", "year")))`.

# .chk_new_data_density errors name the area column

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

