test_that("tide_corrected_cover scales canopy by tide and caps at the plot", {
  grid <- data.frame(
    canopy_area_m2 = c(50, 0, 90),
    plot_area_m2 = c(100, 100, 100),
    tide_height_m = c(1, 1, 1)
  )
  slope <- posterior::rvar(c(0.2, 0.3))
  cover <- posterior::draws_of(tide_corrected_cover(grid, slope))
  expect_equal(cover[, 1], c(0.6, 0.65), ignore_attr = TRUE)
  expect_equal(cover[, 2], c(0, 0), ignore_attr = TRUE)
  # 90 * 1.2 = 108 and 90 * 1.3 = 117 both exceed the plot, so cover is 1.
  expect_equal(cover[, 3], c(1, 1), ignore_attr = TRUE)
})

test_that("zero tide height leaves the raw cover", {
  grid <- data.frame(canopy_area_m2 = 30, plot_area_m2 = 200, tide_height_m = 0)
  cover <- tide_corrected_cover(grid, posterior::rvar(c(0.2, 0.3)))
  expect_equal(posterior::draws_of(cover)[, 1], c(0.15, 0.15), ignore_attr = TRUE)
})
