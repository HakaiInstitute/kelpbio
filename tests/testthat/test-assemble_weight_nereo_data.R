test_that("assemble_weight_nereo_data maps data and priors to the Stan data block", {
  data <- data.frame(
    diameter_mm = c(20, 35, 50),
    weight_kg = c(0.5, 2, 4),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
  sd <- assemble_weight_nereo_data(
    data,
    kb_priors_weight_nereo(),
    diameter_ref = 42,
    prior_only = FALSE
  )

  expect_equal(sd$n_obs, 3L)
  expect_equal(sd$n_site, 2L)
  expect_equal(sd$n_year, 2L)
  expect_equal(sd$site, c(1L, 2L, 1L))
  expect_equal(sd$year, c(1L, 1L, 2L))
  expect_equal(sd$diameter_mm, c(20, 35, 50))
  expect_equal(sd$weight_kg, c(0.5, 2, 4))
  expect_equal(sd$diameter_ref, 42)
  expect_equal(sd$prior_only, 0L)
  expect_equal(sd$site_year_on, 1L)
  expect_equal(sd$floor_on, 1L)
})

test_that("assemble_weight_nereo_data encodes floor_on as 0/1", {
  data <- data.frame(
    diameter_mm = c(20, 35),
    weight_kg = c(0.5, 2),
    site = factor(c("a", "b")),
    year = factor(c("2020", "2021"))
  )
  sd <- assemble_weight_nereo_data(
    data,
    kb_priors_weight_nereo(),
    diameter_ref = 30,
    floor_on = FALSE
  )
  expect_equal(sd$floor_on, 0L)
})

test_that("assemble_weight_nereo_data maps every prior hyperparameter to its own Stan field", {
  data <- data.frame(
    diameter_mm = c(20, 35, 50),
    weight_kg = c(0.5, 2, 4),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
  # Distinct values, so a transposed or dropped wiring cannot pass.
  priors <- list(
    intercept = kb_prior_normal(0.1, 1.1),
    diameter_power = kb_prior_normal(0.2, 1.2),
    weight_floor = kb_prior_normal(0.3, 1.3),
    density_slope = kb_prior_normal(0.4, 1.4),
    sd_site = kb_prior_exponential(2.1),
    sd_year = kb_prior_exponential(2.2),
    sd_site_year = kb_prior_exponential(2.4),
    sd_residual = kb_prior_exponential(2.5)
  )
  sd <- assemble_weight_nereo_data(
    data,
    priors,
    diameter_ref = 30,
    prior_only = FALSE
  )
  expect_equal(sd$prior_intercept_mean, 0.1)
  expect_equal(sd$prior_intercept_sd, 1.1)
  expect_equal(sd$prior_diameter_power_mean, 0.2)
  expect_equal(sd$prior_diameter_power_sd, 1.2)
  expect_equal(sd$prior_weight_floor_mean, 0.3)
  expect_equal(sd$prior_weight_floor_sd, 1.3)
  expect_equal(sd$prior_density_slope_mean, 0.4)
  expect_equal(sd$prior_density_slope_sd, 1.4)
  expect_equal(sd$prior_sd_site_rate, 2.1)
  expect_equal(sd$prior_sd_year_rate, 2.2)
  expect_equal(sd$prior_sd_site_year_rate, 2.4)
  expect_equal(sd$prior_sd_residual_rate, 2.5)
})

test_that("assemble_weight_nereo_data encodes site_year_on as 0/1", {
  data <- data.frame(
    diameter_mm = c(20, 35, 50),
    weight_kg = c(0.5, 2, 4),
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
    diameter_mm = numeric(0),
    weight_kg = numeric(0),
    site = factor(character(0)),
    year = factor(character(0))
  )
  sd <- assemble_weight_nereo_data(
    data,
    kb_priors_weight_nereo(),
    diameter_ref = 30,
    prior_only = TRUE
  )
  expect_equal(sd$n_obs, 0L)
  expect_equal(sd$n_site, 1L)
  expect_equal(sd$n_year, 1L)
  expect_length(sd$site, 0)
  expect_length(sd$diameter_mm, 0)
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

test_that("assemble_weight_nereo_data passes standardised density and its flag", {
  data <- data.frame(
    diameter_mm = c(20, 35, 50, 40),
    weight_kg = c(0.5, 2, 4, 3),
    site = c("a", "b", "a", "b"),
    year = c("2020", "2020", "2021", "2021"),
    stipes_m2 = c(2, 4, NA, NA)
  )
  sd <- assemble_weight_nereo_data(data, kb_priors_weight_nereo(), 30)
  expect_equal(sd$density_on, 1L)
  # Standardised over the recorded rows; unrecorded site-years take the mean.
  expect_equal(sd$density, c(-1, 1, 0, 0) / sqrt(2))
})

test_that("assemble_weight_nereo_data zeroes density when there is none", {
  data <- data.frame(
    diameter_mm = c(20, 35),
    weight_kg = c(0.5, 2),
    site = c("a", "b"),
    year = c("2020", "2020")
  )
  sd <- assemble_weight_nereo_data(data, kb_priors_weight_nereo(), 30)
  expect_equal(sd$density_on, 0L)
  expect_equal(sd$density, c(0, 0))
})
