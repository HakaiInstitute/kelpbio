draws_of_term <- function(fit, term) {
  as.vector(posterior::draws_of(fit$draws[[term]]))
}

test_that("log_prior sums the priors of the fitted terms per draw", {
  fit <- wetdry_nereo_fit
  pri <- fit$meta$priors
  expected <- stats::dnorm(
    draws_of_term(fit, "intercept"),
    pri$intercept$mean,
    pri$intercept$sd,
    log = TRUE
  ) +
    stats::dexp(draws_of_term(fit, "precision"), pri$precision$rate, log = TRUE)
  expect_equal(log_prior(fit), expected)
  expect_length(log_prior(fit), posterior::ndraws(fit$draws))
})

test_that("log_prior evaluates a lognormal prior on the parameter itself", {
  fit <- cover_biomass_nereo_fit
  slope_only <- fit
  slope_only$meta$terms$fixed <- "cover_slope"
  x <- draws_of_term(fit, "cover_slope")
  p <- fit$meta$priors$cover_slope
  expected <- stats::dnorm(log(x), p$meanlog, p$sdlog, log = TRUE) - log(x)
  expect_equal(log_prior(slope_only), expected)
})

test_that("log_prior leaves out a term the fit omitted", {
  full <- log_prior(weight_nereo_fit)
  dropped <- omit_terms(weight_nereo_fit, "density_slope")
  p <- weight_nereo_fit$meta$priors$density_slope
  density_part <- stats::dnorm(
    draws_of_term(weight_nereo_fit, "density_slope"),
    p$mean,
    p$sd,
    log = TRUE
  )
  expect_equal(log_prior(dropped), full - density_part)
})

test_that("log_prior follows the fit's stored hyperparameters", {
  fit <- wetdry_nereo_fit
  wider <- fit
  wider$meta$priors$intercept <- kb_prior_normal(mean = 0, sd = 10)
  expect_false(isTRUE(all.equal(log_prior(fit), log_prior(wider))))
})

test_that("every fitted term of every model has a prior entry of its name", {
  fits <- list(
    weight_nereo_fit,
    weight_macro_fit,
    size_nereo_fit,
    size_macro_fit,
    density_nereo_fit,
    density_macro_fit,
    wetdry_nereo_fit,
    wetdry_macro_fit,
    carbon_nereo_fit,
    carbon_macro_fit,
    cover_biomass_nereo_fit,
    cover_biomass_macro_fit
  )
  for (fit in fits) {
    expect_true(all(fit$meta$terms$fixed %in% names(fit$meta$priors)))
    expect_true(all(is.finite(log_prior(fit))))
  }
})
