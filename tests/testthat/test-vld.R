test_that(".vld_ predicates recognise a weight fit", {
  expect_true(.vld_kb_fit(weight_nereo_fit))
  expect_true(.vld_kb_fit(weight_nereo_fit, "kb_fit_weight"))
  expect_false(.vld_kb_fit(1, "kb_fit_weight"))
  expect_false(.vld_kb_fit(1))
})

test_that(".vld_representative_site accepts NULL and known site levels", {
  levels <- c("a", "b", "c")
  expect_true(.vld_representative_site(NULL, levels))
  expect_true(.vld_representative_site("a", levels))
  expect_true(.vld_representative_site(c("a", "c"), levels))
  expect_false(.vld_representative_site("z", levels))
  expect_false(.vld_representative_site(c("a", "z"), levels))
  expect_false(.vld_representative_site(character(0), levels))
  expect_false(.vld_representative_site(1, levels))
})

test_that(".vld_representative_site_fits accepts a vector or a list naming the fits", {
  fits <- c("weight", "size")
  expect_true(.vld_representative_site_fits(NULL, fits))
  expect_true(.vld_representative_site_fits("a", fits))
  expect_true(.vld_representative_site_fits(list(weight = "a"), fits))
  expect_true(.vld_representative_site_fits(list(weight = "a", size = NULL), fits))
  expect_false(.vld_representative_site_fits(list("a"), fits))
  expect_false(.vld_representative_site_fits(list(wetdry = "a"), fits))
  repeated <- stats::setNames(list("a", "b"), c("weight", "weight"))
  expect_false(.vld_representative_site_fits(repeated, fits))
  expect_false(.vld_representative_site_fits(list(weight = 1), fits))
  expect_false(.vld_representative_site_fits(list(size = "a"), "weight"))
})

test_that(".vld_new_data_weight_nereo requires a data frame with diameter", {
  expect_true(.vld_new_data_weight_nereo(data.frame(diameter_mm = 30)))
  expect_false(.vld_new_data_weight_nereo(data.frame(x = 1)))
  expect_false(.vld_new_data_weight_nereo(1))
  expect_false(.vld_new_data_weight_nereo(list(diameter_mm = 30)))
})

test_that(".vld_new_data_weight_macro requires a data frame with fronds", {
  expect_true(.vld_new_data_weight_macro(data.frame(fronds = 5)))
  expect_false(.vld_new_data_weight_macro(data.frame(diameter_mm = 30)))
  expect_false(.vld_new_data_weight_macro(1))
  expect_false(.vld_new_data_weight_macro(list(fronds = 5)))
})

test_that(".vld_progress accepts the three modes only", {
  expect_true(.vld_progress("bar"))
  expect_true(.vld_progress("verbose"))
  expect_true(.vld_progress("none"))
  expect_false(.vld_progress("loud"))
  expect_false(.vld_progress(c("bar", "none")))
  expect_false(.vld_progress(NA_character_))
  expect_false(.vld_progress(1))
})

test_that(".vld_progress_dir accepts NULL or an existing directory", {
  d <- withr::local_tempdir()
  expect_true(.vld_progress_dir(NULL))
  expect_true(.vld_progress_dir(d))
  expect_false(.vld_progress_dir(file.path(d, "nope")))
  expect_false(.vld_progress_dir(c(d, d)))
  expect_false(.vld_progress_dir(NA_character_))
  expect_false(.vld_progress_dir(1))
})

test_that(".vld_progress_dir rejects a directory that cannot be written to", {
  skip_on_os("windows")
  d <- withr::local_tempdir()
  Sys.chmod(d, "0555")
  withr::defer(Sys.chmod(d, "0755"))
  skip_if(file.access(d, mode = 2L) == 0L, "running with write access to every directory")
  expect_false(.vld_progress_dir(d))
})

