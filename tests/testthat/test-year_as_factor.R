test_that("year_as_factor converts a numeric year to a factor in numeric order", {
  x <- data.frame(site = "a", year = c(2021, 2019, 2020))
  out <- year_as_factor(x)
  expect_identical(out$year, factor(c("2021", "2019", "2020"), levels = c("2019", "2020", "2021")))
  expect_identical(out$site, x$site)
})

test_that("year_as_factor leaves character, factor, and absent years alone", {
  x <- data.frame(year = c("2020", "2021"))
  expect_identical(year_as_factor(x), x)
  y <- data.frame(year = factor("2020"))
  expect_identical(year_as_factor(y), y)
  z <- data.frame(site = "a")
  expect_identical(year_as_factor(z), z)
})
