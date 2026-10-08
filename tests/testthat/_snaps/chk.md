# .chk_kb_fit with class kb_fit_weight passes a fit through invisibly and errors on a non-fit

    Code
      .chk_kb_fit(1, "kb_fit_weight")
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
      .chk_representative_site(weight_nereo_fit, "not_a_site")
    Condition
      Error:
      ! Invalid `representative_site` value: "not_a_site".
      i Available sites: "otter_cove", "gull_rock", "cedar_bay", and "heron_reef".

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
      i Grids are built for weight, size, density, and cover biomass fits.

# .chk_grid_dots accepts the predictor and grouping values and rejects others

    Code
      .chk_grid_dots(weight_nereo_fit, list(fronds = 3), NULL)
    Condition
      Error:
      ! A nereocystis <kb_fit_weight> grid has no column `fronds`.
      i Supply the predictor `diameter_mm`, or values for `site` or `year`.

---

    Code
      .chk_grid_dots(weight_nereo_fit, list(30), NULL)
    Condition
      Error:
      ! Values in `...` must be named.
      i Supply the predictor `diameter_mm`, or values for `site` or `year`.

---

    Code
      .chk_grid_dots(size_nereo_fit, list(diameter_mm = 30), NULL)
    Condition
      Error:
      ! A nereocystis <kb_fit_size> grid has no column `diameter_mm`.
      i Supply values for `site` or `year`.

---

    Code
      .chk_grid_dots(weight_nereo_fit, twice, NULL)
    Condition
      Error:
      ! Supply `diameter_mm` once.

---

    Code
      .chk_grid_dots(weight_nereo_fit, list(diameter_mm = "a"), NULL)
    Condition
      Error in `.chk_grid_dots()`:
      ! Diameter_mm must be numeric.

---

    Code
      .chk_grid_dots(weight_nereo_fit, list(year = 2021), "year")
    Condition
      Error:
      ! `year` is named in `by` and given values.
      i `by` takes every fitted level; values in `...` take the levels supplied.

---

    Code
      .chk_grid_dots(weight_nereo_fit, list(year = TRUE), NULL)
    Condition
      Error:
      ! `year` must be a character, factor, or numeric vector.

# .chk_new_data_density errors name the area column

    Code
      .chk_new_data_density(data.frame(area_m2 = -1))
    Condition
      Error in `.chk_positive_measure()`:
      ! Column `area_m2` of data.frame(area_m2 = -1) must be greater than 0.

# .chk_same_species and .chk_same_ndraws name the fits

    Code
      .chk_same_species(list(weight = weight_nereo_fit, size = size_macro_fit))
    Condition
      Error:
      ! The fits must be of one species.
      i `weight` and `size` are "Nereocystis luetkeana" and "Macrocystis pyrifera".

---

    Code
      .chk_same_ndraws(list(weight = weight_nereo_fit, size = fit_size_sim_nereo))
    Condition
      Error:
      ! The fits must have the same number of posterior draws.
      i `weight` and `size` have 600 and 1500 draws.

# .chk_cover_survey errors name the survey column

    Code
      .chk_cover_survey(good[c("canopy_area_m2", "plot_area_m2")])
    Condition
      Error in `.chk_cover_survey()`:
      ! Good[c("canopy_area_m2", "plot_area_m2")] must include 'tide_height_m'.

---

    Code
      .chk_cover_survey(bad)
    Condition
      Error in `.chk_cover_survey()`:
      ! Column `canopy_area_m2` of bad must not exceed plot_area_m2.
      i The canopy is the area delineated within the plot.

# .chk_biomass_limits and .chk_biomass_estimate name the offending limit

    Code
      .chk_biomass_limits(good["estimate"])
    Condition
      Error in `.chk_biomass_limits()`:
      ! good["estimate"] must have lower and upper columns.
      i They are the compatibility limits of the in situ biomass estimate, which set its precision.

# .chk_site_surveys errors name the survey column

    Code
      .chk_site_surveys(good[c("site", "year", "canopy_area_m2")])
    Condition
      Error in `.chk_site_surveys()`:
      ! Good[c("site", "year", "canopy_area_m2")] must include 'tide_height_m'.

---

    Code
      .chk_site_surveys(transform(good, site_area_m2 = 50))
    Condition
      Error in `.chk_site_surveys()`:
      ! Column `canopy_area_m2` of transform(good, site_area_m2 = 50) must not exceed site_area_m2.
      i The canopy is the area mapped within the site boundary.

# .chk_sum_by names a missing or non-grouping column

    Code
      .chk_sum_by("zone", data)
    Condition
      Error:
      ! `sum_by` column zone must be character or factor with no missing values.
      i Convert a numeric code with `as.character()` or `factor()`.

---

    Code
      .chk_sum_by(c("region", "district"), data)
    Condition
      Error:
      ! `sum_by` names column district that `new_data` does not have.

# .chk_sampling_dots rejects sampler arguments kelpbio sets, naming the replacement

    Code
      .chk_sampling_dots(list(iter = 10, thin = 2))
    Condition
      Error:
      ! `iter` and `thin` cannot be passed to the sampler: kelpbio sets them itself.
      i Use `niters` and `nthin` instead.

---

    Code
      .chk_sampling_dots(list(pars = "intercept"))
    Condition
      Error:
      ! `pars` cannot be passed to the sampler: kelpbio sets it itself.
      i The fit keeps every parameter.

