test_that("group_stan_data codes site and year in factor level order", {
  data <- data.frame(site = c("b", "a", "b"), year = c("2020", "2019", "2019"))
  got <- group_stan_data(data)
  expect_identical(got$n_site, 2L)
  expect_identical(got$n_year, 2L)
  expect_identical(got$site, c(2L, 1L, 2L))
  expect_identical(got$year, c(2L, 1L, 1L))
})

test_that("zero-row data take one level of each", {
  got <- group_stan_data(data.frame(site = character(0), year = character(0)))
  expect_identical(got$n_site, 1L)
  expect_identical(got$n_year, 1L)
  expect_length(got$site, 0)
})

test_that("geometric_ref returns the geometric mean", {
  expect_equal(geometric_ref(c(20, 35, 50), fallback = 30), exp(mean(log(c(20, 35, 50)))))
})

test_that("geometric_ref returns the fallback for zero-row data", {
  expect_equal(geometric_ref(numeric(0), fallback = 30), 30)
})

test_that("assemble_carbon_data passes the carbon fraction to Stan", {
  data <- data.frame(sample_mass_mg = c(2.5, 2), carbon_mass_ug = c(650, 620))
  sd <- assemble_carbon_data(data, kb_priors_carbon_nereo())
  expect_equal(sd$n_obs, 2L)
  expect_equal(sd$carbon_fraction, c(0.26, 0.31))
  expect_equal(sd$prior_only, 0L)
})

test_that("assemble_carbon_data accepts zero-row data", {
  sd <- assemble_carbon_data(
    data.frame(sample_mass_mg = numeric(0), carbon_mass_ug = numeric(0)),
    kb_priors_carbon_nereo(),
    prior_only = TRUE
  )
  expect_equal(sd$n_obs, 0L)
  expect_length(sd$carbon_fraction, 0)
  expect_equal(sd$prior_only, 1L)
})

calibration_rows <- function() {
  survey_calibration_rows(survey_biomass(), progress = "none")
}

test_that("assemble_cover_calibration_data maps data to the Stan data block", {
  d <- calibration_rows()
  sd <- assemble_cover_calibration_data(d, kb_priors_cover_calibration_nereo())
  expect_equal(sd$n_obs, 3L)
  expect_equal(sd$canopy_area_m2, d$canopy_area_m2)
  expect_equal(sd$plot_area_m2, d$plot_area_m2)
  expect_equal(sd$canopy_tide_height_m, d$canopy_tide_height_m)
  expect_equal(sd$biomass, d$biomass_kg_m2)
  expect_equal(sd$weight_cv, c(d$biomass_sd_kg_m2[1] / d$biomass_kg_m2[1], 0, d$biomass_sd_kg_m2[3] / d$biomass_kg_m2[3]))
  expect_equal(sd$zero, c(0L, 1L, 0L))
  expect_equal(sd$presence_on, 0L)
  expect_equal(sd$prior_only, 0L)
  sd <- assemble_cover_calibration_data(d, kb_priors_cover_calibration_nereo(), presence_on = TRUE)
  expect_equal(sd$presence_on, 1L)
})

test_that("assemble_cover_calibration_data accepts zero-row data", {
  sd <- assemble_cover_calibration_data(
    calibration_rows()[0, ],
    kb_priors_cover_calibration_nereo(),
    prior_only = TRUE
  )
  expect_equal(sd$n_obs, 0L)
  expect_length(sd$biomass, 0)
  expect_length(sd$zero, 0)
  expect_equal(sd$prior_only, 1L)
})

test_that("assemble_nitrogen_data passes the nitrogen fraction to Stan", {
  data <- data.frame(sample_mass_mg = c(2.5, 2), nitrogen_mass_ug = c(50, 40))
  sd <- assemble_nitrogen_data(data, kb_priors_nitrogen_nereo())
  expect_equal(sd$n_obs, 2L)
  expect_equal(sd$nitrogen_fraction, c(0.02, 0.02))
  expect_equal(sd$prior_only, 0L)
})

test_that("assemble_nitrogen_data accepts zero-row data", {
  sd <- assemble_nitrogen_data(
    data.frame(sample_mass_mg = numeric(0), nitrogen_mass_ug = numeric(0)),
    kb_priors_nitrogen_nereo(),
    prior_only = TRUE
  )
  expect_equal(sd$n_obs, 0L)
  expect_length(sd$nitrogen_fraction, 0)
  expect_equal(sd$prior_only, 1L)
})

