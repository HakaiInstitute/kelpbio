test_that("assemble_weight_macro_data maps data and priors to the Stan data block", {
  data <- data.frame(
    fronds = c(3L, 8L, 5L),
    weight = c(0.4, 2, 1),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
  sd <- assemble_weight_macro_data(
    data,
    kb_priors_weight_macro(),
    prior_only = FALSE
  )

  expect_equal(sd$nObs, 3L)
  expect_equal(sd$nSite, 2L)
  expect_equal(sd$nYear, 2L)
  expect_equal(sd$site, c(1L, 2L, 1L))
  expect_equal(sd$year, c(1L, 1L, 2L))
  expect_equal(sd$fronds, c(3, 8, 5))
  expect_equal(sd$weight, c(0.4, 2, 1))
  # log-fronds centering reference: geometric mean of the observed frond count
  expect_equal(sd$fronds_ref, exp(mean(log(c(3, 8, 5)))))
  expect_equal(sd$prior_only, 0L)
  expect_equal(sd$site_year_on, 1L)
})

test_that("assemble_weight_macro_data maps every prior hyperparameter to its own Stan field", {
  data <- data.frame(
    fronds = c(3L, 8L, 5L),
    weight = c(0.4, 2, 1),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
  # Every hyperparameter distinct, so a transposed or dropped wiring cannot pass.
  priors <- list(
    intercept = kb_prior_normal(0.1, 1.1),
    fronds = kb_prior_normal(0.2, 1.2),
    shape = kb_prior_exponential(2.0),
    sd_site = kb_prior_exponential(2.1),
    sd_year = kb_prior_exponential(2.2),
    sd_site_year = kb_prior_exponential(2.3)
  )
  sd <- assemble_weight_macro_data(data, priors, prior_only = FALSE)
  expect_equal(sd$prior_intercept_mu, 0.1)
  expect_equal(sd$prior_intercept_sd, 1.1)
  expect_equal(sd$prior_fronds_mu, 0.2)
  expect_equal(sd$prior_fronds_sd, 1.2)
  expect_equal(sd$prior_shape_rate, 2.0)
  expect_equal(sd$prior_sd_site_rate, 2.1)
  expect_equal(sd$prior_sd_year_rate, 2.2)
  expect_equal(sd$prior_sd_site_year_rate, 2.3)
})

test_that("assemble_weight_macro_data encodes site_year_on as 0/1", {
  data <- data.frame(
    fronds = c(3L, 8L, 5L),
    weight = c(0.4, 2, 1),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
  on <- assemble_weight_macro_data(
    data,
    kb_priors_weight_macro(),
    site_year_on = TRUE
  )
  off <- assemble_weight_macro_data(
    data,
    kb_priors_weight_macro(),
    site_year_on = FALSE
  )
  expect_equal(on$site_year_on, 1L)
  expect_equal(off$site_year_on, 0L)
})

test_that("assemble_weight_macro_data accepts zero-row data", {
  data <- data.frame(
    fronds = numeric(0),
    weight = numeric(0),
    site = factor(character(0)),
    year = factor(character(0))
  )
  sd <- assemble_weight_macro_data(
    data,
    kb_priors_weight_macro(),
    prior_only = TRUE
  )
  expect_equal(sd$nObs, 0L)
  expect_equal(sd$nSite, 1L)
  expect_equal(sd$nYear, 1L)
  expect_length(sd$fronds, 0)
  # empty-data reference falls back to 5
  expect_equal(sd$fronds_ref, 5)
  expect_equal(sd$prior_only, 1L)
})
