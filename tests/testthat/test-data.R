test_that("data_carbon_sim_macro has the expected columns and passes validation", {
  expect_s3_class(data_carbon_sim_macro, "data.frame")
  expect_named(data_carbon_sim_macro, c("sample_mass_mg", "carbon_mass_ug"))
  expect_silent(kb_check_data_carbon_macro(data_carbon_sim_macro))
})

test_that("data_carbon_sim_nereo has the expected columns and passes validation", {
  expect_s3_class(data_carbon_sim_nereo, "data.frame")
  expect_named(data_carbon_sim_nereo, c("sample_mass_mg", "carbon_mass_ug"))
  expect_silent(kb_check_data_carbon_nereo(data_carbon_sim_nereo))
})

test_that("data_survey_sim_macro and data_plants_sim_macro pass validation together", {
  expect_named(
    data_survey_sim_macro,
    c("site", "plot_id", "date", "survey_area_m2", "plot_area_m2", "canopy_area_m2", "tide_height_m")
  )
  expect_named(data_plants_sim_macro, c("site", "plot_id", "date", "fronds", "partial"))
  expect_silent(kb_check_data_survey(data_survey_sim_macro, data_plants_sim_macro))
  expect_silent(kb_check_data_plants_macro(data_plants_sim_macro))
  expect_equal(nlevels(data_survey_sim_macro$site), 10L)
})

test_that("data_survey_sim_nereo has the expected columns and passes validation", {
  expect_named(
    data_survey_sim_nereo,
    c(
      "site", "plot_id", "date", "survey_area_m2", "plants",
      "plot_area_m2", "canopy_area_m2", "tide_height_m"
    )
  )
  expect_silent(kb_check_data_survey(data_survey_sim_nereo))
  expect_equal(nlevels(data_survey_sim_nereo$site), 10L)
})

test_that("the survey datasets hold several plots, repeat visits, and an empty survey", {
  for (survey in list(data_survey_sim_nereo, data_survey_sim_macro)) {
    year <- date_year(survey$date)
    plots <- tapply(survey$plot_id, paste(survey$site, year), function(x) length(unique(x)))
    expect_true(any(plots > 1L))
    visits <- table(paste(survey$site, survey$plot_id, year))
    expect_true(any(visits > 1L))
    expect_true(anyNA(survey$canopy_area_m2))
    expect_false(all(is.na(survey$canopy_area_m2)))
  }
  expect_true(any(data_survey_sim_nereo$plants == 0))
  key <- survey_key(data_survey_sim_macro$site, data_survey_sim_macro$plot_id, data_survey_sim_macro$date)
  plant_key <- survey_key(data_plants_sim_macro$site, data_plants_sim_macro$plot_id, data_plants_sim_macro$date)
  expect_false(all(key %in% plant_key))
})

test_that("data_canopy_sim_nereo and data_canopy_sim_macro have the expected columns", {
  for (canopy in list(data_canopy_sim_nereo, data_canopy_sim_macro)) {
    expect_named(
      canopy,
      c("site", "year", "canopy_area_m2", "tide_height_m", "site_area_m2", "region")
    )
    expect_true(all(canopy$canopy_area_m2 <= canopy$site_area_m2))
  }
})

test_that("survey biomass from the bundled fits agrees with the bundled calibration", {
  skip_on_cran()
  withr::local_seed(1)
  biomass <- list(
    nereo = kb_predict_biomass_survey(
      fit_weight_sim_nereo,
      fit_size_sim_nereo,
      data_survey_sim_nereo,
      progress = "none"
    ),
    macro = kb_predict_biomass_survey(
      fit_weight_sim_macro,
      data_plants_sim_macro,
      data_survey_sim_macro,
      progress = "none"
    )
  )
  fits <- list(nereo = fit_cover_calibration_sim_nereo, macro = fit_cover_calibration_sim_macro)
  for (sp in names(fits)) {
    b <- biomass[[sp]]
    b <- b[!is.na(b$canopy_area_m2) & b$estimate > 0, ]
    fitted <- kb_predict_cover_calibration(
      fits[[sp]],
      b[c("site", "year", "plot_area_m2", "canopy_area_m2", "tide_height_m")]
    )
    ratio <- fitted$estimate / b$estimate
    expect_gte(stats::median(ratio), 0.5, label = sp)
    expect_lte(stats::median(ratio), 2, label = sp)
  }
})