size_nereo_data <- function() {
  data.frame(
    diameter_mm = c(20, 35, 50),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
}

test_that("assemble_size_nereo_data maps data to the Stan data block", {
  sd <- assemble_size_nereo_data(size_nereo_data(), kb_priors_size_nereo())
  expect_equal(sd$n_obs, 3L)
  expect_equal(sd$diameter_mm, c(20, 35, 50))
  expect_equal(sd$prior_only, 0L)
})

test_that("assemble_size_nereo_data encodes the flags and accepts zero-row data", {
  sd <- assemble_size_nereo_data(
    size_nereo_data()[0, ],
    kb_priors_size_nereo(),
    prior_only = TRUE
  )
  expect_equal(sd$n_obs, 0L)
  expect_length(sd$diameter_mm, 0)
  expect_equal(sd$prior_only, 1L)
})

test_that("assemble_weight_macro_data maps data and priors to the Stan data block", {
  data <- data.frame(
    fronds = c(3L, 8L, 5L),
    weight_kg = c(0.4, 2, 1),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
  sd <- assemble_weight_macro_data(
    data,
    kb_priors_weight_macro(),
    prior_only = FALSE
  )

  expect_equal(sd$n_obs, 3L)
  expect_equal(sd$fronds, c(3, 8, 5))
  expect_equal(sd$weight_kg, c(0.4, 2, 1))
  expect_equal(sd$fronds_ref, exp(mean(log(c(3, 8, 5)))))
  expect_equal(sd$prior_only, 0L)
})

test_that("assemble_weight_macro_data accepts zero-row data", {
  data <- data.frame(
    fronds = numeric(0),
    weight_kg = numeric(0),
    site = factor(character(0)),
    year = factor(character(0))
  )
  sd <- assemble_weight_macro_data(
    data,
    kb_priors_weight_macro(),
    prior_only = TRUE
  )
  expect_equal(sd$n_obs, 0L)
  expect_length(sd$fronds, 0)
  expect_equal(sd$fronds_ref, 5)
  expect_equal(sd$prior_only, 1L)
})

test_that("assemble_weight_nereo_data maps data and priors to the Stan data block", {
  data <- data.frame(
    diameter_mm = c(20, 35, 50),
    weight_kg = c(0.5, 2, 4),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
  sd <- assemble_weight_nereo_data(
    data,
    kb_priors_weight_nereo(),
    diameter_ref = 42,
    prior_only = FALSE
  )

  expect_equal(sd$n_obs, 3L)
  expect_equal(sd$diameter_mm, c(20, 35, 50))
  expect_equal(sd$weight_kg, c(0.5, 2, 4))
  expect_equal(sd$diameter_ref, 42)
  expect_equal(sd$prior_only, 0L)
  expect_equal(sd$floor_on, 1L)
})

test_that("assemble_weight_nereo_data encodes floor_on as 0/1", {
  data <- data.frame(
    diameter_mm = c(20, 35),
    weight_kg = c(0.5, 2),
    site = factor(c("a", "b")),
    year = factor(c("2020", "2021"))
  )
  sd <- assemble_weight_nereo_data(
    data,
    kb_priors_weight_nereo(),
    diameter_ref = 30,
    floor_on = FALSE
  )
  expect_equal(sd$floor_on, 0L)
})

test_that("assemble_weight_nereo_data accepts zero-row data", {
  data <- data.frame(
    diameter_mm = numeric(0),
    weight_kg = numeric(0),
    site = factor(character(0)),
    year = factor(character(0))
  )
  sd <- assemble_weight_nereo_data(
    data,
    kb_priors_weight_nereo(),
    diameter_ref = 30,
    prior_only = TRUE
  )
  expect_equal(sd$n_obs, 0L)
  expect_length(sd$diameter_mm, 0)
  expect_equal(sd$prior_only, 1L)
})

test_that("assemble_wetdry_data maps data to the Stan data block", {
  data <- data.frame(wet_mass_g = c(4, 10), dry_mass_g = c(0.4, 0.8))
  sd <- assemble_wetdry_data(data, kb_priors_wetdry_nereo())
  expect_equal(sd$n_obs, 2L)
  expect_equal(sd$dry_wet_ratio, c(0.1, 0.08))
  expect_equal(sd$prior_only, 0L)
})

test_that("assemble_wetdry_data accepts zero-row data", {
  data <- data.frame(wet_mass_g = numeric(0), dry_mass_g = numeric(0))
  sd <- assemble_wetdry_data(data, kb_priors_wetdry_nereo(), prior_only = TRUE)
  expect_equal(sd$n_obs, 0L)
  expect_length(sd$dry_wet_ratio, 0)
  expect_equal(sd$prior_only, 1L)
})
