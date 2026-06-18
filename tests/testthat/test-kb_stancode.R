test_that("kb_stancode returns the Stan source", {
  code <- kb_stancode(weight_fit)
  expect_type(code, "character")
  expect_match(code, "bWeight30")
})
