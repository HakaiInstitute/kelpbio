test_that("log_lik returns a D x N matrix usable by loo", {
  ll <- log_lik(weight_nereo_fit)
  expect_true(is.matrix(ll))
  # loo::loo() silently accepts a transposed matrix.
  expect_equal(ncol(ll), nrow(weight_nereo_fit$data))
  expect_equal(nrow(ll), posterior::ndraws(weight_nereo_fit$draws))
  skip_if_not_installed("loo")
  expect_s3_class(suppressWarnings(loo::loo(ll)), "loo")
})

test_that("nereo log_lik is the lognormal density of weight", {
  # Lognormal density of weight: Normal density of log weight minus log weight.
  mu <- posterior_linpred(weight_nereo_fit)
  sw <- as.vector(posterior::draws_of(weight_nereo_fit$draws$sd_residual))
  y <- weight_nereo_fit$data$weight_kg
  expected <- t(vapply(
    seq_along(sw),
    function(d) stats::dnorm(log(y), mu[d, ], sw[d], log = TRUE) - log(y),
    numeric(length(y))
  ))
  expect_equal(log_lik(weight_nereo_fit), expected, tolerance = 1e-10)
})

test_that("macro log_lik matches the Gamma density computed directly", {
  mu <- posterior_linpred(weight_macro_fit)
  shape <- as.vector(posterior::draws_of(weight_macro_fit$draws$shape))
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

test_that("nereo size log_lik matches the Weibull density computed directly", {
  mu <- exp(posterior_linpred(size_nereo_fit))
  shape <- as.vector(posterior::draws_of(size_nereo_fit$draws$shape))
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

test_that("wet/dry log_lik matches the Beta density of the ratio computed directly", {
  mu <- stats::plogis(posterior_linpred(wetdry_nereo_fit))
  precision <- as.vector(posterior::draws_of(wetdry_nereo_fit$draws$precision))
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
  precision <- as.vector(posterior::draws_of(carbon_macro_fit$draws$precision))
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

test_that("cover log_lik is the censored Normal density of the survey biomass", {
  fit <- cover_calibration_nereo_fit
  mu <- exp(posterior_linpred(fit))
  sd_residual <- as.vector(posterior::draws_of(fit$draws$sd_residual))
  cv_residual <- as.vector(posterior::draws_of(fit$draws$cv_residual))
  y <- fit$data$biomass_kg_m2
  biomass_sd <- fit$data$biomass_sd_kg_m2
  expected <- t(vapply(
    seq_len(nrow(mu)),
    function(d) {
      sd <- sqrt(sd_residual[d]^2 + (cv_residual[d] * mu[d, ])^2 + biomass_sd^2)
      ifelse(
        y == 0,
        stats::pnorm(0, mu[d, ], sd, log.p = TRUE),
        stats::dnorm(y, mu[d, ], sd, log = TRUE)
      )
    },
    numeric(length(y))
  ))
  expect_equal(log_lik(fit), expected, tolerance = 1e-10, ignore_attr = TRUE)
})

test_that("cover log_lik past the tide limit is finite and equals full cover", {
  fit <- cover_calibration_nereo_fit
  i <- which(fit$data$canopy_area_m2 > 0)[1]
  # one over the smallest slope draw, so every draw is past the limit
  limit <- 1 / min(posterior::draws_of(fit$draws$tide_height_slope))
  high <- fit
  high$data$canopy_tide_height_m[i] <- limit + 0.1
  full <- fit
  full$data$canopy_area_m2[i] <- full$data$plot_area_m2[i]
  full$data$canopy_tide_height_m[i] <- 0
  expect_true(all(is.finite(log_lik(high)[, i])))
  expect_equal(log_lik(high)[, i], log_lik(full)[, i])
})

test_that("log_lik agrees with the Stan model's likelihood for every model", {
  skip_on_cran()
  fits <- list(
    weight_nereo_fit,
    omit_terms(weight_nereo_fit, "weight_floor"),
    weight_macro_fit,
    size_nereo_fit,
    wetdry_nereo_fit,
    wetdry_macro_fit,
    carbon_nereo_fit,
    carbon_macro_fit,
    cover_calibration_nereo_fit,
    cover_calibration_macro_fit
  )
  for (fit in fits) {
    stan <- stan_log_lik(fit)
    gap <- rowSums(log_lik(stan$fit)) - stan$lp
    expect_equal(gap, rep(gap[1], length(gap)), tolerance = 1e-8, label = paste(c(class(fit)[1], fit$meta$form), collapse = " "))
  }
})
