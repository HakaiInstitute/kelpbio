test_that("assemble_weight_nereo_data maps data and priors to the Stan data block", {
  data <- data.frame(
    diameter = c(20, 35, 50),
    weight = c(0.5, 2, 4),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
  sd <- assemble_weight_nereo_data(data, kb_priors_weight_nereo(), prior_only = FALSE)

  expect_equal(sd$nObs, 3L)
  expect_equal(sd$nSite, 2L)
  expect_equal(sd$nYear, 2L)
  expect_equal(sd$site, c(1L, 2L, 1L))
  expect_equal(sd$year, c(1L, 1L, 2L))
  expect_equal(sd$diameter, c(20, 35, 50))
  expect_equal(sd$weight, c(0.5, 2, 4))
  # log-diameter centering reference: geometric mean of the observed diameter
  expect_equal(sd$diameter_ref, exp(mean(log(c(20, 35, 50)))))
  expect_equal(sd$prior_intercept_mu, 0)
  expect_equal(sd$prior_intercept_sd, 2)
  expect_equal(sd$prior_diameter_mu, 2)
  expect_equal(sd$prior_diameter2_sd, 0.5)
  expect_equal(sd$prior_sd_site_rate, 1)
  expect_equal(sd$prior_sd_site_year_rate, 1)
  expect_equal(sd$prior_only, 0L)
  # site:year random effect included by default
  expect_equal(sd$site_year_on, 1L)
})

test_that("assemble_weight_nereo_data encodes site_year_on as 0/1", {
  data <- data.frame(
    diameter = c(20, 35, 50),
    weight = c(0.5, 2, 4),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
  on <- assemble_weight_nereo_data(data, kb_priors_weight_nereo(), site_year_on = TRUE)
  off <- assemble_weight_nereo_data(data, kb_priors_weight_nereo(), site_year_on = FALSE)
  expect_equal(on$site_year_on, 1L)
  expect_equal(off$site_year_on, 0L)
})

test_that("assemble_weight_nereo_data accepts zero-row data", {
  data <- data.frame(
    diameter = numeric(0), weight = numeric(0),
    site = factor(character(0)), year = factor(character(0))
  )
  sd <- assemble_weight_nereo_data(data, kb_priors_weight_nereo(), prior_only = TRUE)
  expect_equal(sd$nObs, 0L)
  expect_equal(sd$nSite, 1L)
  expect_equal(sd$nYear, 1L)
  expect_length(sd$site, 0)
  expect_length(sd$diameter, 0)
  expect_equal(sd$prior_only, 1L)
})