test_that(".vld_positive_measure and .vld_frond_count check measured values", {
  expect_true(.vld_positive_measure(c(1.5, 30)))
  expect_false(.vld_positive_measure(c(1, 0)))
  expect_false(.vld_positive_measure(c(1, NA)))
  expect_false(.vld_positive_measure("30"))
  expect_false(.vld_positive_measure(c(1, Inf)))
  expect_true(.vld_frond_count(c(1, 5)))
  expect_false(.vld_frond_count(2.5))
})

test_that(".vld_frond_reaches_1m rejects plants with no frond at 1 m", {
  expect_true(.vld_frond_reaches_1m(c(1, 5)))
  expect_false(.vld_frond_reaches_1m(c(0, 5)))
})

test_that(".vld_kb_fit with class kb_fit_cover_calibration recognises a calibration fit", {
  expect_true(.vld_kb_fit(cover_calibration_nereo_fit, "kb_fit_cover_calibration"))
  expect_true(.vld_kb_fit(cover_calibration_macro_fit, "kb_fit_cover_calibration"))
  expect_false(.vld_kb_fit(size_nereo_fit, "kb_fit_cover_calibration"))
  expect_false(.vld_kb_fit(1, "kb_fit_cover_calibration"))
})

test_that(".vld_kb_fit_grouped recognises the models with grouping factors", {
  expect_true(.vld_kb_fit_grouped(weight_nereo_fit))
  expect_true(.vld_kb_fit_grouped(size_nereo_fit))
  expect_true(.vld_kb_fit_grouped(cover_calibration_nereo_fit))
  expect_false(.vld_kb_fit_grouped(wetdry_nereo_fit))
  expect_false(.vld_kb_fit_grouped(carbon_nereo_fit))
  expect_false(.vld_kb_fit_grouped(1))
})

test_that(".vld_kb_fit with class kb_fit_wetdry recognises a wet/dry fit", {
  expect_true(.vld_kb_fit(wetdry_nereo_fit, "kb_fit_wetdry"))
  expect_false(.vld_kb_fit(size_nereo_fit, "kb_fit_wetdry"))
  expect_false(.vld_kb_fit(1, "kb_fit_wetdry"))
})

test_that(".vld_kb_fit with class kb_fit_carbon recognises a carbon fit", {
  expect_true(.vld_kb_fit(carbon_nereo_fit, "kb_fit_carbon"))
  expect_false(.vld_kb_fit(wetdry_nereo_fit, "kb_fit_carbon"))
})

test_that(".vld_same_species and .vld_same_ndraws compare fits", {
  expect_true(.vld_same_species(list(weight_nereo_fit, size_nereo_fit)))
  expect_false(.vld_same_species(list(weight_nereo_fit, weight_macro_fit)))
  expect_true(.vld_same_ndraws(list(weight_nereo_fit, size_nereo_fit)))
  expect_false(.vld_same_ndraws(list(weight_nereo_fit, fit_size_sim_nereo)))
})


test_that(".vld_kb_fit with class kb_fit_cover_calibration recognises a cover calibration fit", {
  expect_true(.vld_kb_fit(cover_calibration_nereo_fit, "kb_fit_cover_calibration"))
  expect_false(.vld_kb_fit(carbon_nereo_fit, "kb_fit_cover_calibration"))
})

test_that(".vld_cover_survey accepts zero canopy within the plot", {
  good <- data.frame(canopy_area_m2 = c(0, 40), plot_area_m2 = 200, canopy_tide_height_m = -0.3)
  expect_true(.vld_cover_survey(good))
  expect_false(.vld_cover_survey(transform(good, canopy_area_m2 = 300)))
  expect_false(.vld_cover_survey(transform(good, plot_area_m2 = 0)))
  expect_false(.vld_cover_survey(transform(good, canopy_tide_height_m = NA)))
  expect_false(.vld_cover_survey(transform(good, canopy_tide_height_m = -Inf)))
  expect_false(.vld_cover_survey(good[c("canopy_area_m2", "plot_area_m2")]))
})