test_that("data_size_sim_nereo has the expected columns and passes validation", {
  expect_s3_class(data_size_sim_nereo, "data.frame")
  expect_named(data_size_sim_nereo, c("diameter_mm", "site", "plot_id", "date"))
  expect_silent(kb_check_data_size_nereo(data_size_sim_nereo))
  expect_equal(nlevels(data_size_sim_nereo$site), 10L)
  expect_equal(length(unique(date_year(data_size_sim_nereo$date))), 4L)
})

test_that("data_weight_sim_macro has the expected columns and passes validation", {
  expect_s3_class(data_weight_sim_macro, "data.frame")
  expect_named(data_weight_sim_macro, c("fronds", "weight_kg", "site", "date"))
  expect_silent(kb_check_data_weight_macro(data_weight_sim_macro))
})

test_that("data_weight_sim_macro matches its documented format", {
  expect_gt(nrow(data_weight_sim_macro), 0L)
  expect_equal(nlevels(data_weight_sim_macro$site), 10L)
  expect_equal(length(unique(date_year(data_weight_sim_macro$date))), 4L)
  expect_true(all(data_weight_sim_macro$fronds > 0))
  expect_true(all(
    data_weight_sim_macro$fronds == round(data_weight_sim_macro$fronds)
  ))
  expect_true(all(data_weight_sim_macro$weight_kg > 0))
})

test_that("the macro data sources cover different site-years", {
  key <- function(site, year) unique(site_year_key(site, year))
  weight <- key(data_weight_sim_macro$site, date_year(data_weight_sim_macro$date))
  survey <- key(data_survey_sim_macro$site, date_year(data_survey_sim_macro$date))
  expect_lt(length(weight), length(survey))
  expect_gt(
    length(setdiff(unique(data_survey_sim_macro$site), unique(data_weight_sim_macro$site))),
    0L
  )
})

test_that("data_weight_sim_nereo has the expected columns and passes validation", {
  expect_s3_class(data_weight_sim_nereo, "data.frame")
  expect_named(
    data_weight_sim_nereo,
    c("diameter_mm", "weight_kg", "site", "date")
  )
  expect_silent(kb_check_data_weight_nereo(data_weight_sim_nereo))
})

test_that("data_weight_sim_nereo matches its documented format", {
  expect_gt(nrow(data_weight_sim_nereo), 0L)
  expect_equal(nlevels(data_weight_sim_nereo$site), 10L)
  expect_equal(length(unique(date_year(data_weight_sim_nereo$date))), 4L)
  expect_true(all(data_weight_sim_nereo$diameter_mm > 0))
  expect_true(all(data_weight_sim_nereo$weight_kg > 0))
})

test_that("the nereo data sources cover different site-years", {
  key <- function(site, year) unique(site_year_key(site, year))
  weight <- key(data_weight_sim_nereo$site, date_year(data_weight_sim_nereo$date))
  size <- key(data_size_sim_nereo$site, date_year(data_size_sim_nereo$date))
  survey <- key(data_survey_sim_nereo$site, date_year(data_survey_sim_nereo$date))
  expect_lt(length(weight), length(survey))
  expect_gt(
    length(setdiff(unique(data_survey_sim_nereo$site), unique(data_weight_sim_nereo$site))),
    0L
  )
  expect_gt(length(setdiff(survey, size)), 0L)
})

test_that("data_wetdry_sim_macro has the expected columns and passes validation", {
  expect_s3_class(data_wetdry_sim_macro, "data.frame")
  expect_named(data_wetdry_sim_macro, c("wet_mass_g", "dry_mass_g"))
  expect_silent(kb_check_data_wetdry_macro(data_wetdry_sim_macro))
})

test_that("data_wetdry_sim_nereo has the expected columns and passes validation", {
  expect_s3_class(data_wetdry_sim_nereo, "data.frame")
  expect_named(data_wetdry_sim_nereo, c("wet_mass_g", "dry_mass_g"))
  expect_silent(kb_check_data_wetdry_nereo(data_wetdry_sim_nereo))
})
