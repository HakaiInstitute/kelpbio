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

test_that("the nereo size mean is the inverse log link", {
  lp <- lp_rvar(size_nereo_fit, c(3, 3.5))
  expect_equal(.epred(size_nereo_fit, lp), exp(lp))
})

test_that("the wet/dry and carbon means are the inverse logit", {
  for (fit in list(wetdry_nereo_fit, carbon_nereo_fit)) {
    lp <- lp_rvar(fit, c(-2.4, -1))
    out <- .epred(fit, lp)
    expect_s3_class(out, "rvar")
    expect_equal(posterior::draws_of(out), stats::plogis(posterior::draws_of(lp)))
  }
})

test_that("cover calibration expectation multiplies mu by the presence probability", {
  fit <- cover_calibration_nereo_fit
  grid <- data.frame(canopy_area_m2 = c(0, 5), plot_area_m2 = 100, canopy_tide_height_m = 0)
  lp <- .linpred(fit, grid, new_levels = "average")
  expect_equal(.epred(fit, lp, grid = grid), exp(lp) / (1 + exp(-presence_logit(fit, grid))))
  expect_equal(.epred(fit, lp, expectation = FALSE, grid = grid), exp(lp))
  fit$meta$presence_on <- FALSE
  expect_equal(.epred(fit, lp, grid = grid), exp(lp))
})
