size_macro_data <- function() {
  data.frame(
    fronds = c(3, 8, 1),
    site = factor(c("a", "b", "a")),
    year = factor(c("2020", "2020", "2021"))
  )
}

test_that("assemble_size_macro_data maps data to the Stan data block", {
  sd <- assemble_size_macro_data(size_macro_data(), kb_priors_size_macro())
  expect_equal(sd$nObs, 3L)
  expect_equal(sd$nSite, 2L)
  expect_equal(sd$nYear, 2L)
  expect_equal(sd$site, c(1L, 2L, 1L))
  expect_equal(sd$year, c(1L, 1L, 2L))
  # a Stan integer array
  expect_identical(sd$fronds, c(3L, 8L, 1L))
  expect_equal(sd$prior_only, 0L)
  expect_equal(sd$site_year_on, 1L)
})

test_that("assemble_size_macro_data maps every prior hyperparameter to its own Stan field", {
  priors <- list(
    intercept = kb_prior_normal(0.1, 1.1),
    dispersion = kb_prior_exponential(2.0),
    sd_site = kb_prior_exponential(2.1),
    sd_year = kb_prior_exponential(2.2),
    sd_site_year = kb_prior_exponential(2.3)
  )
  sd <- assemble_size_macro_data(size_macro_data(), priors)
  expect_equal(sd$prior_intercept_mu, 0.1)
  expect_equal(sd$prior_intercept_sd, 1.1)
  expect_equal(sd$prior_dispersion_rate, 2.0)
  expect_equal(sd$prior_sd_site_rate, 2.1)
  expect_equal(sd$prior_sd_year_rate, 2.2)
  expect_equal(sd$prior_sd_site_year_rate, 2.3)
})

test_that("assemble_size_macro_data encodes the flags and accepts zero-row data", {
  off <- assemble_size_macro_data(
    size_macro_data(),
    kb_priors_size_macro(),
    site_year_on = FALSE
  )
  expect_equal(off$site_year_on, 0L)
  sd <- assemble_size_macro_data(
    size_macro_data()[0, ],
    kb_priors_size_macro(),
    prior_only = TRUE
  )
  expect_equal(sd$nObs, 0L)
  expect_equal(sd$nSite, 1L)
  expect_length(sd$fronds, 0)
  expect_equal(sd$prior_only, 1L)
})
