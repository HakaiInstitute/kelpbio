test_that("validate_by normalises NULL and passes a valid grouping through", {
  expect_identical(validate_by(weight_fit, NULL), character(0))
  expect_identical(validate_by(weight_fit, "site"), "site")
  expect_identical(
    validate_by(weight_fit, c("site", "year")),
    c("site", "year")
  )
})

test_that("validate_by rejects a factor no model groups by", {
  expect_error(validate_by(weight_fit, "bogus"), "Invalid")
  expect_error(validate_by(weight_macro_fit, "bogus"), "Invalid")
  expect_error(validate_by(weight_fit, 1), "character")
})

test_that("year alone is available for both species", {
  # Both weight models carry a year main effect, so the grouping axis no longer
  # varies by species and needs no per-model rule.
  expect_identical(validate_by(weight_fit, "year"), "year")
  expect_identical(validate_by(weight_macro_fit, "year"), "year")
})
