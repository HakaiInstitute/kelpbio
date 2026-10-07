cover_data <- function() {
  data.frame(
    canopy_area_m2 = c(60, 0, 120),
    plot_area_m2 = c(200, 210, 220),
    tide_height_m = c(0.5, -0.2, 1),
    estimate = c(2.8, 0.05, 6),
    lower = c(1.2, 0.02, 3),
    upper = c(6.1, 0.12, 12),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
}

test_that("assemble_cover_biomass_data maps data to the Stan data block", {
  d <- cover_data()
  sd <- assemble_cover_biomass_data(d, kb_priors_cover_biomass_nereo())
  expect_equal(sd$n_obs, 3L)
  expect_equal(sd$n_site, 2L)
  expect_equal(sd$n_year, 2L)
  expect_equal(sd$site, c(1L, 2L, 1L))
  expect_equal(sd$year, c(1L, 1L, 2L))
  expect_equal(sd$canopy_area_m2, d$canopy_area_m2)
  expect_equal(sd$plot_area_m2, d$plot_area_m2)
  expect_equal(sd$tide_height_m, d$tide_height_m)
  expect_equal(sd$log_biomass, log(d$estimate))
  expect_equal(sd$log_biomass_sd, cover_log_sd(d$lower, d$upper, 0.95))
  expect_equal(sd$prior_only, 0L)
})

test_that("assemble_cover_biomass_data uses the level of the supplied limits", {
  d <- cover_data()
  sd90 <- assemble_cover_biomass_data(d, kb_priors_cover_biomass_nereo(), conf_level = 0.9)
  expect_equal(sd90$log_biomass_sd, cover_log_sd(d$lower, d$upper, 0.9))
})

test_that("assemble_cover_biomass_data maps every prior hyperparameter to its own Stan field", {
  priors <- list(
    cover_slope = kb_prior_lognormal(0.1, 1.1),
    biomass_floor = kb_prior_normal(0.2, 1.2),
    tide_height_slope = kb_prior_normal(0.3, 1.3),
    error_scaling = kb_prior_normal(0.4, 1.4),
    sd_site = kb_prior_exponential(2.1),
    sd_year = kb_prior_exponential(2.2)
  )
  sd <- assemble_cover_biomass_data(cover_data(), priors)
  expect_equal(sd$prior_cover_slope_meanlog, 0.1)
  expect_equal(sd$prior_cover_slope_sdlog, 1.1)
  expect_equal(sd$prior_biomass_floor_mean, 0.2)
  expect_equal(sd$prior_biomass_floor_sd, 1.2)
  expect_equal(sd$prior_tide_height_slope_mean, 0.3)
  expect_equal(sd$prior_tide_height_slope_sd, 1.3)
  expect_equal(sd$prior_error_scaling_mean, 0.4)
  expect_equal(sd$prior_error_scaling_sd, 1.4)
  expect_equal(sd$prior_sd_site_rate, 2.1)
  expect_equal(sd$prior_sd_year_rate, 2.2)
})

test_that("assemble_cover_biomass_data accepts zero-row data", {
  sd <- assemble_cover_biomass_data(
    cover_data()[0, ],
    kb_priors_cover_biomass_nereo(),
    prior_only = TRUE
  )
  expect_equal(sd$n_obs, 0L)
  expect_equal(sd$n_site, 1L)
  expect_length(sd$log_biomass, 0)
  expect_length(sd$log_biomass_sd, 0)
  expect_equal(sd$prior_only, 1L)
})
