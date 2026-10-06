test_that("log_lik returns a D x N matrix usable by loo", {
  ll <- log_lik(weight_fit)
  expect_true(is.matrix(ll))
  # Orientation guard: a transposed matrix is accepted by loo::loo() without
  # complaint and silently reports elpd over draws instead of observations.
  expect_equal(ncol(ll), nrow(weight_fit$data))
  expect_equal(nrow(ll), posterior::ndraws(weight_fit$draws))
  skip_if_not_installed("loo")
  expect_s3_class(suppressWarnings(loo::loo(ll)), "loo")
})

test_that("nereo log_lik matches the Normal density computed directly", {
  # Independent of extras, so this pins the parameterisation (the density is of
  # log(weight), not weight) as well as the orientation.
  mu <- posterior_linpred(weight_fit)
  sw <- as.vector(posterior::draws_of(weight_fit$draws$sWeight))
  y <- log(weight_fit$data$weight_kg)
  expected <- t(vapply(
    seq_along(sw),
    function(d) stats::dnorm(y, mu[d, ], sw[d], log = TRUE),
    numeric(length(y))
  ))
  expect_equal(log_lik(weight_fit), expected, tolerance = 1e-10)
})

test_that("macro log_lik matches the Gamma density computed directly", {
  mu <- posterior_linpred(weight_macro_fit)
  shape <- as.vector(posterior::draws_of(weight_macro_fit$draws$bShape))
  y <- weight_macro_fit$data$weight_kg
  expected <- t(vapply(
    seq_along(shape),
    function(d) {
      stats::dgamma(
        y,
        shape = shape[d],
        rate = shape[d] / exp(mu[d, ]),
        log = TRUE
      )
    },
    numeric(length(y))
  ))
  expect_equal(log_lik(weight_macro_fit), expected, tolerance = 1e-10)
})

test_that("log_lik aborts for a zero-observation fit", {
  fit0 <- weight_fit
  fit0$data <- fit0$data[0, ]
  expect_error(log_lik(fit0), "zero-observation fit")
})

test_that("nereo size log_lik matches the Weibull density computed directly", {
  mu <- exp(posterior_linpred(size_nereo_fit))
  shape <- as.vector(posterior::draws_of(size_nereo_fit$draws$bShape))
  y <- size_nereo_fit$data$diameter_mm
  expected <- t(vapply(
    seq_along(shape),
    function(d) {
      stats::dweibull(
        y,
        shape[d],
        mu[d, ] / gamma(1 + 1 / shape[d]),
        log = TRUE
      )
    },
    numeric(length(y))
  ))
  expect_equal(log_lik(size_nereo_fit), expected, tolerance = 1e-10)
})

test_that("macro size log_lik matches the truncated negative binomial computed directly", {
  mu <- exp(posterior_linpred(size_macro_fit))
  theta <- as.vector(posterior::draws_of(size_macro_fit$draws$bDispersion))
  y <- size_macro_fit$data$fronds
  expected <- t(vapply(
    seq_along(theta),
    function(d) {
      size <- 1 / theta[d]
      stats::dnbinom(y, mu = mu[d, ], size = size, log = TRUE) -
        log(1 - stats::dnbinom(0, mu = mu[d, ], size = size))
    },
    numeric(length(y))
  ))
  expect_equal(log_lik(size_macro_fit), expected, tolerance = 1e-8)
})

test_that("nereo density log_lik matches the zero-inflated negative binomial computed directly", {
  mu <- exp(posterior_linpred(density_nereo_fit))
  theta <- as.vector(posterior::draws_of(density_nereo_fit$draws$bDispersion))
  zi <- stats::plogis(
    as.vector(posterior::draws_of(density_nereo_fit$draws$bZeroInflation))
  )
  y <- density_nereo_fit$data$stipes
  expected <- t(vapply(
    seq_len(nrow(mu)),
    function(d) {
      p <- (1 - zi[d]) * stats::dnbinom(y, mu = mu[d, ], size = 1 / theta[d])
      log(p + zi[d] * (y == 0))
    },
    numeric(length(y))
  ))
  expect_equal(log_lik(density_nereo_fit), expected, tolerance = 1e-8)
})

test_that("macro density log_lik matches the negative binomial computed directly", {
  mu <- exp(posterior_linpred(density_macro_fit))
  theta <- as.vector(posterior::draws_of(density_macro_fit$draws$bDispersion))
  y <- density_macro_fit$data$plants
  expected <- t(vapply(
    seq_len(nrow(mu)),
    function(d) stats::dnbinom(y, mu = mu[d, ], size = 1 / theta[d], log = TRUE),
    numeric(length(y))
  ))
  expect_equal(log_lik(density_macro_fit), expected, tolerance = 1e-8)
})

test_that("the density log-likelihood uses each transect's area", {
  fit <- density_macro_fit
  doubled <- fit
  doubled$data$area_m2 <- 2 * doubled$data$area_m2
  expect_false(isTRUE(all.equal(log_lik(fit), log_lik(doubled))))
})

test_that("wet/dry log_lik matches the Beta density of the ratio computed directly", {
  mu <- stats::plogis(posterior_linpred(wetdry_nereo_fit))
  precision <- as.vector(posterior::draws_of(wetdry_nereo_fit$draws$bPrecision))
  y <- wetdry_nereo_fit$data$dry_mass_g / wetdry_nereo_fit$data$wet_mass_g
  expected <- t(vapply(
    seq_len(nrow(mu)),
    function(d) {
      stats::dbeta(
        y,
        mu[d, ] * precision[d],
        (1 - mu[d, ]) * precision[d],
        log = TRUE
      )
    },
    numeric(length(y))
  ))
  expect_equal(log_lik(wetdry_nereo_fit), expected, tolerance = 1e-10)
})

test_that("carbon log_lik matches the Beta density of the fraction computed directly", {
  mu <- stats::plogis(posterior_linpred(carbon_macro_fit))
  precision <- as.vector(posterior::draws_of(carbon_macro_fit$draws$bPrecision))
  y <- carbon_fraction(carbon_macro_fit$data)
  expected <- t(vapply(
    seq_len(nrow(mu)),
    function(d) {
      stats::dbeta(
        y,
        mu[d, ] * precision[d],
        (1 - mu[d, ]) * precision[d],
        log = TRUE
      )
    },
    numeric(length(y))
  ))
  expect_equal(log_lik(carbon_macro_fit), expected, tolerance = 1e-10)
})

test_that("cover log_lik is the Normal density of the log estimate with its Jacobian", {
  fit <- cover_biomass_nereo_fit
  mu <- posterior_linpred(fit)
  scaling <- as.vector(posterior::draws_of(fit$draws$bScaling))
  sd_log <- cover_log_sd(fit$data$lower, fit$data$upper, 0.95)
  y <- fit$data$estimate
  expected <- t(vapply(
    seq_len(nrow(mu)),
    function(d) {
      stats::dlnorm(y, mu[d, ], scaling[d] * sd_log, log = TRUE)
    },
    numeric(length(y))
  ))
  expect_equal(log_lik(fit), expected, tolerance = 1e-10, ignore_attr = TRUE)
})
