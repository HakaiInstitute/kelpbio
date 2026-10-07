test_that("validate_by normalises NULL and passes a valid grouping through", {
  expect_identical(validate_by(NULL), character(0))
  expect_identical(validate_by("site"), "site")
  expect_identical(validate_by("year"), "year")
  expect_identical(validate_by(c("site", "year")), c("site", "year"))
})

test_that("validate_by rejects a factor no model groups by", {
  expect_error(validate_by("bogus"), "Invalid")
  expect_error(validate_by(1), "character")
})
