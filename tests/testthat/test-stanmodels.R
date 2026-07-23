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
    nObs = nObs, nSite = nSite, nYear = nYear,
    site = site, year = year, diameter = diameter, weight = weight,
    diameter_ref = if (length(diameter)) exp(mean(log(diameter))) else 30,
    prior_intercept_mu = 0, prior_intercept_sd = 2,
    prior_diameter_mu = 2, prior_diameter_sd = 1,
    prior_diameter2_mu = 0, prior_diameter2_sd = 0.5,
    prior_sd_site_rate = 1, prior_sd_site_diameter_rate = 1,
    prior_sd_site_year_rate = 1, prior_sd_residual_rate = 1,
    prior_only = prior_only, site_year_on = 1L
  )
}

test_that("stanmodels$weight_nereo is a compiled Stan model", {
  skip_on_cran()
  expect_s4_class(stanmodels$weight_nereo, "stanmodel")
})

test_that("the weight model samples and returns the declared parameters", {
  # One raw-Stan smoke: the only direct check of the model's declared
  # parameter block. Zero-observation / prior-only sampling is covered
  # end-to-end through the wrapper (test-kb_fit_weight_nereo.R).
  skip_on_cran()
  fit <- suppressWarnings(rstan::sampling(
    stanmodels$weight_nereo,
    data = weight_stan_data(),
    chains = 1, iter = 200, refresh = 0, seed = 1
  ))
  expect_s4_class(fit, "stanfit")
  expect_true(all(
    c(
      "bWeight", "bDiameter", "bDiameter2",
      "sSite", "sSiteDiameter", "sSiteYear", "sWeight",
      "bSite", "bSiteDiameter", "bSiteYear",
      "log_lik", "yrep"
    ) %in% fit@model_pars
  ))
})
