test_that("residuals returns a finite deviance-residual vector", {
  r <- residuals(weight_nereo_fit)
  expect_type(r, "double")
  expect_length(r, nobs(weight_nereo_fit))
  expect_true(all(is.finite(r)))
})

test_that("residuals are deviance, not raw response residuals", {
  a <- augment(weight_nereo_fit)
  expect_false(isTRUE(all.equal(a$residual, a$weight_kg - a$fitted)))
})

# Computed without .obs_family(), so the residual is pinned independently of
# it; the per-model parameterisation is checked by test-log_lik.R.
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
  sw <- draw_vec(weight_nereo_fit, "sd_residual")
  y <- log(weight_nereo_fit$data$weight_kg)
  expected <- median_residual(weight_nereo_fit, function(mu, d) {
    extras::res_norm(y, mu, sd = sw[d])
  })
  expect_equal(residuals(weight_nereo_fit), expected, tolerance = 1e-10)
})

test_that("residuals rejects a non-fit and extra args", {
  expect_error(residuals.kb_fit(1), "must be a <kb_fit> object")
  expect_error(
    residuals(weight_nereo_fit, type = "pearson"),
    class = "rlib_error_dots_nonempty"
  )
})