test_that(".vld_cover_survey checks biomass_sd_kg_m2 where present", {
  good <- data.frame(canopy_area_m2 = 40, plot_area_m2 = 200, canopy_tide_height_m = 0.5)
  expect_true(.vld_cover_survey(transform(good, biomass_sd_kg_m2 = 0)))
  expect_false(.vld_cover_survey(transform(good, biomass_sd_kg_m2 = -1)))
  expect_false(.vld_cover_survey(transform(good, biomass_sd_kg_m2 = NA_real_)))
})

test_that(".vld_census_size needs the weight fit's predictor", {
  expect_true(.vld_census_size(weight_macro_fit, data.frame(fronds = 3)))
  expect_false(.vld_census_size(weight_macro_fit, data.frame(diameter_mm = 30)))
})

test_that(".vld_measure_fits needs the conversion fits the measure uses", {
  expect_true(.vld_measure_fits("wet", NULL, NULL))
  expect_true(.vld_measure_fits("dry", wetdry_nereo_fit, NULL))
  expect_true(.vld_measure_fits("carbon", wetdry_nereo_fit, carbon_nereo_fit))
  expect_false(.vld_measure_fits("dry", NULL, NULL))
  expect_false(.vld_measure_fits("carbon", wetdry_nereo_fit, NULL))
  expect_false(.vld_measure_fits("wet", carbon_nereo_fit, NULL))
})

test_that(".vld_canopy_maps needs canopy, tide, site, year, and a large enough classified area", {
  good <- data.frame(
    site = "a", year = "2020", canopy_area_m2 = 100, canopy_tide_height_m = 0.5, classified_area_m2 = 1e4
  )
  expect_true(.vld_canopy_maps(good))
  expect_false(.vld_canopy_maps(good[setdiff(names(good), "classified_area_m2")]))
  expect_false(.vld_canopy_maps(transform(good, classified_area_m2 = 50)))
  expect_false(.vld_canopy_maps(transform(good, canopy_area_m2 = -1)))
  expect_false(.vld_canopy_maps(transform(good, site = NA)))
  expect_false(.vld_canopy_maps(transform(good, canopy_tide_height_m = Inf)))
  expect_false(.vld_canopy_maps(good[c("site", "year", "canopy_area_m2")]))
  expect_false(.vld_canopy_maps(list(good)))
})

test_that(".vld_pool_by accepts NULL or grouping columns of the data", {
  data <- data.frame(region = "north", zone = 1, site = NA_character_)
  expect_true(.vld_pool_by(NULL, data))
  expect_true(.vld_pool_by(character(0), data))
  expect_true(.vld_pool_by("region", data))
  expect_false(.vld_pool_by("zone", data))
  expect_false(.vld_pool_by("site", data))
  expect_false(.vld_pool_by("missing", data))
})

test_that(".vld_sampling_dots flags sampler arguments kelpbio sets", {
  expect_true(.vld_sampling_dots(list()))
  expect_true(.vld_sampling_dots(list(control = list(adapt_delta = 0.99))))
  expect_false(.vld_sampling_dots(list(iter = 10)))
  expect_false(.vld_sampling_dots(list(pars = "intercept")))
  expect_false(.vld_sampling_dots(list("power")))
  expect_false(.vld_sampling_dots(list(control = list(), 0)))
})

test_that(".vld_predictions needs a data frame with estimate and limits", {
  ok <- data.frame(estimate = 1, lower = 0.5, upper = 2)
  expect_true(.vld_predictions(ok))
  expect_false(.vld_predictions(list(estimate = 1, lower = 0.5, upper = 2)))
  expect_false(.vld_predictions(ok[c("estimate", "lower")]))
})

test_that(".vld_plot_x needs a column of the predictions", {
  p <- data.frame(diameter_mm = 1, estimate = 1)
  expect_true(.vld_plot_x("diameter_mm", p))
  expect_false(.vld_plot_x(NULL, p))
  expect_false(.vld_plot_x("site", p))
})

