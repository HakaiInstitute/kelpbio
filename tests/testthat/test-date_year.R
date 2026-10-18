test_that("date_year is the character year of a date", {
  expect_identical(date_year(as.Date(c("2019-08-01", "2021-07-15"))), c("2019", "2021"))
})
