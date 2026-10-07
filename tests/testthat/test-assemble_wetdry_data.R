test_that("assemble_wetdry_data maps data and priors to the Stan data block", {
  data <- data.frame(wet_mass_g = c(4, 10), dry_mass_g = c(0.4, 0.8))
  priors <- list(
    intercept = kb_prior_normal(0.1, 1.1),
    precision = kb_prior_exponential(0.02)
  )
  sd <- assemble_wetdry_data(data, priors)
  expect_equal(sd$n_obs, 2L)
  expect_equal(sd$dry_wet_ratio, c(0.1, 0.08))
  expect_equal(sd$prior_intercept_mean, 0.1)
  expect_equal(sd$prior_intercept_sd, 1.1)
  expect_equal(sd$prior_precision_rate, 0.02)
  expect_equal(sd$prior_only, 0L)
})

test_that("assemble_wetdry_data accepts zero-row data", {
  data <- data.frame(wet_mass_g = numeric(0), dry_mass_g = numeric(0))
  sd <- assemble_wetdry_data(data, kb_priors_wetdry_nereo(), prior_only = TRUE)
  expect_equal(sd$n_obs, 0L)
  expect_length(sd$dry_wet_ratio, 0)
  expect_equal(sd$prior_only, 1L)
})
