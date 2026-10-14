test_that("tide_corrected_canopy scales canopy by tide height", {
  expect_equal(tide_corrected_canopy(c(50, 0), c(1, 2), 0.2), c(60, 0))
  expect_equal(tide_corrected_canopy(30, 0, 0.2), 30)
})

test_that("tide_corrected_canopy takes a slope rvar", {
  out <- tide_corrected_canopy(50, 1, posterior::rvar(c(0.2, 0.3)))
  expect_equal(posterior::draws_of(out)[, 1], c(60, 65), ignore_attr = TRUE)
})
