test_that("tide_corrected_cover corrects canopy for tide and caps at the plot", {
  grid <- data.frame(
    canopy_area_m2 = c(50, 0, 90),
    plot_area_m2 = c(100, 100, 100),
    canopy_tide_height_m = c(1, 1, 1)
  )
  slope <- posterior::rvar(c(0.2, 0.3))
  cover <- posterior::draws_of(tide_corrected_cover(grid, slope))
  expect_equal(cover[, 1], c(0.625, 0.5 / 0.7), ignore_attr = TRUE)
  expect_equal(cover[, 2], c(0, 0), ignore_attr = TRUE)
  # 90 / 0.8 = 112.5 and 90 / 0.7 = 128.6 both exceed the plot, so cover is 1.
  expect_equal(cover[, 3], c(1, 1), ignore_attr = TRUE)
})

test_that("zero tide height leaves the raw cover", {
  grid <- data.frame(canopy_area_m2 = 30, plot_area_m2 = 200, canopy_tide_height_m = 0)
  cover <- tide_corrected_cover(grid, posterior::rvar(c(0.2, 0.3)))
  expect_equal(posterior::draws_of(cover)[, 1], c(0.15, 0.15), ignore_attr = TRUE)
})

test_that("a plot past the tide limit is fully covered unless it has no canopy", {
  grid <- data.frame(canopy_area_m2 = c(20, 0), plot_area_m2 = 200, canopy_tide_height_m = 5)
  cover <- posterior::draws_of(tide_corrected_cover(grid, posterior::rvar(c(0.2, 0.3))))
  expect_equal(cover[, 1], c(1, 1), ignore_attr = TRUE)
  expect_equal(cover[, 2], c(0, 0), ignore_attr = TRUE)
})

test_that("presence_logit is linear in percent tide-corrected cover", {
  fit <- cover_calibration_nereo_fit
  grid <- data.frame(canopy_area_m2 = c(0, 5), plot_area_m2 = 100, canopy_tide_height_m = 0)
  logit_p <- posterior::draws_of(presence_logit(fit, grid))
  dim(logit_p) <- c(nrow(logit_p), 2L)
  intercept <- as.vector(posterior::draws_of(fit$draws$presence_intercept))
  slope <- as.vector(posterior::draws_of(fit$draws$presence_cover_slope))
  expect_equal(logit_p[, 1], intercept)
  expect_equal(logit_p[, 2], intercept + slope * 5)
})
