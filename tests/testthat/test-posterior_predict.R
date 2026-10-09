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

test_that("posterior_predict aborts at observed data for a zero-observation fit", {
  fit0 <- weight_nereo_fit
  fit0$data <- fit0$data[0, ]
  expect_error(posterior_predict(fit0), "zero-observation fit")
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

test_that("macro posterior_predict draws positive Gamma noise, wider than epred", {
  withr::local_seed(1)
  nd <- data.frame(fronds = c(2, 5, 10))
  pp <- posterior_predict(
    weight_macro_fit,
    new_data = nd,
    new_levels = "average"
  )
  ep <- posterior_epred(weight_macro_fit, new_data = nd, new_levels = "average")
  expect_equal(dim(pp), dim(ep))
  expect_true(all(pp > 0)) # Gamma support is strictly positive
  # On the log scale, as on the natural scale a few extreme draws of the
  # expected weight dominate the SD.
  expect_true(all(apply(log(pp), 2, stats::sd) > apply(log(ep), 2, stats::sd)))
})

test_that("size posterior_predict draws plant sizes from the size likelihoods", {
  withr::local_seed(1)
  nd <- data.frame(site = fitted_sites(size_nereo_fit, 2))
  pp <- posterior_predict(size_nereo_fit, new_data = nd, new_levels = "average")
  expect_equal(dim(pp), c(posterior::ndraws(size_nereo_fit$draws), 2L))
  expect_true(all(pp > 0))

  nd <- data.frame(site = fitted_sites(size_macro_fit, 2))
  pm <- posterior_predict(size_macro_fit, new_data = nd, new_levels = "average")
  expect_true(all(pm >= 1))
  expect_true(all(pm == round(pm)))
  ep <- posterior_epred(size_macro_fit, new_data = nd, new_levels = "average")
  expect_equal(colMeans(pm), colMeans(ep), tolerance = 0.15)
})

test_that("density posterior_predict draws transect counts", {
  withr::local_seed(1)
  for (fit in list(density_nereo_fit, density_macro_fit)) {
    nd <- data.frame(site = fitted_sites(fit, 2), area_m2 = c(40, 80))
    pp <- posterior_predict(fit, new_data = nd, new_levels = "average")
    expect_equal(dim(pp), c(posterior::ndraws(fit$draws), 2L))
    expect_true(all(pp >= 0))
    expect_true(all(pp == round(pp)))
    ep <- posterior_epred(fit, new_data = nd, new_levels = "average")
    expect_equal(colMeans(pp), colMeans(ep), tolerance = 0.15)
  }
})

test_that("wet/dry posterior_predict draws ratios between 0 and 1", {
  withr::local_seed(1)
  pp <- posterior_predict(wetdry_nereo_fit)
  expect_equal(
    dim(pp),
    c(posterior::ndraws(wetdry_nereo_fit$draws), nobs(wetdry_nereo_fit))
  )
  expect_true(all(pp > 0 & pp < 1))
  ep <- posterior_epred(wetdry_nereo_fit)
  expect_equal(mean(pp), mean(ep), tolerance = 0.02)
})

test_that("carbon posterior_predict draws fractions between 0 and 1", {
  withr::local_seed(1)
  pp <- posterior_predict(carbon_nereo_fit)
  expect_true(all(pp > 0 & pp < 1))
  expect_equal(mean(pp), mean(posterior_epred(carbon_nereo_fit)), tolerance = 0.02)
})

test_that("cover posterior_predict draws positive estimates with the in situ precision", {
  withr::local_seed(1)
  pp <- posterior_predict(cover_biomass_nereo_fit)
  expect_equal(
    dim(pp),
    c(posterior::ndraws(cover_biomass_nereo_fit$draws), nobs(cover_biomass_nereo_fit))
  )
  expect_true(all(pp > 0))
  # Lognormal around the calibration mean, so the log median is log(epred).
  ep <- posterior_epred(cover_biomass_nereo_fit)
  expect_equal(
    stats::median(log(pp) - log(ep)),
    0,
    tolerance = 0.05
  )
})

test_that("cover posterior_predict needs the in situ limits in new_data", {
  nd <- data.frame(canopy_area_m2 = 40, plot_area_m2 = 200, tide_height_m = 0.5)
  expect_snapshot(posterior_predict(cover_biomass_nereo_fit, nd), error = TRUE)
  withr::local_seed(1)
  pp <- posterior_predict(
    cover_biomass_nereo_fit,
    transform(nd, lower = c(0.5), upper = c(2))
  )
  expect_equal(ncol(pp), 1L)
})

test_that("errors name posterior_predict()", {
  err <- expect_error(posterior_predict(weight_nereo_fit, data.frame(diameter_mm = -1)))
  expect_identical(err$call[[1]], quote(posterior_predict))
  err <- expect_error(posterior_predict(weight_nereo_fit, NULL, 1))
  expect_identical(err$call[[1]], quote(posterior_predict))
})
