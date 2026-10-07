test_that("residuals returns a finite deviance-residual vector", {
  r <- residuals(weight_fit)
  expect_type(r, "double")
  expect_length(r, nobs(weight_fit))
  expect_true(all(is.finite(r)))
})

test_that("residuals are deviance, not raw response residuals", {
  a <- augment(weight_fit)
  expect_false(isTRUE(all.equal(a$residual, a$weight_kg - a$fitted)))
})

# The posterior median of a residual function evaluated at each draw of the
# observed linear predictor, computed without the observation family so these
# tests pin each model's residual independently of it.
median_residual <- function(fit, f) {
  mu <- posterior::draws_of(.linpred_obs(fit))
  per_draw <- t(vapply(
    seq_len(nrow(mu)),
    function(d) f(mu[d, ], d),
    numeric(ncol(mu))
  ))
  as.numeric(apply(per_draw, 2L, stats::median))
}

draw_vec <- function(fit, name) {
  as.vector(posterior::draws_of(fit$draws[[name]]))
}

test_that("nereo weight residuals are Normal deviance residuals of log weight", {
  sw <- draw_vec(weight_fit, "sd_residual")
  y <- log(weight_fit$data$weight_kg)
  expected <- median_residual(weight_fit, function(mu, d) {
    extras::res_norm(y, mu, sd = sw[d])
  })
  expect_equal(residuals(weight_fit), expected, tolerance = 1e-10)
})

test_that("macro weight residuals are Gamma deviance residuals", {
  shape <- draw_vec(weight_macro_fit, "shape")
  y <- weight_macro_fit$data$weight_kg
  expected <- median_residual(weight_macro_fit, function(mu, d) {
    extras::res_gamma(y, shape = shape[d], rate = shape[d] / exp(mu))
  })
  expect_equal(residuals(weight_macro_fit), expected, tolerance = 1e-10)
})

test_that("residuals rejects a non-fit and extra args", {
  expect_error(residuals.kb_fit(1), "must be a <kb_fit> object")
  expect_error(
    residuals(weight_fit, type = "pearson"),
    class = "rlib_error_dots_nonempty"
  )
})

test_that("size residuals are deviance residuals from the size likelihoods", {
  shape <- draw_vec(size_nereo_fit, "shape")
  y <- size_nereo_fit$data$diameter_mm
  expected <- median_residual(size_nereo_fit, function(mu, d) {
    res_weibull(y, shape[d], weibull_scale(exp(mu), shape[d]))
  })
  expect_equal(residuals(size_nereo_fit), expected, tolerance = 1e-10)

  theta <- draw_vec(size_macro_fit, "dispersion")
  y <- size_macro_fit$data$fronds
  expected <- median_residual(size_macro_fit, function(mu, d) {
    res_gamma_pois_zt(y, exp(mu), theta[d])
  })
  r <- residuals(size_macro_fit)
  expect_true(all(is.finite(r)))
  expect_equal(r, expected, tolerance = 1e-10)
})

test_that("density residuals are deviance residuals from the count likelihoods", {
  theta <- draw_vec(density_nereo_fit, "dispersion")
  zi <- stats::plogis(draw_vec(density_nereo_fit, "logit_zero_inflation"))
  y <- density_nereo_fit$data$stipes
  expected <- median_residual(density_nereo_fit, function(mu, d) {
    extras::res_gamma_pois_zi(y, exp(mu), theta[d], prob = zi[d])
  })
  expect_equal(residuals(density_nereo_fit), expected, tolerance = 1e-10)

  theta <- draw_vec(density_macro_fit, "dispersion")
  y <- density_macro_fit$data$plants
  expected <- median_residual(density_macro_fit, function(mu, d) {
    extras::res_gamma_pois(y, exp(mu), theta[d])
  })
  r <- residuals(density_macro_fit)
  expect_true(all(is.finite(r)))
  expect_equal(r, expected, tolerance = 1e-10)
})

test_that("wet/dry residuals are Beta deviance residuals of the ratio", {
  for (fit in list(wetdry_nereo_fit, wetdry_macro_fit)) {
    precision <- draw_vec(fit, "precision")
    y <- fit$data$dry_mass_g / fit$data$wet_mass_g
    expected <- median_residual(fit, function(mu, d) {
      m <- stats::plogis(mu)
      res_beta(y, m * precision[d], (1 - m) * precision[d])
    })
    r <- residuals(fit)
    expect_true(all(is.finite(r)))
    expect_equal(r, expected, tolerance = 1e-10)
  }
})

test_that("carbon residuals are finite Beta deviance residuals", {
  for (fit in list(carbon_nereo_fit, carbon_macro_fit)) {
    r <- residuals(fit)
    expect_length(r, nobs(fit))
    expect_true(all(is.finite(r)))
  }
})

test_that("cover residuals are the log-scale residuals over the scaled in situ SD", {
  for (fit in list(cover_biomass_nereo_fit, cover_biomass_macro_fit)) {
    r <- residuals(fit)
    expect_length(r, nobs(fit))
    expect_true(all(is.finite(r)))
  }
})
