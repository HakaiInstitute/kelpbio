test_that("assemble_carbon_data passes the carbon fraction and priors to Stan", {
  data <- data.frame(sample_mass_mg = c(2.5, 2), carbon_mass_ug = c(650, 620))
  priors <- list(
    intercept = kb_prior_normal(-0.7, 0.4),
    precision = kb_prior_exponential(0.002)
  )
  sd <- assemble_carbon_data(data, priors)
  expect_equal(sd$nObs, 2L)
  expect_equal(sd$carbon_fraction, c(0.26, 0.31))
  expect_equal(sd$prior_intercept_mu, -0.7)
  expect_equal(sd$prior_intercept_sd, 0.4)
  expect_equal(sd$prior_precision_rate, 0.002)
  expect_equal(sd$prior_only, 0L)
})

test_that("assemble_carbon_data accepts zero-row data", {
  sd <- assemble_carbon_data(
    data.frame(sample_mass_mg = numeric(0), carbon_mass_ug = numeric(0)),
    kb_priors_carbon_nereo(),
    prior_only = TRUE
  )
  expect_equal(sd$nObs, 0L)
  expect_length(sd$carbon_fraction, 0)
  expect_equal(sd$prior_only, 1L)
})
