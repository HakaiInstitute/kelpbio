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

test_that("the available combinations follow the fit, not a species string", {
  # Nereo has no year main effect, so year alone is unavailable; macro has one.
  expect_error(validate_by(weight_fit, "year"), "not available")
  expect_identical(validate_by(weight_macro_fit, "year"), "year")
  # Nereo still allows year alongside site, where it enters as the interaction.
  expect_identical(
    validate_by(weight_fit, c("site", "year")),
    c("site", "year")
  )
})

test_that(".chk_by returns the grouping invisibly when it is available", {
  expect_invisible(.chk_by(weight_macro_fit, "year"))
  expect_identical(.chk_by(weight_fit, "site"), "site")
})
