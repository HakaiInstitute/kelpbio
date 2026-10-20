# A link-scale rvar shaped as .linpred() returns it.
lp_rvar <- function(fit, values) {
  nd <- posterior::ndraws(fit$draws)
  posterior::rvar(
    matrix(rep(values, each = nd), nrow = nd),
    nchains = posterior::nchains(fit$draws)
  )
}

test_that(".epred is the inverse log link for macro and the nereo median", {
  lp <- lp_rvar(weight_macro_fit, c(0, 1))
  expect_equal(.epred(weight_macro_fit, lp), exp(lp))
  expect_equal(.epred(weight_macro_fit, lp, expectation = FALSE), exp(lp))
  lp <- lp_rvar(weight_nereo_fit, c(0, 1))
  expect_equal(.epred(weight_nereo_fit, lp, expectation = FALSE), exp(lp))
})

test_that("the nereo weight mean carries the lognormal retransformation", {
  lp <- lp_rvar(weight_nereo_fit, c(0, 1))
  expect_equal(
    .epred(weight_nereo_fit, lp),
    exp(lp + weight_nereo_fit$draws$sd_residual^2 / 2)
  )
})

test_that(".epred returns an rvar for every model", {
  fits <- list(
    weight_nereo_fit,
    weight_macro_fit,
    size_nereo_fit,
    wetdry_nereo_fit,
    carbon_nereo_fit,
    cover_calibration_nereo_fit
  )
  for (fit in fits) {
    out <- .epred(fit, lp_rvar(fit, c(0.5, 1)))
    expect_s3_class(out, "rvar")
    expect_length(out, 2L)
  }
})

test_that("the nereo size mean is the inverse log link", {
  lp <- lp_rvar(size_nereo_fit, c(3, 3.5))
  expect_equal(.epred(size_nereo_fit, lp), exp(lp))
})

test_that("the wet/dry and carbon means are the inverse logit", {
  for (fit in list(wetdry_nereo_fit, carbon_nereo_fit)) {
    lp <- lp_rvar(fit, c(-2.4, -1))
    expect_equal(
      posterior::draws_of(.epred(fit, lp)),
      stats::plogis(posterior::draws_of(lp))
    )
  }
})

test_that("the cover calibration mean is mu, the inverse log, with no retransformation", {
  lp <- lp_rvar(cover_calibration_nereo_fit, c(0.1, 0.5))
  expect_equal(.epred(cover_calibration_nereo_fit, lp), exp(lp))
  expect_equal(.epred(cover_calibration_nereo_fit, lp, expectation = FALSE), exp(lp))
})
