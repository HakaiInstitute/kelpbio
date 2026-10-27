# The corrected canopy at a single slope, as a numeric vector.
corrected <- function(canopy_area_m2, canopy_tide_height_m, slope, cap) {
  out <- tide_corrected_canopy(canopy_area_m2, canopy_tide_height_m, posterior::rvar(slope), cap)
  as.vector(posterior::draws_of(out))
}

test_that("tide_corrected_canopy divides canopy by one minus the tide share", {
  expect_equal(corrected(c(50, 0), c(1, 2), 0.2, cap = 1000), c(62.5, 0))
  expect_equal(corrected(30, 0, 0.2, cap = 1000), 30)
})

test_that("tide_corrected_canopy gives one value per draw", {
  out <- tide_corrected_canopy(50, 1, posterior::rvar(c(0.2, 0.3)), cap = 1000)
  expect_equal(posterior::draws_of(out)[, 1], c(62.5, 50 / 0.7), ignore_attr = TRUE)
})

test_that("the correction is capped, and takes the cap past the tide limit", {
  tide <- c(0, 2, 3.5, 5)
  # 1 - 0.25 * t is 1, 0.5, 0.125, and -0.25: 50, 100, 400 (50 / 0.125), and the cap
  expect_equal(corrected(rep(50, 4), tide, 0.25, cap = 400), c(50, 100, 400, 400))
  expect_equal(corrected(50, 3.5, 0.25, cap = 300), 300)
})

test_that("the cap is continuous across the tide limit", {
  expect_equal(corrected(50, 3.999, 0.25, cap = 400), 400)
  expect_equal(corrected(50, 4.001, 0.25, cap = 400), 400)
})

test_that("zero canopy stays zero at any tide", {
  expect_equal(corrected(c(0, 0), c(4, 5), 0.25, cap = 400), c(0, 0))
  out <- tide_corrected_canopy(0, 5, posterior::rvar(c(0.2, 0.3)), cap = 400)
  expect_equal(posterior::draws_of(out)[, 1], c(0, 0), ignore_attr = TRUE)
})

test_that("a negative tide height shrinks the corrected canopy", {
  expect_equal(corrected(50, -0.5, 0.2, cap = 400), 50 / 1.1)
})

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
