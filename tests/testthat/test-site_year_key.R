test_that("site_year_key joins site and year with a colon", {
  expect_identical(
    site_year_key(factor(c("a", "b")), c(2020, 2021)),
    c("a:2020", "b:2021")
  )
})
