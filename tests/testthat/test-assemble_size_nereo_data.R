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
  expect_equal(sd$n_site, 2L)
  expect_equal(sd$n_year, 2L)
  expect_equal(sd$site, c(1L, 2L, 1L))
  expect_equal(sd$year, c(1L, 1L, 2L))
  expect_equal(sd$diameter_mm, c(20, 35, 50))
  expect_equal(sd$prior_only, 0L)
  expect_equal(sd$site_year_on, 1L)
})

test_that("assemble_size_nereo_data maps every prior hyperparameter to its own Stan field", {
  # Distinct values, so a transposed or dropped wiring cannot pass.
  priors <- list(
    intercept = kb_prior_normal(0.1, 1.1),
    shape = kb_prior_exponential(1.2),
    sd_site = kb_prior_exponential(2.1),
    sd_year = kb_prior_exponential(2.2),
    sd_site_year = kb_prior_exponential(2.3)
  )
  sd <- assemble_size_nereo_data(size_nereo_data(), priors)
  expect_equal(sd$prior_intercept_mean, 0.1)
  expect_equal(sd$prior_intercept_sd, 1.1)
  expect_equal(sd$prior_shape_rate, 1.2)
  expect_equal(sd$prior_sd_site_rate, 2.1)
  expect_equal(sd$prior_sd_year_rate, 2.2)
  expect_equal(sd$prior_sd_site_year_rate, 2.3)
})

test_that("assemble_size_nereo_data encodes the flags and accepts zero-row data", {
  off <- assemble_size_nereo_data(
    size_nereo_data(),
    kb_priors_size_nereo(),
    site_year_on = FALSE
  )
  expect_equal(off$site_year_on, 0L)
  sd <- assemble_size_nereo_data(
    size_nereo_data()[0, ],
    kb_priors_size_nereo(),
    prior_only = TRUE
  )
  expect_equal(sd$n_obs, 0L)
  expect_equal(sd$n_site, 1L)
  expect_equal(sd$n_year, 1L)
  expect_length(sd$diameter_mm, 0)
  expect_equal(sd$prior_only, 1L)
})
