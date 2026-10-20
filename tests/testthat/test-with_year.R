test_that("with_year makes year a factor after site", {
  d <- data.frame(diameter_mm = 30, year = c("2021", "2019"), site = "a")
  out <- with_year(d)
  expect_named(out, c("diameter_mm", "site", "year"))
  expect_identical(levels(out$year), c("2019", "2021"))
  expect_identical(as.character(out$year), c("2021", "2019"))
})

test_that("with_year gives a numeric year its character level", {
  out <- with_year(data.frame(site = "a", year = c(2021, 2019)))
  expect_identical(levels(out$year), c("2019", "2021"))
})

test_that("with_year keeps a factor's level order", {
  d <- data.frame(site = "a", year = factor(c("2021", "2019"), levels = c("2021", "2019")))
  expect_identical(levels(with_year(d)$year), c("2021", "2019"))
})
