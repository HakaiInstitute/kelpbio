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
