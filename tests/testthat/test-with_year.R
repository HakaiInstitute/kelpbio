test_that("with_year adds year from date, after site", {
  d <- data.frame(diameter_mm = 30, site = "a", date = as.Date(c("2021-08-01", "2019-07-15")))
  out <- with_year(d)
  expect_named(out, c("diameter_mm", "site", "year", "date"))
  expect_identical(levels(out$year), c("2019", "2021"))
  expect_identical(as.character(out$year), c("2021", "2019"))
})

test_that("with_year replaces a year column that agrees", {
  d <- data.frame(site = "a", year = 2021, date = as.Date("2021-08-01"))
  expect_true(is.factor(with_year(d)$year))
})
