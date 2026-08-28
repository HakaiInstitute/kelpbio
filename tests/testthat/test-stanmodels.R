# Smoke-test for the rstan/rstantools engine. Structure only -- no MCMC-number
# assertions. Requires the compiled package (devtools::install(), not load_all()).

weight_stan_data <- function(nObs = 6L, prior_only = 0L) {
  if (nObs == 0L) {
    site <- integer(0)
    year <- integer(0)
    diameter <- numeric(0)
    weight <- numeric(0)
    nSite <- 1L
    nYear <- 1L
  } else {
    site <- c(1L, 1L, 1L, 2L, 2L, 2L)
    year <- c(1L, 2L, 1L, 2L, 1L, 2L)
    diameter <- c(10, 20, 30, 40, 50, 60)
    weight <- c(0.5, 1, 2, 4, 6, 9)
    nSite <- 2L
    nYear <- 2L
  }
  list(
    nObs = nObs,
    nSite = nSite,
    nYear = nYear,
    site = site,
    year = year,
    diameter = diameter,
    weight = weight,
    diameter_ref = if (length(diameter)) exp(mean(log(diameter))) else 30,
    prior_intercept_mu = 0,
    prior_intercept_sd = 2,
    prior_power_mu = 2,
    prior_power_sd = 1,
    prior_floor_shape1 = 1,
    prior_floor_shape2 = 5,
    prior_nu_shape = 2,
    prior_nu_rate = 0.1,
    prior_sd_site_rate = 1,
    prior_sd_year_rate = 1,
    prior_sd_site_power_rate = 1,
    prior_sd_site_year_rate = 1,
    prior_sd_residual_rate = 1,
    prior_only = prior_only,
    site_year_on = 1L
  )
}

weight_macro_stan_data <- function(nObs = 6L, prior_only = 0L) {
  if (nObs == 0L) {
    site <- integer(0)
    year <- integer(0)
    fronds <- numeric(0)
    weight <- numeric(0)
    nSite <- 1L
    nYear <- 1L
  } else {
    site <- c(1L, 1L, 1L, 2L, 2L, 2L)
    year <- c(1L, 2L, 1L, 2L, 1L, 2L)
    fronds <- c(2, 3, 5, 6, 8, 12)
    weight <- c(0.3, 0.5, 0.9, 1.4, 2, 3.5)
    nSite <- 2L
    nYear <- 2L
  }
  list(
    nObs = nObs,
    nSite = nSite,
    nYear = nYear,
    site = site,
    year = year,
    fronds = fronds,
    weight = weight,
    fronds_ref = if (length(fronds)) exp(mean(log(fronds))) else 5,
    prior_intercept_mu = 0,
    prior_intercept_sd = 2,
    prior_fronds_mu = 1,
    prior_fronds_sd = 0.5,
    prior_shape_rate = 0.1,
    prior_sd_site_rate = 1,
    prior_sd_year_rate = 1,
    prior_sd_site_year_rate = 1,
    prior_only = prior_only,
    site_year_on = 1L
  )
}

test_that("stanmodels$weight_nereo is a compiled Stan model", {
  skip_on_cran()
  expect_s4_class(stanmodels$weight_nereo, "stanmodel")
})

test_that("stanmodels$weight_macro is a compiled Stan model", {
  skip_on_cran()
  expect_s4_class(stanmodels$weight_macro, "stanmodel")
})

test_that("the macro weight model samples and returns the declared parameters", {
  skip_on_cran()
  fit <- suppressWarnings(rstan::sampling(
    stanmodels$weight_macro,
    data = weight_macro_stan_data(),
    chains = 1,
    iter = 200,
    refresh = 0,
    seed = 1
  ))
  expect_s4_class(fit, "stanfit")
  expect_true(all(
    c(
      "bWeight",
      "bFronds",
      "shape",
      "sSite",
      "sYear",
      "sSiteYear",
      "bSite",
      "bYear",
      "bSiteYear"
    ) %in%
      fit@model_pars
  ))
  # No generated quantities, and the mean is a model-block local, so neither is
  # saved with the draws.
  expect_false(any(
    c("log_lik", "yrep", "log_eWeight") %in% fit@model_pars
  ))
})

test_that("the weight model samples and returns the declared parameters", {
  # the only direct check of the model's declared parameter block
  skip_on_cran()
  fit <- suppressWarnings(rstan::sampling(
    stanmodels$weight_nereo,
    data = weight_stan_data(),
    chains = 1,
    iter = 200,
    refresh = 0,
    seed = 1
  ))
  expect_s4_class(fit, "stanfit")
  expect_true(all(
    c(
      "bWeight",
      "bPower",
      "bFloor",
      "bNu",
      "sSite",
      "sYear",
      "sSitePower",
      "sSiteYear",
      "sWeight",
      "bSite",
      "bYear",
      "bSitePower",
      "bSiteYear"
    ) %in%
      fit@model_pars
  ))
  # No generated quantities, and the mean is a model-block local, so neither is
  # saved with the draws.
  expect_false(any(
    c("log_lik", "yrep", "log_eWeight") %in% fit@model_pars
  ))
})
