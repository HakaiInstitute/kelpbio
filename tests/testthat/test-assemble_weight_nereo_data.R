test_that("assemble_weight_nereo_data maps data and priors to the Stan data block", {
  data <- data.frame(
    diameter = c(20, 35, 50),
    weight = c(0.5, 2, 4),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
  sd <- assemble_weight_nereo_data(
    data,
    kb_priors_weight_nereo(),
    diameter_ref = 42,
    prior_only = FALSE
  )

  expect_equal(sd$nObs, 3L)
  expect_equal(sd$nSite, 2L)
  expect_equal(sd$nYear, 2L)
  expect_equal(sd$site, c(1L, 2L, 1L))
  expect_equal(sd$year, c(1L, 1L, 2L))
  expect_equal(sd$diameter, c(20, 35, 50))
  expect_equal(sd$weight, c(0.5, 2, 4))
  # the supplied centering reference is passed straight through
  expect_equal(sd$diameter_ref, 42)
  expect_equal(sd$prior_only, 0L)
  # site:year random effect included by default
  expect_equal(sd$site_year_on, 1L)
})

test_that("assemble_weight_nereo_data maps every prior hyperparameter to its own Stan field", {
  data <- data.frame(
    diameter = c(20, 35, 50),
    weight = c(0.5, 2, 4),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
  # Every hyperparameter distinct, so a transposed or dropped wiring cannot pass.
  priors <- list(
    intercept = kb_prior_normal(0.1, 1.1),
    log_power = kb_prior_normal(0.2, 1.2),
    floor = kb_prior_beta(0.3, 1.3),
    nu = kb_prior_gamma(0.4, 1.4),
    sd_site = kb_prior_exponential(2.1),
    sd_year = kb_prior_exponential(2.2),
    sd_site_power = kb_prior_exponential(2.3),
    sd_site_year = kb_prior_exponential(2.4),
    sd_residual = kb_prior_exponential(2.5)
  )
  sd <- assemble_weight_nereo_data(
    data,
    priors,
    diameter_ref = 30,
    prior_only = FALSE
  )
  expect_equal(sd$prior_intercept_mu, 0.1)
  expect_equal(sd$prior_intercept_sd, 1.1)
  expect_equal(sd$prior_log_power_mu, 0.2)
  expect_equal(sd$prior_log_power_sd, 1.2)
  expect_equal(sd$prior_floor_shape1, 0.3)
  expect_equal(sd$prior_floor_shape2, 1.3)
  expect_equal(sd$prior_nu_shape, 0.4)
  expect_equal(sd$prior_nu_rate, 1.4)
  expect_equal(sd$prior_sd_site_rate, 2.1)
  expect_equal(sd$prior_sd_year_rate, 2.2)
  expect_equal(sd$prior_sd_site_power_rate, 2.3)
  expect_equal(sd$prior_sd_site_year_rate, 2.4)
  expect_equal(sd$prior_sd_residual_rate, 2.5)
})

test_that("assemble_weight_nereo_data encodes site_year_on as 0/1", {
  data <- data.frame(
    diameter = c(20, 35, 50),
    weight = c(0.5, 2, 4),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
  on <- assemble_weight_nereo_data(
    data,
    kb_priors_weight_nereo(),
    diameter_ref = 30,
    site_year_on = TRUE
  )
  off <- assemble_weight_nereo_data(
    data,
    kb_priors_weight_nereo(),
    diameter_ref = 30,
    site_year_on = FALSE
  )
  expect_equal(on$site_year_on, 1L)
  expect_equal(off$site_year_on, 0L)
})

test_that("assemble_weight_nereo_data accepts zero-row data", {
  data <- data.frame(
    diameter = numeric(0),
    weight = numeric(0),
    site = factor(character(0)),
    year = factor(character(0))
  )
  sd <- assemble_weight_nereo_data(
    data,
    kb_priors_weight_nereo(),
    diameter_ref = 30,
    prior_only = TRUE
  )
  expect_equal(sd$nObs, 0L)
  expect_equal(sd$nSite, 1L)
  expect_equal(sd$nYear, 1L)
  expect_length(sd$site, 0)
  expect_length(sd$diameter, 0)
  expect_equal(sd$prior_only, 1L)
})

test_that("weight_diameter_ref returns the geometric mean of the observed diameter", {
  expect_equal(
    weight_diameter_ref(c(20, 35, 50)),
    exp(mean(log(c(20, 35, 50))))
  )
})

test_that("weight_diameter_ref falls back to 30 for zero-row data", {
  expect_equal(weight_diameter_ref(numeric(0)), 30)
})
