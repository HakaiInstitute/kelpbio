# Build smoke-test for the rstan/rstantools engine. Structure only — no MCMC-number
# assertions. Requires the compiled package (devtools::install(), not load_all()).

test_that("stanmodels$weight is a compiled Stan model", {
  skip_on_cran()
  expect_s4_class(kelpbio:::stanmodels$weight, "stanmodel")
})

test_that("the weight model samples and returns the declared parameters", {
  skip_on_cran()
  stan_data <- list(
    nObs = 6L,
    nSite = 2L,
    site = c(1L, 1L, 1L, 2L, 2L, 2L),
    diameter = c(10, 20, 30, 40, 50, 60),
    weight = c(0.5, 1, 2, 4, 6, 9),
    prior_intercept_mu = 0,
    prior_intercept_sd = 2,
    prior_slope_mu = 2,
    prior_slope_sd = 1,
    prior_sd_site_rate = 1,
    prior_sd_residual_rate = 1,
    prior_only = 0L
  )
  # convergence warnings are expected for this tiny smoke fit and not under test
  fit <- suppressWarnings(rstan::sampling(
    kelpbio:::stanmodels$weight,
    data = stan_data,
    chains = 1,
    iter = 200,
    refresh = 0,
    seed = 1
  ))
  expect_s4_class(fit, "stanfit")
  expect_true(all(
    c("bWeight30", "bDiameter", "sSite", "sWeight", "bSite") %in% fit@model_pars
  ))
})

test_that("a prior-only fit accepts zero observations", {
  skip_on_cran()
  stan_data <- list(
    nObs = 0L,
    nSite = 1L,
    site = integer(0),
    diameter = numeric(0),
    weight = numeric(0),
    prior_intercept_mu = 0,
    prior_intercept_sd = 2,
    prior_slope_mu = 2,
    prior_slope_sd = 1,
    prior_sd_site_rate = 1,
    prior_sd_residual_rate = 1,
    prior_only = 1L
  )
  # convergence warnings are expected for this tiny smoke fit and not under test
  fit <- suppressWarnings(rstan::sampling(
    kelpbio:::stanmodels$weight,
    data = stan_data,
    chains = 1,
    iter = 200,
    refresh = 0,
    seed = 1
  ))
  expect_s4_class(fit, "stanfit")
})
