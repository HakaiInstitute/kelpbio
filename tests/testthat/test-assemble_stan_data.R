test_that("assemble_stan_data maps data and priors to the Stan data block", {
  data <- data.frame(
    diameter = c(20, 35, 50),
    weight = c(0.5, 2, 4),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
  sd <- assemble_stan_data(data, kb_priors_weight(), prior_only = FALSE)

  expect_equal(sd$nObs, 3L)
  expect_equal(sd$nSite, 2L)
  expect_equal(sd$nYear, 2L)
  expect_equal(sd$site, c(1L, 2L, 1L))
  expect_equal(sd$year, c(1L, 1L, 2L))
  expect_equal(sd$diameter, c(20, 35, 50))
  expect_equal(sd$weight, c(0.5, 2, 4))
  expect_equal(sd$prior_intercept_mu, 0)
  expect_equal(sd$prior_intercept_sd, 2)
  expect_equal(sd$prior_diameter_mu, 2)
  expect_equal(sd$prior_diameter2_sd, 0.5)
  expect_equal(sd$prior_sd_site_rate, 1)
  expect_equal(sd$prior_sd_site_year_rate, 1)
  expect_equal(sd$prior_only, 0L)
})

test_that("assemble_stan_data accepts zero-row data", {
  data <- data.frame(
    diameter = numeric(0), weight = numeric(0),
    site = factor(character(0)), year = factor(character(0))
  )
  sd <- assemble_stan_data(data, kb_priors_weight(), prior_only = TRUE)
  expect_equal(sd$nObs, 0L)
  expect_equal(sd$nSite, 1L)
  expect_equal(sd$nYear, 1L)
  expect_length(sd$site, 0)
  expect_length(sd$diameter, 0)
  expect_equal(sd$prior_only, 1L)
})
