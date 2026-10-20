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
