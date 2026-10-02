fit_with <- function(...) list(data = data.frame(...))

test_that("values beyond half the minimum or twice the maximum warn", {
  fit <- fit_with(diameter_mm = c(10, 50))
  expect_snapshot(warn_outside_range(fit, c(3, 30, 150), "diameter_mm"))
  expect_warning(warn_outside_range(fit, 4, "diameter_mm"), "far outside")
  expect_warning(warn_outside_range(fit, 101, "diameter_mm"), "far outside")
})

test_that("values within twice the fitted range do not warn", {
  fit <- fit_with(diameter_mm = c(10, 50))
  expect_no_warning(warn_outside_range(fit, c(5, 30, 100, NA), "diameter_mm"))
})

test_that("a column without a unit gets no unit hint", {
  expect_snapshot(warn_outside_range(fit_with(fronds = c(1, 20)), 100, "fronds"))
})

test_that("nothing is compared for a fit with no observations", {
  fit <- fit_with(diameter_mm = numeric(0))
  expect_no_warning(warn_outside_range(fit, 1000, "diameter_mm"))
})

test_that("lower = FALSE checks only the upper side", {
  fit <- fit_with(stipes_m2 = c(1, 8))
  expect_no_warning(warn_outside_range(fit, 0.1, "stipes_m2", lower = FALSE))
  expect_warning(warn_outside_range(fit, 20, "stipes_m2", lower = FALSE), "far outside")
})
