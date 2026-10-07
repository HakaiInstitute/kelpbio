density_nereo_data <- function() {
  data.frame(
    stipes = c(3, 0, 12),
    area_m2 = c(20, 40, 60),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
}

test_that("assemble_density_nereo_data maps data to the Stan data block", {
  sd <- assemble_density_nereo_data(density_nereo_data(), kb_priors_density_nereo())
  expect_equal(sd$n_obs, 3L)
  expect_equal(sd$n_site, 2L)
  expect_equal(sd$n_year, 2L)
  expect_equal(sd$site, c(1L, 2L, 1L))
  expect_equal(sd$year, c(1L, 1L, 2L))
  # a Stan integer array
  expect_identical(sd$stipes, c(3L, 0L, 12L))
  expect_equal(sd$area_m2, c(20, 40, 60))
  expect_equal(sd$prior_only, 0L)
  expect_equal(sd$site_year_on, 1L)
})

test_that("assemble_density_nereo_data maps every prior hyperparameter to its own Stan field", {
  priors <- list(
    intercept = kb_prior_normal(0.1, 1.1),
    logit_zero_inflation = kb_prior_normal(0.2, 1.2),
    dispersion = kb_prior_exponential(2.0),
    sd_site = kb_prior_exponential(2.1),
    sd_year = kb_prior_exponential(2.2),
    sd_site_year = kb_prior_exponential(2.3)
  )
  sd <- assemble_density_nereo_data(density_nereo_data(), priors)
  expect_equal(sd$prior_intercept_mean, 0.1)
  expect_equal(sd$prior_intercept_sd, 1.1)
  expect_equal(sd$prior_logit_zero_inflation_mean, 0.2)
  expect_equal(sd$prior_logit_zero_inflation_sd, 1.2)
  expect_equal(sd$prior_dispersion_rate, 2.0)
  expect_equal(sd$prior_sd_site_rate, 2.1)
  expect_equal(sd$prior_sd_year_rate, 2.2)
  expect_equal(sd$prior_sd_site_year_rate, 2.3)
})

test_that("assemble_density_nereo_data encodes the flags and accepts zero-row data", {
  off <- assemble_density_nereo_data(
    density_nereo_data(),
    kb_priors_density_nereo(),
    site_year_on = FALSE
  )
  expect_equal(off$site_year_on, 0L)
  sd <- assemble_density_nereo_data(
    density_nereo_data()[0, ],
    kb_priors_density_nereo(),
    prior_only = TRUE
  )
  expect_equal(sd$n_obs, 0L)
  expect_equal(sd$n_site, 1L)
  expect_length(sd$stipes, 0)
  expect_length(sd$area_m2, 0)
  expect_equal(sd$prior_only, 1L)
})
