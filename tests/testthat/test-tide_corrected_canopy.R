test_that("tide_corrected_canopy divides canopy by one minus the tide share", {
  expect_equal(tide_corrected_canopy(c(50, 0), c(1, 2), 0.2, cap = 1000), c(62.5, 0))
  expect_equal(tide_corrected_canopy(30, 0, 0.2, cap = 1000), 30)
})

test_that("tide_corrected_canopy takes a slope rvar", {
  out <- tide_corrected_canopy(50, 1, posterior::rvar(c(0.2, 0.3)), cap = 1000)
  expect_equal(posterior::draws_of(out)[, 1], c(62.5, 50 / 0.7), ignore_attr = TRUE)
})

test_that("the correction is capped, and takes the cap past the tide limit", {
  tide <- c(0, 2, 3.5, 5)
  out <- tide_corrected_canopy(rep(50, 4), tide, 0.25, cap = 400)
  # 1 - 0.25 * t is 1, 0.5, 0.125, and -0.25: 50, 100, 400 (50 / 0.125), and the cap
  expect_equal(out, c(50, 100, 400, 400))
  expect_equal(tide_corrected_canopy(50, 3.5, 0.25, cap = 300), 300)
})

test_that("the cap is continuous across the tide limit", {
  below <- tide_corrected_canopy(50, 3.999, 0.25, cap = 400)
  above <- tide_corrected_canopy(50, 4.001, 0.25, cap = 400)
  expect_equal(below, 400)
  expect_equal(above, 400)
})

test_that("zero canopy stays zero at any tide", {
  expect_equal(tide_corrected_canopy(c(0, 0), c(4, 5), 0.25, cap = 400), c(0, 0))
  out <- tide_corrected_canopy(0, 5, posterior::rvar(c(0.2, 0.3)), cap = 400)
  expect_equal(posterior::draws_of(out)[, 1], c(0, 0), ignore_attr = TRUE)
})

test_that("a negative tide height shrinks the corrected canopy", {
  expect_lt(tide_corrected_canopy(50, -0.5, 0.2, cap = 400), 50)
  expect_equal(tide_corrected_canopy(50, -0.5, 0.2, cap = 400), 50 / 1.1)
})
