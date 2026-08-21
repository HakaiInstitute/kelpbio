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

test_that("macro log_lik returns a D x N matrix usable by loo", {
  ll <- log_lik(weight_macro_fit)
  expect_equal(ncol(ll), nrow(weight_macro_fit$data))
  expect_equal(nrow(ll), posterior::ndraws(weight_macro_fit$draws))
  skip_if_not_installed("loo")
  expect_s3_class(suppressWarnings(loo::loo(ll)), "loo")
})

test_that("log_lik is deterministic", {
  # Recomputed from the draws, so unlike posterior_predict() it must not depend
  # on the RNG state.
  expect_identical(log_lik(weight_fit), log_lik(weight_fit))
  expect_identical(log_lik(weight_macro_fit), log_lik(weight_macro_fit))
})

test_that("nereo log_lik matches the Student-t density computed directly", {
  # Independent of extras, so this pins the parameterisation (theta = 1/nu, and
  # the density is of log(weight), not weight) as well as the orientation.
  mu <- posterior_linpred(weight_fit)
  sw <- as.vector(posterior::draws_of(weight_fit$draws$sWeight))
  y <- log(weight_fit$data$weight)
  nu <- weight_fit$meta$nu
  expected <- t(vapply(
    seq_along(sw),
    function(d) stats::dt((y - mu[d, ]) / sw[d], df = nu, log = TRUE) - log(sw[d]),
    numeric(length(y))
  ))
  expect_equal(log_lik(weight_fit), expected, tolerance = 1e-10)
})

test_that("macro log_lik matches the Gamma density computed directly", {
  mu <- posterior_linpred(weight_macro_fit)
  shape <- as.vector(posterior::draws_of(weight_macro_fit$draws$shape))
  y <- weight_macro_fit$data$weight
  expected <- t(vapply(
    seq_along(shape),
    function(d) {
      stats::dgamma(y, shape = shape[d], rate = shape[d] / exp(mu[d, ]), log = TRUE)
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

test_that("log_lik on a kb_fit with no methods aborts, not falls through", {
  # Registered on kb_fit now, so this dispatches; the default is the guard.
  fake <- structure(
    list(data = data.frame(weight = 1), meta = list()),
    class = c("kb_fit_other", "kb_fit")
  )
  expect_error(log_lik(fake), "no method for a <kb_fit_other>")
})

test_that("the internal generic's default aborts for a fit with no method", {
  # The only guard once the public method accepts any kb_fit.
  expect_error(.log_lik(structure(list(), class = c("kb_fit_other", "kb_fit")), 1), "no method for a <kb_fit_other>")
})