test_that(".vld_log_y and .vld_log_x need positive values", {
  p <- data.frame(cover = c(0, 1), estimate = 1, lower = 0.5, upper = 2)
  expect_true(.vld_log_y(p))
  expect_false(.vld_log_x(p, "cover"))
  p$lower[1] <- 0
  expect_false(.vld_log_y(p))
})

test_that(".vld_log_axis needs positive values on each log axis", {
  p <- data.frame(
    cover = c(0, 1),
    site = c("a", "b"),
    estimate = c(1, 2),
    lower = c(0.5, 1),
    upper = c(2, 3)
  )
  expect_true(.vld_log_axis("y", p, "cover"))
  expect_false(.vld_log_axis("xy", p, "cover"))
  expect_false(.vld_log_axis("xy", p, "site"))
  p$lower[1] <- 0
  expect_true(.vld_log_axis("none", p, "cover"))
  expect_false(.vld_log_axis("y", p, "cover"))
})

test_that(".vld_fit_rows needs rows unless prior_only", {
  expect_true(.vld_fit_rows(data.frame(x = 1), prior_only = FALSE))
  expect_true(.vld_fit_rows(data.frame(x = 1)[0, , drop = FALSE], prior_only = TRUE))
  expect_false(.vld_fit_rows(data.frame(x = 1)[0, , drop = FALSE], prior_only = FALSE))
})

test_that(".vld_finite rejects infinite values but not NA", {
  expect_true(.vld_finite(c(1, NA)))
  expect_false(.vld_finite(c(1, -Inf)))
})

test_that(".vld_rows needs at least one row", {
  expect_true(.vld_rows(data.frame(x = 1)))
  expect_false(.vld_rows(data.frame(x = numeric(0))))
})

test_that(".vld_new_data_groups rejects NA in any site or year column", {
  expect_true(.vld_new_data_groups(data.frame(diameter_mm = 30)))
  expect_true(.vld_new_data_groups(data.frame(site = "a", year = 2020)))
  expect_false(.vld_new_data_groups(data.frame(site = NA, year = "2020")))
  expect_false(.vld_new_data_groups(data.frame(year = NA_real_)))
})

test_that("the survey validators recognise valid survey and census tables", {
  s <- data.frame(
    survey_id = c("s1", "s2"), site = "a", year = "2021",
    plot_area_m2 = c(200, NA), canopy_area_m2 = c(50, NA), canopy_tide_height_m = c(0.5, NA)
  )
  expect_true(.vld_unique_surveys(s))
  expect_false(.vld_unique_surveys(transform(s, survey_id = "s1")))
  expect_true(.vld_drone_columns(s))
  expect_true(.vld_drone_columns(s["site"]))
  expect_false(.vld_drone_columns(transform(s, canopy_tide_height_m = NA)[-6]))
  expect_false(.vld_drone_columns(transform(s, canopy_area_m2 = c(300, NA))))
  expect_true(.vld_partial(c(TRUE, FALSE)))
  expect_false(.vld_partial(c(TRUE, NA)))
  p <- data.frame(survey_id = "s1")
  expect_true(.vld_census_join(p, s))
  expect_false(.vld_census_join(transform(p, survey_id = "s9"), s))
  expect_true(.vld_census_join(data.frame(survey_id = 1), data.frame(survey_id = "1")))
})

test_that(".vld_id_column allows numeric year and survey_id only", {
  expect_true(.vld_id_column(c(2020, 2021), "year"))
  expect_false(.vld_id_column(2020.5, "year"))
  expect_false(.vld_id_column(c(2020, NA), "year"))
  expect_true(.vld_id_column(2.5, "survey_id"))
  expect_false(.vld_id_column(Inf, "survey_id"))
  expect_false(.vld_id_column(1, "site"))
  expect_true(.vld_id_column(factor("a"), "site"))
})

