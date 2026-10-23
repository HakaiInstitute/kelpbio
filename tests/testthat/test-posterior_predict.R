test_that("posterior_predict recomputes replicates at the observed data", {
  withr::local_seed(1)
  yrep <- posterior_predict(weight_nereo_fit)
  expect_true(is.matrix(yrep))
  expect_equal(ncol(yrep), nrow(weight_nereo_fit$data))
  expect_equal(nrow(yrep), posterior::ndraws(weight_nereo_fit$draws))
  expect_true(all(yrep > 0))
  # The median of a lognormal replicate is exp() of the linear predictor.
  med <- posterior_linpred(weight_nereo_fit, transform = TRUE)
  expect_equal(
    stats::median(apply(yrep, 2, stats::median)),
    stats::median(apply(med, 2, stats::median)),
    tolerance = 0.1
  )
})

test_that("posterior_predict is reproducible under a seed and not otherwise", {
  a <- withr::with_seed(7, posterior_predict(weight_nereo_fit))
  b <- withr::with_seed(7, posterior_predict(weight_nereo_fit))
  expect_identical(a, b)
  expect_false(identical(a, withr::with_seed(8, posterior_predict(weight_nereo_fit))))
})

test_that("a zero-observation fit still predicts at supplied new_data", {
  fit0 <- weight_nereo_fit
  fit0$data <- fit0$data[0, ]
  pp <- posterior_predict(
    fit0,
    new_data = data.frame(diameter_mm = c(20, 40)),
    new_levels = "average"
  )
  expect_equal(dim(pp), c(posterior::ndraws(fit0$draws), 2L))
})

test_that("posterior_predict at new data is wider than posterior_epred", {
  nd <- data.frame(diameter_mm = c(20, 40, 60))
  pp <- posterior_predict(weight_nereo_fit, new_data = nd, new_levels = "average")
  ep <- posterior_epred(weight_nereo_fit, new_data = nd, new_levels = "average")
  expect_equal(dim(pp), dim(ep))
  # On the log scale, as on the natural scale a few extreme draws of the
  # expected weight dominate the SD.
  expect_true(all(apply(log(pp), 2, stats::sd) > apply(log(ep), 2, stats::sd)))
})

test_that("cover posterior_predict draws biomass of at least zero", {
  nd <- data.frame(canopy_area_m2 = c(0, 40), plot_area_m2 = 200, canopy_tide_height_m = 0.5)
  withr::local_seed(1)
  pp <- posterior_predict(cover_calibration_nereo_fit, nd)
  expect_equal(ncol(pp), 2L)
  expect_true(all(pp >= 0))
  withr::local_seed(1)
  wider <- posterior_predict(cover_calibration_nereo_fit, transform(nd, biomass_sd_kg_m2 = 5))
  expect_gt(stats::sd(wider[, 2]), stats::sd(pp[, 2]))
})

test_that("errors name posterior_predict()", {
  err <- expect_error(posterior_predict(weight_nereo_fit, data.frame(diameter_mm = -1)))
  expect_identical(err$call[[1]], quote(posterior_predict))
  err <- expect_error(posterior_predict(weight_nereo_fit, NULL, 1))
  expect_identical(err$call[[1]], quote(posterior_predict))
})
